import 'package:daladala_smart_app/models/route.dart' as app_route;
import 'package:daladala_smart_app/models/stop.dart' as app_stop;
import 'package:daladala_smart_app/models/user.dart';

class Trip {
  final int tripId;
  final int? scheduleId;
  final int routeId;
  final int vehicleId;
  final int? driverId;
  final String startTime;
  final String? endTime;
  final String status;
  final int? currentStopId;
  final int? nextStopId;
  final app_route.Route? route;
  final Vehicle? vehicle;
  final Driver? driver;
  final app_stop.Stop? currentStop;
  final app_stop.Stop? nextStop;
  final List<RouteTracking>? tracking;
  final VehicleLocation? currentLocation;

  Trip({
    required this.tripId,
    this.scheduleId,
    required this.routeId,
    required this.vehicleId,
    this.driverId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.currentStopId,
    this.nextStopId,
    this.route,
    this.vehicle,
    this.driver,
    this.currentStop,
    this.nextStop,
    this.tracking,
    this.currentLocation,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['trip_id'],
      scheduleId: json['schedule_id'],
      routeId: json['route_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      currentStopId: json['current_stop_id'],
      nextStopId: json['next_stop_id'],
      route: json['Route'] != null ? app_route.Route.fromJson(json['Route']) : null,
      vehicle: json['Vehicle'] != null ? Vehicle.fromJson(json['Vehicle']) : null,
      driver: json['Driver'] != null ? Driver.fromJson(json['Driver']) : null,
      currentStop: json['currentStop'] != null ? app_stop.Stop.fromJson(json['currentStop']) : null,
      nextStop: json['nextStop'] != null ? app_stop.Stop.fromJson(json['nextStop']) : null,
      tracking: json['tracking'] != null
          ? (json['tracking'] as List)
              .map((e) => RouteTracking.fromJson(e))
              .toList()
          : null,
      currentLocation: json['currentLocation'] != null
          ? VehicleLocation.fromJson(json['currentLocation'])
          : null,
    );
  }

  bool get isActive => status == 'scheduled' || status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class RouteTracking {
  final int trackingId;
  final int tripId;
  final int stopId;
  final String? arrivalTime;
  final String? departureTime;
  final String status;
  final app_stop.Stop? stop;

  RouteTracking({
    required this.trackingId,
    required this.tripId,
    required this.stopId,
    this.arrivalTime,
    this.departureTime,
    required this.status,
    this.stop,
  });

  factory RouteTracking.fromJson(Map<String, dynamic> json) {
    return RouteTracking(
      trackingId: json['tracking_id'],
      tripId: json['trip_id'],
      stopId: json['stop_id'],
      arrivalTime: json['arrival_time'],
      departureTime: json['departure_time'],
      status: json['status'],
      stop: json['Stop'] != null ? app_stop.Stop.fromJson(json['Stop']) : null,
    );
  }
}

class Vehicle {
  final int vehicleId;
  final int? driverId;
  final String plateNumber;
  final String vehicleType;
  final String? model;
  final int? year;
  final int capacity;
  final String? color;
  final String? photo;
  final bool isAirConditioned;
  final bool isActive;
  final String status;
  final Driver? driver;

  Vehicle({
    required this.vehicleId,
    this.driverId,
    required this.plateNumber,
    required this.vehicleType,
    this.model,
    this.year,
    required this.capacity,
    this.color,
    this.photo,
    required this.isAirConditioned,
    required this.isActive,
    required this.status,
    this.driver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      plateNumber: json['plate_number'],
      vehicleType: json['vehicle_type'],
      model: json['model'],
      year: json['year'],
      capacity: json['capacity'],
      color: json['color'],
      photo: json['photo'],
      isAirConditioned: json['is_air_conditioned'] == 1,
      isActive: json['is_active'] == 1,
      status: json['status'],
      driver: json['Driver'] != null ? Driver.fromJson(json['Driver']) : null,
    );
  }
}

class VehicleLocation {
  final int locationId;
  final int vehicleId;
  final int? tripId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final String recordedAt;

  VehicleLocation({
    required this.locationId,
    required this.vehicleId,
    this.tripId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.recordedAt,
  });

  factory VehicleLocation.fromJson(Map<String, dynamic> json) {
    return VehicleLocation(
      locationId: json['location_id'],
      vehicleId: json['vehicle_id'],
      tripId: json['trip_id'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      heading: json['heading'] != null ? double.parse(json['heading'].toString()) : null,
      speed: json['speed'] != null ? double.parse(json['speed'].toString()) : null,
      recordedAt: json['recorded_at'],
    );
  }
}