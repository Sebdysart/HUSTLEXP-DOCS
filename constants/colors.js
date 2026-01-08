/**
 * HustleXP Design Tokens v1.0.1
 * 
 * SOURCE: tokens.css from HUSTLEXP-DOCS repo
 * AUTHORITY: UI Spec v1.0.1 — these values are constitutional.
 * 
 * COLOR AUTHORITY RULES (from UI_SPEC.md):
 * - C1: Money colors may ONLY be used for escrow/payment states
 * - C2: XP purple may ONLY appear when XP is displayed or awarded
 * - C3: No gradients on actionable buttons
 * - B0: Gold hues only in Tier 3+ badge materials
 */

// SEMANTIC COLORS (Legal Meaning)

/** Money Colors — ONLY for escrow states */
export const MONEY = {
  held: '#FF9500',      // Escrow FUNDED
  released: '#30D158',  // Escrow RELEASED
  disputed: '#FF3B30',  // LOCKED_DISPUTE
  pending: '#8E8E93',   // Escrow PENDING
};

/** XP Colors — ONLY when XP displayed/awarded */
export const XP = {
  primary: '#BF5AF2',   // Main XP purple
  secondary: '#DA8FFF', // XP progress bars
  tertiary: '#E8D4F8',  // XP backgrounds
};

/** Status Colors */
export const STATUS = {
  success: '#30D158',
  warning: '#FF9F0A',
  error: '#FF3B30',
  info: '#0A84FF',
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

// BADGE MATERIALS

export const BADGE = {
  steel: { start: '#71717A', end: '#A1A1AA' },
  alloy: { start: '#A8A29E', end: '#D6D3D1' },
  gold: { start: '#F59E0B', end: '#FCD34D' },
  obsidian: { start: '#18181B', end: '#3F3F46', glow: '#BF5AF2' },
};

// COMMON COLORS (for general UI)

export const COLORS = {
  background: '#FFFFFF',
  backgroundSecondary: GRAY[50],
  backgroundTertiary: GRAY[100],
  text: GRAY[900],
  textSecondary: GRAY[600],
  textTertiary: GRAY[400],
  textInverse: '#FFFFFF',
  border: GRAY[200],
  borderStrong: GRAY[300],
  disabled: GRAY[300],
  disabledText: GRAY[400],
};
