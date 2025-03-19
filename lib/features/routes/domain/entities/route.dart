import 'package:equatable/equatable.dart';

class Route extends Equatable {
  final int id;
  final String routeNumber;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final String? description;
  final double? distanceKm;
  final int? estimatedTimeMinutes;
  final String status;
  
  const Route({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.description,
    this.distanceKm,
    this.estimatedTimeMinutes,
    required this.status,
  });
  
  @override
  List<Object?> get props => [
    id,
    routeNumber,
    routeName,
    startPoint,
    endPoint,
    description,
    distanceKm,
    estimatedTimeMinutes,
    status,
  ];
}