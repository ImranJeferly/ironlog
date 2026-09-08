import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../domain/exercise_x.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';
import '../session/exercise_picker_sheet.dart';

/// Edit a workout for good: add library or custom exercises, drop the ones
/// you don't do. Every change is permanent and synced — future sessions
/// start from exactly this list.
class TemplateEditorScreen extends ConsumerWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final String templateId;

  static Future<void> open(BuildContext context, String templateId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TemplateEditorScreen(templateId: templateId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(templatesProvider).value ?? const [];
    TemplateRow? template;
    for (final t in templates) {
      if (t.id == templateId) {
        template = t;
        break;
      }
    }
    final rows =
        ref.watch(templateExercisesProvider(templateId)).value ?? const [];
    final accent = AppColors.forTemplateName(template?.name);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconPill(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template?.name ?? 'Workout',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          rows.isEmpty
                              ? 'Changes apply to future sessions'
                              : '${rows.length} exercises · drag to reorder',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: IronRule(),
            ),
            Expanded(
              child: rows.isEmpty
                  ? const EmptyState(
                      title: 'No exercises yet',
                      icon: Icons.fitness_center,
                      message: 'Add your first exercise below.',
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        120,
                      ),
                      // We supply our own drag handle so the whole card isn't
                      // a long-press target (the × still needs plain taps).
                      buildDefaultDragHandles: false,
                      itemCount: rows.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final ids = [for (final (l, _) in rows) l.id];
                        ids.insert(newIndex, ids.removeAt(oldIndex));
                        ref
                            .read(workoutRepositoryProvider)
                            .reorderTemplateExercises(ids);
                      },
                      itemBuilder: (context, i) {
                        final (link, exercise) = rows[i];
                        final muscle =
                            AppColors.muscleColors[exercise.muscleGroup.key] ??
                            AppColors.accent;
                        return AppCard(
                          key: ValueKey(link.id),
                          margin: const EdgeInsets.only(bottom: 6),
                          radius: AppRadii.cardSmall,
                          edge: muscle,
                          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                index: i,
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.drag_indicator,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              IndexTag(i + 1),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            exercise.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        if (exercise.isCustom) ...[
                                          const SizedBox(width: 6),
                                          const VoltBadge('YOURS'),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          '${link.setsOverride ?? exercise.targetSets}×'
                                          '${link.repMinOverride ?? exercise.repRangeMin}–'
                                          '${link.repMaxOverride ?? exercise.repRangeMax}',
                                          style: AppText.numeric(
                                            size: 12.5,
                                            color: AppColors.textSecondary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                        Text(
                                          '  ·  ${exercise.primary.label}'
                                          '${exercise.secondary == null ? '' : ' + ${exercise.secondary!.label}'}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconPill(
                                icon: Icons.close,
                                size: 34,
                                tooltip: 'Remove from workout',
                                onTap: () => _remove(context, ref, link),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: VoltButton(
            label: 'Add exercise',
            icon: Icons.add,
            onPressed: () => ExercisePickerSheet.showForTemplate(
              context,
              templateId: templateId,
              excludeIds: {for (final (_, e) in rows) e.id},
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    TemplateExerciseRow link,
  ) async {
    await ref
        .read(workoutRepositoryProvider)
        .removeExerciseFromTemplate(link.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed — future sessions skip it.')),
      );
    }
  }
}
