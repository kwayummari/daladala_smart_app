import 'package:daladala_smart_app/models/stop.dart';
import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/models/user.dart';

class Booking {
  final int bookingId;
  final int userId;
  final int tripId;
  final int pickupStopId;
  final int dropoffStopId;
  final String bookingTime;
  final double fareAmount;
  final int passengerCount;
  final String status;
  final String paymentStatus;
  final Trip? trip;
  final Stop? pickupStop;
  final Stop? dropoffStop;
  final User? user;
  final Payment? payment;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.tripId,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.bookingTime,
    required this.fareAmount,
    required this.passengerCount,
    required this.status,
    required this.paymentStatus,
    this.trip,
    this.pickupStop,
    this.dropoffStop,
    this.user,
    this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      pickupStopId: json['pickup_stop_id'],
      dropoffStopId: json['dropoff_stop_id'],
      bookingTime: json['booking_time'],
      fareAmount: double.parse(json['fare_amount'].toString()),
      passengerCount: json['passenger_count'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      trip: json['Trip'] != null ? Trip.fromJson(json['Trip']) : null,
      pickupStop: json['pickupStop'] != null ? Stop.fromJson(json['pickupStop']) : null,
      dropoffStop: json['dropoffStop'] != null ? Stop.fromJson(json['dropoffStop']) : null,
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isPaid => paymentStatus == 'paid';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get isPaymentRefunded => paymentStatus == 'refunded';
}

class Payment {
  final int paymentId;
  final int bookingId;
  final int userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final String paymentTime;
  final String status;
  final Map<String, dynamic>? paymentDetails;
  final Booking? booking;

  Payment({
    required this.paymentId,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentTime,
    required this.status,
    this.paymentDetails,
    this.booking,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      paymentTime: json['payment_time'],
      status: json['status'],
      paymentDetails: json['payment_details'] != null
          ? Map<String, dynamic>.from(json['payment_details'])
          : null,
      booking: json['Booking'] != null ? Booking.fromJson(json['Booking']) : null,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
}