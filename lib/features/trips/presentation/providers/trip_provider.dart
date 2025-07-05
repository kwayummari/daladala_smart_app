import 'package:flutter/material.dart';
import 'package:daladala_smart_app/features/trips/domains/entities/trip.dart';
import 'package:daladala_smart_app/features/trips/domains/usecases/get_upcoming_trips_usecase.dart';
import 'package:daladala_smart_app/features/trips/domains/usecases/get_trip_details_usecase.dart';

class TripProvider with ChangeNotifier {
  final GetUpcomingTripsUseCase getUpcomingTripsUseCase;
  final GetTripDetailsUseCase getTripDetailsUseCase;

  TripProvider({
    required this.getUpcomingTripsUseCase,
    required this.getTripDetailsUseCase,
  });

  // Loading states
  bool _isLoading = false;
  bool _isLoadingTripDetails = false;

  // Data
  List<Trip> _upcomingTrips = [];
  List<Trip> _tripsByRoute = [];
  Trip? _currentTripDetails;

  // Error handling
  String? _errorMessage;
  String? _tripDetailsErrorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingTripDetails => _isLoadingTripDetails;
  List<Trip> get upcomingTrips => _upcomingTrips;
  List<Trip> get tripsByRoute => _tripsByRoute;
  Trip? get currentTripDetails => _currentTripDetails;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Add this getter for compatibility
  String? get tripDetailsErrorMessage => _tripDetailsErrorMessage;

  /// Get upcoming trips for the user
  Future<void> getUpcomingTrips({int? routeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = GetUpcomingTripsParams(routeId: routeId);
      final result = await getUpcomingTripsUseCase.call(params);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _upcomingTrips = [];
        },
        (trips) {
          _upcomingTrips = trips;
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to load upcoming trips: ${e.toString()}';
      _upcomingTrips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get trip details by ID
  Future<void> getTripDetails(int tripId) async {
    _isLoadingTripDetails = true;
    _tripDetailsErrorMessage = null;
    _currentTripDetails = null;
    notifyListeners();

    try {
      final params = GetTripDetailsParams(tripId: tripId);
      final result = await getTripDetailsUseCase.call(params);

      result.fold(
        (failure) {
          _tripDetailsErrorMessage = failure.message;
          _currentTripDetails = null;
        },
        (trip) {
          _currentTripDetails = trip;
          _tripDetailsErrorMessage = null;
        },
      );
    } catch (e) {
      _tripDetailsErrorMessage = 'Failed to load trip details: ${e.toString()}';
      _currentTripDetails = null;
    } finally {
      _isLoadingTripDetails = false;
      notifyListeners();
    }
  }

  /// Get trips by route
  Future<void> getTripsByRoute(int routeId, {String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = GetUpcomingTripsParams(routeId: routeId);
      final result = await getUpcomingTripsUseCase.call(params);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _tripsByRoute = [];
        },
        (trips) {
          // Filter by date if provided
          if (date != null) {
            final filterDate = DateTime.parse(date);
            _tripsByRoute =
                trips.where((trip) {
                  final tripDate = DateTime(
                    trip.startTime.year,
                    trip.startTime.month,
                    trip.startTime.day,
                  );
                  final filterDateOnly = DateTime(
                    filterDate.year,
                    filterDate.month,
                    filterDate.day,
                  );
                  return tripDate.isAtSameMomentAs(filterDateOnly);
                }).toList();
          } else {
            _tripsByRoute = trips;
          }
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to load trips: ${e.toString()}';
      _tripsByRoute = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current trip details
  void clearTripDetails() {
    _currentTripDetails = null;
    _tripDetailsErrorMessage = null;
    notifyListeners();
  }

  /// Clear error messages
  void clearErrors() {
    _errorMessage = null;
    _tripDetailsErrorMessage = null;
    notifyListeners();
  }

  /// Refresh upcoming trips
  Future<void> refreshUpcomingTrips({int? routeId}) async {
    await getUpcomingTrips(routeId: routeId);
  }

  /// Check if there are any trips for a specific route
  bool hasTripsForRoute(int routeId) {
    return _upcomingTrips.any((trip) => trip.route?.routeId == routeId);
  }

  /// Get upcoming trips count
  int get upcomingTripsCount => _upcomingTrips.length;

  /// Get trips by status
  List<Trip> getTripsByStatus(String status) {
    return _upcomingTrips.where((trip) => trip.status == status).toList();
  }

  /// Get next upcoming trip
  Trip? get nextUpcomingTrip {
    if (_upcomingTrips.isEmpty) return null;

    final now = DateTime.now();
    final futureTrips =
        _upcomingTrips.where((trip) => trip.startTime.isAfter(now)).toList();

    if (futureTrips.isEmpty) return null;

    futureTrips.sort((a, b) => a.startTime.compareTo(b.startTime));
    return futureTrips.first;
  }

  /// Check if user has any active trips
  bool get hasActiveTrips {
    return _upcomingTrips.any(
      (trip) => trip.status == 'active' || trip.status == 'in_progress',
    );
  }
}
