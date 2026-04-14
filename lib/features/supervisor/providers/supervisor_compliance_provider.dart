import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap/demo_bootstrap.dart';
import '../../../core/models/operations_enums.dart';
import '../../../core/models/truck_model.dart';
import '../../../core/repositories/repositories_provider.dart';

const double _dieselPriceJodPerLiter = 0.645;
const double _fuelLitersPerKm = 1.26;

/// All trucks: before = 10 bins per round (7.5 km/round). After = scenario-based per round.
const double _beforeKmPerRound = 7.5;

/// Per driver: 4 rounds, each [low_km, medium_km, high_km]. Same period mix for all.
const Map<String, List<List<double>>> _truckAfterKmByDriver = <String, List<List<double>>>{
  '1001': <List<double>>[
    <double>[2.1, 2.4, 2.8],
    <double>[2.9, 3.2, 3.7],
    <double>[4.2, 4.7, 5.3],
    <double>[3.5, 3.9, 4.5],
  ],
  '1002': <List<double>>[
    <double>[2.3, 2.6, 3.0],
    <double>[3.1, 3.5, 3.9],
    <double>[4.5, 5.0, 5.6],
    <double>[3.8, 4.2, 4.8],
  ],
  '1003': <List<double>>[
    <double>[2.0, 2.3, 2.7],
    <double>[2.8, 3.1, 3.6],
    <double>[4.0, 4.5, 5.0],
    <double>[3.3, 3.7, 4.2],
  ],
  '1004': <List<double>>[
    <double>[2.4, 2.7, 3.2],
    <double>[3.2, 3.6, 4.1],
    <double>[4.7, 5.2, 5.8],
    <double>[4.0, 4.4, 5.0],
  ],
  '1005': <List<double>>[
    <double>[2.5, 2.9, 3.3],
    <double>[3.4, 3.8, 4.3],
    <double>[4.9, 5.4, 6.0],
    <double>[4.1, 4.6, 5.2],
  ],
};

/// Day-count mix per period: [low_days, medium_days, high_days]. Daily = 100% MEDIUM (1 day).
const List<List<int>> _periodDayMix = <List<int>>[
  <int>[0, 1, 0],   // daily: 1 medium
  <int>[2, 3, 2],   // weekly: 2 low + 3 medium + 2 high
  <int>[8, 14, 8],  // monthly: 8 low + 14 medium + 8 high
  <int>[70, 190, 105], // yearly: 70 low + 190 medium + 105 high
];

const Map<String, double> _demoComplianceOverrides = <String, double>{
  '1001': 100,
  '1002': 100,
  '1003': 100,
  '1004': 85,
  '1005': 60,
};

enum RouteDeviationLevel { none, low, medium, high, severe }

extension RouteDeviationLevelX on RouteDeviationLevel {
  double get factor => switch (this) {
    RouteDeviationLevel.none => 0.0,
    RouteDeviationLevel.low => 0.2,
    RouteDeviationLevel.medium => 0.5,
    RouteDeviationLevel.high => 0.8,
    RouteDeviationLevel.severe => 1.0,
  };
}

class DriverDieselPeriodStat {
  const DriverDieselPeriodStat({
    required this.period,
    required this.beforeLiters,
    required this.afterLiters,
  });

  final DieselPeriod period;
  final double beforeLiters;
  final double afterLiters;

  double get savedLiters => beforeLiters - afterLiters;
  double get beforeCostJod => beforeLiters * _dieselPriceJodPerLiter;
  double get afterCostJod => afterLiters * _dieselPriceJodPerLiter;
  double get afterCostPctOfBefore =>
      beforeCostJod == 0 ? 0 : (afterCostJod / beforeCostJod) * 100;
  double get savedCostJod => beforeCostJod - afterCostJod;
  double get savedPct =>
      beforeCostJod == 0 ? 0 : (savedCostJod / beforeCostJod) * 100;
}

/// Per-round diesel for truck 1001. Exposes LOW/MEDIUM/HIGH km; each period uses its own day-count mix.
class DriverRoundDieselStat {
  const DriverRoundDieselStat({
    required this.beforeKm,
    required this.lowKm,
    required this.mediumKm,
    required this.highKm,
    required this.beforeLiters,
  });

  final double beforeKm;
  final double lowKm;
  final double mediumKm;
  final double highKm;
  final double beforeLiters;

  /// After distance for a period from day-count mix [lowDays, mediumDays, highDays].
  double afterKmForMix(int lowDays, int mediumDays, int highDays) =>
      lowKm * lowDays + mediumKm * mediumDays + highKm * highDays;
}

class DriverTripSummary {
  const DriverTripSummary({
    required this.tripNumber,
    required this.plannedPredictedBinsCount,
    required this.servicedBinsCount,
    required this.routeDeviationLevel,
    required this.appAdherencePenalty,
  });

  final int tripNumber;
  final int plannedPredictedBinsCount;
  final int servicedBinsCount;
  final RouteDeviationLevel routeDeviationLevel;
  final double appAdherencePenalty;

  int get binMissedCount => plannedPredictedBinsCount - servicedBinsCount;
  double get routePenalty => routeDeviationLevel.factor * 30;
}

class ComplianceBreakdown {
  const ComplianceBreakdown({
    required this.predictedTotal,
    required this.servicedTotal,
    required this.binPenalty,
    required this.routePenalty,
    required this.appPenalty,
    required this.finalScore,
  });

  final int predictedTotal;
  final int servicedTotal;
  final double binPenalty;
  final double routePenalty;
  final double appPenalty;
  final int finalScore;

  int get missedPredicted => predictedTotal - servicedTotal;
}

class DriverComplianceRow {
  const DriverComplianceRow({
    required this.driverId,
    required this.areaName,
    required this.plannedStops,
    required this.confirmedStops,
    required this.skipEvents,
    required this.bypassEvents,
    required this.isLateRoute,
    required this.dieselByPeriod,
    required this.trips,
    required this.breakdown,
    this.complianceOverridePercent,
    this.routeComplianceEfficiencyPercent,
    this.noDataMessage,
    this.dieselByRound,
  });

  final String driverId;
  final String areaName;
  final int plannedStops;
  final int confirmedStops;
  final int skipEvents;
  final int bypassEvents;
  final bool isLateRoute;
  final List<DriverDieselPeriodStat> dieselByPeriod;
  final List<DriverTripSummary> trips;
  final ComplianceBreakdown breakdown;
  final double? complianceOverridePercent;
  /// Route compliance efficiency = actual_savings / expected_savings as %. Good trucks ~85-90%, low compliance ~40-45%.
  final int? routeComplianceEfficiencyPercent;
  /// When set, this driver has no operational data; show this message instead of metrics.
  final String? noDataMessage;
  /// Per-round diesel (4 rounds); null if driver not in _truckAfterKmByDriver.
  final List<DriverRoundDieselStat>? dieselByRound;

  bool get hasOperationalData => noDataMessage == null;

  double get compliance =>
      complianceOverridePercent ??
      (plannedStops == 0 ? 0 : (confirmedStops / plannedStops) * 100);
  bool get isLowCompliance => compliance < 100;
}

class SupervisorComplianceData {
  const SupervisorComplianceData({
    required this.rows,
    required this.totalDieselByPeriod,
  });

  final List<DriverComplianceRow> rows;
  final List<DriverDieselPeriodStat> totalDieselByPeriod;
}

final FutureProvider<SupervisorComplianceData> supervisorComplianceProvider =
    FutureProvider<SupervisorComplianceData>((ref) async {
      await DemoBootstrap.ensureInitialized();
      final List<TruckModel> trucks = await ref.read(trucksRepositoryProvider).getAllTrucks();
      const List<String> driverIds = <String>['1001', '1002', '1003', '1004', '1005'];
      final List<DriverComplianceRow> rows = <DriverComplianceRow>[];

      for (int i = 0; i < driverIds.length; i++) {
        final String driverId = driverIds[i];
        final TruckModel? truck = trucks
            .where((item) => item.driverId == driverId)
            .cast<TruckModel?>()
            .firstWhere((item) => item != null, orElse: () => null);
        final _DriverDemoProfile profile = _demoProfileForDriver(driverId);
        final ComplianceBreakdown breakdown = _buildBreakdown(
          targetCompliance: _demoComplianceOverrides[driverId] ?? 100,
          trips: profile.trips,
        );
        final List<List<double>>? rounds = _truckAfterKmByDriver[driverId];
        final bool hasData = rounds != null && rounds.isNotEmpty;
        final List<DriverDieselPeriodStat> dieselByPeriod = hasData
            ? _dieselByPeriodForDriver(driverId, rounds)
            : _emptyDieselByPeriod();
        final List<DriverRoundDieselStat>? dieselByRound = hasData ? _dieselByRoundForDriver(rounds) : null;
        rows.add(
          DriverComplianceRow(
            driverId: driverId,
            areaName: truck?.areaName ?? 'area_name_generic',
            plannedStops: breakdown.predictedTotal,
            confirmedStops: breakdown.servicedTotal,
            skipEvents: profile.skipEvents,
            bypassEvents: profile.bypassEvents,
            isLateRoute: profile.isLateRoute,
            dieselByPeriod: dieselByPeriod,
            trips: profile.trips,
            breakdown: breakdown,
            complianceOverridePercent: _demoComplianceOverrides[driverId],
            routeComplianceEfficiencyPercent: _driverRouteEfficiencyPercent[driverId],
            noDataMessage: null,
            dieselByRound: dieselByRound,
          ),
        );
      }

      // TOTAL (الإجمالي): one overall percentage = (beforeTotal - afterTotal) / beforeTotal * 100
      // over ALL trucks (1001–1005) and ALL rounds (4 per truck).
      final List<DriverDieselPeriodStat> totalDieselByPeriod = _computeTotalDieselFromAllRows(rows);

      return SupervisorComplianceData(
        rows: rows,
        totalDieselByPeriod: totalDieselByPeriod,
      );
    });

class _DriverDemoProfile {
  const _DriverDemoProfile({
    required this.trips,
    required this.skipEvents,
    required this.bypassEvents,
    required this.isLateRoute,
  });

  final List<DriverTripSummary> trips;
  final int skipEvents;
  final int bypassEvents;
  final bool isLateRoute;
}

_DriverDemoProfile _demoProfileForDriver(String driverId) {
  return switch (driverId) {
    '1001' => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 3,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 2,
            plannedPredictedBinsCount: 4,
            servicedBinsCount: 4,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 3,
            plannedPredictedBinsCount: 6,
            servicedBinsCount: 6,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 4,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
        ],
        skipEvents: 0,
        bypassEvents: 0,
        isLateRoute: false,
      ),
    '1002' => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 3,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 2,
            plannedPredictedBinsCount: 4,
            servicedBinsCount: 4,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 3,
            plannedPredictedBinsCount: 6,
            servicedBinsCount: 6,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 4,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
        ],
        skipEvents: 0,
        bypassEvents: 0,
        isLateRoute: false,
      ),
    '1003' => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 3,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 2,
            plannedPredictedBinsCount: 4,
            servicedBinsCount: 4,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 3,
            plannedPredictedBinsCount: 6,
            servicedBinsCount: 6,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 4,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
        ],
        skipEvents: 0,
        bypassEvents: 0,
        isLateRoute: false,
      ),
    '1004' => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 3,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 2,
            plannedPredictedBinsCount: 4,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.low,
            appAdherencePenalty: 2,
          ),
          DriverTripSummary(
            tripNumber: 3,
            plannedPredictedBinsCount: 6,
            servicedBinsCount: 6,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
          DriverTripSummary(
            tripNumber: 4,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.low,
            appAdherencePenalty: 2,
          ),
        ],
        skipEvents: 1,
        bypassEvents: 0,
        isLateRoute: false,
      ),
    '1005' => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 3,
            servicedBinsCount: 2,
            routeDeviationLevel: RouteDeviationLevel.high,
            appAdherencePenalty: 0.9,
          ),
          DriverTripSummary(
            tripNumber: 2,
            plannedPredictedBinsCount: 4,
            servicedBinsCount: 3,
            routeDeviationLevel: RouteDeviationLevel.high,
            appAdherencePenalty: 0.9,
          ),
          DriverTripSummary(
            tripNumber: 3,
            plannedPredictedBinsCount: 6,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.high,
            appAdherencePenalty: 0.867,
          ),
          DriverTripSummary(
            tripNumber: 4,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 4,
            routeDeviationLevel: RouteDeviationLevel.high,
            appAdherencePenalty: 0.867,
          ),
        ],
        skipEvents: 2,
        bypassEvents: 1,
        isLateRoute: true,
      ),
    _ => const _DriverDemoProfile(
        trips: <DriverTripSummary>[
          DriverTripSummary(
            tripNumber: 1,
            plannedPredictedBinsCount: 5,
            servicedBinsCount: 5,
            routeDeviationLevel: RouteDeviationLevel.none,
            appAdherencePenalty: 0,
          ),
        ],
        skipEvents: 0,
        bypassEvents: 0,
        isLateRoute: false,
      ),
  };
}

ComplianceBreakdown _buildBreakdown({
  required double targetCompliance,
  required List<DriverTripSummary> trips,
}) {
  final int predictedTotal = trips.fold(0, (sum, trip) => sum + trip.plannedPredictedBinsCount);
  final int servicedTotal = trips.fold(0, (sum, trip) => sum + trip.servicedBinsCount);
  final int missedPredicted = predictedTotal - servicedTotal;

  final double binPenalty = predictedTotal == 0 ? 0 : (missedPredicted / predictedTotal) * 60;
  final double routeFactor = predictedTotal == 0
      ? 0
      : trips.fold<double>(
            0,
            (sum, trip) => sum + (trip.routeDeviationLevel.factor * trip.plannedPredictedBinsCount),
          ) /
          predictedTotal;
  final double routePenalty = routeFactor * 30;
  final double desiredPenalty = (100 - targetCompliance).clamp(0, 100);
  final double appPenalty = (desiredPenalty - binPenalty - routePenalty).clamp(0, 10);
  final int finalScore = (100 - (binPenalty + routePenalty + appPenalty)).clamp(0, 100).round();

  return ComplianceBreakdown(
    predictedTotal: predictedTotal,
    servicedTotal: servicedTotal,
    binPenalty: binPenalty,
    routePenalty: routePenalty,
    appPenalty: appPenalty,
    finalScore: finalScore,
  );
}

/// Route compliance efficiency % per truck.
const Map<String, int> _driverRouteEfficiencyPercent = <String, int>{
  '1001': 90,
  '1002': 88,
  '1003': 90,
  '1004': 85,
  '1005': 60,
};

/// Per-driver total (4 rounds). Each period uses its own scenario mix (not daily × N).
List<DriverDieselPeriodStat> _dieselByPeriodForDriver(String driverId, List<List<double>> rounds) {
  const double beforeKmPerRound = _beforeKmPerRound;
  const int roundCount = 4;

  return DieselPeriod.values.map((DieselPeriod period) {
    final int periodIndex = period.index;
    final List<int> mix = _periodDayMix[periodIndex];
    final int lowDays = mix[0];
    final int mediumDays = mix[1];
    final int highDays = mix[2];
    final int totalDays = lowDays + mediumDays + highDays;

    final double beforeKm = beforeKmPerRound * roundCount * (totalDays == 0 ? 1 : totalDays);
    final double beforeLiters = beforeKm * _fuelLitersPerKm;

    double afterKm = 0;
    for (int r = 0; r < rounds.length; r++) {
      final List<double> row = rounds[r];
      afterKm += row[0] * lowDays + row[1] * mediumDays + row[2] * highDays;
    }
    final double afterLiters = afterKm * _fuelLitersPerKm;

    return DriverDieselPeriodStat(
      period: period,
      beforeLiters: beforeLiters,
      afterLiters: afterLiters,
    );
  }).toList(growable: false);
}

List<DriverDieselPeriodStat> _emptyDieselByPeriod() {
  return DieselPeriod.values
      .map((DieselPeriod p) => DriverDieselPeriodStat(period: p, beforeLiters: 0, afterLiters: 0))
      .toList(growable: false);
}

/// TOTAL (الإجمالي): aggregate ALL trucks and ALL rounds. For each period:
/// beforeTotal = sum of beforeLiters, afterTotal = sum of afterLiters;
/// savingPercent = ((beforeTotal - afterTotal) / beforeTotal) * 100.
List<DriverDieselPeriodStat> _computeTotalDieselFromAllRows(List<DriverComplianceRow> rows) {
  final Map<DieselPeriod, double> sumBefore = <DieselPeriod, double>{};
  final Map<DieselPeriod, double> sumAfter = <DieselPeriod, double>{};
  for (final DieselPeriod period in DieselPeriod.values) {
    sumBefore[period] = 0;
    sumAfter[period] = 0;
  }
  for (final DriverComplianceRow row in rows) {
    if (!row.hasOperationalData) continue;
    for (final DriverDieselPeriodStat p in row.dieselByPeriod) {
      sumBefore[p.period] = sumBefore[p.period]! + p.beforeLiters;
      sumAfter[p.period] = sumAfter[p.period]! + p.afterLiters;
    }
  }
  return DieselPeriod.values
      .map((DieselPeriod period) => DriverDieselPeriodStat(
            period: period,
            beforeLiters: sumBefore[period]!,
            afterLiters: sumAfter[period]!,
          ))
      .toList(growable: false);
}

/// Per-driver per-round: low/medium/high km; each period uses its own day-count mix in the UI.
List<DriverRoundDieselStat> _dieselByRoundForDriver(List<List<double>> rounds) {
  const double beforeLiters = _beforeKmPerRound * _fuelLitersPerKm;
  final List<DriverRoundDieselStat> result = <DriverRoundDieselStat>[];
  for (int r = 0; r < rounds.length; r++) {
    final List<double> row = rounds[r];
    result.add(DriverRoundDieselStat(
      beforeKm: _beforeKmPerRound,
      lowKm: row[0],
      mediumKm: row[1],
      highKm: row[2],
      beforeLiters: beforeLiters,
    ));
  }
  return result;
}
