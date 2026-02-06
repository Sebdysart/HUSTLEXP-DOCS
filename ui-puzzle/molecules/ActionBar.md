# MOLECULE: ActionBar

**STATUS: LOCKED**
**Location:** `src/components/molecules/ActionBar.tsx`

---

## PURPOSE

Bottom-anchored action button container for 1-2 primary actions.
Consistent action pattern across screens.

---

## VARIANTS

| Variant | Buttons | Layout |
|---------|---------|--------|
| `single-action` | 1 primary button | Full width |
| `dual-action` | 1 secondary + 1 primary | Side by side |

---

## ANATOMY

### Single Action
```
┌─────────────────────────────────────────────┐
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │      Primary Action Button          │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

### Dual Action
```
┌─────────────────────────────────────────────┐
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │  Secondary   │  │   Primary    │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Button (primary) | Main action button |
| Button (secondary) | Secondary/cancel action |
| Spacer | Button spacing |

---

## PROPS INTERFACE

```typescript
interface ActionBarProps {
  // Appearance
  variant: 'single-action' | 'dual-action';
  
  // Primary action (required)
  primaryLabel: string;
  onPrimaryPress: () => void;
  primaryDisabled?: boolean;
  primaryLoading?: boolean;
  
  // Secondary action (dual-action only)
  secondaryLabel?: string;
  onSecondaryPress?: () => void;
  secondaryDisabled?: boolean;
  
  // Accessibility
  primaryAccessibilityLabel?: string;
  primaryAccessibilityHint?: string;
  secondaryAccessibilityLabel?: string;
  secondaryAccessibilityHint?: string;
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Both buttons enabled |
| Primary disabled | Primary button 50% opacity |
| Primary loading | Spinner inside primary button |
| Secondary disabled | Secondary button 50% opacity |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Primary action is obvious and inviting
- ✅ Actions are passed as props (no logic)
- ✅ Loading state shows during API calls

**FORBIDDEN:**
- ❌ Conditional logic inside component
- ❌ API calls from button press
- ❌ Computing disabled state (pass as prop)
- ❌ More than 2 actions (use menu instead)

---

## USAGE EXAMPLES

### Task Detail Accept (Single)
```tsx
<ActionBar
  variant="single-action"
  primaryLabel="Accept Task"
  onPrimaryPress={() => handleAcceptTask()}
  primaryDisabled={!isEligible}
/>
```

### Task Completion (Dual)
```tsx
<ActionBar
  variant="dual-action"
  secondaryLabel="Cancel"
  onSecondaryPress={() => navigation.goBack()}
  primaryLabel="Mark Complete"
  onPrimaryPress={() => handleCompleteTask()}
  primaryLoading={isSubmitting}
/>
```

### Profile Edit (Single)
```tsx
<ActionBar
  variant="single-action"
  primaryLabel="Save Changes"
  onPrimaryPress={() => handleSaveProfile()}
  primaryDisabled={!hasChanges}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Screen enter | Slide up, duration 200ms |
| Button press | Scale 0.98, duration 100ms |
| Loading start | Fade to spinner, duration 150ms |

---

## FORBIDDEN

```
❌ Business logic inside component
❌ API calls from button handlers
❌ Computing eligibility/validation
❌ Conditional rendering of buttons (use variant)
❌ Custom button colors
❌ More than 2 buttons
```

---

## DESIGN TOKENS

**Colors:**
- Background: `colors.background` (#0D0D0D)
- Border top: `colors.border` (#374151)

**Spacing:**
- Internal padding: `spacing.lg` (24px)
- Button to button: `spacing.md` (16px)
- Top border: 1px

**Sizes:**
- Height: Auto (content + padding)
- Button height: 48px (from Button atom)
- Single button width: 100%
- Dual button width: 50% - spacing/2

---

## SAFE AREA HANDLING

ActionBar MUST respect device safe areas:

```typescript
// Uses SafeAreaView or paddingBottom
<SafeAreaView edges={['bottom']}>
  <ActionBar {...props} />
</SafeAreaView>
```

Ensures buttons are accessible on devices with notches/home indicators.

---

## LOADING STATE

When `primaryLoading` is true:
- Button shows spinner inside
- Button remains same size (no layout shift)
- Button is disabled during loading
- Label hides, spinner shows

---

## BUTTON ORDER CONVENTION

In dual-action variant:
- LEFT: Secondary/Cancel/Back (outline style)
- RIGHT: Primary/Confirm/Submit (filled style)

This follows platform conventions and user expectations.

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
