import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase({required this.repository});

  Future<Either<Failure, List<Payment>>> call(NoParams params) async {
    return await repository.getPaymentHistory();
  }
}

class NoParams {}

// Below are stubs for the required interfaces if they don't exist yet

// This would be defined in ../repositories/payment_repository.dart
class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPaymentHistory() async {
    // This would be implemented in the actual repository
    return Right([]);
  }
}

// This would be defined in ../entities/payment.dart
class Payment {
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
  
  Payment({
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
}