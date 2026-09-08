package com.example.gym

import android.service.notification.NotificationListenerService

/**
 * Exists only so the system will hand us active media sessions:
 * MediaSessionManager.getActiveSessions() requires a component that holds
 * notification-listener access. We never read notifications themselves.
 */
class NowPlayingListener : NotificationListenerService()
