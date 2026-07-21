import '../../domain/enums.dart';

abstract final class Fmt {
  /// Drops the decimal on whole numbers: 40 kg, not 40.0 kg.
  static String num1(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    final rounded = (v * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
  }

  /// Converts from the stored kg and appends the user's unit.
  static String weight(double kg, WeightUnit unit, {bool withUnit = true}) {
    final v = unit.fromKg(kg);
    return withUnit ? '${num1(v)} ${unit.label}' : num1(v);
  }

  /// Big numbers get a thousands separator: 12 480 kg.
  static String tonnage(double kg, WeightUnit unit) {
    final v = unit.fromKg(kg);
    final whole = v.round();
    final s = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '$buf ${unit.label}';
  }

  /// Plain integers with a thousands separator: 20 000, 8 450.
  static String count(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer(v < 0 ? '-' : '');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${d.inMinutes}m';
  }

  static String durationMinutes(int minutes) =>
      duration(Duration(minutes: minutes));

  /// mm:ss — the rest timer readout.
  static String clock(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String setSummary(double weightKg, int reps, WeightUnit unit) =>
      '${weight(weightKg, unit)} × $reps';

  static String water(int ml) =>
      ml >= 1000 ? '${num1(ml / 1000)} L' : '$ml ml';

  static String percent(double fraction) => '${(fraction * 100).round()}%';

  static String signed(double v) => v >= 0 ? '+${num1(v)}' : num1(v);
}
