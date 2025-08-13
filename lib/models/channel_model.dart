

import 'package:p2p_sharpdrop/models/message_model.dart';
import 'package:p2p_sharpdrop/models/user_model.dart';

class ChannelModel {
  final String id;
  final String name;
  final String color;
  final bool hasActiveChats;


  ChannelModel({
    required this.id,
    required this.name,
    required this.color,
    required this.hasActiveChats,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['_id'],
      name: json['name'],
      color: json['color'],
      hasActiveChats: json['hasActiveChats'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'color': color,
      'hasActiveChats': hasActiveChats,
    };
  }
}

class ChannelWithChatInfo {
  final ChannelModel channel;
  final String? lastMessage;
  final String? timestamp;

  ChannelWithChatInfo({
    required this.channel,
    this.lastMessage,
    this.timestamp,
  });

  factory ChannelWithChatInfo.fromJson(Map<String, dynamic> json) {
    return ChannelWithChatInfo(
      channel: ChannelModel.fromJson(json['channel']),
      lastMessage: json['lastMessage'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel': channel.toJson(),
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    };
  }
}

class ChannelChatModel {
  final String id;
  final ChannelModel channel;
  final UserModel user;
  final List<MessageModel> messages;
  final int unreadCount;
  final int userUnreadCount;
  final int adminUnreadCount;
  final bool isActive;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime updatedAt;


  ChannelChatModel({
    required this.id,
    required this.channel,
    required this.user,
    required this.messages,
    required this.unreadCount,
    required this.userUnreadCount,
    required this.adminUnreadCount,
    required this.isActive,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,

  });

  factory ChannelChatModel.fromJson(Map<String, dynamic> json) {
    return ChannelChatModel(
      id: json['_id'],
      channel: (() {
        final ch = json['channel'];
        if (ch is String) {
          return ChannelModel(id: ch, name: '', color: '#000000', hasActiveChats: false,);
        } else if (ch is Map<String, dynamic>) {
          return ChannelModel.fromJson(ch);
        } else {
          throw Exception("Invalid channel format");
        }
      })(),
      user: UserModel.fromJson(json['user']),
      messages: (json['messages'] as List)
          .map((messageJson) => MessageModel.fromJson(messageJson))
          .toList(),
      unreadCount: json['unreadCount'],
      userUnreadCount: json['userUnreadCount'],
      adminUnreadCount: json['adminUnreadCount'],
      isActive: json['isActive'],
      startedAt: DateTime.parse(json['startedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'channel': channel.toJson(),
      'user': user,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'unreadCount': unreadCount,
      'userUnreadCount': userUnreadCount,
      'adminUnreadCount': adminUnreadCount,
      'isActive': isActive,
      'startedAt': startedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}