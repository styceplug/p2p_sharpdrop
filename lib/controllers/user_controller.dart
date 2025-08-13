import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:p2p_sharpdrop/models/message_model.dart';
import 'package:p2p_sharpdrop/models/user_model.dart';
import 'package:p2p_sharpdrop/widgets/snackbars.dart';
import 'package:session_manager/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/api_client.dart';
import '../data/repo/user_repo.dart';
import '../models/channel_model.dart';
import '../routes/routes.dart';
import '../utils/app_constants.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final ApiClient apiClient;

  UserController({required this.userRepo, required this.apiClient});

  var isLoading = false.obs;
  var userDetail = Rxn<UserModel>();
  RxList<UserModel> referralList = <UserModel>[].obs;
  var channels = <ChannelModel>[].obs;
  ChannelChatModel? chatData;
  Rx<Map<String, ChannelChatModel>> chatDetails =
      Rx<Map<String, ChannelChatModel>>({});
  RxMap<String, ChannelChatModel> chatDetail = <String, ChannelChatModel>{}.obs;
  var channelDetails = {}.obs;
  List<MessageModel> messages = [];
  var isDeleting = false.obs;
  Rx<ChannelChatModel?> selectedChat = Rx<ChannelChatModel?>(null);
  // final RxList<ChannelModel> channelsWithChat = <ChannelModel>[].obs;
  // final RxList<ChannelModel> channelsWithoutChat = <ChannelModel>[].obs;
  final RxList<ChannelWithChatInfo> channelsWithChatInfo = <ChannelWithChatInfo>[].obs;
  final RxList<ChannelModel> channelsWithoutChat = <ChannelModel>[].obs;
  final RxList<ChannelWithChatInfo> searchChannelsWithChatInfo = <ChannelWithChatInfo>[].obs;
  final RxList<ChannelModel> searchChannelsWithoutChat = <ChannelModel>[].obs;
  var selectedAvatar = 'avatar1'.obs;
  final RxList<ChannelModel> searchChannelList = <ChannelModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initChannelsAndChats();
    loadSelectedAvatar();
  }




  void searchChannels(String query) {
    if (query.trim().isEmpty) {
      // Reset to original lists when search is empty
      searchChannelList.value = channels.value;
      searchChannelsWithChatInfo.value = channelsWithChatInfo.value;
      searchChannelsWithoutChat.value = channelsWithoutChat.value;
    } else {
      final lowercaseQuery = query.toLowerCase();

      // Search in channels with chat info
      searchChannelsWithChatInfo.value = channelsWithChatInfo
          .where((channelWithChat) =>
          channelWithChat.channel.name.toLowerCase().contains(lowercaseQuery))
          .toList();

      // Search in channels without chat
      searchChannelsWithoutChat.value = channelsWithoutChat
          .where((channel) =>
          channel.name.toLowerCase().contains(lowercaseQuery))
          .toList();

      // Update the combined search list
      final combinedSearchResults = [
        ...searchChannelsWithChatInfo.map((e) => e.channel),
        ...searchChannelsWithoutChat
      ];
      searchChannelList.value = combinedSearchResults;
    }
  }

  void searchChannelsAdvanced(String query) {
    if (query.trim().isEmpty) {
      // Reset to original lists when search is empty
      searchChannelList.value = channels.value;
      searchChannelsWithChatInfo.value = channelsWithChatInfo.value;
      searchChannelsWithoutChat.value = channelsWithoutChat.value;
    } else {
      final lowercaseQuery = query.toLowerCase();

      // Search in channels with chat info (search in multiple fields)
      searchChannelsWithChatInfo.value = channelsWithChatInfo
          .where((channelWithChat) {
        final channel = channelWithChat.channel;
        return channel.name.toLowerCase().contains(lowercaseQuery) ||
            (channel.name?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (channel.name?.toLowerCase().contains(lowercaseQuery) ?? false);
      })
          .toList();

      // Search in channels without chat
      searchChannelsWithoutChat.value = channelsWithoutChat
          .where((channel) {
        return channel.name.toLowerCase().contains(lowercaseQuery) ||
            (channel.name?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (channel.name?.toLowerCase().contains(lowercaseQuery) ?? false);
      })
          .toList();

      // Update the combined search list
      final combinedSearchResults = [
        ...searchChannelsWithChatInfo.map((e) => e.channel),
        ...searchChannelsWithoutChat
      ];
      searchChannelList.value = combinedSearchResults;
    }
  }

  Future<void> getChannels({bool forceRefresh = false}) async {
    print('🔄 getChannels called with forceRefresh: $forceRefresh');
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && channels.isEmpty) {
      print('📁 Checking cached channels...');

      final cachedWithChat = prefs.getString('cachedChannelsWithChat');
      final cachedWithoutChat = prefs.getString('cachedChannelsWithoutChat');

      if (cachedWithChat != null && cachedWithoutChat != null) {
        try {
          print('📥 Found cached data. Attempting to decode...');

          // Decode and parse channels with chat
          final decodedWithChat = jsonDecode(cachedWithChat) as List;
          channelsWithChatInfo.value = decodedWithChat
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();
          print('✅ Decoded channelsWithChat: ${channelsWithChatInfo.length}');

          // Decode and parse channels without chat
          final decodedWithoutChat = jsonDecode(cachedWithoutChat) as List;
          channelsWithoutChat.value = decodedWithoutChat
              .map((e) => ChannelModel.fromJson(e))
              .toList();
          print('✅ Decoded channelsWithoutChat: ${channelsWithoutChat.length}');

          // Combine into full channel list
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];
          channels.value = allChannels;
          searchChannelList.value = allChannels;

          // Initialize search lists
          searchChannelsWithChatInfo.value = channelsWithChatInfo.value;
          searchChannelsWithoutChat.value = channelsWithoutChat.value;

          print('📦 Loaded ${allChannels.length} channels from cache');
        } catch (e) {
          print('❌ Failed to decode cached channels: $e');
        }
      } else {
        print('⚠️ No cached data found');
      }
    }

    // Fetch from API
    print('🌐 Fetching channels from server...');
    try {
      final response = await userRepo.getChannels();

      print('📡 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody['code'] == '00' && responseBody['data'] != null) {
          print('✅ Server responded with valid data');

          final data = responseBody['data'];

          final withChatRaw = data['channelsWithChat'] as List<dynamic>;
          final withoutChatRaw = data['channelsWithoutChat'] as List<dynamic>;

          print('🧩 Raw withChat count: ${withChatRaw.length}');
          print('🧩 Raw withoutChat count: ${withoutChatRaw.length}');

          // Parse channels with chat
          channelsWithChatInfo.value = withChatRaw
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();

          // Parse channels without chat
          channelsWithoutChat.value = withoutChatRaw
              .map((e) => ChannelModel.fromJson(e))
              .toList();

          // Combine all
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];
          channels.value = allChannels;
          searchChannelList.value = allChannels;

          // Initialize search lists
          searchChannelsWithChatInfo.value = channelsWithChatInfo.value;
          searchChannelsWithoutChat.value = channelsWithoutChat.value;

          print('✅ Parsed channels: ${allChannels.length} total');
          print('📁 Caching channels...');

          // Cache fresh data
          await prefs.setString(
            'cachedChannelsWithChat',
            jsonEncode(channelsWithChatInfo.map((e) => e.toJson()).toList()),
          );
          await prefs.setString(
            'cachedChannelsWithoutChat',
            jsonEncode(channelsWithoutChat.map((e) => e.toJson()).toList()),
          );

          print('💾 Successfully cached fresh channel data');
        } else {
          print('⚠️ Invalid response code or missing data: ${responseBody['code']}');
        }
      } else {
        print('❌ Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching channels: $e');
    }
  }



  Future<void> _initChannelsAndChats() async {
    final prefs = await SharedPreferences.getInstance();

    // Step 1: Load channels from cache using the main getChannels method
    await getChannels(forceRefresh: false);

    // Step 2: Load each cached chat (if any)
    for (var channelWithChat in channelsWithChatInfo) {
      final chatCache = prefs.getString('chat_cache_${channelWithChat.channel.id}');
      if (chatCache != null) {
        try {
          final decodedChat = jsonDecode(chatCache);
          final chat = ChannelChatModel.fromJson(decodedChat);
          chatDetails.value[channelWithChat.channel.id!] = chat;
        } catch (e) {
          print('❌ Failed to load cached chat for ${channelWithChat.channel.id}: $e');
        }
      }
    }

    update(); // ✅ Update UI immediately

    // Step 3: Refresh everything in background
    Future.microtask(() async {
      await getChannels(forceRefresh: true);
      for (var channelWithChat in channelsWithChatInfo) {
        await getChannelChat(channelWithChat.channel.id!);
      }
      print('🔄 Refreshed channels and chats from network');
    });
  }

  Future<void> loadSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatar = prefs.getString('selectedAvatar') ?? 'avatar1';
    selectedAvatar.value = avatar;
  }

  void updateSelectedAvatar(String avatarName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAvatar', avatarName);
    selectedAvatar.value = avatarName;
  }

/*  Future<void> getChannels({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && channels.isEmpty) {
      final cached = prefs.getString('cachedChannels');
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached) as List;
          final cachedList =
              decoded.map((e) => ChannelModel.fromJson(e)).toList();
          channels.value = cachedList;
          searchChannelList.value = cachedList;
          print('📦 Loaded channels from cache');
        } catch (e) {
          print('❌ Failed to decode cached channels: $e');
        }
      }
    }

    try {
      final response = await userRepo.getChannels();
      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody['code'] == '00' && responseBody['data'] != null) {
          final data = responseBody['data'];

          final withChatRaw = data['channelsWithChat'] as List<dynamic>;
          final withoutChatRaw = data['channelsWithoutChat'] as List<dynamic>;

          final allChannelsRaw = [...withChatRaw, ...withoutChatRaw];

          final freshData =
              allChannelsRaw.map((e) => ChannelModel.fromJson(e)).toList();
          channels.value = freshData;
          searchChannelList.value =
              freshData; // update search list from fresh data

          channelsWithChat.value =
              withChatRaw.map((e) => ChannelModel.fromJson(e)).toList();
          channelsWithoutChat.value =
              withoutChatRaw.map((e) => ChannelModel.fromJson(e)).toList();

          await prefs.setString('cachedChannels', jsonEncode(allChannelsRaw));
          print('💾 Cached fresh channel data');
        }
      }
    } catch (e) {
      print('❌ Error fetching channels: $e');
    }
  }*/



/*
  Future<void> getChannels({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && channels.isEmpty) {
      final cachedWithChat = prefs.getString('cachedChannelsWithChat');
      final cachedWithoutChat = prefs.getString('cachedChannelsWithoutChat');

      if (cachedWithChat != null && cachedWithoutChat != null) {
        try {
          // Load channels with chat info
          final decodedWithChat = jsonDecode(cachedWithChat) as List;
          channelsWithChatInfo.value = decodedWithChat
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();

          // Load channels without chat
          final decodedWithoutChat = jsonDecode(cachedWithoutChat) as List;
          channelsWithoutChat.value = decodedWithoutChat
              .map((e) => ChannelModel.fromJson(e))
              .toList();

          // Update main channels list
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];
          channels.value = allChannels;
          searchChannelList.value = allChannels;
          print('📦 Loaded channels from cache');
        } catch (e) {
          print('❌ Failed to decode cached channels: $e');
        }
      }
    }

    try {
      final response = await userRepo.getChannels();
      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody['code'] == '00' && responseBody['data'] != null) {
          final data = responseBody['data'];

          final withChatRaw = data['channelsWithChat'] as List<dynamic>;
          final withoutChatRaw = data['channelsWithoutChat'] as List<dynamic>;

          // Parse channels with chat info
          channelsWithChatInfo.value = withChatRaw
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();

          // Parse channels without chat
          channelsWithoutChat.value = withoutChatRaw
              .map((e) => ChannelModel.fromJson(e))
              .toList();

          // For the main channels list, combine all channels
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];

          channels.value = allChannels;
          searchChannelList.value = allChannels;

          // Cache channels separately
          await prefs.setString('cachedChannelsWithChat',
              jsonEncode(channelsWithChatInfo.map((e) => e.toJson()).toList()));
          await prefs.setString('cachedChannelsWithoutChat',
              jsonEncode(channelsWithoutChat.map((e) => e.toJson()).toList()));

          print('💾 Cached fresh channel data');
        }
      }
    } catch (e) {
      print('❌ Error fetching channels: $e');
    }
  }
*/

/*  Future<void> getChannels({bool forceRefresh = false}) async {
    print('🔄 getChannels called with forceRefresh: $forceRefresh');
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && channels.isEmpty) {
      print('📁 Checking cached channels...');

      final cachedWithChat = prefs.getString('cachedChannelsWithChat');
      final cachedWithoutChat = prefs.getString('cachedChannelsWithoutChat');

      if (cachedWithChat != null && cachedWithoutChat != null) {
        try {
          print('📥 Found cached data. Attempting to decode...');

          // Decode and parse channels with chat
          final decodedWithChat = jsonDecode(cachedWithChat) as List;
          channelsWithChatInfo.value = decodedWithChat
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();
          print('✅ Decoded channelsWithChat: ${channelsWithChatInfo.length}');

          // Decode and parse channels without chat
          final decodedWithoutChat = jsonDecode(cachedWithoutChat) as List;
          channelsWithoutChat.value = decodedWithoutChat
              .map((e) => ChannelModel.fromJson(e))
              .toList();
          print('✅ Decoded channelsWithoutChat: ${channelsWithoutChat.length}');

          // Combine into full channel list
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];
          channels.value = allChannels;
          searchChannelList.value = allChannels;

          print('📦 Loaded ${allChannels.length} channels from cache');
        } catch (e) {
          print('❌ Failed to decode cached channels: $e');
        }
      } else {
        print('⚠️ No cached data found');
      }
    }

    // Fetch from API
    print('🌐 Fetching channels from server...');
    try {
      final response = await userRepo.getChannels();

      print('📡 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody['code'] == '00' && responseBody['data'] != null) {
          print('✅ Server responded with valid data');

          final data = responseBody['data'];

          final withChatRaw = data['channelsWithChat'] as List<dynamic>;
          final withoutChatRaw = data['channelsWithoutChat'] as List<dynamic>;

          print('🧩 Raw withChat count: ${withChatRaw.length}');
          print('🧩 Raw withoutChat count: ${withoutChatRaw.length}');

          // Parse channels with chat
          channelsWithChatInfo.value = withChatRaw
              .map((e) => ChannelWithChatInfo.fromJson(e))
              .toList();

          // Parse channels without chat
          channelsWithoutChat.value = withoutChatRaw
              .map((e) => ChannelModel.fromJson(e))
              .toList();

          // Combine all
          final allChannels = [
            ...channelsWithChatInfo.map((e) => e.channel),
            ...channelsWithoutChat
          ];
          channels.value = allChannels;
          searchChannelList.value = allChannels;

          print('✅ Parsed channels: ${allChannels.length} total');
          print('📁 Caching channels...');

          // Cache fresh data
          await prefs.setString(
            'cachedChannelsWithChat',
            jsonEncode(channelsWithChatInfo.map((e) => e.toJson()).toList()),
          );
          await prefs.setString(
            'cachedChannelsWithoutChat',
            jsonEncode(channelsWithoutChat.map((e) => e.toJson()).toList()),
          );

          print('💾 Successfully cached fresh channel data');
        } else {
          print('⚠️ Invalid response code or missing data: ${responseBody['code']}');
        }
      } else {
        print('❌ Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching channels: $e');
    }
  }

  void searchChannels(String query) {
    if (query.trim().isEmpty) {
      searchChannelList.value = channels;
    } else {
      searchChannelList.value = channels
          .where((channel) =>
              channel.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }*/

  Future<void> getUserDetails({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try loading from cache first if not forcing a refresh
      if (!forceRefresh && userDetail.value == null) {
        final cachedData = prefs.getString('cachedUserProfile');
        if (cachedData != null) {
          final parsedData = jsonDecode(cachedData);
          userDetail.value = UserModel.fromJson(parsedData);
          print('📦 Loaded user from cache');
          return;
        }
      }

      // Make network request
      final response = await userRepo.getUserDetails();
      print('📦 Raw response: ${response.body}');
      final body =
          response.body is String ? jsonDecode(response.body) : response.body;
      print('📬 Parsed response: $body');

      if (response.statusCode == 200 && body != null && body['code'] == '00') {
        final user = UserModel.fromJson(body['data']);
        userDetail.value = user;

        // Save to cache
        await prefs.setString('cachedUserProfile', jsonEncode(body['data']));
        // print(body['data']);
        print('💾 User data cached');
      } else {
        print('❌ Error: ${body?['message'] ?? 'Unknown error'}');
        Get.offAllNamed(AppRoutes.signinScreen);
      }
    } catch (e) {
      print('❌ Exception caught: $e');
    }
  }

  Future<void> fetchChannelChat(String channelId, {bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      String? cachedJson = prefs.getString('chat_cache_$channelId');
      if (cachedJson != null) {
        try {
          final decoded = json.decode(cachedJson);
          chatData = ChannelChatModel.fromJson(decoded);
          update();
          Get.toNamed(AppRoutes.messagingScreen, arguments: chatData);
          return;
        } catch (e) {
          print("❌ Error decoding cached chat: $e");
        }
      }
    }

    isLoading.value = true;
    print('getting chat $channelId');
    final result = await userRepo.getChannelChat(channelId);
    print('getting chat again $result');
    isLoading.value = false;

    if (result != null) {
      prefs.setString('chat_cache_$channelId', json.encode(result.toJson()));
      chatData = result;
      update();
      Get.toNamed(AppRoutes.messagingScreen, arguments: chatData);
    } else {
      // Get.snackbar("Error", "Failed to load chat channel");

    }
  }


  void addTempMessage(String chatId, MessageModel message) {
    chatDetails.value[chatId]?.messages.add(message);
    selectedChat.value?.messages.add(message);
    update();
  }

  Future<void> fetchReferrals() async {
    try {
      final referralsData = await userRepo.getPersonalReferrals();

      if (referralsData.isEmpty) {
        print('🔻 No referrals found.');
      } else {
        // Map the fetched referral data to UserModel
        referralList.value = referralsData.map((data) {
          print('🔄 Referral data: $data');
          return UserModel.fromJson(
              data); // Assuming your API returns JSON for each referral
        }).toList();

        print('📦 Referrals fetched: ${referralList.length} referrals');
      }
    } catch (e) {
      print('❌ Error fetching referrals: $e');
    }
  }

  Future<void> getChannelChat(String chatId,
      {bool forceRefresh = false}) async {
    isLoading.value = true;
    if (forceRefresh) update();

    try {
      final response = await userRepo.fetchChannelChatxx();
      var chatD = response?.body;
      // final chatD = await userRepo.fetchChannelChat(chatId);
      var chat;

      print('chatD: $chatD');

      if (chatD != null) {
        chat = (chatD['data'] as List<dynamic>).firstWhereOrNull((cd) {
          print('object ${cd['_id']}');
          print('compare to $chatId');
          return cd['_id'] == chatId;
        });
      }
      print('chat fetched: $chat');

      if (chat != null) {
        String actualChatId = chat?['_id'] ?? '';

        print('actualChatId: $actualChatId');

        chat = await userRepo.fetchChannelChatyy(actualChatId);

        print('chat fetched again: $chat');

        ChannelChatModel channelChatModel = ChannelChatModel.fromJson(chat);

        print('channelChatModel $channelChatModel');

        selectedChat.value = channelChatModel;
        chatDetail[chatId] = channelChatModel;
        chatDetail[actualChatId] = channelChatModel;
        print('selectedChat is $selectedChat');
        print('chatDetail is $chatDetail');
        update();
      } else {
        print('⚠️ No chat returned from API.');
      }
    } catch (e, s) {
      print('❌ Controller Exception: $e\n$s');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    isDeleting.value = true;
    final response = await userRepo.deleteUserAccount();
    isDeleting.value = false;

    if (response.statusCode == 200 && response.body['code'] == '00') {
      // Clear token and navigate to welcome or login screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoutes.signinScreen);
      MySnackBars.success(
          title: 'Account Deleted', message: 'We hope to see you again soon');
    } else {
      Get.snackbar(
          "Error", response.body['message'] ?? "Failed to delete account");
    }
  }
}
