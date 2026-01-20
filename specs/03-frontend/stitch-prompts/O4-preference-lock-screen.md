# Screen O4: Preference Lock Screen (Risk Preferences)
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Hustlers set their risk preferences for tasks. This determines what task categories they'll see and their verification requirements. Posters skip this screen.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │  ← Back button
│                                         │
│      What types of tasks are            │  ← typography.h1
│      you comfortable with?              │
│                                         │
│   This helps us match you with          │  ← typography.body
│   the right opportunities.              │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ☑️  Standard Tasks                 ││  ← Always selected, disabled
│  │      Deliveries, errands, cleaning  ││
│  │      No special requirements        ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ☐  Skilled Tasks                   ││
│  │      Assembly, repairs, tech help   ││
│  │      May require verification       ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ☐  Licensed Tasks                  ││
│  │      Plumbing, electrical, HVAC     ││
│  │      Requires license upload    🔒  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ☐  Insured Tasks                   ││
│  │      Moving, transport, high-value  ││
│  │      Requires insurance proof   🔒  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Continue                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ○ ○ ○ ● ○                              │  ← Progress (4 of 5)
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface PreferenceLockScreenProps {
  // Selected preferences
  preferences?: {
    standardTasks: boolean;  // Always true, not changeable
    skilledTasks: boolean;
    licensedTasks: boolean;
    insuredTasks: boolean;
  };

  // Callbacks
  onTogglePreference?: (key: string, value: boolean) => void;
  onContinue?: () => void;
  onBack?: () => void;

  // Progress
  currentStep?: number;  // 4
  totalSteps?: number;   // 5
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Back button | `iconSize.lg`, `colors.neutral[700]` |
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Preference cards | `cardStyles.outlined`, full width |
| Checkbox | 24px, `colors.primary[500]` when checked |
| Card title | `typography.body`, `colors.neutral[900]`, `fontWeight: 500` |
| Card description | `typography.bodySmall`, `colors.neutral[600]` |
| Requirements note | `typography.caption`, `colors.neutral[500]` |
| Lock icon | 16px, `colors.neutral[400]` |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Card States

### Standard Tasks (Always Selected)
```typescript
{
  checkbox: { checked: true, disabled: true },
  opacity: 1,
  backgroundColor: colors.primary[50],
  borderColor: colors.primary[200],
}
```

### Unselected
```typescript
{
  checkbox: { checked: false },
  backgroundColor: colors.neutral[0],
  borderColor: colors.neutral[200],
}
```

### Selected
```typescript
{
  checkbox: { checked: true },
  backgroundColor: colors.primary[50],
  borderColor: colors.primary[500],
}
```

---

## Task Categories

| Category | Examples | Requirements |
|----------|----------|--------------|
| Standard | Deliveries, errands, cleaning | None |
| Skilled | Assembly, repairs, tech help | May require verification |
| Licensed | Plumbing, electrical, HVAC | License upload required |
| Insured | Moving, transport, high-value | Insurance proof required |

---

## Behavior

- Standard Tasks is always checked and disabled (can't uncheck)
- Other preferences can be toggled
- If Licensed or Insured is selected, next screens will prompt for verification
- Continue is always enabled (Standard Tasks is baseline)

---

## Verification Note

When locked categories are selected:
```
Note: Selecting licensed or insured tasks will
require verification during setup.
```

---

**This screen is Cursor-ready. Build exactly as specified.**
