import 'dart:convert';
import 'dart:io';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

class ChatRepo {
  final ApiClient apiClient;
  ChatRepo({required this.apiClient, required sharedPreferences});

  Future<Response> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    return await apiClient.postData(
      "/message/text",
      {
        "chatId": chatId,
        "content": content,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }


  Future<Map<String, dynamic>?> sendImageMessage({
    required String chatId,
    required File imageFile,
  }) async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        print('❌ No auth token found');
        return null;
      }

      var uri = Uri.parse('https://sharp-drop.onrender.com/api/message/image');
      var request = http.MultipartRequest('POST', uri);

      // Add authorization header with actual token
      request.headers['Authorization'] = 'Bearer $token';

      // Add form field
      request.fields['chatId'] = chatId;

      // Attach the image file
      String mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      String fileName = basename(imageFile.path);

      request.files.add(await http.MultipartFile.fromPath(
        'imageFile',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
        filename: fileName,
      ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody) as Map<String, dynamic>;
        return decodedBody;
      } else {
        print('❌ Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error while uploading image: $e');
      return null;
    }
  }
}