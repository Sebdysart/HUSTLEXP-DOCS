# UI COMPONENT HIERARCHY — HUSTLEXP v1.0

**STATUS: FROZEN — This defines how UI is built**  
**Rule: Screens ASSEMBLE. They do not INVENT.**

---

## THE PUZZLE MODEL

HustleXP UI is built as a **PUZZLE**, not as isolated screens.

```
┌─────────────────────────────────────────────────────────────┐
│                         SCREENS                              │
│   (Assembly ONLY — no invention allowed at this level)       │
├─────────────────────────────────────────────────────────────┤
│                         SECTIONS                             │
│   (Narrative regions — header, content, actions, footer)     │
├─────────────────────────────────────────────────────────────┤
│                        MOLECULES                             │
│   (Combinations of atoms — cards, forms, lists)              │
├─────────────────────────────────────────────────────────────┤
│                          ATOMS                               │
│   (Primitive elements — buttons, inputs, text, icons)        │
└─────────────────────────────────────────────────────────────┘
```

---

## HIERARCHY RULES

### Level 1: ATOMS (Primitives)
```
Definition: Single-purpose visual elements
Examples: Button, Text, Input, Icon, Avatar, Badge
Location: reference/components/atoms/

Rules:
- ✅ Locked once approved
- ✅ Used across all screens
- ❌ Never modified for specific screens
- ❌ Never duplicated with variations
```

### Level 2: MOLECULES (Combinations)
```
Definition: Combinations of atoms with specific purpose
Examples: TaskCard, UserHeader, PriceDisplay, RatingStars, ProgressBar
Location: reference/components/molecules/

Rules:
- ✅ Locked once approved
- ✅ Composed of atoms only
- ✅ Reusable across screens
- ❌ Never contain business logic
- ❌ Never fetch data
```

### Level 3: SECTIONS (Regions)
```
Definition: Narrative regions of a screen
Examples: HeaderSection, ContentSection, ActionSection, FooterSection
Location: Built inline per screen

Rules:
- ✅ Composed of molecules and atoms
- ✅ May have layout logic (flex, scroll)
- ❌ Never contain business logic
- ❌ Never fetch data
```

### Level 4: SCREENS (Assembly)
```
Definition: Full-page views assembled from sections
Examples: TaskFeedScreen, HustlerHomeScreen, SettingsMainScreen
Location: src/screens/[category]/

Rules:
- ✅ ASSEMBLY ONLY — no new visuals
- ✅ Receive all data via props
- ✅ Pass data down to sections
- ❌ Never invent new components
- ❌ Never contain business logic
- ❌ Never fetch data
```

---

## ENFORCEMENT

### If you need a new visual at the Screen level:

```
STOP.

1. Identify which Atom or Molecule is missing
2. Create it at the correct layer
3. Get approval
4. Lock it
5. THEN use it in screens
```

### Cursor is FORBIDDEN from:

```
❌ Creating inline styled components in screens
❌ Duplicating molecules with minor variations
❌ Adding "just this once" visual elements
❌ Treating screens as unique design problems
```

---

## VISUAL INVENTORY (Current)

### Atoms (Locked)
```
- Button (primary, secondary, ghost, danger)
- Text (heading, body, caption, label)
- Input (text, password, number, multiline)
- Icon (from approved icon set only)
- Avatar (small, medium, large)
- Badge (status, count, tier)
- Divider (horizontal, vertical)
- Spacer (xs, sm, md, lg, xl)
```

### Molecules (Locked)
```
- TaskCard (compact, expanded)
- UserHeader (with avatar, stats)
- PriceDisplay (amount, currency, status)
- RatingStars (display, input)
- ProgressBar (linear, circular)
- StatusBadge (task states)
- EmptyState (icon, message, action)
- ErrorState (icon, message, retry)
- LoadingState (spinner, skeleton)
- ListItem (icon, text, action)
- FormField (label, input, error)
- ActionBar (primary, secondary actions)
```

### Sections (Patterns)
```
- ScreenHeader (title, back, actions)
- ContentScroll (scrollable content area)
- ActionFooter (sticky bottom actions)
- FilterBar (sort, filter controls)
- TabBar (bottom navigation)
```

---

## WHY THIS MATTERS

Without the puzzle model:
- Every screen becomes a unique design problem
- Inconsistency compounds
- Technical debt grows
- Quality degrades as screens multiply

With the puzzle model:
- Screens are predictable
- Quality is consistent
- Changes propagate correctly
- 38 screens feel like ONE product
