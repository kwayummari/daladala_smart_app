import 'package:daladala_smart_app/features/trips/domains/entities/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.scheduleId,
    required super.routeId,
    required super.vehicleId,
    super.driverId,
    required super.startTime,
    super.endTime,
    required super.status,
    super.currentStopId,
    super.nextStopId,
    super.currentLocation,
    super.routeName,
    super.vehiclePlate,
    super.driverName,
    super.driverRating,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    LatLng? currentLocation;
    
    if (json['currentLocation'] != null) {
      if (json['currentLocation'] is Map) {
        final lat = json['currentLocation']['latitude'];
        final lng = json['currentLocation']['longitude'];
        if (lat != null && lng != null) {
          currentLocation = LatLng(
            double.parse(lat.toString()),
            double.parse(lng.toString()),
          );
        }
      } else if (json['latitude'] != null && json['longitude'] != null) {
        currentLocation = LatLng(
          double.parse(json['latitude'].toString()),
          double.parse(json['longitude'].toString()),
        );
      }
    }
    
    return TripModel(
      id: json['trip_id'] ?? json['id'],
      scheduleId: json['schedule_id'] ?? 0,
      routeId: json['route_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      startTime: json['start_time'] is String
          ? DateTime.parse(json['start_time'])
          : json['start_time'],
      endTime: json['end_time'] != null
          ? (json['end_time'] is String
              ? DateTime.parse(json['end_time'])
              : json['end_time'])
          : null,
      status: json['status'],
      currentStopId: json['current_stop_id'],
      nextStopId: json['next_stop_id'],
      currentLocation: currentLocation,
      routeName: json['route_name'] ?? 
          (json['route'] != null ? json['route']['route_name'] : null),
      vehiclePlate: json['vehicle_plate'] ?? 
          (json['vehicle'] != null ? json['vehicle']['plate_number'] : null),
      driverName: json['driver_name'] ?? 
          (json['driver'] != null && json['driver']['user'] != null
              ? '${json['driver']['user']['first_name']} ${json['driver']['user']['last_name']}'
              : null),
      driverRating: json['driver_rating'] != null
          ? double.parse(json['driver_rating'].toString())
          : (json['driver'] != null && json['driver']['rating'] != null
              ? double.parse(json['driver']['rating'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': id,
      'schedule_id': scheduleId,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'current_stop_id': currentStopId,
      'next_stop_id': nextStopId,
      'currentLocation': currentLocation != null
          ? {
              'latitude': currentLocation!.latitude,
              'longitude': currentLocation!.longitude,
            }
          : null,
      'route_name': routeName,
      'vehicle_plate': vehiclePlate,
      'driver_name': driverName,
      'driver_rating': driverRating,
    };
  }
}