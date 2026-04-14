import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';
import '../../shared/widgets/primary_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.select_role,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const LanguageSwitchButton(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.choose_access_level,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: Text(l10n.open_login_screen),
                          ),
                          const SizedBox(height: 14),
                          PrimaryButton(
                            label: l10n.driver,
                            onPressed: () => context.go(AppRoutes.driver),
                          ),
                          const SizedBox(height: 14),
                          PrimaryButton(
                            label: l10n.supervisor,
                            onPressed: () => context.go(AppRoutes.supervisor),
                          ),
                          const SizedBox(height: 14),
                          PrimaryButton(
                            label: l10n.governorate_manager,
                            onPressed: () => context.go(AppRoutes.governorate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
