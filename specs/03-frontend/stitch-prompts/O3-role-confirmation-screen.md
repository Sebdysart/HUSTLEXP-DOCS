# Screen O3: Role Confirmation Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES

---

## Overview

Confirms selected role and explains what's next in the onboarding flow. Different content for Hustler vs Poster paths.

---

## Layout (Hustler)

```
┌─────────────────────────────────────────┐
│ ←                                       │  ← Back button
│                                         │
│            ✅                           │  ← Success icon, 64px
│                                         │
│         Great choice!                   │  ← typography.h1
│      You're becoming a Hustler          │  ← typography.h3, primary color
│                                         │
├─────────────────────────────────────────┤
│                                         │
│   Here's what we'll set up:             │  ← typography.body
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 1. 📍 Your service area             ││
│  │    Where you want to work           ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 2. 🛠️  Your capabilities            ││
│  │    What tasks you can do            ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 3. 📅 Your availability             ││
│  │    When you're ready to hustle      ││
│  └─────────────────────────────────────┘│
│                                         │
│   Takes about 3 minutes                 │  ← typography.caption
│                                         │
│  ┌─────────────────────────────────────┐│
│  │          Let's Go                   ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│  ○ ○ ● ○ ○                              │  ← Progress (3 of 5)
│                                         │
└─────────────────────────────────────────┘
```

---

## Layout (Poster)

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│            ✅                           │
│                                         │
│         Great choice!                   │
│      You're becoming a Poster           │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│   Here's what we'll set up:             │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 1. 📍 Your location                 ││
│  │    Where tasks will be              ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 2. 💳 Payment method                ││
│  │    How you'll pay for tasks         ││
│  └─────────────────────────────────────┘│
│                                         │
│   Takes about 2 minutes                 │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │          Let's Go                   ││
│  └─────────────────────────────────────┘│
│                                         │
│  ○ ○ ● ○ ○                              │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface RoleConfirmationScreenProps {
  // Role from previous step
  role: 'HUSTLER' | 'POSTER';

  // Callbacks
  onContinue?: () => void;
  onBack?: () => void;

  // Progress
  currentStep?: number;  // 3
  totalSteps?: number;   // 5
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Back button | `iconSize.lg`, `colors.neutral[700]` |
| Success icon | 64px, `colors.success` |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Role label | `typography.h3`, `colors.primary[500]`, centered |
| Section label | `typography.body`, `colors.neutral[600]` |
| Step cards | `cardStyles.outlined`, `spacing[3]` padding |
| Step number | `typography.bodySmall`, `colors.primary[500]` |
| Step icon | 20px, `colors.neutral[600]` |
| Step title | `typography.body`, `colors.neutral[900]`, `fontWeight: 500` |
| Step description | `typography.bodySmall`, `colors.neutral[600]` |
| Time estimate | `typography.caption`, `colors.neutral[500]`, centered |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |

---

## Steps Content

### Hustler Steps
| # | Icon | Title | Description |
|---|------|-------|-------------|
| 1 | 📍 | Your service area | Where you want to work |
| 2 | 🛠️ | Your capabilities | What tasks you can do |
| 3 | 📅 | Your availability | When you're ready to hustle |

### Poster Steps
| # | Icon | Title | Description |
|---|------|-------|-------------|
| 1 | 📍 | Your location | Where tasks will be |
| 2 | 💳 | Payment method | How you'll pay for tasks |

---

## Animation

- Steps fade/slide in sequentially (150ms delay each)
- Success icon has scale-in animation

---

**This screen is Cursor-ready. Build exactly as specified.**
