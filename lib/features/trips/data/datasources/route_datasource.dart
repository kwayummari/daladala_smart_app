import 'package:daladala_smart_app/features/routes/data/models/fare_model.dart';
import 'package:daladala_smart_app/features/routes/data/models/route_model.dart';
import 'package:daladala_smart_app/features/routes/data/models/stop_model.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';

abstract class RouteDataSource {
  /// Get all active routes
  Future<List<RouteModel>> getAllRoutes();
  
  /// Get route by ID
  Future<RouteModel> getRouteById(int routeId);
  
  /// Get stops for a route
  Future<List<StopModel>> getRouteStops(int routeId);
  
  /// Get fares for a route
  Future<List<FareModel>> getRouteFares({
    required int routeId,
    String? fareType,
  });
  
  /// Search routes by start and end points
  Future<List<RouteModel>> searchRoutes({
    String? startPoint,
    String? endPoint,
  });
  
  /// Get fare between stops
  Future<FareModel> getFareBetweenStops({
    required int routeId,
    required int startStopId,
    required int endStopId,
    String? fareType,
  });
}

class RouteDataSourceImpl implements RouteDataSource {
  final DioClient dioClient;
  
  RouteDataSourceImpl({required this.dioClient});
  
  @override
  Future<List<RouteModel>> getAllRoutes() async {
    try {
      final response = await dioClient.get(AppConstants.routesEndpoint);
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((route) => RouteModel.fromJson(route))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<RouteModel> getRouteById(int routeId) async {
    try {
      final response = await dioClient.get('${AppConstants.routesEndpoint}/$routeId');
      
      if (response['status'] == 'success') {
        return RouteModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<StopModel>> getRouteStops(int routeId) async {
    try {
      final response = await dioClient.get('${AppConstants.routesEndpoint}/$routeId/stops');
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((stop) => StopModel.fromJson(stop['Stop']))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<FareModel>> getRouteFares({
    required int routeId,
    String? fareType,
  }) async {
    try {
      final Map<String, dynamic>? queryParameters = fareType != null ? {'fare_type': fareType} : null;
      
      final response = await dioClient.get(
        '${AppConstants.routesEndpoint}/$routeId/fares',
        queryParameters: queryParameters,
      );
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((fare) => FareModel.fromJson(fare))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<RouteModel>> searchRoutes({
    String? startPoint,
    String? endPoint,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      
      if (startPoint != null) {
        queryParameters['start_point'] = startPoint;
      }
      
      if (endPoint != null) {
        queryParameters['end_point'] = endPoint;
      }
      
      final response = await dioClient.get(
        '${AppConstants.routesEndpoint}/search',
        queryParameters: queryParameters,
      );
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((route) => RouteModel.fromJson(route))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<FareModel> getFareBetweenStops({
    required int routeId,
    required int startStopId,
    required int endStopId,
    String? fareType,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'route_id': routeId,
        'start_stop_id': startStopId,
        'end_stop_id': endStopId,
      };
      
      if (fareType != null) {
        queryParameters['fare_type'] = fareType;
      }
      
      final response = await dioClient.get(
        '${AppConstants.routesEndpoint}/fare',
        queryParameters: queryParameters,
      );
      
      if (response['status'] == 'success') {
        return FareModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}