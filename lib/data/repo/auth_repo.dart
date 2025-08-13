import 'package:get/get_connect/http/src/response/response.dart';
import 'package:p2p_sharpdrop/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });


  Future<Response> registerUser(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.REGISTER_USER, data);
  }

  Future<Response> loginUser(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.LOGIN_USER, data);
  }

  Future<Response> setSecurityPin(String userId, String pin) async {
    return await apiClient.postData(AppConstants.CREATE_PIN, {
      "userId": userId,
      "securityPin": pin,
    });
  }

  Future<Response> requestOtp(String email) async {
    final body = {
      'email': email,
    };

    return await apiClient.postData(AppConstants.REQUEST_OTP, body);
  }

  Future<Response> resetPassword(String email, String otp, String password) async{
    return await apiClient.postData(AppConstants.RESET_PASSWORD, {
      "email": email,
      "otp": otp,
      "newPassword": password,
    });

  }


}