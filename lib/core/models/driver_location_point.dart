class DriverLocationPoint {
  const DriverLocationPoint({
    this.id,
    required this.routeDate,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.metersFromPlannedPath,
  });

  final int? id;
  final String routeDate;
  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? metersFromPlannedPath;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'route_date': routeDate,
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.toIso8601String(),
      'meters_from_planned_path': metersFromPlannedPath,
    };
  }

  factory DriverLocationPoint.fromMap(Map<String, Object?> map) {
    return DriverLocationPoint(
      id: map['id'] as int?,
      routeDate: map['route_date'] as String,
      driverId: map['driver_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      metersFromPlannedPath: (map['meters_from_planned_path'] as num?)?.toDouble(),
    );
  }
}
