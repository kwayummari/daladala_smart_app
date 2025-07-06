// lib/features/profile/presentation/providers/profile_provider.dart
import 'dart:io';
import 'package:daladala_smart_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Either<Failure, User>> updateProfile(
    Map<String, dynamic> profileData, {
    File? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.updateProfile(
      profileData,
      profileImage: profileImage,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
