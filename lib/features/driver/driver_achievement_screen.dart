import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/donut_chart.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/primary_button.dart';

class DriverAchievementScreen extends StatelessWidget {
  const DriverAchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> items = MockData.statusCounts.entries.toList();
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievement_dashboard),
        actions: const [LanguageSwitchButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    children: [
                      DonutChart(
                        values: items.map((entry) => entry.value.toDouble()).toList(),
                        colors: MockData.chartColors,
                        centerLabel: l10n.today,
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: MockData.chartColors[i % MockData.chartColors.length],
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_localizedStatus(items[i].key, l10n))),
                              Text('${items[i].value}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.highlights,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: MockData.achievementHighlightKeys.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '• ${_localizedHighlight(MockData.achievementHighlightKeys[index], l10n)}',
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: l10n.export_report,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => context.go(AppRoutes.driver),
                          child: Text(l10n.back),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _localizedStatus(String key, AppLocalizations l10n) {
  switch (key) {
    case 'full':
      return l10n.full;
    case 'half':
      return l10n.half;
    case 'empty':
      return l10n.empty;
    case 'broken':
      return l10n.broken;
    default:
      return key;
  }
}

String _localizedHighlight(String key, AppLocalizations l10n) {
  switch (key) {
    case 'route_distance_reduced':
      return l10n.route_distance_reduced;
    case 'estimated_fuel_saved':
      return l10n.estimated_fuel_saved;
    case 'priority_bins_ontime':
      return l10n.priority_bins_ontime;
    default:
      return key;
  }
}
