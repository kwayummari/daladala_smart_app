import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Process a payment for a booking
  Future<Either<Failure, Payment>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
  
  /// Get payment history for the current user
  Future<Either<Failure, List<Payment>>> getPaymentHistory();
  
  /// Get payment details by ID
  Future<Either<Failure, Payment>> getPaymentDetails(int paymentId);
  
  /// Get wallet balance for the current user
  Future<Either<Failure, double>> getWalletBalance();
  
  /// Top up wallet
  Future<Either<Failure, double>> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
}