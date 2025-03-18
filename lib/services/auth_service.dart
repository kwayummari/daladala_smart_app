import 'package:daladala_smart_app/config/api_config.dart';
import 'package:daladala_smart_app/models/user.dart';
import 'package:daladala_smart_app/services/api_service.dart';
import 'package:daladala_smart_app/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // User login
  Future<ApiResponse<User>> login(String phone, String password) async {
    final response = await _apiService.post<User>(
      ApiConfig.login,
      data: {
        'phone': phone,
        'password': password,
      },
      fromJson: (json) {
        final userData = json['user'] ?? json;
        final token = json['accessToken'];
        
        // Save token to secure storage
        if (token != null) {
          _storageService.saveToken(token);
        }
        
        final user = User.fromJson(userData);
        // Save user data to storage
        _storageService.saveUser(user);
        
        return user;
      },
    );
    
    return response;
  }

  // User registration
  Future<ApiResponse<User>> register(
    String firstName,
    String lastName,
    String phone,
    String email,
    String password,
  ) async {
    final response = await _apiService.post<User>(
      ApiConfig.register,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
      },
      fromJson: (json) => User.fromJson(json),
    );
    
    return response;
  }

  // Request password reset
  Future<ApiResponse<void>> requestPasswordReset(String phone) async {
    final response = await _apiService.post<void>(
      ApiConfig.requestPasswordReset,
      data: {
        'phone': phone,
      },
    );
    
    return response;
  }

  // Reset password
  Future<ApiResponse<void>> resetPassword(String token, String password) async {
    final response = await _apiService.post<void>(
      ApiConfig.resetPassword,
      data: {
        'token': token,
        'password': password,
      },
    );
    
    return response;
  }

  // Verify user
  Future<ApiResponse<void>> verifyUser(String token) async {
    final response = await _apiService.get<void>(
      '${ApiConfig.verifyUser}/$token',
    );
    
    return response;
  }

  // Logout
  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteUser();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }
}