import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../session/active_session_screen.dart';

/// "Pick a template or start empty" — the entry point to every session.
class TemplatePickerSheet extends ConsumerWidget {
  const TemplatePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => const TemplatePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(templatesProvider).value ?? const [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('START A SESSION', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.md),
            for (final template in templates)
              _TemplateRow(template: template),
            const SizedBox(height: AppSpacing.sm),
            GhostButton(
              label: 'Empty session',
              icon: Icons.add,
              expanded: true,
              onPressed: () async {
                final id = await ref
                    .read(workoutRepositoryProvider)
                    .startEmptySession();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                await ActiveSessionScreen.open(context, id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateRow extends ConsumerWidget {
  const _TemplateRow({required this.template});

  final TemplateRow template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = _accent(template.accentHex);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      color: AppColors.cardHigh,
      onTap: () async {
        final id = await ref
            .read(workoutRepositoryProvider)
            .startSessionFromTemplate(template.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        await ActiveSessionScreen.open(context, id);
      },
      child: Row(
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: theme.textTheme.titleMedium),
                if (template.cardioLabel != null)
                  Text(
                    template.cardioLabel!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  static Color _accent(String? hex) {
    if (hex == null || hex.length < 7) return AppColors.volt;
    final parsed = int.tryParse(hex.substring(1), radix: 16);
    return parsed == null ? AppColors.volt : Color(0xFF000000 | parsed);
  }
}
