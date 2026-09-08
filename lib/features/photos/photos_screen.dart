import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/brutal.dart';
import 'photos_timeline.dart';

class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
