'use strict';

/**
 * IronLog Cloud Functions — the push server the app used to fake on-device.
 *
 * Everything here is a Firestore trigger that fans a write out to the other
 * person's phones over FCM. The app itself never sends a notification to
 * anyone else: it writes the document, and this is what turns that write
 * into a push. Recipients register their FCM tokens under
 * `users/{uid}/fcmTokens/{token}`; dead tokens are pruned on the first
 * failed send.
 */

const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const logger = require('firebase-functions/logger');

initializeApp();
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const db = getFirestore();

/** Android channel the app creates for friend notifications (see push.dart). */
const CHANNEL_SOCIAL = 'ironlog_social';
const ACCENT = '#FF1F2F';

// ------------------------------------------------------------------ helpers

/** `chatIdFor` in the app joins the two uids with an underscore. */
function membersOf(chatId) {
  const parts = String(chatId).split('_');
  return parts.length === 2 && parts.every((p) => p.length > 0) ? parts : [];
}

async function displayNameOf(uid) {
  try {
    const snap = await db.collection('users').doc(uid).get();
    const name = snap.get('displayName');
    return typeof name === 'string' && name.trim() ? name.trim() : 'Friend';
  } catch (e) {
    logger.warn('displayNameOf failed', { uid, error: String(e) });
    return 'Friend';
  }
}

async function tokensOf(uid) {
  const snap = await db.collection('users').doc(uid).collection('fcmTokens').get();
  return snap.docs.map((d) => d.id);
}

/**
 * Sends one notification to every device of [uid]. `data` values must be
 * strings (FCM requirement). Prunes tokens FCM reports as gone.
 */
async function pushTo(uid, { title, body, data, tag, collapseKey }) {
  const tokens = await tokensOf(uid);
  if (tokens.length === 0) {
    logger.debug('no tokens', { uid });
    return;
  }

  const message = {
    tokens,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data || {}).map(([k, v]) => [k, String(v == null ? '' : v)]),
    ),
    android: {
      priority: 'high',
      collapseKey,
      notification: {
        channelId: CHANNEL_SOCIAL,
        icon: 'ic_stat_ironlog',
        color: ACCENT,
        tag,
        // Tapping opens MainActivity; the app reads `data.route` from the
        // launching intent / onMessageOpenedApp.
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      payload: { aps: { sound: 'default', 'thread-id': tag || 'ironlog' } },
    },
  };

  const res = await getMessaging().sendEachForMulticast(message);
  const dead = [];
  res.responses.forEach((r, i) => {
    if (r.success) return;
    const code = r.error && r.error.code;
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/invalid-argument'
    ) {
      dead.push(tokens[i]);
    } else {
      logger.warn('send failed', { uid, code, message: r.error && r.error.message });
    }
  });
  if (dead.length > 0) {
    const batch = db.batch();
    for (const t of dead) {
      batch.delete(db.collection('users').doc(uid).collection('fcmTokens').doc(t));
    }
    await batch.commit();
    logger.info('pruned dead tokens', { uid, count: dead.length });
  }
  logger.info('pushed', { uid, sent: res.successCount, failed: res.failureCount });
}

// ----------------------------------------------------------------- messages

/**
 * New chat message → push to every other member. System lines (session
 * started / finished, PRs) go out the same way, titled by the friend's name.
 */
exports.onMessageCreated = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const { chatId, messageId } = event.params;
    const m = snap.data() || {};
    const from = m.from;
    if (typeof from !== 'string' || !from) return;

    const members = membersOf(chatId);
    const recipients = members.filter((u) => u !== from);
    if (recipients.length === 0) return;

    const name = await displayNameOf(from);
    let body;
    switch (m.kind) {
      case 'voice': {
        const secs = Math.round((Number(m.audioMs) || 0) / 1000);
        body = 'Voice message (' + secs + ' s)';
        break;
      }
      case 'system':
      case 'text':
      default:
        body = typeof m.text === 'string' && m.text ? m.text : 'New message';
    }

    await Promise.all(
      recipients.map((uid) =>
        pushTo(uid, {
          title: name,
          body,
          tag: chatId,
          collapseKey: chatId,
          data: {
            type: 'message',
            route: 'chat:' + chatId + ':' + from,
            chatId,
            messageId,
            from,
            kind: m.kind || 'text',
          },
        }),
      ),
    );
  },
);

// ------------------------------------------------------------------ requests

/**
 * Friend requests: a new pending request pushes to the recipient; an
 * acceptance pushes back to the sender with a route straight into the chat.
 */
exports.onFriendRequestWritten = onDocumentWritten(
  'friendRequests/{requestId}',
  async (event) => {
    const before = event.data && event.data.before.exists ? event.data.before.data() : null;
    const after = event.data && event.data.after.exists ? event.data.after.data() : null;
    if (!after) return; // deleted / cancelled — nothing to say.

    const { from, to, status } = after;
    if (typeof from !== 'string' || typeof to !== 'string') return;
    const requestId = event.params.requestId;

    // Created as pending → "X wants to train with you".
    if (!before && status === 'pending') {
      const name =
        typeof after.fromName === 'string' && after.fromName
          ? after.fromName
          : await displayNameOf(from);
      const handle =
        typeof after.fromHandle === 'string' && after.fromHandle
          ? ' (@' + after.fromHandle + ')'
          : '';
      await pushTo(to, {
        title: 'Friend request',
        body: name + handle + ' wants to train with you',
        tag: 'request:' + requestId,
        data: { type: 'request', route: 'friends', requestId, from },
      });
      return;
    }

    // pending → accepted: tell the sender.
    if (before && before.status !== 'accepted' && status === 'accepted') {
      const name = await displayNameOf(to);
      const chatId = [from, to].sort().join('_');
      await pushTo(from, {
        title: "You're friends now",
        body: name + ' accepted your request — say hi.',
        tag: 'accepted:' + requestId,
        data: { type: 'accepted', route: 'chat:' + chatId + ':' + to, chatId, from: to },
      });
    }
  },
);

// ---------------------------------------------------------------- housekeeping

/**
 * A token document is keyed by the token itself; the app stamps `updatedAt`
 * on every launch. Stamp `createdAt` server-side so stale tokens can be
 * reasoned about from the console.
 */
exports.onTokenCreated = onDocumentCreated('users/{uid}/fcmTokens/{token}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  if (snap.get('createdAt')) return;
  await snap.ref.set({ createdAt: FieldValue.serverTimestamp() }, { merge: true });
});
