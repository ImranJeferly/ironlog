import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/enums.dart';
import '../../domain/program.dart';
import '../../domain/session_view.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';
import '../../widgets/pr_celebration.dart';
import 'exercise_picker_sheet.dart';
import 'rest_timer.dart';
import 'session_summary_screen.dart';
import 'set_logger_sheet.dart';

/// The workout runs as a guided, one-exercise-at-a-time flow: swipe (or get
/// auto-advanced) through exercise pages, one giant Log button for whatever
/// is in front of you, and a wrap-up page at the end. No wall of cards.
class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  static Future<void> open(BuildContext context, String sessionId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActiveSessionScreen(sessionId: sessionId),
      ),
    );
  }

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final _pager = PageController();
  int _page = 0;

  // ---- idle watchdog: auto-end an abandoned session ----
  static const _idleAfter = Duration(minutes: 45);
  static const _answerWithin = Duration(minutes: 5);
  Timer? _idleTicker;
  Timer? _autoEndTimer;
  bool _promptOpen = false;
  bool _warnedOvertime = false;

  /// When the lifter last confirmed "still going", so the idle window restarts
  /// from then instead of from the last logged set.
  DateTime? _idleAcknowledgedAt;

  @override
  void initState() {
    super.initState();
    _idleTicker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkIdle(),
    );
  }

  @override
  void dispose() {
    _idleTicker?.cancel();
    _autoEndTimer?.cancel();
    _pager.dispose();
    super.dispose();
  }

  void _checkIdle() {
    if (!mounted) return;
    final view = ref.read(sessionViewProvider(widget.sessionId)).value;
    if (view == null || view.isComplete) return;

    // One-time nudge once the session runs past the 90-minute warning.
    if (!_warnedOvertime &&
        DateTime.now().difference(view.session.startedAt) >=
            SessionTargets.warn) {
      _warnedOvertime = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Over ${SessionTargets.warn.inMinutes} min — time to wrap up.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }

    if (_promptOpen) return;
    var since = view.lastActivityAt;
    final acked = _idleAcknowledgedAt;
    if (acked != null && acked.isAfter(since)) since = acked;
    if (DateTime.now().difference(since) < _idleAfter) return;
    _promptStillTraining(view);
  }

  /// "Still training?" after 45 idle minutes. No answer within 5 minutes ends
  /// the session at its last logged set, so a forgotten app can't record a
  /// six-hour workout.
  Future<void> _promptStillTraining(SessionView view) async {
    _promptOpen = true;
    _autoEndTimer = Timer(_answerWithin, () {
      if (!mounted || !_promptOpen) return;
      Navigator.of(context, rootNavigator: true).pop(false);
    });

    final stillGoing = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Still training?'),
        content: Text(
          'No set logged for ${_idleAfter.inMinutes} minutes. If you\'re '
          'done, the session ends at your last set.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'End session',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Still going',
              style: TextStyle(
                color: AppColors.volt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    _autoEndTimer?.cancel();
    _promptOpen = false;
    if (!mounted) return;
    if (stillGoing == true) {
      _idleAcknowledgedAt = DateTime.now();
      return;
    }
    await _finish(view, endedAt: view.lastActivityAt);
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(sessionViewProvider(widget.sessionId)).value;
    final rest = ref.watch(restTimerProvider);

    if (view == null) {
      // The session was discarded from under us.
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: EmptyState(
            title: 'Session not found',
            message: 'It may have been discarded.',
          ),
        ),
      );
    }

    final pageCount = view.exercises.length + 1; // +1 for the wrap-up page
    final page = _page.clamp(0, pageCount - 1);
    final onWrapUp = page == view.exercises.length;
    final current = onWrapUp ? null : view.exercises[page];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmLeave(view);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(view: view, onClose: () => _confirmLeave(view)),
              if (rest.isActive) _RestBar(state: rest),
              _ExerciseTrack(
                view: view,
                current: page,
                onTap: _goTo,
              ),
              Expanded(
                child: PageView(
                  controller: _pager,
                  onPageChanged: (i) {
                    Haptics.tick();
                    setState(() => _page = i);
                  },
                  children: [
                    for (final exercise in view.exercises)
                      _ExercisePage(
                        exercise: exercise,
                        onLog: () => _logSet(exercise),
                        onEditSet: (setId, weight, reps, rpe, note) =>
                            _editSet(exercise, setId, weight, reps, rpe, note),
                        onOptions: () => _showOptions(exercise),
                      ),
                    _WrapUpPage(
                      sessionId: widget.sessionId,
                      view: view,
                      cardioLabel: _cardioLabel(view),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildBottomBar(view, current, onWrapUp),
          ),
        ),
      ),
    );
  }

  /// One primary action at all times, matched to the page you're looking at.
  Widget _buildBottomBar(
    SessionView view,
    SessionExerciseView? current,
    bool onWrapUp,
  ) {
    if (onWrapUp || current == null) {
      return VoltButton(
        label: 'Finish workout',
        icon: Icons.check_rounded,
        onPressed: () => _finish(view),
      );
    }

    if (current.isComplete) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: VoltButton(
              label: 'Next exercise',
              icon: Icons.arrow_forward_rounded,
              onPressed: _advance,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: GhostButton(
              label: 'Finish',
              expanded: true,
              height: 56,
              onPressed: () => _finish(view),
            ),
          ),
        ],
      );
    }

    final setNo = current.sets.length + 1;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: VoltButton(
            label: 'Log set $setNo of ${current.targetSets}',
            icon: Icons.add,
            onPressed: () => _logSet(current),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: GhostButton(
            label: 'Finish',
            expanded: true,
            height: 56,
            onPressed: () => _finish(view),
          ),
        ),
      ],
    );
  }

  void _goTo(int page) {
    if (!_pager.hasClients) return;
    _pager.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// Jumps to the next unfinished exercise, or the wrap-up page if there is
  /// none left.
  void _advance() {
    final view = ref.read(sessionViewProvider(widget.sessionId)).value;
    if (view == null) return;
    final list = view.exercises;
    for (var i = 1; i <= list.length; i++) {
      final j = (_page + i) % list.length;
      if (!list[j].isComplete) {
        _goTo(j);
        return;
      }
    }
    _goTo(list.length);
  }

  String _cardioLabel(SessionView view) {
    final templates = ref.read(templatesProvider).value ?? const [];
    for (final t in templates) {
      if (t.id == view.session.templateId && t.cardioLabel != null) {
        return t.cardioLabel!;
      }
    }
    return 'Cardio';
  }

  Future<void> _logSet(SessionExerciseView exercise) async {
    final unit = ref.read(unitProvider);
    final result = await SetLoggerSheet.show(
      context,
      exercise: exercise,
      unit: unit,
    );
    if (result == null || !mounted) return;

    final setNo = exercise.sets.length + 1;
    final completesExercise = setNo >= exercise.targetSets;

    final LogSetResult logged;
    try {
      logged = await ref
          .read(workoutRepositoryProvider)
          .logSet(
            sessionId: widget.sessionId,
            exerciseId: exercise.exercise.id,
            weightKg: result.weightKg,
            reps: result.reps,
            rpe: result.rpe,
            note: result.note,
          );
    } on PhantomSetException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return;
    }

    await Haptics.impact();

    // One-tap undo for mis-logged sets — deleting also retracts any PR the
    // set produced.
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Set $setNo logged'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.volt,
            onPressed: () =>
                ref.read(workoutRepositoryProvider).deleteSet(logged.setId),
          ),
        ),
      );
    }

    final settings = ref.read(settingsProvider);
    if (settings.restTimerEnabled && !completesExercise) {
      ref
          .read(restTimerProvider.notifier)
          .start(
            Duration(seconds: settings.restForRole(exercise.role)),
            exerciseName: exercise.name,
          );
    }

    if (logged.isPr && mounted) {
      await PrCelebration.show(
        context,
        pr: logged.headline!,
        exerciseName: exercise.name,
        unit: unit,
      );
    }

    // Exercise done — carry the lifter straight to the next one.
    if (completesExercise && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (mounted) _advance();
    }
  }

  Future<void> _editSet(
    SessionExerciseView exercise,
    String setId,
    double weight,
    int reps,
    int? rpe,
    String? note,
  ) async {
    final unit = ref.read(unitProvider);
    final result = await SetLoggerSheet.show(
      context,
      exercise: exercise,
      unit: unit,
      initialWeightKg: weight,
      initialReps: reps,
      initialRpe: rpe,
      initialNote: note,
      isEdit: true,
    );
    if (result == null) return;

    if (result.delete) {
      await ref.read(workoutRepositoryProvider).deleteSet(setId);
      return;
    }
    await ref
        .read(workoutRepositoryProvider)
        .updateSet(
          setId: setId,
          weightKg: result.weightKg,
          reps: result.reps,
          rpe: result.rpe,
          note: result.note,
        );
  }

  /// Add/remove-set and remove-exercise live behind one calm menu.
  void _showOptions(SessionExerciseView exercise) {
    final repo = ref.read(workoutRepositoryProvider);
    // Can't drop below what's already been logged (tap a logged set to edit
    // or delete it), and never below one set.
    final canRemoveSet =
        exercise.targetSets > 1 && exercise.targetSets > exercise.sets.length;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _OptionRow(
              icon: Icons.playlist_add,
              label: 'Add a set',
              onTap: () {
                repo.setTargetSets(exercise.link.id, exercise.targetSets + 1);
                Navigator.of(sheet).pop();
              },
            ),
            _OptionRow(
              icon: Icons.playlist_remove,
              label: 'Remove a set',
              enabled: canRemoveSet,
              onTap: () {
                repo.setTargetSets(exercise.link.id, exercise.targetSets - 1);
                Navigator.of(sheet).pop();
              },
            ),
            _OptionRow(
              icon: Icons.delete_outline,
              label: 'Remove exercise from session',
              color: AppColors.danger,
              onTap: () {
                repo.removeExerciseFromSession(exercise.link.id);
                Navigator.of(sheet).pop();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  /// Saves the session. A session with no working sets can never be saved —
  /// the only exit is Discard. [endedAt] is passed by the idle watchdog so an
  /// auto-ended session closes at its last set, not at "now".
  Future<void> _finish(SessionView view, {DateTime? endedAt}) async {
    if (view.totalSets == 0) {
      final discard = await _confirm(
        title: 'Nothing logged',
        message: 'A session with no working sets can\'t be saved. '
            'Discard it?',
        confirmLabel: 'Discard',
        danger: true,
      );
      if (discard != true) return;
      await ref.read(workoutRepositoryProvider).discardSession(widget.sessionId);
      ref.read(restTimerProvider.notifier).stop();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final session = await ref
        .read(workoutRepositoryProvider)
        .finishSession(widget.sessionId, endedAt: endedAt);
    ref.read(restTimerProvider.notifier).stop();
    ref.read(analyticsRevisionProvider.notifier).bump();
    unawaited(ref.read(syncControllerProvider.notifier).sync());
    await Haptics.celebrate();

    if (!mounted || session == null) return;
    await SessionSummaryScreen.openReplacing(context, session.id);
  }

  Future<void> _confirmLeave(SessionView view) async {
    if (view.totalSets == 0) {
      final discard = await _confirm(
        title: 'Leave session?',
        message: 'Nothing has been logged — this session will be discarded.',
        confirmLabel: 'Discard',
        danger: true,
      );
      if (discard != true) return;
      await ref.read(workoutRepositoryProvider).discardSession(widget.sessionId);
      ref.read(restTimerProvider.notifier).stop();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Work is already saved locally, so backing out just hides the screen —
    // the session stays resumable from Home.
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: danger ? AppColors.danger : AppColors.volt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.view, required this.onClose});

  final SessionView view;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconPill(icon: Icons.keyboard_arrow_down, onTap: onClose),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
                _ElapsedText(startedAt: view.session.startedAt),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${view.totalSets}',
                      style: AppText.numeric(size: 20),
                    ),
                    TextSpan(
                      text: '/${view.targetSetTotal}',
                      style: AppText.numeric(
                        size: 13,
                        color: AppColors.textTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Text('SETS', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Story-style progress track: one segment per exercise (plus the finish
/// flag). Filled = done, bright ring = where you are. Tap to jump.
class _ExerciseTrack extends StatelessWidget {
  const _ExerciseTrack({
    required this.view,
    required this.current,
    required this.onTap,
  });

  final SessionView view;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final count = view.exercises.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 6),
      child: Row(
        children: [
          for (var i = 0; i <= count; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              flex: i == count ? 1 : 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Haptics.tick();
                  onTap(i);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 6,
                    decoration: BoxDecoration(
                      color: _colorFor(i),
                      borderRadius: BorderRadius.circular(999),
                      border: i == current
                          ? Border.all(color: AppColors.accent, width: 1)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorFor(int i) {
    final isCurrent = i == current;
    if (i == view.exercises.length) {
      // The finish segment.
      return isCurrent ? AppColors.voltDim : AppColors.cardHigh;
    }
    if (view.exercises[i].isComplete) return AppColors.volt;
    if (isCurrent) return AppColors.voltDim;
    return AppColors.cardHigh;
  }
}

/// Ticks the session clock once a second without rebuilding the whole screen.
class _ElapsedText extends StatefulWidget {
  const _ElapsedText({required this.startedAt});

  final DateTime startedAt;

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    // Session target is 80 min; the colour turns before it's a problem.
    final over = elapsed >= SessionTargets.warn;
    final near = elapsed >= SessionTargets.target;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: over
                ? AppColors.danger
                : (near ? AppColors.warning : AppColors.accent),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${Fmt.duration(elapsed)} / ${SessionTargets.target.inMinutes} MIN',
          style: AppText.numeric(
            size: 12.5,
            letterSpacing: 0,
            color: over
                ? AppColors.danger
                : (near ? AppColors.warning : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Countdown strip that appears between sets.
class _RestBar extends ConsumerWidget {
  const _RestBar({required this.state});

  final RestTimerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final done = state.isFinished;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: done ? AppColors.voltDim : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.cardSmall),
        border: Border.all(
          color: done ? AppColors.accent : AppColors.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.notifications_active : Icons.timer_outlined,
            size: 18,
            color: done ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            done ? 'Rest over — go' : Fmt.clock(state.remaining),
            style: done
                ? AppText.display(size: 17, color: AppColors.accent)
                : AppText.numeric(size: 18, letterSpacing: 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SegmentBar(
              value: state.progress,
              segments: 14,
              height: 8,
              color: done ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          if (!done)
            GestureDetector(
              onTap: () =>
                  ref.read(restTimerProvider.notifier).addSeconds(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent),
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                child: Text(
                  '+30s',
                  style: AppText.display(size: 13, color: AppColors.accent),
                ),
              ),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => ref.read(restTimerProvider.notifier).stop(),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

typedef EditSetCallback =
    void Function(
      String setId,
      double weight,
      int reps,
      int? rpe,
      String? note,
    );

/// One exercise, full screen: big name, its sets, nothing else competing.
class _ExercisePage extends ConsumerWidget {
  const _ExercisePage({
    required this.exercise,
    required this.onLog,
    required this.onEditSet,
    required this.onOptions,
  });

  final SessionExerciseView exercise;
  final VoidCallback onLog;
  final EditSetCallback onEditSet;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unit = ref.watch(unitProvider);
    final done = exercise.isComplete;
    final stalled =
        ref.watch(stalledExercisesProvider).value?.contains(
          exercise.exercise.id,
        ) ??
        false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              AppColors.muscleColors[exercise
                                  .muscleGroup
                                  .key] ??
                              AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${exercise.schemeLabel} · ${exercise.muscleGroup.label}'
                          '${exercise.exercise.isUnilateral ? ' · per side' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (stalled && !done) ...[
              const VoltBadge('STALLED', color: AppColors.warning),
              const SizedBox(width: 6),
            ],
            if (done)
              const Icon(Icons.check_circle, size: 22, color: AppColors.volt)
            else if (exercise.increaseFlagged)
              const VoltBadge('↑ WEIGHT', filled: true)
            else if (exercise.suggestedWeightKg != null)
              VoltBadge(
                Fmt.weight(exercise.suggestedWeightKg!, unit),
                color: AppColors.textSecondary,
              ),
            const SizedBox(width: 8),
            IconPill(
              icon: Icons.more_horiz,
              tooltip: 'Exercise options',
              onTap: onOptions,
            ),
          ],
        ),
        if (exercise.exercise.notes != null) ...[
          const SizedBox(height: 6),
          Text(
            exercise.exercise.notes!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        for (var i = 0; i < exercise.targetSets; i++)
          _SetRow(
            index: i,
            exercise: exercise,
            unit: unit,
            onEdit: onEditSet,
            onLog: onLog,
          ),

        if (done) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'All sets done — swipe on or hit Next.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One prescribed set: either the logged values, or the ghost of last session.
class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.exercise,
    required this.unit,
    required this.onEdit,
    required this.onLog,
  });

  final int index;
  final SessionExerciseView exercise;
  final WeightUnit unit;
  final EditSetCallback onEdit;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logged = index < exercise.sets.length ? exercise.sets[index] : null;
    final ghost = exercise.ghostForSet(index + 1);
    final isNext = logged == null && index == exercise.sets.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: logged != null
          ? () => onEdit(
              logged.id,
              logged.weightKg,
              logged.reps,
              logged.rpe,
              logged.note,
            )
          : (isNext ? onLog : null),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: logged != null
              ? AppColors.cardHigh
              : (isNext ? AppColors.card : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(
            color: isNext
                ? AppColors.accent
                : (logged != null ? AppColors.border : AppColors.border),
            width: isNext ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            IndexTag(
              index + 1,
              size: 26,
              filled: logged != null,
              color: logged != null
                  ? AppColors.accent
                  : (isNext ? AppColors.textPrimary : AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: logged != null
                  ? Row(
                      children: [
                        Text(
                          Fmt.setSummary(logged.weightKg, logged.reps, unit),
                          style: AppText.numeric(size: 18, letterSpacing: 0),
                        ),
                        if (logged.rpe != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'RPE ${logged.rpe}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                        if (logged.isPr) ...[
                          const SizedBox(width: 8),
                          const VoltBadge('PR', icon: Icons.bolt),
                        ],
                      ],
                    )
                  : Text(
                      ghost == null
                          ? '— × ${exercise.link.repRangeMin}'
                          : '${Fmt.weight(ghost.weightKg, unit)} × ${ghost.reps}',
                      style: AppText.numeric(
                        size: 17,
                        letterSpacing: 0,
                        color: isNext
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
            ),
            if (logged == null && ghost != null)
              Text(
                'last time',
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
              ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Text(
                'tap to log',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                  fontSize: 12,
                ),
              ),
            ],
            if (logged != null)
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}

/// Final page: cardio & sauna ticks, extra exercises, session notes.
class _WrapUpPage extends ConsumerWidget {
  const _WrapUpPage({
    required this.sessionId,
    required this.view,
    required this.cardioLabel,
  });

  final String sessionId;
  final SessionView view;
  final String cardioLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final doneCount = view.exercises.where((e) => e.isComplete).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        Text('Finish up', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(
          '$doneCount of ${view.exercises.length} exercises done · '
          '${view.totalSets} sets logged',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        const IronRule(),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: VoltCheck(
                value: view.session.cardioDone,
                icon: Icons.favorite_outline,
                label: cardioLabel,
                onChanged: (v) => ref
                    .read(workoutRepositoryProvider)
                    .setCardioDone(sessionId, v),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: VoltCheck(
                value: view.session.saunaDone,
                icon: Icons.hot_tub_outlined,
                label: 'Sauna',
                onChanged: (v) => ref
                    .read(workoutRepositoryProvider)
                    .setSaunaDone(sessionId, v),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GhostButton(
          label: 'Add exercise',
          icon: Icons.add,
          expanded: true,
          onPressed: () => ExercisePickerSheet.show(
            context,
            sessionId: sessionId,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _NotesField(sessionId: sessionId, initial: view.session.notes),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effective = enabled
        ? (color ?? AppColors.textPrimary)
        : AppColors.textTertiary;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, size: 20, color: effective),
      title: Text(
        label,
        style: AppText.display(size: 17, color: effective, letterSpacing: 0.2),
      ),
      onTap: enabled
          ? () {
              Haptics.light();
              onTap();
            }
          : null,
    );
  }
}

class _NotesField extends ConsumerStatefulWidget {
  const _NotesField({required this.sessionId, required this.initial});

  final String sessionId;
  final String? initial;

  @override
  ConsumerState<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends ConsumerState<_NotesField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 3,
      minLines: 2,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: const InputDecoration(hintText: 'Session notes…'),
      onChanged: (value) => ref
          .read(workoutRepositoryProvider)
          .setSessionNotes(widget.sessionId, value.isEmpty ? null : value),
    );
  }
}
