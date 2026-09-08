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
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';
import '../progress/exercise_detail_screen.dart';
import '../session/active_session_screen.dart';
import 'bodyweight_prompt.dart';
import 'daily_metrics_card.dart';
import 'template_picker_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final active = ref.watch(activeSessionProvider).value;
    final todayTemplate = ref.watch(nextWorkoutProvider);
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
          96,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Dates.weekdayLong(now).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Dates.dayMonthYear(now),
                      style: theme.textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              _StreakBlock(streak: consistency?.currentStreak ?? 0),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const IronRule(),
          const SizedBox(height: AppSpacing.md),

          if (active != null)
            _ResumeCard(session: active)
          else
            _TodayWorkoutCard(template: todayTemplate),

          const SizedBox(height: AppSpacing.md),
          _AdherenceCard(consistency: consistency),
          const _DeloadBanner(),

          // Steps, water, food, sleep and weight all live in one place —
          // no duplicate tiles fighting for attention.
          const SectionHeader('Daily check-in'),
          const DailyMetricsCard(),

          if (prs.isNotEmpty) ...[
            SectionHeader(
              'Recent PRs',
              trailing: Text(
                '${prs.length}',
                style: AppText.numeric(
                  size: 13,
                  color: AppColors.textTertiary,
                  letterSpacing: 0,
                ),
              ),
            ),
            for (final pr in prs.take(3)) _PrRow(pr: pr, unit: unit),
          ],
        ],
      ),
    );
  }
}

/// Suggests a deload week when the calendar or the numbers call for one.
/// One tap applies it to the next six sessions (half the sets, −10 % load).
class _DeloadBanner extends ConsumerWidget {
  const _DeloadBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = ref.watch(deloadRecommendationProvider).value;
    if (rec == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppCard(
        edge: AppColors.ember,
        borderColor: AppColors.ember.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.battery_alert_outlined,
                  size: 18,
                  color: AppColors.ember,
                ),
                const SizedBox(width: 8),
                Text(
                  'DELOAD WEEK SUGGESTED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.ember,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(rec.reason, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Same exercises, half the sets, 10 % lighter — for the next '
              '6 sessions.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Not now',
                    expanded: true,
                    onPressed: () async {
                      await ref.read(workoutRepositoryProvider).dismissDeload();
                      ref.invalidate(deloadRecommendationProvider);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: VoltButton(
                    label: 'Apply deload',
                    icon: Icons.check_rounded,
                    height: 48,
                    color: AppColors.ember,
                    foreground: AppColors.bg,
                    onPressed: () async {
                      await ref.read(workoutRepositoryProvider).applyDeload();
                      ref.invalidate(deloadRecommendationProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Deload on: next 6 sessions run lighter.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak counter as a stamped block: big numeral, caps label under it.
class _StreakBlock extends StatelessWidget {
  const _StreakBlock({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final hot = streak > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: hot ? AppColors.voltDim : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: hot ? AppColors.accent : AppColors.borderStrong,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: hot ? AppColors.accent : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: AppText.numeric(
                  size: 22,
                  color: hot ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'STREAK',
            style: AppText.eyebrow(
              size: 11,
              color: hot ? AppColors.accent : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero: what you're training next and the button that starts it.
class _TodayWorkoutCard extends ConsumerWidget {
  const _TodayWorkoutCard({required this.template});

  final TemplateRow? template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final program = ref.watch(activeProgramProvider);
    final deload = ref.watch(settingsProvider).deloadActive;
    final sessions = ref.watch(recentSessionsProvider).value ?? const [];
    final doneToday = sessions.any(
      (s) => s.isComplete && s.date.isSameDay(DateTime.now()),
    );
    final accent = doneToday ? AppColors.textSecondary : AppColors.accent;
    final title = template?.name ?? 'Rest & recover';

    return SteelPanel(
      accent: accent,
      stencil: _stencilFor(template),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  doneToday
                      ? 'DONE TODAY'
                      : (template == null
                            ? 'REST DAY'
                            : (program != null
                                  ? 'NEXT UP · ${program.name.toUpperCase()}'
                                  : 'TODAY’S SESSION')),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontSize: 14,
                  ),
                ),
              ),
              if (deload && !doneToday)
                const VoltBadge('DELOAD', color: AppColors.ember)
              else if (doneToday)
                const VoltBadge('COMPLETE', icon: Icons.check, filled: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          if (template != null)
            _PlanLine(template: template!)
          else
            const _NextUpLine(),
          const SizedBox(height: AppSpacing.lg),
          if (doneToday)
            GhostButton(
              label: 'Start another workout',
              icon: Icons.add,
              expanded: true,
              height: 52,
              color: AppColors.textPrimary,
              onPressed: () => TemplatePickerSheet.show(context),
            )
          else
            Row(
              children: [
                Expanded(
                  child: VoltButton(
                    label: template == null
                        ? 'Start a workout'
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
                  color: AppColors.textPrimary,
                  onTap: () => TemplatePickerSheet.show(context),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// "PUSH", "PULL", "LEGS", "REST" — the first word, poster-sized.
  static String _stencilFor(TemplateRow? template) {
    final name = template?.name;
    if (name == null || name.isEmpty) return 'REST';
    return name.split(' ').first;
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
    await maybePromptBodyweight(context, ref);
    if (!context.mounted) return;
    final id = await ref
        .read(workoutRepositoryProvider)
        .startSessionFromTemplate(template.id);
    if (!context.mounted) return;
    await ActiveSessionScreen.open(context, id);
  }
}

/// "6 exercises · 19 sets · Rope 5 min + sauna" — what today actually holds.
class _PlanLine extends ConsumerWidget {
  const _PlanLine({required this.template});

  final TemplateRow template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(templatePlanProvider(template.id));

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

    return SteelPanel(
      stencil: 'LIVE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _LiveDot(),
              const SizedBox(width: 8),
              Text(
                'IN PROGRESS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                Fmt.duration(elapsed),
                style: AppText.numeric(
                  size: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
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

/// Pulsing red square — "recording".
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
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
    final target = consistency?.scheduledPerWeek ?? 6;
    final adherence = consistency?.weeklyAdherence ?? 0.0;
    final streak = consistency?.currentStreak ?? 0;
    final fourWeek = consistency?.fourWeekAdherence ?? 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'THIS WEEK',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$done',
                      style: AppText.numeric(
                        size: 20,
                        color: adherence >= 1
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' / $target',
                      style: AppText.numeric(
                        size: 14,
                        color: AppColors.textTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                    TextSpan(
                      text: '  ${Fmt.percent(adherence)}',
                      style: AppText.eyebrow(
                        size: 13,
                        color: adherence >= 1
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _WeekStrip(consistency: consistency),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ConsistencyStat(
                  value: '$streak',
                  label: 'session streak',
                  accent: streak >= target ? AppColors.accent : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ConsistencyStat(
                  value: Fmt.percent(fourWeek),
                  label: '4-week adherence',
                  accent: fourWeek >= 1 ? AppColors.accent : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ConsistencyStat(
                  value: '${consistency?.sessionsLast4Weeks ?? 0}',
                  label: 'last 28 days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact value + caption used under the week strip.
class _ConsistencyStat extends StatelessWidget {
  const _ConsistencyStat({
    required this.value,
    required this.label,
    this.accent,
  });

  final String value;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppText.numeric(
            size: 22,
            color: accent ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

/// The week at a glance: one square per day — outlined on gym days, filled
/// red once that day's session is done, today marked in bone white.
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
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _dayCell(
              context,
              letter: _letters[i],
              date: weekStart.add(Duration(days: i)),
              scheduled: byWeekday.containsKey(i + 1),
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
    required bool scheduled,
    required Set<DateTime> doneDays,
    required bool isToday,
  }) {
    final done = doneDays.any((d) => d.isSameDay(date));
    final past = date.isBefore(DateTime.now().dayStart);

    return Column(
      children: [
        Text(
          letter,
          style: AppText.eyebrow(
            size: 12,
            letterSpacing: 0,
            color: isToday ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: done
                ? AppColors.accent
                : (scheduled ? AppColors.cardHigh : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadii.chip),
            border: Border.all(
              color: done
                  ? AppColors.accent
                  : (isToday
                        ? AppColors.textPrimary
                        : (scheduled
                              ? AppColors.borderStrong
                              : AppColors.border)),
              width: isToday && !done ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 16, color: AppColors.textPrimary)
              : (past && scheduled
                    ? Container(
                        width: 10,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.steel,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    : (scheduled
                          ? Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null)),
        ),
      ],
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
      edge: AppColors.accent,
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      onTap: exercise == null
          ? null
          : () => ExerciseDetailScreen.open(context, exercise.id),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.voltDim,
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(Icons.bolt, color: AppColors.accent, size: 18),
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
                const SizedBox(height: 2),
                Text(
                  '${pr.type.label} · ${Dates.relativeDay(pr.achievedAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            pr.type == PrType.reps
                ? '${pr.reps} REPS'
                : Fmt.weight(pr.value, unit),
            style: AppText.numeric(size: 17, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
