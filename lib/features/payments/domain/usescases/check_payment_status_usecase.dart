// lib/features/payments/domain/usecases/check_payment_status_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class CheckPaymentStatusUseCase implements UseCase<Payment, CheckPaymentStatusParams> {
  final PaymentRepository repository;

  CheckPaymentStatusUseCase({required this.repository});

  @override
  Future<Either<Failure, Payment>> call(CheckPaymentStatusParams params) async {
    return await repository.checkPaymentStatus(params.paymentId);
  }
}

class CheckPaymentStatusParams {
  final int paymentId;

  CheckPaymentStatusParams({required this.paymentId});
}