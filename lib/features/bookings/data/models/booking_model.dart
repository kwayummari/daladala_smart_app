import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.tripId,
    required super.pickupStopId,
    required super.dropoffStopId,
    required super.bookingTime,
    required super.fareAmount,
    required super.passengerCount,
    required super.status,
    required super.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double parseFareAmount(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0; // Default value or throw an exception
    }

    return BookingModel(
      id: json['booking_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      pickupStopId: json['pickup_stop_id'],
      dropoffStopId: json['dropoff_stop_id'],
      bookingTime: DateTime.parse(json['booking_time']),
      fareAmount: parseFareAmount(json['fare_amount']),
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
