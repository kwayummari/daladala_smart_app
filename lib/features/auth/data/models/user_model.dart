import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? accessToken;
  
  const UserModel({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    String? profilePicture,
    required String role,
    required bool isVerified,
    required String status,
    this.accessToken,
  }) : super(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    profilePicture: profilePicture,
    role: role,
    isVerified: isVerified,
    status: status,
  );
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      role: json['role'],
      isVerified: json['is_verified'] ?? false,
      status: json['status'] ?? 'active',
      accessToken: json['accessToken'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'profile_picture': profilePicture,
      'role': role,
      'is_verified': isVerified,
      'status': status,
      'accessToken': accessToken,
    };
  }
  
  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePicture,
    String? role,
    bool? isVerified,
    String? status,
    String? accessToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}