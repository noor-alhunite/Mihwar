import 'operations_enums.dart';

class BinVisitRecord {
  const BinVisitRecord({
    this.id,
    required this.binId,
    required this.status,
    required this.visitedAt,
    required this.driverId,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final int binId;
  final BinStatus status;
  final DateTime visitedAt;
  final String driverId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'bin_id': binId,
      'status': status.value,
      'visited_at': visitedAt.toIso8601String(),
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BinVisitRecord.fromMap(Map<String, Object?> map) {
    return BinVisitRecord(
      id: map['id'] as int?,
      binId: map['bin_id'] as int,
      status: BinStatusX.fromValue(map['status'] as String),
      visitedAt: DateTime.parse(map['visited_at'] as String),
      driverId: map['driver_id'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
