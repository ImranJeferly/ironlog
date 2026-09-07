import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/charts.dart';
import '../home/daily_metrics_card.dart';

/// Body-weight trend with a 7-day moving average, plotted against strength.
class BodyTab extends ConsumerWidget {
  const BodyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final series = ref.watch(bodyWeightProvider).value;
    final unit = ref.watch(unitProvider);
    final consistency = ref.watch(consistencyProvider).value;
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        if (series == null || series.isEmpty)
          const AppCard(
            child: SizedBox(
              height: 220,
              child: EmptyState(
                title: 'No weigh-ins yet',
                icon: Icons.monitor_weight_outlined,
                message: 'Log your weight below and the trend builds itself.',
              ),
            ),
          )
        else
          ChartCard(
            title: 'Body weight',
            headline: Fmt.weight(series.latestKg ?? 0, unit),
            subtitle: _subtitle(series, unit, settings),
            child: TrendChart(
              valueSuffix: ' ${unit.label}',
              series: [
                ChartSeries(
                  dates: series.dates,
                  values: series.weightsKg.map(unit.fromKg).toList(),
                  showArea: true,
                ),
                // Dashed line = the smoothed trend that actually matters.
                ChartSeries(
                  dates: series.dates,
                  values: series.movingAverageKg.map(unit.fromKg).toList(),
                  dashed: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.volt, AppColors.volt],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '${consistency?.currentStreak ?? 0}',
                label: 'Current streak',
                accent: (consistency?.currentStreak ?? 0) > 0
                    ? AppColors.volt
                    : null,
                icon: Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                value: '${consistency?.longestStreak ?? 0}',
                label: 'Best streak',
                icon: Icons.emoji_events_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                value: '${consistency?.totalSessions ?? 0}',
                label: 'Sessions',
                icon: Icons.fitness_center,
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 8),
          child: Text(
            'TODAY’S METRICS',
            style: theme.textTheme.labelSmall,
          ),
        ),
        const DailyMetricsCard(),
      ],
    );
  }

  /// "7-day avg 82.4 kg · +0.28 kg/wk (+0.3%) · target 0.20–0.35 · on track"
  static String _subtitle(
    BodyWeightSeries series,
    WeightUnit unit,
    AppSettings settings,
  ) {
    final parts = <String>[
      '7-day avg ${Fmt.weight(series.latestAverageKg ?? 0, unit)}',
    ];
    final weekly = series.weeklyDeltaKg;
    if (weekly == null) {
      parts.add(
        '${Fmt.signed(unit.fromKg(series.deltaKg))} ${unit.label} over the window',
      );
      return parts.join(' · ');
    }
    final pct = series.weeklyDeltaPct;
    parts.add(
      '${Fmt.signed(unit.fromKg(weekly))} ${unit.label}/wk'
      '${pct == null ? '' : ' (${Fmt.signed(pct)}%)'}',
    );
    final lo = settings.bwTargetMinKg;
    final hi = settings.bwTargetMaxKg;
    parts.add(
      'target ${Fmt.num1(unit.fromKg(lo))}–${Fmt.num1(unit.fromKg(hi))}',
    );
    parts.add(
      weekly < lo
          ? 'under'
          : (weekly > hi ? 'over' : 'on track'),
    );
    return parts.join(' · ');
  }
}
