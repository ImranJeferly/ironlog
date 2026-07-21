import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../core/utils/haptics.dart';
import '../domain/enums.dart';
import '../domain/pr_detector.dart';

/// Full-screen flash shown the moment a set breaks a record.
///
/// Deliberately transient — it auto-dismisses so it never stands between you
/// and the next set.
class PrCelebration extends StatefulWidget {
  const PrCelebration({
    super.key,
    required this.pr,
    required this.exerciseName,
    required this.unit,
  });

  final PrCandidate pr;
  final String exerciseName;
  final WeightUnit unit;

  /// Shows the overlay and returns once it has faded out.
  static Future<void> show(
    BuildContext context, {
    required PrCandidate pr,
    required String exerciseName,
    required WeightUnit unit,
  }) {
    Haptics.celebrate();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PR',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => PrCelebration(
        pr: pr,
        exerciseName: exerciseName,
        unit: unit,
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }

  @override
  State<PrCelebration> createState() => _PrCelebrationState();
}

class _PrCelebrationState extends State<PrCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _value => switch (widget.pr.type) {
    PrType.reps => '${widget.pr.reps} reps',
    PrType.weight => Fmt.weight(widget.pr.value, widget.unit),
    PrType.estimated1RM => Fmt.weight(widget.pr.value, widget.unit),
  };

  String? get _previous {
    final prev = widget.pr.previousValue;
    if (prev == null || prev <= 0) return null;
    return switch (widget.pr.type) {
      PrType.reps => 'was ${prev.round()} reps',
      _ => 'was ${Fmt.weight(prev, widget.unit)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Sparks(controller: _controller),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.volt, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.volt.withValues(alpha: 0.25),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.volt, size: 42),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.pr.type.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.volt,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _value,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.volt,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.exerciseName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (_previous != null) ...[
                      const SizedBox(height: 4),
                      Text(_previous!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cheap confetti: volt shards flung outward on a single controller.
class _Sparks extends StatelessWidget {
  const _Sparks({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        size: const Size(340, 340),
        painter: _SparkPainter(controller.value),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.t);

  final double t;
  static const _count = 22;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(7);
    final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));

    for (var i = 0; i < _count; i++) {
      final angle = (i / _count) * math.pi * 2 + random.nextDouble() * 0.4;
      final distance = (70 + random.nextDouble() * 90) * eased;
      final opacity = (1 - t).clamp(0.0, 1.0);
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * distance;

      final paint = Paint()
        ..color = (i.isEven ? AppColors.volt : AppColors.chartTo).withValues(
          alpha: opacity,
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle + t * 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 4, height: 10),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.t != t;
}
