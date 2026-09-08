import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/enums.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/buttons.dart';
import '../settings_widgets.dart';

/// Schedule, units and the body-weight goal.
class TrainingSettingsPage extends ConsumerWidget {
  const TrainingSettingsPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const TrainingSettingsPage()),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return SettingsPage(
      title: 'Training',
      children: [
        const SectionHeader('Training days'),
        const TrainingDaysCard(),

        const SectionHeader('Units'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weight unit', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Everything is stored in kg — this only changes what you see.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              PillToggle<WeightUnit>(
                values: WeightUnit.values,
                selected: settings.unit,
                labelOf: (u) => u.label.toUpperCase(),
                onChanged: controller.setUnit,
              ),
            ],
          ),
        ),

        const SectionHeader('Body-weight goal'),
        AppCard(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lean bulk: how much to gain per week. The body-weight '
                  'chart grades the last 7 days against this band.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RateRow(
                title: 'From',
                kgPerWeek: settings.bwTargetMinKg,
                unit: settings.unit,
                canIncrease:
                    settings.bwTargetMinKg + 0.05 <= settings.bwTargetMaxKg + 1e-9,
                onChanged: controller.setBwTargetMin,
              ),
              const SizedBox(height: AppSpacing.sm),
              RateRow(
                title: 'To',
                kgPerWeek: settings.bwTargetMaxKg,
                unit: settings.unit,
                canDecrease:
                    settings.bwTargetMaxKg - 0.05 >= settings.bwTargetMinKg - 1e-9,
                onChanged: controller.setBwTargetMax,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
