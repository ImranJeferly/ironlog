import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../widgets/brutal.dart';
import 'app_gate.dart';

class IronLogApp extends ConsumerWidget {
  const IronLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      themeMode: ThemeMode.dark,
      home: const AppGate(),
      builder: (context, child) {
        // Lock text scaling to a sane band so the big numerals never wreck the
        // wheel picker layout.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          // Film grain over everything — the one texture the whole skin
          // shares. Pointer-transparent, drawn from a tiny tiled PNG.
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const GrainOverlay(),
            ],
          ),
        );
      },
    );
  }
}
