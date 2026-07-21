import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Drag-to-reveal comparison between two progress photos.
class CompareSlider extends StatefulWidget {
  const CompareSlider({
    super.key,
    required this.beforePath,
    required this.afterPath,
    this.beforeLabel,
    this.afterLabel,
    this.aspectRatio = 3 / 4,
  });

  final String beforePath;
  final String afterPath;
  final String? beforeLabel;
  final String? afterLabel;
  final double aspectRatio;

  @override
  State<CompareSlider> createState() => _CompareSliderState();
}

class _CompareSliderState extends State<CompareSlider> {
  double _position = 0.5;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          void updateFromDx(double dx) {
            setState(() => _position = (dx / width).clamp(0.0, 1.0));
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: GestureDetector(
              onHorizontalDragUpdate: (d) => updateFromDx(d.localPosition.dx),
              onTapDown: (d) => updateFromDx(d.localPosition.dx),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(widget.afterPath),
                  // The "before" side is clipped to the left of the handle.
                  ClipRect(
                    clipper: _LeftClipper(_position),
                    child: _image(widget.beforePath),
                  ),
                  if (widget.beforeLabel != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _tag(widget.beforeLabel!),
                    ),
                  if (widget.afterLabel != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _tag(widget.afterLabel!),
                    ),
                  Positioned(
                    left: _position * width - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: AppColors.volt),
                  ),
                  Positioned(
                    left: _position * width - 18,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.volt,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.unfold_more,
                          size: 20,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _image(String path) {
    final file = File(path);
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.cardHigh,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _tag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppRadii.chip),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _LeftClipper extends CustomClipper<Rect> {
  const _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper old) => old.fraction != fraction;
}
