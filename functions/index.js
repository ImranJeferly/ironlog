// IronLog push fan-out.
//
// The app never holds a server key: every notification starts as a Firestore
// write the client is already allowed to make (a chat message, a friend
// request), and these triggers turn it into an FCM push to the recipient's
// registered devices (`users/{uid}/devices/{token}`).
//
// Deploy with `firebase deploy --only functions` (needs the Blaze plan; the
// free quota covers a gym's worth of chat many times over).

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");

initializeApp();
setGlobalOptions({ region: "europe-west1", maxInstances: 10 });

const db = getFirestore();

/** Same id the app creates for its friends channel. */
const CHANNEL_ID = "ironlog_social";

// ---------------------------------------------------------------- helpers

async function profile(uid) {
  const snap = await db.collection("users").doc(uid).get();
  const d = snap.exists ? snap.data() : {};
  return {
    name: (d.displayName && d.displayName.trim()) || "Lifter",
    handle: d.handle || null,
  };
}

async function tokensFor(uid) {
  const snap = await db.collection("users").doc(uid).collection("devices").get();
  return snap.docs.map((d) => d.id).filter((t) => t && t.length > 20);
}

/**
 * Sends one push to every device of [uid]. Dead tokens are pruned so the
 * list stays clean without any client involvement.
 */
async function pushTo(uid, { title, body, data, tag }) {
  const tokens = await tokensFor(uid);
  if (tokens.length === 0) return;

  const res = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: { ...data, title, body },
    android: {
      priority: "high",
      notification: {
        channelId: CHANNEL_ID,
        tag,
        sound: "default",
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: { aps: { sound: "default", "thread-id": tag } },
    },
  });

  const dead = [];
  res.responses.forEach((r, i) => {
    if (r.success) return;
    const code = r.error && r.error.code;
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token" ||
      code === "messaging/invalid-argument"
    ) {
      dead.push(tokens[i]);
    } else {
      logger.warn("push failed", { uid, code });
    }
  });
  if (dead.length > 0) {
    const batch = db.batch();
    dead.forEach((t) =>
      batch.delete(db.collection("users").doc(uid).collection("devices").doc(t)),
    );
    await batch.commit();
  }
}

function preview(message) {
  switch (message.kind) {
    case "voice": {
      const s = Math.round((message.audioMs || 0) / 1000);
      return `🎤 Voice message (${s} s)`;
    }
    case "system":
    case "text":
    default:
      return message.text || "";
  }
}

// --------------------------------------------------------------- triggers

/**
 * Every chat message — typed, voice, or a system line the app broadcasts on
 * session start / finish / PR — goes to the other member of the chat.
 */
exports.onChatMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const message = snap.data();
    const { chatId, messageId } = event.params;

    const chat = await db.collection("chats").doc(chatId).get();
    if (!chat.exists) return;
    const members = chat.data().members || [];
    const recipients = members.filter((m) => m && m !== message.from);
    if (recipients.length === 0) return;

    const sender = await profile(message.from);
    const body = preview(message);
    if (!body) return;

    await Promise.all(
      recipients.map((uid) =>
        pushTo(uid, {
          title: sender.name,
          body,
          tag: chatId,
          data: {
            type: "chat",
            chatId,
            messageId,
            friendUid: message.from,
            kind: message.kind || "text",
          },
        }),
      ),
    );
  },
);

/** Someone wants to be friends. */
exports.onFriendRequest = onDocumentCreated(
  "friendRequests/{requestId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const req = snap.data();
    if (req.status !== "pending" || !req.to || !req.from) return;

    const from = await profile(req.from);
    const who = from.handle ? `${from.name} (@${from.handle})` : from.name;
    await pushTo(req.to, {
      title: "Friend request",
      body: `${who} wants to train with you.`,
      tag: "friends",
      data: { type: "friends", requestId: event.params.requestId },
    });
  },
);

/** The other side said yes — tell the sender and drop them into the chat. */
exports.onFriendRequestAnswered = onDocumentUpdated(
  "friendRequests/{requestId}",
  async (event) => {
    const before = event.data && event.data.before.data();
    const after = event.data && event.data.after.data();
    if (!before || !after) return;
    if (before.status === after.status || after.status !== "accepted") return;

    const accepter = await profile(after.to);
    const chatId = [after.from, after.to].sort().join("_");
    await pushTo(after.from, {
      title: "Request accepted",
      body: `${accepter.name} is now your friend. Say hi!`,
      tag: chatId,
      data: { type: "chat", chatId, friendUid: after.to },
    });
  },
);
