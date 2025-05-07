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
     this.createdAt,
     this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      number: json['number'] ?? '',
      role: json['role'] ?? '',
      referralCode: json['referralCode'] ?? '',
      referredBy: json['referredBy'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] ?? '',
      referralCount: json['referralCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}