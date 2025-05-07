import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_sharpdrop/controllers/auth_controller.dart';
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:p2p_sharpdrop/utils/colors.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:p2p_sharpdrop/widgets/custom_button.dart';

import '../../widgets/snackbars.dart';

class CreatePin extends StatefulWidget {
  const CreatePin({super.key, required String userId});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {

  AuthController authController = Get.find<AuthController>();
  TextEditingController pinController = TextEditingController();

  void createPin(){
    final pin = pinController.text.trim();

    if (pin.isEmpty || pin.length != 6) {
      MySnackBars.failure(
        title: 'Invalid Pin',
        message: 'Please enter a valid 6-digit pin.',
      );
      return;
    }

    authController.setSecurityPin(pin);  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20, vertical: Dimensions.height20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimensions.height100),
            Text(
              'Create your 6 digits security pin',
              style: TextStyle(
                  fontSize: Dimensions.font22,
                  color: Theme.of(context).dividerColor,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'This pin will be prompted each time you want to complete a transaction',
              style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: Theme.of(context).dividerColor,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(height: Dimensions.height50),
            //input pin
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: Dimensions.width10 / Dimensions.width5,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: Dimensions.width10 / Dimensions.width5,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height100 * 5),
            Obx(
                ()=> CustomButton(
                  text: authController.isLoading.value? 'Creating Pin...' : 'Continue',
                  onPressed: () {
                    createPin();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
