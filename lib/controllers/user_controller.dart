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

  UserController({
    required this.userRepo,
    required this.apiClient
  });

  var isLoading = false.obs;
  var userDetail = Rxn<UserModel>();
  RxList<UserModel> referralList = <UserModel>[].obs;
  var channels = <ChannelModel>[].obs;
  ChannelChatModel? chatData;
  Rx<Map<String,ChannelChatModel>> chatDetails = Rx<Map<String,ChannelChatModel>>({});
  var channelDetails = {}.obs;
  List<MessageModel> messages = [];

  void addTempMessage(String chatId, MessageModel message) {
    chatDetails.value[chatId]?.messages.add(message);
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
          return UserModel.fromJson(data); // Assuming your API returns JSON for each referral
        }).toList();

        print('📦 Referrals fetched: ${referralList.length} referrals');
      }
    } catch (e) {
      print('❌ Error fetching referrals: $e');
    }
  }


  Future<void> getChannels() async {
    try {
      final Response response = await userRepo.getChannels();
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody['code'] == '00' && responseBody['data'] != null) {
          channels.value = (responseBody['data'] as List)
              .map((channelData) => ChannelModel.fromJson(channelData))
              .toList();
        } else {
          print('Failed to fetch channels: ${responseBody['message']}');
          channels.value = [];
        }
      } else {
        print('Failed to fetch channels. Status code: ${response.statusCode}');
        channels.value = [];
      }
    } catch (e) {
      print('Error fetching channels: $e');
      channels.value = [];
    }
  }



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
      final body = response.body is String ? jsonDecode(response.body) : response.body;
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


  Future<void> fetchChannelChat(String channelId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if cached data exists
    String? cachedJson = prefs.getString('chat_cache_$channelId');

    if (cachedJson != null) {
      try {
        final decoded = json.decode(cachedJson);
        chatData = ChannelChatModel.fromJson(decoded);
        update();
        Get.toNamed(AppRoutes.messagingScreen, arguments: chatData);
        return;
      } catch (e) {
        print("Error decoding cached data: $e");
      }
    }

    // Fetch from API
    isLoading.value = true;
    final result = await userRepo.getChannelChat(channelId);
    isLoading.value = false;

    if (result != null) {
      // Save to SharedPreferences
      prefs.setString('chat_cache_$channelId', json.encode(result.toJson()));

      chatData = result;
      update();
      Get.toNamed(AppRoutes.messagingScreen, arguments: chatData);
    } else {
      Get.snackbar("Error", "Failed to load chat channel");
    }
  }




/*
  Future<void> getChannelChat(String chatId) async {
    isLoading(true);
    print('Fetching chat details for chatId: $chatId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.authToken) ?? '';
      print('Retrieved auth token: $token');
      String url = AppConstants.GET_CHAT_DETAILS.replaceAll('{chatId}', chatId);
      print('Request URL: ${AppConstants.BASE_URL}$url');
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}$url'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Response Body: ${response.body}');
        final chat = ChannelChatModel.fromJson(jsonResponse['data']);
        print('Chat Data Parsed: $chat');
        chatDetails.value = chat;
        print('Messages: ${chat.messages}');
      } else {
        Get.snackbar('Error', 'Failed to load chat details.');
        print('Error: Failed to load chat details.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.');
      print('Error occurred: $e');
    } finally {
      isLoading(false);
      print('Loading state set to false');
    }
  }
*/

  Future<ChannelChatModel?> getChannelChat(String chatId) async {
    isLoading(true);
    print('Fetching chat details for chatId: $chatId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.authToken) ?? '';
      print('Retrieved auth token: $token');
      String url = AppConstants.GET_CHAT_DETAILS.replaceAll('{chatId}', chatId);
      print('Request URL: ${AppConstants.BASE_URL}$url');
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}$url'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Response Body: ${response.body}');
        final chat = ChannelChatModel.fromJson(jsonResponse['data']);
        chatDetails.value[chatId] = chat;
        print('Came Messages: ${chatDetails.value[chatId]!.messages}');
        update();
        return chat; // ✅ return the chat
      } else {
        // Get.snackbar('Error', 'Failed to load chat details.');
        print('Error: Failed to load chat details.');
        return null;
      }
    } catch (e,s) {
      // Get.snackbar('Error', 'Something went wrong. Please try again.');
      print('Error occurred: $e / $s');
      return null;
    } finally {
      isLoading(false);
      print('Loading state set to false');
    }
  }






}



/* Future<void> getChannelById(String channelId) async {
    isLoading(true);

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}channel/$channelId'),
        headers: {
          'Authorization': 'Bearer ${'authToken'}', // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        // Parse the response and set the channel details
        final data = json.decode(response.body);
        channelDetails.value = data;
      } else {
        Get.snackbar('Error', 'Failed to load channel details.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading(false);
    }
  }*/