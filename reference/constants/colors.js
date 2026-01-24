/**
 * HustleXP Design Tokens v2.0.0
 *
 * ⚠️ UPDATED 2026-01-23: Aligned with STITCH HTML specifications
 *
 * AUTHORITY: COLOR_AUTHORITY_RESOLUTION.md (supersedes UI_SPEC.md for colors)
 *
 * COLOR AUTHORITY RULES:
 * - Brand: #1FAD7E (HustleXP teal-green)
 * - XP: brand.primary (#1FAD7E) + apple.orange (#FF9500)
 * - Money: apple.green (#34C759) positive, apple.red (#FF3B30) negative
 * - Status: Apple HIG colors (green/red/orange/blue)
 * - No decorative use of semantic colors
 *
 * DEPRECATED VALUES (do not use):
 * - #10B981 → use #1FAD7E (brand) or #34C759 (success)
 * - #EF4444 → use #FF3B30
 * - #3B82F6 → use #007AFF
 */

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE COLORS (from STITCH HTML specs)
// ═══════════════════════════════════════════════════════════════════════════

/** Brand Identity */
export const BRAND = {
  PRIMARY: '#1FAD7E',      // HustleXP teal-green
  YELLOW: '#FFD900',       // Instant mode
};

/** Apple System Colors (iOS HIG) */
export const APPLE = {
  RED: '#FF3B30',
  ORANGE: '#FF9500',
  GREEN: '#34C759',
  BLUE: '#007AFF',
  GRAY: '#8E8E93',
};

/** Background & Surfaces */
export const BACKGROUND = {
  PRIMARY: '#000000',      // Pure black
  ELEVATED: '#1C1C1E',
};

/** Glass (glassmorphism) */
export const GLASS = {
  SURFACE: 'rgba(28, 28, 30, 0.6)',
  BORDER: 'rgba(255, 255, 255, 0.1)',
};

/** Text colors */
export const TEXT = {
  PRIMARY: '#FFFFFF',
  SECONDARY: '#E5E5EA',
  MUTED: '#8E8E93',
};

// ═══════════════════════════════════════════════════════════════════════════
// SEMANTIC COLORS (mapped to Apple HIG)
// ═══════════════════════════════════════════════════════════════════════════

/** XP Colors — ONLY when XP displayed/awarded */
export const XP = {
  PRIMARY: '#1FAD7E',      // Brand green (was #10B981)
  SECONDARY: '#34C759',    // Apple green
  ACCENT: '#FF9500',       // Apple orange (XP gain highlight)
};

/** Money Colors — ONLY for escrow/payment states */
export const MONEY = {
  POSITIVE: '#34C759',     // Apple green - incoming (was #10B981)
  NEGATIVE: '#FF3B30',     // Apple red - outgoing (was #EF4444)
  NEUTRAL: '#8E8E93',      // Apple gray - pending
  LOCKED: '#FF9500',       // Apple orange - disputed
};

/** Status Colors — ONLY for system state */
export const STATUS = {
  SUCCESS: '#34C759',      // Apple green (was #10B981)
  WARNING: '#FF9500',      // Apple orange (was #F59E0B)
  ERROR: '#FF3B30',        // Apple red (was #EF4444)
  INFO: '#007AFF',         // Apple blue (was #3B82F6)
};

// ═══════════════════════════════════════════════════════════════════════════
// NEUTRAL PALETTE (Zinc scale for subtle UI)
// ═══════════════════════════════════════════════════════════════════════════

export const ZINC = {
  200: '#E4E4E7',
  300: '#D4D4D8',
  400: '#A1A1AA',
  500: '#71717A',
  600: '#52525B',
  700: '#3F3F46',
  800: '#27272A',
};

// Legacy GRAY export (for backward compatibility)
export const GRAY = {
  50: '#F9FAFB',
  100: '#F3F4F6',
  200: '#E5E7EB',
  300: '#D1D5DB',
  400: '#9CA3AF',
  500: '#6B7280',
  600: '#4B5563',
  700: '#374151',
  800: '#1F2937',
  900: '#111827',
};

// ═══════════════════════════════════════════════════════════════════════════
// TRUST TIER COLORS
// ═══════════════════════════════════════════════════════════════════════════

export const TIER = {
  ROOKIE: '#71717A',       // Zinc 500 (matte gray)
  VERIFIED: '#007AFF',     // Apple Blue
  TRUSTED: '#FF9500',      // Apple Orange
  ELITE: '#FFD700',        // Gold
};

// ═══════════════════════════════════════════════════════════════════════════
// BADGE MATERIALS
// ═══════════════════════════════════════════════════════════════════════════

export const BADGE = {
  ROOKIE: {
    color: '#71717A',
  },
  VERIFIED: {
    start: '#71717A',
    end: '#A1A1AA',
  },
  TRUSTED: {
    start: '#FF9500',
    end: '#FCD34D',
    glow: '#1FAD7E',       // Brand green (was #10B981)
  },
};

// ═══════════════════════════════════════════════════════════════════════════
// LIVE MODE COLORS
// ═══════════════════════════════════════════════════════════════════════════

export const LIVE_MODE = {
  INDICATOR: '#FF3B30',    // Apple red (was #EF4444)
  STANDARD: '#8E8E93',     // Apple gray
  ACTIVE: '#34C759',       // Apple green (was #22C55E)
  COOLDOWN: '#FF9500',     // Apple orange
};

// ═══════════════════════════════════════════════════════════════════════════
// NEUTRAL COLORS (for general UI)
// ═══════════════════════════════════════════════════════════════════════════

export const NEUTRAL = {
  BACKGROUND: BACKGROUND.PRIMARY,
  BACKGROUND_SECONDARY: '#1C1C1E',
  TEXT: TEXT.PRIMARY,
  TEXT_SECONDARY: TEXT.SECONDARY,
  TEXT_MUTED: TEXT.MUTED,
  BORDER: GLASS.BORDER,
};

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY EXPORT (for backward compatibility)
// ═══════════════════════════════════════════════════════════════════════════

export const COLORS = {
  brand: BRAND,
  apple: APPLE,
  background: BACKGROUND,
  glass: GLASS,
  text: TEXT,
  xp: XP,
  money: MONEY,
  status: STATUS,
  tier: TIER,
  zinc: ZINC,
};
