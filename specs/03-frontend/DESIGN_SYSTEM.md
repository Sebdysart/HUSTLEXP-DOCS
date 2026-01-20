# HustleXP Design System

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Design/Frontend Team
**Last Updated:** January 2025
**Version:** v1.0.0
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

### Brand Colors

```typescript
export const colors = {
  // Primary - HustleXP Green
  primary: {
    50:  '#E8F5E9',
    100: '#C8E6C9',
    200: '#A5D6A7',
    300: '#81C784',
    400: '#66BB6A',
    500: '#4CAF50',  // Primary action
    600: '#43A047',
    700: '#388E3C',
    800: '#2E7D32',
    900: '#1B5E20',
  },

  // Secondary - Deep Blue
  secondary: {
    50:  '#E3F2FD',
    100: '#BBDEFB',
    200: '#90CAF9',
    300: '#64B5F6',
    400: '#42A5F5',
    500: '#2196F3',  // Secondary action
    600: '#1E88E5',
    700: '#1976D2',
    800: '#1565C0',
    900: '#0D47A1',
  },

  // Accent - Warm Orange (XP, celebrations)
  accent: {
    50:  '#FFF3E0',
    100: '#FFE0B2',
    200: '#FFCC80',
    300: '#FFB74D',
    400: '#FFA726',
    500: '#FF9800',  // XP color
    600: '#FB8C00',
    700: '#F57C00',
    800: '#EF6C00',
    900: '#E65100',
  },

  // Neutral - Grays
  neutral: {
    0:   '#FFFFFF',
    50:  '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    400: '#BDBDBD',
    500: '#9E9E9E',
    600: '#757575',
    700: '#616161',
    800: '#424242',
    900: '#212121',
    1000: '#000000',
  },

  // Semantic Colors
  success: '#4CAF50',
  warning: '#FF9800',
  error: '#F44336',
  info: '#2196F3',

  // State Colors
  live: '#F44336',      // Live mode indicator
  funded: '#4CAF50',    // Escrow funded
  pending: '#FF9800',   // Awaiting action
  disputed: '#9C27B0',  // Dispute state
};
```

### Dark Mode Colors

```typescript
export const darkColors = {
  background: {
    primary: '#121212',
    secondary: '#1E1E1E',
    elevated: '#2D2D2D',
  },
  text: {
    primary: 'rgba(255, 255, 255, 0.87)',
    secondary: 'rgba(255, 255, 255, 0.60)',
    disabled: 'rgba(255, 255, 255, 0.38)',
  },
  // Primary colors remain the same
};
```

### Usage

```typescript
// Correct
<View style={{ backgroundColor: colors.primary[500] }} />

// Incorrect - never hardcode
<View style={{ backgroundColor: '#4CAF50' }} />
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

### Most Used Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `colors.primary[500]` | #4CAF50 | Primary buttons, links |
| `colors.neutral[700]` | #616161 | Body text |
| `colors.neutral[500]` | #9E9E9E | Secondary text |
| `typography.h2` | 24px semibold | Section headers |
| `typography.body` | 14px regular | Default text |
| `spacing[4]` | 16px | Standard padding |
| `radius.lg` | 12px | Card corners |
| `shadows.md` | Elevation 2 | Cards |

---

**END OF DESIGN_SYSTEM v1.0.0**
