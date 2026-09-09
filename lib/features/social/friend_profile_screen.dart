import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../data/social/social_models.dart';
import '../../data/social/social_repository.dart'
    show SendOutcome, describeSocialError;
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import 'avatar.dart';
import 'chat_screen.dart';

/// A friend's profile: photo, what they're doing right now, their headline
/// stats, and a side-by-side compare with yours.
class FriendProfileScreen extends ConsumerWidget {
  const FriendProfileScreen({super.key, required this.uid});

  final String uid;

  static Future<void> open(BuildContext context, String uid) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => FriendProfileScreen(uid: uid)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(friendProfileProvider(uid));
    final profile = profileAsync.value;
    final me = ref.watch(myProfileProvider).value;
    final friends = ref.watch(friendsProvider).value ?? const [];
    final friend = friends.where((f) => f.uid == uid).firstOrNull;
    final unit = ref.watch(unitProvider);
    final repo = ref.read(socialRepositoryProvider);

    if (profile == null) {
      final loading = profileAsync.isLoading && !profileAsync.hasValue;
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: Text(loading ? '' : 'Profile')),
        body: loading
            ? const SizedBox.shrink()
            : const Center(child: EmptyState(title: 'Profile unavailable')),
      );
    }

    final np = profile.nowPlaying;
    final stats = profile.stats;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(profile.displayName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          Row(
            children: [
              Avatar(
                initial: profile.initial,
                photo: profile.photo, photoUrl: profile.photoUrl,
                size: 84,
                training: profile.isTraining,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (profile.handle != null)
                      Text(
                        '@${profile.handle}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(profile.bio!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          // ---- right now
          if (profile.isTraining)
            _NowCard(
              icon: Icons.fitness_center,
              accent: AppColors.accent,
              eyebrow: 'TRAINING NOW',
              title: profile.activeSessionName!,
            )
          else if (np != null && np.isFresh)
            _NowCard(
              icon: Icons.music_note,
              accent: AppColors.ember,
              eyebrow: 'NOW PLAYING',
              title: np.title,
              subtitle: np.artist,
            )
          else if (stats.lastWorkoutAt != null)
            _NowCard(
              icon: Icons.history,
              accent: AppColors.textSecondary,
              eyebrow: 'LAST WORKOUT',
              title: stats.lastWorkoutName ?? 'Workout',
              subtitle: Dates.relativeDay(stats.lastWorkoutAt!),
            ),

          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (friend != null)
                Expanded(
                  child: VoltButton(
                    label: 'Message',
                    icon: Icons.chat_bubble_outline,
                    height: 48,
                    onPressed: () => ChatScreen.open(
                      context,
                      chatId: friend.chatId,
                      friendUid: uid,
                    ),
                  ),
                )
              else
                Expanded(
                  child: VoltButton(
                    label: 'Add friend',
                    icon: Icons.person_add_alt_1,
                    height: 48,
                    onPressed: () async {
                      String text;
                      try {
                        final r = await repo.sendRequest(uid);
                        text = switch (r.outcome) {
                          SendOutcome.sent => 'Request sent.',
                          SendOutcome.nowFriends =>
                            r.message ?? 'You’re friends now.',
                          SendOutcome.noop => r.message ?? 'Nothing to do.',
                        };
                      } on Object catch (e) {
                        text = describeSocialError(e);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(text)),
                        );
                      }
                    },
                  ),
                ),
              if (friend != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconPill(
                  icon: Icons.person_remove_outlined,
                  size: 48,
                  color: AppColors.danger,
                  tooltip: 'Remove friend',
                  onTap: () => _confirmRemove(context, ref, profile),
                ),
              ],
            ],
          ),

          // ---- stats
          const SectionHeader('Stats'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${stats.sessions}',
                  label: 'Sessions',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: '${stats.streak}',
                  label: 'Streak',
                  accent: stats.streak > 0 ? AppColors.accent : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(value: '${stats.prs}', label: 'PRs'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: Fmt.percent(stats.adherence4w),
                  label: '4-week adherence',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: '${stats.weeklySets}',
                  label: 'Sets this week',
                ),
              ),
            ],
          ),

          if (stats.bestLifts.isNotEmpty) ...[
            const SectionHeader('Best lifts · est. 1RM'),
            AppCard(
              child: Column(
                children: [
                  for (final e in stats.bestLifts.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(e.key, style: theme.textTheme.titleSmall),
                          ),
                          Text(
                            Fmt.weight(e.value, unit),
                            style: AppText.numeric(
                              size: 15,
                              letterSpacing: 0,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          // ---- compare
          if (me != null && friend != null) ...[
            const SectionHeader('Compare'),
            _CompareCard(me: me, them: profile, unit: unit),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove friend?'),
        content: Text(
          '${profile.displayName} won’t see your stats or get your alerts '
          'any more. The chat stays but neither of you can post in it.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(socialRepositoryProvider).removeFriend(uid);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({
    required this.icon,
    required this.accent,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      edge: accent,
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: theme.textTheme.labelSmall?.copyWith(color: accent),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// You vs them, row by row, with a bar each so the gap reads at a glance.
class _CompareCard extends StatelessWidget {
  const _CompareCard({
    required this.me,
    required this.them,
    required this.unit,
  });

  final UserProfile me;
  final UserProfile them;
  final dynamic unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = me.stats;
    final b = them.stats;
    final rows = <(String, double, double, String Function(double))>[
      ('Sessions', a.sessions.toDouble(), b.sessions.toDouble(), _int),
      ('Streak', a.streak.toDouble(), b.streak.toDouble(), _int),
      ('PRs', a.prs.toDouble(), b.prs.toDouble(), _int),
      ('4-week adherence', a.adherence4w, b.adherence4w, Fmt.percent),
      ('Sets this week', a.weeklySets.toDouble(), b.weeklySets.toDouble(), _int),
    ];
    final shared = a.bestLifts.keys.where(b.bestLifts.containsKey).toList()
      ..sort();
    for (final name in shared) {
      rows.add((
        name,
        a.bestLifts[name]!,
        b.bestLifts[name]!,
        (v) => Fmt.weight(v, unit),
      ));
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'You',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  them.displayName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (label, mine, theirs, fmt) in rows)
            _CompareRow(label: label, mine: mine, theirs: theirs, fmt: fmt),
        ],
      ),
    );
  }

  static String _int(double v) => v.round().toString();
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.mine,
    required this.theirs,
    required this.fmt,
  });

  final String label;
  final double mine;
  final double theirs;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = mine > theirs ? mine : theirs;
    final l = max <= 0 ? 0.0 : (mine / max).clamp(0.0, 1.0);
    final r = max <= 0 ? 0.0 : (theirs / max).clamp(0.0, 1.0);
    final iLead = mine > theirs;
    final theyLead = theirs > mine;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fmt(mine),
                style: AppText.numeric(
                  size: 15,
                  letterSpacing: 0,
                  color: iLead ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Text(
                fmt(theirs),
                style: AppText.numeric(
                  size: 15,
                  letterSpacing: 0,
                  color: theyLead ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: l == 0 ? 0.02 : l,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: r == 0 ? 0.02 : r,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
