import 'dart:convert';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    super.transactionId,
    required super.paymentTime,
    required super.status,
    super.paymentDetails,
  });
  
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

    double amount;
  var rawAmount = json['amount'];
  if (rawAmount is int) {
    amount = rawAmount.toDouble();
  } else if (rawAmount is double) {
    amount = rawAmount;
  } else if (rawAmount is String) {
    amount = double.tryParse(rawAmount) ?? 0.0;
  } else {
    amount = 0.0; // Default value if amount is null or another type
  }
    
    return PaymentModel(
      id: json['payment_id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: amount,
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