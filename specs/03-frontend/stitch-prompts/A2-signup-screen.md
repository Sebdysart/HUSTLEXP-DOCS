# Screen A2: Signup Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, Firebase Auth
**Cursor-Ready:** YES

---

## Overview

New user registration with email/password. Collects minimal info before onboarding flow.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │  ← Back to login
│                                         │
│            [HustleXP Logo]              │  ← 60px, centered
│                                         │
│           Create Account                │  ← typography.h1
│        Join the hustle economy          │  ← typography.body, secondary
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Full Name                           ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Email                               ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Password                        👁️  ││
│  └─────────────────────────────────────┘│
│  ● Min 8 characters                     │  ← Password requirements
│  ○ One uppercase letter                 │
│  ○ One number                           │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Confirm Password                👁️  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ☐ I agree to the Terms of Service     │
│    and Privacy Policy                   │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │         Create Account              ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│        Already have an account?         │
│              Sign In →                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface SignupScreenProps {
  // State
  isLoading?: boolean;
  error?: Error | null;

  // Form values
  fullName?: string;
  email?: string;
  password?: string;
  confirmPassword?: string;
  agreedToTerms?: boolean;

  // Password validation state (computed by parent)
  passwordValidation?: {
    minLength: boolean;
    hasUppercase: boolean;
    hasNumber: boolean;
  };

  // Callbacks
  onFullNameChange?: (name: string) => void;
  onEmailChange?: (email: string) => void;
  onPasswordChange?: (password: string) => void;
  onConfirmPasswordChange?: (password: string) => void;
  onAgreeToTerms?: (agreed: boolean) => void;
  onSubmit?: () => void;
  onSignIn?: () => void;
  onTermsPress?: () => void;
  onPrivacyPress?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Back button | `iconSize.lg`, `colors.neutral[700]` |
| Logo | 60px height, centered |
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Input fields | `inputStyles.default`, 48px height |
| Password indicator | `typography.caption`, filled circle = green, empty = gray |
| Checkbox | 20px, `colors.primary[500]` when checked |
| Terms links | `colors.primary[500]`, underlined |
| Create button | `buttonVariants.primary`, `buttonSizes.lg`, full width |
| Sign In link | `typography.body`, `colors.primary[500]` |

---

## Password Requirements Visual

```typescript
// Met requirement
● Min 8 characters     // colors.success, filled circle

// Unmet requirement
○ One uppercase letter // colors.neutral[400], empty circle
```

---

## States

### Form Validation
- Button disabled until:
  - All fields filled
  - Password meets requirements
  - Passwords match
  - Terms agreed

### Passwords Don't Match
```
┌─────────────────────────────────────────┐
│ Confirm Password                    👁️  │  ← Red border
└─────────────────────────────────────────┘
  Passwords don't match                     ← colors.error
```

### Email Already Exists
```
┌─────────────────────────────────────────┐
│ ⚠️ An account with this email already   │
│    exists. Sign in instead?             │
└─────────────────────────────────────────┘
```

---

## Keyboard Flow

1. Full Name → Email (next)
2. Email → Password (next)
3. Password → Confirm Password (next)
4. Confirm Password → Dismiss keyboard (done)

---

**This screen is Cursor-ready. Build exactly as specified.**
