class Stop {
  final int stopId;
  final String stopName;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isMajor;
  final String? photo;
  final String status;

  Stop({
    required this.stopId,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.isMajor,
    this.photo,
    required this.status,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      stopId: json['stop_id'],
      stopName: json['stop_name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      address: json['address'],
      isMajor: json['is_major'] == 1,
      photo: json['photo'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'stop_name': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_major': isMajor ? 1 : 0,
      'photo': photo,
      'status': status,
    };
  }
}