import 'dart:convert';

import 'package:latlong2/latlong.dart';

import 'operations_enums.dart';

class PlannedStopRecord {
  const PlannedStopRecord({
    this.id,
    required this.routeDate,
    required this.driverId,
    required this.binId,
    required this.stopOrder,
    required this.isPriority,
  });

  final int? id;
  final String routeDate;
  final String driverId;
  final int binId;
  final int stopOrder;
  final bool isPriority;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'route_date': routeDate,
      'driver_id': driverId,
      'bin_id': binId,
      'stop_order': stopOrder,
      'is_priority': isPriority ? 1 : 0,
    };
  }

  factory PlannedStopRecord.fromMap(Map<String, Object?> map) {
    return PlannedStopRecord(
      id: map['id'] as int?,
      routeDate: map['route_date'] as String,
      driverId: map['driver_id'] as String,
      binId: map['bin_id'] as int,
      stopOrder: map['stop_order'] as int,
      isPriority: (map['is_priority'] as int) == 1,
    );
  }
}

class RoadSegmentRecord {
  const RoadSegmentRecord({
    this.id,
    required this.name,
    required this.fromBinId,
    required this.toBinId,
    required this.distanceKm,
    required this.roadType,
    this.polylinePoints,
  });

  final int? id;
  final String name;
  final int fromBinId;
  final int toBinId;
  final double distanceKm;
  final RoadType roadType;
  final List<LatLng>? polylinePoints;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'from_bin_id': fromBinId,
      'to_bin_id': toBinId,
      'distance_km': distanceKm,
      'road_type': roadType.value,
      'polyline_points_json': polylinePoints == null
          ? null
          : jsonEncode(
              polylinePoints!
                  .map((LatLng p) => <String, double>{
                        'lat': p.latitude,
                        'lng': p.longitude,
                      })
                  .toList(growable: false),
            ),
    };
  }

  factory RoadSegmentRecord.fromMap(Map<String, Object?> map) {
    final String? pointsJson = map['polyline_points_json'] as String?;
    List<LatLng>? points;
    if (pointsJson != null && pointsJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(pointsJson) as List<dynamic>;
      points = decoded
          .map(
            (dynamic row) => LatLng(
              ((row as Map<String, dynamic>)['lat'] as num).toDouble(),
              (row['lng'] as num).toDouble(),
            ),
          )
          .toList(growable: false);
    }
    return RoadSegmentRecord(
      id: map['id'] as int?,
      name: map['name'] as String,
      fromBinId: map['from_bin_id'] as int,
      toBinId: map['to_bin_id'] as int,
      distanceKm: (map['distance_km'] as num).toDouble(),
      roadType: RoadTypeX.fromValue(map['road_type'] as String),
      polylinePoints: points,
    );
  }
}

class DriverEventRecord {
  const DriverEventRecord({
    this.id,
    required this.routeDate,
    required this.driverId,
    this.binId,
    required this.eventType,
    required this.createdAt,
  });

  final int? id;
  final String routeDate;
  final String driverId;
  final int? binId;
  final DriverEventType eventType;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'route_date': routeDate,
      'driver_id': driverId,
      'bin_id': binId,
      'event_type': eventType.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DriverEventRecord.fromMap(Map<String, Object?> map) {
    return DriverEventRecord(
      id: map['id'] as int?,
      routeDate: map['route_date'] as String,
      driverId: map['driver_id'] as String,
      binId: map['bin_id'] as int?,
      eventType: DriverEventTypeX.fromValue(map['event_type'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
