import 'dart:convert';

import 'package:get/get.dart';
import 'package:p2p_sharpdrop/data/api/api_client.dart';
import 'package:p2p_sharpdrop/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repo/auth_repo.dart';
import '../models/user_model.dart';
import '../routes/routes.dart';
import '../screens/auth_screen/create_pin.dart';
import '../widgets/snackbars.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;
  ApiClient apiClient;


  AuthController({required this.authRepo, required this.apiClient});

  final RxString authToken = ''.obs;
  var isLoading = false.obs;


  String getErrorMessage(String serverMessage) {
    // Check for duplicate key error (phone number already exists)
    if (serverMessage.contains('dup key') && serverMessage.contains('number')) {
      return 'This phone number is already registered. Please use a different number.';
    }

    switch (serverMessage.toLowerCase()) {
      case 'user with email already exists':
        return 'An account with this email already exists. Please log in or use a different email.';
      case 'invalid password':
        return 'The password you entered is incorrect. Please try again.';
      case 'invalid credentials':
        return 'Username or password is incorrect.';
      case 'account not found':
        return 'No account found with these details.';
      case 'invalid or expired token':
        return 'Your session has expired. Please log in again.';
      case 'unauthorized':
        return 'You are not authorized to perform this action.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }


  //Sign Up
  Future<void> initiateSignUp({
    required String firstName,
    required String lastName,
    required String email,
    required String number,
    required String password,
    String? referralCode, // optional param
  }) async {
    isLoading.value = true;

    // Build the request body
    Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'number': number,
      'password': password,
    };

    // Include referralCode only if it's not null or empty
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      data['referralCode'] = referralCode.trim();
    }

    try {
      final response = await authRepo.registerUser(data);
      final body = response.body;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body != null &&
          body['code'] == '00') {
        final userId = body['data']?['id'];
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

        }

        MySnackBars.success(
          title: 'Account Creation Successful',
          message: 'User Created Successfully, Pls create a 6 digits security pin.',
        );
        Get.offAllNamed(AppRoutes.createPin);
      } else {
        final message = body != null
            ? body['message']?.toString() ?? 'Signup failed'
            : 'Server did not return a response';

        print('❌ Server responded with error: $message');

        MySnackBars.failure(
          title: 'Signup Failed',
          message: getErrorMessage(message),
        );
      }
    } catch (e) {
      print('❌ Signup exception: $e');
      MySnackBars.failure(
        title: 'Network Error',
        message: 'Please check your connection and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> setSecurityPin(String pin) async {
    if (pin.length != 6) {
      Get.snackbar("Invalid Pin", "Security pin must be 6 digits long");
      return;
    }

    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        Get.snackbar("Error", "User not found. Please log in again.");
        return;
      }

      final response = await authRepo.setSecurityPin(userId, pin);
      final body = response.body;

      if (body['code'] == '00') {
        Get.offAllNamed(AppRoutes.signinScreen);
        MySnackBars.success(title: 'Pin set Successfully', message: 'Account Set up Complete, Kindly login again ');
      } else {
        Get.snackbar("Error", body['message'] ?? "Failed to set security pin");
        print("Status: ${response.statusCode}");
        print("Response: $body");
      }
    } catch (e,s) {
      Get.snackbar("Error", "Something went wrong: $e");
      print('$e,$s');
    } finally {
      isLoading.value = false;
    }
  }





  // LOGIN USER
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    Map<String, dynamic> data = {
      "email": email,
      "password": password,
    };

    try {
      Response response = await authRepo.loginUser(data);
      print('Controller link: 🔗 ${response.request?.url}');

      // If the body is a String, decode it
      final res = response.body is String
          ? jsonDecode(response.body)
          : response.body;

      if (response.statusCode == 200 && res['code'] == '00') {
        String token = res['data'];

        await saveToken(token);

        MySnackBars.success(
          title: 'Welcome Back',
          message: 'Place your orders ASAP',
        );

        Get.offAllNamed(AppRoutes.bottomNav);

      } else {
        MySnackBars.failure(
          title: 'Login Failed',
          message: res['message'] ?? 'Unable to sign in at the moment',
        );
        print('❌ Login failed: ${res['message']}');
      }
    } catch (e) {
      print('Login exception: $e');
      MySnackBars.failure(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }



  // Save token to SharedPreferences & observable
  Future<void> saveToken(String token) async {
    authToken.value = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('✅ Token saved: $token');
  }

// Retrieve token from SharedPreferences into observable
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken.value = prefs.getString('authToken') ?? '';

    if (authToken.value.isNotEmpty) {
      apiClient.updateHeader(authToken.value);
      print("✅ Header updated with token: ${authToken.value}");
    }

    print('🔑 Token loaded: ${authToken.value}');
  }


  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.signinScreen);
  }


}