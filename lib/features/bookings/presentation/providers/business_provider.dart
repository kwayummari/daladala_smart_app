import 'package:daladala_smart_app/services/api_service.dart';
import 'package:flutter/foundation.dart';

class BusinessProvider extends ChangeNotifier {
  Map<String, dynamic>? _businessAccount;
  List<dynamic> _pendingApprovals = [];
  List<dynamic> _recentBookings = [];
  List<dynamic> _allBookings = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get businessAccount => _businessAccount;
  List<dynamic> get pendingApprovals => _pendingApprovals;
  List<dynamic> get recentBookings => _recentBookings;
  List<dynamic> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load business account
  Future<void> loadBusinessAccount() async {
    _setLoading(true);
    try {
      final apiService = ApiService();
      final response = await apiService.getCurrentUser();
      final result = ApiService.handleResponse(response);

      if (result['success']) {
        final userData = result['data']['data'];
        if (userData['user']['role'] == 'business') {
          // User has business role, load business account details
          await _loadBusinessDetails(userData['user']['id']);
        }
        _error = null;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to load business account: $e';
    }
    _setLoading(false);
  }

  Future<void> _loadBusinessDetails(int userId) async {
    try {
      // This would be a new API endpoint to get business account by user ID
      // For now, we'll simulate the response
      _businessAccount = {
        'business_info': {
          'business_id': 1,
          'business_name': 'Sample Corp Ltd',
          'registration_number': 'RC123456',
          'status': 'active',
          'contact_person': 'John Doe',
        },
        'booking_statistics': {
          'total_bookings': 45,
          'total_amount': 135000,
          'by_status': {
            'approved': {'count': 40, 'amount': 120000},
            'pending': {'count': 3, 'amount': 9000},
            'rejected': {'count': 2, 'amount': 6000},
          },
        },
      };
    } catch (e) {
      debugPrint('Failed to load business details: $e');
    }
  }

  // Create employee booking
  Future<bool> createEmployeeBooking(Map<String, dynamic> bookingData) async {
    _setLoading(true);
    try {
      final apiService = ApiService();
      final result = await apiService.createEmployeeBooking(
        bookingData,
        tripId: bookingData['tripId'],
        pickupStopId: bookingData['pickupStopId'],
        dropoffStopId: bookingData['dropoffStopId'],
        employeeName: bookingData['employeeName'],
      );
      if (result['success']) {
        await loadPendingApprovals(); // Refresh approvals
        await loadRecentBookings(); // Refresh recent bookings
        _error = null;
        return true;
      } else {
        _error = result['error'];
        return false;
      }
    } catch (e) {
      _error = 'Failed to create employee booking: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load pending approvals
  Future<void> loadPendingApprovals() async {
    if (_businessAccount == null) return;

    _setLoading(true);
    try {
      final businessId = _businessAccount!['business_info']['business_id'];
      final apiService = ApiService();
      final result = await apiService.getPendingApprovals(businessId);
      if (result['success']) {
        _pendingApprovals = result['data'] ?? [];
        _error = null;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to load pending approvals: $e';
    }
    _setLoading(false);
  }

  // Approve/reject employee booking
  Future<bool> approveEmployeeBooking(
    int businessBookingId,
    String decision,
  ) async {
    _setLoading(true);
    try {
      final apiService = ApiService();
      final result = await apiService.approveEmployeeBooking(
        businessBookingId: businessBookingId, decision: decision,
      );

      if (result['success']) {
        await loadPendingApprovals(); // Refresh approvals
        await loadBusinessAccount(); // Refresh stats
        _error = null;
        return true;
      } else {
        _error = result['error'];
        return false;
      }
    } catch (e) {
      _error = 'Failed to process approval: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load recent bookings
  Future<void> loadRecentBookings() async {
    if (_businessAccount == null) return;

    try {
      final businessId = _businessAccount!['business_info']['business_id'];
      final apiService = ApiService();
      final result = await apiService.getBusinessBookings(
        filters: {'limit': 5}, businessId: businessId,
      );

      if (result['success']) {
        _recentBookings = result['data']['bookings'] ?? [];
      }
    } catch (e) {
      debugPrint('Failed to load recent bookings: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
