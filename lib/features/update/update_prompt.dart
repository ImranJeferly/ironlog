import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/update/update_service.dart';
import '../../widgets/buttons.dart';

/// Shows the "update available" sheet and, on confirm, downloads + installs.
Future<void> promptForUpdate(
  BuildContext context,
  UpdateService service,
  UpdateInfo info,
) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
      final notes = info.notes.trim();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.voltDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.system_update,
                      color: AppColors.volt,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update available',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          info.versionName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: SingleChildScrollView(
                    child: Text(
                      notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GhostButton(
                      label: 'Later',
                      expanded: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: VoltButton(
                      label: 'Update now',
                      icon: Icons.download_rounded,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (accepted != true || !context.mounted) return;
  await _downloadWithProgress(context, service, info);
}

Future<void> _downloadWithProgress(
  BuildContext context,
  UpdateService service,
  UpdateInfo info,
) async {
  final progress = ValueNotifier<double>(0);
  var closed = false;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.cardHigh,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Downloading update…', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value <= 0 ? null : value,
                    minHeight: 8,
                    backgroundColor: AppColors.card,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.volt),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value <= 0 ? 'Starting…' : '${(value * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  final ok = await service.downloadAndInstall(
    info,
    onProgress: (v) => progress.value = v,
  );

  if (context.mounted && !closed) {
    closed = true;
    Navigator.of(context, rootNavigator: true).pop();
  }
  progress.dispose();

  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Update download failed. Try again from Settings.'),
      ),
    );
  }
}
