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
