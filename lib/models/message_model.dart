


class MessageModel {
  final String id;
  final String content;
  final String type;
  final Sender sender;
  final Media? media;
  final DateTime? createdAt;
  bool tempChat;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    this.media,
    this.createdAt,
    this.tempChat = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      sender: Sender.fromJson(json['sender'] ?? {}),
      media: json['media'] != null ? Media.fromJson(json['media']) : Media(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      tempChat: json['tempChat'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'type': type,
      'sender': sender.toJson(),
      'media': media?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'tempChat' : tempChat,
    };
  }
}


class Sender {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  Sender({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}

class Media {
  final String? type;
  final int? duration;
  final int? size;
  final String? url;


  Media({
    this.type,
    this.duration,
    this.size,
    this.url,

  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      type: json['type'],
      duration: json['duration'] ?? 0,
      size: json['size'] ?? 0,
      url: json['url'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration,
      'size': size,
      'url': url,

    };
  }
}