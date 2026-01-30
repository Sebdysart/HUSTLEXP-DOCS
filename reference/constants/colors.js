/**
 * HustleXP Design Tokens v3.0.0
 *
 * ⚠️ UPDATED 2026-01-24: Black + Purple brand identity
 *
 * AUTHORITY: COLOR_SEMANTICS_LAW.md (supersedes all previous color docs)
 *
 * BRAND IDENTITY RULES:
 * - Brand: Black + Purple (NOT green)
 * - Entry screens: Black background + purple gradient/glow
 * - Green is SUCCESS-ONLY (never on entry screens)
 *
 * COLOR SEMANTIC RULES:
 * - Purple: Brand, energy, ambition, CTAs on entry
 * - Green: SUCCESS STATES ONLY (after positive outcome)
 * - Red: Errors, live mode
 * - Orange: Warnings, XP, gamification
 * - Blue: Info, trust, links
 */

// ═══════════════════════════════════════════════════════════════════════════
// BRAND IDENTITY (Black + Purple)
// ═══════════════════════════════════════════════════════════════════════════

/** Brand Canvas - Used for entry screens, identity surfaces */
export const BRAND = {
  BLACK: '#0B0B0F',           // Near-black (premium feel)
  PURPLE: '#5B2DFF',          // Electric purple (primary accent)
  PURPLE_LIGHT: '#7A4DFF',    // Lighter purple (gradients)
  PURPLE_GLOW: '#8B5CF6',     // Glow effects
  PURPLE_MUTED: '#A78BFA',    // Softer purple (secondary)

  // ⚠️ DEPRECATED - Use successGreen instead for money/success
  // PRIMARY: '#1FAD7E',      // REMOVED - was causing green entry screens
  YELLOW: '#FFD900',          // Instant mode only
};

/** Brand Gradient Presets */
export const BRAND_GRADIENTS = {
  // Entry screen gradient (purple tint fading to black)
  ENTRY: ['#1a0a2e', '#0B0B0F', '#000000'],
  ENTRY_LOCATIONS: [0, 0.3, 1],

  // Purple glow gradient
  GLOW: ['#5B2DFF', '#8B5CF6'],

  // Premium dark gradient
  DARK: ['#1C1C1E', '#0B0B0F', '#000000'],
};

// ═══════════════════════════════════════════════════════════════════════════
// SUCCESS / MONEY (Use ONLY after positive outcomes)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * ⚠️ SUCCESS GREEN - ONLY for success states, NEVER on entry screens
 *
 * ALLOWED: Task completed, escrow released, money received, confirmations
 * FORBIDDEN: Entry backgrounds, brand surfaces, onboarding
 */
export const SUCCESS = {
  GREEN: '#34C759',           // Apple HIG green
  MONEY_GREEN: '#1FAD7E',     // HustleXP teal (for money displays)
};

// ═══════════════════════════════════════════════════════════════════════════
// STATUS COLORS (Contextual use only)
// ═══════════════════════════════════════════════════════════════════════════

/** Apple System Colors (iOS HIG) */
export const APPLE = {
  RED: '#FF3B30',
  ORANGE: '#FF9500',
  GREEN: '#34C759',
  BLUE: '#007AFF',
  GRAY: '#8E8E93',
};

/** Status Colors — ONLY for system state */
export const STATUS = {
  SUCCESS: '#34C759',         // Apple green - ONLY after success
  WARNING: '#FF9500',         // Apple orange
  ERROR: '#FF3B30',           // Apple red
  INFO: '#007AFF',            // Apple blue
};

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND & SURFACES
// ═══════════════════════════════════════════════════════════════════════════

/** Background & Surfaces */
export const BACKGROUND = {
  PRIMARY: '#000000',         // Pure black
  BRAND: '#0B0B0F',           // Near-black (premium)
  ELEVATED: '#1C1C1E',
};

/** Glass (glassmorphism) */
export const GLASS = {
  SURFACE: 'rgba(28, 28, 30, 0.6)',
  SURFACE_DARK: 'rgba(11, 11, 15, 0.8)',
  BORDER: 'rgba(255, 255, 255, 0.1)',
  PURPLE_TINT: 'rgba(91, 45, 255, 0.1)',
};

// ═══════════════════════════════════════════════════════════════════════════
// TEXT COLORS
// ═══════════════════════════════════════════════════════════════════════════

/** Text colors */
export const TEXT = {
  PRIMARY: '#FFFFFF',
  SECONDARY: '#E5E5EA',
  MUTED: '#8E8E93',
  PURPLE: '#A78BFA',          // Purple text for accents
};

// ═══════════════════════════════════════════════════════════════════════════
// SEMANTIC COLORS (Contextual use)
// ═══════════════════════════════════════════════════════════════════════════

/** XP Colors — ONLY when XP displayed/awarded */
export const XP = {
  PRIMARY: '#8B5CF6',         // Purple (brand-aligned)
  SECONDARY: '#A78BFA',       // Lighter purple
  ACCENT: '#FF9500',          // Apple orange (XP gain highlight)
};

/** Money Colors — ONLY for escrow/payment states */
export const MONEY = {
  POSITIVE: '#34C759',        // Apple green - incoming
  NEGATIVE: '#FF3B30',        // Apple red - outgoing
  NEUTRAL: '#8E8E93',         // Apple gray - pending
  LOCKED: '#FF9500',          // Apple orange - disputed
};

// ═══════════════════════════════════════════════════════════════════════════
// TRUST TIER COLORS
// ═══════════════════════════════════════════════════════════════════════════

export const TIER = {
  ROOKIE: '#71717A',          // Zinc 500 (matte gray)
  VERIFIED: '#007AFF',        // Apple Blue
  TRUSTED: '#8B5CF6',         // Purple (brand-aligned)
  ELITE: '#FFD700',           // Gold
};

// ═══════════════════════════════════════════════════════════════════════════
// LIVE MODE COLORS
// ═══════════════════════════════════════════════════════════════════════════

export const LIVE_MODE = {
  INDICATOR: '#FF3B30',       // Apple red
  STANDARD: '#8E8E93',        // Apple gray
  ACTIVE: '#34C759',          // Apple green (active state only)
  COOLDOWN: '#FF9500',        // Apple orange
};

// ═══════════════════════════════════════════════════════════════════════════
// NEUTRAL PALETTE
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

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SCREEN COLORS (COPY THESE EXACTLY)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Pre-configured colors for entry screens
 * Use these to avoid accidentally using green
 */
export const ENTRY_SCREEN = {
  background: '#0B0B0F',
  gradientColors: ['#1a0a2e', '#0B0B0F', '#000000'],
  gradientLocations: [0, 0.3, 1],
  glowColor: '#5B2DFF',
  glowOpacity: 0.2,
  buttonBackground: '#5B2DFF',
  buttonText: '#FFFFFF',
  headlineText: '#FFFFFF',
  subtitleText: '#E5E5EA',
  mutedText: '#8E8E93',
  linkText: '#A78BFA',
};

// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED EXPORT
// ═══════════════════════════════════════════════════════════════════════════

export const COLORS = {
  brand: BRAND,
  brandGradients: BRAND_GRADIENTS,
  success: SUCCESS,
  apple: APPLE,
  background: BACKGROUND,
  glass: GLASS,
  text: TEXT,
  xp: XP,
  money: MONEY,
  status: STATUS,
  tier: TIER,
  liveMode: LIVE_MODE,
  zinc: ZINC,
  entryScreen: ENTRY_SCREEN,
};

export default COLORS;
