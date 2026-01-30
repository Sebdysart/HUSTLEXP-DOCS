# TYPOGRAPHY & SPACING AUTHORITY RESOLUTION

**STATUS: BINDING — All AI tools MUST use these values**
**Effective Date:** 2026-01-23
**Authority:** STITCH HTML specifications (Apple Human Interface Guidelines)

---

## THE PROBLEM

Typography and spacing definitions were fragmented across THREE systems:

1. **STITCH HTML (Apple HIG):** Display/Title1/Title2/Headline/Body/Callout/Caption/Micro
2. **DESIGN_SYSTEM.md (Material Design):** h1/h2/h3/h4/bodyLarge/body/bodySmall/caption
3. **reference/constants/typography.js (Tailwind):** xs/sm/base/lg/xl/2xl/3xl/4xl

This caused AI tools to produce inconsistent output.

---

## THE DECISION

**STITCH HTML / Apple HIG is the SINGLE SOURCE OF TRUTH for HustleXP typography and spacing.**

Reasons:
1. HustleXP is iOS-first (SwiftUI native implementation exists)
2. STITCH HTML specs are pixel-perfect design source
3. Apple HIG typography is optimized for mobile readability
4. iOS SwiftUI implementation already uses these values correctly

---

## AUTHORITATIVE TYPOGRAPHY SCALE

```typescript
/**
 * HustleXP Typography Tokens v2.0.0
 *
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 * DO NOT USE Material Design or Tailwind scales
 */

export const TYPOGRAPHY = {
  // Display — Hero headlines, splash screens
  display: {
    fontSize: 36,
    fontWeight: '700',  // Bold
    letterSpacing: -0.5,
    lineHeight: 44,
  },

  // Title1 — Section headers, card titles
  title1: {
    fontSize: 28,
    fontWeight: '700',  // Bold
    letterSpacing: -0.3,
    lineHeight: 34,
  },

  // Title2 — Secondary headers, modal titles
  title2: {
    fontSize: 24,
    fontWeight: '600',  // SemiBold
    letterSpacing: 0,
    lineHeight: 30,
  },

  // Title3 — Tertiary headers, list section headers
  title3: {
    fontSize: 20,
    fontWeight: '600',  // SemiBold
    letterSpacing: 0,
    lineHeight: 26,
  },

  // Headline — Button text, emphasized body
  headline: {
    fontSize: 18,
    fontWeight: '600',  // SemiBold
    letterSpacing: 0,
    lineHeight: 24,
  },

  // Body — Primary content text
  body: {
    fontSize: 16,
    fontWeight: '400',  // Regular
    letterSpacing: 0,
    lineHeight: 22,
  },

  // Callout — Secondary content, descriptions
  callout: {
    fontSize: 14,
    fontWeight: '400',  // Regular
    letterSpacing: 0,
    lineHeight: 20,
  },

  // Caption — Labels, metadata
  caption: {
    fontSize: 12,
    fontWeight: '500',  // Medium
    letterSpacing: 0,
    lineHeight: 16,
  },

  // Micro — Badges, tiny labels, uppercase text
  micro: {
    fontSize: 10,
    fontWeight: '600',  // SemiBold
    letterSpacing: 1,   // Tight spacing for uppercase
    lineHeight: 14,
  },
} as const;
```

---

## AUTHORITATIVE SPACING SCALE

```typescript
/**
 * HustleXP Spacing Tokens v2.0.0
 *
 * AUTHORITY: Tailwind-aligned 4px base unit
 * Matches .cursorrules SECTION 7
 */

export const SPACING = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
} as const;

// Fractional values (for STITCH HTML compatibility)
export const SPACING_FRACTIONAL = {
  0.5: 2,   // gap-0.5
  1.5: 6,   // gap-1.5
} as const;
```

---

## AUTHORITATIVE BORDER RADIUS

```typescript
/**
 * HustleXP Border Radius Tokens v2.0.0
 *
 * AUTHORITY: Apple HIG + STITCH HTML specs
 */

export const RADIUS = {
  none: 0,
  xs: 2,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  '2xl': 24,
  full: 9999,
} as const;
```

---

## DEPRECATED VALUES (NEVER USE)

### Typography (from DESIGN_SYSTEM.md Material Design)

| Deprecated Name | Deprecated Value | Use Instead |
|-----------------|------------------|-------------|
| `display` | 48px | 36px (STITCH display) |
| `h1` | 32px | 28px (title1) |
| `h2` | 24px | 24px (title2) - OK |
| `h3` | 20px | 20px (title3) - OK |
| `h4` | 18px | 18px (headline) - OK |
| `bodyLarge` | 16px | 16px (body) - OK |
| `bodySmall` | 12px | 14px (callout) |
| `caption` | 11px | 12px (caption) |
| `label` | 14px | Use callout or caption |
| `labelSmall` | 11px | Use micro |

### Typography (from reference/constants/typography.js Tailwind)

| Deprecated Name | Deprecated Value | Use Instead |
|-----------------|------------------|-------------|
| `xs` | 12px | caption |
| `sm` | 14px | callout |
| `base` | 16px | body |
| `lg` | 18px | headline |
| `xl` | 20px | title3 |
| `2xl` | 24px | title2 |
| `3xl` | 30px | (not in STITCH) |
| `4xl` | 36px | display |

### Line Height (from DESIGN_SYSTEM.md)

| Deprecated | Use Instead |
|------------|-------------|
| Ratio-based (1.5x) | Absolute pixel values per style |
| 56px (display) | 44px |
| 40px (h1) | 34px |

---

## MAPPING TABLE: ALL SYSTEMS

| Apple HIG (USE THIS) | Size | Weight | Material Design | Tailwind | SwiftUI |
|---------------------|------|--------|-----------------|----------|---------|
| display | 36px | Bold | display (48px) ❌ | 4xl | .largeTitle |
| title1 | 28px | Bold | h1 (32px) ❌ | - | .title |
| title2 | 24px | SemiBold | h2 | 2xl | .title2 |
| title3 | 20px | SemiBold | h3 | xl | .title3 |
| headline | 18px | SemiBold | h4 | lg | .headline |
| body | 16px | Regular | bodyLarge | base | .body |
| callout | 14px | Regular | body | sm | .callout |
| caption | 12px | Medium | bodySmall | xs | .caption |
| micro | 10px | SemiBold | labelSmall | - | .caption2 |

---

## IMPLEMENTATION CHECKLIST

### Files That MUST Use These Values

- [x] `.cursorrules` SECTION 7 — Typography section
- [x] `CURSOR_INSTRUCTIONS.md` — Design tokens section
- [x] `BOOTSTRAP.md` — Typography reference
- [ ] `reference/constants/typography.js` — **NEEDS UPDATE**
- [ ] `reference/constants/spacing.js` — **NEEDS UPDATE**
- [ ] `specs/03-frontend/DESIGN_SYSTEM.md` — **ADD DEPRECATION NOTICE**

### Files That Are Already Correct

- [x] `ios-swiftui/HustleXP/Sources/HustleXP/DesignSystem/HustleTypography.swift`
- [x] All STITCH HTML files in `specs/03-frontend/stitch-prompts/`

---

## COLOR CROSS-REFERENCE

For color authority, see: `COLOR_AUTHORITY_RESOLUTION.md`

The same principle applies:
- STITCH HTML is authoritative
- Apple HIG colors are required
- Material Design colors are deprecated
- Tailwind colors are deprecated

---

**END OF TYPOGRAPHY AUTHORITY RESOLUTION**
