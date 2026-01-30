# COLOR AUTHORITY RESOLUTION

**Status:** BINDING DECISION
**Date:** 2026-01-23
**Issue:** Three conflicting color systems exist in the repository

---

## THE PROBLEM

Three different color systems are defined across the repository:

| Source | Primary | Success | Error | Background |
|--------|---------|---------|-------|------------|
| **STITCH HTML** | `#1FAD7E` | `#34C759` | `#FF3B30` | `#000000` |
| **DESIGN_SYSTEM.md** | `#4CAF50` | `#4CAF50` | `#F44336` | `#121212` |
| **reference/constants** | N/A | `#10B981` | `#EF4444` | `#FFFFFF` |

This causes:
- Cursor producing minimal output (defaults to safe colors)
- Visual inconsistency across implementations
- Developer confusion about which colors to use

---

## THE DECISION

**STITCH HTML specifications are the SINGLE SOURCE OF TRUTH for visual design.**

Rationale:
1. STITCH HTML files contain pixel-perfect designs approved by stakeholders
2. iOS SwiftUI implementation follows STITCH (and works)
3. STITCH uses Apple HIG colors (appropriate for mobile app)
4. Material Design colors (in DESIGN_SYSTEM.md) are for web, not mobile

---

## AUTHORITATIVE COLOR TOKENS

```typescript
/**
 * HUSTLEXP AUTHORITATIVE COLORS
 * Source: STITCH HTML specifications
 * Authority: This file supersedes DESIGN_SYSTEM.md and reference/constants/colors.js
 */

export const COLORS = {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND IDENTITY
  // ═══════════════════════════════════════════════════════════════════════════

  brand: {
    primary: '#1FAD7E',      // HustleXP teal-green (brand identity)
    yellow: '#FFD900',       // Instant mode highlight
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // APPLE SYSTEM COLORS (iOS Human Interface Guidelines)
  // ═══════════════════════════════════════════════════════════════════════════

  apple: {
    red: '#FF3B30',          // Error, alerts, urgent, LIVE indicator
    orange: '#FF9500',       // Warnings, progress, XP accents
    green: '#34C759',        // Success, complete, money positive
    blue: '#007AFF',         // Info, links, actions
    gray: '#8E8E93',         // Muted text, disabled states
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC MAPPINGS
  // ═══════════════════════════════════════════════════════════════════════════

  semantic: {
    success: '#34C759',      // → apple.green (task complete, payment received)
    error: '#FF3B30',        // → apple.red (validation error, rejection)
    warning: '#FF9500',      // → apple.orange (attention needed)
    info: '#007AFF',         // → apple.blue (neutral information)
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // XP & PROGRESSION (Hustler gamification)
  // ═══════════════════════════════════════════════════════════════════════════

  xp: {
    primary: '#1FAD7E',      // XP ring, progress bars (brand green)
    accent: '#FF9500',       // XP gain highlight, celebrations
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // MONEY & ESCROW
  // ═══════════════════════════════════════════════════════════════════════════

  money: {
    positive: '#34C759',     // Incoming payment, available balance
    negative: '#FF3B30',     // Outgoing, fees, deductions
    pending: '#FF9500',      // Processing, in escrow
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TRUST TIERS
  // ═══════════════════════════════════════════════════════════════════════════

  tier: {
    rookie: '#71717A',       // Tier 1 - Zinc 500 (matte gray)
    verified: '#007AFF',     // Tier 2 - Apple Blue (metallic)
    trusted: '#FF9500',      // Tier 3 - Apple Orange (holographic)
    elite: '#FFD700',        // Tier 4 - Gold (premium)
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND & SURFACES
  // ═══════════════════════════════════════════════════════════════════════════

  background: {
    primary: '#000000',      // Pure black (dark mode default)
    elevated: '#1C1C1E',     // Elevated surface
    light: '#F2F2F3',        // Light mode background (if used)
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════════════════════

  glass: {
    surface: 'rgba(28, 28, 30, 0.6)',       // Standard glass
    surfaceDark: 'rgba(28, 28, 30, 0.8)',   // Darker glass
    border: 'rgba(255, 255, 255, 0.1)',     // Glass border
    borderSubtle: 'rgba(255, 255, 255, 0.05)', // Subtle border
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════════════════════════

  text: {
    primary: '#FFFFFF',      // Primary text on dark
    secondary: '#E5E5EA',    // Secondary text
    muted: '#8E8E93',        // Muted, hints, placeholders
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // ZINC SCALE (for subtle UI elements)
  // ═══════════════════════════════════════════════════════════════════════════

  zinc: {
    200: '#E4E4E7',
    300: '#D4D4D8',
    400: '#A1A1AA',
    500: '#71717A',
    600: '#52525B',
    700: '#3F3F46',
    800: '#27272A',
  },
} as const;
```

---

## DEPRECATED COLORS (DO NOT USE)

These colors appear in legacy documents but should NOT be used:

| Color | Where Found | Replacement |
|-------|-------------|-------------|
| `#FF6B35` | Old CURSOR_INSTRUCTIONS, old .cursorrules | `#1FAD7E` (brand) |
| `#0D0D0D` | Old BOOTSTRAP.md | `#000000` (background) |
| `#4CAF50` | DESIGN_SYSTEM.md | `#34C759` (success) or `#1FAD7E` (brand) |
| `#2196F3` | DESIGN_SYSTEM.md | `#007AFF` (info/blue) |
| `#F44336` | DESIGN_SYSTEM.md | `#FF3B30` (error) |
| `#10B981` | reference/constants | `#1FAD7E` (brand) or `#34C759` (success) |
| `#EF4444` | reference/constants | `#FF3B30` (error) |
| `#3B82F6` | reference/constants | `#007AFF` (info) |
| `#1A1A1A` | Old specs | `#1C1C1E` (elevated) |
| `#121212` | DESIGN_SYSTEM.md | `#000000` (background) |

---

## AUTHORITY HIERARCHY

When colors conflict between documents:

```
1. STITCH HTML files (specs/03-frontend/stitch-prompts/*.html)
   ↓ HIGHEST AUTHORITY (pixel-perfect designs)

2. This file (COLOR_AUTHORITY_RESOLUTION.md)
   ↓ Binding decision document

3. BOOTSTRAP.md / CURSOR_INSTRUCTIONS.md
   ↓ Execution documents (must match STITCH)

4. .cursorrules
   ↓ AI enforcement rules (must match STITCH)

5. iOS SwiftUI (ios-swiftui/HustleXP/)
   ↓ Reference implementation (follows STITCH)

6. DESIGN_SYSTEM.md ← DEPRECATED FOR COLORS
   ↓ Use for typography/spacing only, NOT colors

7. reference/constants/colors.js ← DEPRECATED
   ↓ Legacy, will be updated to match STITCH
```

---

## MIGRATION CHECKLIST

Files that need color updates:

### Already Fixed
- [x] `.cursorrules` (SECTION 7)
- [x] `BOOTSTRAP.md`
- [x] `CURSOR_INSTRUCTIONS.md`

### Needs Update (LOW PRIORITY - Legacy)
- [ ] `specs/03-frontend/DESIGN_SYSTEM.md` (add deprecation note for colors)
- [ ] `reference/constants/colors.js` (update to STITCH values)
- [ ] `specs/03-frontend/HUSTLER_UI_SPEC.md` (line 409, 421, 428)
- [ ] `FRONTEND_ARCHITECTURE.md`
- [ ] `FRONTEND_ALIGNMENT_SUMMARY.md`

### No Change Needed
- iOS SwiftUI (already correct)
- STITCH HTML files (source of truth)
- UI_ENFORCEMENT_AUDIT.md (documents the problem)

---

## VERIFICATION

To verify color compliance, check that:

1. **Brand primary** is `#1FAD7E` (NOT `#4CAF50`, `#10B981`, or `#FF6B35`)
2. **Background** is `#000000` (NOT `#0D0D0D`, `#121212`)
3. **Success green** is `#34C759` (NOT `#4CAF50`, `#10B981`)
4. **Error red** is `#FF3B30` (NOT `#F44336`, `#EF4444`)
5. **Info blue** is `#007AFF` (NOT `#2196F3`, `#3B82F6`)
6. **Glass surface** is `rgba(28, 28, 30, 0.6)`

---

## RATIONALE

### Why Apple HIG colors over Material Design?

1. **Target platform**: HustleXP is primarily iOS/mobile
2. **Consistency**: STITCH HTML already uses Apple colors
3. **User expectation**: iOS users expect Apple-style UI
4. **Working implementation**: iOS SwiftUI package uses these colors and works

### Why not Tailwind/Emerald colors?

1. **Different context**: Tailwind colors are for web apps
2. **Brand identity**: `#10B981` is generic emerald, not HustleXP brand
3. **Visual cohesion**: STITCH designs don't use Tailwind palette

---

## ENFORCEMENT

AI tools (Cursor, Claude Code) MUST:

1. Read this file when encountering color decisions
2. Use STITCH colors exclusively
3. Flag any use of deprecated colors as errors
4. Reference BOOTSTRAP.md for quick color lookup

---

## DOCUMENT STATUS

| Field | Value |
|-------|-------|
| Status | BINDING |
| Effective | 2026-01-23 |
| Supersedes | DESIGN_SYSTEM.md §2 (colors only) |
| Review Date | N/A (permanent) |
