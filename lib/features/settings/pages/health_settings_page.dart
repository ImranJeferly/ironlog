import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/health/health_service.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/buttons.dart';
import '../settings_widgets.dart';

/// Health Connect link, step goal and manual sync / import.
class HealthSettingsPage extends ConsumerWidget {
  const HealthSettingsPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const HealthSettingsPage()),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return SettingsPage(
      title: HealthService.providerName,
      subtitle: 'Steps always come from here — they can’t be typed in.',
      children: [
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: [
              SettingsSwitchRow(
                title: 'Read steps, sleep and weight',
                subtitle:
                    'From ${HealthService.providerName}'
                    '${HealthService.providerName == 'Health Connect' ? ' (Samsung Health, Fit…)' : ''}. '
                    'Manual entries are never overwritten.',
                value: settings.healthEnabled,
                onChanged: controller.setHealthEnabled,
              ),
              const Divider(height: AppSpacing.lg),
              const HealthStatusRow(),
            ],
          ),
        ),

        const SectionHeader('Steps'),
        AppCard(
          child: StepGoalRow(
            value: settings.stepGoal,
            onChanged: controller.setStepGoal,
          ),
        ),

        const SectionHeader('Manual sync'),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: GhostButton(
                  label: 'Sync today',
                  icon: Icons.refresh,
                  expanded: true,
                  onPressed: () async {
                    final ok = await ref
                        .read(healthServiceProvider)
                        .syncToday();
                    if (context.mounted) {
                      showSettingsToast(
                        context,
                        ok ? 'Health data updated' : 'No Health data available',
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GhostButton(
                  label: 'Import history',
                  icon: Icons.download_outlined,
                  expanded: true,
                  onPressed: () async {
                    showSettingsToast(context, 'Importing…');
                    final count = await ref
                        .read(healthServiceProvider)
                        .importHistory();
                    ref.read(analyticsRevisionProvider.notifier).bump();
                    if (context.mounted) {
                      showSettingsToast(
                        context,
                        count == 0
                            ? 'Nothing to import'
                            : 'Imported $count days',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
