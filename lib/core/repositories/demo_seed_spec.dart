import 'package:latlong2/latlong.dart';

import '../models/bin.dart';
import '../models/bin_visit_record.dart';
import '../models/diesel_stat_record.dart';
import '../models/driver_location_point.dart';
import '../models/operations_enums.dart';
import '../models/prediction_models.dart';
import '../models/route_planning_models.dart';
import '../models/truck_model.dart';
import 'prediction_engine.dart';

class DemoSeedSpec {
  const DemoSeedSpec._();

  static const String seedVersion = 'msar_demo_seed_v3_phase3_fixes_coords';
  static const String demoDate = '2026-02-16';
  static const String defaultDriverId = '1001';
  static const String trainingDriverId = '1006';

  static List<String> get productionDriverIds => const <String>[
    '1001',
    '1002',
    '1003',
    '1004',
    '1005',
  ];

  static final List<TruckModel> trucks = <TruckModel>[
    const TruckModel(driverId: '1001', label: 'Truck-1001', truckType: TruckType.modern, areaName: 'Zarqa - Al Karama North'),
    const TruckModel(driverId: '1002', label: 'Truck-1002', truckType: TruckType.old, areaName: 'Zarqa - Al Karama East'),
    const TruckModel(driverId: '1003', label: 'Truck-1003', truckType: TruckType.modern, areaName: 'Zarqa - Al Karama South'),
    const TruckModel(driverId: '1004', label: 'Truck-1004', truckType: TruckType.old, areaName: 'Zarqa - Al Karama West'),
    const TruckModel(driverId: '1005', label: 'Truck-1005', truckType: TruckType.modern, areaName: 'Zarqa - Al Karama Central'),
    const TruckModel(
      driverId: trainingDriverId,
      label: 'Truck-1006',
      truckType: TruckType.modern,
      areaName: 'Training Yard',
      trainingOnly: true,
    ),
  ];

  static final List<BinModel> bins = _buildBins();
  static final Map<int, String> binAssignments = _buildBinAssignments();
  static final List<DieselStatRecord> dieselStats = _buildDieselStats();

  static int get totalProductionBins => 50;
  static int get totalProductionDrivers => productionDriverIds.length;

  static SeasonType seasonForDate(DateTime date) {
    final int month = date.month;
    if (month == 3) {
      return SeasonType.ramadan;
    }
    if (month == 7 || month == 8) {
      return SeasonType.summerHoliday;
    }
    return SeasonType.normal;
  }

  static List<PlannedStopRecord> plannedStops() {
    final DateTime now = DateTime.parse('${demoDate}T08:30:00.000');
    final List<PlannedStopRecord> rows = <PlannedStopRecord>[];
    for (final String driverId in productionDriverIds) {
      final List<PredictedBinStop> predicted = predictedStopsFor(
        driverId: driverId,
        now: now,
        shift: ShiftPeriod.morning,
      );
      int order = 1;
      for (final PredictedBinStop stop in predicted) {
        rows.add(
          PlannedStopRecord(
            routeDate: demoDate,
            driverId: driverId,
            binId: stop.binId,
            stopOrder: order,
            isPriority: stop.predictedFillPercent >= PredictionEngine.priorityThresholdPercent,
          ),
        );
        order += 1;
      }
    }
    return rows;
  }

  static List<RoadSegmentRecord> roadSegments() {
    final List<RoadSegmentRecord> rows = <RoadSegmentRecord>[];
    final Map<int, BinModel> byId = <int, BinModel>{for (final BinModel b in bins) b.id: b};

    for (final String driverId in productionDriverIds) {
      final List<int> ids = bins
          .where((b) => binAssignments[b.id] == driverId)
          .map((b) => b.id)
          .toList(growable: false);
      for (int i = 0; i < ids.length; i++) {
        final int a = ids[i];
        final int b = ids[(i + 1) % ids.length];
        rows.add(
          RoadSegmentRecord(
            name: 'D$driverId-$a-$b',
            fromBinId: a,
            toBinId: b,
            distanceKm: _approxKm(byId[a]!, byId[b]!),
            roadType: (i % 3 == 0) ? RoadType.uphill : RoadType.flat,
            polylinePoints: <LatLng>[
              LatLng(byId[a]!.lat, byId[a]!.lng),
              LatLng((byId[a]!.lat + byId[b]!.lat) / 2, byId[a]!.lng),
              LatLng((byId[a]!.lat + byId[b]!.lat) / 2, byId[b]!.lng),
              LatLng(byId[b]!.lat, byId[b]!.lng),
            ],
          ),
        );
      }
    }
    return rows;
  }

  static List<BinVisitRecord> baselineVisits() {
    return <BinVisitRecord>[];
  }

  static List<DriverLocationPoint> locationPointsForDemoDate() {
    return <DriverLocationPoint>[];
  }

  static List<PredictedBinStop> predictedStopsFor({
    required String driverId,
    required DateTime now,
    required ShiftPeriod shift,
  }) {
    final PredictionEngine engine = const PredictionEngine();
    final List<BinModel> driverBins = bins.where((b) => binAssignments[b.id] == driverId).toList(growable: false);
    final SeasonType season = seasonForDate(now);

    final List<PredictedBinStop> all = driverBins.map((bin) {
      final double avgDailyFill = profileDrivenDailyFillForPrediction(
        binId: bin.id,
        day: now,
        shift: shift,
      );
      return engine.predictForShift(
        input: BinPredictionInput(
          bin: bin,
          driverId: driverId,
          lastServicedAt: syntheticLastServicedAt(binId: bin.id, now: now, shift: shift),
          avgDailyFillPercent: avgDailyFill,
          dayOfWeek: now.weekday,
          season: season,
        ),
        now: now,
        shift: shift,
      );
    }).toList(growable: false)
      ..sort((a, b) => b.predictedFillPercent.compareTo(a.predictedFillPercent));

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

  static double profileDrivenDailyFillForPrediction({
    required int binId,
    required DateTime day,
    required ShiftPeriod shift,
  }) {
    final BinModel bin = bins.firstWhere((b) => b.id == binId);
    final bool commercial = bin.zoneType == BinZoneType.commercial;
    final int driverIndex = ((int.tryParse(binAssignments[binId] ?? '1001') ?? 1001) - 1001).clamp(0, 5);
    final double season = switch (seasonForDate(day)) {
      SeasonType.ramadan => 1.35,
      SeasonType.summerHoliday => 1.18,
      SeasonType.normal => 1.0,
    };
    final double shiftMul = switch (shift) {
      ShiftPeriod.morning => 0.95,
      ShiftPeriod.noon => 1.02,
      ShiftPeriod.afternoon => 1.08,
      ShiftPeriod.evening => 1.14,
    };
    final double base = commercial ? 155 : 105;
    final double density = 0.88 + ((binId % 5) * 0.07);
    final double driverMod = 0.95 + (driverIndex * 0.03);
    return base * density * driverMod * season * shiftMul;
  }

  static DateTime syntheticLastServicedAt({
    required int binId,
    required DateTime now,
    required ShiftPeriod shift,
  }) {
    final int hours = (6 + (binId % 10) + shift.index).clamp(3, 20);
    return now.subtract(Duration(hours: hours));
  }

  static Map<int, String> _buildBinAssignments() {
    final Map<int, String> out = <int, String>{};
    for (int i = 0; i < productionDriverIds.length; i++) {
      final String driverId = productionDriverIds[i];
      final int start = (i * 10) + 1;
      for (int n = 0; n < 10; n++) {
        out[start + n] = driverId;
      }
    }
    for (int id = 51; id <= 55; id++) {
      out[id] = trainingDriverId;
    }
    return out;
  }

  /// Driver 1001: only the 10 AI-selected bins. Labels must match predicted_bins_for_flutter.json.
  /// All coordinates are in one logical cluster (AI selected dataset); no legacy 1001 bins.
  static const List<String> _driver1001AiBinLabels = <String>[
    'BIN-004',
    'BIN-006',
    'BIN-007',
    'BIN-005',
    'BIN-009',
    'BIN-011',
    'BIN-015',
    'BIN-012',
    'BIN-020',
    'BIN-017',
  ];

  /// Driver 1001 coordinates: urban distribution (40–120 m spacing).
  /// 1) Dense residential: BIN-004,006,007 on Street A (N–S); BIN-005,009 on Street B (E–W), intersecting.
  /// 2) Commercial street: BIN-011,015,012 along main street.
  /// 3) Quiet residential: BIN-020,017 on same side street.
  static const List<({double lat, double lng})> _driver1001Coords = <({double lat, double lng})>[
    // Dense residential — Street A (N–S, lng=36.0872)
    (lat: 32.07250, lng: 36.0872),  // BIN-004
    (lat: 32.07295, lng: 36.0872),  // BIN-006
    (lat: 32.07340, lng: 36.0872),  // BIN-007
    // Dense residential — Street B (E–W, lat=32.07295), intersects Street A
    (lat: 32.07295, lng: 36.0868),  // BIN-005
    (lat: 32.07295, lng: 36.0876),  // BIN-009
    // Commercial street — main street (diagonal)
    (lat: 32.07290, lng: 36.0879),  // BIN-011
    (lat: 32.07320, lng: 36.0881),  // BIN-015
    (lat: 32.07350, lng: 36.0883),  // BIN-012
    // Quiet residential — side street (E–W, lng=36.0869)
    (lat: 32.07360, lng: 36.0869),  // BIN-020
    (lat: 32.07400, lng: 36.0869),  // BIN-017
  ];

  static List<BinModel> _buildBins() {
    final List<BinModel> result = <BinModel>[];
    // Driver 1001: only the new 10 AI-selected bins, one geographic cluster, no legacy data.
    for (int n = 0; n < 10; n++) {
      result.add(
        BinModel(
          id: 1 + n,
          label: _driver1001AiBinLabels[n],
          lat: _driver1001Coords[n].lat,
          lng: _driver1001Coords[n].lng,
          zoneType: (n % 3 == 0) ? BinZoneType.commercial : BinZoneType.residential,
        ),
      );
    }
    const Map<String, List<({double lat, double lng})>> productionCoordinates =
        <String, List<({double lat, double lng})>>{
          // 1002: west-central block, separated from 1001 with two close pairs.
          '1002': <({double lat, double lng})>[
            (lat: 32.07382, lng: 36.08162),
            (lat: 32.07378, lng: 36.08218),
            (lat: 32.07296, lng: 36.08308),
            (lat: 32.07292, lng: 36.08366),
            (lat: 32.07424, lng: 36.08276),
            (lat: 32.07334, lng: 36.08464),
            (lat: 32.07234, lng: 36.08244),
            (lat: 32.07196, lng: 36.08408),
            (lat: 32.07404, lng: 36.08442),
            (lat: 32.07256, lng: 36.08128),
          ],
          // 1003: central-east block, two close pairs and singles on nearby streets.
          '1003': <({double lat, double lng})>[
            (lat: 32.07414, lng: 36.08874),
            (lat: 32.07410, lng: 36.08930),
            (lat: 32.07338, lng: 36.09108),
            (lat: 32.07334, lng: 36.09162),
            (lat: 32.07456, lng: 36.09014),
            (lat: 32.07286, lng: 36.08984),
            (lat: 32.07246, lng: 36.09072),
            (lat: 32.07486, lng: 36.09132),
            (lat: 32.07382, lng: 36.09228),
            (lat: 32.07292, lng: 36.08846),
          ],
          // 1004: south-central block, two close pairs and wider single stops.
          '1004': <({double lat, double lng})>[
            (lat: 32.07134, lng: 36.08506),
            (lat: 32.07130, lng: 36.08562),
            (lat: 32.07056, lng: 36.08716),
            (lat: 32.07052, lng: 36.08772),
            (lat: 32.07186, lng: 36.08636),
            (lat: 32.07098, lng: 36.08844),
            (lat: 32.06996, lng: 36.08594),
            (lat: 32.06972, lng: 36.08796),
            (lat: 32.07174, lng: 36.08814),
            (lat: 32.07018, lng: 36.08472),
          ],
          // 1005: eastern block, distinct area with two close pairs.
          '1005': <({double lat, double lng})>[
            (lat: 32.07562, lng: 36.09286),
            (lat: 32.07558, lng: 36.09340),
            (lat: 32.07488, lng: 36.09474),
            (lat: 32.07484, lng: 36.09528),
            (lat: 32.07608, lng: 36.09418),
            (lat: 32.07518, lng: 36.09192),
            (lat: 32.07392, lng: 36.09336),
            (lat: 32.07354, lng: 36.09454),
            (lat: 32.07632, lng: 36.09554),
            (lat: 32.07428, lng: 36.09224),
          ],
        };
    for (int i = 1; i < productionDriverIds.length; i++) {
      final String driverId = productionDriverIds[i];
      final int startId = (i * 10) + 1;
      final List<({double lat, double lng})> coords = productionCoordinates[driverId]!;
      for (int n = 0; n < 10; n++) {
        final int id = startId + n;
        final ({double lat, double lng}) point = coords[n];
        result.add(
          BinModel(
            id: id,
            label: 'BIN-${1000 + id}',
            lat: point.lat,
            lng: point.lng,
            zoneType: (n % 3 == 0) ? BinZoneType.commercial : BinZoneType.residential,
          ),
        );
      }
    }
    const double trainingBaseLat = 32.0711;
    const double trainingBaseLng = 36.0891;
    for (int n = 0; n < 5; n++) {
      final int id = 51 + n;
      result.add(
        BinModel(
          id: id,
          label: 'BIN-${1000 + id}',
          lat: trainingBaseLat + ((n % 3) * 0.00042) - ((n ~/ 3) * 0.00024),
          lng: trainingBaseLng + ((n % 3) * 0.00036) + ((n ~/ 3) * 0.00031),
          zoneType: n.isEven ? BinZoneType.residential : BinZoneType.commercial,
        ),
      );
    }
    return result;
  }

  static List<DieselStatRecord> _buildDieselStats() {
    return <DieselStatRecord>[
      const DieselStatRecord(mode: DieselMode.before, period: DieselPeriod.daily, value: 170),
      const DieselStatRecord(mode: DieselMode.after, period: DieselPeriod.daily, value: 110),
      const DieselStatRecord(mode: DieselMode.before, period: DieselPeriod.weekly, value: 1190),
      const DieselStatRecord(mode: DieselMode.after, period: DieselPeriod.weekly, value: 770),
      const DieselStatRecord(mode: DieselMode.before, period: DieselPeriod.monthly, value: 5100),
      const DieselStatRecord(mode: DieselMode.after, period: DieselPeriod.monthly, value: 3300),
      const DieselStatRecord(mode: DieselMode.before, period: DieselPeriod.yearly, value: 62050),
      const DieselStatRecord(mode: DieselMode.after, period: DieselPeriod.yearly, value: 40150),
    ];
  }

  static double _approxKm(BinModel a, BinModel b) {
    final double dLatKm = (a.lat - b.lat).abs() * 111.0;
    final double dLngKm = (a.lng - b.lng).abs() * 94.0;
    return (dLatKm + dLngKm).clamp(0.18, 1.7).toDouble();
  }
}
