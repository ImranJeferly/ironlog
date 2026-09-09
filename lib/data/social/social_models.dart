import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Deterministic 1:1 chat id: both uids, sorted, joined. Either side derives
/// the same id without a round-trip.
String chatIdFor(String a, String b) {
  final ids = [a, b]..sort();
  return '${ids[0]}_${ids[1]}';
}

/// Deterministic friend-request id so a pair can only ever have one open
/// request in each direction (and the security rules can look it up).
String requestIdFor({required String from, required String to}) =>
    '${from}_$to';

/// First character of a name for avatars. Rune-based so a name that starts
/// with an emoji shows the emoji instead of half a surrogate pair.
String initialOf(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return String.fromCharCode(t.runes.first).toUpperCase();
}

DateTime? _ts(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

/// What's playing on the phone right now, as published to friends.
class NowPlaying {
  const NowPlaying({
    required this.title,
    this.artist,
    this.app,
    required this.updatedAt,
  });

  final String title;
  final String? artist;

  /// Package name of the player (Spotify, YouTube Music…).
  final String? app;
  final DateTime updatedAt;

  /// Anything older than this is treated as "nothing playing".
  static const stale = Duration(minutes: 8);

  bool get isFresh => DateTime.now().difference(updatedAt) < stale;

  Map<String, dynamic> toMap() => {
    'title': title,
    'artist': artist,
    'app': app,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static NowPlaying? fromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final title = m['title'] as String?;
    final at = _ts(m['updatedAt']);
    if (title == null || title.isEmpty || at == null) return null;
    return NowPlaying(
      title: title,
      artist: m['artist'] as String?,
      app: m['app'] as String?,
      updatedAt: at,
    );
  }
}

/// The headline numbers a profile shows to friends. Written by the owner
/// after every finished session and on app resume.
class ProfileStats {
  const ProfileStats({
    this.sessions = 0,
    this.streak = 0,
    this.prs = 0,
    this.adherence4w = 0,
    this.weeklySets = 0,
    this.lastWorkoutName,
    this.lastWorkoutAt,
    this.bestLifts = const {},
    this.updatedAt,
  });

  final int sessions;
  final int streak;
  final int prs;

  /// 0–1.
  final double adherence4w;
  final int weeklySets;
  final String? lastWorkoutName;
  final DateTime? lastWorkoutAt;

  /// Exercise name → best estimated 1RM in kg (top few lifts).
  final Map<String, double> bestLifts;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
    'sessions': sessions,
    'streak': streak,
    'prs': prs,
    'adherence4w': adherence4w,
    'weeklySets': weeklySets,
    'lastWorkoutName': lastWorkoutName,
    'lastWorkoutAt': lastWorkoutAt == null
        ? null
        : Timestamp.fromDate(lastWorkoutAt!),
    'bestLifts': bestLifts,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static ProfileStats fromMap(Map<String, dynamic>? m) {
    if (m == null) return const ProfileStats();
    final lifts = <String, double>{};
    final raw = m['bestLifts'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) lifts['$k'] = v.toDouble();
      });
    }
    return ProfileStats(
      sessions: (m['sessions'] as num?)?.toInt() ?? 0,
      streak: (m['streak'] as num?)?.toInt() ?? 0,
      prs: (m['prs'] as num?)?.toInt() ?? 0,
      adherence4w: (m['adherence4w'] as num?)?.toDouble() ?? 0,
      weeklySets: (m['weeklySets'] as num?)?.toInt() ?? 0,
      lastWorkoutName: m['lastWorkoutName'] as String?,
      lastWorkoutAt: _ts(m['lastWorkoutAt']),
      bestLifts: lifts,
      updatedAt: _ts(m['updatedAt']),
    );
  }
}

/// A user as seen by others: the `users/{uid}` document.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.handle,
    this.bio,
    this.photoUrl,
    this.photo,
    this.stats = const ProfileStats(),
    this.nowPlaying,
    this.lastSeenAt,
    this.activeSessionName,
  });

  final String uid;
  final String displayName;

  /// Unique, lowercase, chosen by the user — how friends find you.
  final String? handle;
  final String? bio;

  /// Download URL of the profile photo in Firebase Storage
  /// (`profiles/{uid}/avatar.jpg`).
  final String? photoUrl;

  /// Legacy: small JPEG stored inline in the document by builds ≤29, which had
  /// no Storage. Still rendered so old profiles don't go blank.
  /// TODO(2026-12-01): drop once nobody is on build ≤29.
  final Uint8List? photo;
  final ProfileStats stats;
  final NowPlaying? nowPlaying;
  final DateTime? lastSeenAt;

  /// Name of the workout in progress, if any — "training right now".
  final String? activeSessionName;

  bool get isTraining => activeSessionName != null;

  String get initial => initialOf(displayName);

  static UserProfile fromDoc(String uid, Map<String, dynamic>? m) {
    m ??= const {};
    final photo = m['photo'];
    return UserProfile(
      uid: uid,
      displayName: (m['displayName'] as String?)?.trim().isNotEmpty == true
          ? m['displayName'] as String
          : 'Lifter',
      handle: m['handle'] as String?,
      bio: m['bio'] as String?,
      photoUrl: m['photoUrl'] as String?,
      photo: photo is Blob ? photo.bytes : null,
      stats: ProfileStats.fromMap(m['stats'] as Map<String, dynamic>?),
      nowPlaying: NowPlaying.fromMap(m['nowPlaying'] as Map<String, dynamic>?),
      lastSeenAt: _ts(m['lastSeenAt']),
      activeSessionName: m['activeSessionName'] as String?,
    );
  }
}

enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    required this.status,
    required this.createdAt,
    this.fromName,
    this.fromHandle,
  });

  final String id;
  final String from;
  final String to;
  final FriendRequestStatus status;
  final DateTime createdAt;

  /// Denormalised so the request list needs no extra reads.
  final String? fromName;
  final String? fromHandle;

  static FriendRequest fromDoc(String id, Map<String, dynamic> m) =>
      FriendRequest(
        id: id,
        from: m['from'] as String,
        to: m['to'] as String,
        status: FriendRequestStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => FriendRequestStatus.pending,
        ),
        createdAt: _ts(m['createdAt']) ?? DateTime.now(),
        fromName: m['fromName'] as String?,
        fromHandle: m['fromHandle'] as String?,
      );
}

class Friend {
  const Friend({required this.uid, required this.since, required this.chatId});

  final String uid;
  final DateTime since;
  final String chatId;
}

/// `chats/{chatId}` — the list row.
class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.members,
    this.lastText,
    this.lastFrom,
    this.lastAt,
    this.unread = const {},
  });

  final String id;
  final List<String> members;
  final String? lastText;
  final String? lastFrom;
  final DateTime? lastAt;

  /// uid → unread count.
  final Map<String, int> unread;

  String otherThan(String uid) => members.firstWhere(
    (m) => m != uid,
    orElse: () => members.isEmpty ? '' : members.first,
  );

  int unreadFor(String uid) => unread[uid] ?? 0;

  static ChatSummary fromDoc(String id, Map<String, dynamic> m) {
    final unread = <String, int>{};
    final raw = m['unread'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) unread['$k'] = v.toInt();
      });
    }
    return ChatSummary(
      id: id,
      members: [for (final x in (m['members'] as List? ?? const [])) '$x'],
      lastText: m['lastText'] as String?,
      lastFrom: m['lastFrom'] as String?,
      lastAt: _ts(m['lastAt']),
      unread: unread,
    );
  }
}

enum MessageKind { text, voice, system }

/// WhatsApp-style delivery state, derived from timestamps on the message.
enum MessageStatus { pending, sent, delivered, seen }

class ReplyRef {
  const ReplyRef({required this.messageId, required this.from, this.preview});

  final String messageId;
  final String from;
  final String? preview;

  Map<String, dynamic> toMap() => {
    'messageId': messageId,
    'from': from,
    'preview': preview,
  };

  static ReplyRef? fromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    return ReplyRef(
      messageId: m['messageId'] as String? ?? '',
      from: m['from'] as String? ?? '',
      preview: m['preview'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.from,
    required this.kind,
    this.text,
    this.audioUrl,
    this.audio,
    this.audioMs = 0,
    this.replyTo,
    this.sentAt,
    this.deliveredAt,
    this.seenAt,
    this.hasPendingWrites = false,
  });

  final String id;
  final String from;
  final MessageKind kind;
  final String? text;

  /// Voice note download URL in Firebase Storage
  /// (`chats/{chatId}/voice/{messageId}.m4a`).
  final String? audioUrl;

  /// Legacy: voice note bytes inline in the document, from builds ≤29, which
  /// had no Storage. Still playable.
  /// TODO(2026-12-01): drop once nobody is on build ≤29.
  final Uint8List? audio;
  final int audioMs;
  final ReplyRef? replyTo;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? seenAt;

  /// True until the local write has reached the server.
  final bool hasPendingWrites;

  MessageStatus get status {
    if (seenAt != null) return MessageStatus.seen;
    if (deliveredAt != null) return MessageStatus.delivered;
    if (hasPendingWrites || sentAt == null) return MessageStatus.pending;
    return MessageStatus.sent;
  }

  /// One-line preview for the chat list and reply quotes.
  String get preview => switch (kind) {
    MessageKind.text => text ?? '',
    MessageKind.voice => '🎤 Voice message (${(audioMs / 1000).round()} s)',
    MessageKind.system => text ?? '',
  };

  static ChatMessage fromDoc(
    String id,
    Map<String, dynamic> m, {
    bool hasPendingWrites = false,
  }) {
    final audio = m['audio'];
    return ChatMessage(
      id: id,
      from: m['from'] as String? ?? '',
      kind: MessageKind.values.firstWhere(
        (k) => k.name == m['kind'],
        orElse: () => MessageKind.text,
      ),
      text: m['text'] as String?,
      audioUrl: m['audioUrl'] as String?,
      audio: audio is Blob ? audio.bytes : null,
      audioMs: (m['audioMs'] as num?)?.toInt() ?? 0,
      replyTo: ReplyRef.fromMap(m['replyTo'] as Map<String, dynamic>?),
      sentAt: _ts(m['sentAt']),
      deliveredAt: _ts(m['deliveredAt']),
      seenAt: _ts(m['seenAt']),
      hasPendingWrites: hasPendingWrites,
    );
  }
}
