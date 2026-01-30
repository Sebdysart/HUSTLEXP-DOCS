# Screen H4: En Route Map Screen (Hustler Navigation)
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Full-screen navigation view when hustler is traveling to task location. Shows route, ETA, and quick actions.

---

## Layout

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│                                         │
│                                         │
│           [Full Screen Map]             │
│                                         │
│               🔵                        │  ← Hustler location
│                ╲                        │
│                 ╲                       │
│                  ╲                      │  ← Route line
│                   ╲                     │
│                    📍                   │  ← Task location
│                                         │
│                                         │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  Move furniture to storage          ││  ← Task title
│  │                                     ││
│  │  📍 123 Main St                     ││  ← Address
│  │                                     ││
│  │  ┌───────────────────────────────┐  ││
│  │  │  ETA: 12 min  •  2.3 mi       │  ││  ← ETA chip
│  │  └───────────────────────────────┘  ││
│  │                                     ││
│  │  ┌─────────┐  ┌─────────┐  ┌─────┐ ││
│  │  │ Navigate│  │ Message │  │ Call│ ││  ← Quick actions
│  │  └─────────┘  └─────────┘  └─────┘ ││
│  │                                     ││
│  │  ┌─────────────────────────────────┐││
│  │  │       I've Arrived              │││  ← Primary button
│  │  └─────────────────────────────────┘││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface EnRouteMapScreenProps {
  // Task data
  task?: {
    id: string;
    title: string;
    address: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
    poster: {
      id: string;
      displayName: string;
      phone?: string;  // Only after acceptance
    };
  };

  // Navigation data
  route?: {
    etaMinutes: number;
    distanceMiles: number;
    polyline?: string;  // Encoded polyline
  };

  // Current location
  currentLocation?: {
    latitude: number;
    longitude: number;
  };

  // State
  isLoading?: boolean;
  error?: Error | null;

  // Callbacks
  onNavigate?: () => void;         // Open in Maps app
  onMessage?: () => void;
  onCall?: () => void;
  onArrived?: () => void;
  onCancel?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Map | Full screen, extends behind status bar |
| Hustler marker | Blue dot with pulse animation |
| Task marker | `colors.primary[500]` pin |
| Route line | `colors.primary[500]`, 4px width |
| Bottom sheet | `colors.neutral[0]`, `radius.xl` top corners, shadow |
| Task title | `typography.body`, `fontWeight: 600` |
| Address | `typography.bodySmall`, `colors.neutral[600]` |
| ETA chip | `colors.neutral[100]` bg, `typography.body` |
| Quick action buttons | `buttonVariants.secondary`, icon + label |
| Arrived button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Quick Actions

| Action | Icon | Behavior |
|--------|------|----------|
| Navigate | Navigation arrow | Opens Apple Maps/Google Maps with directions |
| Message | Chat bubble | Opens in-app message thread |
| Call | Phone | Initiates phone call to poster |

---

## Map Behavior

- Auto-centers on route
- Shows hustler location (blue dot)
- Shows task location (pin)
- Draws route between points
- Updates ETA in real-time

---

## ETA Updates

- Refresh every 30 seconds
- Show "Calculating..." while loading
- If no route available: "ETA unavailable"

---

## "I've Arrived" Button

- Enabled when within 100m of task location
- When tapped:
  1. Triggers location verification
  2. Updates task status to `ARRIVED`
  3. Navigates to Active Task screen
  4. Notifies poster

---

## Bottom Sheet Behavior

- Default: Peek state (shows title + ETA + actions)
- Swipe up: Expands to show full details
- Swipe down: Collapses to peek state
- Does NOT dismiss (task context must stay visible)

---

## Cancel Option

Available in overflow menu:
```
⚠️ Cancel Task

Are you sure? Cancelling after acceptance
may affect your trust score.

[Keep Task]  [Cancel]
```

---

**This screen is Cursor-ready. Build exactly as specified.**
