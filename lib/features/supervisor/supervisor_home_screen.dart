import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/models/operations_enums.dart';
import '../auth/providers/auth_controller.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'providers/supervisor_compliance_provider.dart';

class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.area_supervisor_dashboard),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ref
                .watch(supervisorComplianceProvider)
                .when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text(l10n.route_error(error.toString()))),
                  data: (data) {
                    final List<DriverComplianceRow> alertRows = data.rows
                        .where((row) => row.hasOperationalData && row.compliance < 100)
                        .toList(growable: false);
                    return ListView(
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.driver_compliance_title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.driver_compliance_formula,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...data.rows.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DriverComplianceCard(row: row),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _SupervisorTotalsCard(periods: data.totalDieselByPeriod),
                        const SizedBox(height: 12),
                        _SupervisorAlertsCard(rows: alertRows),
                      ],
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _DriverComplianceCard extends StatefulWidget {
  const _DriverComplianceCard({required this.row});

  final DriverComplianceRow row;

  @override
  State<_DriverComplianceCard> createState() => _DriverComplianceCardState();
}

class _DriverComplianceCardState extends State<_DriverComplianceCard> {
  int _selectedTripIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DriverComplianceRow row = widget.row;
    if (row.noDataMessage != null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.person_pin_circle_rounded,
              title: l10n.supervisor_section_driver_info,
            ),
            const SizedBox(height: 8),
            _LabelValueRow(
              label: l10n.driver,
              value: row.driverId,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            Text(
              row.noDataMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    final double complianceValue = row.compliance.clamp(0, 100);
    final Color complianceColor = _complianceColor(complianceValue);
    final Color emphasisColor = const Color(0xFF1F6F43);
    final int safeTripIndex = row.trips.isEmpty ? 0 : _selectedTripIndex.clamp(0, row.trips.length - 1);
    final DriverTripSummary? selectedTrip = row.trips.isEmpty ? null : row.trips[safeTripIndex];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.person_pin_circle_rounded,
            title: l10n.supervisor_section_driver_info,
          ),
          const SizedBox(height: 8),
          _LabelValueRow(
            label: l10n.driver,
            value: row.driverId,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 6),
          _LabelValueRow(
            label: l10n.areas_covered,
            value: _areaLabelForDriver(row.driverId, l10n),
            icon: Icons.map_outlined,
          ),
          const SizedBox(height: 6),
          _LabelValueRow(
            label: l10n.supervisor_route_compliance_efficiency,
            value: '${row.compliance.round()}%',
            icon: Icons.route_rounded,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.verified_user_outlined,
            title: l10n.supervisor_section_compliance_summary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.track_changes_rounded, color: complianceColor),
              const SizedBox(width: 8),
              Text(
                '${complianceValue.round()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: complianceColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: complianceValue / 100,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(complianceColor),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.alt_route_rounded,
            title: l10n.supervisor_trips_title,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < row.trips.length; i++)
                ChoiceChip(
                  label: Text(l10n.supervisor_trip_label(i + 1)),
                  selected: i == safeTripIndex,
                  onSelected: (_) => setState(() => _selectedTripIndex = i),
                ),
            ],
          ),
          if (selectedTrip != null) ...[
            const SizedBox(height: 10),
            _LabelValueRow(
              label: l10n.supervisor_route_deviation_level,
              value: _routeDeviationLabel(selectedTrip.routeDeviationLevel, l10n),
              icon: Icons.alt_route_rounded,
            ),
            const SizedBox(height: 6),
            _LabelValueRow(
              label: l10n.supervisor_route_penalty_points,
              value: '${_points(selectedTrip.routePenalty)} ${l10n.supervisor_points_unit}',
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 6),
            _LabelValueRow(
              label: l10n.supervisor_app_penalty_points,
              value: '${_points(selectedTrip.appAdherencePenalty)} ${l10n.supervisor_points_unit}',
              icon: Icons.task_alt_rounded,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.route_rounded,
            title: l10n.supervisor_section_stops_summary,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricTile(
                title: l10n.supervisor_predicted_bins_count,
                value: (selectedTrip?.plannedPredictedBinsCount ?? row.breakdown.predictedTotal).toString(),
                icon: Icons.list_alt_rounded,
              ),
              _MetricTile(
                title: l10n.supervisor_serviced_bins_count,
                value: (selectedTrip?.servicedBinsCount ?? row.breakdown.servicedTotal).toString(),
                icon: Icons.check_circle_rounded,
                valueColor: emphasisColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _SectionHeader(
            icon: Icons.local_gas_station_rounded,
            title: l10n.supervisor_section_diesel,
          ),
          const SizedBox(height: 8),
          ..._dieselPeriodStatsForCard(row, safeTripIndex).map(
            (period) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DieselPeriodPanel(period: period),
            ),
          ),
          const SizedBox(height: 6),
          if (row.compliance < 100)
            _ComplianceExplainPanel(row: row)
          else
            _LabelValueRow(
              label: l10n.supervisor_section_compliance_explanation,
              value: l10n.supervisor_fully_compliant,
              icon: Icons.check_circle_rounded,
            ),
        ],
      ),
    );
  }
}

class _SupervisorTotalsCard extends StatelessWidget {
  const _SupervisorTotalsCard({required this.periods});

  final List<DriverDieselPeriodStat> periods;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.summarize_rounded,
            title: l10n.supervisor_totals_title,
          ),
          const SizedBox(height: 10),
          ...periods.map(
            (period) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DieselPeriodPanel(period: period, emphasizeSavings: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorAlertsCard extends StatelessWidget {
  const _SupervisorAlertsCard({required this.rows});

  final List<DriverComplianceRow> rows;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.notification_important_rounded,
            title: l10n.area_alerts,
            titleColor: const Color(0xFFC4584A),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF1F6F43)),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.supervisor_no_non_compliant_alerts)),
              ],
            )
          else
            ...rows.map(
              (row) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33C4584A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_rounded, size: 18, color: Color(0xFFC4584A)),
                        const SizedBox(width: 6),
                        Text(
                          '${l10n.driver} ${row.driverId}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC4584A),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _LabelValueRow(
                      label: l10n.driver_compliance_title,
                      value: '${row.compliance.round()}%',
                      icon: Icons.track_changes_rounded,
                    ),
                    const SizedBox(height: 4),
                    for (final String reason in _alertReasons(row, l10n))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 8, color: Color(0xFFC4584A)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(reason)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          PrimaryButton(label: l10n.export_report, onPressed: () {}),
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

  final DriverDieselPeriodStat period;
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
                  litersLabel: l10n.supervisor_liters_label,
                  liters: _liters(period.beforeLiters),
                  costLabel: l10n.supervisor_cost_label,
                  costJod: period.beforeCostJod.toStringAsFixed(2),
                  extraLabel: '100%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DieselCell(
                  title: l10n.after_label,
                  litersLabel: l10n.supervisor_liters_label,
                  liters: _liters(period.afterLiters),
                  costLabel: l10n.supervisor_cost_label,
                  costJod: period.afterCostJod.toStringAsFixed(2),
                  extraLabel: '${_pct1(period.afterCostPctOfBefore)}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DieselCell(
                  title: l10n.supervisor_savings_label,
                  litersLabel: l10n.supervisor_saved_liters_label,
                  liters: _liters(period.savedLiters),
                  costLabel: l10n.supervisor_saved_cost_label,
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

/// Fuel rate L/km (matches provider).
const double _fuelLitersPerKm = 1.26;

/// Day-count mix per period: [low, medium, high]. Daily = 100% MEDIUM; weekly = 2+3+2; monthly = 8+14+8; yearly = 70+190+105.
const List<List<int>> _periodDayMix = <List<int>>[
  <int>[0, 1, 0],   // daily: 1 medium
  <int>[2, 3, 2],   // weekly: 2 low + 3 medium + 2 high
  <int>[8, 14, 8],  // monthly: 8 low + 14 medium + 8 high
  <int>[70, 190, 105], // yearly: 70 low + 190 medium + 105 high
];

/// For truck 1001: each period uses its own scenario mix (not daily × N). Otherwise returns row.dieselByPeriod.
List<DriverDieselPeriodStat> _dieselPeriodStatsForCard(DriverComplianceRow row, int safeTripIndex) {
  if (row.dieselByRound != null && row.dieselByRound!.isNotEmpty) {
    final DriverRoundDieselStat round = row.dieselByRound![safeTripIndex.clamp(0, row.dieselByRound!.length - 1)];
    return List<DriverDieselPeriodStat>.generate(
      DieselPeriod.values.length,
      (int i) {
        final List<int> mix = _periodDayMix[i];
        final int totalDays = mix[0] + mix[1] + mix[2];
        final double beforeLiters = round.beforeLiters * totalDays;
        final double afterKm = round.afterKmForMix(mix[0], mix[1], mix[2]);
        final double afterLiters = afterKm * _fuelLitersPerKm;
        return DriverDieselPeriodStat(
          period: DieselPeriod.values[i],
          beforeLiters: beforeLiters,
          afterLiters: afterLiters,
        );
      },
    );
  }
  return row.dieselByPeriod;
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
    this.valueStyle,
  });

  final String label;
  final String value;
  final IconData? icon;
  final TextStyle? valueStyle;

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
            style: valueStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
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
            '${l10n.supervisor_percent_label}: $extraLabel',
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplianceExplainPanel extends StatelessWidget {
  const _ComplianceExplainPanel({required this.row});

  final DriverComplianceRow row;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0x332D5FA6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.help_outline_rounded,
            title: l10n.supervisor_section_compliance_explanation,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supervisor_score_formula,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _LabelValueRow(
            label: l10n.supervisor_predicted_bins_count,
            value: row.breakdown.predictedTotal.toString(),
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 4),
          _LabelValueRow(
            label: l10n.supervisor_serviced_bins_count,
            value: row.breakdown.servicedTotal.toString(),
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 4),
          _LabelValueRow(
            label: l10n.supervisor_missed_bins_count,
            value: row.breakdown.missedPredicted.toString(),
            icon: Icons.remove_circle_outline_rounded,
          ),
          const SizedBox(height: 8),
          _LabelValueRow(
            label: l10n.supervisor_bin_penalty,
            value: '${_points(row.breakdown.binPenalty)} ${l10n.supervisor_points_unit}',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 4),
          _LabelValueRow(
            label: l10n.supervisor_route_penalty,
            value: '${_points(row.breakdown.routePenalty)} ${l10n.supervisor_points_unit}',
            icon: Icons.alt_route_rounded,
          ),
          const SizedBox(height: 4),
          _LabelValueRow(
            label: l10n.supervisor_app_penalty,
            value: '${_points(row.breakdown.appPenalty)} ${l10n.supervisor_points_unit}',
            icon: Icons.smartphone_rounded,
          ),
          const SizedBox(height: 6),
          _LabelValueRow(
            label: l10n.supervisor_final_result,
            value: '${row.breakdown.finalScore}%',
            icon: Icons.flag_rounded,
            valueStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _complianceColor(row.breakdown.finalScore.toDouble()),
                  fontWeight: FontWeight.w800,
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

String _pct1(double value) => value.toStringAsFixed(1);

String _points(double value) => value.toStringAsFixed(1);

String _liters(double value) {
  final double rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.05) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
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

String _routeDeviationLabel(RouteDeviationLevel level, AppLocalizations l10n) {
  return switch (level) {
    RouteDeviationLevel.none => l10n.supervisor_route_deviation_none,
    RouteDeviationLevel.low => l10n.supervisor_route_deviation_low,
    RouteDeviationLevel.medium => l10n.supervisor_route_deviation_medium,
    RouteDeviationLevel.high => l10n.supervisor_route_deviation_high,
    RouteDeviationLevel.severe => l10n.supervisor_route_deviation_severe,
  };
}

List<String> _alertReasons(DriverComplianceRow row, AppLocalizations l10n) {
  final List<String> reasons = <String>[];
  if (row.breakdown.missedPredicted > 0) {
    reasons.add(l10n.supervisor_alert_reason_missed_bins);
  }
  if (row.breakdown.routePenalty >= 18) {
    reasons.add(l10n.supervisor_alert_reason_route_high);
  } else if (row.breakdown.routePenalty > 0) {
    reasons.add(l10n.supervisor_alert_reason_route_medium);
  }
  if (row.breakdown.appPenalty > 0) {
    reasons.add(l10n.supervisor_alert_reason_app);
  }
  return reasons;
}

String _areaLabelForDriver(String driverId, AppLocalizations l10n) {
  return switch (driverId) {
    '1001' => l10n.area_name_1001,
    '1002' => l10n.area_name_1002,
    '1003' => l10n.area_name_1003,
    '1004' => l10n.area_name_1004,
    '1005' => l10n.area_name_1005,
    '1006' => l10n.area_name_1006,
    _ => l10n.area_name_generic,
  };
}
