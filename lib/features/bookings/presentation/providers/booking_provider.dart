import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  Future<Either<Failure, List<Booking>>> getUserBookings({
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
    
    return result;
  }
  
  // Create booking
  Future<Either<Failure, Booking>> createBooking({
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
    
    return result;
  }
  
  // Get booking details
  Future<Either<Failure, Booking>> getBookingDetails(int bookingId) async {
    if (getBookingDetailsUseCase == null) {
      return Left(ServerFailure(message: 'Feature not implemented'));
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
    
    return result;
  }
  
  // Cancel booking
  Future<Either<Failure, void>> cancelBooking(int bookingId) async {
    if (cancelBookingUseCase == null) {
      return Left(ServerFailure(message: 'Feature not implemented'));
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
    
    return result;
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

// Define the Booking entity stub since we haven't implemented it yet
class Booking {
  final int id;
  final int userId;
  final int tripId;
  final int pickupStopId;
  final int dropoffStopId;
  final DateTime bookingTime;
  final double fareAmount;
  final int passengerCount;
  final String status;
  final String paymentStatus;
  
  Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.bookingTime,
    required this.fareAmount,
    required this.passengerCount,
    required this.status,
    required this.paymentStatus,
  });
  
  Booking copyWith({
    int? id,
    int? userId,
    int? tripId,
    int? pickupStopId,
    int? dropoffStopId,
    DateTime? bookingTime,
    double? fareAmount,
    int? passengerCount,
    String? status,
    String? paymentStatus,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      bookingTime: bookingTime ?? this.bookingTime,
      fareAmount: fareAmount ?? this.fareAmount,
      passengerCount: passengerCount ?? this.passengerCount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

// Usecase parameter classes
class CreateBookingParams {
  final int tripId;
  final int pickupStopId;
  final int dropoffStopId;
  final int passengerCount;
  
  CreateBookingParams({
    required this.tripId,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.passengerCount,
  });
}

class GetUserBookingsParams {
  final String? status;
  
  GetUserBookingsParams({this.status});
}

class GetBookingDetailsParams {
  final int bookingId;
  
  GetBookingDetailsParams({required this.bookingId});
}

class CancelBookingParams {
  final int bookingId;
  
  CancelBookingParams({required this.bookingId});
}