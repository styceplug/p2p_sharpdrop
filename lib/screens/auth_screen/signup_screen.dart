import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:p2p_sharpdrop/widgets/custom_button.dart';
import 'package:p2p_sharpdrop/widgets/custom_textfield.dart';
import 'package:p2p_sharpdrop/widgets/password_textfield.dart';
import 'package:p2p_sharpdrop/widgets/snackbars.dart';

import '../../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  AuthController authController = Get.find<AuthController>();

  //controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController refController = TextEditingController();

  bool termsAccepted = false;

  void registerUser() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = mailController.text.trim();
    final number = phoneController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();
    final referralCode = refController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        number.isEmpty ||
        password.isEmpty) {
      MySnackBars.failure(
        title: 'Error',
        message: 'All fields except referral code are required',
      );
      return;
    }

    if (password != confirmPassword) {
      MySnackBars.failure(title: 'Error', message: 'Passwords do not match');
      return;
    }

    if (!termsAccepted) {
      MySnackBars.failure(
        title: 'Error',
        message: 'Please accept the terms and privacy policy',
      );
      return;
    }

    // ✅ Call initiateSignUp with referralCode only if it's not empty
    authController.initiateSignUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      number: number,
      password: password,
      referralCode: referralCode.isNotEmpty ? referralCode : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimensions.height10 * 9),
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Join a leading platform is P2P asset trading today',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: Dimensions.height20),
              CustomTextField(
                hintText: 'Enter First Name',
                controller: firstNameController,
              ),
              SizedBox(height: Dimensions.height10),
              CustomTextField(
                hintText: 'Enter Last Name',
                controller: lastNameController,
              ),
              SizedBox(height: Dimensions.height10),
              CustomTextField(
                hintText: 'Enter Email Address',
                controller: mailController,
              ),
              SizedBox(height: Dimensions.height10),
              CustomTextField(
                hintText: 'Enter Whatsapp Number',
                controller: phoneController,
              ),
              SizedBox(height: Dimensions.height10),
              PasswordTextField(
                controller: passController,
              ),
              SizedBox(height: Dimensions.height10),
              PasswordTextField(
                controller: confirmPassController,
              ),
              SizedBox(height: Dimensions.height10),
              CustomTextField(
                hintText: 'Referral Code (Optional)',
                controller: refController,
              ),
              SizedBox(height: Dimensions.height10),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          termsAccepted = !termsAccepted;
                        });
                      },
                      child: Icon(
                          termsAccepted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank_sharp,
                          color: Theme.of(context).dividerColor)),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'I accept the terms and privacy Policy',
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Obx(
                () => CustomButton(
                    text: authController.isLoading.value
                        ? 'Creating User...'
                        : 'Sign up Now',
                    onPressed: () {
                      authController.isLoading.value ? null : registerUser();
                    }),
              ),
              SizedBox(height: Dimensions.height10),
              InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.signinScreen);
                  },
                  child: Text(
                    'Already an existing user?, Sign in now',
                    style: TextStyle(
                        fontSize: Dimensions.font15,
                        color: Theme.of(context).dividerColor,
                        fontWeight: FontWeight.w500),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
