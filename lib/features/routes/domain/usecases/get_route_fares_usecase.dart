import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fare.dart';
import '../repositories/route_repository.dart';

class GetRouteFaresUseCase implements UseCase<List<Fare>, GetRouteFaresParams> {
  final RouteRepository repository;

  GetRouteFaresUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Fare>>> call(GetRouteFaresParams params) async {
    return await repository.getRouteFares(
      params.routeId,
      fareType: params.fareType,
    );
  }
}

class GetRouteFaresParams {
  final int routeId;
  final String? fareType;
  
  const GetRouteFaresParams({required this.routeId, this.fareType});
}