# Changelog

All notable changes to IronLog. Newest first.

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
