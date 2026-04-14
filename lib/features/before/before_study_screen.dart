import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../app/app.dart';
import '../../shared/widgets/language_switch_button.dart';

class BeforeStudyScreen extends StatelessWidget {
  const BeforeStudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.before_study_title),
        actions: const [LanguageSwitchButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.before_study_placeholder,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.roleSelection),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
