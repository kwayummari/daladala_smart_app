import 'package:flutter/foundation.dart';
import 'package:daladala_smart_app/config/api_config.dart';
import 'package:daladala_smart_app/models/user.dart';
import 'package:daladala_smart_app/services/api_service.dart';
import 'package:daladala_smart_app/services/storage_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  User? _user;
  bool _loading = false;
  String _errorMessage = '';
  List<Notification> _notifications = [];
  bool _notificationsLoading = false;
  
  // Getters
  User? get user => _user;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;
  List<Notification> get notifications => _notifications;
  bool get notificationsLoading => _notificationsLoading;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
  
  // Initialize user data
  UserProvider() {
    _loadUserData();
  }
  
  // Load user data from storage
  Future<void> _loadUserData() async {
    _loading = true;
    notifyListeners();
    
    try {
      _user = await _storageService.getUser();
      await fetchProfile();
    } catch (e) {
      _errorMessage = 'Failed to load user data';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Fetch user profile
  Future<void> fetchProfile() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<User>(
        ApiConfig.userProfile,
        fromJson: (json) => User.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        await _storageService.saveUser(_user!);
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch profile: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
  }) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;
      if (profilePicture != null) data['profile_picture'] = profilePicture;
      
      final response = await _apiService.put<User>(
        ApiConfig.updateProfile,
        data: data,
        fromJson: (json) => User.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        await _storageService.saveUser(_user!);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.put<void>(
        ApiConfig.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      
      if (response.success) {
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to change password: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete account
  Future<bool> deleteAccount() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.delete<void>(
        ApiConfig.deleteAccount,
      );
      
      if (response.success) {
        await _storageService.clearAll();
        _user = null;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete account: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch notifications
  Future<void> fetchNotifications() async {
    _notificationsLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get<List<Notification>>(
        ApiConfig.notifications,
        fromJsonList: (jsonList) => 
            jsonList.map((json) => Notification.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _notifications = response.data!;
      }
    } catch (e) {
      debugPrint('Failed to fetch notifications: ${e.toString()}');
    } finally {
      _notificationsLoading = false;
      notifyListeners();
    }
  }
  
  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _apiService.put<void>(
        '${ApiConfig.markNotificationRead}/$notificationId/read',
      );
      
      if (response.success) {
        // Update local notification state
        final index = _notifications.indexWhere(
          (n) => n.notificationId == notificationId
        );
        
        if (index != -1) {
          final updatedNotifications = List<Notification>.from(_notifications);
          // Create a new notification with updated read status
          // Since Notification class is immutable, we need to create a new instance
          // However, since we don't have a proper constructor to update isRead,
          // this is just a placeholder. In reality you might need a different approach.
          // updatedNotifications[index] = updatedNotifications[index].copyWith(isRead: true);
          _notifications = updatedNotifications;
          notifyListeners();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to mark notification as read: ${e.toString()}');
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await _apiService.put<void>(
        ApiConfig.markAllNotificationsRead,
      );
      
      if (response.success) {
        await fetchNotifications(); // Refresh notifications
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    }
  }
}