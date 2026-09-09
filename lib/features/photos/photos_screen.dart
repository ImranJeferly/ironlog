import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/brutal.dart';
import 'photos_timeline.dart';

class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key, this.embedded = false});

  /// True when shown as a tab inside Progress, which already has its own
  /// header — so this one is dropped rather than stacking two titles.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (embedded) return const PhotosTimeline(embedded: true);
    return const SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalHeader(
            title: 'Photos',
            eyebrow: 'Same light, same pose, every month',
          ),
          Expanded(child: PhotosTimeline(embedded: true)),
        ],
      ),
    );
  }
}
