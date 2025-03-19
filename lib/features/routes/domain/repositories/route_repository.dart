import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../entities/stop.dart';
import '../entities/fare.dart';

abstract class RouteRepository {
  /// Gets all available routes
  Future<Either<Failure, List<Route>>> getAllRoutes();
  
  /// Gets stops for a specific route
  Future<Either<Failure, List<Stop>>> getRouteStops(int routeId);
  
  /// Gets fares for a specific route
  Future<Either<Failure, List<Fare>>> getRouteFares(int routeId, {String? fareType});
  
  /// Searches for routes based on start and end points
  Future<Either<Failure, List<Route>>> searchRoutes({
    String? startPoint,
    String? endPoint,
  });
}