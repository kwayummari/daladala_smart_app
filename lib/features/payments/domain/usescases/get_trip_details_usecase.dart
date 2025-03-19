import 'package:daladala_smart_app/features/trips/domains/repositories/trip_repository.dart';
import 'package:daladala_smart_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class GetTripDetailsUseCase {
  final TripRepository repository;
  
  GetTripDetailsUseCase({required this.repository});
  
  Future<Either<Failure, Trip>> call(GetTripDetailsParams params) async {
    return await repository.getTripDetails(params.tripId);
  }
}

class GetTripDetailsParams {
  final int tripId;
  
  GetTripDetailsParams({required this.tripId});
}