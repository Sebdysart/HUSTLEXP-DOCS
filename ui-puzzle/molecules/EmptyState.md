# MOLECULE: EmptyState

**STATUS: LOCKED**
**Location:** `src/components/molecules/EmptyState.tsx`

---

## PURPOSE

Displays when a screen or section has no content to show.
Must follow the "Chosen-State" principle: user feels SELECTED, not starting from zero.

---

## VARIANTS

| Variant | Use Case | Context |
|---------|----------|---------|
| `feed-empty` | No tasks in feed | Hustler task feed |
| `history-empty` | No completed tasks | Task history |
| `general` | Generic empty state | Settings, lists |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│                                             │
│              [Icon/Illustration]            │
│                                             │
│         Chosen-State Headline               │
│                                             │
│         Supportive subtext that             │
│         implies activity is coming          │
│                                             │
│            ┌──────────────┐                 │
│            │ Primary CTA  │                 │
│            └──────────────┘                 │
│                                             │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Icon | Visual representation (NOT sad/negative) |
| Text (title) | Headline with chosen-state language |
| Text (body) | Supportive explanation |
| Button | Primary action (optional) |
| Spacer | Vertical rhythm |

---

## PROPS INTERFACE

```typescript
interface EmptyStateProps {
  // Content
  variant: 'feed-empty' | 'history-empty' | 'general';
  headline?: string;  // Overrides default chosen-state copy
  subtext?: string;   // Overrides default supportive copy
  iconName?: string;  // Icon identifier

  // Action (optional)
  actionLabel?: string;
  onAction?: () => void;

  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
}
```

---

## VISUAL STATES

### Default State
- Icon in brand primary color (#FF6B35)
- Headline in white text (heading preset)
- Subtext in secondary text (#9CA3AF)
- CTA button if action provided

### With Action
- Primary button at bottom
- Tappable area

### Without Action
- No button shown
- Purely informational

---

## CHOSEN-STATE COPY RULES

**FORBIDDEN:**
- ❌ "No tasks yet" (implies starting from zero)
- ❌ "Get started by..." (tentative language)
- ❌ "Nothing to show" (negative framing)

**CORRECT:**
- ✅ "You're ready — tasks are matching to your profile now"
- ✅ "Perfect timing — new opportunities load every few minutes"
- ✅ "Your profile is active — eligible tasks will appear here"

---

## DEFAULT COPY BY VARIANT

### `feed-empty`
**Headline:** "You're ready for tasks"
**Subtext:** "New opportunities matching your skills appear here every few minutes. Your profile is active."

### `history-empty`
**Headline:** "Your first task awaits"
**Subtext:** "Completed tasks will build your XP and unlock higher-paying opportunities."

### `general`
**Headline:** "Nothing here yet"
**Subtext:** "Content will appear here once available."

---

## MOTION

- Fade in: 200ms ease
- Icon scale: 0.95 → 1.0 over 300ms (subtle bounce)
- NO loading spinners (implies waiting)

---

## USAGE EXAMPLES

### Feed Empty State
```tsx
<EmptyState
  variant="feed-empty"
  onAction={() => navigation.navigate('Settings')}
  actionLabel="Update Work Preferences"
/>
```

### History Empty (No Action)
```tsx
<EmptyState
  variant="history-empty"
/>
```

### Custom Message
```tsx
<EmptyState
  variant="general"
  headline="Your queue is clear"
  subtext="All disputes have been resolved."
/>
```

---

## FORBIDDEN PATTERNS

❌ Do NOT use sad emojis or negative icons (broken link, empty box)
❌ Do NOT say "no results" or "nothing found" (implies failure)
❌ Do NOT show loading spinners in empty states
❌ Do NOT compute whether to show this (parent decides)

---

## DESIGN TOKENS

**Colors:**
- Icon: `colors.primary` (#FF6B35)
- Headline: `colors.textPrimary` (#FFFFFF)
- Subtext: `colors.textSecondary` (#9CA3AF)

**Typography:**
- Headline: `typography.headline` (20px SemiBold)
- Subtext: `typography.body` (16px Regular)

**Spacing:**
- Internal padding: `spacing.xl` (32px)
- Icon to headline: `spacing.lg` (24px)
- Headline to subtext: `spacing.sm` (8px)
- Subtext to button: `spacing.lg` (24px)

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
