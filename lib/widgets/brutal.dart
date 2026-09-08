import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Graphic vocabulary of the brutalist skin: hazard stripes, grain, stencil
/// watermarks, steel panels, hard rules. Everything here is painted — no
/// bitmaps — so it stays crisp at any size and costs nothing to ship.

/// Diagonal warning stripes. Used as thin strips under headers, on the
/// active-session banner and as the top edge of the nav bar.
class HazardStripes extends StatelessWidget {
  const HazardStripes({
    super.key,
    this.height = 6,
    this.color = AppColors.accent,
    this.background = Colors.transparent,
    this.stripeWidth = 10,
    this.gap = 10,
    this.angle = -0.75,
  });

  final double height;
  final Color color;
  final Color background;
  final double stripeWidth;
  final double gap;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HazardPainter(
          color: color,
          background: background,
          stripeWidth: stripeWidth,
          gap: gap,
          angle: angle,
        ),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  const _HazardPainter({
    required this.color,
    required this.background,
    required this.stripeWidth,
    required this.gap,
    required this.angle,
  });

  final Color color;
  final Color background;
  final double stripeWidth;
  final double gap;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    if (background.a > 0) {
      canvas.drawRect(rect, Paint()..color = background);
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = stripeWidth;
    final period = stripeWidth + gap;
    final dx = math.tan(angle.abs()) * size.height;
    for (var x = -dx - period; x < size.width + period; x += period) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + (angle < 0 ? dx : -dx), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HazardPainter old) =>
      old.color != color ||
      old.background != background ||
      old.stripeWidth != stripeWidth ||
      old.gap != gap ||
      old.angle != angle;
}

/// Film grain laid over the whole app. Tiled from a tiny bundled PNG so it is
/// effectively free to draw; ignores pointer events.
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.055});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/textures/noise.png'),
              repeat: ImageRepeat.repeat,
              scale: 1.6,
            ),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Giant outlined caps bleeding off the edge of a panel — the poster-style
/// watermark behind hero cards ("PUSH", "PR", "REST").
class Stencil extends StatelessWidget {
  const Stencil(
    this.text, {
    super.key,
    this.size = 120,
    this.color = AppColors.textPrimary,
    this.opacity = 0.07,
    this.strokeWidth = 1.2,
    this.filled = false,
    this.alignment = Alignment.bottomRight,
    this.offset = const Offset(12, 18),
  });

  final String text;
  final double size;
  final Color color;
  final double opacity;
  final double strokeWidth;
  final bool filled;
  final Alignment alignment;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: offset,
              child: Text(
                text.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: size,
                  height: 0.85,
                  letterSpacing: 1,
                  foreground: filled
                      ? (Paint()..color = color.withValues(alpha: opacity))
                      : (Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = strokeWidth
                          ..color = color.withValues(alpha: opacity * 2.2)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised steel surface for hero cards: brushed diagonal gradient, a red edge
/// bar and an optional stencil watermark. Hard corners, thick outline.
class SteelPanel extends StatelessWidget {
  const SteelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accent = AppColors.accent,
    this.stencil,
    this.stencilSize = 132,
    this.stripes = true,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color accent;
  final String? stencil;
  final double stencilSize;
  final bool stripes;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(AppColors.cardHigh, accent, 0.10)!,
                    AppColors.card,
                    AppColors.bg,
                  ],
                  stops: const [0, 0.55, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          if (stencil != null)
            Stencil(stencil!, size: stencilSize, color: accent, opacity: 0.09),
          // Accent edge bar.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accent),
          ),
          if (stripes)
            Positioned(
              right: 0,
              top: 0,
              left: 4,
              child: HazardStripes(
                height: 4,
                color: accent.withValues(alpha: 0.55),
                stripeWidth: 6,
                gap: 8,
              ),
            ),
          Padding(padding: padding, child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderStrong),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final wrapped = onTap == null
        ? panel
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: panel,
          );
    return margin == null ? wrapped : Padding(padding: margin!, child: wrapped);
  }
}

/// A thick rule with a short red lead — the brutalist section divider.
class IronRule extends StatelessWidget {
  const IronRule({
    super.key,
    this.color = AppColors.borderStrong,
    this.lead = AppColors.accent,
    this.leadWidth = 28,
    this.thickness = 2,
    this.padding = EdgeInsets.zero,
  });

  final Color color;
  final Color lead;
  final double leadWidth;
  final double thickness;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(width: leadWidth, height: thickness, color: lead),
          Expanded(child: Container(height: thickness, color: color)),
        ],
      ),
    );
  }
}

/// Small square index marker ("01", "02"…) used in exercise lists.
class IndexTag extends StatelessWidget {
  const IndexTag(
    this.index, {
    super.key,
    this.color = AppColors.textTertiary,
    this.size = 28,
    this.filled = false,
  });

  final int index;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.7)),
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        index.toString().padLeft(2, '0'),
        style: AppText.numeric(
          size: size * 0.42,
          color: filled ? AppColors.bg : color,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Hard-edged progress gauge: segmented like a weight rack, not a pill.
class SegmentBar extends StatelessWidget {
  const SegmentBar({
    super.key,
    required this.value,
    this.segments = 12,
    this.height = 10,
    this.color = AppColors.accent,
    this.track = AppColors.cardHigh,
    this.gap = 2,
  });

  /// 0–1.
  final double value;
  final int segments;
  final double height;
  final Color color;
  final Color track;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final lit = (value.clamp(0.0, 1.0) * segments).round();
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < segments; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 220 + i * 18),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: i < lit ? color : track,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Page header: giant Bebas title with an eyebrow above and a rule below.
class BrutalHeader extends StatelessWidget {
  const BrutalHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.sm,
    ),
    this.rule = true,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(title, style: theme.textTheme.headlineLarge),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (rule) ...[
            const SizedBox(height: AppSpacing.sm),
            const IronRule(),
          ],
        ],
      ),
    );
  }
}
