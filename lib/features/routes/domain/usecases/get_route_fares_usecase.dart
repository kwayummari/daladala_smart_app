import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fare.dart';
import '../repositories/route_repository.dart';

class GetRouteFaresUseCase {
  final RouteRepository repository;
  
  GetRouteFaresUseCase({required this.repository});
  
  Future<Either<Failure, List<Fare>>> call(GetRouteFaresParams params) async {
    return await repository.getRouteFares(
      routeId: params.routeId,
      fareType: params.fareType,
    );
  }
}

class GetRouteFaresParams {
  final int routeId;
  final String? fareType;
  
  GetRouteFaresParams({required this.routeId, this.fareType});
}