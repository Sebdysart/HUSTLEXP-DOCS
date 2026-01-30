# Screen O7: Trade Verification Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only (conditional)

---

## Overview

Allows hustlers who selected "Skilled Tasks" or "Licensed Tasks" to upload trade credentials. Optional but required for certain task categories.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Verify your trade skills           │  ← typography.h1
│                                         │
│   Upload credentials to unlock          │  ← typography.body
│   higher-paying skilled tasks.          │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│   Select your trades:                   │  ← typography.bodySmall
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ Electrical                        ││
│  │   License required                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ Plumbing                          ││
│  │   License required                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ HVAC                              ││
│  │   License required                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☐ General Contractor                ││
│  │   License required                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ☑️ Handyman / General Repair        ││
│  │   No license required               ││
│  └─────────────────────────────────────┘│
│                                         │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Continue                  ││
│  └─────────────────────────────────────┘│
│                                         │
│            Skip for now                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## Layout (After Selection with License Required)

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Upload your license                │
│                                         │
│   We'll verify within 24 hours.         │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │     ┌─────────────────────────┐     ││
│  │     │                         │     ││
│  │     │    📄 Upload Photo      │     ││  ← Dashed border
│  │     │    of your license      │     ││
│  │     │                         │     ││
│  │     └─────────────────────────┘     ││
│  │                                     ││
│  │  Accepted: JPG, PNG, PDF            ││
│  │  Max size: 10MB                     ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  ⚠️ Make sure the following is visible: │
│     • Your name                         │
│     • License number                    │
│     • Expiration date                   │
│     • Issuing authority                 │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Submit                    ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface TradeVerificationScreenProps {
  // Available trades
  trades?: Trade[];

  // Selected trades
  selectedTrades?: string[];

  // Upload state
  uploadedLicense?: {
    uri: string;
    name: string;
    size: number;
  } | null;
  isUploading?: boolean;
  uploadError?: Error | null;

  // Callbacks
  onToggleTrade?: (tradeId: string) => void;
  onUploadLicense?: () => void;
  onRemoveLicense?: () => void;
  onSubmit?: () => void;
  onSkip?: () => void;
  onBack?: () => void;
}

interface Trade {
  id: string;
  name: string;
  requiresLicense: boolean;
  licenseTypes?: string[];  // e.g., ["State License", "Certification"]
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Section label | `typography.bodySmall`, `colors.neutral[500]` |
| Trade cards | `cardStyles.outlined`, full width |
| Checkbox | 24px, `colors.primary[500]` when checked |
| Trade name | `typography.body`, `colors.neutral[900]` |
| Trade note | `typography.caption`, `colors.neutral[500]` |
| Upload zone | Dashed border `colors.neutral[300]`, `radius.lg` |
| Upload icon | 48px, `colors.neutral[400]` |
| Upload text | `typography.body`, `colors.primary[500]` |
| File specs | `typography.caption`, `colors.neutral[500]` |
| Warning | `colors.warning` icon, `typography.bodySmall` |
| Checklist | `typography.bodySmall`, `colors.neutral[700]` |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |
| Skip link | `typography.body`, `colors.neutral[500]` |

---

## Trade Data

| Name | Requires License |
|------|-----------------|
| Electrical | Yes |
| Plumbing | Yes |
| HVAC | Yes |
| General Contractor | Yes |
| Handyman / General Repair | No |

---

## Upload States

### Empty
```
┌─────────────────────────┐
│    📄 Upload Photo      │  ← Dashed border, gray
│    of your license      │
└─────────────────────────┘
```

### Uploading
```
┌─────────────────────────┐
│    ⟳ Uploading...       │  ← Spinner, primary color
│    license.pdf          │
└─────────────────────────┘
```

### Uploaded
```
┌─────────────────────────┐
│ 📄 license.pdf     ✕    │  ← Solid border, green check
│    2.4 MB               │
└─────────────────────────┘
```

### Error
```
┌─────────────────────────┐
│ ⚠️ Upload failed         │  ← Red border
│    Tap to retry         │
└─────────────────────────┘
```

---

## Validation

- If any trade with `requiresLicense: true` is selected, license upload is required
- Submit disabled until license uploaded (for licensed trades)
- Skip is always available

---

**This screen is Cursor-ready. Build exactly as specified.**
