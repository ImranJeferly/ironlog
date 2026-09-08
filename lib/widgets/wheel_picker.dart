import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptics.dart';

/// Big-numeral wheel. Neighbouring values fade and blur out so the selected
/// number reads as the only thing on screen.
class NumberWheel extends StatefulWidget {
  const NumberWheel({
    super.key,
    required this.values,
    required this.index,
    required this.onChanged,
    this.labelOf,
    this.itemExtent = 64,
    this.fontSize = 52,
    this.accent = AppColors.textPrimary,
    this.height = 220,
  });

  /// Displayed values, ascending.
  final List<double> values;
  final int index;
  final ValueChanged<int> onChanged;
  final String Function(double)? labelOf;
  final double itemExtent;
  final double fontSize;
  final Color accent;
  final double height;

  @override
  State<NumberWheel> createState() => _NumberWheelState();
}

class _NumberWheelState extends State<NumberWheel> {
  late FixedExtentScrollController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.index;
    _controller = FixedExtentScrollController(initialItem: widget.index);
  }

  @override
  void didUpdateWidget(covariant NumberWheel old) {
    super.didUpdateWidget(old);
    if (widget.index != _current && widget.index != old.index) {
      _current = widget.index;
      if (_controller.hasClients) {
        _controller.jumpToItem(widget.index);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _label(double v) {
    if (widget.labelOf != null) return widget.labelOf!(v);
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection band behind the centre item: a rack slot — two hard
          // rules with a short red tick on each side.
          IgnorePointer(
            child: Container(
              height: widget.itemExtent,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.025),
                border: const Border.symmetric(
                  horizontal: BorderSide(color: AppColors.borderStrong),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 10, height: 2, color: AppColors.accent),
                  Container(width: 10, height: 2, color: AppColors.accent),
                ],
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: widget.itemExtent,
            perspective: 0.004,
            diameterRatio: 1.9,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _current = index);
              Haptics.tick();
              widget.onChanged(index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, index) {
                final distance = (index - _current).abs();
                final blur = distance == 0 ? 0.0 : (distance * 1.6).clamp(0, 5);
                final opacity = switch (distance) {
                  0 => 1.0,
                  1 => 0.42,
                  2 => 0.2,
                  _ => 0.1,
                };

                final text = Text(
                  _label(widget.values[index]),
                  style: TextStyle(
                    fontFamily: AppFonts.numeric,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    height: 1,
                    color: (distance == 0 ? widget.accent : AppColors.textPrimary)
                        .withValues(alpha: opacity),
                    fontFeatures: const [ui.FontFeature.tabularFigures()],
                  ),
                );

                return Center(
                  child: blur == 0
                      ? text
                      : ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: blur.toDouble(),
                            sigmaY: blur.toDouble(),
                          ),
                          child: text,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds an ascending value list, e.g. 0 → 300 in 0.5 steps.
List<double> wheelValues({
  required double min,
  required double max,
  required double step,
}) {
  final out = <double>[];
  // Integer accumulation avoids floating point drift across hundreds of steps.
  final steps = ((max - min) / step).round();
  for (var i = 0; i <= steps; i++) {
    out.add(double.parse((min + i * step).toStringAsFixed(3)));
  }
  return out;
}

/// Nearest index to [value], so opening the picker lands on the right number.
int nearestIndex(List<double> values, double value) {
  if (values.isEmpty) return 0;
  var best = 0;
  var bestDelta = (values.first - value).abs();
  for (var i = 1; i < values.length; i++) {
    final delta = (values[i] - value).abs();
    if (delta < bestDelta) {
      bestDelta = delta;
      best = i;
    }
  }
  return best;
}
