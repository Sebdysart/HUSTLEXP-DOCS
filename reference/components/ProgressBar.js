/**
 * ProgressBar Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §12
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Progress indicator for XP, levels, and task completion.
 */

import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  brand: {
    primary: '#1FAD7E',
  },
  apple: {
    green: '#34C759',
    orange: '#FF9500',
    blue: '#007AFF',
    gray: '#8E8E93',
  },
  text: {
    primary: '#FFFFFF',
    muted: '#8E8E93',
  },
  background: {
    elevated: '#1C1C1E',
  },
};

const VARIANT_COLORS = {
  xp: {
    fill: COLORS.brand.primary,
    background: 'rgba(31, 173, 126, 0.2)',
  },
  level: {
    fill: COLORS.apple.green,
    background: 'rgba(52, 199, 89, 0.2)',
  },
  task: {
    fill: COLORS.apple.blue,
    background: 'rgba(0, 122, 255, 0.2)',
  },
  warning: {
    fill: COLORS.apple.orange,
    background: 'rgba(255, 149, 0, 0.2)',
  },
  default: {
    fill: COLORS.apple.gray,
    background: COLORS.background.elevated,
  },
};

const SIZE_CONFIG = {
  sm: { height: 4, borderRadius: 2 },
  md: { height: 8, borderRadius: 4 },
  lg: { height: 12, borderRadius: 6 },
};

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESSBAR COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} ProgressBarProps
 * @property {number} progress - Progress value (0-100)
 * @property {'xp'|'level'|'task'|'warning'|'default'} [variant='default']
 * @property {'sm'|'md'|'lg'} [size='md']
 * @property {boolean} [animated=true] - Animate progress changes
 * @property {boolean} [showLabel=false] - Show percentage label
 * @property {string} [label] - Custom label text
 */

/**
 * Animated progress bar with semantic variants
 *
 * @param {ProgressBarProps} props
 */
export function ProgressBar({
  progress,
  variant = 'default',
  size = 'md',
  animated = true,
  showLabel = false,
  label,
}) {
  const animatedWidth = useRef(new Animated.Value(0)).current;
  const variantConfig = VARIANT_COLORS[variant];
  const sizeConfig = SIZE_CONFIG[size];

  // Clamp progress between 0 and 100
  const clampedProgress = Math.min(100, Math.max(0, progress));

  useEffect(() => {
    if (animated) {
      Animated.timing(animatedWidth, {
        toValue: clampedProgress,
        duration: 500,
        useNativeDriver: false,
      }).start();
    } else {
      animatedWidth.setValue(clampedProgress);
    }
  }, [clampedProgress, animated, animatedWidth]);

  const widthInterpolation = animatedWidth.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  });

  return (
    <View style={styles.container}>
      {/* Progress Track */}
      <View
        style={[
          styles.track,
          {
            height: sizeConfig.height,
            borderRadius: sizeConfig.borderRadius,
            backgroundColor: variantConfig.background,
          },
        ]}
      >
        {/* Progress Fill */}
        <Animated.View
          style={[
            styles.fill,
            {
              width: widthInterpolation,
              height: sizeConfig.height,
              borderRadius: sizeConfig.borderRadius,
              backgroundColor: variantConfig.fill,
            },
          ]}
        />
      </View>

      {/* Label */}
      {showLabel && (
        <Text style={styles.label}>
          {label || `${Math.round(clampedProgress)}%`}
        </Text>
      )}
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  track: {
    width: '100%',
    overflow: 'hidden',
  },
  fill: {
    position: 'absolute',
    left: 0,
    top: 0,
  },
  label: {
    color: COLORS.text.muted,
    fontSize: 12,
    fontWeight: '500',
    marginTop: 4,
    textAlign: 'right',
  },
});

export default ProgressBar;
