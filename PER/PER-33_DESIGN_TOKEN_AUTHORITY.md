# PER-33: Design Token Authority Invariant

**STATUS: ACTIVE — BINDING**
**Created:** 2026-01-23
**Trigger:** Color/typography fragmentation caused Cursor to produce minimal output

---

## INVARIANT STATEMENT

> **All design tokens (colors, typography, spacing, radius) MUST be sourced from STITCH HTML specifications. Material Design and Tailwind values are DEPRECATED.**

---

## BACKGROUND

On 2026-01-23, Cursor produced minimal output (just "HustleXP" + "Get Started" button) because:

1. **Color Fragmentation:** Three conflicting color systems existed
   - STITCH HTML: Apple HIG colors (#1FAD7E, #34C759, #FF3B30)
   - DESIGN_SYSTEM.md: Material Design (#4CAF50, #2196F3, #F44336)
   - reference/constants: Tailwind (#10B981, #EF4444, #3B82F6)

2. **Typography Fragmentation:** Three conflicting typography scales
   - STITCH HTML: Apple HIG (36px display, 28px title1...)
   - DESIGN_SYSTEM.md: Material Design (48px display, 32px h1...)
   - reference/constants: Tailwind (xs/sm/base/lg/xl...)

3. **Wrong Values in Auto-Loaded Files:**
   - `.cursorrules` had #FF6B35 (wrong) instead of #1FAD7E
   - `BOOTSTRAP.md` had #0D0D0D (wrong) instead of #000000

---

## ENFORCEMENT

### AUTHORITY CHAIN (in order of precedence)

1. **STITCH HTML specifications** (`specs/03-frontend/stitch-prompts/*.html`)
2. **COLOR_AUTHORITY_RESOLUTION.md** (binding for colors)
3. **TYPOGRAPHY_AUTHORITY_RESOLUTION.md** (binding for typography)
4. **BOOTSTRAP.md** (runtime constants)
5. **`.cursorrules` SECTION 7** (AI enforcement)
6. **reference/constants/*.js** (implementation reference)
7. **iOS SwiftUI implementation** (already correct)

### DEPRECATED SOURCES (DO NOT USE)

- `specs/03-frontend/DESIGN_SYSTEM.md` §2 Colors — DEPRECATED
- `specs/03-frontend/DESIGN_SYSTEM.md` §3 Typography — DEPRECATED (use Apple HIG naming)
- Any Tailwind color name (slate, emerald, amber, etc.)
- Any Material Design color name (primary, secondary, surface, etc.)

---

## AUTHORITATIVE VALUES

### Colors (Apple HIG)

```
Brand Primary:    #1FAD7E
Brand Yellow:     #FFD900
Apple Red:        #FF3B30
Apple Orange:     #FF9500
Apple Green:      #34C759
Apple Blue:       #007AFF
Apple Gray:       #8E8E93
Background:       #000000
Elevated:         #1C1C1E
Glass Surface:    rgba(28, 28, 30, 0.6)
Glass Border:     rgba(255, 255, 255, 0.1)
Text Primary:     #FFFFFF
Text Secondary:   #E5E5EA
Text Muted:       #8E8E93
```

### Typography (Apple HIG)

```
Display:   36px Bold,     lineHeight: 44px, tracking: -0.5
Title1:    28px Bold,     lineHeight: 34px, tracking: -0.3
Title2:    24px SemiBold, lineHeight: 30px
Title3:    20px SemiBold, lineHeight: 26px
Headline:  18px SemiBold, lineHeight: 24px
Body:      16px Regular,  lineHeight: 22px
Callout:   14px Regular,  lineHeight: 20px
Caption:   12px Medium,   lineHeight: 16px
Micro:     10px SemiBold, lineHeight: 14px, tracking: 1
```

### Spacing (4px base)

```
1: 4px    2: 8px    3: 12px   4: 16px   5: 20px
6: 24px   8: 32px   10: 40px  12: 48px  16: 64px
```

### Border Radius (Apple HIG)

```
xs: 2px   sm: 4px   md: 8px   lg: 12px
xl: 16px  2xl: 24px full: 9999px
```

---

## VALIDATION

Before any UI implementation, verify:

```
[ ] Colors match STITCH HTML (not Material Design)
[ ] Typography uses Apple HIG names (Display/Title1, not h1/h2)
[ ] Font sizes match STITCH (36px display, not 48px)
[ ] Line heights are defined (not ratio-based)
[ ] Border radius uses Apple HIG scale
[ ] No deprecated colors (#10B981, #EF4444, #3B82F6, etc.)
[ ] No deprecated hex (#FF6B35, #0D0D0D, #1A1A1A)
```

---

## VIOLATION CONSEQUENCE

If this invariant is violated:
1. Cursor will produce minimal/incorrect output
2. iOS SwiftUI and React Native will be visually inconsistent
3. STITCH HTML specs will not match implementation

**All design token violations must be fixed before any other work proceeds.**

---

## FILES AFFECTED

| File | Status | Action |
|------|--------|--------|
| `.cursorrules` SECTION 7 | ✅ Fixed | Uses Apple HIG |
| `BOOTSTRAP.md` | ✅ Fixed | Uses Apple HIG |
| `CURSOR_INSTRUCTIONS.md` | ✅ Fixed | Uses Apple HIG |
| `COLOR_AUTHORITY_RESOLUTION.md` | ✅ Created | Binding document |
| `TYPOGRAPHY_AUTHORITY_RESOLUTION.md` | ✅ Created | Binding document |
| `reference/constants/colors.js` | ✅ Fixed | v2.0.0 Apple HIG |
| `reference/constants/typography.js` | ✅ Fixed | v2.0.0 Apple HIG |
| `reference/constants/spacing.js` | ✅ Fixed | v2.0.0 |
| `CURSOR_PREFLIGHT_CHECKLIST.md` | ✅ Fixed | Corrected paths |
| `specs/03-frontend/DESIGN_SYSTEM.md` | ⚠️ Deprecated | Added notice |

---

**END OF PER-33**
