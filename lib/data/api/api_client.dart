import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import 'api_checker.dart';


class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = AppConstants.BASE_URL;
    timeout = const Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstants.TOKEN) ?? "";
    _mainHeaders = {
      'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Authorization': '$token',
    };

    sharedPreferences.setString(AppConstants.TOKEN, token);

    if (kDebugMode) {
      print('update header called for $token');
    }
  }

  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    try {
      Response response = await get(uri, headers: headers ?? _mainHeaders);
      if (kDebugMode) {
        print('getting $appBaseUrl $uri  $_mainHeaders');
        print("response body ${response.body}");
      }
      return response;
    } catch (e) {
      return Response(
        statusCode: 1,
        statusText: e.toString(),
      );
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      final effectiveHeaders = headers ?? _mainHeaders;

      Response response = await post(uri, body, headers: effectiveHeaders);
      if (kDebugMode) {
        print('posting $appBaseUrl$uri');
        print('body: $body');
        print('headers: $effectiveHeaders');
        print("response body: ${response.body}");
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('from api post client');
        print(e.toString());
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }


  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {

      Response response = await put(uri, body, headers: headers ?? _mainHeaders);
      if (kDebugMode) {
        print("putting ${response.body}");
      }
      ApiChecker.checkApi(response);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('from api put client');
        print(e.toString());
      }
      return Response(statusCode: 1, statusText: e.toString());
    }
  }



}
