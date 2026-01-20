# Screen O11: Availability Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Hustlers set their weekly availability. Determines when they receive task notifications and appear in search results.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      When are you available?            │  ← typography.h1
│                                         │
│   You'll only see tasks during          │  ← typography.body
│   these times.                          │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Monday                          ▼   ││
│  │ ┌──────────┐  ┌──────────┐         ││
│  │ │  9:00 AM │→ │  5:00 PM │    ✕    ││
│  │ └──────────┘  └──────────┘         ││
│  │        + Add another slot          ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Tuesday                         ▼   ││
│  │ Not available                  [+]  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Wednesday                       ▼   ││
│  │ ┌──────────┐  ┌──────────┐         ││
│  │ │  9:00 AM │→ │  5:00 PM │    ✕    ││
│  │ └──────────┘  └──────────┘         ││
│  └─────────────────────────────────────┘│
│                                         │
│  ... (Thu, Fri, Sat, Sun)               │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ Available anytime                 ││  ← Quick option
│  │   24/7, get notified for all tasks  ││
│  └─────────────────────────────────────┘│
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
interface AvailabilityScreenProps {
  // Weekly schedule
  schedule?: WeeklySchedule;

  // Quick option
  availableAnytime?: boolean;

  // Callbacks
  onUpdateDay?: (day: string, slots: TimeSlot[]) => void;
  onToggleAnytime?: (enabled: boolean) => void;
  onContinue?: () => void;
  onBack?: () => void;
}

interface WeeklySchedule {
  monday: TimeSlot[];
  tuesday: TimeSlot[];
  wednesday: TimeSlot[];
  thursday: TimeSlot[];
  friday: TimeSlot[];
  saturday: TimeSlot[];
  sunday: TimeSlot[];
}

interface TimeSlot {
  id: string;
  startTime: string;  // "09:00"
  endTime: string;    // "17:00"
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Day cards | `cardStyles.outlined`, collapsible |
| Day name | `typography.body`, `fontWeight: 600` |
| Chevron | `iconSize.md`, `colors.neutral[400]` |
| Time picker | `inputStyles.default`, 100px width |
| Arrow | `colors.neutral[400]`, → |
| Remove button | `iconSize.sm`, `colors.error` |
| Add slot link | `typography.bodySmall`, `colors.primary[500]` |
| "Not available" | `typography.bodySmall`, `colors.neutral[500]` |
| Add button | 24px circle, `colors.primary[500]` |
| Anytime option | `cardStyles.outlined`, checkbox |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Day States

### Has Slots
```
┌─────────────────────────────────────────┐
│ Monday                              ▼   │  ← Expanded
│ ┌──────────┐  ┌──────────┐             │
│ │  9:00 AM │→ │  5:00 PM │        ✕    │
│ └──────────┘  └──────────┘             │
│ ┌──────────┐  ┌──────────┐             │
│ │  7:00 PM │→ │ 10:00 PM │        ✕    │
│ └──────────┘  └──────────┘             │
│        + Add another slot              │
└─────────────────────────────────────────┘
```

### No Slots
```
┌─────────────────────────────────────────┐
│ Tuesday                             ▼   │
│ Not available                      [+]  │
└─────────────────────────────────────────┘
```

### Collapsed
```
┌─────────────────────────────────────────┐
│ Monday    9 AM - 5 PM              ▶   │
└─────────────────────────────────────────┘
```

---

## Time Picker

- Opens native time picker on tap
- 30-minute increments
- Validate: end time > start time
- Validate: no overlapping slots

---

## "Available Anytime" Behavior

When checked:
- All day cards show "Available 24/7"
- Day cards are not editable
- Uncheck to customize

---

## Default Schedule

Pre-populated with common work hours:
- Monday-Friday: 9:00 AM - 5:00 PM
- Saturday-Sunday: Not available

---

## Validation

- At least one time slot required
- OR "Available anytime" checked
- No overlapping slots within a day

---

**This screen is Cursor-ready. Build exactly as specified.**
