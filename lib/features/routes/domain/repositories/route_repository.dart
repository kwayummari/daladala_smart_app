import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/route.dart';
import '../entities/stop.dart';
import '../entities/fare.dart';

abstract class RouteRepository {
  /// Get all active routes
  Future<Either<Failure, List<Route>>> getAllRoutes();
  
  /// Get route by ID
  Future<Either<Failure, Route>> getRouteById(int routeId);
  
  /// Get stops for a route
  Future<Either<Failure, List<Stop>>> getRouteStops(int routeId);
  
  /// Get fares for a route
  Future<Either<Failure, List<Fare>>> getRouteFares({
    required int routeId,
    String? fareType,
  });
  
  /// Search routes by start and end points
  Future<Either<Failure, List<Route>>> searchRoutes({
    String? startPoint,
    String? endPoint,
  });
  
  /// Get fare between stops
  Future<Either<Failure, Fare>> getFareBetweenStops({
    required int routeId,
    required int startStopId,
    required int endStopId,
    String? fareType,
  });
}