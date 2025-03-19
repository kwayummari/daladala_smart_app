import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final int id;
  final int userId;
  final int tripId;
  final int pickupStopId;
  final int dropoffStopId;
  final DateTime bookingTime;
  final double fareAmount;
  final int passengerCount;
  final String status;
  final String paymentStatus;
  
  const Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.bookingTime,
    required this.fareAmount,
    required this.passengerCount,
    required this.status,
    required this.paymentStatus,
  });
  
  Booking copyWith({
    int? id,
    int? userId,
    int? tripId,
    int? pickupStopId,
    int? dropoffStopId,
    DateTime? bookingTime,
    double? fareAmount,
    int? passengerCount,
    String? status,
    String? paymentStatus,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      bookingTime: bookingTime ?? this.bookingTime,
      fareAmount: fareAmount ?? this.fareAmount,
      passengerCount: passengerCount ?? this.passengerCount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
  
  @override
  List<Object> get props => [
    id,
    userId,
    tripId,
    pickupStopId,
    dropoffStopId,
    bookingTime,
    fareAmount,
    passengerCount,
    status,
    paymentStatus,
  ];
}