# MOLECULE: RatingStars

**STATUS: LOCKED**
**Location:** `src/components/molecules/RatingStars.tsx`

---

## PURPOSE

Displays user ratings as 1-5 star visualization.
Used for displaying reputation and collecting feedback.

---

## VARIANTS

| Variant | Use Case | Interactive |
|---------|----------|-------------|
| `readonly` | Profile display, task history | No |
| `interactive` | Rating submission, feedback | Yes |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│  ★ ★ ★ ★ ☆  (4.0) 127 ratings              │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Icon (star-filled) | Filled star for rating |
| Icon (star-empty) | Empty star |
| Text (caption) | Rating count text |

---

## PROPS INTERFACE

```typescript
interface RatingStarsProps {
  // Required data (from backend)
  rating: number;        // 0-5, backend computed average
  count?: number;        // Total number of ratings
  
  // Appearance
  variant: 'readonly' | 'interactive';
  size?: 'small' | 'medium' | 'large';  // Star size
  
  // Interactive mode
  onRate?: (rating: number) => void;  // Called with 1-5
  
  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
}
```

---

## VISUAL STATES

### Readonly
| State | Visual |
|-------|--------|
| Default | Static stars, rating text |
| With count | Shows "(4.0) 127 ratings" |

### Interactive
| State | Visual |
|-------|--------|
| Default | Tappable stars |
| Hover | Star highlights on hover |
| Selected | Filled stars up to selection |
| Pressed | Scale 1.1 on tap |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Rating is trustworthy (show count)
- ✅ Stars are recognizable standard
- ✅ Interactive mode is obvious

**FORBIDDEN:**
- ❌ Computing average rating client-side
- ❌ Showing 0 stars without "Not rated yet"
- ❌ Half-stars without proper rounding
- ❌ Allowing rating without authentication

---

## USAGE EXAMPLES

### Profile Display (Readonly)
```tsx
<RatingStars
  rating={userData.averageRating}
  count={userData.totalRatings}
  variant="readonly"
  size="medium"
/>
```

### Task Completion Rating (Interactive)
```tsx
<RatingStars
  rating={0}
  variant="interactive"
  size="large"
  onRate={(stars) => submitRating(taskId, stars)}
  accessibilityHint="Select 1 to 5 stars to rate this experience"
/>
```

### Small Card Display
```tsx
<RatingStars
  rating={posterData.rating}
  count={posterData.ratingCount}
  variant="readonly"
  size="small"
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Tap (interactive) | Scale 1.1, duration 100ms |
| Fill animation | Stars fill left-to-right, 50ms stagger |

---

## FORBIDDEN

```
❌ Computing averages from individual ratings
❌ Allowing fractional input (only 1-5 integers)
❌ Submitting ratings without user action
❌ Custom star designs (use standard icons)
❌ Showing ratings without proper backend data
```

---

## DESIGN TOKENS

**Colors:**
- Filled star: `colors.warning` (#FBBF24)
- Empty star: `colors.surface` (#374151)
- Rating text: `colors.textSecondary` (#9CA3AF)

**Typography:**
- Rating/count: `typography.caption` (14px Regular)

**Spacing:**
- Star to star: `spacing.xs` (4px)
- Stars to text: `spacing.sm` (8px)

**Sizes:**
- Small star: 16px
- Medium star: 24px
- Large star: 32px

---

## RATING DISPLAY LOGIC

```typescript
// Backend provides decimal rating (e.g., 4.3)
// Display shows:
// - Full stars: floor(rating)
// - Partial star: if decimal >= 0.5
// - Empty stars: 5 - filled stars

const fullStars = Math.floor(rating);
const hasHalfStar = rating % 1 >= 0.5;
const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
```

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
