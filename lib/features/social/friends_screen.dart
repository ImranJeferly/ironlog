import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../data/social/social_models.dart';
import '../../data/social/social_repository.dart'
    show SendOutcome, SendResult, describeSocialError;
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart' show BrutalHeader;
import '../../widgets/buttons.dart';
import 'avatar.dart';
import 'chat_screen.dart';
import 'friend_profile_screen.dart';
import 'my_profile_screen.dart';

enum _Tab { chats, friends, requests }

/// The Friends tab: chats, the friend list and pending requests, plus the
/// add-by-@handle flow. Everything here needs a real account.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  _Tab _tab = _Tab.chats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = ref.watch(socialEnabledProvider);
    final me = ref.watch(myProfileProvider).value;
    final requests = ref.watch(incomingRequestsProvider).value ?? const [];
    // Any stream failing (almost always: rules not published) must be loud —
    // otherwise it just looks like nobody has sent anything.
    final streamError = [
      ref.watch(chatsProvider),
      ref.watch(friendsProvider),
      ref.watch(incomingRequestsProvider),
      ref.watch(outgoingRequestsProvider),
    ].map((a) => a.error).firstWhere((e) => e != null, orElse: () => null);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalHeader(
            title: 'Friends',
            eyebrow: me?.handle == null ? 'Train together' : '@${me!.handle}',
            rule: false,
            trailing: enabled
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconPill(
                        icon: Icons.person_add_alt_1,
                        color: AppColors.accent,
                        tooltip: 'Add a friend',
                        onTap: () => AddFriendSheet.show(context),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => MyProfileScreen.open(context),
                        child: Avatar(
                          initial: me?.initial ?? '?',
                          photo: me?.photo, photoUrl: me?.photoUrl,
                          size: 36,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          if (!enabled)
            const Expanded(child: _SignedOutState())
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: PillToggle<_Tab>(
                values: _Tab.values,
                selected: _tab,
                labelOf: (t) => switch (t) {
                  _Tab.chats => 'Chats',
                  _Tab.friends => 'Friends',
                  _Tab.requests => requests.isEmpty
                      ? 'Requests'
                      : 'Requests · ${requests.length}',
                },
                onChanged: (t) => setState(() => _tab = t),
              ),
            ),
            if (streamError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppCard(
                  edge: AppColors.danger,
                  radius: AppRadii.cardSmall,
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          describeSocialError(streamError),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (me != null && me.handle == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppCard(
                  edge: AppColors.accent,
                  radius: AppRadii.cardSmall,
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  onTap: () => MyProfileScreen.open(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pick an @handle so friends can find you.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: switch (_tab) {
                _Tab.chats => const _ChatsList(),
                _Tab.friends => const _FriendsList(),
                _Tab.requests => const _RequestsList(),
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Sign in to add friends',
      icon: Icons.people_outline,
      message:
          'Chats, voice notes, PR alerts and friend profiles need an '
          'account. Create one in Settings — it takes a minute.',
    );
  }
}

/// A stream failed. Say why instead of pretending the list is empty.
class _LoadError extends StatelessWidget {
  const _LoadError(this.error);

  final Object error;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Can’t load this',
      icon: Icons.error_outline,
      message: describeSocialError(error),
    );
  }
}

// ------------------------------------------------------------------- chats

class _ChatsList extends ConsumerWidget {
  const _ChatsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chatsProvider);
    final chats = async.value ?? const [];
    final me = ref.watch(socialRepositoryProvider).uid ?? '';

    // Don't flash "no chats" while the first snapshot is still on its way.
    if (async.isLoading && !async.hasValue) return const SizedBox.shrink();
    if (async.hasError) return _LoadError(async.error!);
    if (chats.isEmpty) {
      return const EmptyState(
        title: 'No chats yet',
        icon: Icons.chat_bubble_outline,
        message: 'Add a friend and the chat opens the moment they accept.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        96,
      ),
      itemCount: chats.length,
      itemBuilder: (context, i) => _ChatRow(chat: chats[i], me: me),
    );
  }
}

class _ChatRow extends ConsumerWidget {
  const _ChatRow({required this.chat, required this.me});

  final ChatSummary chat;
  final String me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final other = chat.otherThan(me);
    final profile = ref.watch(friendProfileProvider(other)).value;
    final unread = chat.unreadFor(me);
    final mineLast = chat.lastFrom == me;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      edge: unread > 0 ? AppColors.accent : null,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      onTap: () => ChatScreen.open(context, chatId: chat.id, friendUid: other),
      child: Row(
        children: [
          Avatar(
            initial: profile?.initial ?? '?',
            photo: profile?.photo, photoUrl: profile?.photoUrl,
            training: profile?.isTraining ?? false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile?.displayName ?? 'Friend',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (chat.lastAt != null)
                      Text(
                        _when(chat.lastAt!),
                        style: AppText.numeric(
                          size: 11,
                          letterSpacing: 0,
                          color: unread > 0
                              ? AppColors.accent
                              : AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${mineLast ? 'You: ' : ''}${chat.lastText ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: unread > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      _CountBadge(unread),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _when(DateTime t) {
    final now = DateTime.now();
    if (t.isSameDay(now)) return Dates.time(t);
    if (t.isSameDay(now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return Dates.dayMonth(t);
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppText.numeric(size: 11, letterSpacing: 0),
      ),
    );
  }
}

// ----------------------------------------------------------------- friends

class _FriendsList extends ConsumerWidget {
  const _FriendsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendsProvider);
    final friends = async.value ?? const [];

    if (async.isLoading && !async.hasValue) return const SizedBox.shrink();
    if (async.hasError) return _LoadError(async.error!);
    if (friends.isEmpty) {
      return EmptyState(
        title: 'No friends yet',
        icon: Icons.people_outline,
        message: 'Share your @handle or add someone by theirs.',
        action: VoltButton(
          label: 'Add a friend',
          icon: Icons.person_add_alt_1,
          expanded: false,
          height: 48,
          onPressed: () => AddFriendSheet.show(context),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        96,
      ),
      itemCount: friends.length,
      itemBuilder: (context, i) => _FriendRow(friend: friends[i]),
    );
  }
}

class _FriendRow extends ConsumerWidget {
  const _FriendRow({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(friendProfileProvider(friend.uid)).value;
    final np = profile?.nowPlaying;
    final status = profile == null
        ? ''
        : profile.isTraining
        ? '🏋️ Training now · ${profile.activeSessionName}'
        : (np != null && np.isFresh)
        ? '🎵 ${np.title}${np.artist == null ? '' : ' · ${np.artist}'}'
        : (profile.handle == null ? '' : '@${profile.handle}');

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      onTap: () => FriendProfileScreen.open(context, friend.uid),
      child: Row(
        children: [
          Avatar(
            initial: profile?.initial ?? '?',
            photo: profile?.photo, photoUrl: profile?.photoUrl,
            training: profile?.isTraining ?? false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? 'Friend',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: profile?.isTraining ?? false
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconPill(
            icon: Icons.chat_bubble_outline,
            size: 36,
            color: AppColors.accent,
            tooltip: 'Message',
            onTap: () => ChatScreen.open(
              context,
              chatId: friend.chatId,
              friendUid: friend.uid,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- requests

class _RequestsList extends ConsumerWidget {
  const _RequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final incomingAsync = ref.watch(incomingRequestsProvider);
    final outgoingAsync = ref.watch(outgoingRequestsProvider);
    final incoming = incomingAsync.value ?? const [];
    final outgoing = outgoingAsync.value ?? const [];
    final repo = ref.read(socialRepositoryProvider);

    final loading =
        (incomingAsync.isLoading && !incomingAsync.hasValue) ||
        (outgoingAsync.isLoading && !outgoingAsync.hasValue);
    if (loading) return const SizedBox.shrink();
    final error = incomingAsync.error ?? outgoingAsync.error;
    if (error != null) return _LoadError(error);
    if (incoming.isEmpty && outgoing.isEmpty) {
      return const EmptyState(
        title: 'No pending requests',
        icon: Icons.mark_email_read_outlined,
        message: 'Requests you send and receive show up here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        96,
      ),
      children: [
        if (incoming.isNotEmpty) const SectionHeader('Received'),
        for (final r in incoming)
          _RequestRow(
            uid: r.from,
            fallbackName: r.fromName,
            fallbackHandle: r.fromHandle,
            when: r.createdAt,
            actions: [
              GhostButton(
                label: 'Decline',
                height: 38,
                onPressed: () => repo.declineRequest(r.id),
              ),
              const SizedBox(width: 6),
              VoltButton(
                label: 'Accept',
                height: 38,
                expanded: false,
                onPressed: () async {
                  await repo.acceptRequest(r.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You and ${r.fromName ?? 'your new friend'} are '
                          'friends — the chat is open.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        if (outgoing.isNotEmpty) const SectionHeader('Sent'),
        for (final r in outgoing)
          _RequestRow(
            uid: r.to,
            when: r.createdAt,
            actions: [
              GhostButton(
                label: 'Cancel',
                height: 38,
                onPressed: () => repo.cancelRequest(r.id),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Only friends can message each other or see each other’s stats.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({
    required this.uid,
    required this.when,
    required this.actions,
    this.fallbackName,
    this.fallbackHandle,
  });

  final String uid;
  final DateTime when;
  final List<Widget> actions;
  final String? fallbackName;
  final String? fallbackHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(friendProfileProvider(uid)).value;
    final name = profile?.displayName ?? fallbackName ?? 'Lifter';
    final handle = profile?.handle ?? fallbackHandle;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      radius: AppRadii.cardSmall,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      onTap: () => FriendProfileScreen.open(context, uid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                initial: initialOf(name),
                photo: profile?.photo, photoUrl: profile?.photoUrl,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleSmall),
                    Text(
                      '${handle == null ? '' : '@$handle · '}'
                      '${Dates.relativeDay(when)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- add friend

/// Look someone up by @handle and send a request; shows your own handle so
/// you can share it back.
class AddFriendSheet extends ConsumerStatefulWidget {
  const AddFriendSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    builder: (_) => const AddFriendSheet(),
  );

  @override
  ConsumerState<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<AddFriendSheet> {
  final _controller = TextEditingController();
  UserProfile? _found;
  String? _message;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _message = null;
      _found = null;
    });
    final repo = ref.read(socialRepositoryProvider);
    UserProfile? profile;
    String? error;
    try {
      profile = await repo.findByHandle(_controller.text);
    } on Object catch (e) {
      error = describeSocialError(e);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _found = profile;
      _message = error ?? (profile == null ? 'Nobody has that handle.' : null);
    });
  }

  Future<void> _send() async {
    final target = _found;
    if (target == null) return;
    setState(() => _busy = true);
    SendResult? result;
    String? error;
    try {
      result = await ref.read(socialRepositoryProvider).sendRequest(target.uid);
    } on Object catch (e) {
      error = describeSocialError(e);
    }
    if (!mounted) return;

    // Crossing requests auto-accept: don't say "sent" — take them to the chat.
    if (result?.outcome == SendOutcome.nowFriends && result?.chatId != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result!.message ?? 'You’re now friends with ${target.displayName}.',
          ),
        ),
      );
      unawaited(
        ChatScreen.open(context, chatId: result.chatId!, friendUid: target.uid),
      );
      return;
    }

    setState(() {
      _busy = false;
      _message = switch (result?.outcome) {
        SendOutcome.sent => 'Request sent to ${target.displayName}. '
            'It shows under Requests › Sent until they accept.',
        SendOutcome.noop => result?.message,
        _ => error ?? result?.message,
      };
      if (result?.outcome == SendOutcome.sent) _found = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final me = ref.watch(myProfileProvider).value;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a friend', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Friends see each other’s stats, get PR and workout alerts, '
                'and can chat.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              if (me?.handle != null)
                AppCard(
                  radius: AppRadii.cardSmall,
                  padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR HANDLE',
                              style: theme.textTheme.labelSmall,
                            ),
                            Text(
                              '@${me!.handle}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconPill(
                        icon: Icons.copy,
                        size: 34,
                        tooltip: 'Copy',
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: '@${me.handle}'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Handle copied')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                autofocus: true,
                autocorrect: false,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _busy ? null : _search(),
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '@handle',
                  prefixIcon: const Icon(Icons.alternate_email, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: _busy ? null : _search,
                  ),
                ),
              ),
              if (_found != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  radius: AppRadii.cardSmall,
                  edge: AppColors.accent,
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    children: [
                      Avatar(
                        initial: _found!.initial,
                        photo: _found!.photo, photoUrl: _found!.photoUrl,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _found!.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              '@${_found!.handle} · '
                              '${_found!.stats.sessions} sessions',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      VoltButton(
                        label: 'Add',
                        icon: Icons.person_add_alt_1,
                        height: 40,
                        expanded: false,
                        onPressed: _busy ? null : _send,
                      ),
                    ],
                  ),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _found == null && _message!.startsWith('Nobody')
                        ? AppColors.danger
                        : AppColors.accent,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
