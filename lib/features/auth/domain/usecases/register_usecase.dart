import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase({required this.repository});
  
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  
  RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });
}