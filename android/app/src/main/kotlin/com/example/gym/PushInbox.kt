package com.example.gym

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query

/**
 * Turns Firestore documents into system notifications. Shared by the
 * long-running listener service and the periodic catch-up job, so both paths
 * dedupe through the same SharedPreferences stamps.
 *
 * There is no push server: the recipient's own phone watches the chats it is
 * a member of and notifies itself. That is what keeps the whole feature on the
 * free Firebase plan.
 */
class PushInbox(private val context: Context) {

    companion object {
        const val CHANNEL_SOCIAL = "ironlog_social"
        const val CHANNEL_LISTENER = "ironlog_listener"
        const val EXTRA_ROUTE = "route"
        const val EXTRA_CHAT_ID = "chatId"
        const val EXTRA_FRIEND_UID = "friendUid"
        const val ACTION_REPLY = "com.example.gym.action.REPLY"
        const val KEY_REPLY = "reply"
        const val TAG_FRIENDS = "friends"
        private const val PREFS = "ironlog_push"
        private const val ONE_DAY_MS = 24L * 60 * 60 * 1000

        /** Chat currently open in the app; its pushes are swallowed. */
        @Volatile var activeChatId: String? = null

        /** True while MainActivity is resumed. */
        @Volatile var foreground = false

        fun ensureChannels(context: Context) {
            val manager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_SOCIAL,
                    "Friends",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "Messages, PRs and session updates from your friends."
                }
            )
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_LISTENER,
                    "Background listener",
                    NotificationManager.IMPORTANCE_MIN,
                ).apply {
                    description = "Keeps friend notifications working while IronLog is closed."
                    setShowBadge(false)
                }
            )
        }

        fun notificationId(key: String): Int = 4000 + (key.hashCode() and 0xffff)

        fun chatIdFor(a: String, b: String): String =
            if (a < b) "${a}_$b" else "${b}_$a"

        fun dismissChat(context: Context, chatId: String) {
            NotificationManagerCompat.from(context).cancel(chatId, notificationId(chatId))
        }
    }

    private val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private val db: FirebaseFirestore get() = FirebaseFirestore.getInstance()

    // ------------------------------------------------------------------ chats

    /** A chat document changed: notify if the last message is from the friend and unseen. */
    fun handleChat(me: String, doc: DocumentSnapshot) {
        val lastFrom = doc.getString("lastFrom") ?: return
        if (lastFrom == me) return
        val lastAt = doc.getTimestamp("lastAt") ?: return
        val unread = (doc.get("unread") as? Map<*, *>)?.get(me) as? Number
        if (unread == null || unread.toLong() <= 0L) return

        val stamp = lastAt.toDate().time
        val key = "chat_${doc.id}"
        if (prefs.getLong(key, 0L) >= stamp) return
        prefs.edit().putLong(key, stamp).apply()

        markDelivered(doc.id, lastFrom)
        if (foreground && activeChatId == doc.id) return

        val text = doc.getString("lastText") ?: "New message"
        withName(lastFrom) { name -> notifyMessage(doc.id, lastFrom, name, text, stamp) }
    }

    /** Writes the "delivered" tick for the friend's latest messages. */
    private fun markDelivered(chatId: String, friend: String) {
        db.collection("chats").document(chatId).collection("messages")
            .orderBy("sentAt", Query.Direction.DESCENDING)
            .limit(15)
            .get()
            .addOnSuccessListener { snap ->
                for (m in snap.documents) {
                    if (m.getString("from") != friend) continue
                    if (m.get("deliveredAt") != null) continue
                    if (m.getString("kind") == "system") continue
                    m.reference.update("deliveredAt", FieldValue.serverTimestamp())
                }
            }
    }

    private fun notifyMessage(
        chatId: String,
        friendUid: String,
        friendName: String,
        text: String,
        stamp: Long,
    ) {
        val route = "chat:$chatId:$friendUid"
        val friend = Person.Builder().setName(friendName).setKey(friendUid).build()
        val me = Person.Builder().setName("You").build()
        val style = NotificationCompat.MessagingStyle(me)
            .setConversationTitle(friendName)
            .addMessage(text, stamp, friend)

        val remoteInput = RemoteInput.Builder(KEY_REPLY).setLabel("Reply").build()
        val replyIntent = Intent(context, PushReceiver::class.java)
            .setAction(ACTION_REPLY)
            .putExtra(EXTRA_CHAT_ID, chatId)
            .putExtra(EXTRA_FRIEND_UID, friendUid)
        var replyFlags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            replyFlags = replyFlags or PendingIntent.FLAG_MUTABLE
        }
        val replyPending = PendingIntent.getBroadcast(
            context, notificationId(chatId), replyIntent, replyFlags
        )
        val reply = NotificationCompat.Action.Builder(
            R.drawable.ic_stat_ironlog, "Reply", replyPending
        ).addRemoteInput(remoteInput).setAllowGeneratedReplies(true).build()

        val notification = NotificationCompat.Builder(context, CHANNEL_SOCIAL)
            .setSmallIcon(R.drawable.ic_stat_ironlog)
            .setColor(0xFFFF1F2F.toInt())
            .setStyle(style)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setWhen(stamp)
            .setShowWhen(true)
            .setContentIntent(launchIntent(route))
            .addAction(reply)
            .build()
        post(chatId, notificationId(chatId), notification)
    }

    // --------------------------------------------------------------- requests

    fun handleIncomingRequest(me: String, doc: DocumentSnapshot) {
        if (doc.getString("to") != me) return
        if (doc.getString("status") != "pending") return
        val key = "req_${doc.id}"
        if (prefs.getBoolean(key, false)) return
        prefs.edit().putBoolean(key, true).apply()

        val name = doc.getString("fromName") ?: "Someone"
        val handle = doc.getString("fromHandle")
        val body = if (handle == null) "$name wants to train with you" else
            "$name (@$handle) wants to train with you"
        notifySimple(TAG_FRIENDS, "Friend request", body, "friends")
    }

    fun handleAcceptedRequest(me: String, doc: DocumentSnapshot) {
        if (doc.getString("from") != me) return
        if (doc.getString("status") != "accepted") return
        val acceptedAt = doc.getTimestamp("acceptedAt")?.toDate()?.time ?: return
        // Old acceptances from before this build should not fire on first run.
        if (System.currentTimeMillis() - acceptedAt > ONE_DAY_MS) return
        val key = "acc_${doc.id}"
        if (prefs.getBoolean(key, false)) return
        prefs.edit().putBoolean(key, true).apply()

        val other = doc.getString("to") ?: return
        withName(other) { name ->
            notifySimple(
                TAG_FRIENDS,
                "You're friends now",
                "$name accepted your request — say hi.",
                "chat:${chatIdFor(me, other)}:$other",
            )
        }
    }

    // ---------------------------------------------------------------- helpers

    private fun withName(uid: String, block: (String) -> Unit) {
        val cached = prefs.getString("name_$uid", null)
        if (cached != null) {
            block(cached)
            return
        }
        db.collection("users").document(uid).get()
            .addOnSuccessListener { d ->
                val name = d.getString("displayName")?.takeIf { it.isNotBlank() } ?: "Friend"
                prefs.edit().putString("name_$uid", name).apply()
                block(name)
            }
            .addOnFailureListener { block("Friend") }
    }

    /** Invalidate the cached display name (profile edits). */
    fun forgetName(uid: String) {
        prefs.edit().remove("name_$uid").apply()
    }

    private fun notifySimple(tag: String, title: String, body: String, route: String) {
        val notification = NotificationCompat.Builder(context, CHANNEL_SOCIAL)
            .setSmallIcon(R.drawable.ic_stat_ironlog)
            .setColor(0xFFFF1F2F.toInt())
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setCategory(NotificationCompat.CATEGORY_SOCIAL)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(launchIntent(route))
            .build()
        post(tag, notificationId(route), notification)
    }

    private fun launchIntent(route: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra(EXTRA_ROUTE, route)
        return PendingIntent.getActivity(
            context,
            route.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun post(tag: String, id: Int, notification: android.app.Notification) {
        try {
            NotificationManagerCompat.from(context).notify(tag, id, notification)
        } catch (e: SecurityException) {
            // POST_NOTIFICATIONS not granted yet — the app asks on first run.
        }
    }
}
