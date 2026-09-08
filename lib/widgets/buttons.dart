import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/haptics.dart';

/// The primary CTA — a hard red slab with Bebas caps. Pressing it drops the
/// slab onto its shadow and taps a haptic.
class VoltButton extends StatefulWidget {
  const VoltButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.height = 56,
    this.color = AppColors.accent,
    this.foreground = AppColors.textPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final double height;
  final Color color;
  final Color foreground;

  @override
  State<VoltButton> createState() => _VoltButtonState();
}

class _VoltButtonState extends State<VoltButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final fg = enabled
        ? widget.foreground
        : widget.foreground.withValues(alpha: 0.5);
    final drop = enabled && !_down ? 4.0 : 0.0;

    final button = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              Haptics.impact();
              widget.onPressed!();
            }
          : null,
      child: SizedBox(
        height: widget.height + 4,
        child: Stack(
          children: [
            // Hard offset shadow — the slab sits on it and drops when pressed.
            Positioned.fill(
              top: 4,
              left: 4,
              right: -4,
              bottom: 0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.accentDeep.withValues(alpha: 0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              left: 4 - drop,
              right: drop,
              top: 4 - drop,
              bottom: drop,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: enabled
                      ? widget.color
                      : widget.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                child: Row(
                  mainAxisSize: widget.expanded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: fg),
                      const SizedBox(width: 10),
                    ],
                    // Long labels shrink instead of overflowing the slab.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        // Bebas has no lowercase — the face does the shouting,
                        // so labels stay as written (and findable in tests).
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          style: AppText.display(
                            size: widget.height >= 52 ? 20 : 17,
                            color: fg,
                            letterSpacing: 1.6,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return widget.expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Outlined slab for secondary actions.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = false,
    this.color = AppColors.textSecondary,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                Haptics.light();
                onPressed!();
              },
        borderRadius: BorderRadius.circular(AppRadii.chip),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chip),
            border: Border.all(
              color: color == AppColors.textSecondary
                  ? AppColors.borderStrong
                  : color.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              // Long labels shrink instead of overflowing.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppText.display(
                      size: 16,
                      color: color,
                      letterSpacing: 1.4,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Segmented selector (kg/lb, day/week/month, front/side/back) — hard cells
/// separated by hairlines, red fill on the active one.
class PillToggle<T> extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.expanded = true,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            _segment(context, values[i], values[i] == selected),
          ],
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, T value, bool active) {
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!active) {
          Haptics.tick();
          onChanged(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          labelOf(value),
          style: AppText.display(
            size: 15,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            letterSpacing: 1.4,
            height: 1,
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: child) : child;
  }
}

/// Square icon button used in app bars and card corners.
class IconPill extends StatelessWidget {
  const IconPill({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppColors.textSecondary,
    this.background,
    this.size = 40,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color? background;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              Haptics.light();
              onTap!();
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Icon(icon, size: size * 0.45, color: color),
      ),
    );

    return tooltip == null
        ? button
        : Tooltip(message: tooltip!, child: button);
  }
}

/// Square red tick box for the cardio / sauna checkmarks.
class VoltCheck extends StatelessWidget {
  const VoltCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.icon,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.impact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppColors.voltDim : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(
            color: value ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: value ? AppColors.accent : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 15,
                      color: AppColors.textPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: value ? AppColors.accent : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(
                  size: 16,
                  color: value ? AppColors.textPrimary : AppColors.textSecondary,
                  letterSpacing: 1.2,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
