import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import 'photo_capture.dart';
import 'photo_compare_screen.dart';

/// Grid timeline of progress photos, grouped by day.
///
/// Used both as the Photos tab inside Progress and as the standalone screen.
class PhotosTimeline extends ConsumerWidget {
  const PhotosTimeline({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photos = ref.watch(photosProvider).value ?? const <PhotoRow>[];

    final grouped = <DateTime, List<PhotoRow>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.date, () => []).add(photo);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: VoltButton(
                  label: 'Add photo',
                  icon: Icons.add_a_photo_outlined,
                  height: 48,
                  onPressed: () => PhotoCapture.show(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconPill(
                icon: Icons.compare_arrows,
                size: 52,
                tooltip: 'Compare two dates',
                color: photos.length >= 2
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                onTap: photos.length < 2
                    ? null
                    : () => PhotoCompareScreen.open(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: days.isEmpty
              ? const EmptyState(
                  title: 'No progress photos yet',
                  icon: Icons.photo_camera_outlined,
                  message:
                      'Front, side and back. Same light, same time of day — '
                      'that’s all it takes.',
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    embedded ? 120 : AppSpacing.xl,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final dayPhotos = grouped[day]!
                      ..sort((a, b) => a.pose.index.compareTo(b.pose.index));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          child: Row(
                            children: [
                              Text(
                                Dates.dayMonthYear(day).toUpperCase(),
                                style: theme.textTheme.labelSmall,
                              ),
                              const Spacer(),
                              Text(
                                '${dayPhotos.length} PHOTO'
                                '${dayPhotos.length == 1 ? '' : 'S'}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            for (final photo in dayPhotos)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _PhotoTile(photo: photo),
                                ),
                              ),
                            // Keep tiles a consistent width on short days.
                            for (
                              var k = dayPhotos.length;
                              k < PhotoPose.values.length;
                              k++
                            )
                              const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({required this.photo});

  final PhotoRow photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openViewer(context, ref),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.cardSmall),
              child: Image.file(
                File(photo.localPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: AppColors.cardHigh,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                  border: Border(
                    left: BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
                child: Text(
                  photo.pose.label,
                  style: AppText.eyebrow(
                    size: 11,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openViewer(BuildContext context, WidgetRef ref) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: InteractiveViewer(
                  child: Image.file(File(photo.localPath)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VoltBadge(
                  '${photo.pose.label} · ${Dates.dayMonthYear(photo.date)}',
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                IconPill(
                  icon: Icons.delete_outline,
                  color: AppColors.danger,
                  onTap: () async {
                    await ref
                        .read(photoRepositoryProvider)
                        .deletePhoto(photo.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
