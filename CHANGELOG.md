# Changelog

All notable changes to IronLog. Newest first.

## Unreleased — the cleanup pass

Everything from a full read of the app: what was dead, what was noisy,
and the small features that were missing.

**Gone**

- **Anonymous auth.** The app already required a real account before it
  synced or showed anything social, so the anonymous user only littered
  the Auth list on every fresh install.
- `cupertino_icons` (unused), `TODO.md` (stale), and error copy that
  still blamed undeployed security rules.
- **The sixth bottom tab.** Photos folded into Progress, next to Body,
  where the other "how is my body changing" views already live.

**Quieter**

- **PRs no longer spam.** They're collected during the session and go out
  with the finish summary as one message. A three-PR session with five
  friends was 20 messages and 20 pushes; it's now 5.
- Profile stats are only published when a number actually moved, and
  `lastSeenAt` at most every 15 minutes rather than on every app resume.
- Friend requests are deleted once answered instead of accumulating.

**New — friends**

- **Mute** a friend's workout posts, or everything. Checked server-side
  before the push; muted messages still arrive silently in the chat.
- **Block** (tears down the friendship, stops messages and requests at
  the security rules) and **report**.
- **Reactions** — one emoji per person per message.
- **Photos in chat**, with a zoomable viewer.
- **Delete for everyone**, for your own messages.
- **Typing indicator**, throttled to one write per 5 seconds.
- **Voice notes** get a scrubber and a 1×/1.5×/2× speed pill.
- **Nudge** — one tap on a friend's profile.

**New — training**

- **Plate calculator** under the weight wheel on barbell lifts: what to
  hang on each side, and how far short you are when it isn't loadable.
- **Supersets.** Link an exercise to the one above it in the workout
  editor; logging a set jumps to the partner instead of resting, and the
  timer only runs once the round is done.
- **Rest notification actions** — +30 s and Skip without opening the app.
- **Body measurements** — chest, waist, hips, arm, thigh, neck, on the
  Body tab, synced and exported.
- **Repeat a workout** from any session in History.

**New — your data**

- **Progress photos back up to Storage** (`users/{uid}/photos/…`,
  owner-only) and download onto a new phone. They were local-only because
  Storage used to be off-limits; that reason is gone, and a lost phone
  was the one thing local-only couldn't survive.
- **Restore from CSV** in Sync & data, reading back what Export writes.
  Existing days and sessions are left alone, so running it twice is safe
  and a set naming an unknown exercise is skipped rather than invented.

## Earlier — proper Firebase: Cloud Functions, FCM, Storage

The free-tier workarounds are gone. The project now needs the **Blaze**
plan (pay-as-you-go; the free allowances cover a handful of users many
times over). Deploy with `firebase deploy` — rules, Storage rules and
Functions all live in the repo.

- **Push notifications over FCM.** Cloud Functions (`functions/index.js`)
  watch `chats/*/messages` and `friendRequests` and push to every device
  registered under `users/{uid}/fcmTokens`. Messages, voice notes,
  PR/session broadcasts, new requests and acceptances all arrive as real
  pushes — app closed, screen off, no battery-exemption dance. Dead tokens
  are pruned on the first failed send.
- **The native listener stack is deleted.** `FriendPushService`,
  `KeepAliveJob`, `PushReceiver` and `PushInbox` (a foreground service, a
  15-minute polling job and a persistent "Background listener"
  notification) are gone, along with the FOREGROUND_SERVICE and
  battery-optimisation permissions and the Profile › Notifications card.
  The inline "Reply" box on message notifications went with it.
- **Delivered ticks come from the phone that got the push**, stamped on
  arrival (foreground or background) — the one thing a server can't know.
- **Photos and voice notes in Firebase Storage.** Profile photos upload to
  `profiles/{uid}/avatar.jpg` (now 512 px), voice notes to
  `chats/{chatId}/voice/{messageId}.m4a`, with rules scoped to the owner /
  the two chat members. Messages carry a URL instead of a 1 MiB-capped
  blob, so a chat no longer re-downloads every voice note it ever had.
  Old inline blobs still render. Uploads are the one thing that needs a
  connection, and say so; text still queues offline.
- **Online first, offline fallback, explicitly.** Firestore persistence is
  configured at boot with an unlimited cache: reads go to the server and
  fall back to the cache; writes queue on disk and flush when they can.
  Broadcasts try the server for four seconds before using the cached
  friend list.
- **Tighter Firestore rules.** A sent message is immutable except for
  `deliveredAt`/`seenAt`, which only the recipient may write; only the
  author can delete one. Friend requests can't change their `from`/`to`
  and must be created as `pending` under the `{from}_{to}` id. Chat
  membership can't be rewritten. FCM tokens are private to their owner.

## Earlier — friends, chat and profiles

Everything social lived in Firestore documents only — no Firebase Storage,
no server code. It needs a real (non-guest) account.

- **Friends tab.** New tab between History and Photos with Chats, Friends
  and Requests. The tab badge counts unread messages plus pending requests.
- **Friend requests.** Find someone by `@handle`, send a request, they accept
  (or decline), and only then does a chat open. Nothing — no chat, no
  profile stats — is reachable until both sides are friends. Removing a
  friend closes the door again. If you both send at the same time the
  second send accepts the first, says so, and opens the chat instead of
  claiming a request was sent. Your own sent requests sit under Requests ›
  Sent until answered.
- **Sending never blocks.** A message and the chat's last-message/unread
  fields go out in one atomic batch that returns as soon as it's queued —
  no server round-trip, no chat-document read first — so the composer
  stays responsive on a flaky link and the pending tick resolves on its
  own when the connection is back. If your messages sit unacknowledged
  for more than 8 s the chat shows "Waiting for connection — tap to
  retry", which forces Firestore to reconnect. PR/session broadcasts use
  the same path.
- **Loud failures.** When Firestore rejects a read or write (typically the
  rules aren't published yet) the Friends tab shows a red banner and each
  list says why, instead of an empty "no requests" state; search and send
  report the same reason.
- **Chat, WhatsApp-style.** Text and voice notes (AAC, up to 90 s, stored
  inline in the message), swipe or long-press to reply with a quoted
  preview, copy, day separators, and per-message ticks: clock while sending,
  one tick sent, two ticks delivered, bright double ticks seen. Unread counts clear
  when the chat is open.
- **Broadcasts to every friend.** Starting a session, finishing one (sets +
  tonnage) and every PR post a system line into each friend chat.
- **Profile page** (Settings › pencil, or your avatar on the Friends tab):
  photo from camera or gallery (compressed to ≤320 px and saved inside the
  profile document), display name, unique handle, short bio. Every account
  gets a handle automatically from its email (`imran`, `imran2`, …) the
  same way it gets a name, so friends can find you before you've edited
  anything; you can still change it. A rejected handle save now says why
  (taken, offline, or rules not deployed).
- **Friend profile + compare.** Tap a friend anywhere: training-now / now
  playing / last seen, sessions, streak, PRs, 4-week adherence, weekly
  sets, best lifts, and a you-vs-them bar comparison including every lift
  you both track.
- **Now playing.** With Android "notification access" granted (Profile ›
  Now playing) and the share switch on, the track currently playing on the
  phone shows on your profile and in the chat header for friends. Refreshed
  every minute while the app is open; hidden after 8 minutes without an
  update. Nothing is published until you grant access, and the share switch
  turns it off entirely; only title, artist and player app are read.
- **Real notifications, no server, free plan.** Every chat message, voice
  note, PR, session start/finish and friend request lands on the friend's
  phone as a system notification even when IronLog is closed. A small
  Android foreground service keeps Firestore listeners open on your chats
  and requests and posts the notifications itself (WhatsApp-style
  conversation notifications with an inline Reply box); a 15-minute
  catch-up job restarts it if the OEM kills it and picks up anything
  missed; it restarts after reboots and app updates. Tapping opens the
  chat (or the Requests list), a chat that is already open does not
  double-notify, and messages that arrive while the app is closed still
  get their "delivered" tick. Profile › Notifications › Allow exempts
  IronLog from battery optimisation so the listener survives Doze.
  Signing out stops it.
- Firestore rules updated for `users`, `handles`, `friendRequests` and
  `chats` — deploy `firestore.rules` once (free):
  `firebase deploy --only firestore:rules`.

## Unreleased — red "aggressive" restyle

- **Blood-red accent** replaces volt yellow everywhere (buttons, ticks, PRs,
  live indicators, heatmap ramp, charts). Warnings and deload use ember
  orange; on-target volume reads in bone white so red always means "act".
- **New type system.** Barlow Condensed (bold) for headlines, eyebrows,
  buttons and nav; Barlow for body copy; Chakra Petch kept for every numeral
  (weights, reps, timers, stats) with tabular figures. All bundled — works
  offline.
- **Same soft surfaces as before**, sharpened: rounded cards with red edge
  bars on rows that matter, a red-glow hero panel that starts the session,
  glowing red primary buttons, rounded gauges with a glow on the fill,
  numeric index tags on exercise lists, thin red-led section rules.
- Floating nav pill kept; the active tab is red-tinted with a red icon.
- Every screen touched: Home hero + adherence strip, daily metrics gauges,
  template picker/editor, active session (numbered set rows, numeric clock,
  glowing rest bar), set logger (numeric RPE 6–10 chips), summary, PR flash,
  progress tabs, volume bars with a target band, exercise detail, history,
  photos, settings, auth, first run and the updater.
- Logo recoloured to red; launcher icons regenerated; splash is black.
- **Settings reorganised.** The tab now shows your profile (avatar, account,
  sessions / streak / PRs / 4-week adherence, sign in or out) and one row
  per area; the detail moved to sub-pages: Training (days, units,
  body-weight goal), Session (rest timer, haptics, reminders), Health
  Connect (link, step goal, manual sync), Sync & data (Firebase, CSV) and
  About (version, updates).
- **Rest between exercises.** Logging an exercise's last set now starts a
  separate, longer rest (default 5 min, Settings › Session) before the next
  exercise, labelled with what's coming. Between-set rests are unchanged.

## Unreleased — training-quality overhaul

### 1. Data integrity
- **Auto-end abandoned sessions.** After 45 minutes without a logged set the
  session asks "Still training?"; with no answer inside 5 minutes it ends at
  the last completed set, not at "now".
- **Duration cap.** Stored duration is capped at 240 min; anything longer is
  flagged `duration_suspect` instead of inflating history.
- **No empty sessions.** A session with zero working sets can't be saved —
  the only exit is Discard (a warm-up alone doesn't count).
- **Phantom sets rejected.** 0 kg × ≤1 rep is refused on any exercise that
  isn't bodyweight; the sheet explains why.
- **Undo last set.** Every logged set shows a 5-second UNDO; undoing also
  retracts any PR the set produced.
- **RPE 6–10, required on the last set** of each exercise (optional elsewhere).
  Added the RPE 10 "Max" level.
- **One-time repair job** on first open: caps/flags sessions over 240 min,
  tombstones completed sessions with no working sets, and tombstones phantom
  sets (with their PRs). Counts are logged.
- Schema v2: `sessions.duration_suspect`. The column syncs to the account.

### 2. Exercise model
- **Fine-grained muscles.** New `Muscle` taxonomy (Chest, Back, Traps,
  Shoulders, Side Delts, Rear Delts, Biceps, Triceps, Quads, Hamstrings,
  Glutes, Calves, Core); each rolls up to the old coarse group for colours.
- **`primary_muscle` / `secondary_muscle` / `is_explosive`** on every
  exercise. Secondary counts 0.5 toward volume; explosive is excluded from
  hypertrophy volume and auto-progression.
- **Seed attribution applied** per the spec (e.g. Dips → Chest/Triceps,
  Pull-ups → Back/Biceps, RDL → Hamstrings/Glutes, Box Jump → Quads,
  explosive). A one-time backfill fixes existing installs; custom exercises
  get their group's best-guess primary.
- **11 new exercises:** Flat DB Press, Lateral Raise, Leg Extension, Lying
  Leg Curl, Seated Leg Curl, Chest-Supported Row, Lat Pulldown, Machine
  Chest Press, Walking Lunge, Skull Crusher, Shrugs.
- Custom-exercise sheet now picks primary + optional secondary muscle and an
  Explosive flag. New fields sync to the account.
- Schema v3.

### 3. Program: PPL 6-Day v2
- **Six seeded days** — Push A / Pull A / Legs A / Push B / Pull B / Legs B —
  each with its own sets × rep-range per exercise (template exercises gained
  `rep_min_override` / `rep_max_override`; schema v4). Activated as the
  program on first launch.
- **Rotation, not weekdays.** Home offers the *next day in the rotation*;
  finishing a day advances the cursor (finishing a day out of order
  re-anchors there). A missed day never skips a workout.
- **Starting loads** come from the last logged working weight; new exercises
  open the sheet blank-ish and prompt on the first set.
- **Double progression, RPE-gated.** Top of the rep range on every set *at
  RPE ≤ 9* → +2.5 kg (upper) / +5 kg (lower) pre-filled next session. A set
  ground out at RPE 10 repeats the weight instead.
- **Stalled badge** on any exercise trained in the last 4 weeks without an
  e1RM PR.
- **Deload suggestion** on Home: every 7th program week, or two full weeks at
  average RPE ≥ 8.8 with ≥ 2 stalled lifts. One tap applies it to the next 6
  sessions (half the sets, −10 % load, no jumps); "Not now" snoozes it.
- **Session clock** shows elapsed vs the 80-min target, turns amber at 80,
  red at 90, and nudges you once past 90.

### 6. Daily metrics, low friction
- **Weigh-in prompt** when starting a session with no body weight logged in
  the last 3 days — one wheel, prefilled with the last value. Skip is
  allowed and counted.
- **21:00 reminder** "Log protein + kcal"; tapping it opens the Today card.
  Toggle in Settings › Reminders.
- **Body-weight chart** now reports the weekly change in kg and % (on the
  7-day line) against an **editable target band** (default lean bulk
  0.20–0.35 kg/wk) and says under / on track / over.
- **Steps** keep syncing from Health Connect; the card adds a 7-day rolling
  average.
- Today card fields (weight, kcal, protein, sleep) stay one-tap editable.

### 4. Volume screen
- Progress › Muscles is now **weekly hard sets per muscle** (warm-ups and
  explosive work excluded, secondary muscles ×0.5) against an **editable
  target band** per muscle — defaults Chest 12–16, Back 12–16, Quads 10–14,
  Hamstrings 8–12, Side Delts 8–12, Rear Delts 6–10, Biceps/Triceps 8–12,
  Calves 8–12, Core 6–10. **Red under, amber over**, volt in band.
- Tap a muscle → the exercises behind the number this week, a **4-week
  tonnage trend**, and the target editor.

### 5. Per-exercise trend
- Exercise detail defaults to a **top-set + e1RM (Epley)** chart, shows the
  **STALLED** badge, and ends with a **last-5-sessions table** (date · top
  set · e1RM · sets). Stalled lifts are badged in the exercise list too.

### 7. Consistency
- With the program active, Home measures the week against its **6-session
  target**, shows the **current streak** (consecutive sessions no more than
  3 days apart), a **rolling 4-week adherence %** and sessions in the last
  28 days.

### 8. Export + tests
- `sessions.csv` gains `program_day`, `ended_at`, `duration_suspect`,
  `primary_muscle`, `secondary_muscle`, `is_explosive`.
- New **`weekly_volume.csv`** — `week, muscle, hard_sets, tonnage_kg`, the
  same accounting as the Volume screen, for every trained week.
- `metrics.csv` now exports every column (incl. the from-Health flags and
  `updated_at`).
- Soft-deleted rows are excluded from every file.
- Tests: data-integrity rules, exercise model + backfill, program rotation /
  prescriptions / deload, RPE-gated progression, volume calculation, CSV
  export.
