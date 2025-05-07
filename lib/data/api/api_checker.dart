import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      // User not authorized
      // Get.offAllNamed(AppRoutes.getLoginScreen());
    } else if (response.statusCode == 403) {
      // Forbidden
    } else if (response.statusCode == 500) {
      // Server error
    } else if (response.body is Map && response.body['code'] == '99') {
      // Custom app logic for failure
      Get.snackbar('Error', response.body['message'] ?? 'Something went wrong');
    }
  }
}