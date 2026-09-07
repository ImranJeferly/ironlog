import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/db/database.dart';
import '../../data/health/health_service.dart';
import '../../data/sync/firebase_bootstrap.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../home/template_editor_screen.dart';
import '../update/update_prompt.dart';
import 'account_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;
  bool _checkingUpdate = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final sync = ref.watch(syncControllerProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          Text('Settings', style: theme.textTheme.headlineMedium),

          const SectionHeader('Account'),
          const _AccountCard(),

          const SectionHeader('Training days'),
          const _TrainingDaysCard(),

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

          const SectionHeader('Rest timer'),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Auto-start after each set',
                  subtitle: 'Fires a notification when the rest is up.',
                  value: settings.restTimerEnabled,
                  onChanged: controller.setRestTimerEnabled,
                ),
                const Divider(height: AppSpacing.lg),
                _StepperRow(
                  title: 'Default rest',
                  value: settings.restSeconds,
                  onChanged: controller.setRestSeconds,
                ),
                const SizedBox(height: AppSpacing.md),
                _StepperRow(
                  title: 'Heavy sets (primary / explosive)',
                  value: settings.restSecondsPrimary,
                  onChanged: controller.setRestSecondsPrimary,
                ),
              ],
            ),
          ),

          const SectionHeader('Feel'),
          AppCard(
            child: _SwitchRow(
              title: 'Haptics',
              subtitle: 'Tick on the wheel, thump when a set is logged.',
              value: settings.hapticsEnabled,
              onChanged: controller.setHaptics,
            ),
          ),

          const SectionHeader('Reminders'),
          AppCard(
            child: _SwitchRow(
              title: 'Log protein + kcal at 21:00',
              subtitle: 'A nightly nudge that opens the Today card.',
              value: settings.nutritionReminderEnabled,
              onChanged: controller.setNutritionReminder,
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
                _RateRow(
                  title: 'From',
                  kgPerWeek: settings.bwTargetMinKg,
                  unit: settings.unit,
                  canIncrease: settings.bwTargetMinKg + 0.05 <=
                      settings.bwTargetMaxKg + 1e-9,
                  onChanged: controller.setBwTargetMin,
                ),
                const SizedBox(height: AppSpacing.sm),
                _RateRow(
                  title: 'To',
                  kgPerWeek: settings.bwTargetMaxKg,
                  unit: settings.unit,
                  canDecrease: settings.bwTargetMaxKg - 0.05 >=
                      settings.bwTargetMinKg - 1e-9,
                  onChanged: controller.setBwTargetMax,
                ),
              ],
            ),
          ),

          SectionHeader(HealthService.providerName),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Read steps, sleep and weight',
                  subtitle:
                      'From ${HealthService.providerName}'
                      '${HealthService.providerName == 'Health Connect' ? ' (Samsung Health, Fit…)' : ''}. '
                      'Manual entries are never overwritten.',
                  value: settings.healthEnabled,
                  onChanged: controller.setHealthEnabled,
                ),
                const Divider(height: AppSpacing.lg),
                const _HealthStatusRow(),
                const Divider(height: AppSpacing.lg),
                _StepGoalRow(
                  value: settings.stepGoal,
                  onChanged: controller.setStepGoal,
                ),
                const Divider(height: AppSpacing.lg),
                Row(
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
                          _toast(
                            ok
                                ? 'Health data updated'
                                : 'No Health data available',
                          );
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
                          _toast('Importing…');
                          final count = await ref
                              .read(healthServiceProvider)
                              .importHistory();
                          ref.read(analyticsRevisionProvider.notifier).bump();
                          _toast(
                            count == 0
                                ? 'Nothing to import'
                                : 'Imported $count days',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SectionHeader('Sync'),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Firebase sync',
                  subtitle: FirebaseBootstrap.isAvailable
                      ? 'Backs up to your private Firestore project.'
                      : (FirebaseBootstrap.unavailableReason ??
                            'Not configured.'),
                  value: settings.syncEnabled && FirebaseBootstrap.isAvailable,
                  enabled: FirebaseBootstrap.isAvailable,
                  onChanged: controller.setSyncEnabled,
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    Icon(
                      _syncIcon(sync.state),
                      size: 17,
                      color: _syncColor(sync.state),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sync.label, style: theme.textTheme.titleSmall),
                          Text(
                            sync.lastSyncAt == null
                                ? 'Never synced'
                                : 'Last sync '
                                      '${Dates.relativeDay(sync.lastSyncAt!)} '
                                      '${Dates.time(sync.lastSyncAt!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    GhostButton(
                      label: 'Sync now',
                      height: 40,
                      onPressed: !FirebaseBootstrap.isAvailable
                          ? null
                          : () => ref
                                .read(syncControllerProvider.notifier)
                                .sync(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SectionHeader('Your data'),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export CSV',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            'Sessions, metrics and PRs. It’s your data.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    GhostButton(
                      label: _exporting ? 'Working…' : 'Export',
                      height: 40,
                      onPressed: _exporting ? null : _export,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SectionHeader('Updates'),
          AppCard(
            child: Row(
              children: [
                const Icon(
                  Icons.system_update,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App version', style: theme.textTheme.titleSmall),
                      FutureBuilder<String>(
                        future: ref
                            .read(updateServiceProvider)
                            .currentVersionName(),
                        builder: (context, snap) => Text(
                          snap.data == null || snap.data!.isEmpty
                              ? 'Checks GitHub for new builds'
                              : 'v${snap.data}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                GhostButton(
                  label: _checkingUpdate ? 'Checking…' : 'Check',
                  height: 40,
                  onPressed: _checkingUpdate ? null : _checkUpdate,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'IronLog · offline-first',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _checkingUpdate = true);
    final service = ref.read(updateServiceProvider);
    final info = await service.checkForUpdate();
    if (!mounted) return;
    setState(() => _checkingUpdate = false);
    if (info == null) {
      _toast('You’re on the latest version');
      return;
    }
    await promptForUpdate(context, service, info);
  }

  IconData _syncIcon(SyncState state) => switch (state) {
    SyncState.syncing => Icons.sync,
    SyncState.success => Icons.cloud_done_outlined,
    SyncState.failed => Icons.cloud_off_outlined,
    SyncState.disabled => Icons.cloud_off_outlined,
    SyncState.idle => Icons.cloud_queue,
  };

  Color _syncColor(SyncState state) => switch (state) {
    SyncState.success => AppColors.volt,
    SyncState.failed => AppColors.danger,
    _ => AppColors.textSecondary,
  };

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await ref.read(csvExporterProvider).exportAndShare();
    } on Object catch (e) {
      _toast('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Who the stats belong to. Anonymous data can be upgraded to a permanent
/// account in place — linking keeps the uid, so nothing needs migrating.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final available = FirebaseBootstrap.isAvailable;
    final user = ref.watch(authUserProvider).value;
    final email = (user != null && !user.isAnonymous) ? user.email : null;
    final signedIn = email != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                signedIn ? Icons.verified_user : Icons.person_outline,
                size: 20,
                color: signedIn ? AppColors.volt : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email ?? 'Guest',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      signedIn
                          ? 'It’s you — every stat syncs to this account.'
                          : (available
                                ? 'Create an account so your stats survive '
                                      'reinstalls and new phones.'
                                : (FirebaseBootstrap.unavailableReason ??
                                      'Offline — account unavailable.')),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (available) ...[
            const SizedBox(height: AppSpacing.md),
            if (!signedIn)
              Row(
                children: [
                  Expanded(
                    child: VoltButton(
                      label: 'Create account',
                      height: 46,
                      onPressed: () => _open(context, ref, createMode: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GhostButton(
                      label: 'Sign in',
                      expanded: true,
                      onPressed: () => _open(context, ref, createMode: false),
                    ),
                  ),
                ],
              )
            else
              GhostButton(
                label: 'Sign out',
                icon: Icons.logout,
                expanded: true,
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out — back to guest mode.'),
                      ),
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref, {
    required bool createMode,
  }) async {
    final ok = await AccountSheet.show(context, createMode: createMode);
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createMode
                ? 'Account created — your stats now live on it.'
                : 'Signed in — stats synced to your account.',
          ),
        ),
      );
    }
  }
}

/// Pick which weekday each workout runs on. Arms is a full training day like
/// the others — with the default schedule that's 4 gym days out of 7.
class _TrainingDaysCard extends ConsumerWidget {
  const _TrainingDaysCard();

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
            'off the schedule.',
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
    final accent = _accent(template.accentHex);

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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: template.weekday == null
                      ? AppColors.textTertiary
                      : accent,
                  fontWeight: FontWeight.w700,
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

  static Color _accent(String? hex) {
    if (hex == null || hex.length < 7) return AppColors.volt;
    final parsed = int.tryParse(hex.substring(1), radix: 16);
    return parsed == null ? AppColors.volt : Color(0xFF000000 | parsed);
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
          color: selected ? accent.withValues(alpha: 0.22) : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? accent : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Live Health Connect / Apple Health link status with a one-tap connect.
class _HealthStatusRow extends ConsumerStatefulWidget {
  const _HealthStatusRow();

  @override
  ConsumerState<_HealthStatusRow> createState() => _HealthStatusRowState();
}

class _HealthStatusRowState extends ConsumerState<_HealthStatusRow> {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Connected — steps are syncing.'
              : 'Not connected. Open ${HealthService.providerName} and allow '
                    'IronLog to read steps, sleep and weight.',
        ),
      ),
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
              color: connected ? AppColors.volt : AppColors.danger,
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
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

/// A kg-per-week rate, stepped by 0.05 kg and shown in the user's unit.
class _RateRow extends StatelessWidget {
  const _RateRow({
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
            style: theme.textTheme.titleMedium,
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
class _StepGoalRow extends StatelessWidget {
  const _StepGoalRow({required this.value, required this.onChanged});

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
            style: theme.textTheme.titleMedium,
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

class _StepperRow extends StatelessWidget {
  const _StepperRow({
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
            style: theme.textTheme.titleMedium,
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
