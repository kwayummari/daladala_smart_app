import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/trip_model.dart';

abstract class TripDataSource {
  /// Get upcoming trips
  Future<List<TripModel>> getUpcomingTrips({int? routeId});
  
  /// Get trip details
  Future<TripModel> getTripDetails(int tripId);
  
  /// Update trip status (for driver)
  Future<void> updateTripStatus({
    required int tripId,
    required String status,
    int? currentStopId,
    int? nextStopId,
  });
  
  /// Update vehicle location (for driver)
  Future<void> updateVehicleLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  });
}

class TripDataSourceImpl implements TripDataSource {
  final DioClient dioClient;
  
  TripDataSourceImpl({required this.dioClient});
  
  @override
  Future<List<TripModel>> getUpcomingTrips({int? routeId}) async {
    try {
      final Map<String, dynamic>? queryParameters = routeId != null ? {'route_id': routeId} : null;
      
      final response = await dioClient.get(
        '${AppConstants.tripsEndpoint}/upcoming',
        queryParameters: queryParameters,
      );
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((trip) => TripModel.fromJson(trip))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<TripModel> getTripDetails(int tripId) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.tripsEndpoint}/$tripId',
      );
      
      if (response['status'] == 'success') {
        return TripModel.fromJson(response['data']['trip']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> updateTripStatus({
    required int tripId,
    required String status,
    int? currentStopId,
    int? nextStopId,
  }) async {
    try {
      final data = {
        'status': status,
      };
      
      if (currentStopId != null) {
        data['current_stop_id'] = currentStopId.toString();
      }
      
      if (nextStopId != null) {
        data['next_stop_id'] = nextStopId.toString();
      }
      
      final response = await dioClient.put(
        '${AppConstants.tripsEndpoint}/driver/$tripId/status',
        data: data,
      );
      
      if (response['status'] != 'success') {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> updateVehicleLocation({
    required int tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    try {
      final data = {
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (heading != null) {
        data['heading'] = heading;
      }
      
      if (speed != null) {
        data['speed'] = speed;
      }
      
      final response = await dioClient.post(
        '${AppConstants.tripsEndpoint}/driver/$tripId/location',
        data: data,
      );
      
      if (response['status'] != 'success') {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}