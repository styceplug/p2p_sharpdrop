import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/controllers/chat_controller.dart';
import 'package:p2p_sharpdrop/controllers/theme_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';

import 'helpers/dependencies.dart' as dep;
import 'models/message_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dep.init();
  runApp(MyApp());
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
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'P2P Sharp Drop',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            getPages: AppRoutes.routes,
            initialRoute: AppRoutes.splashScreen,
          );
        });
      });
    });
  }
}
