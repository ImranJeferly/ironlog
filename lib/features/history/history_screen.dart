import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/heatmap.dart';
import '../progress/exercise_detail_screen.dart';
import '../session/session_summary_screen.dart';

/// Calendar heatmap + the full session list, plus the all-time PR feed.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showPrs = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = ref.watch(recentSessionsProvider).value ?? const [];
    final consistency = ref.watch(consistencyProvider).value;
    final unit = ref.watch(unitProvider);
    final prs = ref.watch(personalRecordsProvider).value ?? const [];

    final completed = sessions.where((s) => s.isComplete).toList();

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
          const BrutalHeader(
            title: 'History',
            eyebrow: 'Every session, every record',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 3, height: 12, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text('CONSISTENCY', style: theme.textTheme.labelSmall),
                    const Spacer(),
                    Text(
                      '${consistency?.totalSessions ?? 0}',
                      style: AppText.numeric(size: 14, letterSpacing: 0),
                    ),
                    Text(' SESSIONS', style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CalendarHeatmap(
                  valuesByDay: consistency?.setsByDay ?? const {},
                  onDayTap: (day, value) => _openDay(day, completed),
                ),
                const SizedBox(height: AppSpacing.sm),
                const HeatmapLegend(),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${consistency?.currentStreak ?? 0}',
                  label: 'Streak',
                  accent: (consistency?.currentStreak ?? 0) > 0
                      ? AppColors.volt
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: Fmt.percent(consistency?.weeklyAdherence ?? 0),
                  label: 'This week',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(value: '${prs.length}', label: 'PRs'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Toggle(
                label: 'Sessions',
                active: !_showPrs,
                onTap: () => setState(() => _showPrs = false),
              ),
              const SizedBox(width: 6),
              _Toggle(
                label: 'PR feed',
                active: _showPrs,
                onTap: () => setState(() => _showPrs = true),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const IronRule(),
          const SizedBox(height: AppSpacing.md),

          if (_showPrs)
            if (prs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyState(
                  title: 'No PRs yet',
                  icon: Icons.bolt,
                  message:
                      'Your first session sets the baseline — records start '
                      'from the second one.',
                ),
              )
            else
              for (final pr in prs) _PrFeedRow(pr: pr, unit: unit)
          else if (completed.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: EmptyState(
                title: 'No sessions yet',
                icon: Icons.calendar_today_outlined,
                message: 'Finished workouts show up here.',
              ),
            )
          else
            for (var i = 0; i < completed.length; i++) ...[
              // A quiet month header whenever the list crosses into a new
              // month — long histories stay scannable.
              if (i == 0 ||
                  completed[i - 1].date.month != completed[i].date.month ||
                  completed[i - 1].date.year != completed[i].date.year)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, 4, 8),
                  child: Text(
                    Dates.monthYear(completed[i].date).toUpperCase(),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              _SessionRow(session: completed[i], unit: unit),
            ],
        ],
      ),
    );
  }

  void _openDay(DateTime day, List<SessionRow> completed) {
    for (final session in completed) {
      if (session.date.isSameDay(day)) {
        SessionSummaryScreen.open(context, session.id);
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No session on ${Dates.dayMonthYear(day)}')),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 16,
            letterSpacing: 1.4,
            height: 1,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session, required this.unit});

  final SessionRow session;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = AppColors.forTemplateName(session.templateName);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      edge: accent,
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      onTap: () => SessionSummaryScreen.open(context, session.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.templateName ?? 'Workout',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Text(
                Dates.relativeDay(session.date).toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Pill(
                icon: Icons.timer_outlined,
                label: Fmt.durationMinutes(session.durationMin),
              ),
              const SizedBox(width: 6),
              _Pill(
                icon: Icons.fitness_center,
                label: '${session.totalSets} sets',
              ),
              const SizedBox(width: 6),
              _Pill(
                icon: Icons.scale_outlined,
                label: Fmt.tonnage(session.tonnageKg, unit),
              ),
              const Spacer(),
              if (session.cardioDone)
                const Icon(
                  Icons.favorite,
                  size: 14,
                  color: AppColors.accent,
                ),
              if (session.saunaDone) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.hot_tub,
                  size: 14,
                  color: AppColors.accent,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardHigh,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: AppText.numeric(
              size: 11,
              letterSpacing: 0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrFeedRow extends ConsumerWidget {
  const _PrFeedRow({required this.pr, required this.unit});

  final PersonalRecordRow pr;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercise = ref.watch(exerciseByIdProvider(pr.exerciseId));
    final improvement = pr.previousValue == null
        ? null
        : pr.value - pr.previousValue!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 6),
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
            child: const Icon(Icons.bolt, color: AppColors.accent, size: 17),
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
                  '${pr.type.label} · ${Dates.dayMonth(pr.achievedAt)}'
                      .toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pr.type == PrType.reps
                    ? '${pr.reps} REPS'
                    : Fmt.weight(pr.value, unit),
                style: AppText.numeric(
                  size: 16,
                  color: AppColors.accent,
                  letterSpacing: 0,
                ),
              ),
              if (improvement != null && improvement > 0)
                Text(
                  pr.type == PrType.reps
                      ? '+${improvement.round()}'
                      : '+${Fmt.weight(improvement, unit)}',
                  style: AppText.numeric(
                    size: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
