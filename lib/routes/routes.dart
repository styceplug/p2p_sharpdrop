import 'package:get/get.dart';
import 'package:p2p_sharpdrop/screens/auth_screen/create_pin.dart';
import 'package:p2p_sharpdrop/screens/auth_screen/reset_password.dart';
import 'package:p2p_sharpdrop/screens/auth_screen/signin_screen.dart';
import 'package:p2p_sharpdrop/screens/auth_screen/signup_screen.dart';
import 'package:p2p_sharpdrop/screens/main_screen/channels_screen.dart';
import 'package:p2p_sharpdrop/screens/messaging_screen.dart';
import 'package:p2p_sharpdrop/screens/my_referrals_screen.dart';
import 'package:p2p_sharpdrop/screens/notification_screen.dart';
import 'package:p2p_sharpdrop/screens/referral_screen.dart';
import 'package:p2p_sharpdrop/screens/splash_onboard/onboarding_screen.dart';
import 'package:p2p_sharpdrop/widgets/bottom_nav.dart';

import '../screens/splash_onboard/splash_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash-screen';
  static const String onboardingScreen = '/onboarding-screen';
  static const String signupScreen = '/signup-screen';
  static const String signinScreen = '/signin-screen';
  static const String createPin = '/create-pin';
  static const String bottomNav = '/bottom-nav';
  static const String messagingScreen = '/messaging-screen';
  static const String referralScreen = '/referral-screen';
  static const String referralList = '/referral-list';
  static const String notificationScreen = '/notification-screen';
  static const String resetPassScreen = '/reset-pass-screen';
  static const String channelsScreen = '/channels-screen';




  static final routes = [
    GetPage(
      name: splashScreen,
      page: () {
        return const SplashScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboardingScreen,
      page: () {
        return const OnBoardingScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: referralScreen,
      page: () {
        return const ReferralScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signupScreen,
      page: () {
        return const SignupScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signinScreen,
      page: () {
        return const SigninScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createPin,
      page: () {
        return const CreatePin(userId: '',);
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: bottomNav,
      page: () {
        return const BottomNav();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: messagingScreen,
      page: () {
        return const MessagingScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: referralList,
      page: () {
        return const MyReferralsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notificationScreen,
      page: () {
        return const NotificationScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: resetPassScreen,
      page: () {
        return const ResetPasswordScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: channelsScreen,
      page: () {
        return const ChannelsScreen();
      },
      transition: Transition.fadeIn,
    ),


  ];
}
