import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/buttons.dart';
import '../../update/update_prompt.dart';
import '../settings_widgets.dart';

/// Version, updates and the small print.
class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
  );

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  bool _checking = false;

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    final service = ref.read(updateServiceProvider);
    final info = await service.checkForUpdate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (info == null) {
      showSettingsToast(context, 'You’re on the latest version');
      return;
    }
    await promptForUpdate(context, service, info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsPage(
      title: 'About',
      children: [
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              const Image(
                image: AssetImage('assets/branding/app_icon.png'),
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IronLog', style: theme.textTheme.headlineSmall),
                    FutureBuilder<String>(
                      future: ref
                          .read(updateServiceProvider)
                          .currentVersionName(),
                      builder: (context, snap) => Text(
                        snap.data == null || snap.data!.isEmpty
                            ? 'Offline-first training log'
                            : 'v${snap.data} · offline-first',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SectionHeader('Updates'),
        AppCard(
          child: Row(
            children: [
              const Icon(
                Icons.system_update,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App updates', style: theme.textTheme.titleSmall),
                    Text(
                      'New builds are checked on every launch; check now '
                      'to be sure.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GhostButton(
                label: _checking ? 'Checking…' : 'Check',
                height: 40,
                onPressed: _checking ? null : _checkUpdate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
