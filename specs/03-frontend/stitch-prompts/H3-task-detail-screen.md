# Screen H3: Task Detail Screen (Hustler View)
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Shows full task details before acceptance. Includes eligibility status, requirements, poster info, and accept action.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                 ⋮     │  ← Back + overflow menu
├─────────────────────────────────────────┤
│                                         │
│  Move furniture to storage              │  ← typography.h1
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        $75.00                       ││  ← Price card
│  │        + potential tip              ││
│  │                                     ││
│  │  🛡️ HustleXP Protected              ││  ← Protection badge
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📍 Location                         ││
│  │    123 Main St, Austin TX           ││
│  │    0.8 miles away                   ││
│  │                                     ││
│  │    [Map Preview]                    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🕐 Timing                           ││
│  │    Today, 2:00 PM - 5:00 PM         ││
│  │    Estimated 2-3 hours              ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📋 Task Details                     ││
│  │                                     ││
│  │    Help move a couch, bookshelf,    ││
│  │    and several boxes from 3rd       ││
│  │    floor apartment to storage       ││
│  │    unit (ground floor, same         ││
│  │    building).                       ││
│  │                                     ││
│  │    Requirements:                    ││
│  │    • Able to lift 50+ lbs           ││
│  │    • No equipment needed            ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 👤 Posted by                        ││
│  │                                     ││
│  │    [Avatar] Sarah M.                ││
│  │    ⭐ 4.8 (23 tasks posted)         ││
│  │    Member since Jan 2024            ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │          Accept Task                ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface TaskDetailScreenProps {
  // Task data
  task?: TaskDetail;

  // Eligibility
  isEligible?: boolean;
  eligibilityReason?: string;  // If not eligible

  // State
  isLoading?: boolean;
  isAccepting?: boolean;
  error?: Error | null;

  // Callbacks
  onAccept?: () => void;
  onBack?: () => void;
  onReport?: () => void;
  onShare?: () => void;
}

interface TaskDetail {
  id: string;
  title: string;
  description: string;
  price: number;              // cents
  tipEnabled: boolean;

  location: {
    address: string;
    city: string;
    state: string;
    distanceMiles: number;
    coordinates?: {
      latitude: number;
      longitude: number;
    };
  };

  timing: {
    date: string;             // "Today" or date
    timeWindow: string;       // "2:00 PM - 5:00 PM"
    estimatedDuration: string;
  };

  requirements?: string[];

  category: string;
  isInstant: boolean;

  poster: {
    id: string;
    displayName: string;
    avatarUrl?: string;
    rating: number;
    taskCount: number;
    memberSince: string;
  };

  postedAt: string;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Back button, overflow menu |
| Title | `typography.h1`, `colors.neutral[900]` |
| Price card | `colors.success` tint bg, centered |
| Price | `typography.display`, `colors.success` |
| Tip note | `typography.caption`, `colors.neutral[600]` |
| Protection badge | `colors.primary[500]` icon + text |
| Section cards | `cardStyles.outlined` |
| Section icon | 24px, `colors.neutral[500]` |
| Section title | `typography.bodySmall`, `colors.neutral[500]` |
| Section content | `typography.body`, `colors.neutral[900]` |
| Map preview | 120px height, `radius.lg` |
| Requirements | `typography.body`, bullet list |
| Poster avatar | 48px circle |
| Poster name | `typography.body`, `fontWeight: 600` |
| Poster rating | `colors.accent[500]` star |
| Poster stats | `typography.caption`, `colors.neutral[600]` |
| Accept button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Ineligible State

When `isEligible: false`:

```
┌─────────────────────────────────────────┐
│ ⚠️ You're not eligible for this task   │
│                                         │
│ Reason: Trust Tier 2 required           │
│ Your tier: Rookie (Tier 1)              │
│                                         │
│ [View Requirements]                     │
└─────────────────────────────────────────┘

Button: Accept Task (disabled, grayed out)
```

---

## Accepting State

- Button shows spinner
- Button text: "Accepting..."
- All interactions disabled

---

## Overflow Menu

| Action | Icon |
|--------|------|
| Share Task | Share icon |
| Report Task | Flag icon |

---

## Map Interaction

- Static map preview
- Tap opens full-screen map
- Shows task location pin only (not exact address until accepted)

---

**This screen is Cursor-ready. Build exactly as specified.**
