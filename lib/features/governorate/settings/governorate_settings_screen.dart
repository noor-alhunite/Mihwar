import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../../shared/widgets/app_card.dart';

class GovernorateSettingsScreen extends StatelessWidget {
  const GovernorateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.governorate_settings_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.governorate_about_title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text('• ${l10n.governorate_about_threshold}'),
                      const SizedBox(height: 6),
                      Text('• ${l10n.governorate_about_frequency}'),
                      const SizedBox(height: 6),
                      Text('• ${l10n.governorate_about_seasonality}'),
                      const SizedBox(height: 6),
                      Text('• ${l10n.governorate_about_diesel_model}'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(l10n.back),
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
