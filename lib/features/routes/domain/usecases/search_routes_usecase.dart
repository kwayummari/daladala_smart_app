import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/route.dart';
import '../repositories/route_repository.dart';

class SearchRoutesUseCase {
  final RouteRepository repository;
  
  SearchRoutesUseCase({required this.repository});
  
  Future<Either<Failure, List<Route>>> call(SearchRoutesParams params) async {
    return await repository.searchRoutes(
      startPoint: params.startPoint,
      endPoint: params.endPoint,
    );
  }
}

class SearchRoutesParams {
  final String? startPoint;
  final String? endPoint;
  
  SearchRoutesParams({this.startPoint, this.endPoint});
}