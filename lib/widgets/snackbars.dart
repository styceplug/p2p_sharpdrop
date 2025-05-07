import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MySnackBars {
  static void success({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.85),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, size: 30, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static void failure({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, size: 30, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static void processing({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.85),
      colorText: Colors.white,
      icon: const Icon(Icons.hourglass_empty, size: 30, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
