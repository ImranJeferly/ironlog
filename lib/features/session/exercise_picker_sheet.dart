import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';

/// Adds an exercise to a running session, searchable and grouped by muscle.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({super.key, required this.sessionId});

  final String sessionId;

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

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  String _query = '';
  MuscleGroup? _group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(allExercisesProvider).value ?? const [];

    final filtered = all.where((e) {
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
                child: filtered.isEmpty
                    ? const EmptyState(
                        title: 'No matches',
                        icon: Icons.search_off,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final exercise = filtered[i];
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 6),
                            radius: AppRadii.cardSmall,
                            color: AppColors.cardHigh,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            onTap: () async {
                              await ref
                                  .read(workoutRepositoryProvider)
                                  .addExercise(widget.sessionId, exercise.id);
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
