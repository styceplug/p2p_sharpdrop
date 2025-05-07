import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:p2p_sharpdrop/controllers/theme_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:p2p_sharpdrop/widgets/category_card.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/channel_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

ThemeController themeController = Get.find<ThemeController>();
UserController userController = Get.find<UserController>();

class _HomeScreenState extends State<HomeScreen> {



  @override
  void initState() {
    userController.getUserDetails();
    super.initState();
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
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getPngAsset('avatar')),
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
              Icon(
                CupertinoIcons.bell,
                color: Theme.of(context).dividerColor,
                size: Dimensions.iconSize24,
              ),
              SizedBox(width: Dimensions.width20),
            ],
          )
        ],
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20, vertical: Dimensions.height20),
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: ()async{
            await userController.getChannels();
          },
          child: Column(
            children: [
              /*SearchBar(
                side: MaterialStateProperty.all(
                    BorderSide(color: Theme.of(context).dividerColor)),
                hintText: 'Search.....',
                leading: Icon(Icons.search),
              ),*/
              SizedBox(height: Dimensions.height20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Existing Channels',
                    style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),

                ],
              ),
              SizedBox(
                height: Dimensions.height20,
              ),
              Container(
                child: Expanded(
                  child: Obx(() {
                    if (userController.channels.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: userController.channels.length,
                      itemBuilder: (context, index) {
                        final channel = userController.channels[index];
                        return CategoryCard(
                          title: channel.name,
                          color: Color(int.parse(channel.color.replaceAll('#', '0xff'))),
                          onTap: () {
                            userController.fetchChannelChat(channel.id);
                          },
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
