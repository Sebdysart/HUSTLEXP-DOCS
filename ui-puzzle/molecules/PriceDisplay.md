# MOLECULE: PriceDisplay

**STATUS: LOCKED**
**Location:** `src/components/molecules/PriceDisplay.tsx`

---

## PURPOSE

Displays monetary amounts in a consistent, prominent way.
CRITICAL: All prices must come from backend, never computed client-side.

---

## VARIANTS

| Variant | Use Case | Size | Color |
|---------|----------|------|-------|
| `large` | Task detail, payment screens | 32px | White |
| `small` | Task cards, lists | 18px | White |
| `earnings` | Earnings display, completed tasks | 24px | Green |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│        [$] $50.00                           │
│            USD                               │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Icon | Dollar sign or currency symbol |
| Text (heading/title) | Amount value |
| Text (caption) | Currency code (optional) |

---

## PROPS INTERFACE

```typescript
interface PriceDisplayProps {
  // Required data (from backend)
  amount: number;        // Pre-computed by backend
  currency: string;      // ISO currency code (USD, EUR, etc.)
  
  // Appearance
  variant?: 'large' | 'small' | 'earnings';
  showCurrency?: boolean;  // Show currency code below amount
  
  // Accessibility
  accessibilityLabel?: string;  // e.g., "Fifty dollars"
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Base appearance by variant |
| Earnings | Green color (#10B981) |
| Emphasized | Large variant with icon |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Price is clear and prominent
- ✅ Currency is unambiguous
- ✅ Amount feels attainable (positive framing)

**FORBIDDEN:**
- ❌ Computing amounts client-side
- ❌ Showing "$0.00" without context
- ❌ Hiding currency information
- ❌ Using generic "price" without specific amount

---

## USAGE EXAMPLES

### Task Card (Small)
```tsx
<PriceDisplay
  amount={taskData.price}
  currency={taskData.currency}
  variant="small"
/>
```

### Task Detail (Large)
```tsx
<PriceDisplay
  amount={taskData.price}
  currency={taskData.currency}
  variant="large"
  showCurrency={true}
/>
```

### Earnings Display
```tsx
<PriceDisplay
  amount={completedTask.earnings}
  currency="USD"
  variant="earnings"
  accessibilityLabel="You earned fifty dollars"
/>
```

---

## MOTION

- Fade in: 200ms ease
- If amount changes: Count up animation over 500ms (optional)

---

## FORBIDDEN

```
❌ Computing price = basePrice + fee client-side
❌ Currency conversion inside component
❌ Hardcoded "$" symbol (use currency prop)
❌ Showing prices without backend data
❌ Formatting logic beyond display
```

---

## DESIGN TOKENS

**Colors:**
- Large/small: `colors.textPrimary` (#FFFFFF)
- Earnings: `colors.success` (#10B981)
- Currency label: `colors.textSecondary` (#9CA3AF)

**Typography:**
- Large amount: `typography.title` (32px Bold)
- Small amount: `typography.headline` (18px SemiBold)
- Earnings amount: `typography.headline` (24px SemiBold)
- Currency: `typography.caption` (14px Regular)

**Spacing:**
- Icon to amount: `spacing.xs` (4px)
- Amount to currency: `spacing.xs` (4px)

---

## CURRENCY FORMATTING

Component uses `Intl.NumberFormat` for locale-aware formatting:

```typescript
const formatted = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: currency,
}).format(amount);
```

**Supported Currencies:**
- USD: $50.00
- EUR: €50.00
- GBP: £50.00

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
