import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../domain/enums.dart';
import '../../domain/volume.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../../widgets/charts.dart';

/// Weekly hard sets per muscle against an editable target band, with a
/// tap-through to the exercises behind each number and a 4-week tonnage trend.
class MuscleGroupsTab extends ConsumerWidget {
  const MuscleGroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weeks = ref.watch(volumeWeeksProvider).value;
    final targets =
        ref.watch(volumeTargetsProvider).value ?? VolumeCalc.defaultTargets;

    if (weeks == null || weeks.every((w) => w.totalHardSets == 0)) {
      return const EmptyState(
        title: 'No volume yet',
        icon: Icons.pie_chart_outline,
        message: 'Finish a session to see hard sets per muscle.',
      );
    }

    final thisWeek = weeks.last;
    var under = 0;
    var over = 0;
    for (final m in Muscle.values) {
      final t = targets[m];
      if (t == null) continue;
      switch (t.statusFor(thisWeek.hardSets[m] ?? 0)) {
        case VolumeStatus.under:
          under++;
        case VolumeStatus.over:
          over++;
        case VolumeStatus.onTarget:
          break;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THIS WEEK', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          '${_fmtSets(thisWeek.totalHardSets)} hard sets',
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          'Week of ${Dates.dayMonth(thisWeek.weekStart)} · '
                          'secondary muscles count ½ · explosive excluded',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (under > 0)
                        Text(
                          '$under under',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (over > 0)
                        Text(
                          '$over over',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (under == 0 && over == 0)
                        Text(
                          'all on target',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.volt,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final m in Muscle.values)
                if (targets[m] != null || (thisWeek.hardSets[m] ?? 0) > 0)
                  _MuscleBar(
                    muscle: m,
                    sets: thisWeek.hardSets[m] ?? 0,
                    target: targets[m],
                    onTap: () => _MuscleSheet.show(
                      context,
                      muscle: m,
                      weeks: weeks,
                      target: targets[m],
                    ),
                  ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),
        ChartCard(
          title: 'Weekly hard sets · all muscles',
          headline: _fmtSets(thisWeek.totalHardSets),
          subtitle: 'Last ${weeks.length} weeks',
          child: TrendChart(
            series: [
              ChartSeries(
                dates: weeks.map((w) => w.weekStart).toList(),
                values: weeks.map((w) => w.totalHardSets).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _fmtSets(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

Color _statusColor(VolumeStatus s) => switch (s) {
  VolumeStatus.under => AppColors.danger,
  VolumeStatus.over => AppColors.warning,
  VolumeStatus.onTarget => AppColors.volt,
};

/// One muscle: label, hard sets vs target, and a bar with the target band
/// shaded behind it. Red under, amber over, volt in band.
class _MuscleBar extends StatelessWidget {
  const _MuscleBar({
    required this.muscle,
    required this.sets,
    required this.target,
    required this.onTap,
  });

  final Muscle muscle;
  final double sets;
  final VolumeTarget? target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = target;
    final status = t?.statusFor(sets);
    final color = status == null
        ? (AppColors.muscleColors[muscle.group.key] ?? AppColors.volt)
        : _statusColor(status);
    // Scale so the band's top sits at ~75 % of the bar width.
    final scaleMax = ((t?.max ?? sets) * 1.33).clamp(1.0, double.infinity);
    final fill = (sets / scaleMax).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(muscle.label, style: theme.textTheme.titleSmall),
                ),
                Text(
                  _fmtSets(sets),
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
                if (t != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '/ $t',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 8,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      if (t != null)
                        Positioned(
                          left: w * (t.min / scaleMax).clamp(0.0, 1.0),
                          width:
                              w * ((t.max - t.min) / scaleMax).clamp(0.0, 1.0),
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.volt.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        width: w * fill,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tap-through: which exercises fed this muscle this week, the 4-week
/// tonnage trend, and the editable target band.
class _MuscleSheet extends ConsumerStatefulWidget {
  const _MuscleSheet({
    required this.muscle,
    required this.weeks,
    required this.target,
  });

  final Muscle muscle;
  final List<MuscleWeek> weeks;
  final VolumeTarget? target;

  static Future<void> show(
    BuildContext context, {
    required Muscle muscle,
    required List<MuscleWeek> weeks,
    required VolumeTarget? target,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => _MuscleSheet(muscle: muscle, weeks: weeks, target: target),
    );
  }

  @override
  ConsumerState<_MuscleSheet> createState() => _MuscleSheetState();
}

class _MuscleSheetState extends ConsumerState<_MuscleSheet> {
  late int _min = widget.target?.min ?? 0;
  late int _max = widget.target?.max ?? 0;

  Future<void> _save() async {
    await ref
        .read(settingsRepositoryProvider)
        .setVolumeTarget(widget.muscle, _min, _max);
    ref.invalidate(volumeTargetsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = ref.watch(unitProvider);
    final exercises = ref.watch(allExercisesProvider).value ?? const [];
    final nameOf = {for (final e in exercises) e.id: e.name};
    final week = widget.weeks.last;
    final contributors = (week.setsByExercise[widget.muscle] ?? const {})
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tonnage = widget.weeks
        .map((w) => unit.fromKg(w.tonnageKg[widget.muscle] ?? 0))
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.muscle.label.toUpperCase(), style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              '${_fmtSets(week.hardSets[widget.muscle] ?? 0)} hard sets this week',
              style: theme.textTheme.headlineSmall,
            ),

            const SizedBox(height: AppSpacing.md),
            Text('FROM', style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            if (contributors.isEmpty)
              Text('Nothing logged this week.', style: theme.textTheme.bodySmall)
            else
              for (final c in contributors)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nameOf[c.key] ?? c.key,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${_fmtSets(c.value)} sets',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: AppSpacing.md),
            ChartCard(
              title: 'Tonnage · last ${widget.weeks.length} weeks',
              headline: Fmt.tonnage(
                widget.weeks.last.tonnageKg[widget.muscle] ?? 0,
                unit,
              ),
              child: TrendChart(
                valueSuffix: ' ${unit.label}',
                series: [
                  ChartSeries(
                    dates: widget.weeks.map((w) => w.weekStart).toList(),
                    values: tonnage,
                    showArea: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Text('WEEKLY TARGET · HARD SETS', style: theme.textTheme.labelSmall),
            const SizedBox(height: 6),
            _TargetRow(
              label: 'From',
              value: _min,
              onMinus: _min <= 0 ? null : () => setState(() => _min--),
              onPlus: _min >= _max ? null : () => setState(() => _min++),
            ),
            const SizedBox(height: 6),
            _TargetRow(
              label: 'To',
              value: _max,
              onMinus: _max <= _min ? null : () => setState(() => _max--),
              onPlus: _max >= 40 ? null : () => setState(() => _max++),
            ),
            const SizedBox(height: AppSpacing.md),
            VoltButton(
              label: 'Save target',
              icon: Icons.check_rounded,
              height: 48,
              onPressed: () async {
                await _save();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
        IconPill(icon: Icons.remove, size: 34, onTap: onMinus),
        SizedBox(
          width: 52,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconPill(icon: Icons.add, size: 34, onTap: onPlus),
      ],
    );
  }
}
