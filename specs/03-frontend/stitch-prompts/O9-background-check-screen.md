# Screen O9: Background Check Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only (optional)

---

## Overview

Explains and initiates background check process. Optional but unlocks trust tier progression and premium tasks.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│            🔒                           │  ← Shield icon 64px
│                                         │
│      Build trust with a                 │  ← typography.h1
│      background check                   │
│                                         │
│   Verified hustlers earn more and       │  ← typography.body
│   get matched with premium tasks.       │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  What's included:                       │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✓ Identity verification             ││
│  │ ✓ Criminal background check         ││
│  │ ✓ Sex offender registry check       ││
│  │ ✓ SSN trace                         ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🕐 Takes about 3-5 business days    ││
│  │ 💰 One-time fee: $29.99             ││
│  │ 🔄 Valid for 2 years                ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🛡️ Your data is encrypted and       ││
│  │   securely processed by Checkr.     ││
│  │   Learn more →                      ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │      Start Background Check         ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│            Maybe later                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface BackgroundCheckScreenProps {
  // Check status
  checkStatus?: 'NOT_STARTED' | 'IN_PROGRESS' | 'COMPLETE' | 'FAILED' | null;
  estimatedCompletionDate?: string;

  // Fee info
  fee?: {
    amount: number;  // cents
    validityYears: number;
  };

  // Callbacks
  onStart?: () => void;
  onSkip?: () => void;
  onLearnMore?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Shield icon | 64px, `colors.primary[500]` |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Subtitle | `typography.body`, `colors.neutral[600]`, centered |
| Section label | `typography.bodySmall`, `colors.neutral[600]` |
| Checklist card | `colors.success` tint background (5%), `radius.lg` |
| Checkmarks | `colors.success`, 20px |
| Check items | `typography.body`, `colors.neutral[700]` |
| Info card | `cardStyles.outlined` |
| Info icons | 20px, `colors.neutral[500]` |
| Info text | `typography.bodySmall`, `colors.neutral[700]` |
| Security card | `colors.primary[50]` background |
| Security icon | 20px, `colors.primary[500]` |
| Learn more link | `colors.primary[500]` |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |
| Skip link | `typography.body`, `colors.neutral[500]` |

---

## Background Check Includes

| Item |
|------|
| Identity verification |
| Criminal background check |
| Sex offender registry check |
| SSN trace |

---

## Info Items

| Icon | Text |
|------|------|
| 🕐 | Takes about 3-5 business days |
| 💰 | One-time fee: $29.99 |
| 🔄 | Valid for 2 years |

---

## States

### Not Started (Default)
- Show "Start Background Check" button
- Fee displayed

### In Progress
```
┌─────────────────────────────────────────┐
│ ⏳ Background check in progress         │
│                                         │
│   Started: Jan 15, 2025                 │
│   Estimated completion: Jan 20, 2025    │
│                                         │
│   We'll notify you when complete.       │
└─────────────────────────────────────────┘

Button: Continue Setup (enabled)
```

### Complete (Success)
```
┌─────────────────────────────────────────┐
│ ✅ Background check passed!             │
│                                         │
│   Verified on: Jan 18, 2025             │
│   Valid until: Jan 18, 2027             │
│                                         │
│   You're now eligible for premium       │
│   tasks and faster trust progression.   │
└─────────────────────────────────────────┘

Button: Continue (enabled)
```

### Failed
```
┌─────────────────────────────────────────┐
│ ❌ Background check issue               │
│                                         │
│   We found an issue with your check.    │
│   This may affect your eligibility for  │
│   certain tasks.                        │
│                                         │
│   Contact support →                     │
└─────────────────────────────────────────┘

Button: Continue Anyway (enabled)
```

---

## Payment Flow

1. User taps "Start Background Check"
2. Payment sheet appears (Apple Pay / Google Pay / Card)
3. On success, redirect to Checkr flow
4. On completion, return to app with status update

---

**This screen is Cursor-ready. Build exactly as specified.**
