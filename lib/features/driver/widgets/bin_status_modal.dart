import 'package:flutter/material.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../../shared/widgets/primary_button.dart';

enum BinReadingStatus { full, half, empty, broken }

enum BinStatusModalAction { serviced, skipped, dismissed }

class BinStatusModalResult {
  const BinStatusModalResult({
    required this.action,
    this.status,
  });

  final BinStatusModalAction action;
  final BinReadingStatus? status;
}

Future<BinStatusModalResult> showBinStatusModal(BuildContext context) {
  BinReadingStatus? selectedStatus;
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  bool showSuccess = false;

  return showModalBottomSheet<BinStatusModalResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bin Status',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _StatusOption(
                    title: l10n.full,
                    icon: Icons.warning_amber_rounded,
                    selected: selectedStatus == BinReadingStatus.full,
                    onTap: () => setState(() => selectedStatus = BinReadingStatus.full),
                  ),
                  _StatusOption(
                    title: l10n.half,
                    icon: Icons.opacity_rounded,
                    selected: selectedStatus == BinReadingStatus.half,
                    onTap: () => setState(() => selectedStatus = BinReadingStatus.half),
                  ),
                  _StatusOption(
                    title: l10n.empty,
                    icon: Icons.inbox_rounded,
                    selected: selectedStatus == BinReadingStatus.empty,
                    onTap: () => setState(() => selectedStatus = BinReadingStatus.empty),
                  ),
                  _StatusOption(
                    title: l10n.broken,
                    icon: Icons.build_circle_outlined,
                    selected: selectedStatus == BinReadingStatus.broken,
                    onTap: () => setState(() => selectedStatus = BinReadingStatus.broken),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeInOut,
                    child: showSuccess
                        ? Padding(
                            key: const ValueKey('success'),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.6, end: 1),
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInOutBack,
                                builder: (context, value, child) => Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1F6F43),
                                  size: 38,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('none')),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.serviced,
                    onPressed: selectedStatus == null
                        ? null
                        : () async {
                            setState(() => showSuccess = true);
                            await Future<void>.delayed(const Duration(milliseconds: 420));
                            if (context.mounted) {
                              Navigator.of(context).pop(
                                BinStatusModalResult(
                                  action: BinStatusModalAction.serviced,
                                  status: selectedStatus,
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(
                      const BinStatusModalResult(action: BinStatusModalAction.skipped),
                    ),
                    child: Text(l10n.skip),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((value) => value ?? const BinStatusModalResult(action: BinStatusModalAction.dismissed));
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Colors.white,
          ),
          child: AnimatedScale(
            scale: selected ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutBack,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
