import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';
import '../../widgets/wheel_picker.dart';

/// Before a session starts: if there's no weigh-in in the last three days,
/// ask for one on a single numeric wheel prefilled with the last value.
/// Skipping is allowed (and counted) — the session is never blocked.
Future<void> maybePromptBodyweight(BuildContext context, WidgetRef ref) async {
  final metrics = ref.read(metricsRepositoryProvider);
  if (await metrics.latestWeightWithin(withinDays: 3) != null) return;

  final lastKg = await metrics.latestWeightKg();
  final unit = ref.read(unitProvider);
  if (!context.mounted) return;

  final values = wheelValues(
    min: unit.fromKg(35),
    max: unit.fromKg(200),
    step: unit.fromKg(0.1),
  );
  var index = nearestIndex(values, unit.fromKg(lastKg ?? 80));

  final saved = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HazardStripes(height: 6, background: AppColors.bg),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('WEIGH IN?', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      lastKg == null
                          ? 'No weigh-in yet — log one to start the trend.'
                          : 'Last logged ${Fmt.weight(lastKg, unit)} — still about right?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    NumberWheel(
                      values: values,
                      index: index,
                      accent: AppColors.accent,
                      fontSize: 46,
                      labelOf: (v) => v.toStringAsFixed(1),
                      onChanged: (i) => setState(() => index = i),
                    ),
                    Text(
                      unit.label.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: GhostButton(
                            label: 'Skip',
                            expanded: true,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: VoltButton(
                            label: 'Save & start',
                            height: 48,
                            icon: Icons.check_rounded,
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
        );
      },
    ),
  );

  if (saved == true) {
    await metrics.setWeight(DateTime.now(), unit.toKg(values[index]));
  } else {
    await ref.read(settingsRepositoryProvider).countBodyweightPromptSkip();
  }
}
