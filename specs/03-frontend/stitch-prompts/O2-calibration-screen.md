# Screen O2: Calibration Screen (Role Selection)
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES

---

## Overview

User selects their primary role: Hustler (do tasks) or Poster (post tasks). This determines their default experience and onboarding path.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │  ← Back button
│                                         │
│         How do you want to              │  ← typography.h1
│            use HustleXP?                │
│                                         │
│    You can always do both later.        │  ← typography.body, secondary
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │      🔨                             ││  ← Icon 48px
│  │                                     ││
│  │      I want to HUSTLE               ││  ← Title
│  │                                     ││
│  │      Complete tasks and earn        ││  ← Description
│  │      money on my schedule           ││
│  │                                     ││
│  │      • Choose your tasks            ││  ← Bullet points
│  │      • Set your availability        ││
│  │      • Get paid same-day            ││
│  │                                     ││
│  └─────────────────────────────────────┘│  ← Selectable card
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │      📋                             ││
│  │                                     ││
│  │      I want to POST                 ││
│  │                                     ││
│  │      Get help with tasks around     ││
│  │      your home or business          ││
│  │                                     ││
│  │      • Post in minutes              ││
│  │      • Verified helpers             ││
│  │      • Secure payments              ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  ○ ● ○ ○ ○                              │  ← Progress dots (2 of 5)
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface CalibrationScreenProps {
  // Selection state
  selectedRole?: 'HUSTLER' | 'POSTER' | null;

  // Callbacks
  onSelectRole?: (role: 'HUSTLER' | 'POSTER') => void;
  onBack?: () => void;

  // Progress
  currentStep?: number;  // 2
  totalSteps?: number;   // 5
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Back button | `iconSize.lg`, `colors.neutral[700]` |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Subtitle | `typography.body`, `colors.neutral[600]`, centered |
| Role cards | `cardStyles.outlined`, full width, `spacing[4]` padding |
| Selected card | `colors.primary[500]` border (2px), `colors.primary[50]` background |
| Card icon | 48px, `colors.primary[500]` |
| Card title | `typography.h3`, `colors.neutral[900]` |
| Card description | `typography.body`, `colors.neutral[600]` |
| Bullet points | `typography.bodySmall`, `colors.neutral[700]` |
| Progress dots | 8px, active = `colors.primary[500]` |

---

## Selection Behavior

- Tapping a card selects it AND navigates to next screen
- No separate "Continue" button needed
- Selection triggers `onSelectRole` callback

---

## Card States

### Unselected
```typescript
{
  borderColor: colors.neutral[200],
  backgroundColor: colors.neutral[0],
}
```

### Selected (on press)
```typescript
{
  borderColor: colors.primary[500],
  borderWidth: 2,
  backgroundColor: colors.primary[50],
}
```

### Pressed (feedback)
```typescript
{
  transform: [{ scale: 0.98 }],
  opacity: 0.9,
}
```

---

## Role Data

### Hustler Card
| Field | Value |
|-------|-------|
| Icon | 🔨 (or Hammer from lucide) |
| Title | I want to HUSTLE |
| Description | Complete tasks and earn money on my schedule |
| Bullets | Choose your tasks, Set your availability, Get paid same-day |

### Poster Card
| Field | Value |
|-------|-------|
| Icon | 📋 (or ClipboardList from lucide) |
| Title | I want to POST |
| Description | Get help with tasks around your home or business |
| Bullets | Post in minutes, Verified helpers, Secure payments |

---

**This screen is Cursor-ready. Build exactly as specified.**
