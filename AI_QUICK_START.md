# AI QUICK START — 5-Minute Onboarding for HustleXP

> **Get up to speed in 5 minutes. Everything you need to start working with HUSTLEXP-DOCS.**

---

## ⚡ Ultra-Quick Reference

```
Repo Type:       Documentation/Specifications (NOT implementation code)
Product Status:  FROZEN — 38 screens, 41 tables, v1.0 MVP scope locked
Your Role:       Execute specs exactly, do NOT invent features
Architecture:    7-layer model (Layer 0 = Database, Layer 6 = Human)
UI System:       Puzzle model (Atoms → Molecules → Sections → Screens)
Enforcement:     .cursorrules (frontend), .claude/instructions.md (backend)
```

---

## 🎯 The 5-Minute Path

### Minute 1: Understand What This Is
```
✅ This is HUSTLEXP-DOCS: Specification repository
✅ Product: HustleXP — Task marketplace with trust system
✅ Scope: FROZEN at v1.0 MVP (38 screens, 41 database tables)
✅ Your job: Improve docs, fix references, add machine-readable manifests
❌ NOT your job: Implement features, invent specs, add to frozen scope
```

**Read:** `README.md` (lines 1-100 for overview)

### Minute 2: Know What's Frozen
```
🔒 38 Screens (A1-A3, H1-H14, P1-P4, O1-O12, E1-E6, S1-S9, F1-F4)
🔒 41 Database Tables (users, tasks, escrows, proofs, xp_ledger, etc.)
🔒 5 Core Invariants (XP requires released escrow, etc.)
🔒 9 Atoms (Button, Text, Input, Icon, Avatar, Badge, Divider, Spacer, Image)
🔒 12 Molecules (TaskCard, UserHeader, PriceDisplay, etc.)
🔒 6 Archetypes (A-F: Entry, Feed, Task, Calibration, Progress, System)
```

**Read:** `FINISHED_STATE.md` (product boundary)
**Read:** `FEATURE_FREEZE.md` (what you CANNOT do)

### Minute 3: Learn Your Role
```
Are you working on:
├─ Frontend implementation? → Read .cursorrules (450 lines)
├─ Backend implementation?  → Read .claude/instructions.md (390 lines)
└─ Documentation only?      → Read CLAUDE.md (this repo's AI guide)
```

**Key rule:** Frontend and backend have DIFFERENT rules. Do not confuse them.

### Minute 4: Understand the Architecture

**7-Layer Model:**
```
Layer 0: Database (PostgreSQL + PostGIS)
         - Enforces 5 invariants via triggers
         - Single source of truth
         - NO bypassing for money operations

Layer 1: Backend Services
         - Business logic orchestration
         - State transitions through database

Layer 2: API (tRPC)
         - Exposes endpoints to frontend
         - Validates all input

Layer 3: AI Systems
         - PROPOSAL ONLY, no decisions
         - AI suggests, deterministic systems decide

Layer 4: Frontend Logic
         - NO business logic allowed
         - Receives computed values from backend

Layer 5: UI/Animation
         - Presentation only
         - Assemble from atoms/molecules

Layer 6: Human Override
         - Final authority
```

**UI Puzzle Model:**
```
SCREENS    ← Assemble from sections (NO invention)
  ↓
SECTIONS   ← Assemble from molecules (header, content, footer)
  ↓
MOLECULES  ← Combine atoms (cards, forms, lists)
  ↓
ATOMS      ← Primitives (buttons, text, inputs) [LOCKED]
```

**Read:** `specs/02-architecture/ARCHITECTURE.md` §1-3
**Read:** `UI_COMPONENT_HIERARCHY.md`

### Minute 5: Know Where to Look

| I need... | Read... |
|-----------|---------|
| List of all screens | `screens-spec/SCREEN_REGISTRY.md` |
| Database schema | `specs/02-architecture/schema.sql` |
| What screens do | `SCREEN_FEATURE_MATRIX.md` |
| UI components | `ui-puzzle/atoms/ATOM_REGISTRY.md` + `ui-puzzle/molecules/MOLECULE_REGISTRY.md` |
| Build sequence (frontend) | `EXECUTION_QUEUE.md` |
| Build sequence (backend) | `specs/04-backend/BUILD_GUIDE.md` |
| Core invariants | `PER/INVARIANTS.md` |
| Current build phase | `CURRENT_PHASE.md` |
| What's forbidden | `FEATURE_FREEZE.md` |

---

## 🚨 Top 5 Rules (Never Break These)

### Rule 1: Product is FROZEN
```
❌ Do NOT add features beyond FINISHED_STATE.md
❌ Do NOT add screens beyond the frozen 38
❌ Do NOT add tables beyond the frozen 41
✅ Check FEATURE_FREEZE.md before ANY changes
```

### Rule 2: Respect Layer Boundaries
```
❌ Frontend: No business logic (eligibility, XP calc, pricing)
❌ Backend: No UI concerns (layouts, styling, animations)
❌ AI: Proposes only, does NOT decide
✅ Each layer owns specific concerns
```

### Rule 3: Puzzle Model is Law
```
❌ Do NOT invent new visuals at Screen level
❌ Do NOT create inline styled components
❌ Do NOT duplicate molecules with variations
✅ Screens ASSEMBLE from existing atoms/molecules
✅ If you need something new → create at lower layer FIRST
```

### Rule 4: Invariants are Non-Negotiable
```
The 5 invariants are enforced by database triggers:
INV-1: XP requires RELEASED escrow
INV-2: RELEASED escrow requires COMPLETED task
INV-3: COMPLETED task requires ACCEPTED proof
INV-4: Escrow amount is IMMUTABLE
INV-5: One XP entry per escrow

❌ Do NOT bypass these in business logic
❌ Do NOT "optimize" by skipping steps
✅ Trust the database to enforce
```

### Rule 5: When Unsure, STOP and ASK
```
🛑 Unclear which archetype a screen belongs to?
🛑 Need a component that doesn't exist?
🛑 Spec seems wrong or contradictory?
🛑 Want to "improve" something?
🛑 Need to add beyond frozen scope?

→ STOP, do NOT guess, ASK the user
```

---

## 🧠 Mental Models (Memorize These)

### The Task Lifecycle Chain
```
Task Created → Escrow Funded → Work Done → Proof Accepted → Escrow Released → XP Awarded
     ↓              ↓              ↓              ↓               ↓              ↓
  POSTED        FUNDED         ACCEPTED        PROOF         RELEASED       XP_LEDGER
```
**Every arrow is enforced. You CANNOT skip steps.**

### The Archetype System (A-F)
```
A = Entry/Commitment    (Login, Signup, Role Selection)
B = Feed/Opportunity    (Task Feed, History)
C = Task Lifecycle      (Detail, In Progress, Proof)
D = Calibration         (Onboarding, Settings, Verification)
E = Progress/Status     (Home, Profile, XP, Trust Tier)
F = System/Interrupt    (Errors, Maintenance, Force Update)
```
**Screens inherit patterns from their archetype. Do NOT treat as unique design problems.**

### The Chosen-State Principle
```
All screens must make users feel:
✅ ALREADY SELECTED (not being tested)
✅ SYSTEM IS ACTIVE (not waiting)
✅ SUCCESS IS LIKELY (not uncertain)

❌ FORBIDDEN:
- Empty states feeling like "starting from zero"
- Neutral or tentative language
- UI making user feel they might fail
```

---

## 📋 Common AI Tasks (Quick Recipes)

### Task: Fix Broken Cross-References
```bash
1. Search for `§` notation (e.g., "ARCHITECTURE.md §5.3")
2. Verify target file and section exist
3. Update reference or report missing target
4. Do NOT invent sections to satisfy references
```

### Task: Create Machine-Readable Manifest
```bash
1. Scan relevant markdown files
2. Extract structured data (paths, counts, dependencies)
3. Create JSON with exact file references
4. Validate against frozen counts
```

### Task: Resolve Contradictory Specs
```bash
1. Identify conflicting definitions
2. Report with file:line references
3. Quote both definitions
4. ASK which is authoritative
5. Do NOT merge or guess
```

### Task: Audit for AI Slop
```bash
Search for:
- Placeholder text: "TODO", "[TBD]", "Lorem ipsum", "Example here"
- AI phrases: "It's worth noting", "Let's dive in", "In today's"
- Broken references: § links to non-existent sections
- Missing files: Referenced but don't exist
- Orphaned files: Exist but not referenced anywhere
- Contradictions: Same thing defined differently
```

### Task: Add Documentation
```bash
1. Read existing style and format
2. Follow § notation for cross-references
3. Use status markers: 🔒 FROZEN, ✅ DONE, ⚠️ BLOCKED
4. Do NOT change technical content without approval
5. Preserve frozen counts (38 screens, 41 tables, etc.)
```

---

## 🔍 Fast Lookups (Bookmark These)

### File Paths (Critical Documents)
```
Overview:           README.md, CLAUDE.md, FINISHED_STATE.md
Enforcement:        .cursorrules, .claude/instructions.md, FEATURE_FREEZE.md
Architecture:       specs/02-architecture/ARCHITECTURE.md
Database:           specs/02-architecture/schema.sql
Invariants:         PER/INVARIANTS.md
UI System:          UI_COMPONENT_HIERARCHY.md, SCREEN_ARCHETYPES.md
Screens Registry:   screens-spec/SCREEN_REGISTRY.md
Component Lists:    ui-puzzle/atoms/ATOM_REGISTRY.md, ui-puzzle/molecules/MOLECULE_REGISTRY.md
Build Sequence:     EXECUTION_QUEUE.md (frontend), specs/04-backend/BUILD_GUIDE.md (backend)
Current Phase:      CURRENT_PHASE.md
```

### Frozen Counts (Validate Against These)
```
Screens:       38 (A1-A3, H1-H14, P1-P4, O1-O12, E1-E6, S1-S9, F1-F4)
Tables:        41 (users, tasks, escrows, proofs, messages, xp_ledger, etc.)
Atoms:         9  (Button, Text, Input, Icon, Avatar, Badge, Divider, Spacer, Image)
Molecules:     12 (TaskCard, UserHeader, PriceDisplay, RatingStars, ProgressBar, etc.)
Sections:      5  (ScreenHeader, ContentScroll, ActionFooter, etc.)
Archetypes:    6  (A-F)
Trust Tiers:   5  (ROOKIE → VERIFIED → TRUSTED → ELITE → MASTER)
Invariants:    5  (INV-1 through INV-5)
```

### Error Codes
```
HX101: xp_requires_released_escrow (INV-1)
HX201: escrow_released_requires_completed_task (INV-2)
HX301: task_completed_requires_accepted_proof (INV-3)
HX401: escrow_amount_immutable (INV-4)
HX501: duplicate_xp_entry (INV-5)
```

---

## ⚠️ Common Mistakes (Avoid These)

### Mistake 1: Confusing Repositories
```
❌ HUSTLEXP-DOCS = Specifications (this repo)
❌ HUSTLEXPFINAL1 = Frontend implementation
❌ hustlexp-ai-backend = Backend implementation

These are DIFFERENT repos with DIFFERENT rules.
```

### Mistake 2: Inventing Features
```
❌ "I'll add a 'save for later' feature"
❌ "Let me improve this by adding..."
❌ "This would be better with..."

✅ "Feature X is not in FINISHED_STATE.md. Should I stop?"
```

### Mistake 3: Bypassing Invariants
```
❌ Calculating XP on frontend
❌ Checking eligibility on frontend
❌ Modifying escrow amounts
❌ Skipping proof acceptance step

✅ Let backend compute all values
✅ Let database enforce invariants
```

### Mistake 4: Treating Screens as Unique
```
❌ "This screen needs a custom card design"
❌ "Let me create a new button variant"
❌ "I'll add some inline styles here"

✅ Identify archetype first
✅ Use existing molecules
✅ Assemble from atoms
```

### Mistake 5: Guessing When Unclear
```
❌ Proceeding with assumptions
❌ "Probably means..."
❌ Filling gaps with invented content

✅ STOP and ASK
✅ Quote exact confusion point
✅ Wait for clarification
```

---

## 🎯 Success Checklist

You're ready to work when you can answer:

```
[ ] What repository am I in? (DOCS, frontend impl, or backend impl?)
[ ] What is my role? (Frontend, Backend, or Documentation?)
[ ] What file contains my enforcement rules?
[ ] How many screens are frozen? (38)
[ ] How many database tables are frozen? (41)
[ ] What are the 5 core invariants?
[ ] What are the 6 screen archetypes (A-F)?
[ ] What is the puzzle model? (Atoms → Molecules → Sections → Screens)
[ ] What is the chosen-state principle?
[ ] Where do I look up screens? (screens-spec/SCREEN_REGISTRY.md)
[ ] Where do I look up components? (ui-puzzle/.../REGISTRY.md files)
[ ] Where do I look up database schema? (specs/02-architecture/schema.sql)
[ ] What do I do when unsure? (STOP and ASK)
```

**If you can answer all of these, you're ready to start.**

---

## 🚀 Next Steps

### If You're Working on Documentation:
1. Read `CLAUDE.md` (full AI instructions for this repo)
2. Scan `README.md` for repository structure
3. Check `tracking/EXECUTION_INDEX.md` for implementation status
4. Look for broken references, contradictions, or AI slop

### If You're Working on Frontend Implementation:
1. Switch to **HUSTLEXPFINAL1** repository (NOT this one)
2. Read `.cursorrules` (450 lines of frontend enforcement)
3. Read `EXECUTION_QUEUE.md` to find next step
4. Identify screen archetype before implementing

### If You're Working on Backend Implementation:
1. Switch to **hustlexp-ai-backend** repository (NOT this one)
2. Read `.claude/instructions.md` (390 lines of backend enforcement)
3. Read `specs/02-architecture/schema.sql` (database constitution)
4. Verify all triggers exist for 5 invariants

---

## 🆘 When Things Go Wrong

### "I found contradictory specs"
→ Report with file:line references, do NOT resolve on your own

### "The molecule I need doesn't exist"
→ STOP, do NOT invent it at screen level, ASK to create at molecule layer

### "I want to add a feature"
→ Check FINISHED_STATE.md. If not there → STOP, point to FEATURE_FREEZE.md

### "The archetype is unclear"
→ STOP, do NOT guess, ASK which archetype this screen belongs to

### "I found broken references"
→ Report them, do NOT create stub files to satisfy references

---

## 📞 Key Contacts

**Owner:** Sebastian Dysart
**Project:** HustleXP v1.0 MVP
**Repo:** HUSTLEXP-DOCS (Specifications)

**Related Repos:**
- Frontend: HUSTLEXPFINAL1
- Backend: hustlexp-ai-backend

---

## 🏁 Final Reminder

```
This is a SPECIFICATION REPOSITORY.
The product is FROZEN.
Your role is to improve docs, NOT invent features.

When in doubt: STOP and ASK.
```

**You're now ready to work. Go forth and execute specs exactly!**

---

**Last Updated:** 2026-02-05
**Onboarding Time:** ~5 minutes
**Next Steps:** Read `CLAUDE.md` for comprehensive instructions
