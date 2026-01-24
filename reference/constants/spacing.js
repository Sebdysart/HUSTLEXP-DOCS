/**
 * HustleXP Spacing & Radius Tokens v2.0.0
 *
 * UPDATED 2026-01-23: Aligned with STITCH HTML specifications
 *
 * AUTHORITY: TYPOGRAPHY_AUTHORITY_RESOLUTION.md
 *
 * SPACING SCALE: 4px base unit (Tailwind-aligned)
 * RADIUS SCALE: Apple HIG rounded corners
 */

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE SPACING SCALE
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Spacing tokens (4px base unit)
 *
 * Usage: padding, margin, gap
 * Example: SPACING[4] = 16px
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
};

/**
 * Fractional spacing for STITCH HTML compatibility
 *
 * These values appear in STITCH HTML but are not in the main scale.
 * Use sparingly — prefer integer scale values.
 */
export const SPACING_FRACTIONAL = {
  0.5: 2,  // gap-0.5
  1.5: 6,  // gap-1.5
};

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE BORDER RADIUS SCALE
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Border radius tokens (Apple HIG + STITCH HTML)
 *
 * Usage: borderRadius
 * Example: RADIUS.lg = 12px
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
};

// ═══════════════════════════════════════════════════════════════════════════
// TOUCH TARGETS (WCAG Accessibility)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Minimum touch targets per WCAG 2.1 AAA
 */
export const TOUCH = {
  min: 44,         // WCAG minimum (44x44 points)
  comfortable: 48, // Comfortable touch target
};

// ═══════════════════════════════════════════════════════════════════════════
// GLASS MORPHISM (from STITCH HTML)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Glass card styling values
 *
 * Used for glassmorphism effects on cards and surfaces
 */
export const GLASS = {
  blur: 20,                    // backdrop-blur-xl equivalent
  opacity: 0.6,                // 60% opacity
  borderWidth: 1,
  borderRadius: RADIUS['2xl'], // 24px
};

// ═══════════════════════════════════════════════════════════════════════════
// SAFE AREA (iOS)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Safe area insets for iOS
 *
 * These are approximations — use useSafeAreaInsets() at runtime
 */
export const SAFE_AREA = {
  top: 59,     // iPhone 15 Pro notch
  bottom: 34,  // iPhone 15 Pro home indicator
};

// ═══════════════════════════════════════════════════════════════════════════
// LAYOUT CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Common layout values
 */
export const LAYOUT = {
  screenPadding: SPACING[4],     // 16px horizontal padding
  cardPadding: SPACING[4],       // 16px internal card padding
  sectionGap: SPACING[6],        // 24px between sections
  listItemGap: SPACING[3],       // 12px between list items
  iconSize: {
    sm: 16,
    md: 20,
    lg: 24,
    xl: 32,
  },
};

// ═══════════════════════════════════════════════════════════════════════════
// CONSOLIDATED EXPORT
// ═══════════════════════════════════════════════════════════════════════════

export const SPACING_SYSTEM = {
  spacing: SPACING,
  spacingFractional: SPACING_FRACTIONAL,
  radius: RADIUS,
  touch: TOUCH,
  glass: GLASS,
  safeArea: SAFE_AREA,
  layout: LAYOUT,
};
