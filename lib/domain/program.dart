/// A training program: an ordered rotation of template ids.
///
/// The rotation doesn't care what day of the week it is — the next session is
/// always the one after the last completed one, so a missed day never skips a
/// workout. That suits real adherence far better than a fixed weekly grid.
class ProgramDefinition {
  const ProgramDefinition({
    required this.id,
    required this.name,
    required this.dayIds,
    required this.sessionsPerWeek,
  });

  final String id;
  final String name;

  /// Template ids in rotation order.
  final List<String> dayIds;

  /// What adherence is measured against.
  final int sessionsPerWeek;

  int get length => dayIds.length;

  bool contains(String? templateId) =>
      templateId != null && dayIds.contains(templateId);

  int indexOf(String templateId) => dayIds.indexOf(templateId);

  /// Template id at a rotation cursor (wraps).
  String dayAt(int cursor) => dayIds[cursor % dayIds.length];

  /// Cursor value for "the session after [templateId]".
  int cursorAfter(String templateId) {
    final i = indexOf(templateId);
    return i < 0 ? 0 : (i + 1) % dayIds.length;
  }
}

/// Settings keys the program/rotation state lives under.
abstract final class ProgramKeys {
  static const id = 'program_id';
  static const cursor = 'program_cursor';
  static const startedAt = 'program_started_at';

  /// Sessions still to be run at deload intensity (50% sets, −10% load).
  static const deloadRemaining = 'deload_remaining';

  /// ISO day the current deload was applied — used to avoid re-suggesting one
  /// immediately after.
  static const lastDeloadAt = 'last_deload_at';

  /// ISO day the user tapped "Not now" on a deload suggestion.
  static const deloadDismissedAt = 'deload_dismissed_at';
}

/// Session-length targets (spec §3).
abstract final class SessionTargets {
  static const target = Duration(minutes: 80);
  static const warn = Duration(minutes: 90);
}
