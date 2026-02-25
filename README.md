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
| App builds in Xcode | ✅ |
| App launches without crash | ✅ |
| BootstrapScreen renders | ✅ |
| Button logs to console | ✅ |
| 30-second stability | ✅ |

📋 **[BOOTSTRAP.md](BOOTSTRAP.md)** — The runtime baseline  
📋 **[CURRENT_PHASE.md](CURRENT_PHASE.md)** — What's allowed right now

---

## 🚀 Quick Start

### For AI Assistants (NEW! Start Here)
```
FAST ONBOARDING:
1. AI_QUICK_START.md         ← 5-minute orientation (start here)
2. CLAUDE.md                 ← Full AI instructions for this repo
3. SLOP_AUDIT_REPORT.md      ← Known issues to avoid
4. SPECIFICATION_INDEX.json  ← Machine-readable manifest

Then proceed to role-specific quick starts below.
```

### For Cursor (Frontend)
```
READ IN ORDER:
1. EXECUTION_QUEUE.md        ← Find next step, execute ONLY that
2. SCREEN_ARCHETYPES.md      ← Which archetype is this screen?
3. UI_COMPONENT_HIERARCHY.md ← What atoms/molecules exist?
4. STOP_CONDITIONS.md        ← Know when to STOP
5. .cursorrules              ← ENFORCEMENT (not guidance)
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
├── 🤖 AI OPTIMIZATION (NEW!)
│   ├── CLAUDE.md                 ← AI assistant instructions (P0)
│   ├── AI_QUICK_START.md         ← 5-minute AI onboarding
│   ├── SLOP_AUDIT_REPORT.md      ← Known issues & fixes
│   ├── SPECIFICATION_INDEX.json  ← Machine-readable manifest
│   └── DOCS_CHANGELOG.md         ← Documentation change log
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
│       ├── 00-overview/          ← Quick Start guide
│       ├── 01-product/           ← Product spec, onboarding, features
│       ├── 02-architecture/      ← Architecture, schema.sql, subsystems/ (10 LOCKED)
│       ├── 03-frontend/          ← UI spec, stitch prompts, components
│       └── 04-backend/           ← API contract, Stripe, matching, storage
│
├── 📱 SCREEN SPECIFICATIONS
│   └── screens-spec/             ← SCREEN_REGISTRY + per-screen specs
│
├── 🧩 UI PUZZLE MODEL
│   └── ui-puzzle/                ← atoms/, molecules/, sections/, screens/, tokens/
│
├── ⚙️ AUTHORITY & ENFORCEMENT (Top-Level)
│   ├── AI_CHECKPOINTS.md         ← Enforcement gates
│   ├── ARCHETYPE_MOLECULE_MATRIX.md ← Archetype-to-molecule binding
│   ├── COLOR_AUTHORITY_RESOLUTION.md ← Color system authority
│   ├── COLOR_SEMANTICS_LAW.md    ← Color semantic rules (13 refs)
│   ├── CURSOR_INSTRUCTIONS.md    ← Cursor behavior rules (7 refs)
│   ├── TYPOGRAPHY_AUTHORITY_RESOLUTION.md ← Type system authority
│   ├── NAVIGATION_ARCHITECTURE.md ← Nav structure
│   ├── TASK_CREATION_STATE_MACHINE.md ← Task creation flow
│   ├── TASK_CLARIFICATION_QUESTION_BANK.md ← Question bank for tasks
│   └── TASK_EXECUTION_REQUIREMENTS.md ← Task execution rules
│
├── 📊 tracking/                  ← Implementation status + historical audits
├── 📦 reference/                 ← Scaffold code
├── 📂 staging/                   ← Stub specs (post-v1) + SUPERSEDED redirects
├── 📂 PER/                       ← Persistent Execution Rails (legacy framework)
├── 📂 prompts/                   ← Prompt templates
└── 📂 archive/                   ← Retired files (0 active references)
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

### 🔒 LOCKED Subsystem Architecture (specs/02-architecture/subsystems/)

| Subsystem | File | Lines |
|-----------|------|-------|
| Judge Agent (Proof Verification) | `JUDGE_AGENT_SPEC_LOCKED.md` | 750+ |
| Risk & Trust Engine | `RISK_TRUST_ENGINE_LOCKED.md` | 1,096 |
| Risk Classifier (Task Creation) | `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` | 400+ |
| Capability Profile Schema | `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` | 600+ |
| Capability Onboarding (UX) | `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` | 1,042 |
| Capability Onboarding (Backend) | `CAPABILITY_ONBOARDING_AND_FEED_FILTERING_LOCKED.md` | 838 |
| Feed Eligibility Resolver | `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` | 500+ |
| Verification Pipeline | `VERIFICATION_PIPELINE_LOCKED.md` | 400+ |
| Verification Payment UX | `VERIFICATION_PAYMENT_UX_AND_COPY_LOCKED.md` | 400+ |
| Settings & Verification | `SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` | 400+ |

**Full list: [FINISHED_STATE.md](FINISHED_STATE.md)**

---

## 📊 Counts (Frozen)

| Artifact | Count | Status |
|----------|-------|--------|
| Screens | 32 | 🔒 Frozen (v1.0 simplified onboarding) |
| Tables (schema.sql) | 20 | 🔒 Frozen |
| Tables (migrations) | 21 | 🔒 Frozen |
| Tables (Total) | 41 | 🔒 Frozen |
| LOCKED Subsystems | 10 | 🔒 Frozen |
| Views | 4 | 🔒 Frozen |
| Invariants | 5+ | 🔒 Frozen |
| Archetypes | 6 | 🔒 Frozen |
| Trust Tiers | 5 | 🔒 Frozen (ROOKIE → VERIFIED → TRUSTED → ELITE → MASTER) |

---

## 🔗 Related Repositories

| Repository | Purpose |
|------------|---------|
| [HUSTLEXPFINAL1](https://github.com/Sebdysart/HUSTLEXPFINAL1) | **iOS App — Swift/SwiftUI (ACTIVE)** |
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Backend services |

---

## 👤 Contact

**Owner:** Sebastian Dysart  
**Project:** HustleXP v1.0

---

**The product is defined. The scope is frozen. Assemble from existing pieces. Build exactly this.**
