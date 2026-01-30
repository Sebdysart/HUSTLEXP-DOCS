# Screen O6: Location Setup Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Both (Hustler & Poster)

---

## Overview

User sets their service area (Hustler) or task location (Poster). Includes map visualization and radius selection.

---

## Layout (Hustler)

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Where do you want to work?         │  ← typography.h1
│                                         │
│   We'll show you tasks within           │  ← typography.body
│   this area.                            │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📍 Search address...                ││  ← Search input
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │                                     ││
│  │         [Map with radius]           ││  ← 200px height
│  │              ◉                      ││  ← Center point
│  │            ╭───╮                    ││  ← Radius circle
│  │            ╰───╯                    ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│   Service radius                        │  ← Label
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  5mi   10mi   15mi   25mi   50mi   ││  ← Radius chips
│  │         [●]                         ││  ← Selected: 15mi
│  └─────────────────────────────────────┘│
│                                         │
│  📍 Use current location               │  ← Quick action link
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Continue                  ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Layout (Poster - Simpler)

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Where will your tasks be?          │  ← typography.h1
│                                         │
│   Hustlers nearby will see              │  ← typography.body
│   your posted tasks.                    │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📍 Search address...                ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │         [Map with pin]              ││
│  │              📍                     ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  📍 Use current location               │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Continue                  ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface LocationSetupScreenProps {
  // Role determines UI variant
  role: 'HUSTLER' | 'POSTER';

  // Location state
  address?: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  radiusMiles?: number;  // Hustler only

  // Available radius options (Hustler only)
  radiusOptions?: number[];  // [5, 10, 15, 25, 50]

  // State
  isLoadingLocation?: boolean;
  error?: Error | null;

  // Callbacks
  onAddressChange?: (address: string) => void;
  onAddressSelect?: (place: PlaceResult) => void;
  onRadiusChange?: (miles: number) => void;
  onUseCurrentLocation?: () => void;
  onContinue?: () => void;
  onBack?: () => void;
}

interface PlaceResult {
  address: string;
  latitude: number;
  longitude: number;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Search input | `inputStyles.default`, 📍 icon prefix |
| Map container | `radius.lg`, 200px height, `colors.neutral[100]` placeholder |
| Radius circle | `colors.primary[500]` stroke, `colors.primary[100]` fill (20% opacity) |
| Center point | `colors.primary[500]`, 12px dot |
| Label | `typography.bodySmall`, `colors.neutral[600]` |
| Radius chips | `spacing[2]` padding, `radius.full`, selected = `colors.primary[500]` bg |
| Current location link | `typography.body`, `colors.primary[500]`, 📍 icon |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Radius Options (Hustler)

| Value | Label |
|-------|-------|
| 5 | 5 mi |
| 10 | 10 mi |
| 15 | 15 mi (default) |
| 25 | 25 mi |
| 50 | 50 mi |

---

## Map Behavior

- Shows static map centered on selected location
- Hustler: Shows radius circle overlay
- Poster: Shows single pin
- Tapping map does NOT open full-screen map (onboarding simplicity)

---

## Validation

- Continue disabled until address is set
- "Use current location" requires location permission
- If permission denied, show prompt to enable in settings

---

**This screen is Cursor-ready. Build exactly as specified.**
