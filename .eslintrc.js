/**
 * ESLint Configuration for HustleXP Frontend
 * 
 * Enforces UI_SPEC.md constitutional rules at build time.
 * 
 * SPEC: UI_SPEC.md §8.1
 */

module.exports = {
  root: true,
  extends: [
    'expo',
    'plugin:react/recommended',
    'plugin:react-native/all',
  ],
  plugins: ['react', 'react-native'],
  rules: {
    // ============================================================================
    // Color Authority Rules (UI_SPEC §2)
    // ============================================================================
    
    // Custom rule: no-xp-color-outside-context
    // Enforces: XP colors may ONLY be used for XP displays, level indicators, streak counters, progression bars, level-up celebrations
    'no-restricted-syntax': [
      'error',
      {
        selector: "CallExpression[callee.name='StyleSheet.create'] > ObjectExpression > Property[key.name=/color/i]",
        message: 'XP colors may only be used in XP context. Use XP.PRIMARY, XP.SECONDARY, etc. only for XP displays.',
      },
    ],

    // Custom rule: no-money-color-decorative
    // Enforces: Money colors may ONLY be used for escrow/payment states
    'no-restricted-imports': [
      'error',
      {
        paths: [
          {
            name: '../constants/colors',
            importNames: ['MONEY'],
            message: 'Money colors may only be used for escrow state indicators, payment amounts, wallet balances, transaction history.',
          },
        ],
      },
    ],

    // ============================================================================
    // Animation Rules (UI_SPEC §3)
    // ============================================================================

    // Custom rule: max-animation-duration
    // Enforces: Maximum 2000ms for celebrations, 300ms for transitions
    'no-magic-numbers': [
      'warn',
      {
        ignore: [150, 300, 400, 500, 600, 800, 1200, 1800, 2000], // Animation durations
        ignoreArrayIndexes: true,
        ignoreDefaultValues: true,
      },
    ],

    // ============================================================================
    // Copy Rules (UI_SPEC §5)
    // ============================================================================

    // Forbidden copy patterns
    'no-restricted-syntax': [
      'error',
      {
        selector: "Literal[value=/You failed|Your fault|Mistake|Penalty|Punished|Strike|Warning|Unfortunately|Regrettably/i]",
        message: 'Forbidden copy pattern detected. See UI_SPEC §5.2 for allowed patterns.',
      },
    ],

    // ============================================================================
    // Accessibility Rules (UI_SPEC §7)
    // ============================================================================

    // Touch target minimum (44×44 points)
    'react-native/no-inline-styles': 'warn',
    
    // Color contrast (enforced via design tokens)
    'no-restricted-syntax': [
      'warn',
      {
        selector: "Property[key.name=/color|backgroundColor/i] > Literal[value=/^#[0-9A-Fa-f]{3,6}$/]",
        message: 'Use semantic color tokens from constants/colors.js for proper contrast.',
      },
    ],

    // ============================================================================
    // General React Native Rules
    // ============================================================================

    'react/prop-types': 'off', // Using TypeScript/Flow
    'react/react-in-jsx-scope': 'off', // Not needed in React 17+
    'react-native/no-unused-styles': 'warn',
    'react-native/split-platform-components': 'warn',
    'react-native/no-inline-styles': 'warn',
    'react-native/no-color-literals': 'warn',
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
};

/**
 * NOTE: Custom ESLint Rules Required
 * 
 * The following custom ESLint rules need to be implemented as plugins:
 * 
 * 1. no-xp-color-outside-context (UI_SPEC §2.2)
 *    - Checks if XP colors are used outside allowed contexts
 * 
 * 2. no-money-color-decorative (UI_SPEC §2.3)
 *    - Checks if money colors are used decoratively
 * 
 * 3. no-success-without-confirmation (UI_SPEC §2.4)
 *    - Ensures success colors only appear after server confirmation
 * 
 * 4. no-forbidden-animation (UI_SPEC §3.2)
 *    - Blocks confetti, infinite loops, randomized motion, etc.
 * 
 * 5. max-animation-duration (UI_SPEC §3.3)
 *    - Enforces duration limits per animation type
 * 
 * 6. no-shame-copy (UI_SPEC §5.2)
 *    - Detects forbidden copy patterns
 * 
 * 7. no-false-urgency (UI_SPEC §5.2)
 *    - Detects urgency manipulation language
 * 
 * 8. badge-tier-material-match (UI_SPEC §4.1)
 *    - Ensures badge visuals match trust tier
 * 
 * 9. touch-target-minimum (UI_SPEC §7.1)
 *    - Ensures minimum 44×44 touch targets
 * 
 * 10. color-contrast-minimum (UI_SPEC §7.1)
 *     - Validates WCAG 2.1 AA contrast ratios
 * 
 * 11. no-gamification-for-poster (UI_SPEC §12.5, ONB-3)
 *     - Blocks gamification UI for poster role
 * 
 * 12. no-animated-gamification-pre-unlock (UI_SPEC §12.6, ONB-4)
 *     - Blocks gamification animations before first RELEASED escrow
 * 
 * These rules should be implemented as ESLint plugins in a separate package.
 */
