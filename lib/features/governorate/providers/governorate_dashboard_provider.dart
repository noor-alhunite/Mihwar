import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap/demo_bootstrap.dart';
import '../../../core/models/operations_enums.dart';
import '../../../core/repositories/repositories_provider.dart';
import '../../supervisor/providers/supervisor_compliance_provider.dart';

class GovernorateAreaIds {
  static const String karamaStreet = 'karama_street';
  static const String newZarqa = 'new_zarqa';
  static const String russeifa = 'russeifa';
  static const String hashmiya = 'hashmiya';
  static const String oldZarqa = 'old_zarqa';
}

enum GovernorateDieselStatus { belowExpected, withinExpected, aboveExpected }

enum GovernorateAlertReason {
  missedPredictedBins,
  mediumRouteDeviation,
  highRouteDeviation,
  appAdherence,
}

class GovernorateAreaDieselMetric {
  const GovernorateAreaDieselMetric({
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
  double get savedCostJod => beforeCostJod - afterCostJod;
  double get savedPct =>
      beforeCostJod == 0 ? 0 : ((beforeCostJod - afterCostJod) / beforeCostJod) * 100;
}

class GovernorateDriverVm {
  const GovernorateDriverVm({
    required this.driverId,
    required this.compliancePercent,
    required this.expectedDailyLiters,
    required this.actualDailyLiters,
    required this.expectedDailyCostJod,
    required this.actualDailyCostJod,
    required this.dieselStatus,
  });

  final String driverId;
  final int compliancePercent;
  final double expectedDailyLiters;
  final double actualDailyLiters;
  final double expectedDailyCostJod;
  final double actualDailyCostJod;
  final GovernorateDieselStatus dieselStatus;
}

class GovernorateAreaAlertVm {
  const GovernorateAreaAlertVm({
    required this.driverId,
    required this.reason,
  });

  final String driverId;
  final GovernorateAlertReason reason;
}

class GovernorateAreaVm {
  const GovernorateAreaVm({
    required this.areaId,
    required this.supervisorLabel,
    required this.hasData,
    required this.drivers,
    required this.areaTotals,
    required this.nonCompliantDriversCount,
    required this.alerts,
  });

  final String areaId;
  final String supervisorLabel;
  final bool hasData;
  final List<GovernorateDriverVm> drivers;
  final List<GovernorateAreaDieselMetric> areaTotals;
  final int nonCompliantDriversCount;
  final List<GovernorateAreaAlertVm> alerts;
}

class GovernorateDashboardData {
  const GovernorateDashboardData({
    required this.areas,
  });

  final List<GovernorateAreaVm> areas;
}

class GovernorateDashboardController extends AsyncNotifier<GovernorateDashboardData> {
  @override
  Future<GovernorateDashboardData> build() async {
    return _load();
  }

  Future<void> loadDemoScenario() async {
    await ref.read(demoSeedRepositoryProvider).ensureSeeded();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> resetDemoScenario() async {
    await ref.read(demoSeedRepositoryProvider).resetDemo();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<GovernorateDashboardData> _load() async {
    await DemoBootstrap.ensureInitialized();
    final SupervisorComplianceData supervisorData =
        await ref.read(supervisorComplianceProvider.future);

    final List<DriverComplianceRow> rows = List<DriverComplianceRow>.from(supervisorData.rows)
      ..sort((a, b) => a.driverId.compareTo(b.driverId));

    final List<DriverComplianceRow> rowsWithData = rows
        .where((row) => row.hasOperationalData)
        .toList(growable: false);

    final List<GovernorateDriverVm> populatedDrivers = rowsWithData.map((row) {
      final DriverDieselPeriodStat monthly = row.dieselByPeriod.firstWhere(
        (period) => period.period == DieselPeriod.monthly,
      );
      return GovernorateDriverVm(
        driverId: row.driverId,
        compliancePercent: row.compliance.round(),
        expectedDailyLiters: monthly.beforeLiters,
        actualDailyLiters: monthly.afterLiters,
        expectedDailyCostJod: monthly.beforeCostJod,
        actualDailyCostJod: monthly.afterCostJod,
        dieselStatus: _statusForExpectedVsActual(
          expectedLiters: monthly.beforeLiters,
          actualLiters: monthly.afterLiters,
        ),
      );
    }).toList(growable: false);

    final List<DriverComplianceRow> nonCompliantRows = rowsWithData
        .where((row) => row.compliance < 100)
        .toList(growable: false);

    final List<GovernorateAreaAlertVm> alerts = <GovernorateAreaAlertVm>[
      for (final DriverComplianceRow row in nonCompliantRows) ...[
        if (row.breakdown.missedPredicted > 0)
          GovernorateAreaAlertVm(
            driverId: row.driverId,
            reason: GovernorateAlertReason.missedPredictedBins,
          ),
        if (row.breakdown.routePenalty >= 18)
          GovernorateAreaAlertVm(
            driverId: row.driverId,
            reason: GovernorateAlertReason.highRouteDeviation,
          )
        else if (row.breakdown.routePenalty > 0)
          GovernorateAreaAlertVm(
            driverId: row.driverId,
            reason: GovernorateAlertReason.mediumRouteDeviation,
          ),
        if (row.breakdown.appPenalty > 0)
          GovernorateAreaAlertVm(
            driverId: row.driverId,
            reason: GovernorateAlertReason.appAdherence,
          ),
      ],
    ];

    final List<GovernorateAreaDieselMetric> areaTotals = supervisorData.totalDieselByPeriod
        .map(
          (period) => GovernorateAreaDieselMetric(
            period: period.period,
            beforeLiters: period.beforeLiters,
            afterLiters: period.afterLiters,
          ),
        )
        .toList(growable: false);

    final GovernorateAreaVm populatedArea = GovernorateAreaVm(
      areaId: GovernorateAreaIds.karamaStreet,
      supervisorLabel: '2001',
      hasData: true,
      drivers: populatedDrivers,
      areaTotals: areaTotals,
      nonCompliantDriversCount: nonCompliantRows.length,
      alerts: alerts,
    );

    final List<GovernorateAreaVm> emptyAreas = <GovernorateAreaVm>[
      GovernorateAreaVm(
        areaId: GovernorateAreaIds.newZarqa,
        supervisorLabel: '',
        hasData: false,
        drivers: const <GovernorateDriverVm>[],
        areaTotals: const <GovernorateAreaDieselMetric>[],
        nonCompliantDriversCount: 0,
        alerts: const <GovernorateAreaAlertVm>[],
      ),
      GovernorateAreaVm(
        areaId: GovernorateAreaIds.russeifa,
        supervisorLabel: '',
        hasData: false,
        drivers: const <GovernorateDriverVm>[],
        areaTotals: const <GovernorateAreaDieselMetric>[],
        nonCompliantDriversCount: 0,
        alerts: const <GovernorateAreaAlertVm>[],
      ),
      GovernorateAreaVm(
        areaId: GovernorateAreaIds.hashmiya,
        supervisorLabel: '',
        hasData: false,
        drivers: const <GovernorateDriverVm>[],
        areaTotals: const <GovernorateAreaDieselMetric>[],
        nonCompliantDriversCount: 0,
        alerts: const <GovernorateAreaAlertVm>[],
      ),
      GovernorateAreaVm(
        areaId: GovernorateAreaIds.oldZarqa,
        supervisorLabel: '',
        hasData: false,
        drivers: const <GovernorateDriverVm>[],
        areaTotals: const <GovernorateAreaDieselMetric>[],
        nonCompliantDriversCount: 0,
        alerts: const <GovernorateAreaAlertVm>[],
      ),
    ];

    return GovernorateDashboardData(
      areas: <GovernorateAreaVm>[populatedArea, ...emptyAreas],
    );
  }
}

final AsyncNotifierProvider<GovernorateDashboardController, GovernorateDashboardData>
    governorateDashboardProvider =
    AsyncNotifierProvider<GovernorateDashboardController, GovernorateDashboardData>(
      GovernorateDashboardController.new,
    );

const double _dieselPriceJodPerLiter = 0.645;

GovernorateDieselStatus _statusForExpectedVsActual({
  required double expectedLiters,
  required double actualLiters,
}) {
  if (expectedLiters <= 0) {
    return GovernorateDieselStatus.withinExpected;
  }
  final double delta = actualLiters - expectedLiters;
  final double threshold = expectedLiters * 0.05;
  if (delta.abs() <= threshold) {
    return GovernorateDieselStatus.withinExpected;
  }
  if (actualLiters < (expectedLiters - threshold)) {
    return GovernorateDieselStatus.belowExpected;
  }
  return GovernorateDieselStatus.aboveExpected;
}
