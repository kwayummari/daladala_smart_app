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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _currentProfile;
  User? get currentProfile => _currentProfile;

  // ADD this missing getProfile method
  Future<void> getProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For now, we'll just clear the loading state
      // since you're getting profile from AuthProvider
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Either<Failure, User>> updateProfile(
    Map<String, dynamic> profileData, {
    File? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.updateProfile(
      profileData,
      profileImage: profileImage,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (user) {
        _currentProfile = user;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
