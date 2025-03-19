import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip extends Equatable {
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
  
  const Trip({
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
  
  @override
  List<Object?> get props => [
    id,
    scheduleId,
    routeId,
    vehicleId,
    driverId,
    startTime,
    endTime,
    status,
    currentStopId,
    nextStopId,
    currentLocation,
    routeName,
    vehiclePlate,
    driverName,
    driverRating,
  ];
}