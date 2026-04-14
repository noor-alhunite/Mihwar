import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../app/app.dart';
import 'providers/auth_controller.dart';
import '../../shared/providers/language_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_switch_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final bool isLoading = ref.watch(authControllerProvider).isLoading;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<_RoleOption> options = [
      _RoleOption(label: l10n.role_entry_data_truck, userId: 1006, route: AppRoutes.driver, icon: Icons.local_shipping_outlined),
      _RoleOption(label: l10n.role_entry_smart_truck, userId: 1001, route: AppRoutes.driver, icon: Icons.alt_route_rounded),
      _RoleOption(label: l10n.role_entry_area_supervisor, userId: 2001, route: AppRoutes.supervisor, icon: Icons.supervisor_account_rounded),
      _RoleOption(label: l10n.role_entry_governorate, userId: 3001, route: AppRoutes.governorate, icon: Icons.account_balance_rounded),
    ];
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const SizedBox.shrink(),
            actions: const [LanguageSwitchButton()],
          ),
          body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 24),
                  Text(
                    l10n.select_role,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _RoleGrid(
                    options: options,
                    onRoleSelected: (int userId, String route) async {
                      final success = await ref
                          .read(authControllerProvider.notifier)
                          .loginAsDemoUser(userId);
                      if (context.mounted && success) {
                        context.go(route);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x44000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    const double preferredWidth = 880;
    const double preferredHeight = 496;
    final double maxWidth = MediaQuery.sizeOf(context).width - 40;
    final double w = preferredWidth.clamp(0.0, maxWidth);
    final double h = preferredHeight * (w / preferredWidth);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Image.asset(
            'assets/images/mihwar_logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, Object? e, StackTrace? st) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _RoleGrid extends StatelessWidget {
  const _RoleGrid({required this.options, required this.onRoleSelected});

  final List<_RoleOption> options;
  final Future<void> Function(int userId, String route) onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        if (isNarrow) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        option: o,
                        onTap: () => onRoleSelected(o.userId, o.route),
                      ),
                    ))
                .toList(),
          );
        }
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: options
              .map((o) => _RoleCard(
                    option: o,
                    onTap: () => onRoleSelected(o.userId, o.route),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.label,
    required this.userId,
    required this.route,
    required this.icon,
  });
  final String label;
  final int userId;
  final String route;
  final IconData icon;
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.onTap,
  });

  final _RoleOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
