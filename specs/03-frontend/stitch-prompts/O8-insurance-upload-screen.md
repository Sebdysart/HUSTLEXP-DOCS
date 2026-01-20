# Screen O8: Insurance Upload Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only (conditional)

---

## Overview

Hustlers who selected "Insured Tasks" upload proof of insurance. Required for high-value tasks like moving, transport, and property work.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Upload proof of insurance          │  ← typography.h1
│                                         │
│   Required for moving, transport,       │  ← typography.body
│   and high-value tasks.                 │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │     ┌─────────────────────────┐     ││
│  │     │                         │     ││
│  │     │   🛡️ Upload Insurance   │     ││
│  │     │      Certificate        │     ││
│  │     │                         │     ││
│  │     └─────────────────────────┘     ││
│  │                                     ││
│  │  Accepted: JPG, PNG, PDF            ││
│  │  Max size: 10MB                     ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  What we need to see:                   │
│                                         │
│  ☑️ Policy holder name (your name)      │
│  ☑️ Policy number                       │
│  ☑️ Coverage type (General Liability)   │
│  ☑️ Coverage amount (min $100,000)      │
│  ☑️ Expiration date (must be current)   │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ℹ️ Don't have insurance?            ││
│  │                                     ││
│  │   You can still complete standard   ││
│  │   tasks. Get insured to unlock      ││
│  │   high-value opportunities.         ││
│  │                                     ││
│  │   Learn about coverage options →    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Submit                    ││
│  └─────────────────────────────────────┘│
│                                         │
│            Skip for now                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface InsuranceUploadScreenProps {
  // Upload state
  uploadedDocument?: {
    uri: string;
    name: string;
    size: number;
    type: string;
  } | null;
  isUploading?: boolean;
  uploadError?: Error | null;

  // Verification status
  verificationStatus?: 'PENDING' | 'VERIFIED' | 'REJECTED' | null;
  rejectionReason?: string;

  // Callbacks
  onUpload?: () => void;
  onRemove?: () => void;
  onSubmit?: () => void;
  onSkip?: () => void;
  onLearnMore?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Upload zone | Dashed border `colors.neutral[300]`, `radius.lg` |
| Shield icon | 48px, `colors.primary[500]` |
| Upload text | `typography.body`, `colors.primary[500]` |
| File specs | `typography.caption`, `colors.neutral[500]` |
| Checklist label | `typography.bodySmall`, `colors.neutral[700]`, `fontWeight: 500` |
| Checklist items | `typography.bodySmall`, `colors.neutral[600]` |
| Checkmarks | `colors.success`, 16px |
| Info card | `colors.info` tint background (10%), `radius.lg` |
| Info icon | 20px, `colors.info` |
| Info text | `typography.bodySmall`, `colors.neutral[700]` |
| Learn more link | `typography.bodySmall`, `colors.primary[500]` |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |
| Skip link | `typography.body`, `colors.neutral[500]` |

---

## Insurance Requirements Checklist

| Item | Required |
|------|----------|
| Policy holder name (your name) | Yes |
| Policy number | Yes |
| Coverage type (General Liability) | Yes |
| Coverage amount (min $100,000) | Yes |
| Expiration date (must be current) | Yes |

---

## Upload States

### Empty
```
┌─────────────────────────┐
│  🛡️ Upload Insurance    │
│     Certificate         │
└─────────────────────────┘
```

### Uploading
```
┌─────────────────────────┐
│    ⟳ Uploading...       │
│    insurance.pdf        │
└─────────────────────────┘
```

### Uploaded
```
┌─────────────────────────┐
│ 📄 insurance.pdf   ✕    │
│    1.8 MB               │
│    ⏳ Pending review     │
└─────────────────────────┘
```

### Verified
```
┌─────────────────────────┐
│ 📄 insurance.pdf   ✓    │
│    ✅ Verified           │
└─────────────────────────┘
```

### Rejected
```
┌─────────────────────────┐
│ 📄 insurance.pdf   ✕    │
│    ❌ Rejected           │
│    Coverage amount too   │
│    low. Min $100,000.    │
│    Upload new →          │
└─────────────────────────┘
```

---

## Behavior

- Submit disabled until document uploaded
- Verification happens async (24-48 hours)
- User can continue onboarding after upload
- Verification status shown in profile later
- Skip removes "Insured Tasks" from preferences

---

**This screen is Cursor-ready. Build exactly as specified.**
