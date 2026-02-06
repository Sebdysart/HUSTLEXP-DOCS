# CLAUDE.md — AI Assistant Instructions for HUSTLEXP-DOCS

> **This file configures Claude Code and other AI assistants to work optimally with this repository.**

---

## 🎯 Repository Purpose

This is **HUSTLEXP-DOCS**: The constitutional specification repository for HustleXP v1.0 MVP.

**What this repo contains:**
- ✅ Complete product specification (38 frozen screens, 41 database tables)
- ✅ UI design system (Atoms → Molecules → Sections → Screens)
- ✅ Enforcement rules for AI agents (`.cursorrules` for frontend, `.claude/instructions.md` for backend)
- ✅ Execution queue (step-by-step build sequence)
- ✅ Database schema with 5 core invariants
- ✅ Comprehensive architecture and subsystem specifications

**What this repo is NOT:**
- ❌ NOT an implementation codebase (see HUSTLEXPFINAL1 for frontend implementation)
- ❌ NOT open to new features (product is FROZEN per FEATURE_FREEZE.md)
- ❌ NOT a design brainstorming space (specifications are LOCKED)

---

## 🛑 CRITICAL RULES (Read First)

### Rule 1: Product is FROZEN
```
The product scope is LOCKED in FINISHED_STATE.md.
No new features may be added without explicit approval.
Check FEATURE_FREEZE.md before ANY changes.
```

### Rule 2: Respect Role Boundaries
```
This is a DOCUMENTATION REPOSITORY. AI assistants working here should:
- Improve documentation clarity
- Fix broken references
- Add machine-readable manifests
- Resolve contradictions between specs

AI assistants should NOT:
- Implement code (wrong repo)
- Invent new features
- Contradict frozen specifications
- Bypass enforcement rules
```

### Rule 3: Understand the 7-Layer Architecture
```
Layer 0: Database (PostgreSQL) — Enforces 5 core invariants
Layer 1: Backend Services — Business logic orchestration
Layer 2: API (tRPC) — Exposes endpoints to frontend
Layer 3: AI Systems — Proposal-only, NO decisions
Layer 4: Frontend Logic — No business logic allowed
Layer 5: UI/Animation — Presentation only
Layer 6: Human Override — Final authority

When working on specs, always indicate which layer(s) are affected.
```

---

## 📋 Quick Start for AI Assistants

### If asked to "help with HustleXP":

1. **Determine which repo** the user is working in:
   - **HUSTLEXP-DOCS** (this repo): Specifications and documentation
   - **HUSTLEXPFINAL1**: React Native frontend implementation
   - **hustlexp-ai-backend**: Backend services implementation

2. **Read role-specific enforcement files:**
   - For frontend work: Read `.cursorrules` (450 lines)
   - For backend work: Read `.claude/instructions.md` (390 lines)
   - For docs work: Read this file (CLAUDE.md)

3. **Check the frozen state:**
   - Read `FINISHED_STATE.md` to understand product scope
   - Read `FEATURE_FREEZE.md` to understand what's forbidden
   - Read `CURRENT_PHASE.md` to understand current build phase

4. **Find the execution context:**
   - For frontend: Read `EXECUTION_QUEUE.md` (step-by-step build sequence)
   - For backend: Read `specs/04-backend/BUILD_GUIDE.md`
   - For docs: Read `README.md` for repository structure

---

## 🗂️ Repository Structure (Optimized for AI)

```
HUSTLEXP-DOCS/
├── 🚀 START HERE
│   ├── README.md                    ← Repository overview
│   ├── CLAUDE.md                    ← This file (AI instructions)
│   ├── AI_QUICK_START.md            ← 5-minute AI onboarding guide
│   └── FINISHED_STATE.md            ← Product boundary (FROZEN)
│
├── 🤖 AI ENFORCEMENT
│   ├── .cursorrules                 ← Frontend AI rules (Cursor)
│   ├── .claude/instructions.md      ← Backend AI rules (Claude Code)
│   ├── AI_GUARDRAILS.md             ← AI behavior boundaries
│   ├── AI_CHECKPOINTS.md            ← Validation gates
│   └── FEATURE_FREEZE.md            ← What's forbidden
│
├── 🧠 EXECUTION MODEL
│   ├── EXECUTION_QUEUE.md           ← Step-by-step build sequence
│   ├── FRONTEND_BUILD_MAP.json      ← Machine-readable dependencies
│   ├── STOP_CONDITIONS.md           ← When to stop building
│   ├── BOOTSTRAP.md                 ← Runtime baseline
│   └── CURRENT_PHASE.md             ← Current phase gate
│
├── 🧩 UI DESIGN SYSTEM
│   ├── UI_COMPONENT_HIERARCHY.md    ← Atoms → Molecules → Sections → Screens
│   ├── SCREEN_ARCHETYPES.md         ← 6 screen categories (A-F)
│   ├── SCREEN_FEATURE_MATRIX.md     ← What each screen does (38 screens)
│   └── ui-puzzle/                   ← Component specifications
│       ├── atoms/                   ← 9 locked primitives
│       ├── molecules/               ← 12 locked composites
│       ├── sections/                ← 5 locked regions
│       ├── screens/                 ← Archetype templates
│       └── tokens/                  ← Design tokens (colors, typography, spacing)
│
├── 📚 SPECIFICATIONS
│   └── specs/
│       ├── 00-overview/             ← Quick start
│       ├── 01-product/              ← Product requirements
│       ├── 02-architecture/         ← Backend architecture, schema.sql
│       │   └── subsystems/          ← 10 LOCKED subsystems
│       ├── 03-frontend/             ← UI specifications
│       └── 04-backend/              ← API, deployment, integrations
│
├── 📱 SCREEN SPECIFICATIONS
│   └── screens-spec/
│       ├── SCREEN_REGISTRY.md       ← Master index of 38 screens
│       ├── auth/                    ← Authentication flows
│       ├── hustler/                 ← Worker user screens
│       ├── poster/                  ← Task creator screens
│       ├── onboarding/              ← Onboarding flows (O1-O5)
│       ├── settings/                ← User settings
│       ├── shared/                  ← Cross-role screens
│       └── edge/                    ← Error & system screens
│
├── ⚙️ AUTHORITY & GOVERNANCE
│   ├── PER/                         ← Persistent Execution Rails
│   │   ├── PER_MASTER_INDEX.md      ← Enforcement framework
│   │   ├── INVARIANTS.md            ← 5 core database invariants
│   │   ├── OMEGA_PROTOCOL.md        ← Emergency recovery
│   │   └── [11 more enforcement docs]
│   ├── COLOR_AUTHORITY_RESOLUTION.md
│   ├── TYPOGRAPHY_AUTHORITY_RESOLUTION.md
│   ├── NAVIGATION_ARCHITECTURE.md
│   └── TASK_CREATION_STATE_MACHINE.md
│
├── 📊 IMPLEMENTATION TRACKING
│   └── tracking/
│       ├── EXECUTION_INDEX.md       ← Status of each component
│       ├── EXECUTION_TODO.md        ← Current action items
│       └── audits/                  ← Historical audit reports
│
├── 📦 REFERENCE IMPLEMENTATION
│   └── reference/                   ← Scaffold code (React Native + Expo)
│       ├── components/              ← Example components
│       ├── screens/                 ← Example screens
│       ├── constants/               ← Design tokens in code
│       ├── navigation/              ← Navigation structure
│       └── package.json             ← Dependencies list
│
├── 🎯 PROMPT TEMPLATES
│   └── prompts/                     ← Prompt templates for AI tools
│       ├── CLAUDE_CODE_PROMPT_TEMPLATE.md
│       ├── CURSOR_PROMPT_TEMPLATE.md
│       └── [6 more templates]
│
└── 📂 SUPPORTING FILES
    ├── assets/                      ← Images, placeholders
    ├── mock-data/                   ← Test data
    ├── __tests__/                   ← Jest test suite
    ├── _archive/                    ← Retired files (0 active refs)
    └── staging/                     ← Post-v1 stubs
```

---

## 🔍 Finding What You Need (Fast Lookup)

### "What screens exist?"
→ Read `screens-spec/SCREEN_REGISTRY.md` (38 screens with metadata)

### "What's the database schema?"
→ Read `specs/02-architecture/schema.sql` (41 tables, 5 invariants)

### "What UI components can I use?"
→ Read `ui-puzzle/atoms/ATOM_REGISTRY.md` (9 atoms)
→ Read `ui-puzzle/molecules/MOLECULE_REGISTRY.md` (12 molecules)

### "What features are in v1.0?"
→ Read `FINISHED_STATE.md` (frozen product boundary)

### "How does task flow work?"
→ Read `specs/01-product/PRODUCT_SPEC.md` (task lifecycle: POSTED → COMPLETED)

### "What are the 5 core invariants?"
→ Read `PER/INVARIANTS.md` (database-enforced rules)

### "How do I build the frontend step-by-step?"
→ Read `EXECUTION_QUEUE.md` (sequential build checklist)

### "What's the current build phase?"
→ Read `CURRENT_PHASE.md` (phase gates and current status)

---

## 🧠 Mental Model: The Puzzle Approach

HustleXP UI is built as a **PUZZLE**, not isolated screens:

```
┌─────────────────────────────────────────────────────────────┐
│  SCREENS    — Assembly ONLY (no invention allowed)          │
├─────────────────────────────────────────────────────────────┤
│  SECTIONS   — Narrative regions (header, content, actions)  │
├─────────────────────────────────────────────────────────────┤
│  MOLECULES  — Combinations of atoms (cards, forms, lists)   │
├─────────────────────────────────────────────────────────────┤
│  ATOMS      — Primitive elements (buttons, inputs, text)    │
└─────────────────────────────────────────────────────────────┘
```

**Key Rules:**
1. Atoms are **LOCKED** once approved (9 total)
2. Molecules are **LOCKED** once approved (12 total)
3. Screens **ASSEMBLE** existing pieces — they do NOT invent new visuals
4. If you need something new → create it at Atom/Molecule layer FIRST
5. AI agents are **FORBIDDEN** from inventing new visuals at the Screen level

---

## 🎯 Screen Archetypes (A-F System)

All screens belong to one of 6 archetypes. Identify the archetype BEFORE implementation.

| Archetype | Purpose | Example Screens |
|-----------|---------|----------------|
| **A. Entry/Commitment** | User decides to engage | Login, Signup, Role Selection |
| **B. Feed/Opportunity** | User discovers options | Task Feed, History |
| **C. Task Lifecycle** | Active work flow | Task Detail, In Progress, Proof |
| **D. Calibration/Capability** | User configures self | Onboarding, Verification, Settings |
| **E. Progress/Status** | User sees standing | Home, Profile, XP Breakdown |
| **F. System/Interrupt** | System communicates | Errors, Maintenance, Force Update |

**Rule:** Screens inherit visuals, motion, and hierarchy from their archetype.
**Rule:** AI may NOT treat screens as unique design problems.
**Rule:** If archetype is unclear → STOP and ASK.

---

## ✨ Chosen-State Requirement (Global UI Law)

All Entry, Feed, and Onboarding screens must imply:

✅ The user is **ALREADY SELECTED** — not being tested or judged
✅ The system is **ALREADY ACTIVE** — not waiting or dormant
✅ A successful outcome is **LIKELY or GUARANTEED** — not uncertain

**FORBIDDEN:**
❌ Empty states that feel like "starting from zero"
❌ Neutral or tentative language
❌ UI that makes the user feel unqualified
❌ Loading states that feel like waiting in line

**If a screen feels like "starting from zero" → it FAILS quality review.**

---

## 🔒 The 5 Core Invariants (Memorize These)

These are **MECHANICALLY ENFORCED** at Layer 0 (PostgreSQL):

| ID | Rule | Error Code |
|----|------|------------|
| **INV-1** | XP requires RELEASED escrow | HX101 |
| **INV-2** | RELEASED escrow requires COMPLETED task | HX201 |
| **INV-3** | COMPLETED task requires ACCEPTED proof | HX301 |
| **INV-4** | Escrow amount is IMMUTABLE | HX401 |
| **INV-5** | One XP entry per escrow | HX501 |

**The Chain (Never Break This):**
```
Task Created → Escrow Funded → Work Done → Proof Accepted → Escrow Released → XP Awarded
```

Every arrow is enforced by database triggers. **You cannot skip steps.**

---

## 🚨 When to STOP and ASK

AI assistants should STOP IMMEDIATELY and ask the user if:

🛑 You need to add a feature not in `FINISHED_STATE.md`
🛑 You encounter contradictory specifications
🛑 You find broken internal references (§ notation)
🛑 A spec seems incomplete or wrong
🛑 You're unsure which layer owns a decision
🛑 You need to modify frozen components (atoms/molecules)
🛑 You need to add screens beyond the frozen 38
🛑 You need to add database tables beyond the frozen 41

**DO NOT GUESS. DO NOT ASSUME. DO NOT "HELP" BY FILLING GAPS.**

---

## 📊 Frozen Counts (Reference)

| Artifact | Count | Status |
|----------|-------|--------|
| Screens | 38 | 🔒 FROZEN |
| Database Tables | 41 | 🔒 FROZEN |
| Atoms | 9 | 🔒 LOCKED |
| Molecules | 12 | 🔒 LOCKED |
| Sections | 5 | 🔒 LOCKED |
| Archetypes | 6 | 🔒 LOCKED |
| Trust Tiers | 5 | 🔒 FROZEN |
| Database Invariants | 5 | 🔒 FROZEN |
| LOCKED Subsystems | 10 | 🔒 FROZEN |

---

## 🔗 Related Repositories

| Repository | Purpose | AI Instructions |
|------------|---------|----------------|
| **HUSTLEXP-DOCS** (this repo) | Specifications | Read `CLAUDE.md` |
| **HUSTLEXPFINAL1** | React Native frontend | Read `.cursorrules` |
| **hustlexp-ai-backend** | Backend services | Read `.claude/instructions.md` |

**CRITICAL:** Do not confuse repositories. Each has its own enforcement rules.

---

## 🛠️ Common AI Tasks in This Repo

### Task: "Fix broken references"
1. Search for `§` notation (internal cross-references)
2. Verify target sections exist
3. Update references or report missing targets
4. Do NOT invent sections to satisfy references

### Task: "Add machine-readable manifest"
1. Scan existing markdown specifications
2. Extract structured data (file paths, counts, dependencies)
3. Create JSON manifest with exact references
4. Validate against frozen counts (38 screens, 41 tables, etc.)

### Task: "Resolve specification contradictions"
1. Identify conflicting definitions across files
2. Report contradictions with file paths and line numbers
3. ASK which specification is authoritative
4. Do NOT guess or "merge" contradictory specs

### Task: "Improve documentation clarity"
1. Fix typos and grammar
2. Add missing cross-references
3. Standardize formatting
4. Do NOT change technical content without approval

### Task: "Audit for AI slop"
1. Search for placeholder text: "TODO", "[TBD]", "Lorem ipsum"
2. Search for generic AI phrases: "It's worth noting", "Let's dive in"
3. Find broken references, orphaned files, missing files
4. Report findings with specific line numbers
5. Do NOT auto-fix without explicit approval

---

## 🔐 Enforcement Philosophy

This repository uses a **FROZEN PRODUCT MODEL** with explicit enforcement:

**Constitutional Documents** (Cannot change):
- `FINISHED_STATE.md` — Hard boundary of v1.0 features
- `FEATURE_FREEZE.md` — No new features allowed
- `specs/02-architecture/schema.sql` — Database is "constitution"

**Role-Specific Rules Files:**
- `.cursorrules` — Frontend enforcer for Cursor
- `.claude/instructions.md` — Backend enforcer for Claude Code
- `CLAUDE.md` — Documentation enforcer (this file)

**Authority Hierarchy:**
- **Layer 0** (Database) has final authority on invariants
- **Frozen specifications** override AI suggestions
- **User approval** required for changes to frozen artifacts
- **AI role** is execution, NOT design

---

## 📝 Working with Specifications

### Format Conventions

**Cross-references:** Use `§` notation
```markdown
See ARCHITECTURE.md §5.3 for layer boundaries.
```

**Status markers:**
- `🔒 FROZEN` — Cannot change without explicit approval
- `🔒 LOCKED` — Finalized and cannot be modified
- `✅ DONE` — Implementation complete
- `⚠️ BLOCKED` — Cannot proceed until resolved
- `🚧 IN PROGRESS` — Currently being implemented

**Error codes:** Use HX-prefix
```
HX101: xp_requires_released_escrow
HX201: escrow_released_requires_completed_task
```

---

## 🎓 Learning Path for New AI Assistants

### Level 1: Orientation (5 minutes)
1. Read `README.md`
2. Read `FINISHED_STATE.md`
3. Understand the 38 frozen screens and 41 frozen tables

### Level 2: Role Assignment (10 minutes)
4. Identify your role (Frontend, Backend, or Docs)
5. Read role-specific enforcement file:
   - Frontend → `.cursorrules`
   - Backend → `.claude/instructions.md`
   - Docs → `CLAUDE.md` (this file)

### Level 3: Domain Knowledge (20 minutes)
6. Read `specs/02-architecture/ARCHITECTURE.md` (7-layer model)
7. Read `UI_COMPONENT_HIERARCHY.md` (puzzle model)
8. Read `PER/INVARIANTS.md` (5 core rules)
9. Read `SCREEN_ARCHETYPES.md` (A-F system)

### Level 4: Execution Context (10 minutes)
10. Read `CURRENT_PHASE.md` (where are we in the build?)
11. Read `EXECUTION_QUEUE.md` or `specs/04-backend/BUILD_GUIDE.md`
12. Check `tracking/EXECUTION_INDEX.md` (implementation status)

**Total onboarding time: ~45 minutes**

---

## 🚀 Best Practices for AI Assistants

### DO:
✅ Read specifications before suggesting changes
✅ Verify file paths exist before referencing them
✅ Check frozen counts before adding artifacts
✅ Ask when unclear rather than guessing
✅ Quote exact line numbers when reporting issues
✅ Preserve formatting and structure conventions
✅ Validate cross-references (§ notation)

### DO NOT:
❌ Invent features not in FINISHED_STATE.md
❌ Skip reading enforcement rules
❌ Assume frontend and backend have same rules
❌ Modify frozen artifacts without approval
❌ Create duplicate specifications
❌ Add placeholder text or TODOs
❌ "Improve" specs by adding content not requested

---

## 📞 When Things Go Wrong

### If specifications contradict each other:
1. Report the contradiction with file paths and line numbers
2. Quote the conflicting statements
3. ASK which specification is authoritative
4. Wait for user decision — do NOT resolve on your own

### If you find a frozen count mismatch:
1. Report the discrepancy (e.g., "Registry says 12 molecules, but only 4 files exist")
2. Do NOT auto-create missing files
3. ASK whether to create, remove from registry, or mark as planned

### If a reference points to a missing file:
1. Report the broken reference with source location
2. Search for alternative locations (maybe renamed/moved)
3. Do NOT create stub files to satisfy the reference
4. ASK for guidance

### If you're asked to add a new feature:
1. Check if it exists in FINISHED_STATE.md
2. If NO → Point user to FEATURE_FREEZE.md
3. Explain that the product scope is frozen
4. Do NOT proceed without explicit override approval

---

## 🎯 Success Criteria for AI Work

Your work in this repository is successful when:

✅ Documentation is clear, accurate, and complete
✅ All cross-references (§ notation) are valid
✅ Frozen counts match actual artifacts
✅ No placeholder text (TODO, TBD, etc.)
✅ No contradictory specifications
✅ Machine-readable manifests are accurate
✅ Enforcement rules are consistent
✅ No broken links or missing files

---

## 📚 Key Documents (Must Read)

| Priority | Document | Purpose |
|----------|----------|---------|
| **P0** | `README.md` | Repository overview |
| **P0** | `FINISHED_STATE.md` | Product boundary (FROZEN) |
| **P0** | `FEATURE_FREEZE.md` | What's forbidden |
| **P1** | `.cursorrules` | Frontend AI rules |
| **P1** | `.claude/instructions.md` | Backend AI rules |
| **P1** | `specs/02-architecture/ARCHITECTURE.md` | 7-layer model |
| **P1** | `specs/02-architecture/schema.sql` | Database constitution |
| **P2** | `UI_COMPONENT_HIERARCHY.md` | Puzzle model |
| **P2** | `SCREEN_ARCHETYPES.md` | A-F system |
| **P2** | `PER/INVARIANTS.md` | 5 core database rules |
| **P3** | `EXECUTION_QUEUE.md` | Frontend build sequence |
| **P3** | `specs/04-backend/BUILD_GUIDE.md` | Backend build sequence |

---

## 🏁 Final Reminder

```
This is a SPECIFICATION REPOSITORY, not an implementation codebase.

Your role is to:
- Improve documentation clarity
- Fix broken references
- Add machine-readable manifests
- Resolve contradictions

Your role is NOT to:
- Implement features
- Invent new specifications
- Bypass frozen boundaries
- Make decisions on behalf of the user

When in doubt: STOP and ASK.
```

**The product is defined. The scope is frozen. Build exactly this.**

---

**Owner:** Sebastian Dysart
**Project:** HustleXP v1.0
**Last Updated:** 2026-02-05
