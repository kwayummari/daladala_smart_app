import 'package:flutter/foundation.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_user_bookings_usecase.dart';
import '../../domain/usecases/get_booking_details_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';

class BookingProvider extends ChangeNotifier {
  final CreateBookingUseCase createBookingUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;
  final GetBookingDetailsUseCase? getBookingDetailsUseCase;
  final CancelBookingUseCase? cancelBookingUseCase;
  
  BookingProvider({
    required this.createBookingUseCase,
    required this.getUserBookingsUseCase,
    this.getBookingDetailsUseCase,
    this.cancelBookingUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  List<Booking>? _bookings;
  List<Booking>? get bookings => _bookings;
  
  Booking? _currentBooking;
  Booking? get currentBooking => _currentBooking;
  
  String? _error;
  String? get error => _error;
  
  // Load user bookings
  Future<void> getUserBookings({
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetUserBookingsParams(status: status);
    final result = await getUserBookingsUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (bookings) {
        _bookings = bookings;
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Create booking
  Future<void> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = CreateBookingParams(
      tripId: tripId,
      pickupStopId: pickupStopId,
      dropoffStopId: dropoffStopId,
      passengerCount: passengerCount,
    );
    
    final result = await createBookingUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (booking) {
        _currentBooking = booking;
        if (_bookings != null) {
          _bookings = [booking, ..._bookings!];
        } else {
          _bookings = [booking];
        }
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Get booking details
  Future<void> getBookingDetails(int bookingId) async {
    if (getBookingDetailsUseCase == null) {
      _error = 'Feature not implemented';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetBookingDetailsParams(bookingId: bookingId);
    final result = await getBookingDetailsUseCase!(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (booking) {
        _currentBooking = booking;
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Cancel booking
  Future<void> cancelBooking(int bookingId) async {
    if (cancelBookingUseCase == null) {
      _error = 'Feature not implemented';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = CancelBookingParams(bookingId: bookingId);
    final result = await cancelBookingUseCase!(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Update the booking status in the list
        if (_bookings != null) {
          final index = _bookings!.indexWhere((booking) => booking.id == bookingId);
          if (index != -1) {
            final updatedBooking = _bookings![index].copyWith(status: 'cancelled');
            _bookings![index] = updatedBooking;
            
            if (_currentBooking?.id == bookingId) {
              _currentBooking = updatedBooking;
            }
          }
        }
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Clear current booking
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}