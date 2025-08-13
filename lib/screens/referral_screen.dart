import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:p2p_sharpdrop/widgets/custom_button.dart';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final UserController userController = Get.find<UserController>();

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.rawSnackbar(
      message: 'Copied to clipboard',
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor:
          Get.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  void shareReferralCode(String code) {
    final message = '''
Hey! 👋 

Join me on B2C Sharp Drop to trade crypto easily and securely.

Use my referral code: $code to sign up and get bonuses!

Download now and let's earn together! 🚀
''';

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final user = userController.userDetail.value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Referral Program',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
            fontWeight: FontWeight.w600,
            fontSize: Dimensions.font18,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).dividerColor),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Dimensions.height20),
              Container(
                height: Dimensions.height100 * 3.5,
                width: Dimensions.screenWidth,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage(
                      AppConstants.getGifAsset('referral'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  children: [
                    Text(
                      'YOUR CODE',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${user?.referralCode ?? '----'}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          InkWell(
                            onTap: () {
                              if (user?.referralCode != null) {
                                copyToClipboard(user!.referralCode ?? '');
                              }
                            },
                            child: Icon(
                              Icons.copy,
                              color: Theme.of(context).dividerColor,
                              size: Dimensions.iconSize24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),
                    Text(
                      'We are leading the industry with scheduled and attractive payouts. Drive traffic to B2C Sharp Drop and we will give you commission up to ₦1M for each user that becomes an active client.',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.font15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.height30),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            icon: Icon(
                              CupertinoIcons.share,
                              size: Dimensions.iconSize20,
                              color: Colors.black,
                            ),
                            text: 'Share',
                            onPressed: () {
                              if (user?.referralCode != null) {
                                shareReferralCode(user!.referralCode ?? '');
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.width20,
                        ),
                        Expanded(
                            child: CustomButton(
                          text: 'Show Referrals',
                          onPressed: () {Get.toNamed(AppRoutes.referralList);},
                          icon: Icon(CupertinoIcons.list_bullet_below_rectangle,
                              color: Colors.black, size: Dimensions.iconSize20),
                        ))
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
