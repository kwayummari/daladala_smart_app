import 'package:flutter/foundation.dart';
import 'package:daladala_smart_app/models/user.dart';
import 'package:daladala_smart_app/services/auth_service.dart';
import 'package:daladala_smart_app/services/api_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  
  // Getters
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;
  
  // Initialize the auth state
  AuthProvider() {
    _checkAuthStatus();
  }
  
  // Check if user is authenticated
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    
    try {
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to check authentication status';
    }
    
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String phone, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _authService.login(phone, password);
      
      if (response.success && response.data != null) {
        _currentUser = response.data;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to login: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register(String firstName, String lastName, String phone, String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _authService.register(firstName, lastName, phone, email, password);
      
      if (response.success) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to register: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
  
  // Request Password Reset
  Future<bool> requestPasswordReset(String phone) async {
    _errorMessage = '';
    
    try {
      final response = await _authService.requestPasswordReset(phone);
      
      if (response.success) {
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to request password reset: ${e.toString()}';
      return false;
    } finally {
      notifyListeners();
    }
  }
  
  // Reset Password
  Future<bool> resetPassword(String token, String password) async {
    _errorMessage = '';
    
    try {
      final response = await _authService.resetPassword(token, password);
      
      if (response.success) {
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to reset password: ${e.toString()}';
      return false;
    } finally {
      notifyListeners();
    }
  }
}