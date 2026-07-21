import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications.dart';
import '../../core/utils/haptics.dart';

class RestTimerState {
  const RestTimerState({
    this.total = Duration.zero,
    this.remaining = Duration.zero,
    this.running = false,
    this.exerciseName,
  });

  final Duration total;
  final Duration remaining;
  final bool running;
  final String? exerciseName;

  bool get isActive => running || remaining > Duration.zero;

  bool get isFinished => total > Duration.zero && remaining <= Duration.zero;

  /// 1 → just started, 0 → done. Drives the countdown ring/bar.
  double get progress {
    if (total.inSeconds == 0) return 0;
    return (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }
}

/// Counts down between sets and pings a notification when the rest is up.
class RestTimerController extends Notifier<RestTimerState> {
  Timer? _ticker;
  DateTime? _endsAt;

  @override
  RestTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const RestTimerState();
  }

  void start(Duration duration, {String? exerciseName}) {
    _ticker?.cancel();
    if (duration <= Duration.zero) {
      state = const RestTimerState();
      return;
    }

    // Wall-clock based so the countdown stays honest if the ticker is throttled
    // while the screen is off.
    _endsAt = DateTime.now().add(duration);
    state = RestTimerState(
      total: duration,
      remaining: duration,
      running: true,
      exerciseName: exerciseName,
    );

    // Schedule the alert up front so it fires even if the app is backgrounded
    // or the phone is locked during the rest — the foreground ticker below is
    // only for the in-app countdown UI.
    unawaited(
      Notifications.scheduleRestDone(_endsAt!, exerciseName: exerciseName),
    );

    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _tick() {
    final endsAt = _endsAt;
    if (endsAt == null) return;
    final remaining = endsAt.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _ticker?.cancel();
      _ticker = null;
      state = RestTimerState(
        total: state.total,
        remaining: Duration.zero,
        running: false,
        exerciseName: state.exerciseName,
      );
      // The notification was scheduled at start; only add the in-app haptic
      // here so a foreground finish still feels responsive.
      unawaited(Haptics.celebrate());
      return;
    }

    state = RestTimerState(
      total: state.total,
      remaining: remaining,
      running: true,
      exerciseName: state.exerciseName,
    );
  }

  void addSeconds(int seconds) {
    final endsAt = _endsAt;
    if (endsAt == null || !state.running) return;
    _endsAt = endsAt.add(Duration(seconds: seconds));
    state = RestTimerState(
      total: state.total + Duration(seconds: seconds),
      remaining: _endsAt!.difference(DateTime.now()),
      running: true,
      exerciseName: state.exerciseName,
    );
    // Push the scheduled alert back to the new end time.
    unawaited(
      Notifications.scheduleRestDone(
        _endsAt!,
        exerciseName: state.exerciseName,
      ),
    );
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    state = const RestTimerState();
    unawaited(Notifications.cancelRest());
  }
}

final restTimerProvider =
    NotifierProvider<RestTimerController, RestTimerState>(
      RestTimerController.new,
    );
