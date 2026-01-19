/**
 * HustleXP Design Tokens v1.3.0
 * 
 * AUTHORITY: UI_SPEC.md v1.3.0 §2 — these values are constitutional.
 * 
 * COLOR AUTHORITY RULES (from UI_SPEC.md §2):
 * - XP colors may ONLY be used for XP displays, level indicators, streak counters, progression bars, level-up celebrations
 * - Money colors may ONLY be used for escrow state indicators, payment amounts, wallet balances, transaction history
 * - Status colors may ONLY be used for system state (success, warning, error, info)
 * - No decorative use of semantic colors
 */

// SEMANTIC COLORS (Legal Meaning)

/** XP Colors — ONLY when XP displayed/awarded (UI_SPEC §2.2) */
export const XP = {
  PRIMARY: '#10B981',    // Emerald 500
  SECONDARY: '#34D399',  // Emerald 400
  BACKGROUND: '#D1FAE5', // Emerald 100
  ACCENT: '#059669',     // Emerald 600
};

/** Money Colors — ONLY for escrow/payment states (UI_SPEC §2.3) */
export const MONEY = {
  POSITIVE: '#10B981',  // Green - incoming
  NEGATIVE: '#EF4444',  // Red - outgoing
  NEUTRAL: '#6B7280',   // Gray - pending
  LOCKED: '#F59E0B',    // Amber - disputed
};

/** Status Colors — ONLY for system state (UI_SPEC §2.4) */
export const STATUS = {
  SUCCESS: '#10B981',   // Confirmation, completion
  WARNING: '#F59E0B',   // Attention needed, caution
  ERROR: '#EF4444',     // Failure, rejection, danger
  INFO: '#3B82F6',      // Neutral information
};

// NEUTRAL PALETTE

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

// BADGE MATERIALS (UI_SPEC §4.1 - Tier-Material Binding)

export const BADGE = {
  // ROOKIE tier - Matte (flat color, no effects)
  ROOKIE: {
    color: '#6B7280', // Gray-500
  },
  // VERIFIED tier - Metallic (subtle gradient, soft shine)
  VERIFIED: {
    start: '#71717A', // Zinc-500
    end: '#A1A1AA',   // Zinc-400
  },
  // TRUSTED tier - Holographic (animated gradient, premium)
  TRUSTED: {
    start: '#F59E0B', // Amber-500
    end: '#FCD34D',   // Amber-300
    glow: '#10B981',  // Emerald-500
  },
};

// LIVE MODE COLORS (UI_SPEC §13.1)

export const LIVE_MODE = {
  INDICATOR: '#EF4444',      // Red-500 - Live badge, active broadcast
  STANDARD: '#6B7280',       // Gray-500 - Standard mode, neutral
  ACTIVE: '#22C55E',         // Green-500 - Hustler Live Mode active
  COOLDOWN: '#F59E0B',       // Amber-500 - Hustler in cooldown
};

// NEUTRAL COLORS (No semantic meaning - UI_SPEC §2.1)

export const NEUTRAL = {
  BACKGROUND: '#FFFFFF',
  BACKGROUND_SECONDARY: GRAY[50],
  BACKGROUND_TERTIARY: GRAY[100],
  TEXT: GRAY[900],
  TEXT_SECONDARY: GRAY[600],
  TEXT_TERTIARY: GRAY[400],
  TEXT_INVERSE: '#FFFFFF',
  BORDER: GRAY[200],
  BORDER_STRONG: GRAY[300],
  DISABLED: GRAY[300],
  DISABLED_TEXT: GRAY[400],
};

// COMMON COLORS (for general UI - deprecated, use NEUTRAL)

export const COLORS = {
  background: NEUTRAL.BACKGROUND,
  backgroundSecondary: NEUTRAL.BACKGROUND_SECONDARY,
  backgroundTertiary: NEUTRAL.BACKGROUND_TERTIARY,
  text: NEUTRAL.TEXT,
  textSecondary: NEUTRAL.TEXT_SECONDARY,
  textTertiary: NEUTRAL.TEXT_TERTIARY,
  textInverse: NEUTRAL.TEXT_INVERSE,
  border: NEUTRAL.BORDER,
  borderStrong: NEUTRAL.BORDER_STRONG,
  disabled: NEUTRAL.DISABLED,
  disabledText: NEUTRAL.DISABLED_TEXT,
};
