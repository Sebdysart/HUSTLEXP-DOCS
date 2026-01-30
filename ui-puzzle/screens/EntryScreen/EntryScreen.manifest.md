# Assembly Manifest: PuzzleEntryScreen

**Status:** APPROVED
**Version:** 1.0.0

---

## Sections Used

| Position | Section | Purpose |
|----------|---------|---------|
| Background | `MarketField` (molecule) | Animated gradient + particles |
| Top | `EntryHeroSection` | Brand + headline + subhead |
| Bottom | `EntryActionSection` | CTA button + sign in link |

---

## New Atoms: **NONE**

This screen introduces NO new atoms.

## New Molecules: **NONE**

This screen introduces NO new molecules.

## New Copy: **NONE**

All text comes from sections:
- "Turn time into money." → EntryHeroSection
- "Post tasks and find help..." → EntryHeroSection
- "Enter the market" → EntryActionSection
- "Already have an account? Sign in" → EntryActionSection

## New Motion: **NONE**

All animations come from lower layers:
- Mesh drift → AnimatedMeshField atom
- Particle float → ParticleField atom
- Entrance animations → MotionFadeIn atom
- Button press → PrimaryCTA atom

---

## Cursor Scope

At this layer, Cursor may ONLY:

- [x] Position sections vertically (VStack)
- [x] Apply horizontal padding (screenHorizontal)
- [x] Handle safe areas (safeAreaTop, safeAreaBottom)
- [x] Place MarketField as background
- [x] Connect callbacks to navigation

Cursor may NOT:

- [ ] Add new text
- [ ] Add new visual elements
- [ ] Modify section internals
- [ ] Add animations not in lower layers
- [ ] Invent anything

---

## UAP Compliance (Full)

- [x] UAP-0: Visible hierarchy
- [x] UAP-1: Motion continuity
- [x] UAP-2: Action clarity
- [x] UAP-3: Loading elegance
- [x] UAP-4: System cohesion
- [x] UAP-5: Edge state handling (N/A for entry)
- [x] UAP-6: Polish details
- [x] UAP-7: Emotional calibration

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `onGetStarted` | required | Primary action callback |
| `onSignIn` | required | Sign in callback |
| `animated` | true | Enable all animations |

---

## Layout Diagram

```
┌─────────────────────────────────────┐
│         SAFE AREA TOP               │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │     EntryHeroSection        │    │
│  │  - BrandCluster             │    │
│  │  - Headline                 │    │
│  │  - Subhead                  │    │
│  └─────────────────────────────┘    │
│                                     │
│           [SPACER]                  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    EntryActionSection       │    │
│  │  - PrimaryCTA               │    │
│  │  - Sign in link             │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│        SAFE AREA BOTTOM             │
└─────────────────────────────────────┘

BACKGROUND: MarketField (full bleed)
```
