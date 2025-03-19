import 'dart:convert';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required int id,
    required int bookingId,
    required int userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? transactionId,
    required DateTime paymentTime,
    required String status,
    Map<String, dynamic>? paymentDetails,
  }) : super(
    id: id,
    bookingId: bookingId,
    userId: userId,
    amount: amount,
    currency: currency,
    paymentMethod: paymentMethod,
    transactionId: transactionId,
    paymentTime: paymentTime,
    status: status,
    paymentDetails: paymentDetails,
  );
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? paymentDetails;
    
    if (json['payment_details'] != null) {
      if (json['payment_details'] is String) {
        try {
          paymentDetails = jsonDecode(json['payment_details']);
        } catch (e) {
          paymentDetails = null;
        }
      } else if (json['payment_details'] is Map) {
        paymentDetails = Map<String, dynamic>.from(json['payment_details']);
      }
    }
    
    return PaymentModel(
      id: json['payment_id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      paymentTime: DateTime.parse(json['payment_time']),
      status: json['status'],
      paymentDetails: paymentDetails,
    );
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'payment_id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_time': paymentTime.toIso8601String(),
      'status': status,
    };
    
    if (transactionId != null) {
      data['transaction_id'] = transactionId;
    }
    
    if (paymentDetails != null) {
      data['payment_details'] = jsonEncode(paymentDetails);
    }
    
    return data;
  }
}