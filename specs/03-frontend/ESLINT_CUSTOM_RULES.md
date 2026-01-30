# HustleXP Custom ESLint Rules

**AUTHORITY:** UI_SPEC.md, ONBOARDING_SPEC.md, FRONTEND_ARCHITECTURE.md
**STATUS:** Implementation Guide for eslint-plugin-hustlexp
**VERSION:** 1.0.0

This document defines custom ESLint rules that enforce UI_SPEC compliance at build time.

---

## Overview

The `eslint-plugin-hustlexp` package provides rules that:
1. Prevent color misuse (XP colors in wrong contexts)
2. Block forbidden animations (confetti, shake, etc.)
3. Catch shame language in copy
4. Enforce gamification timing rules

---

## Rule: no-xp-color-outside-context

**Severity:** error
**Authority:** UI_SPEC §2.2

XP colors (`#10B981`, `#34D399`, `#D1FAE5`, `#059669`) may only appear in:
- XP amount displays
- Level badges
- Streak indicators
- Progression bars
- Level-up celebrations

### Implementation

```javascript
module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'XP colors must only be used in XP-related contexts',
    },
  },
  create(context) {
    const XP_COLORS = ['#10B981', '#34D399', '#D1FAE5', '#059669'];
    const XP_CONTEXTS = [
      'XPDisplay', 'LevelBadge', 'StreakIndicator',
      'ProgressionBar', 'FirstXPCelebration', 'LevelUp'
    ];

    return {
      JSXAttribute(node) {
        if (node.name.name === 'style' || node.name.name === 'color') {
          const value = getColorValue(node.value);
          if (XP_COLORS.includes(value)) {
            const component = findParentComponent(node);
            if (!XP_CONTEXTS.some(ctx => component.includes(ctx))) {
              context.report({
                node,
                message: `XP color "${value}" can only be used in XP-related components`,
              });
            }
          }
        }
      },
    };
  },
};
```

### Examples

```tsx
// ❌ ERROR: XP color in task card
<View style={{ backgroundColor: '#10B981' }}>
  <Text>Task Title</Text>
</View>

// ✅ OK: XP color in XP display
<XPDisplay>
  <Text style={{ color: '#10B981' }}>{xpAmount}</Text>
</XPDisplay>
```

---

## Rule: no-money-color-decorative

**Severity:** error
**Authority:** UI_SPEC §2.3

Money colors may only be used for:
- Escrow state indicators
- Payment amounts
- Wallet balances
- Transaction history

### Implementation

```javascript
const MONEY_COLORS = {
  positive: '#10B981',
  negative: '#EF4444',
  neutral: '#6B7280',
  locked: '#F59E0B',
};

const MONEY_CONTEXTS = [
  'MoneyTimeline', 'WalletScreen', 'EscrowIndicator',
  'PaymentAmount', 'TransactionRow', 'BalanceDisplay'
];
```

---

## Rule: no-success-without-confirmation

**Severity:** error
**Authority:** UI_SPEC §9.1

Success color (`#10B981` in non-XP context) may only appear after server confirmation.

### Pattern Detection

```javascript
// ❌ ERROR: Optimistic success state
setStatus('success');
await api.complete();

// ✅ OK: Server-confirmed success
const result = await api.complete();
if (result.success) {
  setStatus('success');
}
```

---

## Rule: no-forbidden-animation

**Severity:** error
**Authority:** UI_SPEC §3.2

Forbidden patterns:
- Confetti
- Infinite loops
- Shake/vibrate
- Slot machine reveals
- Countdown urgency

### Implementation

```javascript
const FORBIDDEN_PATTERNS = [
  'confetti',
  'Confetti',
  'confettiCannon',
  'shake',
  'vibrate',
  'Vibration.vibrate',
  'pulse.*infinite',
  'loop.*true',
  'iterations.*-1',
  'countdown',
  'slotMachine',
];

module.exports = {
  create(context) {
    return {
      Identifier(node) {
        const name = node.name.toLowerCase();
        if (FORBIDDEN_PATTERNS.some(p => name.includes(p.toLowerCase()))) {
          context.report({
            node,
            message: `Forbidden animation pattern: ${node.name}`,
          });
        }
      },
      ImportDeclaration(node) {
        const source = node.source.value.toLowerCase();
        if (source.includes('confetti') || source.includes('slot-machine')) {
          context.report({
            node,
            message: 'Forbidden animation library',
          });
        }
      },
    };
  },
};
```

---

## Rule: max-animation-duration

**Severity:** error
**Authority:** UI_SPEC §3.1

Animation durations:
- Micro-feedback: 150ms max
- State transition: 300ms max
- Celebration: 2000ms max

### Implementation

```javascript
module.exports = {
  meta: {
    schema: [{ type: 'object', properties: { max: { type: 'number' } } }],
  },
  create(context) {
    const maxDuration = context.options[0]?.max || 2000;

    return {
      Property(node) {
        if (node.key.name === 'duration' && node.value.type === 'Literal') {
          if (node.value.value > maxDuration) {
            context.report({
              node,
              message: `Animation duration ${node.value.value}ms exceeds max ${maxDuration}ms`,
            });
          }
        }
      },
    };
  },
};
```

---

## Rule: no-shame-copy

**Severity:** error
**Authority:** UI_SPEC §15

Forbidden phrases:
- "You failed"
- "Your fault"
- "Penalty"
- "Punished"
- "Unfortunately"
- "Regrettably"

### Implementation

```javascript
const SHAME_PATTERNS = [
  /you failed/i,
  /your fault/i,
  /penalty/i,
  /punished/i,
  /unfortunately/i,
  /regrettably/i,
  /we're sorry but/i,
  /you didn't/i,
  /you forgot/i,
];

module.exports = {
  create(context) {
    return {
      Literal(node) {
        if (typeof node.value === 'string') {
          for (const pattern of SHAME_PATTERNS) {
            if (pattern.test(node.value)) {
              context.report({
                node,
                message: `Shame language detected: "${node.value.substring(0, 50)}..."`,
              });
            }
          }
        }
      },
      TemplateLiteral(node) {
        for (const quasi of node.quasis) {
          for (const pattern of SHAME_PATTERNS) {
            if (pattern.test(quasi.value.raw)) {
              context.report({
                node,
                message: `Shame language detected in template literal`,
              });
            }
          }
        }
      },
    };
  },
};
```

---

## Rule: no-false-urgency

**Severity:** error
**Authority:** UI_SPEC §13

Forbidden in Live Mode:
- "Act now!"
- "Hurry!"
- "Limited time"
- "Don't miss out"
- Countdown timers

### Implementation

```javascript
const URGENCY_PATTERNS = [
  /act now/i,
  /hurry/i,
  /limited time/i,
  /don't miss/i,
  /running out/i,
  /last chance/i,
  /expires soon/i,
];
```

---

## Rule: no-gamification-for-poster

**Severity:** error
**Authority:** ONBOARDING_SPEC §13.2 (ONB-3)

Posters never see gamification:
- No XP displays
- No level indicators
- No badges
- No streak counters

### Implementation

```javascript
const GAMIFICATION_COMPONENTS = [
  'XPDisplay', 'LevelBadge', 'BadgeDisplay',
  'StreakCounter', 'LevelProgress', 'FirstXPCelebration'
];

module.exports = {
  create(context) {
    return {
      JSXElement(node) {
        const name = node.openingElement.name.name;
        if (GAMIFICATION_COMPONENTS.includes(name)) {
          // Check if inside poster-only screen
          const filename = context.getFilename();
          if (filename.includes('Poster') || filename.includes('poster')) {
            context.report({
              node,
              message: `Gamification component "${name}" forbidden in poster screens`,
            });
          }
        }
      },
    };
  },
};
```

---

## Rule: no-animated-gamification-pre-unlock

**Severity:** error
**Authority:** ONBOARDING_SPEC §13.3 (ONB-4)

Before first RELEASED escrow:
- No animated XP
- No celebration modals
- Only LockedGamificationUI allowed

### Pattern Detection

Detect use of animated gamification without unlock check:

```tsx
// ❌ ERROR: No unlock check
<FirstXPCelebration xpAmount={100} />

// ✅ OK: With unlock check
{hasFirstReleasedEscrow && <FirstXPCelebration xpAmount={100} />}

// ✅ OK: Locked state
{!hasFirstReleasedEscrow && <LockedGamificationUI />}
```

---

## Package Setup

### package.json

```json
{
  "name": "eslint-plugin-hustlexp",
  "version": "1.0.0",
  "main": "index.js",
  "peerDependencies": {
    "eslint": ">=8.0.0"
  }
}
```

### index.js

```javascript
module.exports = {
  rules: {
    'no-xp-color-outside-context': require('./rules/no-xp-color-outside-context'),
    'no-money-color-decorative': require('./rules/no-money-color-decorative'),
    'no-success-without-confirmation': require('./rules/no-success-without-confirmation'),
    'no-forbidden-animation': require('./rules/no-forbidden-animation'),
    'max-animation-duration': require('./rules/max-animation-duration'),
    'no-shame-copy': require('./rules/no-shame-copy'),
    'no-false-urgency': require('./rules/no-false-urgency'),
    'no-gamification-for-poster': require('./rules/no-gamification-for-poster'),
    'no-animated-gamification-pre-unlock': require('./rules/no-animated-gamification-pre-unlock'),
  },
  configs: {
    recommended: {
      plugins: ['hustlexp'],
      rules: {
        'hustlexp/no-xp-color-outside-context': 'error',
        'hustlexp/no-money-color-decorative': 'error',
        'hustlexp/no-forbidden-animation': 'error',
        'hustlexp/max-animation-duration': ['error', { max: 2000 }],
        'hustlexp/no-shame-copy': 'error',
        'hustlexp/no-gamification-for-poster': 'error',
      },
    },
  },
};
```

---

## Usage

### Installation

```bash
npm install --save-dev eslint-plugin-hustlexp
```

### Configuration

```json
// .eslintrc.json
{
  "plugins": ["hustlexp"],
  "extends": ["plugin:hustlexp/recommended"]
}
```

---

**END OF CUSTOM ESLINT RULES**
