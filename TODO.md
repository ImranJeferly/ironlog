# IRONLOG — Build TODO

Mirrors the feature checklist in `gym-tracker-app-plan.md`. All items implemented,
compiling, `flutter analyze` clean, 89 tests passing.

## 0. Foundation
- [x] Flutter project scaffolded, deps installed (Riverpod, Drift, Firebase, fl_chart, health, image_picker)
- [x] Dark theme system (`#0A0A0F` bg, `#16161D` cards, `#D4FF00` volt accent, purple/blue chart gradient)
- [x] Drift schema: exercises, templates, template_exercises, sessions, session_exercises, workout_sets, metrics, photos, personal_records, settings
- [x] Riverpod architecture: DAOs → repositories → providers → screens
- [x] Seed data on first run: Push/Pull/Legs/Extra templates + all exercises with schemes/rep ranges
- [x] App shell with bottom navigation (Home · Progress · History · Photos · Settings)

## 1. Programming / progression engine
- [x] Role-based schemes: primary 4×5, secondary 3×8, isolation 3×12–15, explosive 4×3
- [x] Rep ranges per role (3×8 ⇒ 8–10 etc.)
- [x] Double progression: all sets at top of range ⇒ `↑ WEIGHT` flag next session
- [x] Increments: +2.5 kg upper body / +5 kg lower body
- [x] Explosive role excluded from auto-progression
- [x] Last-session ghost prefill (weight × reps per set number)

## 2. Program templates (seed)
- [x] PUSH (Mon): Incline DB Press · Seated Shoulder Press · Weighted Dips · Cable Chest Fly · Overhead Tricep Ext · Tricep Pulldown · Rope 5 min + Sauna
- [x] PULL (Wed): Weighted Pull-ups · Cable Row · Single-Arm DB Row · EZ Bar Curl · Cross-Body Hammer Curl · Rear Delt Fly · HIIT bike 15 min + Sauna
- [x] LEGS (Fri): Box Jump/Jump Squat · Bulgarian Split Squat · Romanian Deadlift · Leg Press · Calf Raises · Hanging Leg Raise · Ab Wheel · Rope 10 min + Sauna
- [x] EXTRA (Sat arms finisher): EZ Curl · Incline Curl · Pulldown · OH Ext

## 3. Core — workout logging
- [x] Start Session — pick template or empty session
- [x] Set logger — weight × reps, big wheel/number pickers, kg/lb toggle
- [x] Auto-prefill — last session's weights as ghost values
- [x] ↑ WEIGHT flag surfaced in the session UI
- [x] Rest timer — auto-starts after logging a set, local notification when done
- [x] RPE / notes per set — optional emoji difficulty (😤 → 💀)
- [x] Session summary — duration, tonnage, PRs hit, day-complete checkmark
- [x] Cardio + sauna checkmarks ✓/✗ per session
- [x] Add/remove/reorder exercises mid-session; add extra sets

## 4. Progress & analytics
- [x] Per-exercise page — top-set weight chart, est. 1RM (Epley), total volume over time
- [x] Muscle group view — weekly sets per muscle, volume trend, "least trained" flag
- [x] PR feed — every new rep/weight/e1RM PR logged automatically + celebration
- [x] Consistency — GitHub-style heatmap, current streak, weekly adherence % (3/3)
- [x] Body weight trend — logged weight + 7-day moving average

## 5. Progress photos
- [x] Capture/import with front/side/back tags (camera or gallery)
- [x] Timeline grid
- [x] Compare mode — slider between any two dates
- [x] Compressed, stored on local **external** storage only — never uploaded (owner: no billable Storage)

## 6. Daily metrics
- [x] Steps from Apple Health
- [x] Water quick-add (+250 ml tap)
- [x] Calories / protein manual daily entry
- [x] Sleep hours (Health or manual)
- [x] Today card — workout done?, steps, water, weight at a glance

## 7. System
- [x] Offline-first — local DB is source of truth, zero loading spinners for local data
- [x] Firebase sync — anonymous auth, Firestore push/pull, `synced` flag + `updatedAt`, last-write-wins
- [x] ~~Firebase Storage photo sync~~ — removed per owner: photos are local-only (no billable Storage)
- [x] Sync triggered on connectivity regain / app resume; status surfaced in Settings
- [x] CSV export of all sessions
- [x] Apple Health import on first run (weight, steps history)
- [x] First-run setup: units + Health permission

## 8. Screens
- [x] Home / Today — today's workout card, streak, quick stats row
- [x] Active Session — exercise list, wheel picker, rest timer bar, finish
- [x] Progress — tabs: Exercises · Muscle Groups · Body · Photos
- [x] History — calendar heatmap + session list, tap into past session
- [x] Photos — grid timeline + compare mode
- [x] Settings — units, rest defaults, sync status, export

## 9. UI polish
- [x] No default Material look anywhere (custom card/button/toggle/nav kit)
- [x] Huge numerals wheel picker with faded/blurred neighbours
- [x] Pill buttons, 16–20 px card radius, generous spacing
- [x] Haptic on set logged
- [x] PR celebration animation (flash + confetti + haptics)
- [x] Animated charts

## 10. Quality gates
- [x] `flutter analyze` clean (zero issues)
- [x] Unit tests: progression engine, PR detection, 1RM, volume, moving average, seeding, sync merge
- [x] Widget tests: home, first-run, active session, summary, progress, history, settings
- [x] README.md (setup + Firebase config steps)
- [x] DECISIONS.md

## Build phases
- [x] P1 — Log & Progress
- [x] P2 — Sync + Photos
- [x] P3 — Metrics & Polish
