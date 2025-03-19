import 'package:daladala_smart_app/features/trips/domains/usecases/get_trip_details_usecase.dart';
import 'package:daladala_smart_app/features/trips/domains/usecases/get_upcoming_trips_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/error/failures.dart';

class TripProvider extends ChangeNotifier {
  final GetUpcomingTripsUseCase getUpcomingTripsUseCase;
  final GetTripDetailsUseCase getTripDetailsUseCase;
  
  TripProvider({
    required this.getUpcomingTripsUseCase,
    required this.getTripDetailsUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  List<Trip>? _upcomingTrips;
  List<Trip>? get upcomingTrips => _upcomingTrips;
  
  Trip? _currentTrip;
  Trip? get currentTrip => _currentTrip;
  
  String? _error;
  String? get error => _error;
  
  // Get upcoming trips
  Future<Either<Failure, List<Trip>>> getUpcomingTrips({
    int? routeId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetUpcomingTripsParams(routeId: routeId);
    final result = await getUpcomingTripsUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (trips) {
        _upcomingTrips = trips;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Get trip details
  Future<Either<Failure, Trip>> getTripDetails(int tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final params = GetTripDetailsParams(tripId: tripId);
    final result = await getTripDetailsUseCase(params);
    
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (trip) {
        _currentTrip = trip;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  // Clear current trip
  void clearCurrentTrip() {
    _currentTrip = null;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Define the Trip entity stub since we haven't implemented it yet
class Trip {
  final int id;
  final int scheduleId;
  final int routeId;
  final int vehicleId;
  final int? driverId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int? currentStopId;
  final int? nextStopId;
  final LatLng? currentLocation;
  final String? routeName;
  final String? vehiclePlate;
  final String? driverName;
  final double? driverRating;
  
  Trip({
    required this.id,
    required this.scheduleId,
    required this.routeId,
    required this.vehicleId,
    this.driverId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.currentStopId,
    this.nextStopId,
    this.currentLocation,
    this.routeName,
    this.vehiclePlate,
    this.driverName,
    this.driverRating,
  });
  
  Trip copyWith({
    int? id,
    int? scheduleId,
    int? routeId,
    int? vehicleId,
    int? driverId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? currentStopId,
    int? nextStopId,
    LatLng? currentLocation,
    String? routeName,
    String? vehiclePlate,
    String? driverName,
    double? driverRating,
  }) {
    return Trip(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      currentStopId: currentStopId ?? this.currentStopId,
      nextStopId: nextStopId ?? this.nextStopId,
      currentLocation: currentLocation ?? this.currentLocation,
      routeName: routeName ?? this.routeName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
    );
  }
}

// Usecase parameter classes
class GetUpcomingTripsParams {
  final int? routeId;
  
  GetUpcomingTripsParams({this.routeId});
}

class GetTripDetailsParams {
  final int tripId;
  
  GetTripDetailsParams({required this.tripId});
}