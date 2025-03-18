import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/services/storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  final StorageService _storageService = StorageService();
  
  // Helper method to add authorization header
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
    List<T> Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final headers = await _getHeaders();
      
      if (queryParams != null) {
        final queryString = Uri(queryParameters: queryParams).query;
        url = '$url?$queryString';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(AppConfig.timeoutDuration);

      return _processResponse<T>(response, fromJson, fromJsonList);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No Internet connection',
        statusCode: 0,
      );
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        message: 'Request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
    List<T> Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(AppConfig.timeoutDuration);

      return _processResponse<T>(response, fromJson, fromJsonList);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No Internet connection',
        statusCode: 0,
      );
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        message: 'Request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
    List<T> Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(AppConfig.timeoutDuration);

      return _processResponse<T>(response, fromJson, fromJsonList);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No Internet connection',
        statusCode: 0,
      );
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        message: 'Request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    List<T> Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(AppConfig.timeoutDuration);

      return _processResponse<T>(response, fromJson, fromJsonList);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No Internet connection',
        statusCode: 0,
      );
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        message: 'Request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Process HTTP response
  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
    List<T> Function(List<dynamic>)? fromJsonList,
  ) {
    try {
      final responseJson = json.decode(response.body);
      final statusCode = response.statusCode;
      
      if (statusCode >= 200 && statusCode < 300) {
        final success = responseJson['status'] == 'success';
        final message = responseJson['message'] ?? '';
        
        // Handle data response based on type
        T? data;
        if (fromJson != null && responseJson['data'] != null) {
          data = fromJson(responseJson['data']);
        } else if (fromJsonList != null && responseJson['data'] != null) {
          data = fromJsonList(responseJson['data']) as T;
        }

        return ApiResponse(
          success: success,
          message: message,
          data: data,
          statusCode: statusCode,
        );
      } else {
        final message = responseJson['message'] ?? 'Request failed';
        return ApiResponse(
          success: false,
          message: message,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Add this method specifically for handling lists
Future<ApiResponse<List<T>>> getList<T>(
  String url, {
  Map<String, String>? queryParams,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final headers = await _getHeaders();
    
    if (queryParams != null) {
      final queryString = Uri(queryParameters: queryParams).query;
      url = '$url?$queryString';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    ).timeout(AppConfig.timeoutDuration);

    return _processListResponse<T>(response, fromJson);
  } on SocketException {
    return ApiResponse(
      success: false,
      message: 'No Internet connection',
      statusCode: 0,
    );
  } on Exception catch (e) {
    return ApiResponse(
      success: false,
      message: 'Request failed: ${e.toString()}',
      statusCode: 0,
    );
  }
}

// Process HTTP response for list data
ApiResponse<List<T>> _processListResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) fromJson,
) {
  try {
    final responseJson = json.decode(response.body);
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      final success = responseJson['status'] == 'success';
      final message = responseJson['message'] ?? '';
      
      List<T>? data;
      if (responseJson['data'] != null && responseJson['data'] is List) {
        data = (responseJson['data'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        data = <T>[];
      }

      return ApiResponse(
        success: success,
        message: message,
        data: data,
        statusCode: statusCode,
      );
    } else {
      final message = responseJson['message'] ?? 'Request failed';
      return ApiResponse(
        success: false,
        message: message,
        statusCode: statusCode,
      );
    }
  } catch (e) {
    return ApiResponse(
      success: false,
      message: 'Failed to process response: ${e.toString()}',
      statusCode: response.statusCode,
    );
  }
}
}