import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';

/// Tape measurements. The scale tells you the direction; these tell you where
/// it's going. One row per site, showing the latest value and when it was
/// taken, tap to log a new one against today.
class MeasurementsCard extends ConsumerWidget {
  const MeasurementsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Rebuilds when a metric changes anywhere.
    ref.watch(todayMetricsProvider);
    final latest = ref.watch(latestMeasurementsProvider).value ?? const {};

    return AppCard(
      child: Column(
        children: [
          for (final m in BodyMeasurement.values) ...[
            if (m != BodyMeasurement.values.first)
              const Divider(height: AppSpacing.lg),
            _Row(
              measurement: m,
              value: latest[m]?.$1,
              takenAt: latest[m]?.$2,
              onTap: () => _edit(context, ref, m, latest[m]?.$1),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Measure cold, same time of day, same spot. Consistency beats '
            'precision.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    BodyMeasurement measurement,
    double? current,
  ) async {
    final controller = TextEditingController(
      text: current == null ? '' : _trim(current),
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(measurement.label),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: const InputDecoration(
            hintText: 'Centimetres',
            suffixText: 'cm',
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;

    final cm = value.trim().isEmpty
        ? null
        : double.tryParse(value.trim().replaceAll(',', '.'));
    if (value.trim().isNotEmpty && cm == null) return;
    await ref
        .read(metricsRepositoryProvider)
        .setMeasurement(DateTime.now(), measurement, cm);
    ref.invalidate(latestMeasurementsProvider);
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class _Row extends StatelessWidget {
  const _Row({
    required this.measurement,
    required this.value,
    required this.takenAt,
    required this.onTap,
  });

  final BodyMeasurement measurement;
  final double? value;
  final DateTime? takenAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.cardSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(measurement.label, style: theme.textTheme.titleSmall),
                  if (takenAt != null)
                    Text(
                      Dates.relativeDay(takenAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Text(
              value == null ? '—' : '${MeasurementsCard._trim(value!)} cm',
              style: AppText.numeric(
                size: 18,
                color: value == null
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
