import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/charts.dart';

/// Weekly sets per muscle group, volume trend, and the "least trained" flag.
class MuscleGroupsTab extends ConsumerWidget {
  const MuscleGroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(muscleSummaryProvider).value;
    final unit = ref.watch(unitProvider);

    if (summary == null || summary.totalSets == 0) {
      return const EmptyState(
        title: 'No volume yet',
        icon: Icons.pie_chart_outline,
        message: 'Finish a session to see how your volume is distributed.',
      );
    }

    final weeklyTotals = summary.weeks
        .map((w) => w.totalSets.toDouble())
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        if (summary.leastTrained != null)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            borderColor: AppColors.warning.withValues(alpha: 0.4),
            color: AppColors.card,
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Least trained: ${summary.leastTrained!.label}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${summary.setsLast4Weeks[summary.leastTrained] ?? 0} '
                        'sets in the last 4 weeks',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ChartCard(
          title: 'Sets per muscle · last 4 weeks',
          headline: '${summary.totalSets} sets',
          child: GroupBarChart(
            data: [
              for (final group in MuscleGroup.values)
                BarDatum(
                  label: group.label.substring(
                    0,
                    group.label.length < 4 ? group.label.length : 4,
                  ),
                  value: (summary.setsLast4Weeks[group] ?? 0).toDouble(),
                  color:
                      AppColors.muscleColors[group.key] ?? AppColors.chartFrom,
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ChartCard(
          title: 'Weekly set volume',
          headline: '${summary.weeks.isEmpty ? 0 : summary.weeks.last.totalSets} this week',
          subtitle: summary.weeks.isEmpty
              ? null
              : 'Week of ${Dates.dayMonth(summary.weeks.last.weekStart)}',
          child: TrendChart(
            series: [
              ChartSeries(
                dates: summary.weeks.map((w) => w.weekStart).toList(),
                values: weeklyTotals,
              ),
            ],
          ),
        ),

        const SectionHeader('Breakdown'),
        for (final group in MuscleGroup.values)
          _GroupRow(
            group: group,
            sets: summary.setsLast4Weeks[group] ?? 0,
            tonnage: summary.tonnageLast4Weeks[group] ?? 0,
            maxSets: summary.setsLast4Weeks.values.isEmpty
                ? 1
                : summary.setsLast4Weeks.values.reduce((a, b) => a > b ? a : b),
            unit: unit,
          ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.sets,
    required this.tonnage,
    required this.maxSets,
    required this.unit,
  });

  final MuscleGroup group;
  final int sets;
  final double tonnage;
  final int maxSets;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.muscleColors[group.key] ?? AppColors.volt;
    final fraction = maxSets == 0 ? 0.0 : sets / maxSets;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 6),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(group.label, style: theme.textTheme.titleSmall),
              ),
              Text('$sets sets', style: theme.textTheme.titleSmall),
              const SizedBox(width: 10),
              Text(
                Fmt.tonnage(tonnage, unit),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: AppColors.cardHigh,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
