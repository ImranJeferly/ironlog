import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import 'new_exercise_sheet.dart';

/// Picks an exercise from the library (or creates a brand-new one) and adds
/// it to a running session or, permanently, to a workout template.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({
    super.key,
    this.sessionId,
    this.templateId,
    this.excludeIds = const {},
  }) : assert(sessionId != null || templateId != null);

  final String? sessionId;
  final String? templateId;

  /// Already in the target — hidden from the list.
  final Set<String> excludeIds;

  static Future<void> show(
    BuildContext context, {
    required String sessionId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => ExercisePickerSheet(sessionId: sessionId),
    );
  }

  static Future<void> showForTemplate(
    BuildContext context, {
    required String templateId,
    Set<String> excludeIds = const {},
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => ExercisePickerSheet(
        templateId: templateId,
        excludeIds: excludeIds,
      ),
    );
  }

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  String _query = '';
  MuscleGroup? _group;

  /// Routes the pick to its target: the running session, or the template.
  Future<void> _add(String exerciseId) async {
    final repo = ref.read(workoutRepositoryProvider);
    if (widget.sessionId != null) {
      await repo.addExercise(widget.sessionId!, exerciseId);
    } else if (widget.templateId != null) {
      await repo.addExerciseToTemplate(widget.templateId!, exerciseId);
    }
  }

  Future<void> _createNew() async {
    final created = await NewExerciseSheet.show(context);
    if (created == null || !mounted) return;
    await _add(created.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(allExercisesProvider).value ?? const [];

    final filtered = all.where((e) {
      if (widget.excludeIds.contains(e.id)) return false;
      final matchesQuery =
          _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      final matchesGroup = _group == null || e.muscleGroup == _group;
      return matchesQuery && matchesGroup;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ADD EXERCISE', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      autofocus: false,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Search exercises…',
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: [
                    _chip('All', _group == null, () {
                      setState(() => _group = null);
                    }),
                    for (final group in MuscleGroup.values)
                      _chip(group.label, _group == group, () {
                        setState(() => _group = group);
                      }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  // +1 for the "create your own" row that always leads.
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 6),
                        radius: AppRadii.cardSmall,
                        color: AppColors.voltDim,
                        borderColor: AppColors.volt.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        onTap: _createNew,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: AppColors.volt,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create your own exercise',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(color: AppColors.volt),
                                  ),
                                  Text(
                                    'Saved to your library forever.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.lg),
                        child: EmptyState(
                          title: 'No matches',
                          icon: Icons.search_off,
                        ),
                      );
                    }
                    final exercise = filtered[index - 1];
                    return AppCard(
                            margin: const EdgeInsets.only(bottom: 6),
                            radius: AppRadii.cardSmall,
                            color: AppColors.cardHigh,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            onTap: () async {
                              await _add(exercise.id);
                              if (context.mounted) Navigator.of(context).pop();
                            },
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
                                      Text(
                                        exercise.name,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      Text(
                                        '${exercise.role.label} · '
                                        '${exercise.targetSets}×'
                                        '${exercise.repRangeMin}–'
                                        '${exercise.repRangeMax}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: AppColors.volt,
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
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.volt : AppColors.cardHigh,
            borderRadius: BorderRadius.circular(AppRadii.chip),
            border: Border.all(
              color: active ? AppColors.volt : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.bg : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
