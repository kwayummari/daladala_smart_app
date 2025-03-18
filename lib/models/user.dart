class User {
  final int userId;
  final int roleId;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String? profilePicture;
  final bool isVerified;
  final String status;
  final String? lastLogin;
  final String roleName;

  User({
    required this.userId,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    this.profilePicture,
    required this.isVerified,
    required this.status,
    this.lastLogin,
    required this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      roleId: json['role_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] == 1,
      status: json['status'],
      lastLogin: json['last_login'],
      roleName: json['role']?['role_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'is_verified': isVerified ? 1 : 0,
      'status': status,
      'last_login': lastLogin,
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isAdmin => roleName == 'admin';
  bool get isPassenger => roleName == 'passenger';
  bool get isDriver => roleName == 'driver';
  bool get isOperator => roleName == 'operator';
}

class UserRole {
  final int roleId;
  final String roleName;
  final String? description;

  UserRole({
    required this.roleId,
    required this.roleName,
    this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleId: json['role_id'],
      roleName: json['role_name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
      'description': description,
    };
  }
}

class Notification {
  final int notificationId;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String? relatedEntity;
  final int? relatedId;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedEntity,
    this.relatedId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedEntity: json['related_entity'],
      relatedId: json['related_id'],
      isRead: json['is_read'] == 1,
      readAt: json['read_at'],
      createdAt: json['created_at'],
    );
  }
}

class Driver {
  final int driverId;
  final int userId;
  final String licenseNumber;
  final String licenseExpiry;
  final String idNumber;
  final int? experienceYears;
  final double rating;
  final int totalRatings;
  final bool isAvailable;
  final String status;
  final User? user;

  Driver({
    required this.driverId,
    required this.userId,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.idNumber,
    this.experienceYears,
    required this.rating,
    required this.totalRatings,
    required this.isAvailable,
    required this.status,
    this.user,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driver_id'],
      userId: json['user_id'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      idNumber: json['id_number'],
      experienceYears: json['experience_years'],
      rating: double.parse(json['rating'].toString()),
      totalRatings: json['total_ratings'],
      isAvailable: json['is_available'] == 1,
      status: json['status'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
    );
  }
}