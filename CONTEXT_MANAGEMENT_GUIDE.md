# Context Management Guide

**Purpose:** Optimize AI tool context loading for maximum effectiveness with minimal token usage.

**Last Updated:** 2025-01-23

---

## The Problem

AI tools have limited context windows:
- **Cursor Agent:** ~8k tokens effective context
- **Claude Code:** ~100k tokens (but quality degrades with size)
- **Cursor Chat:** ~4k tokens per message

Loading too much context = confusion and hallucination.
Loading too little = missing critical constraints.

---

## Progressive Context Loading Strategy

### Level 1: Foundation (ALWAYS READ FIRST)

**Every session must start with these files:**

| Tool | Files | Total ~Tokens |
|------|-------|---------------|
| Cursor | `.cursorrules`, `CURRENT_PHASE.md` | ~3k |
| Claude Code | `.claude/instructions.md`, `CURRENT_PHASE.md` | ~4k |

**Why:** These files contain enforcement rules that prevent hallucination and scope creep.

### Level 2: Task-Specific (READ BASED ON TASK)

| Task Type | Additional Files | ~Tokens |
|-----------|------------------|---------|
| Frontend (React Native) | `CURSOR_INSTRUCTIONS.md`, `specs/03-frontend/DESIGN_SYSTEM.md` | ~6k |
| Frontend (iOS) | `ios-swiftui/HustleXP/README.md`, `specs/03-frontend/DESIGN_SYSTEM.md` | ~4k |
| Backend | `specs/04-backend/BUILD_GUIDE.md`, `specs/04-backend/API_CONTRACT.md` | ~8k |
| Database | `specs/02-architecture/schema.sql`, `PER/INVARIANTS.md` | ~10k |
| Screen Implementation | `screens-spec/SCREEN_REGISTRY.md`, specific screen spec | ~4k |

### Level 3: Reference (LOOKUP ONLY — DON'T PRELOAD)

| Reference Need | File | Use When |
|----------------|------|----------|
| All invariants | `PER/INVARIANTS.md` | Touching data flow or state machines |
| Error codes | `specs/ERROR_CODES.md` | Adding error handling |
| Database schema | `specs/02-architecture/schema.sql` | Adding/modifying queries |
| Design tokens | `specs/03-frontend/DESIGN_SYSTEM.md` | Adding new UI elements |
| Component library | `specs/03-frontend/COMPONENT_LIBRARY.md` | Using shared components |
| Screen feature matrix | `SCREEN_FEATURE_MATRIX.md` | Understanding screen responsibilities |

---

## Context Loading by Scenario

### Scenario 1: Implement a New Screen (React Native)

```
1. Foundation: .cursorrules + CURRENT_PHASE.md
2. Task: CURSOR_INSTRUCTIONS.md + DESIGN_SYSTEM.md
3. Specific: screens-spec/{category}/{SCREEN_NAME}.md
4. Reference (if needed): COMPONENT_LIBRARY.md
```

**Total: ~8-10k tokens**

### Scenario 2: Implement a Screen (iOS SwiftUI)

```
1. Foundation: .cursorrules + CURRENT_PHASE.md
2. Task: ios-swiftui/HustleXP/README.md
3. Specific: specs/03-frontend/stitch-prompts/{screen}.html
4. Reference (if needed): HustleColors.swift, HustleTypography.swift
```

**Total: ~6-8k tokens**

### Scenario 3: Add Backend Endpoint

```
1. Foundation: .claude/instructions.md + CURRENT_PHASE.md
2. Task: specs/04-backend/BUILD_GUIDE.md + API_CONTRACT.md
3. Specific: Relevant section of EXECUTION_QUEUE.md
4. Reference (if needed): schema.sql, PER/INVARIANTS.md
```

**Total: ~10-12k tokens**

### Scenario 4: Fix a Bug

```
1. Foundation: .cursorrules OR .claude/instructions.md
2. Task: Specific file(s) containing the bug
3. Reference (if needed): Related spec file
```

**Total: ~4-6k tokens (minimal)**

### Scenario 5: Understand System Architecture

```
1. APP_OVERVIEW.md (this document summarizes everything)
2. ARCHITECTURE_DIAGRAMS.md (visual understanding)
3. If deeper dive needed: specific spec directories
```

**Total: ~4k tokens for overview**

---

## Context Refresh Triggers

**Refresh your context when:**

| Trigger | Action |
|---------|--------|
| 10+ file changes in session | Re-read `.cursorrules`/`.claude/instructions.md` |
| Switching task types (frontend → backend) | Re-read task-specific files |
| Encountering unexpected behavior | Re-read `PER/INVARIANTS.md` |
| Starting new session | Full Level 1 reload |
| After git pull | Check `CURRENT_PHASE.md` for changes |

---

## Anti-Patterns (What NOT to Do)

### Don't: Load Everything at Once

```
❌ "Read all files in specs/"
```

This overloads context and causes confusion.

### Don't: Skip Foundation

```
❌ Jump straight to implementation without reading .cursorrules
```

This leads to pattern violations and scope creep.

### Don't: Preload Reference Files

```
❌ "Read schema.sql before knowing if I need it"
```

Only load reference files when you have a specific question.

### Don't: Ignore Context Staleness

```
❌ Continue session after major changes without refreshing
```

Stale context causes inconsistency.

---

## Context Budget by Tool

### Cursor Agent Mode

| Allocation | Tokens | Percentage |
|------------|--------|------------|
| Foundation | 3,000 | 37% |
| Task-Specific | 3,000 | 37% |
| Working Files | 2,000 | 26% |
| **Total** | **8,000** | 100% |

### Claude Code

| Allocation | Tokens | Percentage |
|------------|--------|------------|
| Foundation | 5,000 | 5% |
| Task-Specific | 15,000 | 15% |
| Working Files | 30,000 | 30% |
| Reference | 20,000 | 20% |
| Conversation | 30,000 | 30% |
| **Total** | **100,000** | 100% |

---

## Quick Reference: File Priorities

### Tier 1: Constitutional (Never Skip)
- `.cursorrules` / `.claude/instructions.md`
- `CURRENT_PHASE.md`
- `PER/PER_MASTER_INDEX.md`

### Tier 2: Operational (Read for Task Type)
- `CURSOR_INSTRUCTIONS.md` (frontend)
- `BUILD_GUIDE.md` (backend)
- `EXECUTION_QUEUE.md` (current step)

### Tier 3: Specification (Read for Specific Work)
- Screen specs in `screens-spec/`
- STITCH prompts in `specs/03-frontend/stitch-prompts/`
- API contracts in `specs/04-backend/`

### Tier 4: Reference (Lookup Only)
- `schema.sql`
- `PER/INVARIANTS.md`
- `ERROR_CODES.md`
- `DESIGN_SYSTEM.md`

---

## Context Loading Commands

### Cursor (Using @ Symbol)

```
@.cursorrules @CURRENT_PHASE.md                    # Foundation
@CURSOR_INSTRUCTIONS.md @DESIGN_SYSTEM.md          # Frontend task
@screens-spec/hustler/HUSTLER_SCREENS.md           # Specific screen
```

### Claude Code (Tool Usage)

```
Read .cursorrules first
Read CURRENT_PHASE.md
Then read task-specific files as needed
```

---

## Cross-References

- `APP_OVERVIEW.md` — Quick system understanding
- `ARCHITECTURE_DIAGRAMS.md` — Visual context
- `.cursorrules` — Cursor enforcement
- `.claude/instructions.md` — Claude Code enforcement
