import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/route_repository.dart';

class GetAllRoutesUseCase implements UseCase<List<Route>, NoParams> {
  final RouteRepository repository;

  GetAllRoutesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Route>>> call(NoParams params) async {
    return await repository.getAllRoutes();
  }
}