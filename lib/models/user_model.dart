class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? number;
  final String? role;
  final String? referralCode;
  final String? referredBy;
  final bool? isOnline;
  final String? lastSeen;
  final int? referralCount;
  final List<DeviceToken>? deviceTokens;
  final String? deactivationReason;
  final String? deactivationStatus;
  final String? deactivationRequestDate;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.number,
    this.role,
    this.referralCode,
    this.referredBy,
    this.isOnline,
    this.lastSeen,
    this.referralCount,
    this.deviceTokens,
    this.deactivationReason,
    this.deactivationStatus,
    this.deactivationRequestDate,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      number: json['number'],
      role: json['role'],
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      isOnline: json['isOnline'],
      lastSeen: json['lastSeen'],
      referralCount: json['referralCount'],
      deviceTokens: (json['deviceTokens'] as List<dynamic>?)
          ?.map((e) => DeviceToken.fromJson(e))
          .toList(),
      deactivationReason: json['deactivationReason'],
      deactivationStatus: json['deactivationStatus'],
      deactivationRequestDate: json['deactivationRequestDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'number': number,
      'role': role,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'referralCount': referralCount,
      'deviceTokens': deviceTokens?.map((e) => e.toJson()).toList(),
      'deactivationReason': deactivationReason,
      'deactivationStatus': deactivationStatus,
      'deactivationRequestDate': deactivationRequestDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class DeviceToken {
  final String? token;
  final String? platform;
  final String? createdAt;

  DeviceToken({
    this.token,
    this.platform,
    this.createdAt,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      token: json['token'],
      platform: json['platform'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'platform': platform,
      'createdAt': createdAt,
    };
  }
}