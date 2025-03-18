import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  factory LocationData.fromPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
    };
  }
}

class LocationService {
  // Stream controller for location updates
  StreamController<LocationData>? _locationController;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Stream getter
  Stream<LocationData>? get locationStream => _locationController?.stream;

  // Initialize the location service
  Future<void> initialize() async {
    await _checkPermission();
  }

  // Check location permission and request if needed
  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }
    
    return true;
  }

  // Get current position
  Future<LocationData?> getCurrentLocation() async {
    try {
      if (!await _checkPermission()) {
        throw Exception('Location permission not granted');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return LocationData.fromPosition(position);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Start streaming location updates
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // in meters
  }) async {
    if (!await _checkPermission()) {
      throw Exception('Location permission not granted');
    }
    
    // Create a new controller if it doesn't exist or is closed
    _locationController ??= StreamController<LocationData>.broadcast();
    
    // Cancel any existing subscription
    await _positionStreamSubscription?.cancel();
    
    // Start the new subscription
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).listen(
      (Position position) {
        if (_locationController != null && !_locationController!.isClosed) {
          _locationController!.add(LocationData.fromPosition(position));
        }
      },
    );
  }

  // Stop streaming location updates
  Future<void> stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    await _locationController?.close();
    _locationController = null;
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  // Dispose the location service
  void dispose() {
    stopLocationUpdates();
  }
}