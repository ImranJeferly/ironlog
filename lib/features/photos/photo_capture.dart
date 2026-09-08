import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';

/// Pose + source picker, then hands the file to the repository which
/// compresses it and stores it locally.
class PhotoCapture extends ConsumerStatefulWidget {
  const PhotoCapture({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => const PhotoCapture(),
    );
  }

  @override
  ConsumerState<PhotoCapture> createState() => _PhotoCaptureState();
}

class _PhotoCaptureState extends ConsumerState<PhotoCapture> {
  PhotoPose _pose = PhotoPose.front;
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD PROGRESS PHOTO', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            const IronRule(),
            const SizedBox(height: AppSpacing.md),

            Text('POSE', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            PillToggle<PhotoPose>(
              values: PhotoPose.values,
              selected: _pose,
              labelOf: (p) => p.label,
              onChanged: (p) => setState(() => _pose = p),
            ),

            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('DATE', style: theme.textTheme.labelSmall),
                const Spacer(),
                GhostButton(
                  label: Dates.dayMonthYear(_date),
                  icon: Icons.calendar_today_outlined,
                  height: 40,
                  onPressed: _pickDate,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Gallery',
                    icon: Icons.photo_library_outlined,
                    expanded: true,
                    height: 52,
                    onPressed: _busy ? null : () => _pick(fromCamera: false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: VoltButton(
                    label: 'Camera',
                    icon: Icons.photo_camera_outlined,
                    height: 52,
                    onPressed: _busy ? null : () => _pick(fromCamera: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Compressed and saved to this device only, on local storage. '
              'Progress photos are never uploaded anywhere.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.textPrimary,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pick({required bool fromCamera}) async {
    setState(() => _busy = true);
    final repo = ref.read(photoRepositoryProvider);
    try {
      final file = await repo.pick(fromCamera: fromCamera);
      if (file == null) return;
      await repo.importPhoto(source: file, pose: _pose, date: _date);
      if (mounted) {
        unawaited(ref.read(syncControllerProvider.notifier).sync());
        Navigator.of(context).pop();
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
