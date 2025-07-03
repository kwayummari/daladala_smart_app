// lib/features/payments/data/models/payment_model.dart
import '../../domain/entities/payment.dart';
import '../../../bookings/data/models/booking_model.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    super.paymentProvider,
    super.transactionId,
    super.internalReference,
    super.paymentTime,
    super.initiatedTime,
    required super.status,
    super.failureReason,
    super.paymentDetails,
    super.webhookData,
    super.zenoPayData,
    super.refundAmount,
    super.refundTime,
    super.commissionAmount,
    super.booking,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['payment_id'] ?? json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'TZS',
      paymentMethod: json['payment_method'],
      paymentProvider: json['payment_provider'],
      transactionId: json['transaction_id'],
      internalReference: json['internal_reference'],
      paymentTime:
          json['payment_time'] != null
              ? DateTime.parse(json['payment_time'])
              : null,
      initiatedTime:
          json['initiated_time'] != null
              ? DateTime.parse(json['initiated_time'])
              : DateTime.now(),
      status: json['status'],
      failureReason: json['failure_reason'],
      paymentDetails:
          json['payment_details'] != null
              ? Map<String, dynamic>.from(json['payment_details'])
              : null,
      webhookData:
          json['webhook_data'] != null
              ? Map<String, dynamic>.from(json['webhook_data'])
              : null,
      zenoPayData:
          json['zenopay'] != null
              ? ZenoPayDataModel.fromJson(json['zenopay']).toEntity()
              : null,
      refundAmount: json['refund_amount']?.toDouble(),
      refundTime:
          json['refund_time'] != null
              ? DateTime.parse(json['refund_time'])
              : null,
      commissionAmount: json['commission_amount']?.toDouble(),
      booking:
          json['Booking'] != null || json['booking'] != null
              ? BookingModel.fromJson(
                  json['Booking'] ?? json['booking'],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_provider': paymentProvider,
      'transaction_id': transactionId,
      'internal_reference': internalReference,
      'payment_time': paymentTime?.toIso8601String(),
      'initiated_time': initiatedTime?.toIso8601String(),
      'status': status,
      'failure_reason': failureReason,
      'payment_details': paymentDetails,
      'webhook_data': webhookData,
      'zenopay':
          zenoPayData != null
              ? ZenoPayDataModel.fromEntity(zenoPayData!).toJson()
              : null,
      'refund_amount': refundAmount,
      'refund_time': refundTime?.toIso8601String(),
      'commission_amount': commissionAmount,
      'booking': booking != null ? (booking as BookingModel).toJson() : null,
    };
  }
}

class ZenoPayDataModel {
  final String? orderId;
  final String? reference;
  final String? message;
  final String? instructions;
  final String? channel;
  final String? msisdn;

  const ZenoPayDataModel({
    this.orderId,
    this.reference,
    this.message,
    this.instructions,
    this.channel,
    this.msisdn,
  });

  factory ZenoPayDataModel.fromJson(Map<String, dynamic> json) {
    return ZenoPayDataModel(
      orderId: json['order_id'],
      reference: json['reference'],
      message: json['message'],
      instructions: json['instructions'],
      channel: json['channel'],
      msisdn: json['msisdn'],
    );
  }

  factory ZenoPayDataModel.fromEntity(ZenoPayData entity) {
    return ZenoPayDataModel(
      orderId: entity.orderId,
      reference: entity.reference,
      message: entity.message,
      instructions: entity.instructions,
      channel: entity.channel,
      msisdn: entity.msisdn,
    );
  }

  ZenoPayData toEntity() {
    return ZenoPayData(
      orderId: orderId,
      reference: reference,
      message: message,
      instructions: instructions,
      channel: channel,
      msisdn: msisdn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'reference': reference,
      'message': message,
      'instructions': instructions,
      'channel': channel,
      'msisdn': msisdn,
    };
  }
}
