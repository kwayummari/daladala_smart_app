import 'package:daladala_smart_app/models/trip.dart';
import 'package:daladala_smart_app/models/user.dart';

class Review {
  final int reviewId;
  final int userId;
  final int tripId;
  final int? driverId;
  final int? vehicleId;
  final double rating;
  final String? comment;
  final String reviewTime;
  final bool isAnonymous;
  final String status;
  final User? user;
  final Trip? trip;
  final Driver? driver;
  final Vehicle? vehicle;

  Review({
    required this.reviewId,
    required this.userId,
    required this.tripId,
    this.driverId,
    this.vehicleId,
    required this.rating,
    this.comment,
    required this.reviewTime,
    required this.isAnonymous,
    required this.status,
    this.user,
    this.trip,
    this.driver,
    this.vehicle,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      driverId: json['driver_id'],
      vehicleId: json['vehicle_id'],
      rating: double.parse(json['rating'].toString()),
      comment: json['comment'],
      reviewTime: json['review_time'],
      isAnonymous: json['is_anonymous'] == 1,
      status: json['status'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      trip: json['Trip'] != null ? Trip.fromJson(json['Trip']) : null,
      driver: json['Driver'] != null ? Driver.fromJson(json['Driver']) : null,
      vehicle: json['Vehicle'] != null ? Vehicle.fromJson(json['Vehicle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'rating': rating,
      'comment': comment,
      'is_anonymous': isAnonymous ? 1 : 0,
    };
  }
}