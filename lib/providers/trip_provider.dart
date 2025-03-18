import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:daladala_smart_app/config/api_config.dart';
import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/models/stop.dart';
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/services/api_service.dart';
import 'package:daladala_smart_app/services/location_service.dart';

class TripProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  
  // Routes list
  List<app_route.Route> _routes = [];
  bool _routesLoading = false;
  String _routesError = '';
  
  // Stops list
  List<Stop> _stops = [];
  bool _stopsLoading = false;
  String _stopsError = '';
  
  // Routes and stops for a specific route
  app_route.Route? _selectedRoute;
  List<app_route.RouteStop> _routeStops = [];
  bool _routeDetailsLoading = false;
  String _routeDetailsError = '';
  
  // Upcoming trips
  List<Trip> _upcomingTrips = [];
  bool _upcomingTripsLoading = false;
  String _upcomingTripsError = '';
  
  // Current trip details
  Trip? _currentTrip;
  bool _currentTripLoading = false;
  String _currentTripError = '';
  Timer? _tripRefreshTimer;
  
  // Current location
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  
  // Getters
  List<app_route.Route> get routes => _routes;
  bool get routesLoading => _routesLoading;
  String get routesError => _routesError;
  
  List<Stop> get stops => _stops;
  bool get stopsLoading => _stopsLoading;
  String get stopsError => _stopsError;
  
  app_route.Route? get selectedRoute => _selectedRoute;
  List<app_route.RouteStop> get routeStops => _routeStops;
  bool get routeDetailsLoading => _routeDetailsLoading;
  String get routeDetailsError => _routeDetailsError;
  
  List<Trip> get upcomingTrips => _upcomingTrips;
  bool get upcomingTripsLoading => _upcomingTripsLoading;
  String get upcomingTripsError => _upcomingTripsError;
  
  Trip? get currentTrip => _currentTrip;
  bool get currentTripLoading => _currentTripLoading;
  String get currentTripError => _currentTripError;
  
  LocationData? get currentLocation => _currentLocation;
  
  // Initialize
  TripProvider() {
    _initializeLocationService();
  }
  
  // Initialize location service
  Future<void> _initializeLocationService() async {
    await _locationService.initialize();
    _getCurrentLocation();
  }
  
  // Get current location
  Future<void> _getCurrentLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    notifyListeners();
  }
  
  // Start location updates
  void startLocationUpdates() {
    _locationService.startLocationUpdates();
    _locationSubscription = _locationService.locationStream?.listen((locationData) {
      _currentLocation = locationData;
      notifyListeners();
    });
  }
  
  // Stop location updates
  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationService.stopLocationUpdates();
  }
  
  // Fetch all routes
  Future<void> fetchRoutes() async {
    _routesLoading = true;
    _routesError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<List<app_route.Route>>(
        ApiConfig.routes,
        fromJsonList: (jsonList) => 
            jsonList.map((json) => app_route.Route.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _routes = response.data!;
      } else {
        _routesError = response.message;
      }
    } catch (e) {
      _routesError = 'Failed to fetch routes: ${e.toString()}';
    } finally {
      _routesLoading = false;
      notifyListeners();
    }
  }
  
  // Search routes
  Future<List<app_route.Route>> searchRoutes(String startPoint, String endPoint) async {
    try {
      final response = await _apiService.get<List<app_route.Route>>(
        ApiConfig.searchRoutes,
        queryParams: {
          'start_point': startPoint,
          'end_point': endPoint,
        },
        fromJsonList: (jsonList) => 
            jsonList.map((json) => app_route.Route.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      debugPrint('Failed to search routes: ${e.toString()}');
      return [];
    }
  }
  
  // Fetch all stops
  Future<void> fetchStops() async {
    _stopsLoading = true;
    _stopsError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<List<Stop>>(
        ApiConfig.stops,
        fromJsonList: (jsonList) => 
            jsonList.map((json) => Stop.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _stops = response.data!;
      } else {
        _stopsError = response.message;
      }
    } catch (e) {
      _stopsError = 'Failed to fetch stops: ${e.toString()}';
    } finally {
      _stopsLoading = false;
      notifyListeners();
    }
  }
  
  // Search stops
  Future<List<Stop>> searchStops(String query) async {
    try {
      final response = await _apiService.get<List<Stop>>(
        ApiConfig.searchStops,
        queryParams: {'query': query},
        fromJsonList: (jsonList) => 
            jsonList.map((json) => Stop.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      debugPrint('Failed to search stops: ${e.toString()}');
      return [];
    }
  }
  
  // Set selected route and fetch details
  Future<void> selectRoute(int routeId) async {
    _routeDetailsLoading = true;
    _routeDetailsError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<app_route.Route>(
        '${ApiConfig.routeById}/$routeId',
        fromJson: (json) => app_route.Route.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _selectedRoute = response.data;
        await fetchRouteStops(routeId);
      } else {
        _routeDetailsError = response.message;
      }
    } catch (e) {
      _routeDetailsError = 'Failed to fetch route details: ${e.toString()}';
    } finally {
      _routeDetailsLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch route stops
  Future<void> fetchRouteStops(int routeId) async {
    try {
      final response = await _apiService.get<List<app_route.RouteStop>>(
        '${ApiConfig.routeStops}/$routeId/stops',
        fromJsonList: (jsonList) => 
            jsonList.map((json) => app_route.RouteStop.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _routeStops = response.data!;
      }
    } catch (e) {
      debugPrint('Failed to fetch route stops: ${e.toString()}');
    }
  }
  
  // Fetch upcoming trips
  Future<void> fetchUpcomingTrips({int? routeId}) async {
    _upcomingTripsLoading = true;
    _upcomingTripsError = '';
    notifyListeners();
    
    try {
      final queryParams = routeId != null ? {'route_id': routeId.toString()} : null;
      
      final response = await _apiService.get<List<Trip>>(
        ApiConfig.upcomingTrips,
        queryParams: queryParams,
        fromJsonList: (jsonList) => 
            jsonList.map((json) => Trip.fromJson(json)).toList(),
      );
      
      if (response.success && response.data != null) {
        _upcomingTrips = response.data!;
      } else {
        _upcomingTripsError = response.message;
      }
    } catch (e) {
      _upcomingTripsError = 'Failed to fetch upcoming trips: ${e.toString()}';
    } finally {
      _upcomingTripsLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch trip details
  Future<void> fetchTripDetails(int tripId, {bool startTracking = false}) async {
    _currentTripLoading = true;
    _currentTripError = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get<Trip>(
        '${ApiConfig.tripById}/$tripId',
        fromJson: (json) => Trip.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        _currentTrip = response.data;
        
        if (startTracking) {
          _startTripTracking();
        }
      } else {
        _currentTripError = response.message;
      }
    } catch (e) {
      _currentTripError = 'Failed to fetch trip details: ${e.toString()}';
    } finally {
      _currentTripLoading = false;
      notifyListeners();
    }
  }
  
  // Start tracking trip (refresh every 30 seconds)
  void _startTripTracking() {
    // Cancel any existing timer
    _tripRefreshTimer?.cancel();
    
    // Only start tracking for active trips
    if (_currentTrip != null && _currentTrip!.isActive) {
      _tripRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        // Stop tracking if trip is no longer active
        if (_currentTrip == null || !_currentTrip!.isActive) {
          timer.cancel();
          _tripRefreshTimer = null;
          return;
        }
        
        // Refresh trip details
        fetchTripDetails(_currentTrip!.tripId);
      });
    }
  }
  
  // Stop tracking trip
  void stopTripTracking() {
    _tripRefreshTimer?.cancel();
    _tripRefreshTimer = null;
  }
  
  // Calculate fare between stops
  Future<app_route.Fare?> calculateFare(int routeId, int startStopId, int endStopId, {String fareType = 'standard'}) async {
    try {
      final response = await _apiService.get<app_route.Fare>(
        ApiConfig.fareBetweenStops,
        queryParams: {
          'route_id': routeId.toString(),
          'start_stop_id': startStopId.toString(),
          'end_stop_id': endStopId.toString(),
          'fare_type': fareType,
        },
        fromJson: (json) => app_route.Fare.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to calculate fare: ${e.toString()}');
      return null;
    }
  }
  
  @override
  void dispose() {
    stopTripTracking();
    stopLocationUpdates();
    super.dispose();
  }
}