import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../data/db/database.dart';
import '../../widgets/app_card.dart';
import 'exercise_detail_screen.dart';

/// Every exercise, most recently trained first. Tap through for charts.
class ExercisesTab extends ConsumerWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final index = ref.watch(exerciseIndexProvider).value ?? const [];

    if (index.isEmpty) {
      return const EmptyState(
        title: 'No exercises yet',
        message: 'Start a session — everything you log shows up here.',
      );
    }

    final trained = index.where((e) => e.$3 > 0).toList();
    final untouched = index.where((e) => e.$3 == 0).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        for (final row in trained) _ExerciseRow(row: row),
        if (untouched.isNotEmpty) ...[
          SectionHeader(
            'Not logged yet',
            trailing: Text(
              '${untouched.length}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          for (final row in untouched) _ExerciseRow(row: row),
        ],
      ],
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.row});

  final (ExerciseRow, DateTime?, int) row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = row.$1;
    final lastTrained = row.$2;
    final setCount = row.$3;
    final color =
        AppColors.muscleColors[exercise.muscleGroup.key] ?? AppColors.volt;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 6),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      onTap: () =>
          ExerciseDetailScreen.open(context, exercise.id),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: setCount > 0 ? color : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  lastTrained == null
                      ? '${exercise.targetSets}×${exercise.repRangeMin}–${exercise.repRangeMax}'
                      : '$setCount sets · ${Dates.relativeDay(lastTrained)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 13,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
