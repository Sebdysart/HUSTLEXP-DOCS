# Screen O1: Framing Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES

---

## Overview

First onboarding screen. Establishes HustleXP value proposition and sets expectations. This is Layer 1 (Apple Glass) - clean, professional, no gamification.

---

## Layout

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            [HustleXP Logo]              │  ← 100px, centered
│                                         │
│                                         │
│         Welcome to HustleXP             │  ← typography.h1
│                                         │
│    The marketplace for local tasks      │  ← typography.bodyLarge
│    done right, paid fast.               │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🎯  Post tasks, get help fast       ││  ← Value prop 1
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 💰  Earn money on your schedule     ││  ← Value prop 2
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✅  Secure payments, always         ││  ← Value prop 3
│  └─────────────────────────────────────┘│
│                                         │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Get Started               ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│  ○ ○ ○ ○ ○                              │  ← Progress dots (1 of 5)
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface FramingScreenProps {
  // Navigation
  onContinue?: () => void;

  // Progress
  currentStep?: number;  // 1
  totalSteps?: number;   // 5
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Logo | 100px height, centered |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Subtitle | `typography.bodyLarge`, `colors.neutral[600]`, centered |
| Value prop cards | `cardStyles.outlined`, `spacing[4]` padding |
| Icons | 24px, `colors.primary[500]` |
| Value prop text | `typography.body`, `colors.neutral[700]` |
| Button | `buttonVariants.primary`, `buttonSizes.lg`, full width |
| Progress dots | 8px circles, active = `colors.primary[500]`, inactive = `colors.neutral[300]` |

---

## Value Props

| Icon | Text |
|------|------|
| 🎯 | Post tasks, get help fast |
| 💰 | Earn money on your schedule |
| ✅ | Secure payments, always |

---

## Animation

- Cards fade in sequentially (200ms delay each)
- Total entrance: 600ms
- Use `easing.decelerate`

---

## Accessibility

- Progress dots have "Step 1 of 5" label
- Button has clear action label

---

**This screen is Cursor-ready. Build exactly as specified.**
