package com.example.gym

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.MediaMetadata
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The only native surface left is "now playing": reading the active media
 * session needs a notification-listener component, which Flutter can't do.
 * Friend notifications arrive over FCM (firebase_messaging) — no native code.
 */
class MainActivity : FlutterActivity() {
    private val nowPlayingChannel = "ironlog/now_playing"

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
