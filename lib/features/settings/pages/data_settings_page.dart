import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/sync/firebase_bootstrap.dart';
import '../../../domain/enums.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/buttons.dart';
import '../settings_widgets.dart';

/// Cloud sync and the CSV escape hatch.
class DataSettingsPage extends ConsumerStatefulWidget {
  const DataSettingsPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const DataSettingsPage()),
  );

  @override
  ConsumerState<DataSettingsPage> createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends ConsumerState<DataSettingsPage> {
  bool _exporting = false;
  bool _importing = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await ref.read(csvExporterProvider).exportAndShare();
    } on Object catch (e) {
      if (mounted) showSettingsToast(context, 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Restore picks the file itself and decides from the header which kind of
  /// export it is, so the user doesn't have to say.
  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final picked = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'CSV', extensions: ['csv']),
        ],
      );
      if (picked == null) return;
      final file = File(picked.path);
      final head = (await file.readAsString()).split(RegExp(r'\r?\n')).first;
      final importer = ref.read(csvImporterProvider);
      final report = head.contains('session_id')
          ? await importer.importSessions(file)
          : head.contains('water_ml')
          ? await importer.importMetrics(file)
          : null;

      if (!mounted) return;
      if (report == null) {
        showSettingsToast(
          context,
          'That isn\'t an IronLog sessions or metrics export.',
        );
        return;
      }
      ref.read(analyticsRevisionProvider.notifier).bump();
      showSettingsToast(context, report.summary);
    } on Object catch (e) {
      if (mounted) showSettingsToast(context, 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  IconData _syncIcon(SyncState state) => switch (state) {
    SyncState.syncing => Icons.sync,
    SyncState.success => Icons.cloud_done_outlined,
    SyncState.failed => Icons.cloud_off_outlined,
    SyncState.disabled => Icons.cloud_off_outlined,
    SyncState.idle => Icons.cloud_queue,
  };

  Color _syncColor(SyncState state) => switch (state) {
    SyncState.success => AppColors.accent,
    SyncState.failed => AppColors.danger,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final sync = ref.watch(syncControllerProvider);

    return SettingsPage(
      title: 'Sync & data',
      children: [
        const SectionHeader('Sync'),
        AppCard(
          child: Column(
            children: [
              SettingsSwitchRow(
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
                        : () =>
                              ref.read(syncControllerProvider.notifier).sync(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SectionHeader('Your data'),
        AppCard(
          child: Row(
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
                    Text('Export CSV', style: theme.textTheme.titleSmall),
                    Text(
                      'Sessions, metrics, PRs and weekly volume. It’s your '
                      'data.',
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
        ),
        AppCard(
          child: Row(
            children: [
              const Icon(
                Icons.restore_page_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restore from CSV', style: theme.textTheme.titleSmall),
                    Text(
                      'Reads a sessions or metrics export back in. Existing '
                      'days and sessions are left alone.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GhostButton(
                label: _importing ? 'Working…' : 'Restore',
                height: 40,
                onPressed: _importing ? null : _import,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
