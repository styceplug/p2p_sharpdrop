import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';

import '../controllers/user_controller.dart';
import '../utils/dimensions.dart';

class MyReferralsScreen extends StatefulWidget {
  const MyReferralsScreen({super.key});

  @override
  State<MyReferralsScreen> createState() => _MyReferralsScreenState();
}

class _MyReferralsScreenState extends State<MyReferralsScreen> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    userController.fetchReferrals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Referrals'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Obx(() {
          final referrals = userController.referralList;

          if (referrals.isEmpty) {
            return Center(
              child: Text(
                'No referrals yet!',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(Dimensions.width20),
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final user = referrals[index];
              return Container(
                margin: EdgeInsets.only(bottom: Dimensions.height10),
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Dimensions.radius30,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Dimensions.font16,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height5),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            fontSize: Dimensions.font14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );

  }
}
