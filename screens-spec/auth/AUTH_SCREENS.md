# Auth Screens Specification

**Location:** `hustlexp-app/screens/auth/`  
**Count:** 3 screens  
**Status:** ✅ All functional

---

## A1: LoginScreen

**File:** `LoginScreen.tsx`  
**Spec:** ONBOARDING_SPEC §2

### Purpose
Entry point for existing users.

### Required Elements
- [ ] Email input
- [ ] Password input
- [ ] Login button
- [ ] Forgot password link → ForgotPasswordScreen
- [ ] Sign up link → SignupScreen
- [ ] Social login options (Apple, Google)
- [ ] Error display

### Props Interface
```typescript
interface LoginScreenProps {
  onLogin?: (email: string, password: string) => void;
  onSocialLogin?: (provider: 'apple' | 'google') => void;
  isLoading?: boolean;
  error?: string;
}
```

---

## A2: SignupScreen

**File:** `SignupScreen.tsx`  
**Spec:** ONBOARDING_SPEC §3

### Purpose
New user registration.

### Required Elements
- [ ] Full name input
- [ ] Email input
- [ ] Password input (with requirements shown)
- [ ] Confirm password input
- [ ] Terms & conditions checkbox
- [ ] Sign up button
- [ ] Login link → LoginScreen
- [ ] Social signup options

### Validation
- Email: Valid format
- Password: 8+ chars, 1 uppercase, 1 number
- Passwords match
- Terms accepted

---

## A3: ForgotPasswordScreen

**File:** `ForgotPasswordScreen.tsx`  
**Spec:** ONBOARDING_SPEC §2.3

### Purpose
Password reset flow.

### Required Elements
- [ ] Email input
- [ ] Send reset link button
- [ ] Back to login link
- [ ] Success state: "Check your email"

---

## Navigation Flow

```
                 LoginScreen
                 /    |    \
                /     |     \
    SignupScreen   Forgot   SocialLogin
          |        Password     |
          |           |         |
          ▼           ▼         ▼
    OnboardingFlow   Email   OnboardingFlow
                     Sent      (if new)
```
