import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';

abstract class TripRepository {
  /// Get upcoming trips
  Future<Either<Failure, List<Trip>>> getUpcomingTrips({int? routeId});
  
  /// Get trip details
  Future<Either<Failure, Trip>> getTripDetails(int tripId);
  
  /// Update trip status (for driver)
  Future<Either<Failure, void>> updateTripStatus({
    required int tripId,
    required String status,
    int? currentStopId,
    int? nextStopId,
  });
  
  /// Update vehicle location (for driver)
  Future<Either<Failure, void>> updateVehicleLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  });
}