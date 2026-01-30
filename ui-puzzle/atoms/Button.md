# ATOM: Button

**STATUS: LOCKED**  
**Location:** `src/components/atoms/Button.tsx`

---

## PURPOSE

The primary interactive element for user actions.
Used for submissions, confirmations, and navigation triggers.

---

## VARIANTS

| Variant | Use Case | Background | Text |
|---------|----------|------------|------|
| `primary` | Main actions | `#FF6B35` (brand orange) | `#FFFFFF` |
| `secondary` | Secondary actions | `#1A1A1A` (surface) | `#FFFFFF` |
| `ghost` | Tertiary actions | `transparent` | `#9CA3AF` |
| `danger` | Destructive actions | `#EF4444` (error red) | `#FFFFFF` |

---

## SIZES

| Size | Height | Padding | Font |
|------|--------|---------|------|
| `sm` | 36px | 12px 16px | 14px Medium |
| `md` | 48px | 16px 24px | 16px SemiBold |
| `lg` | 56px | 20px 32px | 18px Bold |

---

## STATES

| State | Visual Change |
|-------|---------------|
| `default` | Base appearance |
| `pressed` | 10% darker, scale 0.98 |
| `disabled` | 50% opacity, no press |
| `loading` | Spinner replaces text |

---

## PROPS INTERFACE

```typescript
interface ButtonProps {
  // Content
  label: string;
  icon?: IconName;           // Optional leading icon
  iconPosition?: 'left' | 'right';
  
  // Appearance
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  fullWidth?: boolean;
  
  // State
  disabled?: boolean;
  loading?: boolean;
  
  // Events
  onPress: () => void;
  
  // Accessibility
  accessibilityLabel?: string;  // Defaults to label
}
```

---

## USAGE EXAMPLES

### Primary Action
```tsx
<Button
  label="Complete Task"
  variant="primary"
  size="lg"
  fullWidth
  onPress={handleComplete}
/>
```

### Secondary with Icon
```tsx
<Button
  label="Add Photo"
  icon="camera"
  variant="secondary"
  size="md"
  onPress={handleAddPhoto}
/>
```

### Ghost Link
```tsx
<Button
  label="Skip for now"
  variant="ghost"
  size="sm"
  onPress={handleSkip}
/>
```

### Danger Action
```tsx
<Button
  label="Cancel Task"
  variant="danger"
  size="md"
  onPress={handleCancel}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Press down | Scale to 0.98, duration 50ms |
| Press up | Scale to 1.0, duration 100ms |
| Loading start | Fade text, show spinner, duration 200ms |

---

## ACCESSIBILITY

- `accessibilityRole="button"`
- `accessibilityState={{ disabled, busy: loading }}`
- Minimum touch target: 44x44px
- Focus indicator: 2px outline offset 2px

---

## FORBIDDEN

```
❌ Custom background colors (use variants only)
❌ Custom text styles (use size presets only)
❌ Nested buttons
❌ Buttons without onPress handler
❌ Buttons with hardcoded strings (use i18n keys)
```

---

## ARCHETYPE USAGE

| Archetype | Typical Button Pattern |
|-----------|------------------------|
| A. Entry/Commitment | Primary CTA, Ghost skip |
| B. Feed/Opportunity | Secondary filter, Ghost sort |
| C. Task Lifecycle | Primary action, Danger cancel |
| D. Calibration | Primary continue, Ghost back |
| E. Progress/Status | Secondary detail, Ghost share |
| F. System/Interrupt | Primary retry, Ghost dismiss |
