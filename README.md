# HustleXP Product Requirements Repository

> **The single source of truth for building HustleXP v1.0**

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

**Nothing proceeds until Bootstrap passes.**

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
1. .cursorrules              ← ENFORCEMENT (not guidance)
2. FINISHED_STATE.md         ← What the product IS
3. SCREEN_FEATURE_MATRIX.md  ← What each screen does
4. BOOTSTRAP.md              ← Your ONLY task right now
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

## 📁 Repository Structure

```
HUSTLEXP-DOCS/
│
├── 🔒 PRODUCT DEFINITION (Frozen)
│   ├── FINISHED_STATE.md         ← What "done" means
│   ├── FEATURE_FREEZE.md         ← No new features
│   ├── AI_GUARDRAILS.md          ← AI behavior rules
│   └── SCREEN_FEATURE_MATRIX.md  ← What each screen does/doesn't do
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

## 🔐 The Rules

### Rule 1: Product is Frozen
- 38 screens defined (no more)
- 32 tables defined (no more)
- Features listed in FINISHED_STATE.md (no more)

### Rule 2: AI Executes, Not Designs
- Claude Code: Layers 0-2 only
- Cursor: UI shells only, no business logic
- Both: No inventing features

### Rule 3: Sequential Phases
- Bootstrap must pass first
- Then Phase 0, then Phase 1, etc.
- No skipping

### Rule 4: Stop on Uncertainty
- If unclear, STOP and ASK
- Do not guess
- Do not "help" by filling gaps

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

---

## 🔗 Related Repositories

| Repository | Purpose |
|------------|---------|
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Backend services |
| [hustlexp-app](https://github.com/Sebdysart/hustlexp-app) | React Native app |

---

## 👤 Contact

**Owner:** Sebastian Dysart  
**Project:** HustleXP v1.0

---

**The product is defined. The scope is frozen. Build exactly this.**
