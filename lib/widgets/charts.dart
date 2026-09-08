import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_x.dart';

class ChartSeries {
  const ChartSeries({
    required this.dates,
    required this.values,
    this.label = '',
    this.gradient,
    this.dashed = false,
    this.showArea = true,
  });

  final List<DateTime> dates;
  final List<double> values;
  final String label;
  final Gradient? gradient;
  final bool dashed;
  final bool showArea;

  bool get isEmpty => values.isEmpty;
}

/// Animated line chart with the purple→blue gradient reserved for charts.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    this.height = 200,
    this.valueSuffix = '',
    this.minYPadding = 0.08,
  });

  final List<ChartSeries> series;
  final double height;
  final String valueSuffix;
  final double minYPadding;

  @override
  Widget build(BuildContext context) {
    final visible = series.where((s) => !s.isEmpty).toList();
    if (visible.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data yet',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final allValues = visible.expand((s) => s.values).toList();
    var minY = allValues.reduce(math.min);
    var maxY = allValues.reduce(math.max);
    if (minY == maxY) {
      // A single flat line still deserves a sensible band.
      minY -= math.max(1, minY.abs() * 0.05);
      maxY += math.max(1, maxY.abs() * 0.05);
    } else {
      final pad = (maxY - minY) * minYPadding;
      minY -= pad;
      maxY += pad;
    }

    final pointCount = visible.map((s) => s.values.length).reduce(math.max);
    final labelDates = visible.first.dates;

    return SizedBox(
      height: height,
      child: LineChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        LineChartData(
          minX: 0,
          maxX: (pointCount - 1).toDouble().clamp(0.0001, double.infinity),
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: (maxY - minY) / 2,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _short(value) + valueSuffix,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: math.max(1, (pointCount - 1) / 3).toDouble(),
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= labelDates.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Dates.dayMonth(labelDates[i]),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.cardHigh,
              tooltipBorderRadius: BorderRadius.circular(AppRadii.chip),
              tooltipBorder: const BorderSide(color: AppColors.borderStrong),
              getTooltipItems: (spots) => spots.map((spot) {
                final i = spot.x.round();
                final date = i >= 0 && i < labelDates.length
                    ? Dates.dayMonth(labelDates[i])
                    : '';
                return LineTooltipItem(
                  '${_short(spot.y)}$valueSuffix\n',
                  AppText.numeric(size: 14, letterSpacing: 0),
                  children: [
                    TextSpan(
                      text: date,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            for (final s in visible)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < s.values.length; i++)
                    FlSpot(i.toDouble(), s.values[i]),
                ],
                // Straight segments — the brutalist chart is a polyline, not
                // a spline.
                isCurved: false,
                barWidth: s.dashed ? 2 : 2.5,
                dashArray: s.dashed ? const [5, 5] : null,
                gradient: s.gradient ?? AppColors.chartGradient,
                dotData: FlDotData(
                  show: s.values.length <= 14 && !s.dashed,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotSquarePainter(
                        size: 6,
                        color: AppColors.bg,
                        strokeWidth: 2,
                        strokeColor: AppColors.accent,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: s.showArea && !s.dashed,
                  gradient: AppColors.chartAreaGradient,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _short(double v) {
    if (v.abs() >= 10000) return '${(v / 1000).toStringAsFixed(0)}k';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
  }
}

class BarDatum {
  const BarDatum({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Horizontal-labelled vertical bars — weekly sets per muscle group.
class GroupBarChart extends StatelessWidget {
  const GroupBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.valueSuffix = '',
  });

  final List<BarDatum> data;
  final double height;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((d) => d.value == 0)) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No sets logged yet',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final maxY = data.map((d) => d.value).reduce(math.max) * 1.25;

    return SizedBox(
      height: height,
      child: BarChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[i].label,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.cardHigh,
              tooltipBorderRadius: BorderRadius.circular(AppRadii.chip),
              tooltipBorder: const BorderSide(color: AppColors.borderStrong),
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    '${rod.toY.round()}$valueSuffix',
                    AppText.numeric(size: 13, letterSpacing: 0),
                  ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value,
                    width: 18,
                    borderRadius: BorderRadius.zero,
                    gradient: LinearGradient(
                      colors: [
                        data[i].color.withValues(alpha: 0.55),
                        data[i].color,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: AppColors.cardHigh,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A chart wrapped in a titled card, with an optional headline figure.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.headline,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? headline;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 11,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title.toUpperCase(),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    if (headline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        headline!,
                        style: AppText.numeric(size: 26, letterSpacing: -0.5),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
