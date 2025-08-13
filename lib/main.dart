/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/controllers/chat_controller.dart';
import 'package:p2p_sharpdrop/controllers/notification_controller.dart';
import 'package:p2p_sharpdrop/controllers/theme_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';

import 'helpers/dependencies.dart' as dep;
import 'helpers/push_notification.dart';

import 'package:flutter/foundation.dart';
import 'firebase_options.dart';



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (true) {
    await Firebase.initializeApp(
      name: 'sharpdrop',
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() {
      if (kDebugMode) {
        print("completedAppInitialize");
      }
    });
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dep.init();

  FirebaseMessagingHelper firebaseMessagingHelper = FirebaseMessagingHelper();
  await firebaseMessagingHelper.requestNotificationPermission();

  await FirebaseMessaging.instance.getInitialMessage();

  String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  print('🍏 APNs Token: $apnsToken');

  runApp(MyApp());

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('🔔 Permission granted: ${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBg,
    // textTheme: getTextTheme(AppColors.lightTextColor),
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
    ),
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBg,
    // textTheme: getTextTheme(AppColors.darkTextColor),
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
    ),
  );

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        builder: (_) {
      return GetBuilder<UserController>(
          builder: (_) {
        return GetBuilder<ChatController>(
            builder: (_) {
          return GetBuilder<NotificationController>(builder: (_){
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Sharp Drop - Digital Services',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              getPages: AppRoutes.routes,
              initialRoute: AppRoutes.splashScreen,
            );
          });
        });
      });
    });
  }
}*/


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/controllers/chat_controller.dart';
import 'package:p2p_sharpdrop/controllers/notification_controller.dart';
import 'package:p2p_sharpdrop/controllers/theme_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';

import 'helpers/dependencies.dart' as dep;
import 'helpers/push_notification.dart';

import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      name: 'sharpdrop',
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() {
      if (kDebugMode) {
        print("completedAppInitialize");
      }
    });

    // Only initialize Firebase Messaging for mobile platforms
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessagingHelper firebaseMessagingHelper = FirebaseMessagingHelper();
      await firebaseMessagingHelper.requestNotificationPermission();

      await FirebaseMessaging.instance.getInitialMessage();

      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('🍏 APNs Token: $apnsToken');

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 Permission granted: ${settings.authorizationStatus}');
    } else {
      print('🌐 Running on web - skipping mobile-specific Firebase features');
    }
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Continue anyway for testing
  }

  try {
    await dep.init();
  } catch (e) {
    print('❌ Dependencies initialization error: $e');
    // Continue anyway for testing
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
    ),
  );

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        builder: (_) {
          return GetBuilder<UserController>(
              builder: (_) {
                return GetBuilder<ChatController>(
                    builder: (_) {
                      return GetBuilder<NotificationController>(builder: (_){
                        return GetMaterialApp(
                          debugShowCheckedModeBanner: false,
                          title: 'Sharp Drop - Digital Services',
                          theme: lightTheme,
                          darkTheme: darkTheme,
                          themeMode: ThemeMode.system,
                          getPages: AppRoutes.routes,
                          initialRoute: AppRoutes.splashScreen,
                        );
                      });
                    });
              });
        });
  }
}


