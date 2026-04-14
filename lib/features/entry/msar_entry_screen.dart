import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../app/app.dart';
import '../../shared/widgets/language_switch_button.dart';

class MsarEntryScreen extends StatelessWidget {
  const MsarEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mihwar'),
        actions: const [LanguageSwitchButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.msar_branding_title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.msar_branding_subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 72,
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.beforeStudy),
                    child: Text(
                      l10n.before_label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 72,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      l10n.after_label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
