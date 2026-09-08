import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_card.dart';
import '../settings_widgets.dart';

/// Rest timer, haptics and reminders — everything that happens mid-session
/// or nudges you outside one.
class SessionSettingsPage extends ConsumerWidget {
  const SessionSettingsPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SessionSettingsPage()),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return SettingsPage(
      title: 'Session',
      children: [
        const SectionHeader('Rest timer'),
        AppCard(
          child: Column(
            children: [
              SettingsSwitchRow(
                title: 'Auto-start after each set',
                subtitle: 'Fires a notification when the rest is up.',
                value: settings.restTimerEnabled,
                onChanged: controller.setRestTimerEnabled,
              ),
              const Divider(height: AppSpacing.lg),
              SettingsStepperRow(
                title: 'Default rest',
                value: settings.restSeconds,
                onChanged: controller.setRestSeconds,
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsStepperRow(
                title: 'Heavy sets (primary / explosive)',
                value: settings.restSecondsPrimary,
                onChanged: controller.setRestSecondsPrimary,
              ),
              const Divider(height: AppSpacing.lg),
              SettingsStepperRow(
                title: 'Between exercises',
                subtitle: 'Starts when an exercise’s last set is logged.',
                value: settings.restSecondsExercise,
                step: 30,
                min: 60,
                max: 900,
                onChanged: controller.setRestSecondsExercise,
              ),
            ],
          ),
        ),

        const SectionHeader('Feel'),
        AppCard(
          child: SettingsSwitchRow(
            title: 'Haptics',
            subtitle: 'Tick on the wheel, thump when a set is logged.',
            value: settings.hapticsEnabled,
            onChanged: controller.setHaptics,
          ),
        ),

        const SectionHeader('Reminders'),
        AppCard(
          child: SettingsSwitchRow(
            title: 'Log protein + kcal at 21:00',
            subtitle: 'A nightly nudge that opens the Today card.',
            value: settings.nutritionReminderEnabled,
            onChanged: controller.setNutritionReminder,
          ),
        ),
      ],
    );
  }
}
