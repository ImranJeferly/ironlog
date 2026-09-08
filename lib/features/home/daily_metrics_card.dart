import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/health/health_service.dart';
import '../../data/repositories/metrics_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';
import '../../widgets/wheel_picker.dart';

/// Water / kcal / protein / sleep / weight for the selected day.
///
/// No food database on purpose — the plan calls that over-engineering.
class DailyMetricsCard extends ConsumerWidget {
  const DailyMetricsCard({super.key});

  static const _waterGoalMl = 3000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = ref.watch(selectedMetricDateProvider);
    final metrics = ref.watch(todayMetricsProvider).value;
    final unit = ref.watch(unitProvider);
    final repo = ref.watch(metricsRepositoryProvider);
    final stepGoal = ref.watch(settingsProvider).stepGoal;

    final water = metrics?.waterMl ?? 0;
    final steps = metrics?.steps;
    final stepsReached = (steps ?? 0) >= stepGoal;

    // 7-day rolling average of synced steps (days without data don't count).
    int? stepsAvg;
    final recent = ref.watch(recentMetricsProvider).value;
    if (recent != null) {
      final counts = [
        for (final m in recent)
          if (m.steps != null) m.steps!,
      ];
      if (counts.isNotEmpty) {
        stepsAvg = (counts.reduce((a, b) => a + b) / counts.length).round();
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- steps (auto-synced from Health Connect / Samsung Health) ----
          // Read-only on purpose: steps always come from the device's health
          // store, never typed in, so the count can't drift from reality.
          _GaugeHeader(
            icon: Icons.directions_walk,
            label: 'Steps',
            value: Fmt.count(steps ?? 0),
            goal: Fmt.count(stepGoal),
            reached: stepsReached,
          ),
          const SizedBox(height: 10),
          SegmentBar(
            value: ((steps ?? 0) / stepGoal).clamp(0.0, 1.0),
            segments: 16,
            color: stepsReached ? AppColors.accent : AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.sync, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${steps == null ? 'AUTO-SYNCS FROM' : 'SYNCED FROM'} '
                  '${HealthService.providerName.toUpperCase()}'
                  '${stepsAvg == null ? '' : ' · 7-DAY AVG ${Fmt.count(stepsAvg)}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg * 1.4),

          // ---- water ----
          _GaugeHeader(
            icon: Icons.water_drop_outlined,
            label: 'Water',
            value: Fmt.water(water),
            goal: Fmt.water(_waterGoalMl),
            reached: water >= _waterGoalMl,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SegmentBar(
                  value: (water / _waterGoalMl).clamp(0.0, 1.0),
                  segments: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              _MiniButton(
                label: '−',
                onTap: water <= 0
                    ? null
                    : () => repo.addWater(
                        date,
                        ml: -MetricsRepository.glassMl,
                      ),
              ),
              const SizedBox(width: 6),
              _MiniButton(
                label: '+250',
                wide: true,
                accent: true,
                onTap: () => repo.addWater(date),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg * 1.4),

          // ---- manual entries ----
          Row(
            children: [
              Expanded(
                child: _MetricField(
                  label: 'Calories',
                  value: metrics?.kcal == null ? '—' : '${metrics!.kcal}',
                  suffix: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                  onTap: () => _editInt(
                    context,
                    title: 'Calories',
                    suffix: 'kcal',
                    initial: metrics?.kcal ?? 2400,
                    min: 0,
                    max: 6000,
                    step: 50,
                    onSave: (v) => repo.setKcal(date, v),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricField(
                  label: 'Protein',
                  value: metrics?.proteinG == null
                      ? '—'
                      : '${metrics!.proteinG}',
                  suffix: 'g',
                  icon: Icons.egg_outlined,
                  onTap: () => _editInt(
                    context,
                    title: 'Protein',
                    suffix: 'g',
                    initial: metrics?.proteinG ?? 150,
                    min: 0,
                    max: 400,
                    step: 5,
                    onSave: (v) => repo.setProtein(date, v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricField(
                  label: 'Sleep',
                  value: metrics?.sleepHours == null
                      ? '—'
                      : Fmt.num1(metrics!.sleepHours!),
                  suffix: 'h',
                  icon: Icons.bedtime_outlined,
                  onTap: () => _editDouble(
                    context,
                    title: 'Sleep',
                    suffix: 'h',
                    initial: metrics?.sleepHours ?? 7.5,
                    min: 0,
                    max: 14,
                    step: 0.5,
                    onSave: (v) => repo.setSleep(date, v),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricField(
                  label: 'Body weight',
                  value: metrics?.weightKg == null
                      ? '—'
                      : Fmt.weight(metrics!.weightKg!, unit, withUnit: false),
                  suffix: unit.label,
                  icon: Icons.monitor_weight_outlined,
                  onTap: () => _editDouble(
                    context,
                    title: 'Body weight',
                    suffix: unit.label,
                    initial: unit.fromKg(metrics?.weightKg ?? 80),
                    min: unit.fromKg(35),
                    max: unit.fromKg(200),
                    step: unit.fromKg(0.1),
                    decimals: 1,
                    onSave: (v) => repo.setWeight(date, unit.toKg(v)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editInt(
    BuildContext context, {
    required String title,
    required String suffix,
    required int initial,
    required int min,
    required int max,
    required int step,
    required Future<void> Function(int) onSave,
  }) async {
    await _editDouble(
      context,
      title: title,
      suffix: suffix,
      initial: initial.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      step: step.toDouble(),
      onSave: (v) => onSave(v.round()),
    );
  }

  Future<void> _editDouble(
    BuildContext context, {
    required String title,
    required String suffix,
    required double initial,
    required double min,
    required double max,
    required double step,
    required Future<void> Function(double) onSave,
    int decimals = 0,
  }) async {
    final values = wheelValues(min: min, max: max, step: step);
    var index = nearestIndex(values, initial);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HazardStripes(height: 6, background: AppColors.bg),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    NumberWheel(
                      values: values,
                      index: index,
                      accent: AppColors.accent,
                      fontSize: 46,
                      labelOf: (v) => v.toStringAsFixed(decimals),
                      onChanged: (i) => setState(() => index = i),
                    ),
                    Text(
                      suffix.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: GhostButton(
                            label: 'Cancel',
                            expanded: true,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: VoltButton(
                            label: 'Save',
                            height: 48,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved ?? false) {
      await onSave(values[index]);
    }
  }
}

/// "STEPS   8,412 / 20,000" — icon, caps label, numeric readout.
class _GaugeHeader extends StatelessWidget {
  const _GaugeHeader({
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
    required this.reached,
  });

  final IconData icon;
  final String label;
  final String value;
  final String goal;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          icon,
          size: 16,
          color: reached ? AppColors.accent : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppText.numeric(
            size: 16,
            color: reached ? AppColors.accent : AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        Text(
          ' / $goal',
          style: AppText.numeric(
            size: 12,
            color: AppColors.textTertiary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.label,
    this.onTap,
    this.wide = false,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool wide;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              Haptics.impact();
              onTap!();
            }
          : null,
      child: Container(
        height: 34,
        width: wide ? 64 : 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent ? AppColors.accent : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: accent ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppText.numeric(
            size: 13,
            letterSpacing: 0,
            color: accent
                ? AppColors.textPrimary
                : (enabled ? AppColors.textSecondary : AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.numeric(size: 22),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
