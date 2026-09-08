import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../domain/enums.dart';
import '../../domain/session_view.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';

/// Post-workout wrap-up: duration, tonnage, PRs, and the day-complete tick.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({
    super.key,
    required this.sessionId,
    this.isCelebration = true,
  });

  final String sessionId;
  final bool isCelebration;

  /// Replaces the active-session route so back doesn't return to logging.
  static Future<void> openReplacing(BuildContext context, String sessionId) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(sessionId: sessionId),
      ),
    );
  }

  static Future<void> open(BuildContext context, String sessionId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(
          sessionId: sessionId,
          isCelebration: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(sessionViewProvider(sessionId)).value;
    final unit = ref.watch(unitProvider);

    if (view == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: EmptyState(title: 'Session not found')),
      );
    }

    final session = view.session;
    final duration = session.endedAt == null
        ? view.elapsed
        : session.endedAt!.difference(session.startedAt);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(isCelebration ? 'Session complete' : view.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          SteelPanel(
            stencil: isCelebration ? 'DONE' : view.title.split(' ').first,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      color: AppColors.accent,
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Dates.relativeDay(session.date).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                    ),
                    if (session.durationSuspect) ...[
                      const Spacer(),
                      const VoltBadge('DURATION CAPPED', color: AppColors.ember),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(view.title, style: theme.textTheme.displaySmall),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        value: Fmt.duration(duration),
                        label: 'Duration',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        value: Fmt.tonnage(view.tonnageKg, unit),
                        label: 'Tonnage',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        value: '${view.totalSets}',
                        label: 'Sets',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        value: '${view.prCount}',
                        label: 'PRs',
                        accent: view.prCount > 0 ? AppColors.accent : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: VoltCheck(
                  value: session.cardioDone,
                  icon: Icons.favorite_outline,
                  label: 'Cardio',
                  onChanged: (v) => ref
                      .read(workoutRepositoryProvider)
                      .setCardioDone(sessionId, v),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: VoltCheck(
                  value: session.saunaDone,
                  icon: Icons.hot_tub_outlined,
                  label: 'Sauna',
                  onChanged: (v) => ref
                      .read(workoutRepositoryProvider)
                      .setSaunaDone(sessionId, v),
                ),
              ),
            ],
          ),

          if (view.prCount > 0) ...[
            const SectionHeader('Records broken'),
            for (final exercise in view.exercises)
              for (final set in exercise.sets.where((s) => s.isPr))
                AppCard(
                  margin: const EdgeInsets.only(bottom: 6),
                  radius: AppRadii.cardSmall,
                  edge: AppColors.accent,
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        Fmt.setSummary(set.weightKg, set.reps, unit),
                        style: AppText.numeric(
                          size: 16,
                          color: AppColors.accent,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
          ],

          const SectionHeader('What you did'),
          for (final (i, exercise) in view.exercises.indexed)
            if (exercise.sets.isNotEmpty)
              _ExerciseSummary(index: i + 1, exercise: exercise, unit: unit),

          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SectionHeader('Notes'),
            AppCard(
              child: Text(
                session.notes!,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          VoltButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, this.accent});

  final String value;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppText.numeric(
              size: 20,
              color: accent ?? AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

class _ExerciseSummary extends StatelessWidget {
  const _ExerciseSummary({
    required this.index,
    required this.exercise,
    required this.unit,
  });

  final int index;
  final SessionExerciseView exercise;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      edge: AppColors.muscleColors[exercise.muscleGroup.key],
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IndexTag(index, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise.name,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                Fmt.tonnage(exercise.tonnageKg, unit),
                style: AppText.numeric(
                  size: 13,
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final set in exercise.sets)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: set.isPr ? AppColors.voltDim : AppColors.cardHigh,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    border: Border.all(
                      color: set.isPr ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${Fmt.weight(set.weightKg, unit, withUnit: false)}×${set.reps}',
                    style: AppText.numeric(
                      size: 12.5,
                      letterSpacing: 0,
                      color: set.isPr
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
