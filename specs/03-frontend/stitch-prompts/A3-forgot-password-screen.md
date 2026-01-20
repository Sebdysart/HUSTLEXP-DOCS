# Screen A3: Forgot Password Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, Firebase Auth
**Cursor-Ready:** YES

---

## Overview

Password reset flow via email. Single screen with success state.

---

## Layout (Initial)

```
┌─────────────────────────────────────────┐
│ ←                                       │  ← Back to login
│                                         │
│                                         │
│            🔐                           │  ← Lock icon, 64px
│                                         │
│         Reset Password                  │  ← typography.h1
│                                         │
│   Enter your email and we'll send       │  ← typography.body
│   you a link to reset your password.    │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Email                               ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        Send Reset Link              ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│                                         │
│          Back to Sign In →              │
│                                         │
└─────────────────────────────────────────┘
```

---

## Layout (Success)

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│                                         │
│            ✅                           │  ← Checkmark, 64px, success
│                                         │
│          Check Your Email               │  ← typography.h1
│                                         │
│   We sent a password reset link to      │  ← typography.body
│   john@example.com                      │  ← Bold email
│                                         │
│   Didn't receive it? Check your spam    │
│   folder or try again.                  │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        Open Email App               ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        Resend Email                 ││  ← Secondary button
│  └─────────────────────────────────────┘│
│                                         │
│          Back to Sign In →              │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface ForgotPasswordScreenProps {
  // State
  isLoading?: boolean;
  error?: Error | null;
  emailSent?: boolean;

  // Form values
  email?: string;

  // Callbacks
  onEmailChange?: (email: string) => void;
  onSubmit?: () => void;
  onResend?: () => void;
  onOpenEmailApp?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Back button | `iconSize.lg`, `colors.neutral[700]` |
| Lock icon | 64px, `colors.neutral[400]` |
| Checkmark icon | 64px, `colors.success` |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Description | `typography.body`, `colors.neutral[600]`, centered |
| Email highlight | `typography.body`, `fontWeight: 600` |
| Input field | `inputStyles.default`, 48px height |
| Primary button | `buttonVariants.primary`, `buttonSizes.lg` |
| Secondary button | `buttonVariants.secondary`, `buttonSizes.lg` |
| Link | `typography.body`, `colors.primary[500]` |

---

## States

### Loading
- Button shows spinner
- Input disabled

### Error (Invalid Email)
```
┌─────────────────────────────────────────┐
│ Email                                   │  ← Red border
└─────────────────────────────────────────┘
  Please enter a valid email address        ← colors.error
```

### Error (Email Not Found)
```
┌─────────────────────────────────────────┐
│ ⚠️ No account found with this email.    │
│    Would you like to sign up?           │
└─────────────────────────────────────────┘
```

### Success
- Switch to success layout
- Show email that was sent to
- Offer resend option

### Resend Cooldown
```
Resend Email (2:00)  ← Disabled with countdown
```

---

## Button Actions

| Button | Action |
|--------|--------|
| Send Reset Link | Call `onSubmit` |
| Open Email App | Deep link to email app |
| Resend Email | Call `onResend` (has 2min cooldown) |
| Back to Sign In | Call `onBack` |

---

**This screen is Cursor-ready. Build exactly as specified.**
