import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../widgets/app_card.dart';
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
    final accent = _accent(template?.accentHex);

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
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconPill(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 4,
                    height: 24,
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
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          '${rows.length} exercises — changes apply to '
                          'future sessions',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? const EmptyState(
                      title: 'No exercises yet',
                      icon: Icons.fitness_center,
                      message: 'Add your first exercise below.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        120,
                      ),
                      itemCount: rows.length,
                      itemBuilder: (context, i) {
                        final (link, exercise) = rows[i];
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          radius: AppRadii.cardSmall,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      AppColors.muscleColors[exercise
                                          .muscleGroup
                                          .key] ??
                                      AppColors.volt,
                                ),
                              ),
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
                                    Text(
                                      '${link.setsOverride ?? exercise.targetSets}×'
                                      '${exercise.repRangeMin}–'
                                      '${exercise.repRangeMax} · '
                                      '${exercise.muscleGroup.label}',
                                      style: theme.textTheme.bodySmall,
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

  static Color _accent(String? hex) {
    if (hex == null || hex.length < 7) return AppColors.volt;
    final parsed = int.tryParse(hex.substring(1), radix: 16);
    return parsed == null ? AppColors.volt : Color(0xFF000000 | parsed);
  }
}
