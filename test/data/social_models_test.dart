import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/social/social_models.dart';

void main() {
  group('ids', () {
    test('chatIdFor is order-independent', () {
      expect(chatIdFor('bob', 'alice'), 'alice_bob');
      expect(chatIdFor('alice', 'bob'), 'alice_bob');
    });

    test('requestIdFor is directional', () {
      expect(requestIdFor(from: 'a', to: 'b'), 'a_b');
      expect(requestIdFor(from: 'b', to: 'a'), 'b_a');
    });
  });

  group('ChatMessage.status', () {
    ChatMessage msg({
      DateTime? sentAt,
      DateTime? deliveredAt,
      DateTime? seenAt,
      bool pending = false,
    }) => ChatMessage(
      id: 'm',
      from: 'me',
      kind: MessageKind.text,
      text: 'hi',
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      seenAt: seenAt,
      hasPendingWrites: pending,
    );

    final t = DateTime(2026, 9, 8, 12);

    test('pending until the server has it', () {
      expect(msg().status, MessageStatus.pending);
      expect(msg(sentAt: t, pending: true).status, MessageStatus.pending);
    });

    test('sent → delivered → seen', () {
      expect(msg(sentAt: t).status, MessageStatus.sent);
      expect(msg(sentAt: t, deliveredAt: t).status, MessageStatus.delivered);
      expect(
        msg(sentAt: t, deliveredAt: t, seenAt: t).status,
        MessageStatus.seen,
      );
    });

    test('seen wins even with a pending local write', () {
      expect(
        msg(sentAt: t, seenAt: t, pending: true).status,
        MessageStatus.seen,
      );
    });
  });

  group('ChatMessage.preview', () {
    test('voice notes show a rounded duration', () {
      const m = ChatMessage(
        id: 'v',
        from: 'me',
        kind: MessageKind.voice,
        audioMs: 12_600,
      );
      expect(m.preview, '🎤 Voice message (13 s)');
    });

    test('text and system lines echo their text', () {
      const t = ChatMessage(
        id: 't',
        from: 'me',
        kind: MessageKind.text,
        text: 'see you at 6',
      );
      const s = ChatMessage(
        id: 's',
        from: 'me',
        kind: MessageKind.system,
        text: '🏋️ Started Push',
      );
      expect(t.preview, 'see you at 6');
      expect(s.preview, '🏋️ Started Push');
    });
  });

  group('fromDoc', () {
    test('ChatMessage reads blobs, timestamps and reply refs', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final m = ChatMessage.fromDoc(
        'x',
        {
          'from': 'u1',
          'kind': 'voice',
          'audio': Blob(bytes),
          'audioMs': 4200,
          'replyTo': {'messageId': 'y', 'from': 'u2', 'preview': 'yo'},
          'sentAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        },
        hasPendingWrites: false,
      );
      expect(m.kind, MessageKind.voice);
      expect(m.audio, bytes);
      expect(m.audioMs, 4200);
      expect(m.replyTo?.messageId, 'y');
      expect(m.replyTo?.preview, 'yo');
      expect(m.sentAt, DateTime(2026, 1, 1));
      expect(m.status, MessageStatus.sent);
    });

    test('ChatMessage reads a Storage voice URL', () {
      final m = ChatMessage.fromDoc('x', {
        'from': 'u1',
        'kind': 'voice',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/x/o/a.m4a',
        'audioMs': 3000,
      });
      expect(m.audioUrl, startsWith('https://'));
      expect(m.audio, isNull);
      expect(m.preview, '🎤 Voice message (3 s)');
    });

    test('UserProfile prefers the Storage photo URL over a legacy blob', () {
      final p = UserProfile.fromDoc('u', {
        'displayName': 'Imran',
        'photoUrl': 'https://example.test/avatar.jpg',
        'photo': Blob(Uint8List.fromList([9])),
      });
      expect(p.photoUrl, 'https://example.test/avatar.jpg');
      expect(p.photo, isNotNull);
    });

    test('UserProfile falls back sensibly on an empty document', () {
      final p = UserProfile.fromDoc('u', null);
      expect(p.displayName, 'Lifter');
      expect(p.initial, 'L');
      expect(p.isTraining, isFalse);
      expect(p.stats.sessions, 0);
      expect(p.nowPlaying, isNull);
    });

    test('NowPlaying goes stale after 8 minutes', () {
      final fresh = NowPlaying(title: 'Song', updatedAt: DateTime.now());
      final old = NowPlaying(
        title: 'Song',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 9)),
      );
      expect(fresh.isFresh, isTrue);
      expect(old.isFresh, isFalse);
    });

    test('ChatSummary finds the other member and per-user unread', () {
      final c = ChatSummary.fromDoc('a_b', {
        'members': ['a', 'b'],
        'unread': {'a': 2, 'b': 0},
      });
      expect(c.otherThan('a'), 'b');
      expect(c.otherThan('b'), 'a');
      expect(c.unreadFor('a'), 2);
      expect(c.unreadFor('zzz'), 0);
    });
  });
}
