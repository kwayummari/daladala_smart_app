import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/route.dart';
import '../repositories/route_repository.dart';

class SearchRoutesUseCase implements UseCase<List<Route>, SearchRoutesParams> {
  final RouteRepository repository;

  SearchRoutesUseCase({required this.repository});

  @override
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
  
  const SearchRoutesParams({this.startPoint, this.endPoint});
}