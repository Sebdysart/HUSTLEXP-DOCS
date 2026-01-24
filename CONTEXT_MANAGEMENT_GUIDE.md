# CONTEXT MANAGEMENT GUIDE — PROGRESSIVE AI CONTEXT LOADING

**STATUS: OPERATIONAL**
**PURPOSE: Optimize AI tool context for maximum effectiveness**
**LAST UPDATED: 2026-01-24**
**VERSION: 2.0.0**

---

## THE PROBLEM

AI tools have limited context windows:

| Tool | Effective Context | Quality Threshold |
|------|-------------------|-------------------|
| **Cursor Agent** | ~8k tokens | Degrades rapidly above 10k |
| **Claude Code** | ~100k tokens | Degrades above 50k practical |
| **Cursor Chat** | ~4k tokens per message | Very limited |

**Loading too much context = confusion and hallucination**
**Loading too little = missing critical constraints**

This guide teaches progressive context loading — getting exactly what you need, when you need it.

---

## PROGRESSIVE LOADING LEVELS

### Level 1: Foundation (ALWAYS READ FIRST)

**These files are MANDATORY at session start:**

| Tool | Files | Purpose |
|------|-------|---------|
| **Cursor** | `.cursorrules` | Enforcement rules |
| **Cursor** | `CURRENT_PHASE.md` | What's allowed now |
| **Claude Code** | `.claude/instructions.md` | Enforcement rules |
| **Claude Code** | `CURRENT_PHASE.md` | What's allowed now |

**Skip Level 1 = Guaranteed violations**

### Level 2: Task-Specific (READ BASED ON TASK)

| Task Type | Files to Add |
|-----------|--------------|
| **Frontend (React Native)** | `CURSOR_INSTRUCTIONS.md`, `specs/03-frontend/DESIGN_SYSTEM.md` |
| **Frontend (iOS SwiftUI)** | `ios-swiftui/HustleXP/README.md`, `specs/03-frontend/DESIGN_SYSTEM.md` |
| **Backend Implementation** | `specs/04-backend/BUILD_GUIDE.md`, `specs/04-backend/API_CONTRACT.md` |
| **Database Work** | `specs/02-architecture/schema.sql`, `PER/INVARIANTS.md` |
| **Screen Work** | Specific screen spec from `screens-spec/` |
| **Entry Screen** | `reference/components/EntryScreen.js`, `COLOR_SEMANTICS_LAW.md` |

### Level 3: Reference (LOOKUP ONLY — NOT PRELOADED)

| When You Need | File to Lookup |
|---------------|----------------|
| Invariant details | `PER/INVARIANTS.md` |
| Error code definitions | `specs/ERROR_CODES.md` |
| Database schema | `specs/02-architecture/schema.sql` |
| Design tokens | `reference/constants/colors.js` |
| Component patterns | `reference/components/` |
| All UAP gates | `PER/UI_ACCEPTANCE_PROTOCOL.md` |

**Rule: Don't preload reference files. Load when needed.**

---

## CONTEXT LOADING BY SCENARIO

### Scenario 1: Bootstrap Phase Work

```
Level 1 (Foundation):
  ├── .cursorrules
  └── CURRENT_PHASE.md

Level 2 (Task):
  ├── BOOTSTRAP.md
  ├── reference/components/EntryScreen.js
  └── COLOR_SEMANTICS_LAW.md

Level 3 (Reference, if needed):
  ├── reference/constants/colors.js
  └── PER/UI_ACCEPTANCE_PROTOCOL.md
```

**Total: ~6-8k tokens**

### Scenario 2: Implement React Native Screen

```
Level 1 (Foundation):
  ├── .cursorrules
  └── CURRENT_PHASE.md

Level 2 (Task):
  ├── CURSOR_INSTRUCTIONS.md
  ├── specs/03-frontend/DESIGN_SYSTEM.md
  └── screens-spec/{category}/{SCREEN}.md

Level 3 (Reference, if needed):
  └── reference/components/
```

**Total: ~8-10k tokens**

### Scenario 3: Implement iOS SwiftUI Screen

```
Level 1 (Foundation):
  ├── .cursorrules
  └── CURRENT_PHASE.md

Level 2 (Task):
  ├── ios-swiftui/HustleXP/README.md
  └── STITCH HTML file for screen

Level 3 (Reference, if needed):
  ├── HustleColors.swift
  └── HustleTypography.swift
```

**Total: ~6-8k tokens**

### Scenario 4: Backend Endpoint Work

```
Level 1 (Foundation):
  ├── .claude/instructions.md
  └── CURRENT_PHASE.md

Level 2 (Task):
  ├── specs/04-backend/BUILD_GUIDE.md
  └── specs/04-backend/API_CONTRACT.md

Level 3 (Reference, if needed):
  ├── specs/02-architecture/schema.sql
  └── PER/INVARIANTS.md
```

**Total: ~10-12k tokens**

### Scenario 5: Bug Fix (Minimal Context)

```
Level 1 (Foundation):
  └── .cursorrules OR .claude/instructions.md

Level 2 (Task):
  └── Specific file(s) containing the bug

Level 3 (Reference, if needed):
  └── Related spec file
```

**Total: ~4-6k tokens**

### Scenario 6: Architecture Understanding

```
Level 1:
  └── APP_OVERVIEW.md (comprehensive summary)

Level 2 (if needed):
  └── ARCHITECTURE_DIAGRAMS.md (visual)

Level 3 (deep dive):
  └── Specific spec directories
```

**Total: ~4k tokens for overview**

---

## CONTEXT REFRESH TRIGGERS

| Trigger | Action |
|---------|--------|
| 10+ file changes in session | Re-read `.cursorrules` |
| Switching task types | Re-read task-specific files |
| Unexpected behavior | Re-read `PER/INVARIANTS.md` |
| New session | Full Level 1 reload |
| After git pull | Check `CURRENT_PHASE.md` |
| After 30 minutes | Verify alignment |

---

## CONTEXT BUDGET ALLOCATION

### Cursor Agent (~8k tokens)

| Allocation | Tokens | Percentage |
|------------|--------|------------|
| Foundation | 3,000 | 37% |
| Task-Specific | 3,000 | 37% |
| Working Files | 2,000 | 26% |
| **Total** | **8,000** | 100% |

### Claude Code (~100k tokens)

| Allocation | Tokens | Percentage |
|------------|--------|------------|
| Foundation | 5,000 | 5% |
| Task-Specific | 15,000 | 15% |
| Working Files | 30,000 | 30% |
| Reference | 20,000 | 20% |
| Conversation | 30,000 | 30% |
| **Total** | **100,000** | 100% |

---

## ANTI-PATTERNS (WHAT NOT TO DO)

### DON'T: Load Everything at Once

```
❌ "Read all files in specs/"
❌ "Read all PER documents"
❌ "Load the entire codebase"
```

This overloads context and causes hallucination.

### DON'T: Skip Foundation

```
❌ Jump straight to implementation
❌ Ignore .cursorrules
❌ Start without checking CURRENT_PHASE.md
```

This leads to pattern violations and scope creep.

### DON'T: Preload Reference Files

```
❌ "Read schema.sql before knowing if I need it"
❌ "Load all invariants just in case"
```

Only load reference files when you have a specific question.

### DON'T: Ignore Context Staleness

```
❌ Continue long session without refreshing
❌ Trust memory after major changes
```

Stale context causes inconsistency.

---

## QUICK REFERENCE: FILE PRIORITIES

### Tier 1: Constitutional (NEVER SKIP)

- `.cursorrules` / `.claude/instructions.md`
- `CURRENT_PHASE.md`
- `PER/PER_MASTER_INDEX.md`

### Tier 2: Operational (READ FOR TASK TYPE)

- `CURSOR_INSTRUCTIONS.md` (frontend)
- `specs/04-backend/BUILD_GUIDE.md` (backend)
- `EXECUTION_QUEUE.md` (current step)
- `BOOTSTRAP.md` (bootstrap phase)

### Tier 3: Specification (READ FOR SPECIFIC WORK)

- Screen specs in `screens-spec/`
- STITCH prompts in `specs/03-frontend/stitch-prompts/`
- API contracts in `specs/04-backend/`

### Tier 4: Reference (LOOKUP ONLY)

- `specs/02-architecture/schema.sql`
- `PER/INVARIANTS.md`
- `specs/ERROR_CODES.md`
- `reference/constants/colors.js`

---

## CONTEXT LOADING COMMANDS

### Cursor (Using @ Symbol)

```
# Foundation (always first)
@.cursorrules @CURRENT_PHASE.md

# Frontend task
@CURSOR_INSTRUCTIONS.md @DESIGN_SYSTEM.md

# Specific screen
@screens-spec/hustler/HUSTLER_SCREENS.md

# Bootstrap phase
@BOOTSTRAP.md @reference/components/EntryScreen.js
```

### Claude Code (Progressive Reading)

```
1. Read .cursorrules first
2. Read CURRENT_PHASE.md
3. Read task-specific files as needed
4. Lookup reference files only when questions arise
```

---

## CONTEXT VERIFICATION CHECKLIST

Before proceeding with work, verify:

```
[ ] Foundation files read (Level 1)
[ ] Current phase understood
[ ] Task-specific files loaded (Level 2)
[ ] No reference files preloaded unnecessarily
[ ] Context budget not exceeded
```

---

## CROSS-REFERENCES

- `APP_OVERVIEW.md` — Quick system understanding
- `ARCHITECTURE_DIAGRAMS.md` — Visual context
- `.cursorrules` — Cursor enforcement
- `.claude/instructions.md` — Claude Code enforcement
- `PER/PER_MASTER_INDEX.md` — PER system root

---

**Context management is the foundation of AI effectiveness.**
**Progressive loading > Bulk loading.**
