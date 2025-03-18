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
  
  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
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
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final params = RegisterParams(
      firstName: firstName,
      lastName: lastName,
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
}

class NoParams {}