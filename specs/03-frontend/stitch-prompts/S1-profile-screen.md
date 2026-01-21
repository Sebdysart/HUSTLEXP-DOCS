# Screen S1: Profile Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md, POSTER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Both (different content per role)

---

## Overview

User profile showing stats, verification status, and account settings. Hustler version includes XP/trust tier; Poster version is simpler.

---

## Layout (Hustler)

```
┌─────────────────────────────────────────┐
│ Profile                           ⚙️    │  ← Settings gear
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │           [Avatar]                  ││  ← 80px
│  │                                     ││
│  │         John Doe                    ││  ← Name
│  │         @johndoe                    ││  ← Username
│  │                                     ││
│  │    ⭐ 4.9  •  152 tasks completed   ││  ← Stats
│  │    Member since Jan 2024            ││
│  │                                     ││
│  │         [Edit Profile]              ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🏆 Level 12                         ││  ← XP card
│  │                                     ││
│  │ ████████████░░░░░░  2,450 / 3,000   ││  ← Progress bar
│  │                                     ││
│  │ 550 XP to Level 13                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🛡️ Trust Tier: TRUSTED (3)         ││  ← Trust tier card
│  │                                     ││
│  │ ████████████████░░  85%             ││
│  │                                     ││
│  │ Complete 5 more tasks for Elite     ││
│  │                     View Ladder →   ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📊 This Month                       ││
│  │                                     ││
│  │ Tasks: 18        Earnings: $1,245   ││
│  │ Hours: 42        Avg Rating: 4.9    ││
│  │                                     ││
│  │                     View History →  ││
│  └─────────────────────────────────────┘│
│                                         │
│  Verification Status                    │
│  ─────────────────────────────────────  │
│                                         │
│  ✅ Background Check                    │
│  ✅ Identity Verified                   │
│  ⏳ Insurance (pending)                 │
│  ○  License                            │
│                                         │
└─────────────────────────────────────────┘
```

---

## Layout (Poster)

```
┌─────────────────────────────────────────┐
│ Profile                           ⚙️    │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │           [Avatar]                  ││
│  │                                     ││
│  │         Sarah Miller                ││
│  │         @sarahm                     ││
│  │                                     ││
│  │    ⭐ 4.8  •  23 tasks posted       ││
│  │    Member since Mar 2024            ││
│  │                                     ││
│  │         [Edit Profile]              ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📊 Task Summary                     ││
│  │                                     ││
│  │ Total Posted: 23                    ││
│  │ Completed: 21                       ││
│  │ Active: 2                           ││
│  │ Avg Rating Given: 4.7               ││
│  │                                     ││
│  │                     View History →  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 💳 Payment Methods                  ││
│  │                                     ││
│  │ Visa •••• 4242                      ││
│  │ Apple Pay                           ││
│  │                                     ││
│  │                          Manage →   ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface ProfileScreenProps {
  // Role
  role: 'HUSTLER' | 'POSTER';

  // User data
  user?: UserProfile;

  // Hustler-specific
  hustlerStats?: {
    level: number;
    currentXP: number;
    xpForNextLevel: number;
    trustTier: 1 | 2 | 3 | 4;
    trustTierName: 'ROOKIE' | 'VERIFIED' | 'TRUSTED' | 'ELITE';
    trustProgress: number;  // 0-100
    tasksToNextTier: number;
    monthlyTasks: number;
    monthlyEarnings: number;
    monthlyHours: number;
    averageRating: number;
  };

  // Poster-specific
  posterStats?: {
    totalPosted: number;
    completed: number;
    active: number;
    averageRatingGiven: number;
    paymentMethods: PaymentMethod[];
  };

  // Verification
  verifications?: Verification[];

  // Callbacks
  onEditProfile?: () => void;
  onSettings?: () => void;
  onViewTrustLadder?: () => void;
  onViewHistory?: () => void;
  onManagePayments?: () => void;
}

interface UserProfile {
  id: string;
  displayName: string;
  username: string;
  avatarUrl?: string;
  rating: number;
  taskCount: number;  // Completed (hustler) or posted (poster)
  memberSince: string;
}

interface Verification {
  type: 'BACKGROUND_CHECK' | 'IDENTITY' | 'INSURANCE' | 'LICENSE';
  status: 'VERIFIED' | 'PENDING' | 'NOT_STARTED' | 'FAILED';
  verifiedAt?: string;
}

interface PaymentMethod {
  id: string;
  type: 'CARD' | 'APPLE_PAY' | 'GOOGLE_PAY';
  lastFour?: string;
  brand?: string;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Title + settings gear |
| Avatar | 80px circle, fallback to initials |
| Name | `typography.h2`, `colors.neutral[900]` |
| Username | `typography.body`, `colors.neutral[500]` |
| Stats row | `typography.bodySmall`, `colors.neutral[600]` |
| Edit button | `buttonVariants.secondary`, `buttonSizes.sm` |
| Stat cards | `cardStyles.default` |
| Card icon | 24px |
| Card title | `typography.bodySmall`, `colors.neutral[500]` |
| Progress bar | `progressTokens.xpProgress` |
| XP value | `typography.body`, `colors.neutral[900]` |
| Trust tier | `trustTierColors[tier]` |
| Section header | `typography.bodySmall`, `colors.neutral[500]` |
| Verification items | List with status icons |
| Verified | ✅ `colors.success` |
| Pending | ⏳ `colors.warning` |
| Not started | ○ `colors.neutral[400]` |
| Failed | ❌ `colors.error` |

---

## Trust Tier Display

| Tier | Name | Color |
|------|------|-------|
| 1 | ROOKIE | `trustTierColors[1]` |
| 2 | VERIFIED | `trustTierColors[2]` |
| 3 | TRUSTED | `trustTierColors[3]` |
| 4 | ELITE | `trustTierColors[4]` |

---

**This screen is Cursor-ready. Build exactly as specified.**
