# MOLECULE: LoadingState

**STATUS: LOCKED**
**Location:** `src/components/molecules/LoadingState.tsx`

---

## PURPOSE

Displays while content is loading.
Must feel ACTIVE and CERTAIN, not passive waiting.

---

## VARIANTS

| Variant | Use Case | Animation |
|---------|----------|-----------|
| `fullscreen` | Initial screen load | Centered spinner |
| `inline` | Section loading | Small spinner in place |
| `skeleton` | Content placeholder | Shimmer effect |

---

## ANATOMY

### Fullscreen Variant
```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│              [Spinner Animation]            │
│                                             │
│           Loading your tasks...             │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### Inline Variant
```
┌─────────────────────────────────────────────┐
│ Content above...                            │
│                                             │
│    [Small Spinner] Loading...               │
│                                             │
│ Content below...                            │
└─────────────────────────────────────────────┘
```

### Skeleton Variant
```
┌─────────────────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                      │
│ ▓▓▓▓▓▓▓▓▓▓▓▓                               │
│                                             │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                      │
│ ▓▓▓▓▓▓▓▓▓▓▓▓                               │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Text (caption) | Loading message |
| Spacer | Centering and rhythm |

**Custom Element:**
- ActivityIndicator (React Native built-in)

---

## PROPS INTERFACE

```typescript
interface LoadingStateProps {
  // Appearance
  variant: 'fullscreen' | 'inline' | 'skeleton';

  // Content (optional)
  message?: string;  // Overrides default "Loading..."

  // Skeleton-specific
  lines?: number;  // Number of skeleton rows (default: 3)

  // Accessibility
  accessibilityLabel?: string;
}
```

---

## VISUAL STATES

### Fullscreen
- Centered spinner (primary color)
- Message below spinner
- Dark background (#0D0D0D)

### Inline
- Small spinner (16px)
- Inline with text
- Transparent background

### Skeleton
- Gray bars with shimmer animation
- Matches expected content shape
- Smooth fade-to-content transition

---

## ACTIVE-STATE COPY RULES

**FORBIDDEN:**
- ❌ "Please wait..." (passive language)
- ❌ "Hang tight..." (uncertain)
- ❌ No message at all (feels stuck)

**CORRECT:**
- ✅ "Loading your tasks..."
- ✅ "Preparing your feed..."
- ✅ "Updating your profile..."

---

## DEFAULT MESSAGES BY CONTEXT

- Feed: "Loading tasks near you..."
- Profile: "Loading your profile..."
- History: "Loading your history..."
- Default: "Loading..."

---

## MOTION

### Spinner
- Rotation: Continuous 360° at 1s per rotation
- Color: Brand primary (#FF6B35)
- Size: 32px (fullscreen), 16px (inline)

### Skeleton Shimmer
- Gradient sweep: Left to right
- Duration: 1.5s continuous loop
- Colors: #1A1A1A → #2A2A2A → #1A1A1A

---

## USAGE EXAMPLES

### Fullscreen Loading
```tsx
<LoadingState
  variant="fullscreen"
  message="Loading your tasks..."
/>
```

### Inline Section
```tsx
<LoadingState
  variant="inline"
  message="Updating..."
/>
```

### Skeleton Placeholder
```tsx
<LoadingState
  variant="skeleton"
  lines={5}
/>
```

---

## FORBIDDEN PATTERNS

❌ Do NOT show loading for <200ms (jarring flicker)
❌ Do NOT use progress bars without real progress data
❌ Do NOT nest loading states
❌ Do NOT show loading indefinitely (timeout after 30s → ErrorState)

---

## DESIGN TOKENS

**Colors:**
- Spinner: `colors.primary` (#FF6B35)
- Message: `colors.textSecondary` (#9CA3AF)
- Skeleton base: `colors.surface` (#1A1A1A)
- Skeleton shimmer: Gradient to `#2A2A2A`

**Typography:**
- Message: `typography.caption` (14px Regular)

**Spacing:**
- Fullscreen padding: `spacing.2xl` (48px)
- Spinner to message: `spacing.md` (16px)
- Skeleton line spacing: `spacing.sm` (8px)

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
