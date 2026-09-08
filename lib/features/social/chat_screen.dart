import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Foreground pushes for this chat are redundant while it's on screen.
    PushService.activeChatId = widget.chatId;
  }

  @override
  void dispose() {
    if (PushService.activeChatId == widget.chatId) {
      PushService.activeChatId = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    _recTicker?.cancel();
    _recorder.dispose();
    _input.dispose();
    super.dispose();
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
    setState(() => _reply = null);
    await ref
        .read(socialRepositoryProvider)
        .sendText(widget.chatId, text, replyTo: reply);
    if (mounted) setState(() => _sending = false);
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
      setState(() => _reply = null);
      final error = await ref
          .read(socialRepositoryProvider)
          .sendVoice(
            widget.chatId,
            clip.bytes,
            durationMs: clip.durationMs,
            replyTo: reply,
          );
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
    });

    final np = friend?.nowPlaying;
    final subtitle = friend == null
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
                photo: friend?.photo,
                size: 36,
                training: friend?.isTraining ?? false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
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
                          color: friend?.isTraining ?? false
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
                              friendName: friend?.displayName ?? 'Friend',
                              onReply: () => _setReply(m),
                            ),
                        ],
                      );
                    },
                  ),
          ),
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
            onCancelRecord: _cancelRecord,
            onClearReply: () => setState(() => _reply = null),
          ),
        ],
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
    required this.friendName,
    required this.onReply,
  });

  final ChatMessage message;
  final bool mine;
  final String friendName;
  final VoidCallback onReply;

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
            if (message.kind == MessageKind.voice && message.audio != null)
              VoiceNotePlayer(
                bytes: message.audio!,
                durationMs: message.audioMs,
                mine: mine,
              )
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
        child: body,
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
            const SizedBox(height: AppSpacing.sm),
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
                ] else
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
