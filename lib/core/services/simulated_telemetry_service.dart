import 'package:latlong2/latlong.dart';

import '../models/driver_location_point.dart';
import '../repositories/demo_repositories.dart';

class SimulatedTelemetryService {
  SimulatedTelemetryService({
    required DriverLocationRepository locationRepository,
    this.thresholdMeters = 50,
  }) : _locationRepository = locationRepository;

  final DriverLocationRepository _locationRepository;
  final double thresholdMeters;
  final Distance _distance = const Distance();

  bool _simulateDeviation = false;
  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);
  double _totalDeviation = 0;
  int _sampleCount = 0;

  void setSimulateDeviation(bool value) {
    _simulateDeviation = value;
  }

  double get compliancePercent {
    if (_sampleCount == 0) {
      return 100;
    }
    final double avgDeviation = _totalDeviation / _sampleCount;
    final double score = 100 - ((avgDeviation / thresholdMeters) * 100);
    return score.clamp(0, 100);
  }

  void reset() {
    _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);
    _totalDeviation = 0;
    _sampleCount = 0;
  }

  Future<void> capturePoint({
    required String routeDate,
    required String driverId,
    required LatLng truckPosition,
    required List<LatLng> plannedPathPoints,
    required DateTime now,
  }) async {
    final int elapsedMs = now.difference(_lastSavedAt).inMilliseconds;
    if (elapsedMs < 6000) {
      return;
    }
    _lastSavedAt = now;

    final LatLng point = _simulateDeviation
        ? LatLng(
            truckPosition.latitude + 0.00045,
            truckPosition.longitude - 0.00035,
          )
        : truckPosition;

    final double metersFromPath = _distanceFromPathMeters(
      point: point,
      path: plannedPathPoints,
    );

    _totalDeviation += metersFromPath;
    _sampleCount += 1;

    await _locationRepository.addLocationPoint(
      DriverLocationPoint(
        routeDate: routeDate,
        driverId: driverId,
        latitude: point.latitude,
        longitude: point.longitude,
        recordedAt: now,
        metersFromPlannedPath: metersFromPath,
      ),
    );
  }

  double _distanceFromPathMeters({
    required LatLng point,
    required List<LatLng> path,
  }) {
    if (path.isEmpty) {
      return 0;
    }
    double minMeters = double.infinity;
    for (final LatLng routePoint in path) {
      final double d = _distance(point, routePoint);
      if (d < minMeters) {
        minMeters = d;
      }
    }
    return minMeters.isFinite ? minMeters : 0;
  }
}
