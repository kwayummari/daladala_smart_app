// lib/core/services/api_service.dart
// ENHANCED VERSION - Keeping your existing format and adding new methods

import 'dart:convert';
import 'dart:io';
import 'package:daladala_smart_app/core/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  Future<String?> _getAuthToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-access-token': token,
    };
  }

  // ============================================================================
  // EXISTING METHODS (Keep all your existing methods exactly as they are)
  // ============================================================================

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
        request.headers['x-access-token'] = token; // Use correct header
      }

      String mimeType = 'image/jpeg'; // Default
      String extension = imageFile.path.split('.').last.toLowerCase();

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: MediaType.parse(mimeType), // ADD THIS
        ),
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

  // Wallet Methods
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/balance'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load wallet balance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
      };

      final uri = Uri.parse(
        '$baseUrl/wallet/transactions',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load wallet transactions');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? phoneNumber,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'amount': amount,
        'payment_method': paymentMethod,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/topup'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to top up wallet');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> processWalletPayment({
    required int bookingId,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {'booking_id': bookingId};

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/pay'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process wallet payment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Booking Methods
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse(
        '$baseUrl/bookings',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load booking details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
    List<String>? seatNumbers, // NEW: Add seat selection support
    String? bookingType, // NEW: Add booking type support
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'trip_id': tripId,
        'pickup_stop_id': pickupStopId,
        'dropoff_stop_id': dropoffStopId,
        'passenger_count': passengerCount,
        if (seatNumbers != null && seatNumbers.isNotEmpty)
          'seat_numbers': seatNumbers,
        if (bookingType != null) 'booking_type': bookingType,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAvailableTrips({
    String? from,
    String? to,
    DateTime? date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
      };

      final uri = Uri.parse(
        '$baseUrl/trips/upcoming',
      ).replace(queryParameters: queryParams);
      print('Fetching available trips from: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load available trips');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get trip details by ID
  Future<Map<String, dynamic>> getTripDetails(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trips/$tripId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user bookings
  static Future<List<Map<String, dynamic>>> getUserBookings({
    required String authToken,
    String? status,
  }) async {
    try {
      String url =
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.bookingsEndpoint}/';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  // Get all routes
  static Future<List<Map<String, dynamic>>> getAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching routes: $e');
      return [];
    }
  }

  // Get route by ID
  static Future<Map<String, dynamic>?> getRouteById(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/$routeId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }

  // Search stops
  static Future<List<Map<String, dynamic>>> searchStops(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.stopsEndpoint}/search?q=$query',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching stops: $e');
      return [];
    }
  }

  // Get all stops
  static Future<List<Map<String, dynamic>>> getAllStops() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.stopsEndpoint}/',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching stops: $e');
      return [];
    }
  }

  // Get route stops
  static Future<List<Map<String, dynamic>>> getRouteStops(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/$routeId/stops',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching route stops: $e');
      return [];
    }
  }

  // Get fare between stops
  static Future<Map<String, dynamic>?> getFareBetweenStops({
    required int routeId,
    required int startStopId,
    required int endStopId,
    String fareType = 'standard',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/fare?route_id=$routeId&start_stop_id=$startStopId&end_stop_id=$endStopId&fare_type=$fareType',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching fare: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Payment Methods
  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? phoneNumber,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (paymentDetails != null) 'payment_details': paymentDetails,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/payments/process'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process payment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(int paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get payment status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Trips Methods
  Future<Map<String, dynamic>> getTrips({
    String? from,
    String? to,
    DateTime? date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
      };

      final uri = Uri.parse(
        '$baseUrl/trips',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Notifications Methods
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (isRead != null) 'is_read': isRead.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/notifications',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/mark-all-read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Dashboard/Stats Methods
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ZenoPay Integration Methods
  Future<Map<String, dynamic>> checkZenoPayStatus(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/payments/zenopay/status/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check ZenoPay status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchRoutes({
    required String startPoint,
    required String endPoint,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.apiBaseUrl}${AppConstants.routesEndpoint}/search?start_point=$startPoint&end_point=$endPoint',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching trips: $e');
      return [];
    }
  }

  // Auth related methods (if needed)
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update stored tokens
        await prefs.setString('auth_token', data['data']['access_token']);
        if (data['data']['refresh_token'] != null) {
          await prefs.setString('refresh_token', data['data']['refresh_token']);
        }

        return data;
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
  }

  // Utility method to logout (clear tokens)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // ============================================================================
  // NEW METHODS FOR ENHANCED FEATURES (Added to your existing class)
  // ============================================================================

  // Enhanced Authentication Methods (Phone/Email Login)
  Future<Map<String, dynamic>> loginWithIdentifier({
    required String identifier, // Can be phone or email
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> registerWithNationalId({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String nationalId, // NEW: National ID requirement
    String role = 'passenger',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'password': password,
          'national_id': nationalId,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Driver Trip Management Methods
  Future<Map<String, dynamic>> startTrip(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips/$tripId/start'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start trip');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> endTrip(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips/$tripId/end'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to end trip');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips/location'),
        headers: headers,
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update location');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getDriverTrips({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/trips/driver';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load driver trips');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getTripSeatOccupancy(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trips/$tripId/seats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load seat occupancy');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> markPassengerBoarded({
    required int tripId,
    required int seatId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips/$tripId/seats/$seatId/board'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark passenger as boarded');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> markPassengerAlighted({
    required int tripId,
    required int seatId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips/$tripId/seats/$seatId/alight'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark passenger as alighted');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Passenger Trip Tracking Methods
  Future<Map<String, dynamic>> getLiveTripLocation(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trips/$tripId/location'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get trip location');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getPassengerTrips({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/trips/passenger';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load passenger trips');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Seat Selection Methods
  Future<Map<String, dynamic>> getAvailableSeats({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/bookings/seats/available?trip_id=$tripId&pickup_stop_id=$pickupStopId&dropoff_stop_id=$dropoffStopId',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load available seats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Pre-booking Methods (30 Days Advance)
  Future<Map<String, dynamic>> createPreBooking({
    required int routeId,
    required int pickupStopId,
    required int dropoffStopId,
    required List<String> travelDates,
    String? preferredTime,
    int passengerCount = 1,
    List<String>? seatPreferences,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'route_id': routeId,
        'pickup_stop_id': pickupStopId,
        'dropoff_stop_id': dropoffStopId,
        'travel_dates': travelDates,
        'passenger_count': passengerCount,
        if (preferredTime != null) 'preferred_time': preferredTime,
        if (seatPreferences != null) 'seat_preferences': seatPreferences,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/pre-bookings'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create pre-booking');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreBookings({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/pre-bookings';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load pre-bookings');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> cancelPreBooking(int preBookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/pre-bookings/$preBookingId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to cancel pre-booking');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // On-demand Transportation Methods
  Future<Map<String, dynamic>> createOnDemandRequest({
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String destinationLocation,
    required double destinationLatitude,
    required double destinationLongitude,
    int passengerCount = 1,
    int minimumPassengers = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'pickup_location': pickupLocation,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'destination_location': destinationLocation,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'passenger_count': passengerCount,
        'minimum_passengers': minimumPassengers,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/on-demand'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create on-demand request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> joinOnDemandRequest({
    required int requestId,
    int passengerCount = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/on-demand/$requestId/join'),
        headers: headers,
        body: json.encode({'passenger_count': passengerCount}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to join on-demand request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getNearbyOnDemandRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/on-demand/nearby?latitude=$latitude&longitude=$longitude&radius=$radiusKm',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load nearby on-demand requests');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Business/Corporate Booking Methods
  Future<Map<String, dynamic>> createBusinessAccount({
    required String businessName,
    required String businessRegistrationNumber,
    required String contactPerson,
    required String businessPhone,
    String? businessEmail,
    String? taxId,
    String? address,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'business_name': businessName,
        'business_registration_number': businessRegistrationNumber,
        'contact_person': contactPerson,
        'business_phone': businessPhone,
        if (businessEmail != null) 'business_email': businessEmail,
        if (taxId != null) 'tax_id': taxId,
        if (address != null) 'address': address,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/business'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create business account');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createEmployeeBooking(Map<String, dynamic> bookingData, {
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required String employeeName,
    String? employeeId,
    String? department,
    int passengerCount = 1,
    List<String>? seatPreferences,
    bool autoApprove = false,
  }) async {
    try {
      final headers = await _getHeaders();
      final data = {
        'trip_id': tripId,
        'pickup_stop_id': pickupStopId,
        'dropoff_stop_id': dropoffStopId,
        'employee_name': employeeName,
        'passenger_count': passengerCount,
        'auto_approve': autoApprove,
        if (employeeId != null) 'employee_id': employeeId,
        if (department != null) 'department': department,
        if (seatPreferences != null) 'seat_preferences': seatPreferences,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/business/bookings'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create employee booking');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

   Future<http.Response> getCurrentUser() async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl/auth/me'), headers: headers);
  }

  Future<Map<String, dynamic>> getBusinessBookings({
    required int businessId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/business/$businessId/bookings';

      if (filters != null && filters.isNotEmpty) {
        final queryParams = filters.entries
            .where((entry) => entry.value != null)
            .map((entry) => '${entry.key}=${entry.value}')
            .join('&');
        if (queryParams.isNotEmpty) {
          url += '?$queryParams';
        }
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load business bookings');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getPendingApprovals(int businessId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/business/$businessId/pending-approvals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load pending approvals');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> approveEmployeeBooking({
    required int businessBookingId,
    required String decision, // 'approved' or 'rejected'
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/business/bookings/$businessBookingId/approve'),
        headers: headers,
        body: json.encode({'decision': decision}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process booking approval');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // QR Code & Receipt Methods
  Future<Map<String, dynamic>> generateBookingQRCode(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/receipts/booking/$bookingId/qr'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate QR code');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> validateTicket(String qrData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/receipts/validate-ticket'),
        headers: headers,
        body: json.encode({'qr_data': qrData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to validate ticket');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserReceipts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/receipts?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load receipts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyReceipt(String receiptNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/receipts/verify/$receiptNumber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to verify receipt');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Enhanced Route & Stop Methods
  Future<Map<String, dynamic>> getRoutesWithStops() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/routes/with-stops'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load routes with stops');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getStopsForRoute(int routeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/routes/$routeId/stops'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stops for route');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Enhanced Search Methods
  Future<Map<String, dynamic>> searchTripsAdvanced({
    int? routeId,
    int? pickupStopId,
    int? dropoffStopId,
    DateTime? date,
    String? timeRange,
    int? minSeats,
    String? vehicleType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (routeId != null) 'route_id': routeId.toString(),
        if (pickupStopId != null) 'pickup_stop_id': pickupStopId.toString(),
        if (dropoffStopId != null) 'dropoff_stop_id': dropoffStopId.toString(),
        if (date != null) 'date': date.toIso8601String().split('T')[0],
        if (timeRange != null) 'time_range': timeRange,
        if (minSeats != null) 'min_seats': minSeats.toString(),
        if (vehicleType != null) 'vehicle_type': vehicleType,
      };

      final uri = Uri.parse(
        '$baseUrl/trips/search',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search trips');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method to handle API responses consistently
  static Map<String, dynamic> handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': data, 'statusCode': response.statusCode};
    } else {
      return {
        'success': false,
        'error': data['message'] ?? 'An error occurred',
        'statusCode': response.statusCode,
        'data': data,
      };
    }
  }
}
