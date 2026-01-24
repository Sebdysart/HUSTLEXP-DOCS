# PROJECT STATE — HUSTLEXP BUILD INDEX

**STATUS: AUTHORITATIVE**
**LAST UPDATED: 2026-01-24**
**PURPOSE: AI reads this FIRST to know exactly where we are**

---

## READ THIS BEFORE ANYTHING ELSE

This document tells you:
1. What are we building?
2. Where are we in the build?
3. What is locked (cannot change)?
4. What is the current focus?
5. What is the next legal action?

**If you don't know this information, you cannot produce correct output.**

---

## PRODUCT IDENTITY

| Field | Value |
|-------|-------|
| **Product Name** | HustleXP |
| **Type** | Local task marketplace (Uber meets TaskRabbit) |
| **Platforms** | iOS (React Native + Expo), Backend (tRPC + PostgreSQL) |
| **Brand Colors** | Black (#0B0B0F) + Purple (#5B2DFF) — NOT GREEN |
| **Design System** | iOS HIG + Glassmorphism + SF Pro |

---

## CURRENT BUILD PHASE

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                     PHASE: BOOTSTRAP (FRONTEND)                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  STATUS: IN PROGRESS                                                      ║
║  OWNER:  Cursor (Frontend Agent)                                          ║
║  GATE:   App must build + launch + render + not crash                     ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Phase Progression

```
[CURRENT] Bootstrap (Frontend)
          ↓ must pass before
          Phase 0: Schema Verification (Backend)
          ↓ must pass before
          Phase 1: Navigation Shell (Frontend)
          ↓ must pass before
          Phase 1: Core Services (Backend)
          ↓ ...continues
```

---

## WHAT IS LOCKED (CANNOT CHANGE)

### Features Locked
- **FEATURE_FREEZE.md active** — No new features
- **38 screens defined** — Cannot add screens
- **31 database tables defined** — Cannot add tables
- **33 invariants defined** — Cannot modify invariants

### Brand Identity Locked
- **Black + Purple only** — Green is SUCCESS-ONLY
- **Entry screens: Purple gradient** — NEVER green backgrounds
- **UAP-5 required** — Full-canvas composition (no card layouts)

### Design System Locked
- **PER/PER-33_DESIGN_TOKEN_AUTHORITY.md** — Token ownership
- **COLOR_SEMANTICS_LAW.md** — What colors MEAN
- **UI_ACCEPTANCE_PROTOCOL.md** — 5 UAP gates must pass

---

## CURRENT FOCUS

### Today's Focus (2026-01-24)
```
┌─────────────────────────────────────────────────────────────────────┐
│  GOAL: Pass Bootstrap Gate                                          │
│                                                                     │
│  SUCCESS CRITERIA:                                                  │
│  [ ] App builds in Xcode without errors                             │
│  [ ] App launches in iOS Simulator without crashing                 │
│  [ ] EntryScreen renders with purple brand                          │
│  [ ] "Get Started" button visible and tappable                      │
│  [ ] No crashes for 30 seconds idle                                 │
│  [ ] Colors match COLOR_SEMANTICS_LAW.md                            │
│                                                                     │
│  FORBIDDEN:                                                         │
│  - Network requests                                                 │
│  - Navigation to other screens                                      │
│  - Maps or location services                                        │
│  - New dependencies                                                 │
│  - Any screen other than EntryScreen                                │
└─────────────────────────────────────────────────────────────────────┘
```

### Reference Files for Current Focus
| File | Purpose |
|------|---------|
| `BOOTSTRAP.md` | Success criteria (authoritative) |
| `reference/components/EntryScreen.js` | Copy this, not minimal patterns |
| `reference/constants/colors.js` | Authoritative color tokens |
| `COLOR_SEMANTICS_LAW.md` | What colors mean |
| `PER/UI_ACCEPTANCE_PROTOCOL.md` | UAP gates |

---

## NEXT LEGAL ACTION

### What You CAN Do Right Now
1. Create/edit EntryScreen to pass Bootstrap criteria
2. Fix build errors in Xcode
3. Fix crashes in iOS Simulator
4. Verify colors match specification

### What You CANNOT Do Right Now
- Add new screens (BLOCKED until Bootstrap passes)
- Add navigation (BLOCKED until Bootstrap passes)
- Add backend calls (BLOCKED until Bootstrap passes)
- Add maps/SVG (BLOCKED until Bootstrap passes)
- Add new dependencies (BLOCKED until Bootstrap passes)
- Modify invariants (NEVER allowed)
- Add new features (FEATURE_FREEZE active)

---

## FRONTEND STATUS

### App Structure
```
hustlexp-app/
├── App.tsx                    → Entry point (renders EntryScreen)
├── screens/
│   └── EntryScreen.tsx        → The ONLY screen for Bootstrap
├── package.json               → Dependencies (DO NOT ADD)
└── ios/                       → Native iOS project
```

### Screen Registry (38 total, 0 implemented)
| Phase | Screen | Status |
|-------|--------|--------|
| Bootstrap | EntryScreen | IN PROGRESS |
| Phase 1 | All others | BLOCKED |

### iOS Native (15 SwiftUI screens synced)
- **Location:** `ios-swiftui/HustleXP/Sources/Screens/`
- **Status:** Synced with React Native specs
- **Authority:** STITCH HTML files are source of truth

---

## BACKEND STATUS

### Current Phase: WAITING
Backend work is BLOCKED until Frontend Bootstrap passes.

### Database Schema
- **31 tables defined** in `specs/02-architecture/schema.sql`
- **33 invariants defined** in `PER/INVARIANTS.md`
- **24 kill tests required** (not yet implemented)

### API Status
- **tRPC routers:** Defined in spec, not implemented
- **Endpoints:** 0 implemented

---

## QUALITY GATES

### UAP (UI Acceptance Protocol) — 5 Gates

| Gate | Name | Status |
|------|------|--------|
| UAP-1 | Design Token Compliance | Must pass |
| UAP-2 | 300ms Polish Gate | Must pass |
| UAP-3 | Accessibility Baseline | Must pass |
| UAP-4 | Empty/Error State Audit | Must pass |
| UAP-5 | Full-Canvas Immersion | **CRITICAL for Entry** |

### Color Semantics Gate

| Context | Required Color |
|---------|---------------|
| Entry/Welcome screens | Black + Purple |
| Success states | Green (ONLY after success) |
| Errors | Red |
| Warnings | Orange |
| Information | Blue |

---

## ERROR RECOVERY

### If Build Fails
1. Read exact error message
2. Do NOT add dependencies to fix
3. Check `CRASH_PROTOCOL.md`
4. Report to user if stuck

### If Stuck > 60 Minutes
1. Trigger `PER/OMEGA_PROTOCOL.md`
2. AI loses autonomy
3. Human takes control

### Last Known Good
- **Commit:** See `PER/LAST_KNOWN_GOOD.md`
- **Recovery:** `git checkout <commit>`

---

## INVARIANTS SUMMARY

### Core Financial (5)
- INV-1: XP requires RELEASED escrow
- INV-2: RELEASED escrow requires COMPLETED task
- INV-3: COMPLETED task requires ACCEPTED proof
- INV-4: Escrow amount is IMMUTABLE
- INV-5: One XP entry per escrow

### Eligibility (8)
- Trust tier → risk clearance mapping
- Verified trades require active verification
- Expired credentials invalidate capabilities
- See `PER/INVARIANTS.md` for full list

### Architectural (4)
- Layer N cannot bypass Layer N-1
- Only Layer 0 enforces invariants
- AI cannot write to Layer 0
- UI cannot call Layer 0 directly

### Total: 33 invariants, all mechanically enforced

---

## AUTHORITY HIERARCHY

```
Layer 0: PostgreSQL (triggers, constraints)           ← ENFORCES
Layer 1: Backend Services (tRPC)                      ← VALIDATES
Layer 2: API Gateway (rate limits, auth)              ← GUARDS
Layer 3: AI Services (proposals only)                 ← PROPOSES
Layer 4: Frontend Logic (state management)            ← DERIVES
Layer 5: UI Components (rendering)                    ← DISPLAYS
Layer 6: Native Shell (iOS/Android)                   ← HOSTS
```

---

## QUICK START FOR AI

### Step 1: Confirm Phase
You are in **BOOTSTRAP** phase. Only EntryScreen work is allowed.

### Step 2: Confirm Colors
- Brand: Black (#0B0B0F) + Purple (#5B2DFF)
- Entry screens: Purple gradient, NOT green
- Green: SUCCESS-ONLY (never on entry)

### Step 3: Confirm Pattern
- Copy `reference/components/EntryScreen.js`
- Do NOT copy minimal patterns
- UAP-5 (Full-Canvas) is REQUIRED

### Step 4: Check Constraints
- No network requests
- No new screens
- No new dependencies
- Must pass Bootstrap criteria

### Step 5: Output
Only produce work that passes:
1. Bootstrap success criteria
2. UAP-5 Full-Canvas Immersion
3. COLOR_SEMANTICS_LAW compliance

---

## DOCUMENT QUICK LINKS

| Need | Document |
|------|----------|
| Bootstrap criteria | `BOOTSTRAP.md` |
| Color rules | `COLOR_SEMANTICS_LAW.md` |
| UI gates | `PER/UI_ACCEPTANCE_PROTOCOL.md` |
| What's forbidden | `PER/DO_NOT_TOUCH.md` |
| All invariants | `PER/INVARIANTS.md` |
| Recovery protocol | `PER/OMEGA_PROTOCOL.md` |
| Component reference | `reference/components/EntryScreen.js` |
| Color tokens | `reference/constants/colors.js` |

---

**This document is the first thing AI should read when entering this repo.**
**If the AI doesn't know this information, it cannot produce correct output.**
