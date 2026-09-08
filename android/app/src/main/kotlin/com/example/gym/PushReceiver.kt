package com.example.gym

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.RemoteInput
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore

/**
 * Two jobs: restart the listener after a reboot / app update, and handle the
 * inline "Reply" typed into a message notification.
 */
class PushReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                KeepAliveJob.schedule(context)
                FriendPushService.start(context)
            }
            PushInbox.ACTION_REPLY -> reply(context, intent)
        }
    }

    private fun reply(context: Context, intent: Intent) {
        val text = RemoteInput.getResultsFromIntent(intent)
            ?.getCharSequence(PushInbox.KEY_REPLY)?.toString()?.trim()
        val chatId = intent.getStringExtra(PushInbox.EXTRA_CHAT_ID)
        val friend = intent.getStringExtra(PushInbox.EXTRA_FRIEND_UID)
        val me = FirebaseAuth.getInstance().currentUser?.uid
        if (text.isNullOrEmpty() || chatId == null || friend == null || me == null) {
            if (chatId != null) PushInbox.dismissChat(context, chatId)
            return
        }

        // Same shape the app writes (SocialRepository.sendText + _touchChat).
        // Firestore queues this locally if offline and sends when it can.
        val db = FirebaseFirestore.getInstance()
        val chat = db.collection("chats").document(chatId)
        val batch = db.batch()
        batch.set(
            chat.collection("messages").document(),
            hashMapOf(
                "from" to me,
                "kind" to "text",
                "text" to text,
                "sentAt" to FieldValue.serverTimestamp(),
            ),
        )
        batch.update(
            chat,
            mapOf(
                "lastText" to text,
                "lastFrom" to me,
                "lastAt" to FieldValue.serverTimestamp(),
                "unread.$friend" to FieldValue.increment(1L),
                "unread.$me" to 0L,
            ),
        )
        // Keep the process alive until the write is at least queued durably;
        // a receiver that returns immediately can be killed before Firestore
        // persists it when no service is running.
        val pending = goAsync()
        batch.commit().addOnCompleteListener { pending.finish() }
        // Android requires the notification to be updated or removed after a
        // RemoteInput reply, otherwise the spinner never stops.
        PushInbox.dismissChat(context, chatId)
    }
}
