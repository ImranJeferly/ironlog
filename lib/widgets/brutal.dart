import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Accent vocabulary of the skin: hero panels with a red glow, thin red-led
/// rules, index tags, rounded gauges, page headers. Everything is painted so
/// it stays crisp at any size.

/// Diagonal stripes. Kept for the volume target band; used sparingly.
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

/// Faint oversized word behind a hero panel. Kept very quiet — a texture,
/// not a headline.
class Stencil extends StatelessWidget {
  const Stencil(
    this.text, {
    super.key,
    this.size = 120,
    this.color = AppColors.textPrimary,
    this.opacity = 0.04,
    this.alignment = Alignment.bottomRight,
    this.offset = const Offset(12, 18),
  });

  final String text;
  final double size;
  final Color color;
  final double opacity;
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
                  fontWeight: FontWeight.w700,
                  height: 0.85,
                  letterSpacing: -2,
                  color: color.withValues(alpha: opacity),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero surface: rounded card with a red-tinted gradient, a red outline and
/// a soft glow — the card that starts a session.
class SteelPanel extends StatelessWidget {
  const SteelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accent = AppColors.accent,
    this.stencil,
    this.stencilSize = 132,
    this.stripes = false,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color accent;
  final String? stencil;
  final double stencilSize;

  /// Unused — kept so call sites don't churn.
  final bool stripes;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(AppColors.card, accent, 0.18)!,
                      AppColors.card,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            if (stencil != null)
              Stencil(stencil!, size: stencilSize, color: accent),
            Padding(padding: padding, child: child),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
              ),
            ),
          ],
        ),
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

/// A hairline with a short red lead — the section divider.
class IronRule extends StatelessWidget {
  const IronRule({
    super.key,
    this.color = AppColors.border,
    this.lead = AppColors.accent,
    this.leadWidth = 24,
    this.thickness = 1.5,
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
          Container(
            width: leadWidth,
            height: thickness,
            decoration: BoxDecoration(
              color: lead,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
          Expanded(child: Container(height: thickness, color: color)),
        ],
      ),
    );
  }
}

/// Small rounded index marker ("01", "02"…) used in exercise lists.
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
        border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.6)),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        index.toString().padLeft(2, '0'),
        style: AppText.numeric(
          size: size * 0.42,
          color: filled ? AppColors.textPrimary : color,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Rounded progress gauge with a soft glow on the filled part.
class SegmentBar extends StatelessWidget {
  const SegmentBar({
    super.key,
    required this.value,
    this.segments = 12,
    this.height = 8,
    this.color = AppColors.accent,
    this.track = AppColors.cardHigh,
    this.gap = 2,
  });

  /// 0–1.
  final double value;

  /// Unused — kept so call sites don't churn.
  final int segments;
  final double height;
  final Color color;
  final Color track;

  /// Unused — kept so call sites don't churn.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final fill = value.clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              width: c.maxWidth * fill,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: fill > 0
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page header: condensed title with an optional red eyebrow above and a
/// thin rule below.
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
                        eyebrow!.toUpperCase(),
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
