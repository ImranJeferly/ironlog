import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'START A SESSION',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const IronRule(),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < sorted.length; i++)
                  _TemplateRow(
                    index: i + 1,
                    template: sorted[i],
                    badge: sorted[i].id == next?.id
                        ? (program != null ? 'NEXT' : 'TODAY')
                        : null,
                  ),
                const SizedBox(height: AppSpacing.sm),
                GhostButton(
                  label: 'Empty session',
                  icon: Icons.add,
                  expanded: true,
                  color: AppColors.textPrimary,
                  onPressed: () async {
                    await maybePromptBodyweight(context, ref);
                    if (!context.mounted) return;
                    final id = await ref
                        .read(workoutRepositoryProvider)
                        .startEmptySession();
                    unawaited(
                      ref.read(socialHooksProvider).sessionStarted('Freestyle'),
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    await ActiveSessionScreen.open(context, id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends ConsumerWidget {
  const _TemplateRow({
    required this.index,
    required this.template,
    this.badge,
  });

  final int index;
  final TemplateRow template;

  /// "NEXT" / "TODAY" for the workout you're here for; null otherwise.
  final String? badge;

  bool get isToday => badge != null;

  static const _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = AppColors.forTemplateName(template.name);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      color: isToday ? AppColors.cardHigh : AppColors.card,
      borderColor: isToday ? accent.withValues(alpha: 0.7) : null,
      edge: accent,
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      onTap: () async {
        await maybePromptBodyweight(context, ref);
        if (!context.mounted) return;
        final id = await ref
            .read(workoutRepositoryProvider)
            .startSessionFromTemplate(template.id);
        unawaited(ref.read(socialHooksProvider).sessionStarted(template.name));
        if (!context.mounted) return;
        Navigator.of(context).pop();
        await ActiveSessionScreen.open(context, id);
      },
      child: Row(
        children: [
          IndexTag(index, color: isToday ? accent : AppColors.textTertiary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: theme.textTheme.headlineSmall),
                if (template.cardioLabel != null)
                  Text(
                    template.cardioLabel!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (badge != null)
            VoltBadge(badge!, filled: true, color: accent)
          else if (template.weekday != null)
            Text(
              _dayNames[template.weekday! - 1],
              style: theme.textTheme.labelSmall,
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
}
