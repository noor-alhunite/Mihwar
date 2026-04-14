import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/mock/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/primary_button.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driver_profile),
        actions: const [LanguageSwitchButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      MockData.driverName.substring(0, 1),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    MockData.driverName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    MockData.areaName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  _ProfileRow(label: l10n.truck, value: MockData.truckName),
                  const SizedBox(height: 8),
                  _ProfileRow(label: l10n.shift, value: l10n.morning_shift),
                  const SizedBox(height: 8),
                  _ProfileRow(label: l10n.contact, value: '+964 770 000 1234'),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: l10n.back_to_driver_dashboard,
                    onPressed: () => context.go(AppRoutes.driver),
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
