import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for the rest timer.
///
/// The "rest over" alert is **scheduled** (`zonedSchedule`) rather than fired
/// from a foreground ticker, so it still goes off when the phone is locked or
/// the app is backgrounded mid-rest — the normal gym case. Every call is
/// guarded so a device without notification support (or a denied permission)
/// never breaks logging.
abstract final class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _tzReady = false;

  static const _restChannelId = 'ironlog_rest';
  static const _restNotificationId = 1001;
  static const _nutritionChannelId = 'ironlog_nutrition';
  static const _nutritionNotificationId = 1002;

  /// Payload carried by the nightly nutrition nudge; the shell opens the
  /// Today card when it sees it.
  static const routeToday = 'today';

  /// Route requested by a tapped notification. The app shell listens and
  /// clears it once handled.
  static final pendingRoute = ValueNotifier<String?>(null);

  static Future<void> init() async {
    if (_ready) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) pendingRoute.value = response.payload;
        },
      );
      // Tapping a notification while the app was dead launches it — pick that
      // route up too.
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        pendingRoute.value = launch!.notificationResponse?.payload;
      }
      await _initTimezone();
      _ready = true;
    } on Object catch (e) {
      debugPrint('IronLog: notifications unavailable ($e)');
    }
  }

  static NotificationDetails get _nutritionDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _nutritionChannelId,
      'Daily log reminder',
      channelDescription: 'Evening nudge to log protein and calories.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Keeps the 21:00 "log protein + kcal" reminder in step with the setting:
  /// (re)schedules a daily repeat when [enabled], cancels it otherwise.
  static Future<void> syncNutritionReminder({required bool enabled}) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _nutritionNotificationId);
      if (!enabled) return;
      if (!_tzReady) await _initTimezone();

      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21);
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        id: _nutritionNotificationId,
        title: 'Log protein + kcal',
        body: 'Thirty seconds now keeps the trend honest.',
        scheduledDate: at,
        notificationDetails: _nutritionDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: routeToday,
      );
    } on Object catch (e) {
      debugPrint('IronLog: could not schedule nutrition reminder ($e)');
    }
  }

  static Future<void> _initTimezone() async {
    if (_tzReady) return;
    try {
      tz_data.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      _tzReady = true;
    } on Object catch (e) {
      // Fall back to UTC so scheduling still works, just not local-exact.
      debugPrint('IronLog: could not resolve local timezone ($e)');
      _tzReady = false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      // Exact alarms make the rest alert land on the second instead of
      // "sometime within the next 15 minutes" — essential for a rest timer.
      if (android != null &&
          !(await android.canScheduleExactNotifications() ?? false)) {
        await android.requestExactAlarmsPermission();
      }
    } on Object catch (e) {
      debugPrint('IronLog: notification permission request failed ($e)');
    }
  }

  static NotificationDetails get _restDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _restChannelId,
      'Rest timer',
      channelDescription: 'Fires when your rest between sets is up.',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: DarwinNotificationDetails(presentSound: true),
  );

  /// Schedules the "rest over" alert for [when]. Reliable across
  /// backgrounding/lock. Re-scheduling replaces any pending alert.
  static Future<void> scheduleRestDone(
    DateTime when, {
    String? exerciseName,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    if (!_tzReady) await _initTimezone();

    try {
      await _plugin.cancel(id: _restNotificationId);
      final scheduled = tz.TZDateTime.from(when, tz.local);
      // A time already in the past can't be scheduled; fire immediately.
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
        await restFinished(exerciseName: exerciseName);
        return;
      }
      final body =
          exerciseName == null ? 'Next set — go.' : 'Next set: $exerciseName';
      try {
        // Exact first: a rest timer that fires minutes late is useless.
        await _plugin.zonedSchedule(
          id: _restNotificationId,
          title: 'Rest over',
          body: body,
          scheduledDate: scheduled,
          notificationDetails: _restDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } on Object {
        // Exact alarms not permitted on this device — inexact still beats
        // nothing when the app is backgrounded.
        await _plugin.zonedSchedule(
          id: _restNotificationId,
          title: 'Rest over',
          body: body,
          scheduledDate: scheduled,
          notificationDetails: _restDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } on Object catch (e) {
      debugPrint('IronLog: could not schedule rest notification ($e)');
    }
  }

  /// Fires the alert immediately — used as the fallback when scheduling isn't
  /// available.
  static Future<void> restFinished({String? exerciseName}) async {
    if (!_ready) await init();
    try {
      await _plugin.show(
        id: _restNotificationId,
        title: 'Rest over',
        body: exerciseName == null ? 'Next set — go.' : 'Next set: $exerciseName',
        notificationDetails: _restDetails,
      );
    } on Object catch (e) {
      debugPrint('IronLog: could not show rest notification ($e)');
    }
  }

  static Future<void> cancelRest() async {
    try {
      await _plugin.cancel(id: _restNotificationId);
    } on Object {
      // Nothing to cancel.
    }
  }
}
