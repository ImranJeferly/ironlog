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
    final unit = ref.watch(unitProvider);
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
          _AdherenceCard(consistency: consistency),

          // Steps, water, food, sleep and weight all live in one place —
          // no duplicate tiles fighting for attention.
          const SectionHeader('Daily check-in'),
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
            template?.name ?? 'Rest & recover',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 6),
          if (template != null)
            _PlanLine(template: template!)
          else
            _NextUpLine(),
          const SizedBox(height: AppSpacing.lg),
          if (doneToday)
            GhostButton(
              label: 'Start another workout',
              icon: Icons.add,
              expanded: true,
              height: 52,
              onPressed: () => TemplatePickerSheet.show(context),
            )
          else
            Row(
              children: [
                Expanded(
                  child: VoltButton(
                    label: template == null
                        ? 'Start a session anyway'
                        : 'Start ${template!.name}',
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

/// "6 exercises · 19 sets · Rope 5 min + sauna" — what today actually holds.
class _PlanLine extends ConsumerWidget {
  const _PlanLine({required this.template});

  final TemplateRow template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(templatePlanProvider(template.id)).value;

    final parts = <String>[
      if (plan != null) '${plan.$1} exercises · ${plan.$2} sets',
      if (template.cardioLabel != null) '${template.cardioLabel} + sauna',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(
          Icons.format_list_bulleted,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            parts.join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// On a rest day the card points at what's coming instead of a dead end.
class _NextUpLine extends ConsumerWidget {
  const _NextUpLine();

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final next = ref.watch(nextTemplateProvider);
    if (next == null) {
      return Text(
        'No workouts scheduled — set your training days in Settings.',
        style: theme.textTheme.bodySmall,
      );
    }
    final isTomorrow =
        next.weekday == (DateTime.now().weekday % 7) + 1;
    return Row(
      children: [
        const Icon(
          Icons.event_repeat,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          'Next up: ${next.name} · '
          '${isTomorrow ? 'tomorrow' : _dayNames[next.weekday! - 1]}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('THIS WEEK', style: theme.textTheme.labelSmall),
              ),
              Text(
                '$done of ${consistency?.scheduledPerWeek ?? 4} gym days · '
                '${Fmt.percent(adherence)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: adherence >= 1
                      ? AppColors.volt
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _WeekStrip(consistency: consistency),
        ],
      ),
    );
  }
}

/// The week at a glance: one circle per day — accented ring on gym days,
/// filled tick once that day's session is done, label highlighted for today.
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.consistency});

  final ConsistencyStats? consistency;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider).value ?? const [];
    final byWeekday = {
      for (final t in templates)
        if (t.weekday != null) t.weekday!: t,
    };
    final doneDays = consistency?.setsByDay.keys.toSet() ?? const <DateTime>{};
    final now = DateTime.now();
    final weekStart = now.weekStart;

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _dayCell(
              context,
              letter: _letters[i],
              date: weekStart.add(Duration(days: i)),
              template: byWeekday[i + 1],
              doneDays: doneDays,
              isToday: now.weekday == i + 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _dayCell(
    BuildContext context, {
    required String letter,
    required DateTime date,
    required TemplateRow? template,
    required Set<DateTime> doneDays,
    required bool isToday,
  }) {
    final theme = Theme.of(context);
    final accent = _accent(template?.accentHex);
    final scheduled = template != null;
    final done = doneDays.any((d) => d.isSameDay(date));

    return Column(
      children: [
        Text(
          letter,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: isToday ? AppColors.volt : AppColors.textTertiary,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: done
                ? AppColors.volt.withValues(alpha: 0.18)
                : (scheduled ? AppColors.cardHigh : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: done
                  ? AppColors.volt
                  : (isToday
                        ? AppColors.volt.withValues(alpha: 0.6)
                        : (scheduled
                              ? accent.withValues(alpha: 0.55)
                              : AppColors.border)),
              width: isToday && !done ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 15, color: AppColors.volt)
              : (scheduled
                    ? Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null),
        ),
      ],
    );
  }

  static Color _accent(String? hex) {
    if (hex == null || hex.length < 7) return AppColors.volt;
    final parsed = int.tryParse(hex.substring(1), radix: 16);
    return parsed == null ? AppColors.volt : Color(0xFF000000 | parsed);
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
