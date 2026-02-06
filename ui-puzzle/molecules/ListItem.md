# MOLECULE: ListItem

**STATUS: LOCKED**
**Location:** `src/components/molecules/ListItem.tsx`

---

## PURPOSE

Generic list row component for settings, menus, and selectable lists.
Provides consistent interaction patterns across the app.

---

## VARIANTS

| Variant | Use Case | Right Element |
|---------|----------|---------------|
| `with-chevron` | Navigation items | Chevron icon |
| `with-toggle` | Settings switches | Toggle/switch |
| `simple` | Read-only list items | None |

---

## ANATOMY

### With Chevron
```
┌─────────────────────────────────────────────┐
│ [Icon] Label Text                        › │
│        Subtitle text                        │
├─────────────────────────────────────────────┤
```

### With Toggle
```
┌─────────────────────────────────────────────┐
│ [Icon] Label Text                     [O ]  │
│        Subtitle text                        │
├─────────────────────────────────────────────┤
```

### Simple
```
┌─────────────────────────────────────────────┐
│ [Icon] Label Text                           │
│        Subtitle text                        │
├─────────────────────────────────────────────┤
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Icon | Left icon (optional) |
| Text (body) | Primary label |
| Text (caption) | Subtitle/description |
| Icon (chevron) | Navigation indicator |
| Divider | Row separator |

**Custom Element:**
- Switch/Toggle (React Native built-in)

---

## PROPS INTERFACE

```typescript
interface ListItemProps {
  // Content
  label: string;
  subtitle?: string;
  iconName?: string;
  
  // Appearance
  variant: 'with-chevron' | 'with-toggle' | 'simple';
  
  // Toggle-specific
  toggleValue?: boolean;
  onToggle?: (value: boolean) => void;
  
  // Navigation
  onPress?: () => void;
  
  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
  accessibilityRole?: string;
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Base appearance |
| Pressed | Background #1A1A1A (5% lighter) |
| Disabled | 50% opacity, no interaction |
| Toggle On | Toggle shows active color |
| Toggle Off | Toggle shows inactive color |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Item is tappable (if interactive)
- ✅ Purpose is clear from label
- ✅ Current state is visible (for toggles)

**FORBIDDEN:**
- ❌ Ambiguous labels ("Settings", "More")
- ❌ Missing chevron for navigation items
- ❌ Toggle without clear label
- ❌ Long labels without truncation

---

## USAGE EXAMPLES

### Settings Navigation
```tsx
<ListItem
  label="Payment Methods"
  subtitle="Manage your payment options"
  iconName="credit-card"
  variant="with-chevron"
  onPress={() => navigation.navigate('PaymentMethods')}
/>
```

### Settings Toggle
```tsx
<ListItem
  label="Push Notifications"
  subtitle="Receive alerts for new tasks"
  iconName="bell"
  variant="with-toggle"
  toggleValue={settings.pushEnabled}
  onToggle={(value) => updateSetting('pushEnabled', value)}
/>
```

### Simple List Item
```tsx
<ListItem
  label="Version 1.0.0"
  subtitle="Build 2026.02.05"
  variant="simple"
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Press | Background color, duration 150ms |
| Toggle | Switch slide, duration 200ms |

---

## FORBIDDEN

```
❌ Computing toggle state inside component
❌ Navigation logic inside component
❌ Fetching data inside component
❌ Hardcoded icon names
❌ Custom divider colors
❌ Missing press feedback for interactive items
```

---

## DESIGN TOKENS

**Colors:**
- Label: `colors.textPrimary` (#FFFFFF)
- Subtitle: `colors.textSecondary` (#9CA3AF)
- Icon: `colors.textSecondary` (#9CA3AF)
- Chevron: `colors.textTertiary` (#6B7280)
- Pressed background: `colors.surface` (#1A1A1A)
- Divider: `colors.border` (#374151)
- Toggle active: `colors.primary` (#FF6B35)
- Toggle inactive: `colors.textTertiary` (#6B7280)

**Typography:**
- Label: `typography.body` (16px Regular)
- Subtitle: `typography.caption` (14px Regular)

**Spacing:**
- Internal padding: `spacing.md` (16px)
- Icon to label: `spacing.md` (16px)
- Label to subtitle: `spacing.xs` (4px)
- Content to right element: `spacing.md` (16px)

**Sizes:**
- Min height: 56px
- Icon: 24px
- Chevron: 20px
- Toggle: Platform default

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
