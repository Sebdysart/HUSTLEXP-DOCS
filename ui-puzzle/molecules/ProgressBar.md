# MOLECULE: ProgressBar

**STATUS: LOCKED**
**Location:** `src/components/molecules/ProgressBar.tsx`

---

## PURPOSE

Displays completion progress for XP, task steps, and goal tracking.
Progress values MUST come from backend calculations.

---

## VARIANTS

| Variant | Use Case | Shape |
|---------|----------|-------|
| `linear` | XP progress, step completion | Horizontal bar |
| `circular` | Profile level, round indicators | Circle/ring |

---

## ANATOMY

### Linear Variant
```
┌─────────────────────────────────────────────┐
│ XP Progress                        750/1000 │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░                       │
│                                             │
│ 75% to next level                           │
└─────────────────────────────────────────────┘
```

### Circular Variant
```
┌─────────────────────────────────────────────┐
│              ◐◐◐                            │
│             ◐   ◐    Level 3                │
│             ◐   ◐    750 XP                 │
│              ◐◐◐                            │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Text (body) | Label and current/total values |
| Text (caption) | Percentage or status |

**Custom Elements:**
- Progress bar track (background)
- Progress bar fill (foreground)

---

## PROPS INTERFACE

```typescript
interface ProgressBarProps {
  // Required data (from backend)
  current: number;      // Current progress value
  total: number;        // Maximum value
  label?: string;       // e.g., "XP Progress"
  
  // Appearance
  variant: 'linear' | 'circular';
  showPercentage?: boolean;
  showValues?: boolean;  // Show "750/1000"
  
  // Accessibility
  accessibilityLabel?: string;
  accessibilityValue?: {
    min: number;
    max: number;
    now: number;
  };
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Progress fill to current % |
| Animating | Smooth fill animation |
| Complete | Green color, 100% filled |
| Near complete | Pulsing effect at 90%+ |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Progress feels achievable (clear next milestone)
- ✅ Current state is visible
- ✅ Completion is celebrated

**FORBIDDEN:**
- ❌ Computing progress percentage client-side
- ❌ Empty bar with no context
- ❌ Indefinite progress (no total)
- ❌ Regressing progress (must increase or stay same)

---

## USAGE EXAMPLES

### XP Progress (Linear)
```tsx
<ProgressBar
  current={userData.currentXP}
  total={userData.nextLevelXP}
  label="XP Progress"
  variant="linear"
  showPercentage={true}
  showValues={true}
/>
```

### Task Steps (Linear)
```tsx
<ProgressBar
  current={completedSteps}
  total={totalSteps}
  label="Task Progress"
  variant="linear"
  showValues={true}
/>
```

### Profile Level (Circular)
```tsx
<ProgressBar
  current={userData.levelProgress}
  total={100}
  variant="circular"
  showPercentage={true}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Progress update | Fill animates smoothly, duration 500ms |
| Completion | Scale pulse 1.05, color flash |
| Appear | Fade in + fill, duration 300ms |

---

## FORBIDDEN

```
❌ Computing percentage = (current/total)*100 client-side
❌ Animating indefinitely (use LoadingState instead)
❌ Progress without total value
❌ Backward progress without explanation
❌ Custom colors outside design system
```

---

## DESIGN TOKENS

**Colors:**
- Track (background): `colors.surface` (#1A1A1A)
- Fill (progress): `colors.primary` (#FF6B35)
- Fill (complete): `colors.success` (#10B981)
- Label: `colors.textPrimary` (#FFFFFF)
- Values: `colors.textSecondary` (#9CA3AF)

**Typography:**
- Label: `typography.body` (16px Regular)
- Values: `typography.caption` (14px Regular)
- Percentage: `typography.caption` (14px SemiBold)

**Spacing:**
- Label to bar: `spacing.sm` (8px)
- Bar to percentage: `spacing.xs` (4px)

**Sizes:**
- Linear height: 8px
- Linear border radius: 4px
- Circular diameter: 120px
- Circular stroke: 8px

---

## PROGRESS CALCULATION

```typescript
// Backend provides current and total
// Component only renders the display

const percentage = Math.round((current / total) * 100);
const isComplete = current >= total;
const isNearComplete = percentage >= 90;
```

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
