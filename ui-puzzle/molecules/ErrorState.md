# MOLECULE: ErrorState

**STATUS: LOCKED**
**Location:** `src/components/molecules/ErrorState.tsx`

---

## PURPOSE

Displays when an operation fails or content cannot load.
Must be ACTIONABLE, not just informative.

---

## VARIANTS

| Variant | Use Case | Recovery Action |
|---------|----------|----------------|
| `network` | Connection lost | Retry button |
| `permission` | Access denied | Open settings |
| `server` | API error | Retry or go back |
| `generic` | Unknown error | Retry or dismiss |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│                                             │
│            [Error Icon - Red]               │
│                                             │
│          Error Headline                     │
│                                             │
│     Clear explanation of what               │
│     happened and what to do next            │
│                                             │
│      ┌──────────┐  ┌──────────┐            │
│      │  Retry   │  │ Go Back  │            │
│      └──────────┘  └──────────┘            │
│                                             │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Icon | Error indicator (⚠️ or ⨯) |
| Text (title) | Error headline |
| Text (body) | Explanation and guidance |
| Button (primary) | Primary action (Retry) |
| Button (secondary) | Secondary action (Go Back) |
| Spacer | Vertical rhythm |

---

## PROPS INTERFACE

```typescript
interface ErrorStateProps {
  // Content
  variant: 'network' | 'permission' | 'server' | 'generic';
  headline?: string;  // Overrides default
  message?: string;   // Overrides default explanation
  errorCode?: string; // Optional error code (e.g., "HX101")

  // Actions
  onRetry?: () => void;
  onDismiss?: () => void;
  primaryActionLabel?: string;   // Default: "Try Again"
  secondaryActionLabel?: string; // Default: "Go Back"

  // Accessibility
  accessibilityLabel?: string;
}
```

---

## DEFAULT COPY BY VARIANT

### `network`
**Headline:** "Connection Lost"
**Message:** "Check your internet connection and try again."
**Primary:** "Try Again"

### `permission`
**Headline:** "Permission Required"
**Message:** "Enable location access in Settings to see nearby tasks."
**Primary:** "Open Settings"

### `server`
**Headline:** "Something Went Wrong"
**Message:** "We couldn't load this right now. Please try again."
**Primary:** "Try Again"
**Secondary:** "Go Back"

### `generic`
**Headline:** "Error"
**Message:** "An unexpected error occurred."
**Primary:** "Try Again"

---

## VISUAL STATES

- Error icon in `colors.error` (#EF4444)
- Headline in `colors.textPrimary`
- Message in `colors.textSecondary`
- Primary button (solid)
- Secondary button (outline)

---

## MOTION

- Fade in: 200ms ease
- Icon subtle shake: 3px left-right at 100ms intervals (2 cycles)
- Buttons fade in 100ms after text

---

## USAGE EXAMPLES

### Network Error
```tsx
<ErrorState
  variant="network"
  onRetry={handleRetry}
/>
```

### Server Error with Code
```tsx
<ErrorState
  variant="server"
  errorCode="HX301"
  message="Task proof verification failed."
  onRetry={handleRetry}
  onDismiss={() => navigation.goBack()}
/>
```

---

## FORBIDDEN PATTERNS

❌ Do NOT show stack traces or technical jargon
❌ Do NOT blame the user ("You did X wrong")
❌ Do NOT use vague messages ("Error" with no context)
❌ Do NOT prevent dismissal (always allow escape)

---

## DESIGN TOKENS

**Colors:**
- Icon: `colors.error` (#EF4444)
- Headline: `colors.textPrimary` (#FFFFFF)
- Message: `colors.textSecondary` (#9CA3AF)

**Typography:**
- Headline: `typography.headline` (20px SemiBold)
- Message: `typography.body` (16px Regular)
- Error code: `typography.caption` (14px Medium)

**Spacing:**
- Internal padding: `spacing.xl` (32px)
- Icon to headline: `spacing.lg` (24px)
- Message to buttons: `spacing.lg` (24px)
- Button gap: `spacing.md` (16px)

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
