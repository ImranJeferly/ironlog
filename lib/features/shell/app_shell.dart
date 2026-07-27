import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptics.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../photos/photos_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../update/update_prompt.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;
  bool _updateChecked = false;

  static const _tabs = <_TabSpec>[
    _TabSpec('Today', Icons.bolt_outlined, Icons.bolt),
    _TabSpec('Progress', Icons.show_chart_outlined, Icons.show_chart),
    _TabSpec('History', Icons.calendar_today_outlined, Icons.calendar_today),
    _TabSpec('Photos', Icons.photo_library_outlined, Icons.photo_library),
    _TabSpec('Settings', Icons.tune_outlined, Icons.tune),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onResume());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }

  /// Background work on resume — never blocks the UI, never shows a spinner.
  void _onResume() {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    if (settings.syncEnabled) {
      ref.read(syncControllerProvider.notifier).sync();
    }
    if (settings.healthEnabled) {
      // A week's window, not just today — catches up after days offline.
      ref.read(healthServiceProvider).syncRecent();
    }
    _maybeCheckForUpdate();
  }

  /// Checks GitHub releases once per app session and, if a newer build is out,
  /// offers a one-tap download + install. Silent when up to date or offline.
  Future<void> _maybeCheckForUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;
    final service = ref.read(updateServiceProvider);
    final info = await service.checkForUpdate();
    if (info == null || !mounted) return;
    await promptForUpdate(context, service, info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ProgressScreen(),
          HistoryScreen(),
          PhotosScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _NavBar(
        tabs: _tabs,
        index: _index,
        onChanged: (i) {
          if (i == _index) return;
          Haptics.tick();
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Custom floating nav bar — deliberately not a Material NavigationBar.
class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<_TabSpec> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(child: _item(context, i)),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i) {
    final active = i == index;
    final tab = tabs[i];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.voltDim : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? tab.activeIcon : tab.icon,
              size: 20,
              color: active ? AppColors.volt : AppColors.textTertiary,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.volt : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
