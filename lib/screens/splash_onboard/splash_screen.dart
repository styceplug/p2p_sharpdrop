import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/screens/main_screen/home_screen.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  AuthController authController = Get.find<AuthController>();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppLaunchFlow();
    });
  }

  Future<void> checkAppLaunchFlow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    await authController.loadToken();
    await userController.getChannels();

    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (isFirstTime) {
      await prefs.setBool('is_first_time', false);
      Get.offAllNamed(AppRoutes.bottomNav);
    } else if (authController.authToken.value.isNotEmpty) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      Get.offAllNamed(AppRoutes.signinScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          height: Dimensions.height100,
          width: Dimensions.width100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            image: DecorationImage(
              image: AssetImage(AppConstants.getPngAsset('logo')),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
