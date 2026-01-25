# UI Puzzle System

> **Cursor is a puzzle assembler, not a designer.**

This directory contains the constrained component system for HustleXP UI development.

---

## Layer Structure

```
ui-puzzle/
├── tokens/      # Layer 0: Zero-decision primitives (READ-ONLY)
├── atoms/       # Layer 1: Visual primitives (single responsibility)
├── molecules/   # Layer 2: Semantic combinations (atom assemblies)
├── sections/    # Layer 3: Narrative fragments (one job each)
└── screens/     # Layer 4: Pure assembly (no invention)
```

---

## Quick Rules

| Layer | Cursor CAN | Cursor CANNOT |
|-------|------------|---------------|
| Token | Read | Create, modify |
| Atom | Implement, refine | Invent, use non-tokens |
| Molecule | Combine atoms | Add unapproved atoms |
| Section | Arrange molecules | Add new molecules |
| Screen | Assemble sections | Invent ANYTHING |

---

## How to Use

### 1. Start at the right layer
Don't jump to screens. Build atoms first, then molecules, then sections.

### 2. Always invoke with layer
```
HUSTLEXP_INVOCATION(layer: .atom, target: "GlowOrb", scope: .implement)
```

### 3. Pass stress test before promotion
An atom cannot be used in a molecule until it passes its stress test.

### 4. Lock when validated
Add to `COMPLETION_LOCK.md` when a component is production-ready.

---

## Authority

This system is governed by:
- `PER/PUZZLE_MODE.md` — Full specification
- `PER/INVARIANTS.md` — System invariants
- `COMPLETION_LOCK.md` — Frozen components

Violations trigger PER enforcement.
