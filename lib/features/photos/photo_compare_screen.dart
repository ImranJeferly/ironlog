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
import '../../widgets/compare_slider.dart';

/// Side-by-side comparison of the same pose on two different dates.
class PhotoCompareScreen extends ConsumerStatefulWidget {
  const PhotoCompareScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PhotoCompareScreen()),
    );
  }

  @override
  ConsumerState<PhotoCompareScreen> createState() => _PhotoCompareScreenState();
}

class _PhotoCompareScreenState extends ConsumerState<PhotoCompareScreen> {
  PhotoPose _pose = PhotoPose.front;
  DateTime? _before;
  DateTime? _after;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(photosProvider).value ?? const <PhotoRow>[];
    final forPose = all.where((p) => p.pose == _pose).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final dates = forPose.map((p) => p.date).toSet().toList()..sort();

    // Default to the widest span available for this pose.
    final before = _before ?? (dates.isNotEmpty ? dates.first : null);
    final after = _after ?? (dates.isNotEmpty ? dates.last : null);

    final beforePhoto = _photoFor(forPose, before);
    final afterPhoto = _photoFor(forPose, after);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Compare')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          PillToggle<PhotoPose>(
            values: PhotoPose.values,
            selected: _pose,
            labelOf: (p) => p.label,
            onChanged: (p) => setState(() {
              _pose = p;
              _before = null;
              _after = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),

          if (dates.length < 2)
            const AppCard(
              child: SizedBox(
                height: 240,
                child: EmptyState(
                  title: 'Need two dates',
                  icon: Icons.compare_arrows,
                  message:
                      'Take this pose on at least two different days to '
                      'compare them.',
                ),
              ),
            )
          else if (beforePhoto != null && afterPhoto != null) ...[
            CompareSlider(
              beforePath: beforePhoto.localPath,
              afterPath: afterPhoto.localPath,
              beforeLabel: Dates.dayMonthYear(beforePhoto.date),
              afterLabel: Dates.dayMonthYear(afterPhoto.date),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Drag the handle to reveal.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _DatePickRow(
              label: 'Before',
              dates: dates,
              selected: before,
              onChanged: (d) => setState(() => _before = d),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DatePickRow(
              label: 'After',
              dates: dates,
              selected: after,
              onChanged: (d) => setState(() => _after = d),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.timelapse,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${Dates.daysBetween(beforePhoto.date, afterPhoto.date).abs()}',
                    style: AppText.numeric(size: 18, letterSpacing: 0),
                  ),
                  Text(
                    '  DAYS APART',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  PhotoRow? _photoFor(List<PhotoRow> photos, DateTime? date) {
    if (date == null) return null;
    for (final photo in photos) {
      if (photo.date.isSameDay(date)) return photo;
    }
    return null;
  }
}

class _DatePickRow extends StatelessWidget {
  const _DatePickRow({
    required this.label,
    required this.dates,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<DateTime> dates;
  final DateTime? selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final date = dates[i];
              final active = selected != null && date.isSameDay(selected!);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(date),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                      border: Border.all(
                        color: active
                            ? AppColors.accent
                            : AppColors.borderStrong,
                      ),
                    ),
                    child: Text(
                      Dates.dayMonth(date),
                      style: AppText.display(
                        size: 15,
                        letterSpacing: 1,
                        height: 1,
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
