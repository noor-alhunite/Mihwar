import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/primary_button.dart';

class DriverMapStartScreen extends StatelessWidget {
  const DriverMapStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.start_trip),
        actions: const [LanguageSwitchButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.trip_ready,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${MockData.areaName} • ${MockData.truckName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.priority_bins_today(MockData.todayRouteStops.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.start_trip,
                    onPressed: () => context.go(AppRoutes.driverRouteMap),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
