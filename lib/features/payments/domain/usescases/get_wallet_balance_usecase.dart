import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

class GetWalletBalanceUseCase {
  final PaymentRepository repository;

  GetWalletBalanceUseCase({required this.repository});

  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.getWalletBalance();
  }
}

class NoParams {}