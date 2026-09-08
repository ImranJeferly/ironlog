import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/notifications.dart';
import '../../core/utils/haptics.dart';
import '../../widgets/brutal.dart';
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
    Notifications.pendingRoute.addListener(_onNotificationRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onResume();
      _onNotificationRoute();
    });
  }

  @override
  void dispose() {
    Notifications.pendingRoute.removeListener(_onNotificationRoute);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// A tapped notification asked for a screen — the nightly nutrition nudge
  /// deep-links to the Today card on the Home tab.
  void _onNotificationRoute() {
    final route = Notifications.pendingRoute.value;
    if (route == null || !mounted) return;
    Notifications.pendingRoute.value = null;
    if (route == Notifications.routeToday && _index != 0) {
      setState(() => _index = 0);
    }
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
    // Cheap and idempotent: keeps the 21:00 nudge alive across reinstalls
    // and reboots without a boot receiver.
    Notifications.syncNutritionReminder(
      enabled: settings.nutritionReminderEnabled,
    );
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

/// Full-bleed steel nav bar — a hard slab with a hazard edge, not a floating
/// pill. The active tab carries a red top bar and a filled icon.
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HazardStripes(
              height: 3,
              color: AppColors.steel,
              stripeWidth: 6,
              gap: 10,
            ),
            SizedBox(
              height: 58,
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                    Expanded(child: _item(context, i)),
                  ],
                ],
              ),
            ),
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
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: 0,
            left: active ? 0 : 24,
            right: active ? 0 : 24,
            child: Container(
              height: 3,
              color: active ? AppColors.accent : Colors.transparent,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  active ? tab.activeIcon : tab.icon,
                  size: 20,
                  color: active ? AppColors.textPrimary : AppColors.textTertiary,
                ),
                const SizedBox(height: 4),
                Text(
                  // Bebas renders caps; keep the label as written so it
                  // stays findable by name.
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppText.eyebrow(
                    size: 12,
                    letterSpacing: 1.6,
                    color: active ? AppColors.accent : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
