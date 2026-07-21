import 'package:intl/intl.dart';

/// Everything in IronLog keys off the *local calendar day*, so dates are
/// normalised to local midnight before they touch the database.
extension DateOnly on DateTime {
  DateTime get dayStart => DateTime(year, month, day);

  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Monday of the week this date falls in.
  DateTime get weekStart => dayStart.subtract(Duration(days: weekday - 1));

  int get daysSinceEpochLocal => dayStart.millisecondsSinceEpoch ~/ 86400000;
}

abstract final class Dates {
  static DateTime today() => DateTime.now().dayStart;

  static int daysBetween(DateTime from, DateTime to) =>
      to.dayStart.difference(from.dayStart).inDays;

  /// Inclusive list of day-start dates.
  static List<DateTime> range(DateTime from, DateTime to) {
    final out = <DateTime>[];
    var d = from.dayStart;
    final end = to.dayStart;
    while (!d.isAfter(end)) {
      out.add(d);
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return out;
  }

  static final _weekday = DateFormat('EEE');
  static final _weekdayLong = DateFormat('EEEE');
  static final _dayMonth = DateFormat('d MMM');
  static final _dayMonthYear = DateFormat('d MMM yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _time = DateFormat('HH:mm');

  static String weekdayShort(DateTime d) => _weekday.format(d);

  static String weekdayLong(DateTime d) => _weekdayLong.format(d);

  static String dayMonth(DateTime d) => _dayMonth.format(d);

  static String dayMonthYear(DateTime d) => _dayMonthYear.format(d);

  static String monthYear(DateTime d) => _monthYear.format(d);

  static String time(DateTime d) => _time.format(d);

  /// "Today" / "Yesterday" / "Wed 14 May" — used in history lists.
  static String relativeDay(DateTime d) {
    final diff = daysBetween(d, DateTime.now());
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    return dayMonth(d);
  }

  /// ISO-ish `yyyy-MM-dd`, used as the Firestore document id for daily metrics.
  static String isoDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime parseIsoDay(String s) => DateTime.parse(s).dayStart;
}
