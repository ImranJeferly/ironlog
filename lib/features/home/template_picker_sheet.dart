import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../session/active_session_screen.dart';
import 'bodyweight_prompt.dart';
import 'template_editor_screen.dart';

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

    // The workout you're here for goes first: the program's next rotation day
    // when a program is active, otherwise today's weekday template.
    final today = DateTime.now().weekday;
    final program = ref.watch(activeProgramProvider);
    final next = ref.watch(nextWorkoutProvider);
    int rank(TemplateRow t) {
      if (t.id == next?.id) return 0;
      if (program != null && program.contains(t.id)) return 1;
      if (program == null && t.weekday == today) return 0;
      return 2;
    }
    final sorted = [...templates]
      ..sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        if (program != null && program.contains(a.id) && program.contains(b.id)) {
          // Keep rotation order within the program, starting from "next".
          final n = program.length;
          final base = next == null ? 0 : program.indexOf(next.id);
          final ai = (program.indexOf(a.id) - base + n) % n;
          final bi = (program.indexOf(b.id) - base + n) % n;
          return ai.compareTo(bi);
        }
        return a.orderIndex.compareTo(b.orderIndex);
      });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('START A SESSION', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.md),
            for (final template in sorted)
              _TemplateRow(
                template: template,
                badge: template.id == next?.id
                    ? (program != null ? 'NEXT' : 'TODAY')
                    : null,
              ),
            const SizedBox(height: AppSpacing.sm),
            GhostButton(
              label: 'Empty session',
              icon: Icons.add,
              expanded: true,
              onPressed: () async {
                await maybePromptBodyweight(context, ref);
                if (!context.mounted) return;
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
  const _TemplateRow({required this.template, this.badge});

  final TemplateRow template;

  /// "NEXT" / "TODAY" for the workout you're here for; null otherwise.
  final String? badge;

  bool get isToday => badge != null;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = _accent(template.accentHex);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      color: AppColors.cardHigh,
      borderColor: isToday ? accent.withValues(alpha: 0.6) : null,
      onTap: () async {
        await maybePromptBodyweight(context, ref);
        if (!context.mounted) return;
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
          if (badge != null)
            VoltBadge(badge!, filled: true)
          else if (template.weekday != null)
            Text(
              _dayNames[template.weekday! - 1],
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(width: 10),
          IconPill(
            icon: Icons.edit_outlined,
            size: 34,
            tooltip: 'Edit this workout',
            onTap: () {
              Navigator.of(context).pop();
              TemplateEditorScreen.open(context, template.id);
            },
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
