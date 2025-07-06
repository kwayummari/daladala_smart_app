import 'package:daladala_smart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  
  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<Either<Failure, User>> verifyAccount({
    required String identifier,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await authRepository.verifyAccount(
      identifier: identifier,
      code: code,
    );

    result.fold(
      (failure) {
        // Handle failure - do nothing here, just log or handle errors
      },
      (user) {
        _currentUser = user; // This is the actual User object
      },
    );

    _isLoading = false;
    notifyListeners();

    return result; // Return the Either<Failure, User>
  }

  Future<Either<Failure, void>> resendVerificationCode({
    required String identifier
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await authRepository.resendVerificationCode(
      identifier: identifier,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }
  
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final params = LoginParams(
      phone: phone,
      password: password,
      rememberMe: rememberMe,
    );
    
    final result = await loginUseCase(params);
    
    result.fold(
      (failure) {
        // Handle failure if needed
      },
      (user) {
        _currentUser = user;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  Future<Either<Failure, User>> register({
    required String phone,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final params = RegisterParams(
      phone: phone,
      email: email,
      password: password,
    );
    
    final result = await registerUseCase(params);
    
    result.fold(
      (failure) {
        // Handle failure if needed
      },
      (user) {
        _currentUser = user;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  Future<Either<Failure, void>> logout() async {
    _isLoading = true;
    notifyListeners();
    
    final result = await logoutUseCase(NoParams());
    
    result.fold(
      (failure) {
        // Handle failure if needed
      },
      (_) {
        _currentUser = null;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  Future<bool> isLoggedIn() async {
    final params = CheckAuthStatusParams();
    final result = await loginUseCase.checkAuthStatus(params);
    
    return result.fold(
      (failure) => false,
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
  
  // Add this method to refresh user from server
  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      try {
        _isLoading = true;
        notifyListeners();
        
        final result = await authRepository.getCurrentUser();
        result.fold(
          (failure) {
            // Handle failure silently or show error if needed
            print('Failed to refresh user: ${failure.message}');
          },
          (user) {
            _currentUser = user;
          },
        );
      } catch (e) {
        print('Error refreshing user: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}

class NoParams {}