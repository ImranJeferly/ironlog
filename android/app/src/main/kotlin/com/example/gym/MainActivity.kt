package com.example.gym

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.MediaMetadata
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.net.Uri
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val nowPlayingChannel = "ironlog/now_playing"
    private val pushChannelName = "ironlog/push"

    private var pushChannel: MethodChannel? = null

    /** Route from a tapped notification, held until Dart asks for it. */
    private var pendingRoute: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingRoute = intent?.getStringExtra(PushInbox.EXTRA_ROUTE)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = intent.getStringExtra(PushInbox.EXTRA_ROUTE) ?: return
        pendingRoute = route
        pushChannel?.invokeMethod("route", route)
    }

    override fun onResume() {
        super.onResume()
        PushInbox.foreground = true
    }

    override fun onPause() {
        PushInbox.foreground = false
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nowPlayingChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAccess" -> result.success(hasNotificationAccess())
                    "requestAccess" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("unavailable", e.message, null)
                        }
                    }
                    "current" -> result.success(currentTrack())
                    else -> result.notImplemented()
                }
            }

        pushChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pushChannelName)
        pushChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    PushInbox.ensureChannels(this)
                    KeepAliveJob.schedule(this)
                    FriendPushService.start(this)
                    result.success(null)
                }
                "stop" -> {
                    KeepAliveJob.cancel(this)
                    FriendPushService.stop(this)
                    result.success(null)
                }
                "setActiveChat" -> {
                    PushInbox.activeChatId = call.arguments as? String
                    result.success(null)
                }
                "dismissChat" -> {
                    (call.arguments as? String)?.let { PushInbox.dismissChat(this, it) }
                    result.success(null)
                }
                "pendingRoute" -> {
                    val route = pendingRoute
                    pendingRoute = null
                    result.success(route)
                }
                "isBatteryExempt" -> result.success(isBatteryExempt())
                "requestBatteryExemption" -> {
                    try {
                        startActivity(
                            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                .setData(Uri.parse("package:$packageName"))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("unavailable", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isBatteryExempt(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun hasNotificationAccess(): Boolean {
        val enabled = Settings.Secure.getString(
            contentResolver, "enabled_notification_listeners"
        ) ?: return false
        return enabled.contains(packageName)
    }

    /** Title / artist / app of the first *playing* media session, or null. */
    private fun currentTrack(): Map<String, Any?>? {
        if (!hasNotificationAccess()) return null
        return try {
            val manager =
                getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
            val component = ComponentName(this, NowPlayingListener::class.java)
            val sessions = manager.getActiveSessions(component)
            var best: Map<String, Any?>? = null
            for (controller in sessions) {
                val meta = controller.metadata ?: continue
                val title = meta.getString(MediaMetadata.METADATA_KEY_TITLE)
                    ?: meta.getString(MediaMetadata.METADATA_KEY_DISPLAY_TITLE)
                    ?: continue
                val playing =
                    controller.playbackState?.state == PlaybackState.STATE_PLAYING
                val track = mapOf(
                    "title" to title,
                    "artist" to (meta.getString(MediaMetadata.METADATA_KEY_ARTIST)
                        ?: meta.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST)),
                    "app" to controller.packageName,
                    "playing" to playing,
                )
                if (playing) return track
                if (best == null) best = track
            }
            best
        } catch (e: SecurityException) {
            null
        } catch (e: Exception) {
            null
        }
    }
}
