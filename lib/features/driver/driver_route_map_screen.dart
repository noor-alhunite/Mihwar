import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'widgets/bin_status_modal.dart';

class DriverRouteMapScreen extends StatelessWidget {
  const DriverRouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MockBinStop> stops = MockData.todayRouteStops;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today_route),
        actions: const [LanguageSwitchButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFEAF1EC),
                      ),
                    ),
                    Positioned(
                      top: 22,
                      left: 24,
                      right: 24,
                      child: Container(
                        height: 3,
                        color: const Color(0xFF1F6F43),
                      ),
                    ),
                    for (int i = 0; i < stops.length; i++)
                      Positioned(
                        top: 14 + (i * 48),
                        left: 20 + (i * 30),
                        child: _MapPin(label: stops[i].label),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.planned_stops,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          final MockBinStop stop = stops[index];
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                child: Text('${index + 1}'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${stop.label} • ${l10n.percent_full((stop.fillLevel * 100).round())}',
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemCount: stops.length,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: l10n.end_trip,
                      onPressed: () => context.go(AppRoutes.driver),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showBinStatusModal(context);
        },
        label: Text(l10n.bin_status),
        icon: const Icon(Icons.fact_check_outlined),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFF1F6F43), size: 20),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
