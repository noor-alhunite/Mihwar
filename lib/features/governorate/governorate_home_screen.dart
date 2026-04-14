import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../app/app.dart';
import '../../core/models/operations_enums.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../auth/providers/auth_controller.dart';
import 'providers/governorate_dashboard_provider.dart';

class GovernorateHomeScreen extends ConsumerWidget {
  const GovernorateHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<GovernorateDashboardData> dashboard = ref.watch(
      governorateDashboardProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.governorate_manager_dashboard_title),
        actions: [
          const LanguageSwitchButton(),
          TextButton.icon(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l10n.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.route_error(error.toString())),
          ),
        ),
        data: (GovernorateDashboardData data) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.governorate_manager_dashboard_title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.governorate_zarqa_subtitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.governorate_dashboard_note,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...data.areas.map(
                      (area) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GovernorateAreaCard(area: area),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GovernorateAreaCard extends StatelessWidget {
  const _GovernorateAreaCard({required this.area});

  final GovernorateAreaVm area;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.location_city_rounded,
            title: _areaLabel(area.areaId, l10n),
          ),
          const SizedBox(height: 8),
          _LabelValueRow(
            icon: Icons.supervisor_account_rounded,
            label: l10n.governorate_area_supervisor_label,
            value: area.hasData
                ? area.supervisorLabel
                : l10n.governorate_supervisor_unavailable,
          ),
          if (!area.hasData) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.inbox_rounded, color: Color(0xFF7A7A7A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.governorate_empty_area_state,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _SectionHeader(
              icon: Icons.groups_rounded,
              title: l10n.governorate_area_drivers_title,
            ),
            const SizedBox(height: 10),
            ...area.drivers.map(
              (driver) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DriverRowCard(driver: driver),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _SectionHeader(
              icon: Icons.local_gas_station_rounded,
              title: l10n.governorate_area_totals_diesel_title,
            ),
            const SizedBox(height: 8),
            ...area.areaTotals.map(
              (metric) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DieselPeriodPanel(period: metric, emphasizeSavings: true),
              ),
            ),
            const SizedBox(height: 6),
            _LabelValueRow(
              icon: Icons.warning_amber_rounded,
              label: l10n.governorate_non_compliant_drivers_count,
              value: area.nonCompliantDriversCount.toString(),
            ),
            const SizedBox(height: 10),
            _SectionHeader(
              icon: Icons.notification_important_rounded,
              title: l10n.governorate_alerts_non_compliant,
              titleColor: const Color(0xFFC4584A),
            ),
            const SizedBox(height: 8),
            ...area.alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33C4584A)),
                    color: const Color(0xFFFDF2EF),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_rounded, size: 18, color: Color(0xFFC4584A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.driver} ${alert.driverId}: ${_alertReasonLabel(alert.reason, l10n)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DriverRowCard extends StatelessWidget {
  const _DriverRowCard({required this.driver});

  final GovernorateDriverVm driver;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Color complianceColor = _complianceColor(driver.compliancePercent.toDouble());
    final Color dieselStatusColor = _dieselStatusColor(driver.dieselStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Tag(
                icon: Icons.badge_outlined,
                text: '${l10n.driver} ${driver.driverId}',
              ),
              _Tag(
                icon: Icons.track_changes_rounded,
                text: '${driver.compliancePercent}%',
                color: complianceColor,
              ),
              _Tag(
                icon: Icons.local_gas_station_rounded,
                text: _dieselStatusLabel(driver.dieselStatus, l10n),
                color: dieselStatusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniMetricCard(
                  title: l10n.governorate_expected_daily_label.replaceAll(
                    l10n.governorate_period_daily,
                    l10n.governorate_period_monthly,
                  ),
                  liters: _liters(driver.expectedDailyLiters),
                  costJod: driver.expectedDailyCostJod.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniMetricCard(
                  title: l10n.governorate_actual_daily_label.replaceAll(
                    l10n.governorate_period_daily,
                    l10n.governorate_period_monthly,
                  ),
                  liters: _liters(driver.actualDailyLiters),
                  costJod: driver.actualDailyCostJod.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DieselPeriodPanel extends StatelessWidget {
  const _DieselPeriodPanel({
    required this.period,
    this.emphasizeSavings = false,
  });

  final GovernorateAreaDieselMetric period;
  final bool emphasizeSavings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _periodLabel(period.period, l10n),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DieselCell(
                  title: l10n.before_label,
                  litersLabel: l10n.governorate_liters_label,
                  liters: _liters(period.beforeLiters),
                  costLabel: l10n.governorate_cost_label,
                  costJod: period.beforeCostJod.toStringAsFixed(2),
                  extraLabel: '100%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DieselCell(
                  title: l10n.after_label,
                  litersLabel: l10n.governorate_liters_label,
                  liters: _liters(period.afterLiters),
                  costLabel: l10n.governorate_cost_label,
                  costJod: period.afterCostJod.toStringAsFixed(2),
                  extraLabel: '${_pct1(_afterPct(period))}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DieselCell(
                  title: l10n.governorate_savings_label,
                  litersLabel: l10n.governorate_saved_liters_label,
                  liters: _liters(period.savedLiters),
                  costLabel: l10n.governorate_saved_cost_label,
                  costJod: period.savedCostJod.toStringAsFixed(2),
                  extraLabel: '${_pct1(period.savedPct)}%',
                  accent: emphasizeSavings ? const Color(0xFF1F6F43) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.title,
    required this.liters,
    required this.costJod,
  });

  final String title;
  final String liters;
  final String costJod;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${l10n.governorate_liters_label}: $liters ${l10n.liter_unit}'),
          const SizedBox(height: 3),
          Text('${l10n.governorate_cost_label}: $costJod ${l10n.currency_jod}'),
        ],
      ),
    );
  }
}

class _DieselCell extends StatelessWidget {
  const _DieselCell({
    required this.title,
    required this.litersLabel,
    required this.liters,
    required this.costLabel,
    required this.costJod,
    required this.extraLabel,
    this.accent,
  });

  final String title;
  final String litersLabel;
  final String liters;
  final String costLabel;
  final String costJod;
  final String extraLabel;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('$litersLabel: $liters ${l10n.liter_unit}'),
          const SizedBox(height: 4),
          Text('$costLabel: $costJod ${l10n.currency_jod}'),
          const SizedBox(height: 4),
          Text(
            '${l10n.governorate_percent_label}: $extraLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final Color color = titleColor ?? Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color base = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: base.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: base),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: base,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

String _periodLabel(DieselPeriod period, AppLocalizations l10n) {
  return switch (period) {
    DieselPeriod.daily => l10n.governorate_period_daily,
    DieselPeriod.weekly => l10n.governorate_period_weekly,
    DieselPeriod.monthly => l10n.governorate_period_monthly,
    DieselPeriod.yearly => l10n.governorate_period_yearly,
  };
}

String _liters(double value) {
  final double rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.05) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String _pct1(double value) => value.toStringAsFixed(1);

double _afterPct(GovernorateAreaDieselMetric period) {
  if (period.beforeCostJod == 0) {
    return 0;
  }
  return (period.afterCostJod / period.beforeCostJod) * 100;
}

Color _complianceColor(double compliance) {
  if (compliance >= 90) {
    return const Color(0xFF1F6F43);
  }
  if (compliance >= 70) {
    return const Color(0xFFE6A700);
  }
  return const Color(0xFFD66B5E);
}

Color _dieselStatusColor(GovernorateDieselStatus status) {
  return switch (status) {
    GovernorateDieselStatus.belowExpected => const Color(0xFF1F6F43),
    GovernorateDieselStatus.withinExpected => const Color(0xFF2D5FA6),
    GovernorateDieselStatus.aboveExpected => const Color(0xFFD66B5E),
  };
}

String _dieselStatusLabel(GovernorateDieselStatus status, AppLocalizations l10n) {
  return switch (status) {
    GovernorateDieselStatus.belowExpected => l10n.governorate_status_below_expected,
    GovernorateDieselStatus.withinExpected => l10n.governorate_status_within_expected,
    GovernorateDieselStatus.aboveExpected => l10n.governorate_status_above_expected,
  };
}

String _alertReasonLabel(GovernorateAlertReason reason, AppLocalizations l10n) {
  return switch (reason) {
    GovernorateAlertReason.missedPredictedBins => l10n.governorate_alert_reason_missed_bins,
    GovernorateAlertReason.mediumRouteDeviation => l10n.governorate_alert_reason_route_medium,
    GovernorateAlertReason.highRouteDeviation => l10n.governorate_alert_reason_route_high,
    GovernorateAlertReason.appAdherence => l10n.governorate_alert_reason_app,
  };
}

String _areaLabel(String areaId, AppLocalizations l10n) {
  return switch (areaId) {
    GovernorateAreaIds.karamaStreet => l10n.governorate_area_karama_street,
    GovernorateAreaIds.newZarqa => l10n.governorate_area_new_zarqa,
    GovernorateAreaIds.russeifa => l10n.governorate_area_russeifa,
    GovernorateAreaIds.hashmiya => l10n.governorate_area_hashmiya,
    GovernorateAreaIds.oldZarqa => l10n.governorate_area_old_zarqa,
    _ => l10n.area_name_generic,
  };
}
