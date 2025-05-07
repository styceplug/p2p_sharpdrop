import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:p2p_sharpdrop/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/channel_model.dart';
import '../../models/message_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class UserRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  UserRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<Response> startChat(ChannelModel channel, String token) async {
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final endpoint = AppConstants.GET_CHATS.replaceAll('{channelId}', channel.id ?? '');

      print('🔁 GET $endpoint');
      print('📨 headers: $headers');

      final response = await apiClient.getData(endpoint, headers: headers);

      if (response.statusCode == 200 && response.body['code'] == '00') {
        return response; // success
      } else {
        throw Exception('Failed to start chat: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  Future<Response> getUserDetails() async {
    final token = sharedPreferences.getString('authToken');

    if (token == null || token.isEmpty) {
      print('❌ No token found in SharedPreferences!');
      Get.offAllNamed(AppRoutes.signinScreen);
    } else {
      print('✅ Token retrieved: $token');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    print('🔁 getting ${AppConstants.GET_USER} $headers');
    return await apiClient.getData(AppConstants.GET_USER, headers: headers);
  }

  Future<List<dynamic>> getPersonalReferrals() async {
    try {
      final token = sharedPreferences.getString('authToken');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await apiClient.getData(AppConstants.GET_PERSONAL_REFERRALS, headers: headers);

      final body = response.body is String ? jsonDecode(response.body) : response.body;

      if (response.statusCode == 200 && body['code'] == '00') {
        return body['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('❌ getPersonalReferrals Error: $e');
      return [];
    }
  }

  Future<Response> getChannels() async {
    return await apiClient.getData(AppConstants.GET_CHANNELS);
  }

  Future<ChannelChatModel?> getChannelChat(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await apiClient.getData(
      '/chat/v2/user/channel/$channelId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 && response.body['code'] == '00') {
      return ChannelChatModel.fromJson(response.body['data']);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }



}
