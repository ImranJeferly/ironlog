import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../sync/firebase_bootstrap.dart';
import 'social_models.dart';

enum _Claim { ok, taken, denied, failed }

/// Outcome of [SocialRepository.sendRequest].
enum SendOutcome {
  /// A pending request now sits in their Requests tab.
  sent,

  /// They had already asked you — that request was accepted instead, so you
  /// are friends and a chat exists.
  nowFriends,

  /// Nothing to do (already friends, or it's you).
  noop,
}

class SendResult {
  const SendResult(this.outcome, {this.message, this.chatId});

  final SendOutcome outcome;
  final String? message;

  /// Set for [SendOutcome.nowFriends].
  final String? chatId;
}

/// Human explanation for a Firestore failure — the one that matters most is
/// "rules not deployed", which otherwise looks like an empty screen.
String describeSocialError(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' =>
        'Firestore rejected this (permission denied). The security rules in '
            'firestore.rules aren\'t published in the Firebase console yet.',
      'unavailable' => 'Firestore is unreachable — check your connection.',
      _ => 'Firestore error: ${error.code}',
    };
  }
  return 'Something went wrong: $error';
}

/// Friends, requests, chats and profiles — all in Firestore documents, no
/// Storage. Photos and voice notes travel as inline blobs, which keeps the
/// whole feature inside the free tier.
///
/// Every method is a no-op (or empty stream) when Firebase isn't available or
/// the user isn't signed into a real account, so the rest of the app never has
/// to special-case it.
class SocialRepository {
  SocialRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get isAvailable => FirebaseBootstrap.isAvailable;

  String? get uid => FirebaseBootstrap.uid;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _handles =>
      _db.collection('handles');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('friendRequests');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  // ------------------------------------------------------------- profiles

  Stream<UserProfile?> watchProfile(String userId) {
    if (!isAvailable) return Stream.value(null);
    return _users
        .doc(userId)
        .snapshots()
        .map((d) => d.exists ? UserProfile.fromDoc(d.id, d.data()) : null);
  }

  Stream<UserProfile?> watchMyProfile() {
    final me = uid;
    if (me == null) return Stream.value(null);
    return watchProfile(me);
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    if (!isAvailable) return null;
    final d = await _users.doc(userId).get();
    return d.exists ? UserProfile.fromDoc(d.id, d.data()) : null;
  }

  /// Makes sure the profile document exists with a display name and a
  /// handle. Called after sign-in and on every resume; safe to repeat.
  /// Existing accounts without a handle get one derived from their email
  /// the same way the name is, so friends can find them right away.
  Future<void> ensureProfile({String? email}) async {
    final me = uid;
    if (me == null) return;
    final doc = await _users.doc(me).get();
    final data = doc.data() ?? const {};
    final hasName = (data['displayName'] as String?)?.trim().isNotEmpty == true;

    if (hasName) {
      await _users.doc(me).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      final name = email == null
          ? 'Lifter'
          : email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
      await _users.doc(me).set({
        'displayName': name.isEmpty ? 'Lifter' : name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if ((data['handle'] as String?) == null) {
      await _autoHandle(me, email: email, name: data['displayName'] as String?);
    }
  }

  /// Picks the first free handle from the email/name base: `imran`, then
  /// `imran2`, `imran3`… Stops on any error other than "taken" (offline,
  /// rules not deployed) — the user can still set one by hand later.
  Future<void> _autoHandle(String me, {String? email, String? name}) async {
    final base = suggestHandle(email: email, name: name);
    for (var i = 1; i <= 40; i++) {
      final candidate = i == 1 ? base : '$base$i';
      final result = await _claimHandle(me, candidate, current: null);
      if (result != _Claim.taken) return;
    }
  }

  /// Lowercase `[a-z0-9_]`, 3–16 characters, from the email local part or
  /// the display name. Leaves room for a numeric suffix.
  static String suggestHandle({String? email, String? name}) {
    final source = (email != null && email.contains('@'))
        ? email.split('@').first
        : (name ?? '');
    var base = source
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (base.length < 3) base = 'lifter';
    if (base.length > 16) base = base.substring(0, 16);
    return base;
  }

  Future<void> updateProfile({String? displayName, String? bio}) async {
    final me = uid;
    if (me == null) return;
    await _users.doc(me).set({
      if (displayName != null) 'displayName': displayName.trim(),
      if (bio != null) 'bio': bio.trim(),
    }, SetOptions(merge: true));
  }

  /// Small JPEG bytes → inline blob on the profile. Pass null to clear.
  Future<void> setPhoto(Uint8List? jpeg) async {
    final me = uid;
    if (me == null) return;
    await _users.doc(me).set({
      'photo': jpeg == null ? FieldValue.delete() : Blob(jpeg),
    }, SetOptions(merge: true));
  }

  static final _handleRx = RegExp(r'^[a-z0-9_]{3,20}$');

  static String normalizeHandle(String raw) =>
      raw.trim().toLowerCase().replaceAll('@', '');

  /// Claims [raw] as this user's unique handle. Returns null on success or a
  /// human-readable reason.
  Future<String?> setHandle(String raw) async {
    final me = uid;
    if (me == null) return 'Sign in first.';
    final handle = normalizeHandle(raw);
    if (!_handleRx.hasMatch(handle)) {
      return 'Handles are 3–20 characters: letters, numbers, underscore.';
    }
    final current = (await _users.doc(me).get()).data()?['handle'] as String?;
    if (current == handle) return null;

    return switch (await _claimHandle(me, handle, current: current)) {
      _Claim.ok => null,
      _Claim.taken => '@$handle is taken.',
      _Claim.denied =>
        'Firestore rejected the write — the security rules in '
            'firestore.rules aren\'t deployed yet.',
      _Claim.failed => 'Could not save the handle. Check your connection.',
    };
  }

  /// One atomic claim: the `handles/{handle}` row and the profile field, and
  /// the old row released. [current] is the handle being replaced, if any.
  Future<_Claim> _claimHandle(
    String me,
    String handle, {
    required String? current,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final ref = _handles.doc(handle);
        final existing = await tx.get(ref);
        if (existing.exists && existing.data()?['uid'] != me) {
          throw StateError('taken');
        }
        tx.set(ref, {'uid': me});
        if (current != null && current != handle) {
          tx.delete(_handles.doc(current));
        }
        tx.set(_users.doc(me), {'handle': handle}, SetOptions(merge: true));
      });
      return _Claim.ok;
    } on StateError {
      return _Claim.taken;
    } on FirebaseException catch (e) {
      debugPrint('IronLog: claim @$handle failed (${e.code})');
      return e.code == 'permission-denied' ? _Claim.denied : _Claim.failed;
    } on Object catch (e) {
      debugPrint('IronLog: claim @$handle failed ($e)');
      return _Claim.failed;
    }
  }

  /// Finds a user by @handle. Null when nobody has it.
  Future<UserProfile?> findByHandle(String raw) async {
    if (!isAvailable) return null;
    final handle = normalizeHandle(raw);
    if (handle.isEmpty) return null;
    final d = await _handles.doc(handle).get();
    final target = d.data()?['uid'] as String?;
    if (target == null) return null;
    return fetchProfile(target);
  }

  Future<void> publishStats(ProfileStats stats) async {
    final me = uid;
    if (me == null) return;
    await _users.doc(me).set({
      'stats': stats.toMap(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> publishNowPlaying(NowPlaying? np) async {
    final me = uid;
    if (me == null) return;
    await _users.doc(me).set({
      'nowPlaying': np == null ? FieldValue.delete() : np.toMap(),
    }, SetOptions(merge: true));
  }

  Future<void> setActiveSession(String? name) async {
    final me = uid;
    if (me == null) return;
    await _users.doc(me).set({
      'activeSessionName': name ?? FieldValue.delete(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // -------------------------------------------------------------- friends

  Stream<List<Friend>> watchFriends() {
    final me = uid;
    if (me == null) return Stream.value(const []);
    return _users.doc(me).collection('friends').snapshots().map(
      (s) => [
        for (final d in s.docs)
          Friend(
            uid: d.id,
            since: (d.data()['since'] as Timestamp?)?.toDate() ?? DateTime.now(),
            chatId: d.data()['chatId'] as String? ?? chatIdFor(me, d.id),
          ),
      ],
    );
  }

  Future<bool> isFriend(String other) async {
    final me = uid;
    if (me == null) return false;
    return (await _users.doc(me).collection('friends').doc(other).get()).exists;
  }

  /// Requests addressed to me that are still pending.
  Stream<List<FriendRequest>> watchIncomingRequests() {
    final me = uid;
    if (me == null) return Stream.value(const []);
    return _requests
        .where('to', isEqualTo: me)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .snapshots()
        .map(
          (s) => [for (final d in s.docs) FriendRequest.fromDoc(d.id, d.data())]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  /// Requests I sent that are still pending.
  Stream<List<FriendRequest>> watchOutgoingRequests() {
    final me = uid;
    if (me == null) return Stream.value(const []);
    return _requests
        .where('from', isEqualTo: me)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .snapshots()
        .map(
          (s) => [for (final d in s.docs) FriendRequest.fromDoc(d.id, d.data())],
        );
  }

  /// Sends a request to [other]. Firestore errors propagate so the caller
  /// can show [describeSocialError].
  Future<SendResult> sendRequest(String other) async {
    final me = uid;
    if (me == null) {
      return const SendResult(SendOutcome.noop, message: 'Sign in first.');
    }
    if (other == me) {
      return const SendResult(SendOutcome.noop, message: 'That’s you.');
    }
    if (await isFriend(other)) {
      return SendResult(
        SendOutcome.nowFriends,
        message: 'Already friends.',
        chatId: chatIdFor(me, other),
      );
    }

    // If they already asked me, accept instead of creating a crossing request.
    final reverse = await _requests
        .doc(requestIdFor(from: other, to: me))
        .get();
    if (reverse.exists &&
        reverse.data()?['status'] == FriendRequestStatus.pending.name) {
      await acceptRequest(reverse.id);
      return SendResult(
        SendOutcome.nowFriends,
        message: 'They had already asked you — you’re friends now.',
        chatId: chatIdFor(me, other),
      );
    }

    final mine = await _users.doc(me).get();
    await _requests.doc(requestIdFor(from: me, to: other)).set({
      'from': me,
      'to': other,
      'status': FriendRequestStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'fromName': mine.data()?['displayName'],
      'fromHandle': mine.data()?['handle'],
    });
    return const SendResult(SendOutcome.sent);
  }

  Future<void> cancelRequest(String requestId) => _requests.doc(requestId).delete();

  Future<void> declineRequest(String requestId) => _requests
      .doc(requestId)
      .set({'status': FriendRequestStatus.declined.name}, SetOptions(merge: true));

  /// Accepts: marks the request, writes both friend rows and creates the chat.
  Future<void> acceptRequest(String requestId) async {
    final me = uid;
    if (me == null) return;
    final req = await _requests.doc(requestId).get();
    final from = req.data()?['from'] as String?;
    if (from == null || req.data()?['to'] != me) return;

    final chatId = chatIdFor(me, from);
    final now = FieldValue.serverTimestamp();

    // Status first — the security rules for the cross-write below check it.
    await _requests.doc(requestId).set({
      'status': FriendRequestStatus.accepted.name,
      'acceptedAt': now,
    }, SetOptions(merge: true));

    final batch = _db.batch();
    batch.set(_users.doc(me).collection('friends').doc(from), {
      'since': now,
      'chatId': chatId,
    });
    batch.set(_users.doc(from).collection('friends').doc(me), {
      'since': now,
      'chatId': chatId,
    });
    batch.set(_chats.doc(chatId), {
      'members': [me, from]..sort(),
      'createdAt': now,
      'lastAt': now,
      'lastText': 'You’re now friends — say hi.',
      'lastFrom': null,
      'unread': {me: 0, from: 0},
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> removeFriend(String other) async {
    final me = uid;
    if (me == null) return;
    final batch = _db.batch();
    batch.delete(_users.doc(me).collection('friends').doc(other));
    batch.delete(_users.doc(other).collection('friends').doc(me));
    batch.delete(_requests.doc(requestIdFor(from: me, to: other)));
    batch.delete(_requests.doc(requestIdFor(from: other, to: me)));
    await batch.commit();
  }

  // ---------------------------------------------------------------- chats

  Stream<List<ChatSummary>> watchChats() {
    final me = uid;
    if (me == null) return Stream.value(const []);
    return _chats.where('members', arrayContains: me).snapshots().map((s) {
      final list = [
        for (final d in s.docs) ChatSummary.fromDoc(d.id, d.data()),
      ];
      list.sort((a, b) {
        final x = a.lastAt ?? DateTime(2000);
        final y = b.lastAt ?? DateTime(2000);
        return y.compareTo(x);
      });
      return list;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 200}) {
    if (!isAvailable) return Stream.value(const []);
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map(
          (s) => [
            for (final d in s.docs)
              ChatMessage.fromDoc(
                d.id,
                d.data(),
                hasPendingWrites: d.metadata.hasPendingWrites,
              ),
          ],
        );
  }

  /// Members of a 1:1 chat from its id (`chatIdFor` joins the two uids with
  /// an underscore; Firebase uids never contain one). Avoids a server read
  /// on every send, which is what stalled the composer on a flaky link.
  List<String> _membersOf(String chatId) {
    final parts = chatId.split('_');
    return parts.length == 2 && parts.every((p) => p.isNotEmpty)
        ? parts
        : const [];
  }

  /// Writes a message and the chat's "last message / unread" fields in one
  /// atomic batch, and returns as soon as the write is queued locally.
  /// Firestore shows it immediately (pending tick) and delivers when the
  /// network allows; awaiting the server here only freezes the UI offline.
  void _post(
    String chatId, {
    required String me,
    required Map<String, dynamic> message,
    required String preview,
  }) {
    final chat = _chats.doc(chatId);
    final batch = _db.batch();
    batch.set(chat.collection('messages').doc(), message);
    final updates = <String, dynamic>{
      'lastText': preview,
      'lastFrom': me,
      'lastAt': FieldValue.serverTimestamp(),
    };
    for (final m in _membersOf(chatId)) {
      if (m != me) updates['unread.$m'] = FieldValue.increment(1);
    }
    batch.update(chat, updates);
    unawaited(
      batch.commit().catchError((Object e) {
        debugPrint('IronLog: message write failed ($e)');
      }),
    );
  }

  /// Nudges a stalled connection: Firestore's stream can sit in back-off
  /// after a network switch; a disable/enable cycle forces a reconnect and
  /// flushes queued writes. Safe to call any time.
  Future<void> kickNetwork() async {
    try {
      await _db.disableNetwork();
      await _db.enableNetwork();
    } on Object catch (e) {
      debugPrint('IronLog: kickNetwork failed ($e)');
    }
  }

  Future<void> sendText(
    String chatId,
    String text, {
    ReplyRef? replyTo,
  }) async {
    final me = uid;
    if (me == null) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _post(
      chatId,
      me: me,
      message: {
        'from': me,
        'kind': MessageKind.text.name,
        'text': trimmed,
        'replyTo': replyTo?.toMap(),
        'sentAt': FieldValue.serverTimestamp(),
      },
      preview: trimmed,
    );
  }

  /// Inline AAC bytes. Firestore documents cap at 1 MiB, so the recorder keeps
  /// clips short and low-bitrate.
  Future<String?> sendVoice(
    String chatId,
    Uint8List audio, {
    required int durationMs,
    ReplyRef? replyTo,
  }) async {
    final me = uid;
    if (me == null) return 'Sign in first.';
    if (audio.length > 900 * 1024) {
      return 'That voice note is too long to send.';
    }
    _post(
      chatId,
      me: me,
      message: {
        'from': me,
        'kind': MessageKind.voice.name,
        'audio': Blob(audio),
        'audioMs': durationMs,
        'replyTo': replyTo?.toMap(),
        'sentAt': FieldValue.serverTimestamp(),
      },
      preview: '🎤 Voice message (${(durationMs / 1000).round()} s)',
    );
    return null;
  }

  /// Receiver-side: mark everything from the other person as delivered.
  Future<void> markDelivered(String chatId, List<ChatMessage> messages) async {
    final me = uid;
    if (me == null) return;
    final batch = _db.batch();
    var n = 0;
    for (final m in messages) {
      if (m.from == me || m.deliveredAt != null || m.kind == MessageKind.system) {
        continue;
      }
      batch.update(_chats.doc(chatId).collection('messages').doc(m.id), {
        'deliveredAt': FieldValue.serverTimestamp(),
      });
      if (++n >= 400) break;
    }
    if (n > 0) await batch.commit();
  }

  /// Receiver-side, while the chat is open: mark as seen and clear my unread.
  Future<void> markSeen(String chatId, List<ChatMessage> messages) async {
    final me = uid;
    if (me == null) return;
    final batch = _db.batch();
    var n = 0;
    for (final m in messages) {
      if (m.from == me || m.seenAt != null) continue;
      batch.update(_chats.doc(chatId).collection('messages').doc(m.id), {
        'seenAt': FieldValue.serverTimestamp(),
        if (m.deliveredAt == null) 'deliveredAt': FieldValue.serverTimestamp(),
      });
      if (++n >= 400) break;
    }
    batch.update(_chats.doc(chatId), {'unread.$me': 0});
    await batch.commit();
  }

  /// Posts a system line ("started Push A", "new PR…") into every friend chat.
  Future<void> broadcast(String text) async {
    final me = uid;
    if (me == null || !isAvailable) return;
    try {
      // Cache first: the friend list rarely changes and this must not wait
      // on the network mid-session.
      QuerySnapshot<Map<String, dynamic>> friends;
      try {
        friends = await _users
            .doc(me)
            .collection('friends')
            .get(const GetOptions(source: Source.cache));
        if (friends.docs.isEmpty) throw StateError('empty cache');
      } on Object {
        friends = await _users.doc(me).collection('friends').get();
      }
      for (final f in friends.docs) {
        final chatId = f.data()['chatId'] as String? ?? chatIdFor(me, f.id);
        _post(
          chatId,
          me: me,
          message: {
            'from': me,
            'kind': MessageKind.system.name,
            'text': text,
            'sentAt': FieldValue.serverTimestamp(),
          },
          preview: text,
        );
      }
    } on Object catch (e) {
      debugPrint('IronLog: broadcast failed ($e)');
    }
  }
}
