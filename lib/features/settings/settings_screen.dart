import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../data/sync/firebase_bootstrap.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;

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

          const SectionHeader('Apple Health'),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Read steps, sleep and weight',
                  subtitle: 'Manual entries are never overwritten.',
                  value: settings.healthEnabled,
                  onChanged: controller.setHealthEnabled,
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
