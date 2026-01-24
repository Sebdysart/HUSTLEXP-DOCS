# HustleXP Design System

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Design/Frontend Team
**Last Updated:** January 2025
**Version:** v1.1.0
**Governance:** All UI implementation must use these design tokens. No hardcoded values.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Colors](#2-colors)
3. [Typography](#3-typography)
4. [Spacing](#4-spacing)
5. [Border Radius](#5-border-radius)
6. [Shadows](#6-shadows)
7. [Breakpoints](#7-breakpoints)
8. [Animation](#8-animation)
9. [Icons](#9-icons)
10. [Components](#10-components)

---

## 1. Overview

### Design Principles

1. **Clarity First** - Information hierarchy is immediately clear
2. **Speed Matters** - Animations are fast, loading states are brief
3. **Trust Through Simplicity** - No clutter, no confusion
4. **Mobile Native** - Designed for thumb navigation

### Token Structure

```typescript
// Import design tokens
import { colors, typography, spacing, radius, shadows } from '@/design-system';
```

---

## 2. Colors

> **⚠️ DEPRECATION NOTICE (2026-01-23)**
>
> The color values in this section are DEPRECATED. They use Material Design palette
> which conflicts with STITCH HTML specifications (Apple HIG colors).
>
> **For authoritative colors, see:**
> - `COLOR_AUTHORITY_RESOLUTION.md` (binding decision)
> - `BOOTSTRAP.md` (quick reference)
> - `.cursorrules` SECTION 7 (AI enforcement)
> - `ios-swiftui/HustleXP/Sources/HustleXP/DesignSystem/HustleColors.swift` (reference impl)
>
> **Correct values:**
> - Brand Primary: `#1FAD7E` (NOT `#4CAF50`)
> - Background: `#000000` (NOT `#121212`)
> - Success: `#34C759` (NOT `#4CAF50`)
> - Error: `#FF3B30` (NOT `#F44336`)
> - Info: `#007AFF` (NOT `#2196F3`)

### AUTHORITATIVE Colors (USE THESE)

```typescript
/**
 * AUTHORITATIVE COLOR TOKENS — from STITCH HTML / Apple HIG
 *
 * See: COLOR_AUTHORITY_RESOLUTION.md for complete specification
 */
export const colors = {
  // Brand
  brand: {
    primary: '#1FAD7E',      // HustleXP teal-green
    yellow: '#FFD900',       // Instant mode
  },

  // Apple System Colors (iOS HIG)
  apple: {
    red: '#FF3B30',
    orange: '#FF9500',
    green: '#34C759',
    blue: '#007AFF',
    gray: '#8E8E93',
  },

  // Semantic Colors
  success: '#34C759',        // Apple green
  warning: '#FF9500',        // Apple orange
  error: '#FF3B30',          // Apple red
  info: '#007AFF',           // Apple blue

  // State Colors
  live: '#FF3B30',           // Apple red
  funded: '#34C759',         // Apple green
  pending: '#FF9500',        // Apple orange
  disputed: '#FF9500',       // Apple orange

  // Background
  background: {
    primary: '#000000',      // Pure black
    elevated: '#1C1C1E',
  },

  // Glass (glassmorphism)
  glass: {
    surface: 'rgba(28, 28, 30, 0.6)',
    border: 'rgba(255, 255, 255, 0.1)',
  },

  // Text
  text: {
    primary: '#FFFFFF',
    secondary: '#E5E5EA',
    muted: '#8E8E93',
  },

  // Zinc scale (for subtle UI)
  zinc: {
    400: '#A1A1AA',
    500: '#71717A',
    600: '#52525B',
    700: '#3F3F46',
    800: '#27272A',
  },
};
```

### Usage

```typescript
// Correct — use authoritative tokens
<View style={{ backgroundColor: colors.brand.primary }} />
<View style={{ backgroundColor: colors.apple.green }} />
<Text style={{ color: colors.text.primary }} />

// WRONG — Material Design colors (deprecated)
// <View style={{ backgroundColor: '#4CAF50' }} />  // Use #1FAD7E or #34C759
// <View style={{ backgroundColor: '#121212' }} />  // Use #000000
```

---

## 3. Typography

### Font Family

```typescript
export const fontFamily = {
  // Primary: SF Pro (iOS) / Roboto (Android)
  regular: 'System',
  medium: 'System',
  semibold: 'System',
  bold: 'System',

  // Monospace (for numbers, codes)
  mono: 'SF Mono',  // iOS
  // mono: 'Roboto Mono', // Android
};
```

### Type Scale

```typescript
export const typography = {
  // Display - Hero text, celebrations
  display: {
    fontSize: 48,
    lineHeight: 56,
    fontWeight: '700',
    letterSpacing: -0.5,
  },

  // Heading 1 - Screen titles
  h1: {
    fontSize: 32,
    lineHeight: 40,
    fontWeight: '700',
    letterSpacing: -0.25,
  },

  // Heading 2 - Section headers
  h2: {
    fontSize: 24,
    lineHeight: 32,
    fontWeight: '600',
    letterSpacing: 0,
  },

  // Heading 3 - Card titles
  h3: {
    fontSize: 20,
    lineHeight: 28,
    fontWeight: '600',
    letterSpacing: 0.15,
  },

  // Heading 4 - Subsection headers
  h4: {
    fontSize: 18,
    lineHeight: 24,
    fontWeight: '600',
    letterSpacing: 0.15,
  },

  // Body Large - Primary content
  bodyLarge: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '400',
    letterSpacing: 0.5,
  },

  // Body - Default text
  body: {
    fontSize: 14,
    lineHeight: 20,
    fontWeight: '400',
    letterSpacing: 0.25,
  },

  // Body Small - Secondary text
  bodySmall: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '400',
    letterSpacing: 0.4,
  },

  // Caption - Metadata, timestamps
  caption: {
    fontSize: 11,
    lineHeight: 14,
    fontWeight: '400',
    letterSpacing: 0.5,
  },

  // Label - Buttons, inputs
  label: {
    fontSize: 14,
    lineHeight: 20,
    fontWeight: '500',
    letterSpacing: 0.1,
  },

  // Label Small - Tags, chips
  labelSmall: {
    fontSize: 11,
    lineHeight: 16,
    fontWeight: '500',
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },

  // Price - Currency display
  price: {
    fontSize: 24,
    lineHeight: 32,
    fontWeight: '700',
    letterSpacing: 0,
    fontFamily: 'mono',
  },

  // XP - Experience points
  xp: {
    fontSize: 20,
    lineHeight: 28,
    fontWeight: '700',
    letterSpacing: 0,
    fontFamily: 'mono',
  },
};
```

### Usage

```typescript
// Correct
<Text style={typography.h2}>Section Title</Text>

// With color
<Text style={[typography.body, { color: colors.neutral[700] }]}>
  Body text
</Text>
```

---

## 4. Spacing

### Base Unit: 4px

```typescript
export const spacing = {
  0: 0,
  1: 4,    // Tight
  2: 8,    // Default small
  3: 12,   // Small padding
  4: 16,   // Default padding
  5: 20,   // Medium
  6: 24,   // Section spacing
  7: 28,
  8: 32,   // Large
  10: 40,  // Extra large
  12: 48,  // Screen padding
  16: 64,  // Hero spacing
  20: 80,  // Section gaps
  24: 96,  // Major divisions
};
```

### Common Patterns

```typescript
// Card padding
padding: spacing[4]  // 16px

// List item spacing
marginBottom: spacing[2]  // 8px

// Section gap
marginTop: spacing[6]  // 24px

// Screen horizontal padding
paddingHorizontal: spacing[4]  // 16px

// Screen vertical padding
paddingTop: spacing[6]  // 24px
paddingBottom: spacing[8]  // 32px (for safe area)
```

---

## 5. Border Radius

```typescript
export const radius = {
  none: 0,
  xs: 2,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  xxl: 24,
  full: 9999,  // Pill/circle
};
```

### Common Patterns

```typescript
// Buttons
borderRadius: radius.md  // 8px

// Cards
borderRadius: radius.lg  // 12px

// Chips/Tags
borderRadius: radius.full  // Pill

// Avatars
borderRadius: radius.full  // Circle

// Input fields
borderRadius: radius.md  // 8px
```

---

## 6. Shadows

```typescript
export const shadows = {
  none: {
    shadowColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },

  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },

  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },

  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },

  xl: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },

  // Colored shadows for emphasis
  primary: {
    shadowColor: colors.primary[500],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },

  accent: {
    shadowColor: colors.accent[500],
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
};
```

---

## 7. Breakpoints

```typescript
export const breakpoints = {
  // Mobile first
  xs: 0,      // Small phones
  sm: 375,    // Standard phones
  md: 414,    // Large phones
  lg: 768,    // Tablets
  xl: 1024,   // Large tablets
  xxl: 1280,  // Desktop (future)
};

// Usage with hooks
const { width } = useWindowDimensions();
const isTablet = width >= breakpoints.lg;
```

---

## 8. Animation

### Duration

```typescript
export const duration = {
  instant: 0,
  fast: 150,
  normal: 300,
  slow: 500,
  slower: 800,
};
```

### Easing

```typescript
import { Easing } from 'react-native-reanimated';

export const easing = {
  // Standard easing
  standard: Easing.bezier(0.4, 0, 0.2, 1),

  // Decelerate (entering)
  decelerate: Easing.bezier(0, 0, 0.2, 1),

  // Accelerate (exiting)
  accelerate: Easing.bezier(0.4, 0, 1, 1),

  // Sharp (quick emphasis)
  sharp: Easing.bezier(0.4, 0, 0.6, 1),

  // Bounce (celebrations)
  bounce: Easing.bounce,

  // Spring config
  spring: {
    damping: 15,
    mass: 1,
    stiffness: 150,
  },
};
```

### Common Animations

```typescript
// Fade in
const fadeIn = {
  from: { opacity: 0 },
  to: { opacity: 1 },
  duration: duration.fast,
  easing: easing.decelerate,
};

// Slide up
const slideUp = {
  from: { translateY: 20, opacity: 0 },
  to: { translateY: 0, opacity: 1 },
  duration: duration.normal,
  easing: easing.decelerate,
};

// Scale pop (for celebrations)
const scalePop = {
  from: { scale: 0.8 },
  to: { scale: 1 },
  duration: duration.normal,
  easing: easing.spring,
};
```

---

## 9. Icons

### Icon Library

Use `lucide-react-native` for all icons.

```typescript
import {
  Home,
  Search,
  Bell,
  User,
  MapPin,
  Clock,
  DollarSign,
  CheckCircle,
  XCircle,
  AlertTriangle,
  // ... etc
} from 'lucide-react-native';
```

### Icon Sizes

```typescript
export const iconSize = {
  xs: 12,
  sm: 16,
  md: 20,
  lg: 24,
  xl: 32,
  xxl: 48,
};
```

### Usage

```typescript
<MapPin size={iconSize.md} color={colors.neutral[600]} />
```

---

## 10. Components

### Button Variants

```typescript
export const buttonVariants = {
  primary: {
    backgroundColor: colors.primary[500],
    textColor: colors.neutral[0],
    pressedBackgroundColor: colors.primary[700],
    disabledBackgroundColor: colors.neutral[300],
  },

  secondary: {
    backgroundColor: colors.neutral[0],
    textColor: colors.primary[500],
    borderColor: colors.primary[500],
    borderWidth: 1,
    pressedBackgroundColor: colors.primary[50],
  },

  ghost: {
    backgroundColor: 'transparent',
    textColor: colors.primary[500],
    pressedBackgroundColor: colors.primary[50],
  },

  danger: {
    backgroundColor: colors.error,
    textColor: colors.neutral[0],
    pressedBackgroundColor: '#D32F2F',
  },
};

export const buttonSizes = {
  sm: {
    height: 32,
    paddingHorizontal: spacing[3],
    ...typography.labelSmall,
  },

  md: {
    height: 44,
    paddingHorizontal: spacing[4],
    ...typography.label,
  },

  lg: {
    height: 52,
    paddingHorizontal: spacing[5],
    ...typography.label,
    fontSize: 16,
  },
};
```

### Card Styles

```typescript
export const cardStyles = {
  default: {
    backgroundColor: colors.neutral[0],
    borderRadius: radius.lg,
    padding: spacing[4],
    ...shadows.md,
  },

  elevated: {
    backgroundColor: colors.neutral[0],
    borderRadius: radius.lg,
    padding: spacing[4],
    ...shadows.lg,
  },

  outlined: {
    backgroundColor: colors.neutral[0],
    borderRadius: radius.lg,
    padding: spacing[4],
    borderWidth: 1,
    borderColor: colors.neutral[200],
  },

  task: {
    backgroundColor: colors.neutral[0],
    borderRadius: radius.lg,
    padding: spacing[4],
    ...shadows.md,
    borderLeftWidth: 4,
    borderLeftColor: colors.primary[500],
  },

  live: {
    backgroundColor: colors.neutral[0],
    borderRadius: radius.lg,
    padding: spacing[4],
    ...shadows.lg,
    borderWidth: 2,
    borderColor: colors.live,
  },
};
```

### Input Styles

```typescript
export const inputStyles = {
  default: {
    height: 48,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.neutral[300],
    paddingHorizontal: spacing[4],
    ...typography.body,
    backgroundColor: colors.neutral[0],
  },

  focused: {
    borderColor: colors.primary[500],
    borderWidth: 2,
  },

  error: {
    borderColor: colors.error,
    borderWidth: 2,
  },

  disabled: {
    backgroundColor: colors.neutral[100],
    borderColor: colors.neutral[200],
  },
};
```

### Trust Tier Colors

```typescript
export const trustTierColors = {
  1: { // ROOKIE
    background: colors.neutral[100],
    text: colors.neutral[600],
    badge: colors.neutral[400],
  },
  2: { // VERIFIED
    background: colors.secondary[50],
    text: colors.secondary[700],
    badge: colors.secondary[500],
  },
  3: { // TRUSTED
    background: colors.primary[50],
    text: colors.primary[700],
    badge: colors.primary[500],
  },
  4: { // ELITE
    background: colors.accent[50],
    text: colors.accent[800],
    badge: colors.accent[500],
  },
};
```

---

## Quick Reference

### Most Used Tokens (AUTHORITATIVE — Apple HIG)

| Token | Value | Use Case |
|-------|-------|----------|
| `colors.brand.primary` | #1FAD7E | Primary buttons, links |
| `colors.text.primary` | #FFFFFF | Primary text |
| `colors.text.muted` | #8E8E93 | Secondary text |
| `typography.title2` | 24px semibold | Section headers |
| `typography.body` | 16px regular | Default text |
| `spacing[4]` | 16px | Standard padding |
| `radius.2xl` | 24px | Card corners (glass) |
| `glass.surface` | rgba(28,28,30,0.6) | Cards |

---

## 11. Celebration Moments

Celebration animations are **earned, not given**. They follow the COD/Clash Royale layer (Layer 3) rules.

### Celebration Types

| Type | Trigger | Duration | Elements |
|------|---------|----------|----------|
| **Task Complete** | First task RELEASED | 2000ms | XP count-up, progress bar fill, haptic |
| **Badge Unlock** | Badge earned | 1500ms | Badge reveal, glow pulse, haptic burst |
| **Level Up** | XP threshold reached | 1800ms | Level number scale, shine sweep, haptic |
| **Payment Received** | Escrow RELEASED | 1200ms | Amount float, balance roll, haptic |
| **Streak Milestone** | 7/30/100/365 days | 1500ms | Fire icon, badge reveal, haptic |

### Celebration Animation Tokens

```typescript
export const celebrations = {
  // Task Complete
  taskComplete: {
    duration: 2000,
    sequence: [
      { element: 'xp', animation: 'countUp', delay: 0, duration: 800 },
      { element: 'progressBar', animation: 'fill', delay: 300, duration: 500 },
      { element: 'label', animation: 'fadeIn', delay: 800, duration: 400 },
      { element: 'settle', animation: 'scale', delay: 1600, duration: 400 },
    ],
    haptic: 'taskComplete',
    sound: 'celebration_first_task',
    serverFlag: 'xp_first_celebration_shown_at',
  },

  // Badge Unlock
  badgeUnlock: {
    duration: 1500,
    sequence: [
      { element: 'badge', animation: 'scaleIn', delay: 0, duration: 300 },
      { element: 'glow', animation: 'pulse', delay: 300, duration: 600 },
      { element: 'name', animation: 'fadeIn', delay: 600, duration: 300 },
      { element: 'settle', animation: 'none', delay: 900, duration: 600 },
    ],
    haptic: 'badgeUnlock',
    sound: 'celebration_badge_unlock',
    serverFlag: 'animation_shown_at',
  },

  // Level Up
  levelUp: {
    duration: 1800,
    sequence: [
      { element: 'levelNumber', animation: 'scaleUp', delay: 0, duration: 400 },
      { element: 'shine', animation: 'sweep', delay: 200, duration: 600 },
      { element: 'label', animation: 'fadeIn', delay: 600, duration: 400 },
      { element: 'settle', animation: 'scale', delay: 1200, duration: 600 },
    ],
    haptic: 'levelUp',
    sound: 'celebration_level_up',
    serverFlag: 'level_animation_shown_at',
  },

  // Payment Received
  paymentReceived: {
    duration: 1200,
    sequence: [
      { element: 'amount', animation: 'slideUp', delay: 0, duration: 100 },
      { element: 'amount', animation: 'floatUp', delay: 100, duration: 300 },
      { element: 'balance', animation: 'countUp', delay: 400, duration: 600 },
      { element: 'balance', animation: 'pulse', delay: 1000, duration: 200 },
    ],
    haptic: 'paymentReceived',
    sound: 'money_incoming',
    serverFlag: null, // Always plays on payment
  },

  // Streak Milestone
  streakMilestone: {
    duration: 1500,
    sequence: [
      { element: 'fire', animation: 'scaleUp', delay: 0, duration: 300 },
      { element: 'count', animation: 'countUp', delay: 200, duration: 400 },
      { element: 'badge', animation: 'reveal', delay: 600, duration: 500 },
      { element: 'settle', animation: 'none', delay: 1100, duration: 400 },
    ],
    haptic: 'badgeUnlock',
    sound: 'streak_milestone_30', // or _7, _100
    serverFlag: 'streak_milestone_shown_at',
  },
};
```

### Celebration Easing

```typescript
export const celebrationEasing = {
  // Scale in (badges, levels)
  scaleIn: {
    from: { scale: 0, opacity: 0 },
    to: { scale: 1, opacity: 1 },
    easing: easing.spring,
  },

  // Float up (payment amount)
  floatUp: {
    from: { translateY: 0, opacity: 1 },
    to: { translateY: -50, opacity: 0 },
    easing: easing.decelerate,
  },

  // Shine sweep (level up)
  shineSweep: {
    from: { translateX: -100, opacity: 0 },
    to: { translateX: 100, opacity: 0 },
    via: { translateX: 0, opacity: 0.8 },
    easing: Easing.linear,
  },

  // Glow pulse (badges)
  glowPulse: {
    from: { scale: 1, shadowRadius: 4 },
    via: { scale: 1.05, shadowRadius: 16 },
    to: { scale: 1, shadowRadius: 4 },
    easing: easing.standard,
  },

  // Count up (XP, balance)
  countUp: {
    easing: Easing.out(Easing.cubic),
    stepDuration: 30, // ms per increment
  },
};
```

### Celebration Colors

```typescript
export const celebrationColors = {
  // XP celebrations
  xp: {
    primary: colors.accent[500],    // Orange
    glow: colors.accent[300],
    text: colors.accent[700],
  },

  // Badge celebrations
  badge: {
    matte: colors.neutral[500],
    metallic: colors.secondary[500],
    holographic: `linear-gradient(45deg, ${colors.primary[400]}, ${colors.accent[400]}, ${colors.secondary[400]})`,
    obsidian: colors.neutral[900],
    glow: 'rgba(255, 255, 255, 0.3)',
  },

  // Level up
  level: {
    primary: colors.primary[500],
    shine: 'rgba(255, 255, 255, 0.6)',
    text: colors.primary[700],
  },

  // Payment
  payment: {
    amount: colors.success,
    background: colors.success + '10', // 10% opacity
    balance: colors.neutral[900],
  },

  // Streak (using Apple orange for warmth)
  streak: {
    fire: '#FF9500',           // Apple orange (was #FF6B35)
    fireGlow: '#FF950050',     // Apple orange 50% (was #FF6B3550)
    milestone: '#FF9500',      // Apple orange
  },
};
```

### Celebration Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **CELEB-1** | Celebrations play EXACTLY once per achievement | Server flag check |
| **CELEB-2** | Max duration 2000ms | Animation config |
| **CELEB-3** | No confetti (forbidden per UI_SPEC) | Code review |
| **CELEB-4** | Poster UI has NO celebrations | Role guard |
| **CELEB-5** | Reduced motion: instant state change | Accessibility check |
| **CELEB-6** | Server must confirm before celebration | State guard |

### Reduced Motion Alternatives

When `prefers-reduced-motion: reduce`:

| Celebration | Standard | Reduced Motion |
|-------------|----------|----------------|
| Task Complete | Full sequence | Static XP display + "First Task Complete!" label |
| Badge Unlock | Scale + glow | Static badge with "New" label |
| Level Up | Scale + shine | Static level number with "Level Up!" label |
| Payment | Float + count | Static balance with "+$X" indicator |
| Streak | Fire + count | Static streak count with milestone badge |

---

## 12. Loading & Progress Tokens

### Progress Indicators

```typescript
export const progressTokens = {
  // Linear progress bar
  linearProgress: {
    height: 4,
    backgroundColor: colors.neutral[200],
    fillColor: colors.primary[500],
    borderRadius: radius.full,
    animationDuration: duration.normal,
  },

  // Circular progress
  circularProgress: {
    size: 48,
    strokeWidth: 4,
    backgroundColor: colors.neutral[200],
    fillColor: colors.primary[500],
    animationDuration: duration.slow,
  },

  // XP progress bar
  xpProgress: {
    height: 8,
    backgroundColor: colors.neutral[200],
    fillColor: colors.accent[500],
    borderRadius: radius.full,
    glowColor: colors.accent[300],
    animationDuration: duration.slow,
  },
};
```

### Skeleton Tokens

```typescript
export const skeletonTokens = {
  // Base skeleton
  base: {
    backgroundColor: colors.neutral[200],
    shimmerColor: colors.neutral[100],
    borderRadius: radius.md,
  },

  // Shimmer animation
  shimmer: {
    duration: 1500,
    direction: 'ltr',
    gradient: `linear-gradient(90deg, transparent, ${colors.neutral[100]}, transparent)`,
  },

  // Component-specific
  text: {
    height: 16,
    borderRadius: radius.sm,
    widthPercent: 75,
  },

  avatar: {
    size: 48,
    borderRadius: radius.full,
  },

  card: {
    height: 120,
    borderRadius: radius.lg,
  },

  button: {
    height: 44,
    borderRadius: radius.md,
    widthPercent: 100,
  },
};
```

---

**END OF DESIGN_SYSTEM v1.1.0**
