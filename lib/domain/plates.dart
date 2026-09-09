import 'enums.dart';

/// What to hang on each side of the bar, biggest plate first.
class PlateLoad {
  const PlateLoad({
    required this.perSide,
    required this.barKg,
    required this.leftoverKg,
  });

  /// Plate weights for **one** side, in the user's unit, heaviest first.
  final List<double> perSide;

  /// The bar this was calculated against, in the user's unit.
  final double barKg;

  /// What couldn't be made up with the available plates, in the user's unit.
  /// Anything above zero means the target isn't loadable.
  final double leftoverKg;

  bool get isExact => leftoverKg < 0.01;

  bool get isBarOnly => perSide.isEmpty && isExact;
}

/// Barbell plate maths. Gyms stock a known set of plates, so "what do I put on
/// the bar for 82.5 kg" is a greedy fit against that set — which is exactly
/// how you do it standing in front of the rack.
abstract final class Plates {
  /// Standard metric plate set, heaviest first (kg).
  static const kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];

  /// Standard imperial set (lb).
  static const lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  /// Olympic bar, per unit.
  static const barKg = 20.0;
  static const barLb = 45.0;

  static List<double> platesFor(WeightUnit unit) =>
      unit == WeightUnit.kg ? kgPlates : lbPlates;

  static double defaultBar(WeightUnit unit) =>
      unit == WeightUnit.kg ? barKg : barLb;

  /// Greedy split of [totalKg] across both sides of a [barWeightKg] bar.
  /// Everything in and out is kg; convert for display.
  ///
  /// Returns null when the target is at or below the bar — there's nothing to
  /// load and nothing useful to show.
  static PlateLoad? forTotal(
    double totalKg, {
    required WeightUnit unit,
    double? barWeightKg,
  }) {
    final bar = barWeightKg ?? unit.toKg(defaultBar(unit));
    if (totalKg < bar - 0.01) return null;

    // Work in the display unit: a gym's plates are whatever's printed on them,
    // and rounding in kg then converting invents 1.13 lb plates.
    final total = unit.fromKg(totalKg);
    final barDisplay = unit.fromKg(bar);
    var perSide = (total - barDisplay) / 2;
    if (perSide < 0) perSide = 0;

    final chosen = <double>[];
    var remaining = perSide;
    for (final plate in platesFor(unit)) {
      while (remaining >= plate - 0.001) {
        chosen.add(plate);
        remaining -= plate;
      }
    }

    return PlateLoad(
      perSide: chosen,
      barKg: barDisplay,
      leftoverKg: remaining < 0.001 ? 0 : remaining * 2,
    );
  }

  /// "20 + 20 + 5" — the per-side list as a human reads it off the bar.
  static String describe(PlateLoad load) {
    if (load.isBarOnly) return 'Bar only';
    if (load.perSide.isEmpty) return '—';
    return load.perSide.map(_trim).join(' + ');
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
}
