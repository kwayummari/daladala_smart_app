import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required int id,
    required int scheduleId,
    required int routeId,
    required int vehicleId,
    int? driverId,
    required DateTime startTime,
    DateTime? endTime,
    required String status,
    int? currentStopId,
    int? nextStopId,
    LatLng? currentLocation,
    String? routeName,
    String? vehiclePlate,
    String? driverName,
    double? driverRating,
  }) : super(
    id: id,
    scheduleId: scheduleId,
    routeId: routeId,
    vehicleId: vehicleId,
    driverId: driverId,
    startTime: startTime,
    endTime: endTime,
    status: status,
    currentStopId: currentStopId,
    nextStopId: nextStopId,
    currentLocation: currentLocation,
    routeName: routeName,
    vehiclePlate: vehiclePlate,
    driverName: driverName,
    driverRating: driverRating,
  );
  
  factory TripModel.fromJson(Map<String, dynamic> json) {
    LatLng? currentLocation;
    if (json['currentLocation'] != null) {
      currentLocation = LatLng(
        json['currentLocation']['latitude'],
        json['currentLocation']['longitude'],
      );
    }
    
    return TripModel(
      id: json['trip_id'],
      scheduleId: json['schedule_id'] ?? 0,
      routeId: json['route_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: json['status'],
      currentStopId: json['current_stop_id'],
      nextStopId: json['next_stop_id'],
      currentLocation: currentLocation,
      routeName: json['Route']?['route_name'],
      vehiclePlate: json['Vehicle']?['plate_number'],
      driverName: json['Driver']?['User']?['first_name'] != null && json['Driver']?['User']?['last_name'] != null
          ? '${json['Driver']['User']['first_name']} ${json['Driver']['User']['last_name']}'
          : null,
      driverRating: json['Driver']?['rating']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'trip_id': id,
      'schedule_id': scheduleId,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'status': status,
      'start_time': startTime.toIso8601String(),
    };
    
    if (driverId != null) data['driver_id'] = driverId;
    if (endTime != null) data['end_time'] = endTime!.toIso8601String();
    if (currentStopId != null) data['current_stop_id'] = currentStopId;
    if (nextStopId != null) data['next_stop_id'] = nextStopId;
    
    return data;
  }
}