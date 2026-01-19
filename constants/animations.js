/**
 * HustleXP Animation Tokens v1.3.0
 * 
 * AUTHORITY: UI_SPEC.md v1.3.0 §3 — these constraints are constitutional.
 * 
 * ANIMATION CONSTRAINTS (from UI_SPEC.md §3):
 * - Animations may NEVER imply state changes that haven't occurred
 * - Animations may NEVER play without server-confirmed trigger
 * - Animations may NEVER create false urgency
 * - Animations may NEVER manipulate user decisions
 * - Maximum duration: 2000ms (except loading)
 * - Reduced motion must be respected
 */

// Duration Limits (UI_SPEC §3.3)
export const DURATION = {
  MICRO_FEEDBACK: 150,    // Button press, toggle (max 150ms)
  STATE_TRANSITION: 300,   // Screen change, modal (max 300ms)
  CELEBRATION: 2000,       // Level up, badge unlock (max 2000ms)
  LOADING: null,          // Indefinite (but must show progress)
};

// First XP Celebration Sequence (UI_SPEC §12.4, ONBOARDING_SPEC §13.4)
export const FIRST_XP_CELEBRATION = {
  XP_NUMBER_FADE_IN: 300,      // 0-300ms: XP number fade in + scale
  PROGRESS_BAR_FILL: 500,      // 300-800ms: Progress bar linear fill
  MESSAGE_FADE_IN: 400,        // 800-1200ms: "First Task Complete!" fade in
  BADGE_UNLOCK: 600,           // 1200-1800ms: Badge unlock (if earned)
  SETTLE: 200,                 // 1800-2000ms: Settle to static
  TOTAL: 2000,                 // Maximum duration
};

// Standard Celebration (after first XP)
export const CELEBRATION = {
  XP_GAIN: 400,               // XP number animation
  PROGRESS_FILL: 500,         // Progress bar fill
  BADGE_UNLOCK: 400,          // Badge unlock animation
  SETTLE: 200,                // Settle to static
};

// Easing Functions (Deterministic, no randomness - UI_SPEC §3.2)
export const EASING = {
  OUT: 'cubic-bezier(0, 0, 0.2, 1)',
  IN_OUT: 'cubic-bezier(0.4, 0, 0.2, 1)',
  SPRING: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
};

// Forbidden Animation Patterns (UI_SPEC §3.2)
export const FORBIDDEN_PATTERNS = {
  CONFETTI: 'confetti',                    // Casino psychology
  INFINITE_LOOPS: 'infinite_loops',        // Attention hijacking
  RANDOMIZED_MOTION: 'randomized_motion',  // Unpredictable = untrustworthy
  SHAKE_VIBRATE: 'shake_vibrate',          // Aggressive, anxiety-inducing
  SLOT_MACHINE: 'slot_machine',           // Gambling association
  COUNTDOWN_URGENCY: 'countdown_urgency',  // False scarcity manipulation
};

// Animation Priority Order (UI_SPEC §3.4)
export const ANIMATION_PRIORITY = {
  ERROR: 1,
  SUCCESS: 2,
  INFO: 3,
  CELEBRATION: 4,
};

// Queue Limit (UI_SPEC §3.4)
export const MAX_QUEUED_ANIMATIONS = 2;
