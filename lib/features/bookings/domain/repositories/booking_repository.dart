import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  /// Create a new booking
  Future<Either<Failure, Booking>> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
  });
  
  /// Get bookings for the current user
  Future<Either<Failure, List<Booking>>> getUserBookings({String? status});
  
  /// Get booking details
  Future<Either<Failure, Booking>> getBookingDetails(int bookingId);
  
  /// Cancel a booking
  Future<Either<Failure, void>> cancelBooking(int bookingId);
}