import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/push.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_x.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/social/social_models.dart';
import '../../widgets/buttons.dart';
import 'avatar.dart';
import 'friend_profile_screen.dart';
import 'voice_note.dart';

/// 1:1 chat: text and voice notes, reply-to, and WhatsApp-style ticks
/// (pending · sent · delivered · seen).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.friendUid});

  final String chatId;
  final String friendUid;

  static Future<void> open(
    BuildContext context, {
    required String chatId,
    required String friendUid,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatScreen(chatId: chatId, friendUid: friendUid),
    ),
  );

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _input = TextEditingController();
  final _recorder = VoiceRecorder();
  Timer? _recTicker;
  bool _recording = false;
  bool _sending = false;
  ReplyRef? _reply;
  bool _visible = true;

  /// When my oldest still-pending message first showed up; drives the
  /// "waiting for connection" pill after a few seconds.
  DateTime? _pendingSince;
  Timer? _pendingTicker;
  bool _kicking = false;

  /// Last time we told the other side we're typing. A write, so it goes out
  /// at most once per [_typingEvery] while the composer has text in it.
  DateTime? _typingSentAt;
  Timer? _typingExpiry;

  static const _stuckAfter = Duration(seconds: 8);
  static const _typingEvery = Duration(seconds: 5);

  void _trackPending(List<ChatMessage>? messages, String? me) {
    final anyPending =
        me != null &&
        (messages ?? const []).any(
          (m) => m.from == me && m.status == MessageStatus.pending,
        );
    if (anyPending) {
      _pendingSince ??= DateTime.now();
      _pendingTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (_pendingSince != null) {
      _pendingSince = null;
      _pendingTicker?.cancel();
      _pendingTicker = null;
    }
  }

  bool get _stuck =>
      _pendingSince != null &&
      DateTime.now().difference(_pendingSince!) > _stuckAfter;

  Future<void> _retryStuck() async {
    if (_kicking) return;
    setState(() => _kicking = true);
    await ref.read(socialRepositoryProvider).kickNetwork();
    if (mounted) setState(() => _kicking = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Notifications for this chat are redundant while it's on screen.
    PushService.setActiveChat(widget.chatId);
    PushService.dismissChat(widget.chatId);
    _input.addListener(_onTyping);
  }

  @override
  void dispose() {
    PushService.setActiveChat(null);
    WidgetsBinding.instance.removeObserver(this);
    _pendingTicker?.cancel();
    _typingExpiry?.cancel();
    _recTicker?.cancel();
    _recorder.dispose();
    _input.removeListener(_onTyping);
    _input.dispose();
    // Leaving the screen means I've stopped typing. Fire-and-forget: the
    // stamp expires on its own anyway.
    if (_typingSentAt != null) {
      unawaited(
        ref
            .read(socialRepositoryProvider)
            .setTyping(widget.chatId, typing: false),
      );
    }
    super.dispose();
  }

  /// Throttled "still typing" ping. Cleared as soon as the box is empty, and
  /// re-armed to clear itself if the user just stops mid-word.
  void _onTyping() {
    final repo = ref.read(socialRepositoryProvider);
    if (_input.text.trim().isEmpty) {
      _typingExpiry?.cancel();
      if (_typingSentAt != null) {
        _typingSentAt = null;
        unawaited(repo.setTyping(widget.chatId, typing: false));
      }
      return;
    }
    final now = DateTime.now();
    if (_typingSentAt == null ||
        now.difference(_typingSentAt!) > _typingEvery) {
      _typingSentAt = now;
      unawaited(repo.setTyping(widget.chatId, typing: true));
    }
    _typingExpiry?.cancel();
    _typingExpiry = Timer(ChatSummary.typingWindow, () {
      _typingSentAt = null;
      unawaited(repo.setTyping(widget.chatId, typing: false));
    });
  }

  void _stopTyping() {
    _typingExpiry?.cancel();
    if (_typingSentAt == null) return;
    _typingSentAt = null;
    unawaited(
      ref.read(socialRepositoryProvider).setTyping(widget.chatId, typing: false),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (_visible) _receipts(ref.read(chatMessagesProvider(widget.chatId)).value);
  }

  /// Delivered receipts always; seen receipts only while the chat is on
  /// screen and the app is in the foreground.
  void _receipts(List<ChatMessage>? messages) {
    if (messages == null || messages.isEmpty) return;
    final repo = ref.read(socialRepositoryProvider);
    if (_visible) {
      unawaited(repo.markSeen(widget.chatId, messages));
    } else {
      unawaited(repo.markDelivered(widget.chatId, messages));
    }
  }

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final reply = _reply;
    _input.clear();
    _stopTyping();
    setState(() => _reply = null);
    await ref
        .read(socialRepositoryProvider)
        .sendText(widget.chatId, text, replyTo: reply);
    if (mounted) setState(() => _sending = false);
  }

  /// Camera or gallery → compressed JPEG → Storage → message.
  Future<void> _sendImage({required bool fromCamera}) async {
    if (_sending) return;
    final reply = _reply;
    setState(() {
      _sending = true;
      _reply = null;
    });
    try {
      final file = await ref
          .read(photoRepositoryProvider)
          .pick(fromCamera: fromCamera);
      if (file == null) return;
      // 1600 px long edge is plenty for a phone screen and keeps the upload
      // quick on gym wifi.
      final bytes = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 1600,
        minHeight: 1600,
        quality: 78,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (bytes == null) {
        _toast('Could not read that image.');
        return;
      }
      final data = Uint8List.fromList(bytes);
      final size = await decodeImageFromList(data);
      final error = await ref
          .read(socialRepositoryProvider)
          .sendImage(
            widget.chatId,
            data,
            width: size.width,
            height: size.height,
            replyTo: reply,
          );
      if (error != null) _toast(error);
    } on Object catch (e) {
      _toast('Photo failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _pickImageSource() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.textPrimary,
              ),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(sheet).pop();
                _sendImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.textPrimary,
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(sheet).pop();
                _sendImage(fromCamera: false);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage(ChatMessage m, List<ChatMessage> all) async {
    // `all` is newest-first, so the replacement preview is the next one down.
    final isLast = all.isNotEmpty && all.first.id == m.id;
    final replacement = isLast && all.length > 1 ? all[1].preview : null;
    await ref
        .read(socialRepositoryProvider)
        .deleteMessage(
          widget.chatId,
          m.id,
          newPreview: isLast ? (replacement ?? 'Message deleted') : null,
        );
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      _recTicker?.cancel();
      final clip = await _recorder.stop();
      if (!mounted) return;
      setState(() => _recording = false);
      if (clip == null) {
        _toast('Too short — hold the mic a little longer.');
        return;
      }
      final reply = _reply;
      setState(() {
        _reply = null;
        _sending = true;
      });
      final error = await ref
          .read(socialRepositoryProvider)
          .sendVoice(
            widget.chatId,
            clip.bytes,
            durationMs: clip.durationMs,
            replyTo: reply,
          );
      if (mounted) setState(() => _sending = false);
      if (error != null) _toast(error);
      return;
    }

    final ok = await _recorder.start();
    if (!mounted) return;
    if (!ok) {
      _toast('Microphone permission is needed for voice messages.');
      return;
    }
    Haptics.impact();
    setState(() => _recording = true);
    _recTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      if (_recorder.elapsed >= VoiceRecorder.maxDuration) {
        _toggleRecord();
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _cancelRecord() async {
    _recTicker?.cancel();
    await _recorder.cancel();
    if (mounted) setState(() => _recording = false);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setReply(ChatMessage m) {
    Haptics.tick();
    setState(
      () => _reply = ReplyRef(
        messageId: m.id,
        from: m.from,
        preview: m.preview,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final me = ref.watch(socialRepositoryProvider).uid ?? '';
    final friend = ref.watch(friendProfileProvider(widget.friendUid)).value;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final messages = messagesAsync.value ?? const <ChatMessage>[];

    // Receipts as messages arrive.
    ref.listen(chatMessagesProvider(widget.chatId), (_, next) {
      _receipts(next.value);
      _trackPending(next.value, me);
    });

    // "typing…" outranks everything else in the header — it's the most
    // immediate thing the other person can be doing.
    final chat = ref
        .watch(chatsProvider)
        .value
        ?.where((c) => c.id == widget.chatId)
        .firstOrNull;
    final typing = chat?.someoneTypingOtherThan(me) ?? false;

    final np = friend?.nowPlaying;
    final subtitle = typing
        ? 'typing…'
        : friend == null
        ? ''
        : friend.isTraining
        ? 'Training now · ${friend.activeSessionName}'
        : (np != null && np.isFresh)
        ? '🎵 ${np.title}${np.artist == null ? '' : ' · ${np.artist}'}'
        : friend.lastSeenAt == null
        ? (friend.handle == null ? '' : '@${friend.handle}')
        : 'Last seen ${Dates.relativeDay(friend.lastSeenAt!)}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FriendProfileScreen.open(context, widget.friendUid),
          child: Row(
            children: [
              Avatar(
                initial: friend?.initial ?? '?',
                photo: friend?.photo, photoUrl: friend?.photoUrl,
                size: 36,
                training: friend?.isTraining ?? false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend?.displayName ?? 'Chat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: typing || (friend?.isTraining ?? false)
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => FriendProfileScreen.open(context, widget.friendUid),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        messagesAsync.isLoading
                            ? 'Loading…'
                            : 'Say hi — voice notes work too.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final prev = i + 1 < messages.length
                          ? messages[i + 1]
                          : null;
                      final showDay =
                          m.sentAt != null &&
                          (prev?.sentAt == null ||
                              !prev!.sentAt!.isSameDay(m.sentAt!));
                      return Column(
                        children: [
                          if (showDay) _DayChip(m.sentAt!),
                          if (m.kind == MessageKind.system)
                            _SystemLine(
                              message: m,
                              mine: m.from == me,
                              friendName: friend?.displayName ?? 'Friend',
                            )
                          else
                            _Bubble(
                              message: m,
                              mine: m.from == me,
                              me: me,
                              friendName: friend?.displayName ?? 'Friend',
                              onReply: () => _setReply(m),
                              onReact: (emoji) => ref
                                  .read(socialRepositoryProvider)
                                  .react(widget.chatId, m.id, emoji),
                              onDelete: m.from == me
                                  ? () => _deleteMessage(m, messages)
                                  : null,
                            ),
                        ],
                      );
                    },
                  ),
          ),
          if (_stuck)
            _StuckPill(busy: _kicking, onRetry: _retryStuck),
          _Composer(
            controller: _input,
            reply: _reply,
            replyAuthor: _reply == null
                ? null
                : (_reply!.from == me ? 'You' : friend?.displayName ?? 'Friend'),
            recording: _recording,
            recordElapsed: _recorder.elapsed,
            sending: _sending,
            onSend: _sendText,
            onMic: _toggleRecord,
            onPhoto: _pickImageSource,
            onCancelRecord: _cancelRecord,
            onClearReply: () => setState(() => _reply = null),
          ),
        ],
      ),
    );
  }
}

/// Shown when my messages have sat unacknowledged for a while — usually a
/// Wi-Fi with no internet or a stalled stream after a network switch.
class _StuckPill extends StatelessWidget {
  const _StuckPill({required this.busy, required this.onRetry});

  final bool busy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 6),
      child: GestureDetector(
        onTap: busy ? null : onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardHigh,
            borderRadius: BorderRadius.circular(AppRadii.chip),
            border: Border.all(color: AppColors.ember.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: busy
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ember,
                      )
                    : const Icon(
                        Icons.cloud_off_outlined,
                        size: 14,
                        color: AppColors.ember,
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  busy
                      ? 'Reconnecting…'
                      : 'Waiting for connection — messages will send when '
                            'it’s back. Tap to retry now.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip(this.day);

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          Dates.relativeDay(day).toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

/// "🏋️ Started Push A" — activity lines from either side, centred.
class _SystemLine extends StatelessWidget {
  const _SystemLine({
    required this.message,
    required this.mine,
    required this.friendName,
  });

  final ChatMessage message;
  final bool mine;
  final String friendName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppColors.voltDim,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          '${mine ? 'You' : friendName} · ${message.text ?? ''}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.me,
    required this.friendName,
    required this.onReply,
    required this.onReact,
    this.onDelete,
  });

  /// The reactions offered in the long-press menu.
  static const reactionChoices = ['💪', '🔥', '👍', '😂', '😮', '👀'];

  final ChatMessage message;
  final bool mine;
  final String me;
  final String friendName;
  final VoidCallback onReply;

  /// Null clears my reaction.
  final void Function(String? emoji) onReact;

  /// Null when the message isn't mine to delete.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = mine ? AppColors.accent : AppColors.cardHigh;
    final fg = AppColors.textPrimary;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(mine ? 16 : 4),
      bottomRight: Radius.circular(mine ? 4 : 16),
    );

    final body = GestureDetector(
      onLongPress: () => _menu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 9, 10, 7),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: mine ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.replyTo != null) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: mine ? 0.18 : 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: mine ? AppColors.textPrimary : AppColors.accent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  message.replyTo!.preview ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (message.kind == MessageKind.voice &&
                (message.audioUrl != null || message.audio != null))
              VoiceNotePlayer(
                url: message.audioUrl,
                bytes: message.audio,
                durationMs: message.audioMs,
                mine: mine,
              )
            else if (message.kind == MessageKind.image &&
                message.imageUrl != null)
              _ChatImage(message: message)
            else
              Text(
                message.text ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.sentAt == null ? '…' : Dates.time(message.sentAt!),
                  style: AppText.numeric(
                    size: 10.5,
                    letterSpacing: 0,
                    color: fg.withValues(alpha: mine ? 0.8 : 0.55),
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  _Ticks(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    final reactions = message.reactionCounts;
    final bubbleWithReactions = reactions.isEmpty
        ? body
        : Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              body,
              Transform.translate(
                offset: const Offset(0, -6),
                child: Wrap(
                  spacing: 4,
                  children: [
                    for (final e in reactions.entries)
                      GestureDetector(
                        onTap: () => onReact(
                          message.reactions[me] == e.key ? null : e.key,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: message.reactions[me] == e.key
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            e.value > 1 ? '${e.key} ${e.value}' : e.key,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );

    // Swipe toward the centre to reply, like the chat apps people know.
    return Dismissible(
      key: ValueKey('swipe-${message.id}'),
      direction: mine
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.25,
        DismissDirection.startToEnd: 0.25,
      },
      confirmDismiss: (_) async {
        onReply();
        return false;
      },
      background: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.reply, color: AppColors.textSecondary),
        ),
      ),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: bubbleWithReactions,
      ),
    );
  }

  void _menu(BuildContext context) {
    Haptics.tick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            // The reaction row sits above the actions — it's the one people
            // reach for most.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final emoji in reactionChoices)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(sheet).pop();
                      Haptics.tick();
                      onReact(message.reactions[me] == emoji ? null : emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: message.reactions[me] == emoji
                            ? AppColors.voltDim
                            : Colors.transparent,
                        border: Border.all(
                          color: message.reactions[me] == emoji
                              ? AppColors.accent
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.textPrimary),
              title: const Text('Reply'),
              onTap: () {
                Navigator.of(sheet).pop();
                onReply();
              },
            ),
            if (message.kind == MessageKind.text)
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.textPrimary),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.text ?? ''));
                  Navigator.of(sheet).pop();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'Delete for everyone',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.of(sheet).pop();
                  onDelete!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.textPrimary),
              title: Text(_statusLine()),
              subtitle: Text(
                mine ? 'Delivery status' : 'From $friendName',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  String _statusLine() {
    String at(DateTime? t) => t == null ? '' : ' · ${Dates.time(t)}';
    return switch (message.status) {
      MessageStatus.pending => 'Sending…',
      MessageStatus.sent => 'Sent${at(message.sentAt)}',
      MessageStatus.delivered => 'Delivered${at(message.deliveredAt)}',
      MessageStatus.seen => 'Seen${at(message.seenAt)}',
    };
  }
}

/// Clock → ✓ → ✓✓ → ✓✓ (bright) — the four WhatsApp states.
class _Ticks extends StatelessWidget {
  const _Ticks({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final dim = AppColors.textPrimary.withValues(alpha: 0.7);
    return switch (status) {
      MessageStatus.pending => Icon(Icons.schedule, size: 13, color: dim),
      MessageStatus.sent => Icon(Icons.check, size: 14, color: dim),
      MessageStatus.delivered => Icon(Icons.done_all, size: 14, color: dim),
      MessageStatus.seen => const Icon(
        Icons.done_all,
        size: 14,
        color: AppColors.textPrimary,
      ),
    };
  }
}

/// A photo in a bubble. Sized from the stored dimensions so the list doesn't
/// jump when the image finishes loading, and tappable for a full-screen look.
class _ChatImage extends StatelessWidget {
  const _ChatImage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final w = message.imageW ?? 4;
    final h = message.imageH ?? 3;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ImageViewer(url: message.imageUrl!),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: AspectRatio(
            aspectRatio: w / h,
            child: Image.network(
              message.imageUrl!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      color: AppColors.card,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (_, _, _) => Container(
                color: AppColors.card,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.reply,
    required this.replyAuthor,
    required this.recording,
    required this.recordElapsed,
    required this.sending,
    required this.onSend,
    required this.onMic,
    required this.onPhoto,
    required this.onCancelRecord,
    required this.onClearReply,
  });

  final TextEditingController controller;
  final ReplyRef? reply;
  final String? replyAuthor;
  final bool recording;
  final Duration recordElapsed;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final VoidCallback onPhoto;
  final VoidCallback onCancelRecord;
  final VoidCallback onClearReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reply != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                decoration: BoxDecoration(
                  color: AppColors.cardHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(color: AppColors.accent, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${replyAuthor ?? ''}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            reply!.preview ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: onClearReply,
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (recording) ...[
                  IconPill(
                    icon: Icons.delete_outline,
                    color: AppColors.danger,
                    size: 44,
                    tooltip: 'Discard',
                    onTap: onCancelRecord,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardHigh,
                        borderRadius: BorderRadius.circular(AppRadii.cardSmall),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        children: [
                          const _RecDot(),
                          const SizedBox(width: 8),
                          Text(
                            'Recording',
                            style: theme.textTheme.titleSmall,
                          ),
                          const Spacer(),
                          Text(
                            Fmt.clock(recordElapsed),
                            style: AppText.numeric(size: 15, letterSpacing: 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  IconPill(
                    icon: Icons.add_photo_alternate_outlined,
                    size: 44,
                    tooltip: 'Send a photo',
                    onTap: sending ? null : onPhoto,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(hintText: 'Message'),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final hasText = value.text.trim().isNotEmpty;
                    final send = hasText && !recording;
                    return GestureDetector(
                      onTap: sending ? null : (send ? onSend : onMic),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: Icon(
                          send
                              ? Icons.send
                              : (recording ? Icons.stop : Icons.mic),
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecDot extends StatefulWidget {
  const _RecDot();

  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
