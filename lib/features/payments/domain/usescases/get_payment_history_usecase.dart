import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase({required this.repository});

  Future<Either<Failure, List<Payment>>> call(NoParams params) async {
    return await repository.getPaymentHistory();
  }
}

class NoParams {}