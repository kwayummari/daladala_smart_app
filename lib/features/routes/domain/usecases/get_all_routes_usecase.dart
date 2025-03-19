import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/route.dart';
import '../repositories/route_repository.dart';

class GetAllRoutesUseCase {
  final RouteRepository repository;
  
  GetAllRoutesUseCase({required this.repository});
  
  Future<Either<Failure, List<Route>>> call(NoParams params) async {
    return await repository.getAllRoutes();
  }
}

class NoParams {}