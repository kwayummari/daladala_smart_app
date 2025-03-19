import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Processes a payment for a booking
  Future<Either<Failure, Payment>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
  
  /// Gets the payment history for the current user
  Future<Either<Failure, List<Payment>>> getPaymentHistory();
  
  /// Gets the wallet balance for the current user
  Future<Either<Failure, double>> getWalletBalance();
  
  /// Tops up the wallet with a specified amount
  Future<Either<Failure, double>> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  });
}