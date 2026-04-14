import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/bootstrap/demo_bootstrap.dart';
import '../../../core/models/bin.dart';
import '../../../core/models/operations_enums.dart';
import '../../../core/models/route_planning_models.dart';
import '../../../core/repositories/demo_seed_spec.dart';
import '../../../core/repositories/repositories_provider.dart';

const double _dieselPriceJodPerLiter = 0.645;

class RouteComparisonSummary {
  const RouteComparisonSummary({
    required this.name,
    required this.points,
    required this.distanceKm,
    required this.dieselLiters,
  });

  final String name;
  final List<LatLng> points;
  final double distanceKm;
  final double dieselLiters;

  double get costJod => dieselLiters * _dieselPriceJodPerLiter;
}

class RouteDemoData {
  const RouteDemoData({
    required this.beforeRoute,
    required this.afterRoute,
    required this.shortUphillLiters,
    required this.longFlatLiters,
  });

  final RouteComparisonSummary beforeRoute;
  final RouteComparisonSummary afterRoute;
  final double shortUphillLiters;
  final double longFlatLiters;
}

final FutureProvider<RouteDemoData> routeDemoProvider =
    FutureProvider<RouteDemoData>((ref) async {
      await DemoBootstrap.ensureInitialized();
      final String driverId = DemoSeedSpec.defaultDriverId;
      final String routeDate = DemoSeedSpec.demoDate;

      final List<PlannedStopRecord> plannedStops = await ref
          .read(routePlanningRepositoryProvider)
          .getPlannedStops(driverId: driverId, routeDate: routeDate);
      final List<BinModel> bins = await ref.read(binsRepositoryProvider).getAllBins();
      final List<RoadSegmentRecord> segments = await ref
          .read(routePlanningRepositoryProvider)
          .getRoadSegments();

      final Map<int, BinModel> binsById = {
        for (final BinModel bin in bins) bin.id: bin,
      };

      final List<PlannedStopRecord> beforeStops = plannedStops;
      final List<PlannedStopRecord> afterStops = plannedStops
          .where((stop) => stop.isPriority)
          .toList(growable: false);

      final RouteComparisonSummary before = _buildRouteSummary(
        name: 'governorate_route_before_label',
        stops: beforeStops,
        binsById: binsById,
        segments: segments,
      );
      final RouteComparisonSummary after = _buildRouteSummary(
        name: 'governorate_route_after_label',
        stops: afterStops,
        binsById: binsById,
        segments: segments,
      );

      final double shortUphillLiters = _segmentDieselLiters(
        distanceKm: 2.1,
        roadType: RoadType.uphill,
      );
      final double longFlatLiters = _segmentDieselLiters(
        distanceKm: 2.8,
        roadType: RoadType.flat,
      );

      return RouteDemoData(
        beforeRoute: before,
        afterRoute: after,
        shortUphillLiters: shortUphillLiters,
        longFlatLiters: longFlatLiters,
      );
    });

RouteComparisonSummary _buildRouteSummary({
  required String name,
  required List<PlannedStopRecord> stops,
  required Map<int, BinModel> binsById,
  required List<RoadSegmentRecord> segments,
}) {
  final List<int> stopBinIds = stops.map((s) => s.binId).toList(growable: false);
  final List<LatLng> points = stopBinIds
      .map((id) => binsById[id])
      .whereType<BinModel>()
      .map((b) => LatLng(b.lat, b.lng))
      .toList(growable: false);

  final Map<String, RoadSegmentRecord> segmentByPair = {
    for (final segment in segments) '${segment.fromBinId}->${segment.toBinId}': segment,
  };

  double distanceKm = 0;
  double liters = 0;
  for (int i = 0; i < stopBinIds.length - 1; i++) {
    final String key = '${stopBinIds[i]}->${stopBinIds[i + 1]}';
    final RoadSegmentRecord? segment = segmentByPair[key];
    if (segment == null) {
      continue;
    }
    distanceKm += segment.distanceKm;
    liters += _segmentDieselLiters(
      distanceKm: segment.distanceKm,
      roadType: segment.roadType,
    );
  }

  return RouteComparisonSummary(
    name: name,
    points: points,
    distanceKm: distanceKm,
    dieselLiters: liters,
  );
}

double _segmentDieselLiters({
  required double distanceKm,
  required RoadType roadType,
}) {
  // Demo truck is fixed to modern type for this competition scenario.
  const double baseLitersPerKmModern = 0.34;
  final double roadMultiplier = switch (roadType) {
    RoadType.uphill => 1.35,
    RoadType.flat => 1.00,
    RoadType.downhill => 0.82,
  };
  return distanceKm * baseLitersPerKmModern * roadMultiplier;
}
