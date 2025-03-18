import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? profilePicture;
  final String role;
  final bool isVerified;
  final String status;
  
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.profilePicture,
    required this.role,
    required this.isVerified,
    required this.status,
  });
  
  String get fullName => '$firstName $lastName';
  
  bool get isDriver => role == 'driver';
  
  bool get isOperator => role == 'operator';
  
  bool get isAdmin => role == 'admin';
  
  bool get isActive => status == 'active';
  
  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phone,
    email,
    profilePicture,
    role,
    isVerified,
    status,
  ];
}