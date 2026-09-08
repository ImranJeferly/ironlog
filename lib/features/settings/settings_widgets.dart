import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/db/database.dart';
import '../../data/health/health_service.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../home/template_editor_screen.dart';

/// Scaffold shared by every settings sub-page: back button, condensed title,
/// scrolling body.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                0,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              child: Text(subtitle!, style: theme.textTheme.bodySmall),
            ),
          ...children,
        ],
      ),
    );
  }
}

void showSettingsToast(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// Title + subtitle + switch.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Switch(value: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}

/// Seconds stepper (rest timer), ±15 s.
class SettingsStepperRow extends StatelessWidget {
  const SettingsStepperRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
        IconPill(
          icon: Icons.remove,
          size: 34,
          onTap: value <= 30 ? null : () => onChanged(value - 15),
        ),
        SizedBox(
          width: 64,
          child: Text(
            Fmt.clock(Duration(seconds: value)),
            textAlign: TextAlign.center,
            style: AppText.numeric(size: 17, letterSpacing: 0),
          ),
        ),
        IconPill(
          icon: Icons.add,
          size: 34,
          onTap: value >= 600 ? null : () => onChanged(value + 15),
        ),
      ],
    );
  }
}

/// A kg-per-week rate, stepped by 0.05 kg and shown in the user's unit.
class RateRow extends StatelessWidget {
  const RateRow({
    super.key,
    required this.title,
    required this.kgPerWeek,
    required this.unit,
    required this.onChanged,
    this.canIncrease = true,
    this.canDecrease = true,
  });

  final String title;
  final double kgPerWeek;
  final WeightUnit unit;
  final ValueChanged<double> onChanged;
  final bool canIncrease;
  final bool canDecrease;

  static const _step = 0.05;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
        IconPill(
          icon: Icons.remove,
          size: 34,
          onTap: !canDecrease || kgPerWeek - _step < -1.0
              ? null
              : () => onChanged(kgPerWeek - _step),
        ),
        SizedBox(
          width: 104,
          child: Text(
            '${Fmt.signed(unit.fromKg(kgPerWeek))} ${unit.label}/wk',
            textAlign: TextAlign.center,
            style: AppText.numeric(size: 15, letterSpacing: 0),
          ),
        ),
        IconPill(
          icon: Icons.add,
          size: 34,
          onTap: !canIncrease || kgPerWeek + _step > 1.5
              ? null
              : () => onChanged(kgPerWeek + _step),
        ),
      ],
    );
  }
}

/// Changeable daily step goal, stepped in 1 000-step increments.
class StepGoalRow extends StatelessWidget {
  const StepGoalRow({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily step goal', style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                'Home progress fills toward this.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconPill(
          icon: Icons.remove,
          size: 34,
          onTap: value <= 1000 ? null : () => onChanged(value - 1000),
        ),
        SizedBox(
          width: 76,
          child: Text(
            Fmt.count(value),
            textAlign: TextAlign.center,
            style: AppText.numeric(size: 17, letterSpacing: 0),
          ),
        ),
        IconPill(
          icon: Icons.add,
          size: 34,
          onTap: value >= 100000 ? null : () => onChanged(value + 1000),
        ),
      ],
    );
  }
}

/// Pick which weekday each workout runs on; tap the name to edit the workout.
class TrainingDaysCard extends ConsumerWidget {
  const TrainingDaysCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(templatesProvider).value ?? const [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap a day to move a workout. Tapping its current day takes it '
            'off the schedule. Tap the name to edit its exercises.',
            style: theme.textTheme.bodySmall,
          ),
          for (final template in templates) ...[
            const SizedBox(height: AppSpacing.md),
            _TrainingDayRow(template: template),
          ],
        ],
      ),
    );
  }
}

class _TrainingDayRow extends ConsumerWidget {
  const _TrainingDayRow({required this.template});

  final TemplateRow template;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = AppColors.forTemplateName(template.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => TemplateEditorScreen.open(context, template.id),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(template.name, style: theme.textTheme.titleSmall),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Text(
                template.weekday == null
                    ? 'Off schedule'
                    : _dayNames[template.weekday! - 1],
                style: AppText.display(
                  size: 14,
                  color: template.weekday == null
                      ? AppColors.textTertiary
                      : accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var day = 1; day <= 7; day++) ...[
              if (day > 1) const SizedBox(width: 6),
              Expanded(
                child: _DayChip(
                  label: _dayLetters[day - 1],
                  selected: template.weekday == day,
                  accent: accent,
                  onTap: () => ref
                      .read(workoutRepositoryProvider)
                      .setTemplateWeekday(
                        template.id,
                        template.weekday == day ? null : day,
                      ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 14,
            color: selected
                ? (accent == AppColors.textPrimary
                      ? AppColors.bg
                      : AppColors.textPrimary)
                : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Live Health Connect / Apple Health link status with a one-tap connect.
class HealthStatusRow extends ConsumerStatefulWidget {
  const HealthStatusRow({super.key});

  @override
  ConsumerState<HealthStatusRow> createState() => _HealthStatusRowState();
}

class _HealthStatusRowState extends ConsumerState<HealthStatusRow> {
  late Future<bool> _connected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _connected = ref.read(healthServiceProvider).hasPermissions();
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    final health = ref.read(healthServiceProvider);
    final granted = await health.requestPermissions();
    if (granted) {
      await health.syncRecent();
      ref.read(analyticsRevisionProvider.notifier).bump();
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _connected = health.hasPermissions();
    });
    showSettingsToast(
      context,
      granted
          ? 'Connected — steps are syncing.'
          : 'Not connected. Open ${HealthService.providerName} and allow '
                'IronLog to read steps, sleep and weight.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<bool>(
      future: _connected,
      builder: (context, snapshot) {
        final connected = snapshot.data ?? false;
        return Row(
          children: [
            Icon(
              connected ? Icons.link : Icons.link_off,
              size: 17,
              color: connected ? AppColors.accent : AppColors.danger,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connected ? 'Connected' : 'Not connected',
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    connected
                        ? 'Steps land here automatically on every app open.'
                        : 'Steps can’t sync until IronLog is allowed in '
                              '${HealthService.providerName}.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            GhostButton(
              label: _busy ? 'Working…' : (connected ? 'Re-check' : 'Connect'),
              height: 40,
              onPressed: _busy ? null : _connect,
            ),
          ],
        );
      },
    );
  }
}
