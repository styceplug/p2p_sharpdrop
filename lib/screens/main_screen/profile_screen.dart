import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_constants.dart';
import '../../widgets/snackbars.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

AuthController authController = Get.find<AuthController>();
UserController userController = Get.find<UserController>();
final String supportUrl = 'info@sharpdropapp.com';


void _showDeleteConfirmationDialog(BuildContext context) {
  String confirmationText = '';
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Type "DELETE" below to confirm account deletion.'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              onChanged: (value) => confirmationText = value,
              decoration: const InputDecoration(
                hintText: 'Enter DELETE to confirm',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // close dialog
            child: const Text('Cancel'),
          ),
          Obx(() {
            return TextButton(
              onPressed: () {
                if (controller.text.trim().toUpperCase() == 'DELETE') {
                  Get.back(); // close dialog
                  userController.deleteAccount();
                } else {
                  MySnackBars.failure(
                    title: 'Invalid Input',
                    message: 'Please type DELETE in uppercase to proceed.',
                  );
                }
              },
              child: userController.isDeleting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Confirm',
                      style: TextStyle(color: Theme.of(context).focusColor),
                    ),
            );
          }),
        ],
      );
    },
  );
}

void showAvatarSelectionSheet(BuildContext context) {
  final avatars = List.generate(12, (index) => 'avatar${index + 1}');

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        itemCount: avatars.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, index) {
          final avatar = avatars[index];
          return GestureDetector(
            onTap: () async {
              userController.updateSelectedAvatar(avatar);
              Get.back();
            },
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/$avatar.png'),
              radius: 30,
            ),
          );
        },
      );
    },
  );
}





class _ProfileScreenState extends State<ProfileScreen> {

  void openSupportUrl() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportUrl,
      query:
      'subject=B2C Sharp Drop App Support&body=Hello, I need help with...',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email client.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image

                Obx(() {
                  final user = userController.userDetail.value;
                  final avatar = userController.selectedAvatar.value;

                  return GestureDetector(
                    onTap: () {
                      showAvatarSelectionSheet(context);
                    },
                    child: FutureBuilder<String?>(
                      future: SharedPreferences.getInstance()
                          .then((prefs) => prefs.getString('selectedAvatar')),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: CircleAvatar(
                                radius: 50, backgroundColor: Colors.white),
                          );
                        }

                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            'assets/images/${snapshot.data ?? "avatar1"}.png',
                          ),
                        );
                      },
                    ),
                  );
                }),

                SizedBox(height: 20),

                // User Name
                Obx(() {
                  final user = userController.userDetail.value;

                  if (user == null) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 20,
                        color: Colors.white,
                      ),
                    );
                  }

                  return Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }),

                SizedBox(height: 10),

                // User Email
                Obx(() {
                  final user = userController.userDetail.value;

                  if (user == null) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 20,
                        color: Colors.white,
                      ),
                    );
                  }

                  return Text(
                    user.email ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).dividerColor,
                    ),
                  );
                }),

                SizedBox(height: Dimensions.height30),

                // Log Out Button
                InkWell(
                  onTap: () {
                    authController.logOut();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'LOG OUT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Dimensions.height30),

                InkWell(
                  onTap: () {
                    openSupportUrl();
                  },
                  child: Container(
                    height: Dimensions.height10 * 9,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: Dimensions.width10 / Dimensions.width30),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // SizedBox(width: Dimensions.width10,),
                        Icon(Icons.support_agent,
                            color: Theme.of(context).dividerColor),
                        Text(
                          'Help and Support',
                          style: TextStyle(
                              fontSize: Dimensions.font20,
                              color: Theme.of(context).dividerColor),
                        ),
                        SizedBox(width: Dimensions.width113),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.referralScreen);
                  },
                  child: Container(
                    height: Dimensions.height10 * 9,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: Dimensions.width10 / Dimensions.width30),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // SizedBox(width: Dimensions.width10,),
                        Icon(Icons.remove_from_queue,
                            color: Theme.of(context).dividerColor),
                        Text(
                          'Referral Program',
                          style: TextStyle(
                              fontSize: Dimensions.font20,
                              color: Theme.of(context).dividerColor),
                        ),
                        SizedBox(width: Dimensions.width113),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Obx(() => InkWell(
                      onTap: () {
                        if (!userController.isDeleting.value) {
                          _showDeleteConfirmationDialog(context);
                        }
                      },
                      child: Container(
                        height: Dimensions.height10 * 9,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: Dimensions.width10 / Dimensions.width30,
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.cancel,
                                color: Theme.of(context).dividerColor),
                            userController.isDeleting.value
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).dividerColor,
                                  )
                                : Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: Dimensions.font20,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                            SizedBox(width: Dimensions.width113),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
