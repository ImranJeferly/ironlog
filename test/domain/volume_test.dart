import 'package:flutter_test/flutter_test.dart';
import 'package:gym/core/utils/date_x.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/volume.dart';

/// Spec §4 — hard sets per muscle: primary 1, secondary 0.5, explosive 0,
/// warm-ups excluded, bucketed by calendar week.
void main() {
  final now = DateTime(2026, 9, 9, 12); // a Wednesday
  final thisWeek = now.weekStart;
  final lastWeek = thisWeek.subtract(const Duration(days: 7));

  const credits = <String, Map<Muscle, double>>{
    'dips': {Muscle.chest: 1.0, Muscle.triceps: 0.5},
    'curl': {Muscle.biceps: 1.0},
    'jump': <Muscle, double>{}, // explosive → no credit
  };

  VolumeSetInput set(
    String id,
    DateTime date, {
    double w = 40,
    int reps = 10,
    bool warmup = false,
  }) => VolumeSetInput(
    exerciseId: id,
    weightKg: w,
    reps: reps,
    isWarmup: warmup,
    date: date,
  );

  test('primary gets 1, secondary 0.5, per hard set', () {
    final weeks = VolumeCalc.weekly(
      sets: [set('dips', thisWeek), set('dips', thisWeek), set('curl', thisWeek)],
      credits: credits,
      now: now,
    );
    final w = weeks.last;
    expect(w.hardSets[Muscle.chest], 2.0);
    expect(w.hardSets[Muscle.triceps], 1.0);
    expect(w.hardSets[Muscle.biceps], 1.0);
    expect(w.hardSets[Muscle.back], 0.0);
    expect(w.totalHardSets, 4.0);
  });

  test('warm-ups and explosive work count for nothing', () {
    final weeks = VolumeCalc.weekly(
      sets: [
        set('dips', thisWeek, warmup: true),
        set('jump', thisWeek),
        set('jump', thisWeek),
      ],
      credits: credits,
      now: now,
    );
    expect(weeks.last.totalHardSets, 0.0);
  });

  test('tonnage is credited with the same weights', () {
    final weeks = VolumeCalc.weekly(
      sets: [set('dips', thisWeek, w: 20, reps: 10)], // 200 kg
      credits: credits,
      now: now,
    );
    expect(weeks.last.tonnageKg[Muscle.chest], 200.0);
    expect(weeks.last.tonnageKg[Muscle.triceps], 100.0);
  });

  test('sets land in their calendar week, oldest first', () {
    final weeks = VolumeCalc.weekly(
      sets: [set('curl', lastWeek), set('curl', thisWeek), set('curl', thisWeek)],
      credits: credits,
      now: now,
      weeks: 4,
    );
    expect(weeks.length, 4);
    expect(weeks.last.weekStart, thisWeek);
    expect(weeks[2].weekStart, lastWeek);
    expect(weeks[2].hardSets[Muscle.biceps], 1.0);
    expect(weeks.last.hardSets[Muscle.biceps], 2.0);
    expect(weeks.first.totalHardSets, 0.0);
  });

  test('older sets and unknown exercises are ignored', () {
    final weeks = VolumeCalc.weekly(
      sets: [
        set('curl', thisWeek.subtract(const Duration(days: 60))),
        set('mystery', thisWeek),
      ],
      credits: credits,
      now: now,
    );
    expect(weeks.every((w) => w.totalHardSets == 0), isTrue);
  });

  test('contributing exercises are tracked per muscle', () {
    final weeks = VolumeCalc.weekly(
      sets: [set('dips', thisWeek), set('dips', thisWeek), set('curl', thisWeek)],
      credits: credits,
      now: now,
    );
    expect(weeks.last.setsByExercise[Muscle.chest], {'dips': 2.0});
    expect(weeks.last.setsByExercise[Muscle.triceps], {'dips': 1.0});
    expect(weeks.last.setsByExercise[Muscle.biceps], {'curl': 1.0});
  });

  test('target status', () {
    const t = VolumeTarget(12, 16);
    expect(t.statusFor(11.5), VolumeStatus.under);
    expect(t.statusFor(12), VolumeStatus.onTarget);
    expect(t.statusFor(16), VolumeStatus.onTarget);
    expect(t.statusFor(16.5), VolumeStatus.over);
    expect(VolumeCalc.defaultTargets[Muscle.chest], const VolumeTarget(12, 16));
    expect(VolumeCalc.defaultTargets.keys.toSet(), Muscle.values.toSet());
  });
}
