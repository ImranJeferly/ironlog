# Engineering decisions

Choices made while building IronLog that aren't obvious from the code, and the few places
I deviated from or extended the plan. Written for the person who owns this app.

## Architecture

- **Layering: `domain` → `data` → `features`, wired by Riverpod.** The progression engine,
  PR detection and strength maths live in `lib/domain` as pure functions with no Flutter or
  Drift imports, so they're trivially unit-testable (and they are — see
  `test/domain/`). Repositories in `lib/data/repositories` own all DB access; screens never
  touch Drift directly. `lib/app/providers.dart` is the single composition root.

- **Drift as the source of truth, chosen over `sqflite`/Isar.** The plan calls for
  relational session/set data and cheap chart queries; Drift gives typed SQL, reactive
  `watch()` streams (so screens update with no manual refresh), and code-genned companions.
  Every screen reads local streams, so there is never a spinner for local data — the
  offline-first requirement is structural, not best-effort.

- **Offline-first is enforced by construction.** Firebase is never awaited on the read
  path. `FirebaseBootstrap.init()` is wrapped so an unconfigured or unreachable Firebase
  leaves the app fully working; sync only ever flips a `synced` flag in the background.

## Progression & PR rules (the parts with judgement calls)

- **Rep ranges are the scheme's floor.** The plan says "3×8 means 8–10". I encoded each
  seeded exercise with an explicit `repRangeMin/Max`: 4×5 → 5–6, 3×8 → 8–10, 3×10 → 10–12,
  3×12 → 12–15, 3×15 → 15–18, 4×3 → 3. You earn the weight jump by hitting the **top** on
  **every** working set.

- **"Working weight" = the heaviest load carried last session.** Lighter back-off sets
  never hold progression back, and a heavier partial top set correctly becomes the new
  baseline. See `ProgressionEngine.suggest` and its tests.

- **Explosive work never auto-progresses.** Box jumps / jump squats are driven by bar
  speed and explicitly "not to failure", so double progression is disabled for the
  `explosive` role (`ExerciseRole.autoProgresses`).

- **The first session of an exercise sets silent baselines, not PRs.** Celebrating 18 PRs
  on your first Push day would make the PR feed meaningless, so `PrDetector` returns nothing
  when there's no history to beat.

- **Three PR types, ranked.** Weight PR (heaviest ever), rep PR (most reps at a
  previously-used load), and estimated-1RM PR (Epley) — the last one catches strength gains
  the other two miss, e.g. 32.5×6 beating 30×6. When one set breaks several, the weight PR
  leads the celebration.

## Sync

- **Last-write-wins on `updatedAt`, single user.** The plan states single-user, so there
  are no real conflicts. Every table carries `updatedAt`, `synced` and a `deleted`
  tombstone. Pull compares timestamps and the newer row wins; deletes propagate as
  tombstones rather than hard deletes so they survive the round trip.
- **Incremental pull via a stored high-water mark.** After each pull the newest
  `updatedAt` seen is saved; the next pull only asks Firestore for documents strictly newer,
  keeping sync cheap.
- **Progress photos never sync — local external storage only.** They're large, personal,
  and the compare slider only needs them on the phone that took them, so they stay on the
  device's app-scoped **external** storage (`getExternalStorageDirectory`, no runtime
  permission). `SyncService` has no photo push/pull path and `RemoteStore` has no file
  operations. (Profile avatars and voice notes *do* use Storage — see Firebase below.)

## Firebase

- **Blaze plan, on purpose.** The first social build ran on the free Spark plan and paid
  for it in complexity: a native foreground service holding Firestore listeners open to
  fake push notifications, a 15-minute polling job to catch what it missed, a
  battery-exemption prompt, and photos/voice notes squeezed into Firestore documents as
  inline blobs under the 1 MiB cap. All of that is deleted. The owner reversed the
  "nothing billable" constraint (Sept 2026); the free allowances on Blaze cover this
  app's traffic anyway.
- **Cloud Functions are the only thing that sends a push.** `functions/index.js` reacts
  to Firestore writes (`chats/*/messages`, `friendRequests`) and fans out over FCM to the
  tokens in `users/{uid}/fcmTokens`. The app writes documents; it never notifies anyone.
  Tokens are keyed by the token string so re-registering is idempotent; FCM's
  "not registered" error deletes them.
- **Notification + data messages, not data-only.** With a `notification` block Android
  displays the push itself when the app is backgrounded or killed — the reliable path —
  and the `data.route` tells the app where to go on tap. In the foreground the app posts
  the same thing through `flutter_local_notifications` (unless that chat is open). The
  background isolate does exactly one thing: stamp `deliveredAt`.
- **Storage rules decide membership from the path.** A chat id is `{uidA}_{uidB}`, so
  `chats/{chatId}/voice/*` is readable by `uid in chatId.split('_')` — no Firestore
  lookup per download. Voice notes are write-once (no overwrite/delete), like messages.
- **Online first, offline fallback = Firestore's own semantics, made explicit.**
  `persistenceEnabled` + unlimited cache at boot. `get()` is server-then-cache; listeners
  emit cache then server; writes queue on disk. The one deliberate deviation is
  `broadcast()`, which caps the server wait at 4 s because it runs mid-session.
- **Messages are immutable; receipts are the recipient's.** Rules allow `update` on a
  message only for `deliveredAt`/`seenAt`, only by the non-author. That's what makes the
  ticks trustworthy.
- **`RemoteStore` is a Firestore-only interface.** The whole push/pull/merge algorithm is
  tested against an in-memory fake (`test/data/sync_service_test.dart`) with no Firebase
  project required, including a test asserting photos are never pushed.

## Health & metrics

- **Health never overwrites manual entries.** Each metric tracks whether steps/sleep/weight
  came from Health (`stepsFromHealth`, etc.); a Health refresh only fills fields that are
  empty or were themselves Health-sourced. Type a weight by hand and Health won't stomp it.
- **No food database.** The plan calls that over-engineering — calories/protein are a plain
  manual daily number.
- **Health is guarded everywhere.** Every call sits behind platform checks and try/catch so
  desktop, the test runner, and denied permissions degrade to manual entry instead of
  crashing.

## UI

- **One neon accent, enforced.** `AppColors.volt` (#D4FF00) is the only accent for CTAs,
  checkmarks and PRs; the purple→blue gradient is reserved for charts, as specced. No
  default Material surfaces — a custom card, pill-button, toggle and nav-bar kit lives in
  `lib/widgets`.
- **The wheel picker fades and blurs neighbours** (`NumberWheel`) for the screenshot-1
  look, with integer-accumulated steps to avoid float drift over hundreds of values, and
  nudge buttons for when scrolling mid-set is fiddly.
- **The platform UI font is used (SF Pro on iOS, Roboto on Android)** rather than bundling
  Inter — it matches the design intent, avoids a webfont download, and keeps the repo light.
  Swap in Inter via `pubspec` fonts + `AppTheme._fontFamily` if you want it pixel-exact.

## Deviations / extensions beyond the plan

- **Added `SessionExercises` (a per-session snapshot of the prescription).** Freezing each
  exercise's target sets, rep range and the engine's suggestion at session-start means past
  sessions keep showing exactly what the app told you at the time, even after you later edit
  the exercise definition.
- **Added a `deleted` tombstone column** to every synced table — not in the plan's schema,
  but required for deletes to sync correctly under last-write-wins.
- **Added mid-session editing** (add/remove/reorder exercises, add sets, edit/delete a
  logged set with renumbering) — implied by "empty session" and real gym use.
- **Discard vs. delete.** An abandoned session with nothing logged is hard-deleted (nothing
  was ever synced); a finished session is soft-deleted so the tombstone reaches Firestore.

## Test-only note

- **`closeTestDatabase` uses a timed close.** Under the widget-test `FakeAsync` zone, drift
  schedules a real zero-duration timer to detach a stream query when a screen unmounts; that
  timer never runs inside `FakeAsync`, so a plain in-memory `db.close()` (which waits for
  outstanding stream queries) can block forever. The production app never closes its
  database, so this only ever affects tests — see the helper in `test/helpers/test_db.dart`.

## Known follow-ups (not blocking)

- The `health` package on iOS needs the **HealthKit capability** toggled once in Xcode
  (documented in the README); it can't be scripted from Dart.
- Two-way *external* calendar sync (Google/Outlook) from the plan's aspirational notes is
  not implemented — the plan's own screen list and feature checklist don't include it, and
  it's out of scope for a personal single-user tracker.
