import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/first_run/first_run_screen.dart';
import '../features/shell/app_shell.dart';
import 'providers.dart';

class IronLogApp extends ConsumerWidget {
  const IronLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      themeMode: ThemeMode.dark,
      home: settings.firstRunComplete
          ? const AppShell()
          : const FirstRunScreen(),
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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
