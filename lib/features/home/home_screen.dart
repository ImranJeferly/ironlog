import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../data/db/database.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../progress/exercise_detail_screen.dart';
import '../session/active_session_screen.dart';
import 'daily_metrics_card.dart';
import 'template_picker_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final active = ref.watch(activeSessionProvider).value;
    final todayTemplate = ref.watch(todayTemplateProvider);
    final consistency = ref.watch(consistencyProvider).value;
    final metrics = ref.watch(todayMetricsProvider).value;
    final unit = ref.watch(unitProvider);
    final stepGoal = ref.watch(settingsProvider).stepGoal;
    final prs = ref.watch(personalRecordsProvider).value ?? const [];
    final now = DateTime.now();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Dates.weekdayLong(now).toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Dates.dayMonthYear(now),
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              _StreakChip(streak: consistency?.currentStreak ?? 0),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (active != null)
            _ResumeCard(session: active)
          else
            _TodayWorkoutCard(template: todayTemplate),

          const SizedBox(height: AppSpacing.md),

          // Quick glance row — workout done?, steps, water, weight.
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.directions_walk,
                  value: metrics?.steps == null
                      ? '—'
                      : Fmt.count(metrics!.steps!),
                  label: 'Steps / ${Fmt.count(stepGoal)}',
                  accent: (metrics?.steps ?? 0) >= stepGoal
                      ? AppColors.volt
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  icon: Icons.local_drink_outlined,
                  value: Fmt.water(metrics?.waterMl ?? 0),
                  label: 'Water',
                  accent: (metrics?.waterMl ?? 0) >= 2000
                      ? AppColors.volt
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  icon: Icons.monitor_weight_outlined,
                  value: metrics?.weightKg == null
                      ? '—'
                      : Fmt.weight(metrics!.weightKg!, unit, withUnit: false),
                  label: 'Weight ${unit.label}',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          _AdherenceCard(consistency: consistency),

          const SectionHeader('Today'),
          const DailyMetricsCard(),

          if (prs.isNotEmpty) ...[
            SectionHeader(
              'Recent PRs',
              trailing: Text(
                '${prs.length}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            for (final pr in prs.take(3)) _PrRow(pr: pr, unit: unit),
          ],
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final hot = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: hot ? AppColors.voltDim : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: hot ? AppColors.volt : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 17,
            color: hot ? AppColors.volt : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: hot ? AppColors.volt : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero card: what you're training today and the button that starts it.
class _TodayWorkoutCard extends ConsumerWidget {
  const _TodayWorkoutCard({required this.template});

  final TemplateRow? template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = _accentOf(template);
    final sessions = ref.watch(recentSessionsProvider).value ?? const [];
    final doneToday = sessions.any(
      (s) => s.isComplete && s.date.isSameDay(DateTime.now()),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gradient: LinearGradient(
        colors: [accent.withValues(alpha: 0.16), AppColors.card],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: accent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                doneToday
                    ? 'DONE TODAY'
                    : (template == null ? 'REST DAY' : 'TODAY’S SESSION'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: doneToday ? AppColors.volt : accent,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              if (doneToday)
                const VoltBadge('COMPLETE', icon: Icons.check, filled: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            template?.name ?? 'No workout scheduled',
            style: theme.textTheme.displaySmall,
          ),
          if (template?.cardioLabel != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.favorite_outline,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${template!.cardioLabel} + Sauna',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: VoltButton(
                  label: template == null ? 'Start a session' : 'Start ${template!.name}',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => _start(context, ref, template),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconPill(
                icon: Icons.more_horiz,
                size: 56,
                tooltip: 'Pick another workout',
                background: AppColors.cardHigh,
                onTap: () => TemplatePickerSheet.show(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    TemplateRow? template,
  ) async {
    if (template == null) {
      await TemplatePickerSheet.show(context);
      return;
    }
    final id = await ref
        .read(workoutRepositoryProvider)
        .startSessionFromTemplate(template.id);
    if (!context.mounted) return;
    await ActiveSessionScreen.open(context, id);
  }

  static Color _accentOf(TemplateRow? template) {
    final hex = template?.accentHex;
    if (hex == null || hex.length < 7) return AppColors.volt;
    final parsed = int.tryParse(hex.substring(1), radix: 16);
    return parsed == null ? AppColors.volt : Color(0xFF000000 | parsed);
  }
}

/// Shown in place of the start card while a session is in progress.
class _ResumeCard extends ConsumerWidget {
  const _ResumeCard({required this.session});

  final SessionRow session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final elapsed = DateTime.now().difference(session.startedAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: AppColors.volt,
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
              Text(
                'IN PROGRESS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.volt,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(Fmt.duration(elapsed), style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.templateName ?? 'Workout',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          VoltButton(
            label: 'Resume session',
            icon: Icons.play_arrow_rounded,
            onPressed: () => ActiveSessionScreen.open(context, session.id),
          ),
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.consistency});

  final ConsistencyStats? consistency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = consistency?.sessionsThisWeek ?? 0;
    final adherence = consistency?.weeklyAdherence ?? 0.0;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THIS WEEK', style: theme.textTheme.labelSmall),
                const SizedBox(height: 6),
                Text(
                  '$done of 3 gym days',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: adherence),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: AppColors.cardHigh,
                      valueColor: const AlwaysStoppedAnimation(AppColors.volt),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            Fmt.percent(adherence),
            style: theme.textTheme.displaySmall?.copyWith(
              color: adherence >= 1 ? AppColors.volt : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrRow extends ConsumerWidget {
  const _PrRow({required this.pr, required this.unit});

  final PersonalRecordRow pr;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercise = ref.watch(exerciseByIdProvider(pr.exerciseId));

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: exercise == null
          ? null
          : () => ExerciseDetailScreen.open(context, exercise.id),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.voltDim,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.bolt, color: AppColors.volt, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise?.name ?? 'Exercise',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${pr.type.label} · ${Dates.relativeDay(pr.achievedAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            pr.type == PrType.reps
                ? '${pr.reps} reps'
                : Fmt.weight(pr.value, unit),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.volt,
            ),
          ),
        ],
      ),
    );
  }
}
