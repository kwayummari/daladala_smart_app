import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
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
  );
  
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['booking_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      pickupStopId: json['pickup_stop_id'],
      dropoffStopId: json['dropoff_stop_id'],
      bookingTime: DateTime.parse(json['booking_time']),
      fareAmount: json['fare_amount'].toDouble(),
      passengerCount: json['passenger_count'],
      status: json['status'],
      paymentStatus: json['payment_status'],
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
    };
  }
}