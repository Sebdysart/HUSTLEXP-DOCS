# PUZZLE_MODE.md
## UI Assembly Constraint System — PER Extension

**Version:** 1.0.0
**Status:** ACTIVE
**Authority:** Extends PER, does not replace

---

## Core Principle

> **Cursor is a puzzle assembler, not a designer.**

HustleXP UI is not "built" — it is **assembled from pre-validated pieces**.

This document governs:
- What pieces exist (Layers 0-4)
- What Cursor can do at each layer
- How pieces are validated before use
- How screens are assembled from pieces

---

## The 5-Layer Puzzle System

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 4: SCREENS                                           │
│  Assembly only. No invention.                               │
│  EntryScreen, OnboardingCarousel, HustlerHome              │
├─────────────────────────────────────────────────────────────┤
│  LAYER 3: SECTIONS                                          │
│  Narrative fragments. One job per section.                  │
│  EntryHeroSection, EntryActionSection                       │
├─────────────────────────────────────────────────────────────┤
│  LAYER 2: MOLECULES                                         │
│  Semantic combinations. No screen logic.                    │
│  BrandCluster, CTAStack, MarketField                        │
├─────────────────────────────────────────────────────────────┤
│  LAYER 1: ATOMS                                             │
│  Visual primitives. Single responsibility.                  │
│  GlowOrb, AnimatedMesh, PrimaryCTA, BrandMark              │
├─────────────────────────────────────────────────────────────┤
│  LAYER 0: TOKENS                                            │
│  Zero-decision primitives. Read-only.                       │
│  colors, typography, spacing, motion, shadows               │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Definitions

### LAYER 0: TOKENS
**Location:** `ui-puzzle/tokens/`

**What they are:**
- Raw design values with zero creative decisions
- Colors, font sizes, spacing units, timing curves, shadow definitions
- The "periodic table" of HustleXP UI

**Rules:**
- Tokens are NEVER created by Cursor
- Tokens are manually audited once, then **read-only forever**
- Every visual value in the app must trace to a token
- If a value doesn't exist as a token, it cannot be used

**Files:**
```
tokens/
├── colors.swift         # All color definitions
├── typography.swift     # Font sizes, weights, line heights
├── spacing.swift        # Padding, margins, gaps
├── motion.swift         # Duration, easing curves, delays
└── shadows.swift        # Shadow definitions
```

---

### LAYER 1: ATOMS
**Location:** `ui-puzzle/atoms/`

**What they are:**
- Small, single-purpose visual components
- Zero narrative meaning
- Zero layout decisions
- Zero role awareness (hustler/poster)

**Examples:**
- `GlowOrb` — pulsing glow effect
- `AnimatedMeshField` — drifting gradient background
- `NoiseOverlay` — grain texture
- `ParticleField` — floating particles
- `BrandMark` — the "H" logo
- `PrimaryCTA` — the main action button
- `MotionFadeIn` — entrance animation wrapper
- `TypeReveal` — text animation

**Rules:**
- Each atom does ONE thing
- Atoms cannot import other atoms
- Atoms can only use tokens
- Atoms must pass isolation stress test before use

**Stress Test (required for each atom):**
```markdown
## Atom Stress Test: [AtomName]

### Isolation Test
- [ ] Renders correctly with no parent context
- [ ] Works on pure black background
- [ ] Works on pure white background
- [ ] No hardcoded values (all from tokens)

### Performance Test
- [ ] 60fps on iPhone 12
- [ ] No memory leaks in animation loop
- [ ] TimelineView efficiency (if animated)

### Accessibility Test
- [ ] Sufficient contrast (WCAG AA)
- [ ] Respects reduced motion setting
```

---

### LAYER 2: MOLECULES
**Location:** `ui-puzzle/molecules/`

**What they are:**
- Combinations of atoms that create semantic meaning
- Still no screen logic or narrative flow
- Still no role bias (hustler/poster)

**Examples:**
- `BrandCluster` — BrandMark + GlowOrb + MotionFadeIn
- `CTAStack` — PrimaryCTA + secondary link + affordance glow
- `MarketField` — AnimatedMeshField + ParticleField + NoiseOverlay
- `ValueStatement` — TypeReveal headline + subtext

**Rules:**
- Molecules can only use approved atoms
- Molecules must declare their composition contract
- Molecules cannot contain layout logic (no full-screen positioning)
- Molecules must pass Dominant Axis stress test

**Composition Contract (required for each molecule):**
```markdown
## Composition Contract: [MoleculeName]

### Atoms Used
- AtomA (required)
- AtomB (required)
- AtomC (optional)

### Forbidden Atoms
- AtomX (belongs in different molecule)
- AtomY (role-specific, violates bidirectionality)

### Dominant Axis Compliance
- [ ] momentum > calm
- [ ] urgency > comfort
- [ ] action > reassurance
- [ ] direction > balance
- [ ] concrete > abstract

### Role Bias
- [ ] NONE — this molecule works for both hustlers and posters
```

---

### LAYER 3: SECTIONS
**Location:** `ui-puzzle/sections/`

**What they are:**
- Screen regions with a single narrative job
- Answer ONE question only
- Can have role-specific variants

**Examples:**
- `EntryHeroSection` — "What is this app?"
- `EntryActionSection` — "What do I do next?"
- `EntryContextSection` — "What else should I know?"
- `OnboardingMapSection` — "How does location work?"
- `OnboardingTierSection` — "How do I level up?"

**Rules:**
- One section = one narrative job
- Sections can only use approved molecules
- Sections must pass UAP-0 through UAP-3
- Sections must declare their single purpose

**Section Contract (required for each section):**
```markdown
## Section Contract: [SectionName]

### Purpose (ONE sentence only)
[What single question does this section answer?]

### Molecules Used
- MoleculeA
- MoleculeB

### Forbidden Content
- [What this section must NOT communicate]

### UAP Compliance
- [ ] UAP-0: Visible hierarchy
- [ ] UAP-1: Motion continuity
- [ ] UAP-2: Action clarity
- [ ] UAP-3: Loading elegance

### Role Handling
- [ ] Bidirectional (no role bias)
- [ ] OR: Hustler-specific
- [ ] OR: Poster-specific
```

---

### LAYER 4: SCREENS
**Location:** `ui-puzzle/screens/`

**What they are:**
- Pure assembly of pre-approved sections
- NO new atoms, molecules, or concepts
- NO creative decisions
- Layout and spacing ONLY

**Rules:**
- Screens can only arrange approved sections
- Screens cannot introduce new visual elements
- Screens cannot modify section internals
- Screens must pass UAP-4 through UAP-7
- Screens must declare their assembly manifest

**Assembly Manifest (required for each screen):**
```markdown
## Assembly Manifest: [ScreenName]

### Sections Used
1. SectionA (position: top)
2. SectionB (position: middle)
3. SectionC (position: bottom)

### New Atoms: NONE
### New Molecules: NONE
### New Copy: NONE
### New Motion: NONE

### Cursor Scope
- [ ] Layout positioning
- [ ] Section spacing
- [ ] Safe area handling
- [ ] Transition to next screen

### UAP Compliance
- [ ] UAP-4: System cohesion
- [ ] UAP-5: Edge state handling
- [ ] UAP-6: Polish details
- [ ] UAP-7: Emotional calibration
```

---

## Layer Permissions Matrix

| Layer | Cursor CAN | Cursor CANNOT |
|-------|------------|---------------|
| **Token** | Read values | Create, modify, delete |
| **Atom** | Implement from spec, refine animation | Invent new concepts, use non-token values |
| **Molecule** | Combine approved atoms, adjust composition | Add unapproved atoms, add screen logic |
| **Section** | Arrange molecules, adjust narrative | Add new molecules, blur purpose |
| **Screen** | Assemble sections, handle spacing | Invent ANYTHING, modify section internals |

---

## Invocation Pattern

Every Cursor task involving UI must specify:

```
HUSTLEXP_INVOCATION(
    layer: .atom | .molecule | .section | .screen,
    target: "ComponentName",
    scope: .implement | .refine | .assemble | .stress_test
)
```

**Examples:**
```
HUSTLEXP_INVOCATION(layer: .atom, target: "GlowOrb", scope: .implement)
HUSTLEXP_INVOCATION(layer: .molecule, target: "BrandCluster", scope: .refine)
HUSTLEXP_INVOCATION(layer: .screen, target: "EntryScreen", scope: .assemble)
```

If invocation is missing or malformed → **REFUSE execution**.

---

## Violation Responses

| Violation | Response |
|-----------|----------|
| Cursor attempts work outside declared layer | REFUSE — "Scope violation: declared layer is X, attempted action is layer Y" |
| Cursor invents at screen layer | REFUSE — "Screen layer is assembly-only. No new concepts allowed." |
| Cursor uses unapproved atom in molecule | REFUSE — "Atom X is not in composition contract for molecule Y" |
| Cursor uses hardcoded value instead of token | REFUSE — "Value must trace to token. Found hardcoded: [value]" |
| Cursor skips stress test before promotion | REFUSE — "Component must pass stress test before use at higher layer" |

---

## Completion Lock Integration

When a component passes all stress tests at its layer:

1. Add to `COMPLETION_LOCK.md`:
   ```
   - ui-puzzle/atoms/GlowOrb/ [LOCKED: 2025-01-24]
   ```

2. Component becomes **read-only** for Cursor
3. Any modification requires explicit unlock in prompt
4. Unlock must include justification

---

## Stress Test Protocol

### Atom Stress Test
1. Isolation rendering (no context)
2. Token compliance (no hardcoded values)
3. Performance (60fps, no leaks)
4. Accessibility (contrast, reduced motion)

### Molecule Stress Test
1. Composition contract compliance
2. Dominant Axis pass (all 5 axes)
3. Role bias check (bidirectional unless specified)
4. Atom approval verification

### Section Stress Test
1. Single-purpose clarity
2. Molecule approval verification
3. UAP-0 through UAP-3 pass
4. Narrative boundary check

### Screen Stress Test
1. Assembly manifest compliance
2. No new concepts verification
3. UAP-4 through UAP-7 pass
4. Section arrangement verification

---

## Regression Anchors

Each component folder includes:
```
ComponentName/
├── ComponentName.swift       # Implementation
├── ComponentName.snapshot.png # Visual reference (golden master)
├── ComponentName.stress.md   # Stress test results
└── ComponentName.contract.md # Composition/assembly contract
```

The `.snapshot.png` is the **visual ground truth**.

If Cursor's output differs from snapshot → requires explicit approval to update.

---

## Why This Works

### Before Puzzle Mode
- Cursor reasons across 30+ documents per screen
- Every screen is a full creative exercise
- Verification is post-hoc ("does this look right?")
- Aesthetic regression is constant

### After Puzzle Mode
- Cursor reasons about ONE layer at a time
- Screens are pure assembly (no creativity)
- Verification is per-component (small, testable)
- Locked components cannot regress

### The Key Insight
> Cursor is not failing because it's dumb.
> Cursor is failing because we ask it to reason across too many dimensions.
>
> Puzzle Mode constrains the dimensions.
> Each layer has exactly ONE type of decision.
> That's the difference between "design a city" and "place buildings on a grid."

---

## Relationship to Existing PER System

| System | Governs |
|--------|---------|
| **PER** | What exists (features, scope, invariants) |
| **HIC** | How Cursor behaves (invocation, commitment) |
| **UAP** | When something is acceptable (quality gates) |
| **DESIGN_TARGET** | What max-tier looks like (reference class) |
| **DOMINANT_AXIS** | Which direction to tilt (aesthetic vector) |
| **Puzzle Mode** | Where thinking is allowed (layer constraints) |

Puzzle Mode does not replace PER — it **adds spatial constraints** to the temporal constraints PER already provides.

---

## Integration with DESIGN_TARGET and DOMINANT_AXIS

### DESIGN_TARGET Applies At:
| Layer | How DESIGN_TARGET Applies |
|-------|---------------------------|
| **Atoms** | Reference class informs visual quality (would Apple approve?) |
| **Molecules** | Semantic grouping must feel like tier 1 references |
| **Sections** | Narrative energy must match reference class |
| **Screens** | Assembly must plausibly belong with Uber/Cash App/Duolingo |

### DOMINANT_AXIS Applies At:
| Layer | How DOMINANT_AXIS Applies |
|-------|---------------------------|
| **Atoms** | Motion must imply momentum (directional, not decorative) |
| **Molecules** | Composition must tilt urgent > calm |
| **Sections** | Narrative must favor action > reassurance |
| **Screens** | Overall feel must pass 5-axis checklist |

### Verification at Each Layer

**Atom Stress Test Addition:**
```
- [ ] Would this atom appear in Uber/Cash App/Duolingo?
- [ ] Does motion imply momentum (not decoration)?
```

**Molecule Contract Addition:**
```
### DOMINANT_AXIS Compliance
- [ ] momentum > calm
- [ ] urgency > comfort
- [ ] action > reassurance
- [ ] direction > balance
- [ ] concrete > abstract
```

**Screen Manifest Addition:**
```
### DESIGN_TARGET Verification
- [ ] Passes Reference Class Test (could appear in tier 1 apps)
- [ ] Passes Exclusion Class Test (doesn't resemble excluded patterns)
- [ ] Passes DOMINANT_AXIS 5-point checklist
```

---

## Quick Reference

```
TOKEN   → "What raw values exist?"           → Read-only, no decisions
ATOM    → "What visual primitives exist?"    → Single-purpose, isolated
MOLECULE → "What semantic units exist?"      → Atom combinations, no layout
SECTION → "What narrative fragments exist?"  → One question answered
SCREEN  → "How are sections arranged?"       → Assembly only, no invention
```

**If Cursor is inventing at the screen layer, something is broken.**

---

## Authority Chain

```
PUZZLE_MODE.md
    ↓ extends
PER/INVARIANTS.md
    ↓ enforced by
HIC v1.1
    ↓ validated by
UAP-0 through UAP-7
    ↓ locked by
COMPLETION_LOCK.md
```

This document is binding. Violations trigger PER enforcement.
