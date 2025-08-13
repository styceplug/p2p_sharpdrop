import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:p2p_sharpdrop/controllers/notification_controller.dart';
import 'package:p2p_sharpdrop/data/api/api_client.dart';
import 'package:p2p_sharpdrop/screens/main_screen/home_screen.dart';
import 'package:path/path.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../main_screen/profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  UserController userController = Get.find<UserController>();
  NotificationController notificationController = Get.find<NotificationController>();
  ApiClient apiClient = Get.find<ApiClient>();

  @override
  void initState() {
    super.initState();

    // ✅ Animation Controller
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // ✅ Check internet before proceeding
    _checkInternetAndProceed();

  }

  /// 🔹 Checks internet connection and proceeds accordingly
  Future<void> _checkInternetAndProceed() async {
    print("🔍 Checking internet connection...");

    bool hasInternet = await InternetConnectionChecker.createInstance().hasConnection;

    if (hasInternet) {
      print("✅ Internet is available. Proceeding with initialization...");
      _initialize();
    } else {
      print("❌ No internet connection. Showing dialog...");
      _showNoInternetDialog();
    }
  }

  /// 🔹 Authentication & Routing Logic
  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate splash delay

    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    await userController.getChannels();

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Get.offAllNamed(AppRoutes.onboardingScreen);
      return;
    }

    final String? token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // ✅ Update API headers before any request
      apiClient.updateHeader(token);

      // ✅ Load user details after headers are set
      await Get.find<UserController>().getUserDetails();

      // ✅ Save device token (will now include Authorization)
      await notificationController.saveDeviceToken();


      // ✅ Navigate after everything is ready
      Get.offAllNamed(AppRoutes.bottomNav);
      return;
    }

    Get.offAllNamed(AppRoutes.signinScreen);
  }

  /// 🔹 Show No Internet Dialog
  void _showNoInternetDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
        ),
        title: Text(
          "No Internet Connection",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: Dimensions.font20),
        ),
        content: Text(
          "Please check your internet and try again.",
          style: TextStyle(fontSize: Dimensions.font14),
        ),

        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          SizedBox(width: Dimensions.width10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius5),
              ),
            ),
            onPressed: () {
              Get.back();
              _checkInternetAndProceed();
            },
            child: Text(
              "Retry",
              style: TextStyle(
                color: Theme.of(Get.context!).highlightColor,
                fontSize: Dimensions.font15,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false, // Prevents closing by tapping outside
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: Dimensions.height313),
            // 🔹 Centered Logo & Text
            Center(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
              ),
            ),
            SizedBox(height: Dimensions.height313),
            // 🔹 Bouncing Dots Indicator (Bottom of screen)
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height50),
              child: Container(
                  height: Dimensions.height20,
                  width: Dimensions.width20*10,
                  child: BouncingDotsIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class BouncingDotsIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double spacing;

  const BouncingDotsIndicator({
    super.key,
    this.color = AppColors.darkPrimary,
    this.dotSize = 10.0,
    this.spacing = 8.0,
  });

  @override
  _BouncingDotsIndicatorState createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<BouncingDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true, period: const Duration(milliseconds: 800)),
    );

    _animations = _controllers
        .map((controller) =>
        Tween<double>(begin: 0, end: 10.0).animate(controller))
        .toList();

    // 🔹 Delay each dot's animation for a wave effect
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.translate(
                offset: Offset(0, -_animations[index].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}