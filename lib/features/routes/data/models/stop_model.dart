import '../../domain/entities/stop.dart';

class StopModel extends Stop {
  const StopModel({
    required int id,
    required String stopName,
    required double latitude,
    required double longitude,
    String? address,
    required bool isMajor,
    required String status,
  }) : super(
    id: id,
    stopName: stopName,
    latitude: latitude,
    longitude: longitude,
    address: address,
    isMajor: isMajor,
    status: status,
  );
  
  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      id: json['stop_id'],
      stopName: json['stop_name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      isMajor: json['is_major'] == 1,
      status: json['status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'stop_id': id,
      'stop_name': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_major': isMajor ? 1 : 0,
      'status': status,
    };
  }
}