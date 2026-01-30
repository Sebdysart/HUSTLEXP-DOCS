# HustleXP Product Requirements Repository

> **The single source of truth for building HustleXP v1.0**

---

## 🧠 EXECUTION MENTAL MODEL (NON-NEGOTIABLE)

```
HustleXP UI is built as a PUZZLE, not as isolated screens.

┌─────────────────────────────────────────────────────────────┐
│  SCREENS    — Assembly ONLY (no invention allowed)          │
├─────────────────────────────────────────────────────────────┤
│  SECTIONS   — Narrative regions (header, content, actions)  │
├─────────────────────────────────────────────────────────────┤
│  MOLECULES  — Combinations of atoms (cards, forms, lists)   │
├─────────────────────────────────────────────────────────────┤
│  ATOMS      — Primitive elements (buttons, inputs, text)    │
└─────────────────────────────────────────────────────────────┘

RULES:
- Atoms are LOCKED once approved
- Molecules are LOCKED once approved
- Screens ASSEMBLE existing pieces — they do NOT invent new visuals
- If you need something new → create it at Atom/Molecule layer FIRST

Cursor is FORBIDDEN from inventing new visuals at the Screen level.
```

📋 **[UI_COMPONENT_HIERARCHY.md](UI_COMPONENT_HIERARCHY.md)** — Full hierarchy spec

---

## 🎯 SCREEN ARCHETYPE ROUTING (MANDATORY)

**All screens belong to an ARCHETYPE. Identify the archetype BEFORE implementation.**

| Archetype | Purpose | Screens |
|-----------|---------|---------|
| **A. Entry/Commitment** | User decides to engage | Login, Signup, Role Selection |
| **B. Feed/Opportunity** | User discovers options | Task Feed, History |
| **C. Task Lifecycle** | Active work flow | Task Detail, In Progress, Proof |
| **D. Calibration/Capability** | User configures self | Onboarding, Verification, Settings |
| **E. Progress/Status** | User sees standing | XP Breakdown, Trust Tier, Earnings |
| **F. System/Interrupt** | System communicates | Errors, Maintenance, Force Update |

```
Cursor may NOT treat screens as unique design problems.
Screens inherit visuals, motion, and hierarchy from their archetype.

If archetype is unclear → STOP and ask.
```

📋 **[SCREEN_ARCHETYPES.md](SCREEN_ARCHETYPES.md)** — Full archetype specs

---

## ✨ CHOSEN-STATE REQUIREMENT (GLOBAL)

```
All Entry, Feed, and Onboarding screens must imply:

✅ The user is ALREADY selected
✅ The system is ALREADY active  
✅ A successful outcome is LIKELY or GUARANTEED

FORBIDDEN:
❌ Empty states that feel like "starting from zero"
❌ Neutral or tentative language
❌ UI that makes the user feel unqualified

If a screen feels like "starting from zero" → it FAILS quality review.
```

---

## ⚠️ PRODUCT IS FROZEN

| Document | Purpose | Status |
|----------|---------|--------|
| **[FINISHED_STATE.md](FINISHED_STATE.md)** | What "done" means | 🔒 FROZEN |
| **[FEATURE_FREEZE.md](FEATURE_FREEZE.md)** | No new features | 🔒 ACTIVE |
| **[AI_GUARDRAILS.md](AI_GUARDRAILS.md)** | AI behavior rules | 🔒 ACTIVE |
| **[SCREEN_FEATURE_MATRIX.md](SCREEN_FEATURE_MATRIX.md)** | What each screen does | 🔒 FROZEN |

**No feature may be added without modifying FINISHED_STATE.md first.**

---

## ⚠️ CURRENT PHASE: BOOTSTRAP

**Ready for MVP: CONDITIONAL (per CURRENT_PHASE.md)**

| Check | Status |
|-------|--------|
| App builds in Xcode | ❌ |
| App launches without crash | ❌ |
| BootstrapScreen renders | ❌ |
| Button logs to console | ❌ |
| 30-second stability | ❌ |

📋 **[BOOTSTRAP.md](BOOTSTRAP.md)** — The runtime baseline  
📋 **[CURRENT_PHASE.md](CURRENT_PHASE.md)** — What's allowed right now

---

## 🚀 Quick Start

### For Cursor (Frontend)
```
READ IN ORDER:
1. EXECUTION_QUEUE.md        ← Find next step, execute ONLY that
2. STOP_CONDITIONS.md        ← Know when to STOP
3. .cursorrules              ← ENFORCEMENT (not guidance)
4. SCREEN_ARCHETYPES.md      ← Which archetype is this screen?
5. UI_COMPONENT_HIERARCHY.md ← What atoms/molecules exist?
```

### For Claude Code (Backend)
```
READ IN ORDER:
1. .claude/instructions.md   ← ENFORCEMENT (not guidance)
2. FINISHED_STATE.md         ← What the product IS
3. AI_GUARDRAILS.md          ← Your behavior rules
4. CURRENT_PHASE.md          ← Wait for frontend bootstrap
```

---

## 🔐 The Rules

### Rule 1: Product is Frozen
- 38 screens defined (no more)
- 32 tables defined (no more)
- Features listed in FINISHED_STATE.md (no more)

### Rule 2: AI Executes, Not Designs
- Cursor: Assembles from existing atoms/molecules — NO invention
- Claude Code: Layers 0-2 only
- Both: No inventing features

### Rule 3: Archetype First
- Identify screen archetype BEFORE implementation
- Inherit visuals from archetype
- Do NOT treat screens as unique design problems

### Rule 4: Chosen-State Always
- Users feel selected, not tested
- System feels active, not waiting
- Outcomes feel likely, not uncertain

### Rule 5: Stop on Uncertainty
- If unclear, STOP and ASK
- Do not guess
- Do not "help" by filling gaps

---

## 📁 Repository Structure

```
HUSTLEXP-DOCS/
│
├── 🧠 EXECUTION MODEL
│   ├── EXECUTION_QUEUE.md        ← Step-by-step build sequence
│   ├── STOP_CONDITIONS.md        ← When to stop building
│   ├── FRONTEND_BUILD_MAP.json   ← Machine-readable dependencies
│   ├── UI_COMPONENT_HIERARCHY.md ← Atoms → Molecules → Screens
│   └── SCREEN_ARCHETYPES.md      ← Screen categories
│
├── 🔒 PRODUCT DEFINITION (Frozen)
│   ├── FINISHED_STATE.md         ← What "done" means
│   ├── FEATURE_FREEZE.md         ← No new features
│   ├── AI_GUARDRAILS.md          ← AI behavior rules
│   └── SCREEN_FEATURE_MATRIX.md  ← What each screen does
│
├── 🚨 PHASE CONTROL
│   ├── BOOTSTRAP.md              ← Runtime baseline
│   └── CURRENT_PHASE.md          ← Current phase gate
│
├── 🤖 AI ENFORCEMENT
│   ├── .cursorrules              ← Cursor hard constraints
│   └── .claude/instructions.md   ← Claude Code hard constraints
│
├── 📚 SPECIFICATIONS
│   └── specs/
│       ├── 00-overview/          ← Quick start
│       ├── 01-product/           ← Product specs
│       ├── 02-architecture/      ← Backend specs
│       ├── 03-frontend/          ← UI specs
│       └── 04-backend/           ← Build phases
│
├── 📱 SCREEN SPECIFICATIONS
│   └── screens-spec/
│       ├── SCREEN_REGISTRY.md    ← All 38 screens
│       └── [category]/           ← Per-category specs
│
├── 🤖 prompts/                   ← AI execution prompts
├── 📊 tracking/                  ← Implementation status
├── 📦 reference/                 ← Scaffold code
└── 🗄️ _archive/                  ← Historical specs
```

---

## 📱 Product Summary (v1.0)

### Includes:
- ✅ Core marketplace (task lifecycle)
- ✅ Trust & eligibility system
- ✅ Messaging (in-task)
- ✅ Maps & location (EN_ROUTE only)
- ✅ Disputes & safety
- ✅ Notifications (push + email)
- ✅ Ratings (1-5 stars)
- ✅ Admin operations

### Does NOT Include (v2+):
- ❌ AI task suggestions
- ❌ Smart pricing
- ❌ Gamified streaks
- ❌ Text reviews
- ❌ Tipping
- ❌ Recurring tasks
- ❌ Team tasks
- ❌ Video proof

**Full list: [FINISHED_STATE.md](FINISHED_STATE.md)**

---

## 📊 Counts (Frozen)

| Artifact | Count | Status |
|----------|-------|--------|
| Screens | 38 | 🔒 Frozen |
| Tables | 32 | 🔒 Frozen |
| Views | 4 | 🔒 Frozen |
| Invariants | 5 | 🔒 Frozen |
| Archetypes | 6 | 🔒 Frozen |

---

## 🔗 Related Repositories

| Repository | Purpose |
|------------|---------|
| [HUSTLEXPFINAL1](https://github.com/Sebdysart/HUSTLEXPFINAL1) | **React Native Frontend (ACTIVE)** |
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Backend services |

---

## 👤 Contact

**Owner:** Sebastian Dysart  
**Project:** HustleXP v1.0

---

**The product is defined. The scope is frozen. Assemble from existing pieces. Build exactly this.**
