// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/constants.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/api'; // Replace with your actual API URL

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final token = await _getAuthToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/upload-avatar'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['data']['profile_picture'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
}
