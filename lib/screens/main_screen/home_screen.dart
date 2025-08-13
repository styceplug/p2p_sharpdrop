import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:p2p_sharpdrop/controllers/theme_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/models/message_model.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:p2p_sharpdrop/widgets/category_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/channel_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ThemeController themeController = Get.find<ThemeController>();
  UserController userController = Get.find<UserController>();
  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  var chatMessages = <MessageModel>[].obs;




  @override
  void initState() {
    userController.getUserDetails();
    userController.getChannels();
    super.initState();
  }


  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Obx(() {
          final user = userController.userDetail.value;

          if (user == null) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
            );
          }

          return Text(
            'Hi, ${user.firstName}',
            style: TextStyle(
              color: Theme.of(context).dividerColor,
              fontSize: Dimensions.font17,
              fontWeight: FontWeight.w800,
            ),
          );
        }),
        centerTitle: false,
        leadingWidth: Dimensions.width10 * 6,
        leading: Obx(() {
          final user = userController.userDetail.value;
          final avatar = userController.selectedAvatar.value;

          return Row(
            children: [
              SizedBox(width: Dimensions.width20),
              user == null
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[100]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: Dimensions.height40,
                  width: Dimensions.width40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : Container(
                height: Dimensions.height40,
                width: Dimensions.width40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/$avatar.png'),
                  ),
                ),
              ),
            ],
          );
        }),
        actions: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  themeController.toggleTheme();
                },
                child: Icon(
                  Icons.light_mode_outlined,
                  color: Theme.of(context).dividerColor,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.notificationScreen);
                },
                child: Icon(
                  CupertinoIcons.bell,
                  color: Theme.of(context).dividerColor,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width20),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              await userController.getChannels();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                TextField(
                  onChanged: (value){
                    searchQuery.value = value;
                    userController.searchChannels(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Channels...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Existing Channels',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.toNamed(AppRoutes.channelsScreen),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(Dimensions.radius5),
                        ),
                        child: Text(
                          'New Channel',
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Expanded(
                  child: Obx(() {
                    final isSearching = searchQuery.value.trim().isNotEmpty;
                    final listToShow = isSearching
                        ? userController.searchChannelsWithChatInfo
                        : userController.channelsWithChatInfo;
        
                    if (listToShow.isEmpty) {
                      return const Center(child: Text("No active chats"));
                    }
        
                    return ListView.builder(
                      itemCount: listToShow.length,
                      itemBuilder: (context, index) {
                        final channelWithChat = listToShow[index];
                        final channel = channelWithChat.channel;
        
                        return CategoryCard(
                          title: channel.name,
                          lastMessage: channelWithChat.lastMessage ?? 'No messages yet',
                          lastMessageTime: channelWithChat.timestamp != null
                              ? _formatTimestamp(channelWithChat.timestamp!)
                              : '',
                          color: Color(int.parse(channel.color.replaceAll('#', '0xff'))),
                          onTap: () async {
                            await userController.fetchChannelChat(channel.id);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
