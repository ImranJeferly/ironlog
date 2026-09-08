import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/charts.dart';

enum _Metric {
  strength('Top set + e1RM'),
  topSet('Top set'),
  e1rm('Est. 1RM'),
  volume('Volume');

  const _Metric(this.label);

  final String label;
}

/// Per-exercise analytics: top-set weight, Epley 1RM and volume over time.
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  static Future<void> open(BuildContext context, String exerciseId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseDetailScreen(exerciseId: exerciseId),
      ),
    );
  }

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  _Metric _metric = _Metric.strength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ref.watch(exerciseProgressProvider(widget.exerciseId)).value;
    final unit = ref.watch(unitProvider);
    final exercise = ref.watch(exerciseByIdProvider(widget.exerciseId));
    final stalled =
        ref.watch(stalledExercisesProvider).value?.contains(widget.exerciseId) ??
        false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(exercise?.name ?? 'Exercise'),
        actions: [
          if (stalled)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: VoltBadge('STALLED', color: AppColors.warning),
              ),
            ),
        ],
      ),
      body: progress == null || progress.isEmpty
          ? EmptyState(
              title: exercise?.name ?? 'Exercise',
              icon: Icons.show_chart,
              message: 'Log a few sets and your progress lands here.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: Fmt.weight(progress.bestWeightKg, unit),
                        label: 'Best weight',
                        accent: AppColors.volt,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatTile(
                        value: Fmt.weight(progress.best1RM, unit),
                        label: 'Best est. 1RM',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatTile(
                        value: '${progress.totalSets}',
                        label: 'Total sets',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final m in _Metric.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _Chip(
                            label: m.label,
                            active: m == _metric,
                            onTap: () => setState(() => _metric = m),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                ChartCard(
                  title: _metric.label,
                  headline: _headline(progress, unit),
                  subtitle: stalled
                      ? 'No e1RM PR in 4 weeks — ${_subtitle(progress, unit)}'
                      : _subtitle(progress, unit),
                  child: TrendChart(
                    series: [
                      if (_metric == _Metric.strength) ...[
                        // Solid = top-set weight, dashed volt = Epley e1RM.
                        ChartSeries(
                          dates: progress.points.map((p) => p.date).toList(),
                          values: progress.points
                              .map((p) => unit.fromKg(p.topWeightKg))
                              .toList(),
                          showArea: true,
                        ),
                        ChartSeries(
                          dates: progress.points.map((p) => p.date).toList(),
                          values: progress.points
                              .map((p) => unit.fromKg(p.best1RM))
                              .toList(),
                          dashed: true,
                          gradient: const LinearGradient(
                            colors: [AppColors.volt, AppColors.volt],
                          ),
                        ),
                      ] else
                        ChartSeries(
                          dates: progress.points.map((p) => p.date).toList(),
                          values: progress.points.map(_valueOf).toList(),
                        ),
                    ],
                    valueSuffix: _metric == _Metric.volume
                        ? ''
                        : ' ${unit.label}',
                  ),
                ),

                if (progress.records.isNotEmpty) ...[
                  const SectionHeader('Personal records'),
                  for (final pr in progress.records.take(10))
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 6),
                      radius: AppRadii.cardSmall,
                      edge: AppColors.accent,
                      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 17,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pr.type.label,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            pr.type == PrType.reps
                                ? '${pr.reps} × ${Fmt.weight(pr.weightKg, unit)}'
                                : Fmt.weight(pr.value, unit),
                            style: AppText.numeric(
                              size: 15,
                              color: AppColors.accent,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            Dates.dayMonth(pr.achievedAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],

                const SectionHeader('Last 5 sessions'),
                AppCard(
                  radius: AppRadii.cardSmall,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _HistoryRow.header(theme),
                      for (final point in progress.points.reversed.take(5))
                        _HistoryRow(point: point, unit: unit),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  double _valueOf(ExercisePoint point) => switch (_metric) {
    _Metric.strength || _Metric.topSet => point.topWeightKg,
    _Metric.e1rm => point.best1RM,
    _Metric.volume => point.volumeKg,
  };

  String _headline(ExerciseProgress progress, WeightUnit unit) {
    if (progress.points.isEmpty) return '—';
    final last = progress.points.last;
    return switch (_metric) {
      _Metric.strength =>
        '${Fmt.weight(last.topWeightKg, unit)} × ${last.topReps} · '
            'e1RM ${Fmt.weight(last.best1RM, unit)}',
      _Metric.volume => Fmt.tonnage(last.volumeKg, unit),
      _ => Fmt.weight(_valueOf(last), unit),
    };
  }

  String? _subtitle(ExerciseProgress progress, WeightUnit unit) {
    final points = progress.points;
    if (points.length < 2) return 'First session logged';
    final delta = _valueOf(points.last) - _valueOf(points.first);
    final sign = delta >= 0 ? '+' : '−';
    final formatted = _metric == _Metric.volume
        ? Fmt.tonnage(delta.abs(), unit)
        : Fmt.weight(delta.abs(), unit);
    return '$sign$formatted since ${Dates.dayMonth(points.first.date)}';
  }
}

/// One line of the last-5 table: date · top set · e1RM · sets.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.point, required this.unit})
    : _header = false;

  const _HistoryRow.header(ThemeData _)
    : point = null,
      unit = WeightUnit.kg,
      _header = true;

  final ExercisePoint? point;
  final WeightUnit unit;
  final bool _header;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = point;
    final labelStyle = theme.textTheme.labelSmall;
    final cell = AppText.numeric(size: 14, letterSpacing: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              _header ? 'DATE' : Dates.dayMonth(p!.date),
              style: _header ? labelStyle : theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              _header
                  ? 'TOP SET'
                  : '${Fmt.weight(p!.topWeightKg, unit)} × ${p.topReps}',
              style: _header ? labelStyle : cell,
            ),
          ),
          SizedBox(
            width: 82,
            child: Text(
              _header ? 'E1RM' : Fmt.weight(p!.best1RM, unit),
              textAlign: TextAlign.right,
              style: _header
                  ? labelStyle
                  : cell.copyWith(color: AppColors.accent),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              _header ? 'SETS' : '${p!.sets}',
              textAlign: TextAlign.right,
              style: _header ? labelStyle : theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 15,
            letterSpacing: 1.2,
            height: 1,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
