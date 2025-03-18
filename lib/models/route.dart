import 'package:daladala_smart_app/models/stop.dart';

class Route {
  final int routeId;
  final String routeNumber;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final String? description;
  final double? distanceKm;
  final int? estimatedTimeMinutes;
  final String status;
  final String? polyline;
  final List<Stop>? stops;
  final List<RouteStop>? routeStops;

  Route({
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    this.description,
    this.distanceKm,
    this.estimatedTimeMinutes,
    required this.status,
    this.polyline,
    this.stops,
    this.routeStops,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    List<Stop>? stopsList;
    List<RouteStop>? routeStopsList;

    if (json['Stops'] != null) {
      stopsList = (json['Stops'] as List)
          .map((stopJson) => Stop.fromJson(stopJson))
          .toList();
    }

    if (json['RouteStops'] != null) {
      routeStopsList = (json['RouteStops'] as List)
          .map((stopJson) => RouteStop.fromJson(stopJson))
          .toList();
    }

    return Route(
      routeId: json['route_id'],
      routeNumber: json['route_number'],
      routeName: json['route_name'],
      startPoint: json['start_point'],
      endPoint: json['end_point'],
      description: json['description'],
      distanceKm: json['distance_km'] != null
          ? double.parse(json['distance_km'].toString())
          : null,
      estimatedTimeMinutes: json['estimated_time_minutes'],
      status: json['status'],
      polyline: json['polyline'],
      stops: stopsList,
      routeStops: routeStopsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_number': routeNumber,
      'route_name': routeName,
      'start_point': startPoint,
      'end_point': endPoint,
      'description': description,
      'distance_km': distanceKm,
      'estimated_time_minutes': estimatedTimeMinutes,
      'status': status,
      'polyline': polyline,
    };
  }
}

class RouteStop {
  final int routeStopId;
  final int routeId;
  final int stopId;
  final int stopOrder;
  final double? distanceFromStart;
  final int? estimatedTimeFromStart;
  final Stop? stop;

  RouteStop({
    required this.routeStopId,
    required this.routeId,
    required this.stopId,
    required this.stopOrder,
    this.distanceFromStart,
    this.estimatedTimeFromStart,
    this.stop,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      routeStopId: json['route_stop_id'],
      routeId: json['route_id'],
      stopId: json['stop_id'],
      stopOrder: json['stop_order'],
      distanceFromStart: json['distance_from_start'] != null
          ? double.parse(json['distance_from_start'].toString())
          : null,
      estimatedTimeFromStart: json['estimated_time_from_start'],
      stop: json['Stop'] != null ? Stop.fromJson(json['Stop']) : null,
    );
  }
}

class Fare {
  final int fareId;
  final int routeId;
  final int startStopId;
  final int endStopId;
  final double amount;
  final String currency;
  final String fareType;
  final bool isActive;
  final Stop? startStop;
  final Stop? endStop;

  Fare({
    required this.fareId,
    required this.routeId,
    required this.startStopId,
    required this.endStopId,
    required this.amount,
    required this.currency,
    required this.fareType,
    required this.isActive,
    this.startStop,
    this.endStop,
  });

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      fareId: json['fare_id'],
      routeId: json['route_id'],
      startStopId: json['start_stop_id'],
      endStopId: json['end_stop_id'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      fareType: json['fare_type'],
      isActive: json['is_active'] == 1,
      startStop: json['startStop'] != null ? Stop.fromJson(json['startStop']) : null,
      endStop: json['endStop'] != null ? Stop.fromJson(json['endStop']) : null,
    );
  }
}

class Schedule {
  final int scheduleId;
  final int routeId;
  final int vehicleId;
  final int? driverId;
  final String departureTime;
  final String? arrivalTime;
  final String dayOfWeek;
  final bool isActive;
  final Route? route;

  Schedule({
    required this.scheduleId,
    required this.routeId,
    required this.vehicleId,
    this.driverId,
    required this.departureTime,
    this.arrivalTime,
    required this.dayOfWeek,
    required this.isActive,
    this.route,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['schedule_id'],
      routeId: json['route_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      dayOfWeek: json['day_of_week'],
      isActive: json['is_active'] == 1,
      route: json['Route'] != null ? Route.fromJson(json['Route']) : null,
    );
  }
}