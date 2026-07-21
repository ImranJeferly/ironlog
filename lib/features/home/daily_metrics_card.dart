import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/repositories/metrics_repository.dart';
import '../../widgets/app_card.dart';
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- steps (Health Connect / Samsung Health, editable) ----
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                size: 18,
                color: stepsReached ? AppColors.volt : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text('Steps', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                '${Fmt.count(steps ?? 0)} / ${Fmt.count(stepGoal)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: stepsReached ? AppColors.volt : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: ((steps ?? 0) / stepGoal).clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: AppColors.cardHigh,
                      valueColor: const AlwaysStoppedAnimation(AppColors.volt),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _MiniButton(
                label: 'Edit',
                wide: true,
                onTap: () => _editInt(
                  context,
                  title: 'Steps',
                  suffix: 'steps',
                  initial: steps ?? stepGoal,
                  min: 0,
                  max: 100000,
                  step: 100,
                  onSave: (v) => repo.setSteps(date, v),
                ),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg * 1.4),

          // ---- water ----
          Row(
            children: [
              const Icon(
                Icons.local_drink_outlined,
                size: 18,
                color: AppColors.chartTo,
              ),
              const SizedBox(width: 8),
              Text('Water', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                '${Fmt.water(water)} / ${Fmt.water(_waterGoalMl)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (water / _waterGoalMl).clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: AppColors.cardHigh,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.chartTo,
                      ),
                    ),
                  ),
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                NumberWheel(
                  values: values,
                  index: index,
                  accent: AppColors.volt,
                  fontSize: 46,
                  labelOf: (v) => v.toStringAsFixed(decimals),
                  onChanged: (i) => setState(() => index = i),
                ),
                Text(suffix, style: Theme.of(context).textTheme.bodyMedium),
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
        ),
      ),
    );

    if (saved ?? false) {
      await onSave(values[index]);
    }
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
          color: accent ? AppColors.chartTo : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: accent ? AppColors.chartTo : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: accent
                ? Colors.white
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
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
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 3),
                Text(suffix, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
