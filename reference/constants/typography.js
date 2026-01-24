/**
 * HustleXP Typography Tokens v2.0.0
 *
 * UPDATED 2026-01-23: Aligned with STITCH HTML specifications (Apple HIG)
 *
 * AUTHORITY: TYPOGRAPHY_AUTHORITY_RESOLUTION.md
 *
 * DEPRECATED VALUES (do not use):
 * - xs/sm/base/lg/xl (Tailwind scale)
 * - h1/h2/h3/h4 (Material Design naming)
 * - 48px display (Material Design)
 */

import { Platform } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// FONT FAMILY
// ═══════════════════════════════════════════════════════════════════════════

export const FONT_FAMILY = {
  regular: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
  mono: Platform.select({
    ios: 'Menlo',
    android: 'monospace',
    default: 'monospace',
  }),
};

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TYPOGRAPHY SCALE (Apple HIG / STITCH HTML)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Font weights as numeric strings (React Native convention)
 */
export const FONT_WEIGHT = {
  regular: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
};

/**
 * Typography styles — USE THESE
 *
 * Each style includes: fontSize, fontWeight, letterSpacing, lineHeight
 */
export const TYPOGRAPHY = {
  /** Display — Hero headlines, splash screens */
  display: {
    fontSize: 36,
    fontWeight: FONT_WEIGHT.bold,
    letterSpacing: -0.5,
    lineHeight: 44,
  },

  /** Title1 — Section headers, card titles */
  title1: {
    fontSize: 28,
    fontWeight: FONT_WEIGHT.bold,
    letterSpacing: -0.3,
    lineHeight: 34,
  },

  /** Title2 — Secondary headers, modal titles */
  title2: {
    fontSize: 24,
    fontWeight: FONT_WEIGHT.semibold,
    letterSpacing: 0,
    lineHeight: 30,
  },

  /** Title3 — Tertiary headers, list section headers */
  title3: {
    fontSize: 20,
    fontWeight: FONT_WEIGHT.semibold,
    letterSpacing: 0,
    lineHeight: 26,
  },

  /** Headline — Button text, emphasized body */
  headline: {
    fontSize: 18,
    fontWeight: FONT_WEIGHT.semibold,
    letterSpacing: 0,
    lineHeight: 24,
  },

  /** Body — Primary content text */
  body: {
    fontSize: 16,
    fontWeight: FONT_WEIGHT.regular,
    letterSpacing: 0,
    lineHeight: 22,
  },

  /** Callout — Secondary content, descriptions */
  callout: {
    fontSize: 14,
    fontWeight: FONT_WEIGHT.regular,
    letterSpacing: 0,
    lineHeight: 20,
  },

  /** Caption — Labels, metadata */
  caption: {
    fontSize: 12,
    fontWeight: FONT_WEIGHT.medium,
    letterSpacing: 0,
    lineHeight: 16,
  },

  /** Micro — Badges, tiny labels, uppercase text */
  micro: {
    fontSize: 10,
    fontWeight: FONT_WEIGHT.semibold,
    letterSpacing: 1,
    lineHeight: 14,
  },
};

// ═══════════════════════════════════════════════════════════════════════════
// CONVENIENCE EXPORTS (font sizes only, for simple usage)
// ═══════════════════════════════════════════════════════════════════════════

export const FONT_SIZE = {
  display: 36,
  title1: 28,
  title2: 24,
  title3: 20,
  headline: 18,
  body: 16,
  callout: 14,
  caption: 12,
  micro: 10,
};

export const LINE_HEIGHT = {
  display: 44,
  title1: 34,
  title2: 30,
  title3: 26,
  headline: 24,
  body: 22,
  callout: 20,
  caption: 16,
  micro: 14,
};

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY EXPORTS (for backward compatibility — DEPRECATED)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @deprecated Use TYPOGRAPHY or FONT_SIZE instead
 *
 * Mapping:
 * - xs → caption (12px)
 * - sm → callout (14px)
 * - base → body (16px)
 * - lg → headline (18px)
 * - xl → title3 (20px)
 * - 2xl → title2 (24px)
 * - 3xl → NOT USED (30px not in STITCH)
 * - 4xl → display (36px)
 */
export const FONT_SIZE_LEGACY = {
  xs: 12,
  sm: 14,
  base: 16,
  lg: 18,
  xl: 20,
  '2xl': 24,
  '3xl': 30, // NOT IN STITCH — avoid using
  '4xl': 36,
};
