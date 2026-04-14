import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../providers/language_provider.dart';

class LanguageSwitchButton extends ConsumerWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(languageProvider);
    final bool isArabic = locale.languageCode == 'ar';
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.language,
      child: TextButton.icon(
        onPressed: () => ref.read(languageProvider.notifier).toggle(),
        icon: const Icon(Icons.language, size: 18),
        label: Text(isArabic ? 'EN' : 'AR'),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
