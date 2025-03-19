import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  /// Creates a booking for a trip
  Future<Either<Failure, Booking>> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
  });
  
  /// Gets the bookings for the current user
  Future<Either<Failure, List<Booking>>> getUserBookings({String? status});
  
  /// Gets a specific booking by ID
  Future<Either<Failure, Booking>> getBookingDetails(int bookingId);
  
  /// Cancels a booking
  Future<Either<Failure, void>> cancelBooking(int bookingId);
}