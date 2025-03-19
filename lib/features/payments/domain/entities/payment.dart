import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final DateTime paymentTime;
  final String status;
  final Map<String, dynamic>? paymentDetails;
  
  const Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentTime,
    required this.status,
    this.paymentDetails,
  });
  
  @override
  List<Object?> get props => [
    id,
    bookingId,
    userId,
    amount,
    currency,
    paymentMethod,
    transactionId,
    paymentTime,
    status,
    paymentDetails,
  ];
}