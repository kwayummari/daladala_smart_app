import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingDetailsUseCase implements UseCase<Booking, GetBookingDetailsParams> {
  final BookingRepository repository;

  GetBookingDetailsUseCase({required this.repository});

  @override
  Future<Either<Failure, Booking>> call(GetBookingDetailsParams params) async {
    return await repository.getBookingDetails(params.bookingId);
  }
}

class GetBookingDetailsParams {
  final int bookingId;
  
  GetBookingDetailsParams({required this.bookingId});
}