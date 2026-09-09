import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/health/health_service.dart';
import '../../data/sync/firebase_bootstrap.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart' show BrutalHeader;
import '../../widgets/buttons.dart';
import '../social/avatar.dart';
import '../social/my_profile_screen.dart';
import 'account_sheet.dart';
import 'pages/about_page.dart';
import 'pages/data_settings_page.dart';
import 'pages/health_settings_page.dart';
import 'pages/session_settings_page.dart';
import 'pages/training_settings_page.dart';

/// Profile up top, then one row per settings area. The detail lives on
/// sub-pages so this screen stays short.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          96,
        ),
        children: [
          const BrutalHeader(
            title: 'Settings',
            eyebrow: 'Your profile',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),
          const _ProfileCard(),

          const SectionHeader('Preferences'),
          _NavRow(
            icon: Icons.calendar_month_outlined,
            title: 'Training',
            subtitle: 'Training days, weight unit, body-weight goal',
            onTap: () => TrainingSettingsPage.open(context),
          ),
          _NavRow(
            icon: Icons.timer_outlined,
            title: 'Session',
            subtitle: 'Rest timer, haptics, reminders',
            onTap: () => SessionSettingsPage.open(context),
          ),
          _NavRow(
            icon: Icons.favorite_outline,
            title: HealthService.providerName,
            subtitle: 'Steps, sleep and weight sync · step goal',
            onTap: () => HealthSettingsPage.open(context),
          ),
          _NavRow(
            icon: Icons.cloud_outlined,
            title: 'Sync & data',
            subtitle: 'Firebase backup, CSV export',
            onTap: () => DataSettingsPage.open(context),
          ),
          _NavRow(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version and updates',
            onTap: () => AboutPage.open(context),
          ),

          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'IRONLOG · OFFLINE-FIRST',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Who the stats belong to, with the headline numbers. Anonymous data can
/// be upgraded to a permanent account in place — linking keeps the uid.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final available = FirebaseBootstrap.isAvailable;
    final user = ref.watch(authUserProvider).value;
    final email = (user != null && !user.isAnonymous) ? user.email : null;
    final signedIn = email != null;
    final consistency = ref.watch(consistencyProvider).value;
    final prs = ref.watch(personalRecordsProvider).value ?? const [];
    final profile = signedIn ? ref.watch(myProfileProvider).value : null;
    final initial = (email ?? 'G').trim().isEmpty
        ? 'G'
        : (email ?? 'G').trim()[0].toUpperCase();
    final title = (profile?.displayName.trim().isNotEmpty ?? false)
        ? profile!.displayName
        : (email ?? 'Guest');
    final subtitle = signedIn
        ? (profile?.handle != null
              ? '@${profile!.handle} · synced to this account'
              : 'Synced to this account')
        : (available
              ? 'Sign in so your stats survive reinstalls and new phones.'
              : (FirebaseBootstrap.unavailableReason ??
                    'Offline — account unavailable.'));

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: signedIn ? AppColors.accent.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                initial: profile?.initial ?? initial,
                photo: profile?.photo, photoUrl: profile?.photoUrl,
                size: 56,
                muted: !signedIn,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (signedIn)
                IconPill(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit profile',
                  onTap: () => MyProfileScreen.open(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  value: '${consistency?.totalSessions ?? 0}',
                  label: 'Sessions',
                ),
              ),
              Expanded(
                child: _ProfileStat(
                  value: '${consistency?.currentStreak ?? 0}',
                  label: 'Streak',
                  accent: (consistency?.currentStreak ?? 0) > 0,
                ),
              ),
              Expanded(
                child: _ProfileStat(
                  value: '${prs.length}',
                  label: 'PRs',
                ),
              ),
              Expanded(
                child: _ProfileStat(
                  value: Fmt.percent(consistency?.fourWeekAdherence ?? 0),
                  label: '4-week',
                ),
              ),
            ],
          ),
          if (available) ...[
            const SizedBox(height: AppSpacing.lg),
            if (!signedIn)
              Row(
                children: [
                  Expanded(
                    child: VoltButton(
                      label: 'Create account',
                      height: 46,
                      onPressed: () => _open(context, createMode: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GhostButton(
                      label: 'Sign in',
                      expanded: true,
                      onPressed: () => _open(context, createMode: false),
                    ),
                  ),
                ],
              )
            else
              GhostButton(
                label: 'Sign out',
                icon: Icons.logout,
                expanded: true,
                onPressed: () async {
                  // Stop friend notifications for this account first.
                  await ref.read(socialHooksProvider).stopPush();
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out — back to guest mode.'),
                      ),
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, {required bool createMode}) async {
    final ok = await AccountSheet.show(context, createMode: createMode);
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createMode
                ? 'Account created — your stats now live on it.'
                : 'Signed in — stats synced to your account.',
          ),
        ),
      );
    }
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    this.accent = false,
  });

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppText.numeric(
            size: 20,
            color: accent ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// One tappable row leading to a settings sub-page.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardHigh,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 19, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 13,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
