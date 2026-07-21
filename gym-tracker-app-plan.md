# 🏋️ IRONLOG — Personal Gym Tracker (App Plan)

Personal-use only. Gym only (no kickboxing). Offline-first, Firebase-synced, dark & sleek.
Stack: Flutter + local DB + Firestore + Firebase Storage.

---

## 1. PROGRAMMING — Rep Schemes (the fix)

Your current mix (4×6 / 4×5 / 3×12) isn't broken, it's just unstructured. Use **role-based schemes** + **double progression**:

| Role | Scheme | Load feel | Examples |
|---|---|---|---|
| Primary compound (1 per day) | **4×5** (5th set optional top set) | Heavy, 2-3 reps in reserve | Incline DB Press, Weighted Pull-up, Bulgarian SS |
| Secondary compound | **3×8** | Moderate-heavy | Shoulder Press, Cable Row, RDL |
| Isolation / pump | **3×12–15** | Light-moderate, chase the burn | Flys, curls, pushdowns, calves |
| Explosive (legs day) | **4×3** | Max intent, NOT to failure | Box jumps, jump squats |

**Double progression rule (this is what the app enforces):**
- Work in a rep range (e.g. 3×8 means 8–10).
- Hit the top of the range on ALL sets → app flags **↑ WEIGHT** next session (+2.5kg upper / +5kg lower).
- No more guessing "↑ HEAVIER every 3 weeks" like the spreadsheet.

---

## 2. THE PROGRAM — Push / Pull / Legs (Mon / Wed / Fri)

### PUSH — Monday
- [ ] Incline DB Press — 4×5 (primary)
- [ ] Seated Shoulder Press — 3×8
- [ ] Weighted Dips — 3×8
- [ ] Cable Chest Fly — 3×12–15
- [ ] Overhead Tricep Ext — 3×12
- [ ] Tricep Pulldown — 3×12–15
- [ ] Rope 5 min + Sauna ✓/✗

### PULL — Wednesday
- [ ] Weighted Pull-ups — 4×5 (primary)
- [ ] Cable Row — 3×8
- [ ] Single-Arm DB Row — 3×10
- [ ] EZ Bar Curl — 3×10
- [ ] Cross-Body Hammer Curl — 3×12
- [ ] Rear Delt Fly — 3×15
- [ ] HIIT bike 15 min + Sauna ✓/✗

### LEGS — Friday
- [ ] Box Jump / Jump Squat — 4×3 (explosive first, fresh)
- [ ] Bulgarian Split Squat — 4×5/leg (primary)
- [ ] Romanian Deadlift — 3×8
- [ ] Leg Press — 3×10
- [ ] Calf Raises — 4×12–15
- [ ] Hanging Leg Raise — 3×12 · Ab Wheel — 3×10
- [ ] Rope 10 min + Sauna ✓/✗

> Sat arms finisher (post-class) stays optional as a saved "Extra" template: EZ Curl 3×12, Incline Curl 3×12, Pulldown 3×15, OH Ext 3×12.

---

## 3. FEATURE CHECKLIST

### Core — Workout Logging
- [ ] **Start Session** — pick template (Push/Pull/Legs/Extra) or empty session
- [ ] **Set logger** — per exercise: weight × reps, big wheel/number pickers (like screenshot), kg/lb toggle
- [ ] **Auto-prefill** — last session's weights shown as ghost values; one tap to repeat
- [ ] **↑ WEIGHT flag** — double progression engine tells you when to go heavier
- [ ] **Rest timer** — auto-starts after logging a set, notification when done
- [ ] **RPE / notes per set** — optional, quick emoji-level difficulty (😤 easy → 💀 grinder)
- [ ] **Session summary** — duration, tonnage (total kg lifted), PRs hit, checkmark day complete
- [ ] **Cardio + sauna checkmarks** — ✓/✗ per session (carries over the spreadsheet habit)

### Progress & Analytics
- [ ] **Per-exercise page** — chart of top-set weight, est. 1RM (Epley), total volume over time
- [ ] **Muscle group view** — weekly sets per muscle (chest/back/shoulders/arms/legs/core), volume trend, "least trained" flag
- [ ] **PR feed** — every new rep-PR or weight-PR logged automatically, celebratory moment
- [ ] **Consistency** — GitHub-style calendar heatmap, current streak, weekly adherence % (3/3 gym days)
- [ ] **Body weight trend** — log weight, 7-day moving average line vs strength progress

### Progress Photos
- [ ] **Photo capture/import** — front/side/back tags, taken in-app or from gallery
- [ ] **Timeline + compare** — slider comparison between any two dates
- [ ] **Private by default** — stored locally, synced encrypted-path to Firebase Storage

### Daily Metrics (dashboard)
- [ ] **Steps** — pulled from Apple Health (health package)
- [ ] **Water intake** — quick-add glasses (+250ml tap)
- [ ] **Calories/protein** — simple manual daily entry (no food DB — over-engineering)
- [ ] **Sleep hours** — from Apple Health or manual
- [ ] **Today card** — one glance: workout done?, steps, water, weight

### System
- [ ] **Offline-first** — local DB is source of truth; zero loading states in the gym
- [ ] **Firebase sync** — background push/pull when online (Firestore for data, Storage for photos)
- [ ] **Export** — CSV dump of all sessions (escape hatch, it's your data)
- [ ] **Apple Health import** on first run (weight, steps history)

---

## 4. SCREENS

1. **Home / Today** — today's workout card (Start button, neon accent), streak, quick stats row (steps · water · weight)
2. **Active Session** — exercise list with sets, wheel picker input, rest timer bar, finish button
3. **Progress** — tabs: Exercises · Muscle Groups · Body · Photos
4. **History** — calendar heatmap + session list, tap into any past session
5. **Photos** — grid timeline, compare mode
6. **Settings** — units, rest timer defaults, sync status, export

No onboarding flow needed (personal app) — just first-run: units + Apple Health permission.

---

## 5. UI DIRECTION (from your screenshots)

- Near-black background `#0A0A0F`, cards `#16161D`
- **One neon accent** — the lime/volt yellow from screenshot 2 (`#D4FF00`) for CTAs, checkmarks, PRs; gradient purple/blue kept only for charts
- Huge numerals for weight input (wheel picker, blurred neighbors — screenshot 1 style)
- Pill buttons, 16-20px radius cards, generous spacing
- Micro-interactions: haptic on set logged, confetti-ish flash on PR, smooth animated charts
- SF Pro / Inter, high contrast, minimal chrome

---

## 6. DATA MODEL (Firestore mirrors local)

```
exercises/{id}        → name, muscleGroup, scheme(role), repRangeMin/Max, incrementKg
templates/{id}        → name(Push/Pull/Legs), ordered exerciseIds
sessions/{id}         → date, templateId, durationMin, tonnage, cardioDone, saunaDone, notes
sessions/{id}/sets    → exerciseId, setNo, weightKg, reps, rpe, isPR
metrics/{date}        → weightKg, steps, waterMl, kcal, protein, sleepHrs
photos/{id}           → date, pose(front/side/back), localPath, storagePath, synced
```

Local: **Drift** (SQLite) — relational fits sets/sessions, easy charts queries. Sync layer: `synced` flag + updatedAt, push on connectivity, last-write-wins (single user = no conflicts).

## 7. TECH STACK

- Flutter (your usual), Riverpod
- Drift (local, source of truth)
- Firebase: Firestore + Storage, anonymous auth (single user)
- fl_chart (progress charts), health (steps/sleep/weight), image_picker + photo compression before upload

## 8. BUILD PHASES

- [ ] **P1 — Log & Progress (the app is useful here)**: templates, session logging, prefill, rest timer, per-exercise charts, local only
- [ ] **P2 — Sync + Photos**: Firebase sync, photo timeline + compare
- [ ] **P3 — Metrics & Polish**: daily metrics, Health integration, heatmap, PR feed, haptics/animations, CSV export
