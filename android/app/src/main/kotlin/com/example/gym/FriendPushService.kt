package com.example.gym

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration

/**
 * Foreground service that keeps Firestore listeners open on this user's chats
 * and friend requests, so a message lands as a system notification even when
 * the Flutter side is not running. Replaces a push server on the free plan.
 *
 * Runs only for real (non-anonymous) accounts; stops itself otherwise.
 */
class FriendPushService : Service() {

    companion object {
        private const val LISTENER_NOTIFICATION_ID = 3000

        @Volatile var running = false

        fun start(context: Context) {
            val user = FirebaseAuth.getInstance().currentUser
            if (user == null || user.isAnonymous) return
            val intent = Intent(context, FriendPushService::class.java)
            try {
                context.startForegroundService(intent)
            } catch (e: Exception) {
                // Background-start restriction (Android 12+). Once the user
                // grants the battery exemption this is allowed from the
                // keep-alive job too; until then the job's own catch-up reads
                // still deliver notifications, just up to 15 minutes late.
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, FriendPushService::class.java))
        }
    }

    private lateinit var inbox: PushInbox
    private var chatsReg: ListenerRegistration? = null
    private var incomingReg: ListenerRegistration? = null
    private var acceptedReg: ListenerRegistration? = null
    private val authListener = FirebaseAuth.AuthStateListener { auth -> attach(auth.currentUser) }

    override fun onCreate() {
        super.onCreate()
        inbox = PushInbox(this)
        PushInbox.ensureChannels(this)
        try {
            startForegroundCompat()
        } catch (e: Exception) {
            // A sticky restart from the background without the battery
            // exemption isn't allowed to go foreground (Android 12+). Bail
            // quietly instead of crash-looping; the keep-alive job catches up.
            stopSelf()
            return
        }
        FirebaseAuth.getInstance().addAuthStateListener(authListener)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        running = true
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        FirebaseAuth.getInstance().removeAuthStateListener(authListener)
        detach()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startForegroundCompat() {
        val notification = NotificationCompat.Builder(this, PushInbox.CHANNEL_LISTENER)
            .setSmallIcon(R.drawable.ic_stat_ironlog)
            .setContentTitle("Listening for friends")
            .setContentText("Messages and PRs arrive as notifications.")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                LISTENER_NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(LISTENER_NOTIFICATION_ID, notification)
        }
    }

    private fun attach(user: FirebaseUser?) {
        detach()
        if (user == null || user.isAnonymous) {
            stopSelf()
            return
        }
        val me = user.uid
        val db = FirebaseFirestore.getInstance()

        chatsReg = db.collection("chats")
            .whereArrayContains("members", me)
            .addSnapshotListener { snap, _ ->
                if (snap == null) return@addSnapshotListener
                for (change in snap.documentChanges) {
                    if (change.type == DocumentChange.Type.REMOVED) continue
                    inbox.handleChat(me, change.document)
                }
            }

        incomingReg = db.collection("friendRequests")
            .whereEqualTo("to", me)
            .whereEqualTo("status", "pending")
            .addSnapshotListener { snap, _ ->
                if (snap == null) return@addSnapshotListener
                for (change in snap.documentChanges) {
                    if (change.type == DocumentChange.Type.REMOVED) continue
                    inbox.handleIncomingRequest(me, change.document)
                }
            }

        acceptedReg = db.collection("friendRequests")
            .whereEqualTo("from", me)
            .whereEqualTo("status", "accepted")
            .addSnapshotListener { snap, _ ->
                if (snap == null) return@addSnapshotListener
                for (change in snap.documentChanges) {
                    if (change.type == DocumentChange.Type.REMOVED) continue
                    inbox.handleAcceptedRequest(me, change.document)
                }
            }
    }

    private fun detach() {
        chatsReg?.remove()
        incomingReg?.remove()
        acceptedReg?.remove()
        chatsReg = null
        incomingReg = null
        acceptedReg = null
    }
}
