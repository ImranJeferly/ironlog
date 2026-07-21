import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_x.dart';
import '../core/utils/haptics.dart';

/// GitHub-style contribution grid: one column per week, one square per day.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    super.key,
    required this.valuesByDay,
    this.weeks = 26,
    this.onDayTap,
    this.squareSize = 13,
    this.gap = 4,
  });

  /// Working sets logged on each day. Missing days render as empty.
  final Map<DateTime, int> valuesByDay;
  final int weeks;
  final void Function(DateTime day, int value)? onDayTap;
  final double squareSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().dayStart;
    // Finish on the Sunday of this week so the last column is always complete.
    final end = today.weekStart.add(const Duration(days: 6));
    final start = end.subtract(Duration(days: weeks * 7 - 1));

    final maxValue = valuesByDay.values.isEmpty
        ? 0
        : valuesByDay.values.reduce((a, b) => a > b ? a : b);

    final columns = <Widget>[];
    var monthCursor = -1;

    for (var w = 0; w < weeks; w++) {
      final weekStart = start.add(Duration(days: w * 7));
      final showMonth = weekStart.month != monthCursor;
      monthCursor = weekStart.month;

      columns.add(
        Padding(
          padding: EdgeInsets.only(right: gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 14,
                width: squareSize,
                child: showMonth
                    ? Text(
                        Dates.monthYear(weekStart).substring(0, 3),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                        ),
                      )
                    : null,
              ),
              for (var d = 0; d < 7; d++)
                _square(weekStart.add(Duration(days: d)), today, maxValue),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns),
    );
  }

  Widget _square(DateTime day, DateTime today, int maxValue) {
    final future = day.isAfter(today);
    final value = valuesByDay[day] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: future || onDayTap == null
            ? null
            : () {
                Haptics.light();
                onDayTap!(day, value);
              },
        child: Container(
          width: squareSize,
          height: squareSize,
          decoration: BoxDecoration(
            color: future
                ? Colors.transparent
                : _colorFor(value, maxValue),
            borderRadius: BorderRadius.circular(3.5),
            border: day.isSameDay(today)
                ? Border.all(color: AppColors.volt, width: 1.4)
                : null,
          ),
        ),
      ),
    );
  }

  Color _colorFor(int value, int maxValue) {
    if (value <= 0) return AppColors.heatEmpty;
    if (maxValue <= 0) return AppColors.heatSteps.first;
    // Four bands, so a light day still reads clearly against a heavy one.
    final ratio = value / maxValue;
    final index = (ratio * AppColors.heatSteps.length).ceil().clamp(
      1,
      AppColors.heatSteps.length,
    );
    return AppColors.heatSteps[index - 1];
  }
}

/// Colour key shown under the heatmap.
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
        const SizedBox(width: 6),
        _dot(AppColors.heatEmpty),
        for (final c in AppColors.heatSteps) _dot(c),
        const SizedBox(width: 6),
        const Text(
          'More',
          style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}
