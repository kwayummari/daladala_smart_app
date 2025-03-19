import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase({required this.repository});

  Future<Either<Failure, Payment>> call(ProcessPaymentParams params) async {
    return await repository.processPayment(
      bookingId: params.bookingId,
      paymentMethod: params.paymentMethod,
      transactionId: params.transactionId,
      paymentDetails: params.paymentDetails,
    );
  }
}

class ProcessPaymentParams {
  final int bookingId;
  final String paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  
  ProcessPaymentParams({
    required this.bookingId,
    required this.paymentMethod,
    this.transactionId,
    this.paymentDetails,
  });
}