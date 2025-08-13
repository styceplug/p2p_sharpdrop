import 'package:flutter/material.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/widgets/custom_button.dart';
import 'package:p2p_sharpdrop/widgets/custom_textfield.dart';
import 'package:p2p_sharpdrop/widgets/password_textfield.dart';
import 'package:p2p_sharpdrop/widgets/snackbars.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/routes.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

AuthController authController = Get.find<AuthController>();

TextEditingController mailController = TextEditingController();
TextEditingController passController = TextEditingController();

void verifyForm() {
  if (mailController.text.isNotEmpty && passController.text.isNotEmpty) {
    print('Forms has being filled you can Proceed');
    authController.login(
        email: mailController.text.trim(),
        password: passController.text.trim());
  } else {
    MySnackBars.failure(
        title: 'Cannot Proceed', message: 'Pls fill both fields');
    print('Please fill in both fields');
  }
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Dimensions.height76),
                Container(
                  height: Dimensions.height20 * 5,
                  width: Dimensions.width20 * 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        AppConstants.getPngAsset('logo'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                      fontSize: Dimensions.font22,
                      color: Theme.of(context).dividerColor,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                      fontSize: Dimensions.font16,
                      color: Theme.of(context).dividerColor,
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(height: Dimensions.height50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: Dimensions.height5),
                    CustomTextField(
                      hintText: 'Enter your email address',
                      controller: mailController,
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: Dimensions.height5),
                    PasswordTextField(
                      controller: passController,
                    )
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Obx(
                  () => CustomButton(
                      text: authController.isLoading.value
                          ? 'Signing in...'
                          : 'Sign in',
                      onPressed: () {
                        verifyForm();
                      }),
                ),
                SizedBox(height: Dimensions.height20),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.resetPassScreen);
                  },
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                        fontSize: Dimensions.font17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(height: Dimensions.height20 * 12),
                InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.signupScreen);
                    },
                    child: Text(
                      'New here? Sign up today!!',
                      style: TextStyle(
                          fontSize: Dimensions.font15,
                          color: Theme.of(context).dividerColor,
                          fontWeight: FontWeight.w500),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
