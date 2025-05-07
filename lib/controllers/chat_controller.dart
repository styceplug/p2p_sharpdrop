import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/data/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repo/chat_repo.dart';
import '../models/channel_model.dart';
import '../models/message_model.dart';

class ChatController extends GetxController {
  final ChatRepo chatRepo;

  ChatController( {required this.chatRepo});

  var isSending = false.obs;
  var messageText = ''.obs;
  var chatMessages = <MessageModel>[].obs;
  UserController userController = Get.find<UserController>();
  var isSendingImage = false.obs;
  Rxn<Media> uploadedMedia = Rxn<Media>();
  final ImagePicker _picker = ImagePicker();
  Rxn<File> selectedImage = Rxn<File>();
  RxBool isPreviewingImage = false.obs;
  var isUploading = false.obs;



  Future<void> sendMessage(String chatId) async {
    if (messageText.value.trim().isEmpty) return;
    isSending.value = true;
    try {
      final response = await chatRepo.sendTextMessage(
        chatId: chatId,
        content: messageText.value.trim(),
      );
      isSending.value = false;
      print(response.statusCode);
      if (response.statusCode == 201 || response.body['code'] == '00') {
        final messageData = response.body['data'];
        // final message = MessageModel.fromJson(messageData);
       /* final updatedChat = userController.chatDetails.value;
        if (updatedChat?.messages != null) {
          updatedChat?.messages.add(message);
        }
        userController.chatDetails.value = updatedChat;*/
        print('Sent Successfully');
        messageText.value = '';
      } else {
        final message = response.body['message'] ?? "Server error occurred.";
        print(message);
      }
    } catch (e,s) {
      isSending.value = false;
      Get.snackbar("Error", "Unexpected error: $e");
      print('Error inSending Message: ${e}, ${s}');
    }
  }





  void clearPreview() {
    selectedImage.value = null;
    isPreviewingImage.value = false;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      isPreviewingImage.value = true;
    }
  }
  Future<void> sendPickedImage(String chatId) async {
    if (selectedImage.value == null) return;
    isUploading.value = true;
    final response = await chatRepo.sendImageMessage(
      chatId: chatId,
      imageFile: selectedImage.value!,
    );
    isUploading.value = false;
    if (response != null && response['code'] == '00') {
      await userController.getChannelChat(chatId);
      clearPreview();
    } else {
      print(response);
    }
  }
  Future<void> sendImage({
    required String chatId,
    required File imageFile,
  }) async {
    try {
      isSendingImage.value = true;
      final media = await chatRepo.sendImageMessage(
        chatId: chatId,
        imageFile: imageFile,
      );
      if (media != null) {
        print('✅ Image uploaded successfully: ${media['data']['media']['url']}');
        // Handle the response or update UI
      } else {
        print('⚠️ Media upload failed');
      }
    } catch (e) {
      print('❌ Error while sending image: $e');
    } finally {
      isSendingImage.value = false;
    }
  }
}