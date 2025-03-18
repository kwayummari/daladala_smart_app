import 'package:flutter/foundation.dart';
import 'package:daladala_smart_app/config/api_config.dart';
import 'package:daladala_smart_app/models/booking.dart';
import 'package:daladala_smart_app/services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Booking> _bookings = [];
  bool _bookingsLoading = false;
  String _bookingsError = '';
  
  Booking? _currentBooking;
  bool _currentBookingLoading = false;
  String _currentBookingError = '';
  
  // Process status
  bool _processing = false;
  String _processingError = '';
  
  // Getters
  List<Booking> get bookings => _bookings;
  bool get bookingsLoading => _bookingsLoading;
  String get bookingsError => _bookingsError;
  
  Booking? get currentBooking => _currentBooking;
  bool get currentBookingLoading => _currentBookingLoading;
  String get currentBookingError => _currentBookingError;
  
  bool get processing => _processing;
  String get processingError => _processingError;
  
  // Filter bookings
  List<Booking> get activeBookings => _bookings.where((b) => b.isPending || b.isConfirmed || b.isInProgress).toList();
  List<Booking> get completedBookings => _bookings.where((b) => b.isCompleted).toList();
  List<Booking> get cancelledBookings => _bookings.where((b) => b.isCancelled).toList();
  
  // Create a new booking
  Future<bool> createBooking(int tripId, int pickupStopId, int dropoffStopId, int passengerCount) async {
    _processing = true;
    _processingError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.post<Booking>(
        ApiConfig.bookings,
        data: {
          'trip_id': tripId,
          'pickup_stop_id': pickupStopId,
          'dropoff_stop_id': dropoffStopId,
          'passenger_count': passengerCount,
        },
        fromJson: (json) => Booking.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _currentBooking = response.data;
        await fetchBookings(); // Refresh bookings list
        _processing = false;
        notifyListeners();
        return true;
      } else {
        _processingError = response.message;
        _processing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _processingError = 'Failed to create booking: ${e.toString()}';
      _processing = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch user bookings
  Future<void> fetchBookings({String? status}) async {
  _bookingsLoading = true;
  _bookingsError = '';
  notifyListeners();
  
  try {
    final queryParams = status != null ? {'status': status} : null;
    
    final response = await _apiService.getList<Booking>(
      ApiConfig.bookings,
      queryParams: queryParams,
      fromJson: (json) => Booking.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      _bookings = response.data!;
    } else {
      _bookingsError = response.message;
    }
  } catch (e) {
    _bookingsError = 'Failed to fetch bookings: ${e.toString()}';
  } finally {
    _bookingsLoading = false;
    notifyListeners();
  }
}
  
  // Fetch booking details
  Future<void> fetchBookingDetails(int bookingId) async {
    _currentBookingLoading = true;
    _currentBookingError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<Booking>(
        '${ApiConfig.bookingById}/$bookingId',
        fromJson: (json) => Booking.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _currentBooking = response.data;
      } else {
        _currentBookingError = response.message;
      }
    } catch (e) {
      _currentBookingError = 'Failed to fetch booking details: ${e.toString()}';
    } finally {
      _currentBookingLoading = false;
      notifyListeners();
    }
  }
  
  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    _processing = true;
    _processingError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.put<void>(
        '${ApiConfig.cancelBooking}/$bookingId/cancel',
      );
      
      if (response.success) {
        // Update local state
        if (_currentBooking != null && _currentBooking!.bookingId == bookingId) {
          await fetchBookingDetails(bookingId);
        }
        await fetchBookings();
        _processing = false;
        notifyListeners();
        return true;
      } else {
        _processingError = response.message;
        _processing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _processingError = 'Failed to cancel booking: ${e.toString()}';
      _processing = false;
      notifyListeners();
      return false;
    }
  }
}