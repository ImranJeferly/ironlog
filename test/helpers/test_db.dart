import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gym/data/db/database.dart';

/// Fresh in-memory database with the seed data applied, as a real first run
/// would have it.
Future<AppDatabase> createTestDatabase() async {
  final db = AppDatabase.withExecutor(NativeDatabase.memory());
  // `beforeOpen` (and therefore seeding) runs lazily on first query.
  await db.customStatement('SELECT 1');
  return db;
}

/// Silences drift's "multiple databases" warning across many test cases.
void quietDrift() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

/// Closes an in-memory test database without hanging.
///
/// In widget tests the binding runs under `FakeAsync`, and drift schedules a
/// real zero-duration timer to detach a stream query when its subscription is
/// cancelled on unmount. That timer never runs inside `FakeAsync`, so a plain
/// `db.close()` — which waits for outstanding stream queries — can block
/// forever. The production app never closes its database, so this only ever
/// affects tests; a short timeout is the right cleanup here.
Future<void> closeTestDatabase(AppDatabase db) async {
  await db.close().timeout(const Duration(seconds: 2), onTimeout: () {});
}
