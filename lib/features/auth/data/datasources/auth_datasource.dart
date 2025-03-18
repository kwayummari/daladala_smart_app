import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> login({
    required String phone,
    required String password,
  });
  
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  });
  
  Future<void> logout();
  
  Future<void> requestPasswordReset({
    required String phone,
  });
  
  Future<void> resetPassword({
    required String token,
    required String password,
  });
}

class AuthDataSourceImpl implements AuthDataSource {
  final DioClient dioClient;
  
  AuthDataSourceImpl({required this.dioClient});
  
  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '${AppConstants.authEndpoint}/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );
      
      if (response['status'] == 'success') {
        return UserModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '${AppConstants.authEndpoint}/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );
      
      if (response['status'] == 'success') {
        // After registration, we need to login to get the token
        return await login(phone: phone, password: password);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> logout() async {
    // No need to make API call for logout since we're using token-based auth
    // Just clear the token on the client side
    return;
  }
  
  @override
  Future<void> requestPasswordReset({required String phone}) async {
    try {
      final response = await dioClient.post(
        '${AppConstants.authEndpoint}/request-reset',
        data: {
          'phone': phone,
        },
      );
      
      if (response['status'] != 'success') {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> resetPassword({required String token, required String password}) async {
    try {
      final response = await dioClient.post(
        '${AppConstants.authEndpoint}/reset-password',
        data: {
          'token': token,
          'password': password,
        },
      );
      
      if (response['status'] != 'success') {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}