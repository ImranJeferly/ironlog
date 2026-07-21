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
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderColor: AppColors.volt.withValues(alpha: 0.4),
            gradient: const LinearGradient(
              colors: [Color(0xFF1C2109), AppColors.card],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.volt,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Dates.relativeDay(session.date).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.volt,
                      ),
                    ),
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
                        accent: view.prCount > 0 ? AppColors.volt : null,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.volt, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        Fmt.setSummary(set.weightKg, set.reps, unit),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.volt,
                        ),
                      ),
                    ],
                  ),
                ),
          ],

          const SectionHeader('What you did'),
          for (final exercise in view.exercises)
            if (exercise.sets.isNotEmpty)
              _ExerciseSummary(exercise: exercise, unit: unit),

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
            style: theme.textTheme.titleMedium?.copyWith(color: accent),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _ExerciseSummary extends StatelessWidget {
  const _ExerciseSummary({required this.exercise, required this.unit});

  final SessionExerciseView exercise;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                Fmt.tonnage(exercise.tonnageKg, unit),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: set.isPr ? AppColors.volt : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${Fmt.weight(set.weightKg, unit, withUnit: false)}×${set.reps}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: set.isPr
                          ? AppColors.volt
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
