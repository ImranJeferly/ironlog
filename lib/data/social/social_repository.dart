import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../sync/firebase_bootstrap.dart';
import 'social_models.dart';

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

  /// Makes sure the profile document exists with at least a display name.
  /// Called once after sign-in; safe to call repeatedly.
  Future<void> ensureProfile({String? email}) async {
    final me = uid;
    if (me == null) return;
    final doc = await _users.doc(me).get();
    if (doc.exists && (doc.data()?['displayName'] as String?) != null) {
      await _users.doc(me).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }
    final name = email == null
        ? 'Lifter'
        : email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    await _users.doc(me).set({
      'displayName': name.isEmpty ? 'Lifter' : name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    try {
      await _db.runTransaction((tx) async {
        final ref = _handles.doc(handle);
        final existing = await tx.get(ref);
        if (existing.exists && existing.data()?['uid'] != me) {
          throw StateError('taken');
        }
        tx.set(ref, {'uid': me});
        if (current != null) tx.delete(_handles.doc(current));
        tx.set(_users.doc(me), {'handle': handle}, SetOptions(merge: true));
      });
      return null;
    } on StateError {
      return '@$handle is taken.';
    } on Object catch (e) {
      debugPrint('IronLog: setHandle failed ($e)');
      return 'Could not save the handle. Check your connection.';
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

  /// Sends a request to [other]. Returns null on success or a reason.
  Future<String?> sendRequest(String other) async {
    final me = uid;
    if (me == null) return 'Sign in first.';
    if (other == me) return 'That’s you.';
    if (await isFriend(other)) return 'Already friends.';

    // If they already asked me, accept instead of creating a crossing request.
    final reverse = await _requests
        .doc(requestIdFor(from: other, to: me))
        .get();
    if (reverse.exists &&
        reverse.data()?['status'] == FriendRequestStatus.pending.name) {
      await acceptRequest(reverse.id);
      return null;
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
    return null;
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

  Future<void> _touchChat(
    String chatId, {
    required String me,
    required String preview,
  }) async {
    final chat = await _chats.doc(chatId).get();
    final members = [
      for (final m in (chat.data()?['members'] as List? ?? const [])) '$m',
    ];
    final updates = <String, dynamic>{
      'lastText': preview,
      'lastFrom': me,
      'lastAt': FieldValue.serverTimestamp(),
    };
    for (final m in members) {
      if (m != me) updates['unread.$m'] = FieldValue.increment(1);
    }
    await _chats.doc(chatId).update(updates);
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
    await _chats.doc(chatId).collection('messages').add({
      'from': me,
      'kind': MessageKind.text.name,
      'text': trimmed,
      'replyTo': replyTo?.toMap(),
      'sentAt': FieldValue.serverTimestamp(),
    });
    await _touchChat(chatId, me: me, preview: trimmed);
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
    await _chats.doc(chatId).collection('messages').add({
      'from': me,
      'kind': MessageKind.voice.name,
      'audio': Blob(audio),
      'audioMs': durationMs,
      'replyTo': replyTo?.toMap(),
      'sentAt': FieldValue.serverTimestamp(),
    });
    await _touchChat(
      chatId,
      me: me,
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
      final friends = await _users.doc(me).collection('friends').get();
      for (final f in friends.docs) {
        final chatId = f.data()['chatId'] as String? ?? chatIdFor(me, f.id);
        await _chats.doc(chatId).collection('messages').add({
          'from': me,
          'kind': MessageKind.system.name,
          'text': text,
          'sentAt': FieldValue.serverTimestamp(),
        });
        await _touchChat(chatId, me: me, preview: text);
      }
    } on Object catch (e) {
      debugPrint('IronLog: broadcast failed ($e)');
    }
  }
}
