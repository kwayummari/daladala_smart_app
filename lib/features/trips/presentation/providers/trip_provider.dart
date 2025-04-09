import 'package:daladala_smart_app/features/trips/domains/entities/trip.dart';
import 'package:daladala_smart_app/features/trips/domains/usecases/get_trip_details_usecase.dart';
import 'package:daladala_smart_app/features/trips/domains/usecases/get_upcoming_trips_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
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
  // In TripProvider
Future<Either<Failure, List<Trip>>> getUpcomingTrips({
  int? routeId,
}) async {
  // Set loading without notifying
  _isLoading = true;
  _error = null;
  
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
  
  // Update state once at the end
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