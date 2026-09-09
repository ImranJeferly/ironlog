import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Round avatar: the profile photo from Storage when there is one (or a
/// legacy inline one), otherwise the initial on a red gradient. A
/// live-training ring when [training].
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initial,
    this.photoUrl,
    this.photo,
    this.size = 44,
    this.training = false,
    this.muted = false,
  });

  final String initial;

  /// Storage download URL. Takes precedence over [photo].
  final String? photoUrl;

  /// Legacy inline JPEG from builds before Storage.
  final Uint8List? photo;
  final double size;
  final bool training;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: muted
              ? [AppColors.cardHigh, AppColors.card]
              : [AppColors.accent, AppColors.accentDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initial,
        style: AppText.display(
          size: size * 0.42,
          color: muted ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    );

    final Widget image;
    if (photoUrl != null) {
      // Image.network caches in memory per URL; a failed fetch (offline with
      // a cold cache) shows the initial rather than a broken tile.
      image = Image.network(
        photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (photo != null) {
      image = Image.memory(
        photo!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else {
      image = fallback;
    }
    final inner = ClipOval(child: image);

    return Container(
      width: size + 4,
      height: size + 4,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: training ? AppColors.accent : AppColors.borderStrong,
          width: training ? 2 : 1,
        ),
        boxShadow: training
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.45),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: inner,
    );
  }
}
