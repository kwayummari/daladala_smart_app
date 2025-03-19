import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/booking_model.dart';

abstract class BookingDataSource {
  /// Create a new booking
  Future<BookingModel> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
  });
  
  /// Get bookings for the current user
  Future<List<BookingModel>> getUserBookings({String? status});
  
  /// Get booking details
  Future<BookingModel> getBookingDetails(int bookingId);
  
  /// Cancel a booking
  Future<void> cancelBooking(int bookingId);
}

class BookingDataSourceImpl implements BookingDataSource {
  final DioClient dioClient;
  
  BookingDataSourceImpl({required this.dioClient});
  
  @override
  Future<BookingModel> createBooking({
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required int passengerCount,
  }) async {
    try {
      final response = await dioClient.post(
        AppConstants.bookingsEndpoint,
        data: {
          'trip_id': tripId,
          'pickup_stop_id': pickupStopId,
          'dropoff_stop_id': dropoffStopId,
          'passenger_count': passengerCount,
        },
      );
      
      if (response['status'] == 'success') {
        return BookingModel.fromJson(response['data']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<BookingModel>> getUserBookings({String? status}) async {
    try {
      final Map<String, dynamic>? queryParameters = status != null ? {'status': status} : null;
      
      final response = await dioClient.get(
        AppConstants.bookingsEndpoint,
        queryParameters: queryParameters,
      );
      
      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<BookingModel> getBookingDetails(int bookingId) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.bookingsEndpoint}/$bookingId',
      );
      
      if (response['status'] == 'success') {
        return BookingModel.fromJson(response['data']['booking']);
      } else {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> cancelBooking(int bookingId) async {
    try {
      final response = await dioClient.put(
        '${AppConstants.bookingsEndpoint}/$bookingId/cancel',
      );
      
      if (response['status'] != 'success') {
        throw ServerException(message: response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}