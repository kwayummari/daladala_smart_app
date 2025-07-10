import 'package:daladala_smart_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentLocation;
  bool _isTracking = false;
  bool _isPermissionGranted = false;
  bool _isServiceEnabled = false;
  bool _highAccuracyMode = true;
  bool _isDriver = false;
  bool _isAvailable = false;
  int _updateInterval = 10; // seconds
  String _driverStatus = 'offline';
  DateTime? _lastUpdate;
  List<Map<String, dynamic>> _locationHistory = [];

  Position? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isServiceEnabled => _isServiceEnabled;
  bool get highAccuracyMode => _highAccuracyMode;
  bool get isDriver => _isDriver;
  bool get isAvailable => _isAvailable;
  int get updateInterval => _updateInterval;
  String get driverStatus => _driverStatus;
  DateTime? get lastUpdate => _lastUpdate;
  List<Map<String, dynamic>> get locationHistory => _locationHistory;

  // Check location permissions and service
  Future<void> checkLocationPermissions() async {
    _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    
    LocationPermission permission = await Geolocator.checkPermission();
    _isPermissionGranted = permission == LocationPermission.whileInUse || 
                          permission == LocationPermission.always;
    
    notifyListeners();
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    if (!_isServiceEnabled) {
      _isServiceEnabled = await Geolocator.openLocationSettings();
      if (!_isServiceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    _isPermissionGranted = permission == LocationPermission.whileInUse || 
                          permission == LocationPermission.always;
    
    notifyListeners();
    return _isPermissionGranted;
  }

  // Start location tracking
  Future<void> startTracking() async {
    if (!_isPermissionGranted) {
      final granted = await requestLocationPermission();
      if (!granted) return;
    }

    _isTracking = true;
    _driverStatus = _isDriver ? 'available' : 'tracking';
    notifyListeners();

    // Start location stream
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: _highAccuracyMode ? LocationAccuracy.high : LocationAccuracy.medium,
        distanceFilter: 10,
        timeLimit: Duration(seconds: _updateInterval),
      ),
    ).listen(
      (Position position) {
        _updateLocation(position);
      },
      onError: (error) {
        debugPrint('Location tracking error: $error');
        stopTracking();
      },
    );
  }

  // Stop location tracking
  void stopTracking() {
    _isTracking = false;
    _driverStatus = 'offline';
    notifyListeners();
  }

  // Update current location
  void _updateLocation(Position position) {
    _currentLocation = position;
    _lastUpdate = DateTime.now();
    
    // Add to history
    _locationHistory.insert(0, {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': _lastUpdate!,
      'accuracy': position.accuracy,
      'speed': position.speed,
    });

    // Keep only last 50 updates
    if (_locationHistory.length > 50) {
      _locationHistory = _locationHistory.take(50).toList();
    }

    // Send to server if driver
    if (_isDriver && _isTracking) {
      _sendLocationToServer(position.latitude, position.longitude);
    }

    notifyListeners();
  }

  // Send location to server
  Future<void> _sendLocationToServer(double latitude, double longitude) async {
    try {
      await ApiService.updateDriverLocation(latitude, longitude);
    } catch (e) {
      debugPrint('Failed to send location to server: $e');
    }
  }

  // Set high accuracy mode
  void setHighAccuracyMode(bool enabled) {
    _highAccuracyMode = enabled;
    notifyListeners();
    
    // Restart tracking if currently tracking
    if (_isTracking) {
      stopTracking();
      startTracking();
    }
  }

  // Set update interval
  void setUpdateInterval(int interval) {
    _updateInterval = interval;
    notifyListeners();
    
    // Restart tracking if currently tracking
    if (_isTracking) {
      stopTracking();
      startTracking();
    }
  }

  // Set driver availability
  void setAvailability(bool available) {
    _isAvailable = available;
    _driverStatus = available ? 'available' : 'offline';
    notifyListeners();
  }

  // Set user as driver
  void setIsDriver(bool isDriver) {
    _isDriver = isDriver;
    notifyListeners();
  }
}