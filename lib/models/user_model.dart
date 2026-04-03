import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { tenant, owner }

class UserModel {
  final String uid;
  final String name;
  final String? phoneNumber;
  final String? email;
  final UserRole role;
  final String verificationMethod;
  final bool isVerified;
  final DateTime createdAt;

  final String? propertyId;
  final String? roomId;
  final String? photoUrl;
  final String? bio;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    this.phoneNumber,
    this.email,
    required this.role,
    required this.verificationMethod,
    this.isVerified = false,
    required this.createdAt,
    this.propertyId,
    this.roomId,
    this.photoUrl,
    this.bio,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'role': role.toString().split('.').last,
      'verification_method': verificationMethod,
      'is_verified': isVerified,
      'created_at': Timestamp.fromDate(createdAt),
      'propertyId': propertyId,
      'roomId': roomId,
      'photo_url': photoUrl,
      'bio': bio,
      'fcm_token': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'],
      email: map['email'],
      role: map['role'] == 'owner' ? UserRole.owner : UserRole.tenant,
      verificationMethod: map['verification_method'] ?? 'email',
      isVerified: map['is_verified'] ?? false,
      createdAt: (map['created_at'] is Timestamp) 
          ? (map['created_at'] as Timestamp).toDate() 
          : DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      propertyId: map['propertyId'],
      roomId: map['roomId'],
      photoUrl: map['photo_url'],
      bio: map['bio'],
      fcmToken: map['fcm_token'],
    );
  }
}
