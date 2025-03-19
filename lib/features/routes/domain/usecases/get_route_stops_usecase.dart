import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stop.dart';
import '../repositories/route_repository.dart';

class GetRouteStopsUseCase {
  final RouteRepository repository;
  
  GetRouteStopsUseCase({required this.repository});
  
  Future<Either<Failure, List<Stop>>> call(GetRouteStopsParams params) async {
    return await repository.getRouteStops(params.routeId);
  }
}

class GetRouteStopsParams {
  final int routeId;
  
  GetRouteStopsParams({required this.routeId});
}