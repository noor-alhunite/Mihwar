import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/bin.dart';
import '../../models/bin_visit_record.dart';
import '../../models/diesel_stat_record.dart';
import '../../models/driver_location_point.dart';
import '../../models/operations_enums.dart';
import '../../models/prediction_models.dart';
import '../../models/route_planning_models.dart';
import '../../models/truck_model.dart';
import '../demo_repositories.dart';
import '../demo_seed_spec.dart';
import '../prediction_engine.dart';

class InMemoryDemoRepositoryBundle {
  const InMemoryDemoRepositoryBundle._();

  static DemoRepositoryBundle create() {
    final _InMemoryStore store = _InMemoryStore();
    final _InMemoryBinsRepository bins = _InMemoryBinsRepository(store);
    final _InMemoryVisitsRepository visits = _InMemoryVisitsRepository(store);
    final _InMemoryDieselStatsRepository diesel = _InMemoryDieselStatsRepository(store);
    final _InMemoryRoutePlanningRepository routes = _InMemoryRoutePlanningRepository(store);
    final _InMemoryDriverEventsRepository events = _InMemoryDriverEventsRepository(store);
    final _InMemoryDriverLocationRepository location = _InMemoryDriverLocationRepository(store);
    final _InMemoryTrucksRepository trucks = _InMemoryTrucksRepository(store);
    final _InMemoryPredictionRepository prediction = _InMemoryPredictionRepository(
      binsRepository: bins,
      visitsRepository: visits,
    );
    final _InMemoryDemoSeedRepository seed = _InMemoryDemoSeedRepository(
      store: store,
      binsRepository: bins,
      visitsRepository: visits,
      dieselStatsRepository: diesel,
      routePlanningRepository: routes,
      driverEventsRepository: events,
      locationRepository: location,
      trucksRepository: trucks,
    );

    return DemoRepositoryBundle(
      binsRepository: bins,
      visitsRepository: visits,
      dieselStatsRepository: diesel,
      routePlanningRepository: routes,
      driverEventsRepository: events,
      driverLocationRepository: location,
      predictionRepository: prediction,
      trucksRepository: trucks,
      demoSeedRepository: seed,
    );
  }
}

class _InMemoryStore {
  String? seedVersion;
  final List<BinModel> bins = <BinModel>[];
  final List<BinVisitRecord> visits = <BinVisitRecord>[];
  final List<DieselStatRecord> diesel = <DieselStatRecord>[];
  final List<PlannedStopRecord> plannedStops = <PlannedStopRecord>[];
  final List<RoadSegmentRecord> roadSegments = <RoadSegmentRecord>[];
  final List<DriverEventRecord> driverEvents = <DriverEventRecord>[];
  final List<DriverLocationPoint> locationPoints = <DriverLocationPoint>[];
  final List<TruckModel> trucks = <TruckModel>[];
  final Map<int, String> assignedDriversByBin = <int, String>{};
}

class _InMemoryBinsRepository implements BinsRepository {
  _InMemoryBinsRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<List<BinModel>> getAllBins() async => List<BinModel>.from(_store.bins);

  @override
  Future<void> replaceAllBins(List<BinModel> bins) async {
    _store.bins
      ..clear()
      ..addAll(bins);
  }

  @override
  Future<List<BinModel>> getBinsByDriver(String driverId) async {
    return _store.bins.where((b) => _store.assignedDriversByBin[b.id] == driverId).toList(growable: false);
  }

  @override
  Future<void> assignBinsToDrivers(Map<int, String> binAssignments) async {
    _store.assignedDriversByBin
      ..clear()
      ..addAll(binAssignments);
  }
}

class _InMemoryVisitsRepository implements VisitsRepository {
  _InMemoryVisitsRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> addVisit(BinVisitRecord visit) async => _store.visits.add(visit);

  @override
  Future<void> addVisits(List<BinVisitRecord> visits) async => _store.visits.addAll(visits);

  @override
  Future<List<BinVisitRecord>> getVisitsByDriverAndDate({
    required String driverId,
    required String routeDate,
  }) async {
    return _store.visits.where((v) => v.driverId == driverId && _dateOnly(v.visitedAt) == routeDate).toList(growable: false);
  }

  @override
  Future<List<BinVisitRecord>> getVisitsByBin(int binId) async {
    return _store.visits.where((v) => v.binId == binId).toList(growable: false);
  }
}

class _InMemoryDieselStatsRepository implements DieselStatsRepository {
  _InMemoryDieselStatsRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> replaceAllStats(List<DieselStatRecord> stats) async {
    _store.diesel
      ..clear()
      ..addAll(stats);
  }

  @override
  Future<List<DieselStatRecord>> getAllStats() async => List<DieselStatRecord>.from(_store.diesel);
}

class _InMemoryRoutePlanningRepository implements RoutePlanningRepository {
  _InMemoryRoutePlanningRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> replacePlannedStops(List<PlannedStopRecord> stops) async {
    _store.plannedStops
      ..clear()
      ..addAll(stops);
  }

  @override
  Future<List<PlannedStopRecord>> getPlannedStops({
    required String driverId,
    required String routeDate,
  }) async {
    final List<PlannedStopRecord> out = _store.plannedStops
        .where((s) => s.driverId == driverId && s.routeDate == routeDate)
        .toList(growable: false);
    out.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    return out;
  }

  @override
  Future<void> replaceRoadSegments(List<RoadSegmentRecord> segments) async {
    _store.roadSegments
      ..clear()
      ..addAll(segments);
  }

  @override
  Future<List<RoadSegmentRecord>> getRoadSegments() async => List<RoadSegmentRecord>.from(_store.roadSegments);
}

class _InMemoryDriverEventsRepository implements DriverEventsRepository {
  _InMemoryDriverEventsRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> addEvent(DriverEventRecord event) async => _store.driverEvents.add(event);

  @override
  Future<List<DriverEventRecord>> getEventsByDriverAndDate({
    required String driverId,
    required String routeDate,
  }) async {
    return _store.driverEvents.where((e) => e.driverId == driverId && e.routeDate == routeDate).toList(growable: false);
  }
}

class _InMemoryDriverLocationRepository implements DriverLocationRepository {
  _InMemoryDriverLocationRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> addLocationPoint(DriverLocationPoint point) async => _store.locationPoints.add(point);

  @override
  Future<void> addLocationPoints(List<DriverLocationPoint> points) async => _store.locationPoints.addAll(points);

  @override
  Future<List<DriverLocationPoint>> getLocationPoints({
    required String driverId,
    required String routeDate,
  }) async {
    return _store.locationPoints.where((p) => p.driverId == driverId && p.routeDate == routeDate).toList(growable: false);
  }
}

class _InMemoryPredictionRepository implements PredictionRepository {
  _InMemoryPredictionRepository({
    required BinsRepository binsRepository,
    required VisitsRepository visitsRepository,
  }) : _binsRepository = binsRepository,
       _visitsRepository = visitsRepository;

  final BinsRepository _binsRepository;
  final VisitsRepository _visitsRepository;
  final PredictionEngine _engine = const PredictionEngine();

  @override
  Future<List<PredictedBinStop>> getPriorityStops({
    required String driverId,
    required String routeDate,
    required DateTime now,
    required String shift,
    bool includeTrainingDriver = false,
  }) async {
    if (!includeTrainingDriver && driverId == DemoSeedSpec.trainingDriverId) {
      return const <PredictedBinStop>[];
    }
    final ShiftPeriod shiftPeriod = ShiftPeriodX.fromValue(shift);

    if (driverId == '1001') {
      final List<PredictedBinStop>? aiStops = await _loadAiPredictedStops(
        driverId: driverId,
        shiftPeriod: shiftPeriod,
      );
      if (aiStops != null && aiStops.isNotEmpty) {
        return aiStops;
      }
    }

    final SeasonType season = DemoSeedSpec.seasonForDate(now);
    final List<BinModel> bins = await _binsRepository.getBinsByDriver(driverId);
    final List<PredictedBinStop> all = <PredictedBinStop>[];

    for (final BinModel bin in bins) {
      final List<BinVisitRecord> history = (await _visitsRepository.getVisitsByBin(bin.id))
          .where((v) => v.driverId == driverId)
          .toList(growable: false);
      final BinVisitRecord? last = history.isEmpty ? null : history.last;
      final PredictedBinStop stop = _engine.predictForShift(
        input: BinPredictionInput(
          bin: bin,
          driverId: driverId,
          lastServicedAt: last?.visitedAt ??
              DemoSeedSpec.syntheticLastServicedAt(
                binId: bin.id,
                now: now,
                shift: shiftPeriod,
              ),
          avgDailyFillPercent: DemoSeedSpec.profileDrivenDailyFillForPrediction(
            binId: bin.id,
            day: now,
            shift: shiftPeriod,
          ),
          dayOfWeek: now.weekday,
          season: season,
        ),
        now: now,
        shift: shiftPeriod,
      );
      all.add(stop);
    }

    all.sort((a, b) => b.predictedFillPercent.compareTo(a.predictedFillPercent));
    final List<PredictedBinStop> threshold = all
        .where((s) => s.predictedFillPercent >= PredictionEngine.priorityThresholdPercent)
        .toList(growable: false);
    if (threshold.isNotEmpty) {
      return threshold.take(7).toList(growable: false);
    }
    return all.take(3).map((s) {
      return PredictedBinStop(
        binId: s.binId,
        driverId: s.driverId,
        predictedFillPercent: s.predictedFillPercent,
        reasons: <String>[...s.reasons, 'predict_reason_fallback_top3'],
        shift: s.shift,
      );
    }).toList(growable: false);
  }

  static const String _aiJsonAsset = 'assets/data/predicted_bins_for_flutter.json';

  /// For driver 1001 only: load AI JSON and convert to [PredictedBinStop] list.
  /// Returns null on load/parse error or when no entries match driver bins (fallback).
  Future<List<PredictedBinStop>?> _loadAiPredictedStops({
    required String driverId,
    required ShiftPeriod shiftPeriod,
  }) async {
    try {
      final String jsonString = await rootBundle.loadString(_aiJsonAsset);
      final Object? decoded = jsonDecode(jsonString);
      if (decoded is! List<Object?>) return null;
      final List<BinModel> driverBins = await _binsRepository.getBinsByDriver(driverId);
      final Map<String, BinModel> byLabel = <String, BinModel>{
        for (final BinModel b in driverBins) b.label: b,
      };
      final Map<int, BinModel> byId = <int, BinModel>{
        for (final BinModel b in driverBins) b.id: b,
      };

      final List<PredictedBinStop> result = <PredictedBinStop>[];
      for (final Object? entry in decoded) {
        if (entry is! Map<String, dynamic>) continue;
        final Object? selected = entry['selected_for_collection'];
        if (selected != true) continue;
        final String? binIdStr = entry['bin_id'] as String?;
        if (binIdStr == null || binIdStr.isEmpty) continue;
        final Object? fill = entry['predicted_fill'];
        final double predictedFill = (fill is num) ? fill.toDouble() : 0.0;
        final String? reasonText = entry['prediction_reason'] as String?;

        BinModel? bin = byLabel[binIdStr];
        if (bin == null) {
          final int? parsedId = _parseBinIdFromLabel(binIdStr);
          if (parsedId != null) bin = byId[parsedId];
        }
        if (bin == null) continue;

        final List<String> reasons = <String>[
          'predict_reason_ai_json',
          if (reasonText != null && reasonText.isNotEmpty) reasonText,
        ];
        result.add(PredictedBinStop(
          binId: bin.id,
          driverId: driverId,
          predictedFillPercent: predictedFill,
          reasons: reasons,
          shift: shiftPeriod,
        ));
      }
      if (result.isEmpty) return null;
      result.sort((a, b) => b.predictedFillPercent.compareTo(a.predictedFillPercent));
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Parse numeric part from labels like "BIN-015" or "BIN-1001".
  static int? _parseBinIdFromLabel(String binIdStr) {
    final RegExp re = RegExp(r'BIN-(\d+)', caseSensitive: false);
    final Match? match = re.firstMatch(binIdStr);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}

class _InMemoryTrucksRepository implements TrucksRepository {
  _InMemoryTrucksRepository(this._store);
  final _InMemoryStore _store;

  @override
  Future<void> replaceAllTrucks(List<TruckModel> trucks) async {
    _store.trucks
      ..clear()
      ..addAll(trucks);
  }

  @override
  Future<List<TruckModel>> getAllTrucks() async => List<TruckModel>.from(_store.trucks);
}

class _InMemoryDemoSeedRepository implements DemoSeedRepository {
  _InMemoryDemoSeedRepository({
    required _InMemoryStore store,
    required BinsRepository binsRepository,
    required VisitsRepository visitsRepository,
    required DieselStatsRepository dieselStatsRepository,
    required RoutePlanningRepository routePlanningRepository,
    required DriverEventsRepository driverEventsRepository,
    required DriverLocationRepository locationRepository,
    required TrucksRepository trucksRepository,
  }) : _store = store,
       _binsRepository = binsRepository,
       _visitsRepository = visitsRepository,
       _dieselStatsRepository = dieselStatsRepository,
       _routePlanningRepository = routePlanningRepository,
       _driverEventsRepository = driverEventsRepository,
       _locationRepository = locationRepository,
       _trucksRepository = trucksRepository;

  final _InMemoryStore _store;
  final BinsRepository _binsRepository;
  final VisitsRepository _visitsRepository;
  final DieselStatsRepository _dieselStatsRepository;
  final RoutePlanningRepository _routePlanningRepository;
  final DriverEventsRepository _driverEventsRepository;
  final DriverLocationRepository _locationRepository;
  final TrucksRepository _trucksRepository;

  @override
  Future<void> ensureSeeded() async {
    if (_store.seedVersion == DemoSeedSpec.seedVersion) {
      return;
    }
    await resetDemo();
  }

  @override
  Future<void> resetDemo() async {
    _store.visits.clear();
    _store.driverEvents.clear();
    _store.locationPoints.clear();

    await _trucksRepository.replaceAllTrucks(DemoSeedSpec.trucks);
    await _binsRepository.replaceAllBins(DemoSeedSpec.bins);
    await _binsRepository.assignBinsToDrivers(DemoSeedSpec.binAssignments);
    await _dieselStatsRepository.replaceAllStats(DemoSeedSpec.dieselStats);
    await _routePlanningRepository.replacePlannedStops(DemoSeedSpec.plannedStops());
    await _routePlanningRepository.replaceRoadSegments(DemoSeedSpec.roadSegments());
    await _visitsRepository.addVisits(DemoSeedSpec.baselineVisits());
    await _locationRepository.addLocationPoints(DemoSeedSpec.locationPointsForDemoDate());

    _store.seedVersion = DemoSeedSpec.seedVersion;
    await _driverEventsRepository.addEvent(
      DriverEventRecord(
        routeDate: DemoSeedSpec.demoDate,
        driverId: '1004',
        eventType: DriverEventType.skipAttempt,
        createdAt: DateTime.parse('${DemoSeedSpec.demoDate}T08:45:00.000'),
      ),
    );
  }
}

String _dateOnly(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
