import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daladala_smart_app/models/user.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: tokenKey);
  }
  
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: tokenKey);
  }
  
  // User Data Management
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(user.toJson());
    await prefs.setString(userKey, userData);
  }
  
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    
    if (userData != null) {
      try {
        return User.fromJson(json.decode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }
  
  // FCM Token Management
  Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fcmTokenKey, token);
  }
  
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(fcmTokenKey);
  }
  
  // Onboarding Status
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingKey, completed);
  }
  
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingKey) ?? false;
  }
  
  // Theme Preference
  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, theme);
  }
  
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeKey) ?? 'system';
  }
  
  // Language Preference
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language);
  }
  
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? 'en';
  }
  
  // Clear All Data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}