# UI PUZZLE — HUSTLEXP COMPONENT SYSTEM

**STATUS: FROZEN — These are the ONLY building blocks**

---

## PURPOSE

This directory contains the **locked building blocks** for HustleXP UI.

Cursor/AI tools read these specs to understand WHAT components exist.
They may NOT create new components without explicit approval.

---

## DIRECTORY STRUCTURE

```
ui-puzzle/
├── README.md              ← You are here
├── atoms/                 ← Primitive elements (LOCKED)
│   ├── ATOM_REGISTRY.md   ← Index of all atoms
│   ├── Button.md          ← Button spec
│   ├── Text.md            ← Text spec
│   ├── Input.md           ← Input spec
│   └── ...
├── molecules/             ← Composite elements (LOCKED)
│   ├── MOLECULE_REGISTRY.md
│   ├── TaskCard.md
│   ├── UserHeader.md
│   └── ...
├── sections/              ← Screen regions (LOCKED)
│   ├── SECTION_REGISTRY.md
│   ├── ScreenHeader.md
│   ├── ActionFooter.md
│   └── ...
├── screens/               ← Archetype templates (LOCKED)
│   └── ARCHETYPE_TEMPLATES.md
└── tokens/                ← Design tokens (LOCKED)
    ├── colors.md
    ├── spacing.md
    ├── typography.md
    └── motion.md
```

---

## USAGE RULES

### For Cursor/AI:

1. **BEFORE building any screen**, read this directory
2. **IDENTIFY** which atoms and molecules you need
3. **USE ONLY** what exists here
4. **IF MISSING**, STOP and ask — do NOT invent

### For Humans:

1. **To add a new atom/molecule**, create spec file first
2. **Get approval** before implementation
3. **Lock it** after implementation passes stress test

---

## QUICK REFERENCE

### Atoms (9 total)
- Button, Text, Input, Icon, Avatar, Badge, Divider, Spacer, Image

### Molecules (12 total)
- TaskCard, UserHeader, PriceDisplay, RatingStars, ProgressBar
- StatusBadge, EmptyState, ErrorState, LoadingState, ListItem
- FormField, ActionBar

### Sections (5 total)
- ScreenHeader, ContentScroll, ActionFooter, FilterBar, TabBar

### Archetypes (6 total)
- A. Entry/Commitment
- B. Feed/Opportunity
- C. Task Lifecycle
- D. Calibration/Capability
- E. Progress/Status
- F. System/Interrupt

---

## ENFORCEMENT

This directory is referenced by:
- `.cursorrules` (enforcement)
- `UI_COMPONENT_HIERARCHY.md` (documentation)
- `EXECUTION_QUEUE.md` (build steps)

**Components not in this directory DO NOT EXIST.**
