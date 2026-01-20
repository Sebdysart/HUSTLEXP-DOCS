# Screen S3: Work Eligibility Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Shows hustler's current capabilities, verifications, and what's needed to unlock more task categories. Central place to manage work eligibility.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←  Work Eligibility                     │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🎯 Current Access                   ││
│  │                                     ││
│  │ You can accept 68% of tasks         ││  ← Eligibility %
│  │                                     ││
│  │ ████████████████░░░░  68%           ││  ← Progress bar
│  │                                     ││
│  │ Complete verifications below to     ││
│  │ unlock more opportunities.          ││
│  └─────────────────────────────────────┘│
│                                         │
│  Your Capabilities                      │  ← Section header
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☑️ Physical Tasks                   ││  ← Enabled capability
│  │    Moving, lifting, delivery        ││
│  │                              Edit → ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☑️ Transportation                   ││
│  │    Vehicle: 2019 Honda Civic        ││
│  │                              Edit → ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ Skilled Trades                    ││  ← Disabled
│  │    Requires verification            ││
│  │                              Add → ││
│  └─────────────────────────────────────┘│
│                                         │
│  Verifications                          │  ← Section header
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✅ Background Check                 ││
│  │    Verified Jan 18, 2025            ││
│  │    Valid until Jan 2027             ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✅ Identity Verification            ││
│  │    Verified Jan 15, 2025            ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ⏳ Insurance                        ││  ← Pending
│  │    Under review (1-2 days)          ││
│  │                       View Status → ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ○ Trade License                     ││  ← Not started
│  │    Required for licensed work       ││
│  │                              Add → ││
│  └─────────────────────────────────────┘│
│                                         │
│  Unlock More Tasks                      │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🔓 Get insurance verified           ││  ← Unlock suggestion
│  │    +15% more task access            ││
│  │                                     ││
│  │    Unlocks: Moving, transport,      ││
│  │    high-value deliveries            ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface WorkEligibilityScreenProps {
  // Overall eligibility
  eligibilityPercent?: number;

  // Capabilities
  capabilities?: Capability[];

  // Verifications
  verifications?: Verification[];

  // Unlock suggestions
  unlockSuggestions?: UnlockSuggestion[];

  // State
  isLoading?: boolean;
  error?: Error | null;

  // Callbacks
  onEditCapability?: (capabilityId: string) => void;
  onAddCapability?: (type: string) => void;
  onViewVerification?: (verificationId: string) => void;
  onStartVerification?: (type: string) => void;
  onBack?: () => void;
}

interface Capability {
  id: string;
  type: 'PHYSICAL' | 'TRANSPORTATION' | 'SKILLED' | 'LICENSED';
  name: string;
  description: string;
  isEnabled: boolean;
  details?: string;  // "Vehicle: 2019 Honda Civic"
  requiresVerification?: string[];
}

interface Verification {
  id: string;
  type: 'BACKGROUND_CHECK' | 'IDENTITY' | 'INSURANCE' | 'LICENSE';
  name: string;
  status: 'VERIFIED' | 'PENDING' | 'NOT_STARTED' | 'EXPIRED' | 'FAILED';
  verifiedAt?: string;
  expiresAt?: string;
  statusDetail?: string;  // "Under review (1-2 days)"
}

interface UnlockSuggestion {
  id: string;
  title: string;
  accessIncrease: number;  // percentage points
  unlocksDescription: string;
  action: string;  // verification type to start
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Back button + title |
| Access card | `colors.primary[50]` bg |
| Percent text | `typography.body`, `colors.neutral[700]` |
| Progress bar | `progressTokens.linearProgress`, `colors.primary[500]` fill |
| Helper text | `typography.bodySmall`, `colors.neutral[600]` |
| Section header | `typography.bodySmall`, `colors.neutral[500]` |
| Capability cards | `cardStyles.outlined` |
| Enabled checkbox | ☑️ `colors.primary[500]` |
| Disabled checkbox | ☐ `colors.neutral[400]` |
| Capability name | `typography.body`, `fontWeight: 500` |
| Capability desc | `typography.bodySmall`, `colors.neutral[600]` |
| Edit/Add link | `typography.bodySmall`, `colors.primary[500]` |
| Verified icon | ✅ `colors.success` |
| Pending icon | ⏳ `colors.warning` |
| Not started icon | ○ `colors.neutral[400]` |
| Expired icon | ⚠️ `colors.error` |
| Verification name | `typography.body`, `fontWeight: 500` |
| Verification detail | `typography.bodySmall`, `colors.neutral[600]` |
| Unlock card | `colors.accent[50]` bg, dashed border |
| Unlock icon | 🔓 |
| Access increase | `typography.bodySmall`, `colors.success` |

---

## Verification Statuses

| Status | Icon | Color | Detail |
|--------|------|-------|--------|
| VERIFIED | ✅ | `colors.success` | "Verified Jan 18, 2025" |
| PENDING | ⏳ | `colors.warning` | "Under review (1-2 days)" |
| NOT_STARTED | ○ | `colors.neutral[400]` | "Required for..." |
| EXPIRED | ⚠️ | `colors.error` | "Expired. Renew →" |
| FAILED | ❌ | `colors.error` | "Verification failed" |

---

## Capability Types

| Type | Icon | Example Tasks |
|------|------|---------------|
| PHYSICAL | 📦 | Moving, lifting, delivery |
| TRANSPORTATION | 🚗 | Deliveries, errands, driving |
| SKILLED | 🔧 | Assembly, repairs, tech help |
| LICENSED | 📜 | Electrical, plumbing, HVAC |

---

**This screen is Cursor-ready. Build exactly as specified.**
