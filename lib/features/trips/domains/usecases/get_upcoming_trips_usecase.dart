import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetUpcomingTripsUseCase {
  final TripRepository repository;
  
  GetUpcomingTripsUseCase({required this.repository});
  
  Future<Either<Failure, List<Trip>>> call(GetUpcomingTripsParams params) async {
    return await repository.getUpcomingTrips(routeId: params.routeId);
  }
}

class GetUpcomingTripsParams {
  final int? routeId;
  
  GetUpcomingTripsParams({this.routeId});
}