import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p2p_sharpdrop/controllers/chat_controller.dart';
import 'package:p2p_sharpdrop/controllers/user_controller.dart';
import 'package:p2p_sharpdrop/models/channel_model.dart';
import 'package:p2p_sharpdrop/models/user_model.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';
import 'package:shimmer/shimmer.dart';

import '../models/message_model.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final UserController userController = Get.find<UserController>();
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  MessageModel? _selectedMessage;

  void onLongPressMessage(MessageModel message) {
    setState(() {
      _selectedMessage = message;
    });
  }

  void cancelCopyMode() {
    setState(() {
      _selectedMessage = null;
    });
  }

  late ChannelChatModel channelChatModel;

  Timer? _refreshTimer;

  bool lie = false;

  @override
  void initState() {
    super.initState();
    channelChatModel = Get.arguments as ChannelChatModel;
    userController.fetchChannelChat(channelChatModel.id);
    userController
        .getChannelChat(
      channelChatModel.id,
    )
        .then((_) {
      scrollToBottom();
    });
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      userController.getChannelChat(channelChatModel.id).then((_) {
        scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(messageDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';

    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme
        .of(context)
        .scaffoldBackgroundColor;
    final textColor = Theme
        .of(context)
        .dividerColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(
                int.tryParse(
                  channelChatModel.channel.color.replaceFirst('#', '0xff'),
                ) ??
                    0xff000000,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedMessage != null
                    ? 'Select Message'
                    : channelChatModel.channel.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedMessage != null) ...[
            IconButton(
              icon: Icon(Icons.copy, color: textColor),
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: _selectedMessage!.content));
                Get.snackbar(
                  'Copied',
                  'Message copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
                setState(() {
                  _selectedMessage = null;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: textColor),
              onPressed: () {
                setState(() {
                  _selectedMessage = null;
                });
              },
            ),
          ] else
            ...[
              IconButton(
                icon: Icon(Icons.attach_file, color: textColor),
                onPressed: () {
                  chatController.pickImage();
                },
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: textColor),
                onPressed: () {},
              ),
            ],
        ],
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      body: SafeArea(
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          child: Column(
            children: [
              // Messages
              Expanded(
                child: GetBuilder<UserController>(builder: (userController) {
                  if (userController.isLoading.value) {
                    return ListView.builder(
                      padding:
                      EdgeInsets.symmetric(vertical: Dimensions.height10),
                      itemCount: 6,
                      itemBuilder: (_, __) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.white10,
                              highlightColor: Colors.grey.shade50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  }

                  if (userController.selectedChat.value == null ||
                      userController.selectedChat.value!.messages.isEmpty) {
                    return Center(
                      child: Text('No messages yet'),
                    );
                  }

                  return ListView.builder(
                      controller: _scrollController,
                      padding:
                      EdgeInsets.symmetric(vertical: Dimensions.height10),
                      itemCount:
                      userController.selectedChat.value!.messages.length,
                      itemBuilder: (context, index) {
                        MessageModel message =
                        userController.selectedChat.value!.messages[index];
                        return MessageBubble(
                          message: message,
                          isSelected: _selectedMessage?.id == message.id,
                          onLongPress: () => onLongPressMessage(message),
                        );
                      });
                }),
              ),
              // Input
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: bgColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Obx(() {
                            if (!chatController.isPreviewingImage.value)
                              return const SizedBox.shrink();

                            /*return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: Dimensions.height20 * 20,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                        image: FileImage(chatController
                                            .selectedImage.value!),
                                        fit: BoxFit
                                            .contain, // optional, adjusts how image fills container
                                      ),
                                    ),
                                  ),

                                  // Uploading indicator on top of the image
                                  if (chatController.isUploading.value)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.5),
                                        child: const Center(
                                          child: LinearProgressIndicator(
                                            color: Colors.white,
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Close icon
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () =>
                                          chatController.clearPreview(),
                                    ),
                                  ),
                                ],
                              ),
                            );*/
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Platform-conditional image display
                                  if (kIsWeb)
                                    chatController.selectedImageBytes.value != null
                                        ? Image.memory(
                                      chatController.selectedImageBytes.value!,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Text('Image preview not available'),
                                      ),
                                    )
                                  else
                                    chatController.selectedImage.value != null
                                        ? Image.file(
                                      chatController.selectedImage.value!,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Text('Image preview not available'),
                                      ),
                                    ),

                                  // Uploading indicator on top of the image
                                  if (chatController.isUploading.value)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.5),
                                        child: const Center(
                                          child: LinearProgressIndicator(
                                            color: Colors.white,
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Close icon
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => chatController.clearPreview(),
                                    ),
                                  ),
                                ],
                              ),
                            );

                          }),
                          TextField(
                            controller: messageController,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (val) =>
                            chatController.messageText.value = val,
                            decoration: InputDecoration(
                              hintText: "Type a message",
                              filled: true,
                              fillColor: Theme
                                  .of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        if (chatController.isPreviewingImage.value) {
                          await chatController
                              .sendPickedImage(channelChatModel.id);
                          scrollToBottom();
                          return;
                        }

                        final content = messageController.text.trim();
                        if (content.isEmpty) return;

                        final sender = userController.userDetail.value!;
                        final tempMessage = MessageModel(
                          id: '${channelChatModel.id}-temp',
                          content: content,
                          tempChat: true,
                          type: 'text',
                          sender: Sender(
                              id: sender.id,
                              firstName: sender.firstName ?? '',
                              lastName: sender.lastName ?? '',
                              email: sender.email ?? '',
                              role: sender.role ?? ''),
                          media: Media(
                            size: 0,
                            url: '',
                          ),
                        );

                        userController.addTempMessage(
                            channelChatModel.id, tempMessage);
                        scrollToBottom();
                        messageController.clear();

                        await chatController.sendMessage(channelChatModel.id);
                        await userController
                            .getChannelChat(channelChatModel.id);
                        scrollToBottom();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class MessageBubble extends StatelessWidget {
  final MessageModel? message;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    this.message,
    this.isSelected = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = Get.find<UserController>().userDetail.value?.id;
    final isUserMessage = message?.sender.id == userId;
    final isFile = message?.type == 'image';
    final isTemp = message?.tempChat ?? false;

    final time = message?.createdAt != null
        ? DateFormat('dd MMM yyyy, h:mm a').format(
        message!.createdAt!.add(Duration(hours: 1)))
        : '';

    final baseUrl = 'https://api.sharpdropapp.com';
    final fullImageUrl = message?.media?.url != null
        ? '$baseUrl${message!.media!.url}'
        : '';

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: isFile
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: isFile
              ? null
              : BoxDecoration(
            color: isSelected
                ? Colors.blue.shade100
                : (isTemp
                ? Colors.redAccent
                : isUserMessage
                ? Colors.green.shade400
                : Colors.grey.shade300),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUserMessage ? 16 : 4),
              bottomRight: Radius.circular(isUserMessage ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isFile)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildNetworkImage(fullImageUrl),
                )
              else
                Text(
                  message?.content ?? '',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                        fontSize: 11,
                        color: isFile ? Colors.white : Colors.black45),
                  ),
                  if (isUserMessage) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isTemp ? Icons.check : Icons.done_all,
                      size: 16,
                      color: isTemp ? Colors.black38 : Colors.white,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String fullImageUrl) {
    if (kIsWeb) {
      // Web-specific image loading with better error handling
      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        width: Dimensions.width20 * 10,
        height: 150,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: Dimensions.width20 * 10,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Loading image...',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          if (kDebugMode) {
            print('❌ Image loading error: $error');
            print('📸 Image URL: $fullImageUrl');
          }

          return Container(
            width: Dimensions.width20 * 10,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Colors.grey.shade500,
                ),
                SizedBox(height: 8),
                Text(
                  'Image failed to load',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (kDebugMode) ...[
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'URL: ${fullImageUrl.length > 30 ? '${fullImageUrl.substring(0, 30)}...' : fullImageUrl}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    } else {
      // Mobile - original simple implementation
      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        width: Dimensions.width20 * 10,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image),
      );
    }
  }
}