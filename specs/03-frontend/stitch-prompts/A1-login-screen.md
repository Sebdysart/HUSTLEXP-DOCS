# Screen A1: Login Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, Firebase Auth
**Cursor-Ready:** YES

---

## Overview

The login screen is the primary authentication entry point. Uses Firebase Auth with email/password and social providers.

---

## Layout

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            [HustleXP Logo]              │  ← 80px, centered
│                                         │
│            Welcome Back                 │  ← typography.h1
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Email                               ││  ← Input field
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Password                        👁️  ││  ← Input + toggle visibility
│  └─────────────────────────────────────┘│
│                                         │
│               Forgot Password? →        │  ← Link, right-aligned
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Sign In                   ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│            ─── or continue with ───     │  ← Divider
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ Google  │  │  Apple  │  │ Phone   │ │  ← Social buttons
│  └─────────┘  └─────────┘  └─────────┘ │
│                                         │
│                                         │
│        Don't have an account?           │
│              Sign Up →                  │  ← Link to signup
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface LoginScreenProps {
  // State
  isLoading?: boolean;
  error?: Error | null;

  // Form values (controlled)
  email?: string;
  password?: string;

  // Callbacks
  onEmailChange?: (email: string) => void;
  onPasswordChange?: (password: string) => void;
  onSubmit?: () => void;
  onGoogleSignIn?: () => void;
  onAppleSignIn?: () => void;
  onPhoneSignIn?: () => void;
  onForgotPassword?: () => void;
  onSignUp?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Logo | 80px height, centered, `spacing[12]` top margin |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Input fields | `inputStyles.default`, 48px height |
| Password toggle | `iconSize.md`, `colors.neutral[500]` |
| Forgot link | `typography.body`, `colors.primary[500]` |
| Sign In button | `buttonVariants.primary`, `buttonSizes.lg`, full width |
| Divider | 1px `colors.neutral[200]`, "or continue with" centered |
| Social buttons | `buttonVariants.secondary`, equal width, 44px height |
| Sign Up link | `typography.body`, `colors.primary[500]` |

---

## States

### Loading
```typescript
// During authentication
isLoading: true
// Sign In button shows spinner, inputs disabled
```

### Error
```typescript
error: { message: "Invalid email or password" }
// Error banner below inputs, red border on relevant field
```

### Input Validation
- Email: Validate format on blur
- Password: Min 8 characters indicator

---

## Error Display

```
┌─────────────────────────────────────────┐
│ ⚠️ Invalid email or password            │  ← colors.error background (10%)
└─────────────────────────────────────────┘
```

---

## Keyboard Behavior

- Email input: `keyboardType="email-address"`, `autoCapitalize="none"`
- Password input: `secureTextEntry={!showPassword}`
- Return key on email → focus password
- Return key on password → submit

---

## Accessibility

- All inputs have labels
- Error messages announced to screen reader
- Social buttons have descriptive labels ("Sign in with Google")

---

**This screen is Cursor-ready. Build exactly as specified.**
