import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  BookingModel({
    required int id,
    required int userId,
    required int tripId,
    required int pickupStopId,
    required int dropoffStopId,
    required DateTime bookingTime,
    required double fareAmount,
    required int passengerCount,
    required String status,
    required String paymentStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? trip,
    Map<String, dynamic>? pickupStop,
    Map<String, dynamic>? dropoffStop,
    Map<String, dynamic>? payment,
    Map<String, dynamic>? user,
  }) : super(
          id: id,
          userId: userId,
          tripId: tripId,
          pickupStopId: pickupStopId,
          dropoffStopId: dropoffStopId,
          bookingTime: bookingTime,
          fareAmount: fareAmount,
          passengerCount: passengerCount,
          status: status,
          paymentStatus: paymentStatus,
          createdAt: createdAt,
          updatedAt: updatedAt,
          trip: trip,
          pickupStop: pickupStop,
          dropoffStop: dropoffStop,
          payment: payment,
          user: user,
        );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['booking_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      pickupStopId: json['pickup_stop_id'],
      dropoffStopId: json['dropoff_stop_id'],
      bookingTime: DateTime.parse(json['booking_time']),
      fareAmount: double.parse(json['fare_amount'].toString()),
      passengerCount: json['passenger_count'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      trip: json['Trip'],
      pickupStop: json['pickupStop'],
      dropoffStop: json['dropoffStop'],
      payment: json['payment'],
      user: json['User'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': id,
      'user_id': userId,
      'trip_id': tripId,
      'pickup_stop_id': pickupStopId,
      'dropoff_stop_id': dropoffStopId,
      'booking_time': bookingTime.toIso8601String(),
      'fare_amount': fareAmount,
      'passenger_count': passengerCount,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}