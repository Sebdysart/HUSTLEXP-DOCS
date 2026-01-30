/**
 * Skeleton Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §13
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Loading placeholder with shimmer animation.
 */

import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Dimensions } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  skeleton: {
    base: '#27272A',      // Zinc 800
    highlight: '#3F3F46', // Zinc 700
  },
};

const RADIUS = {
  sm: 4,
  md: 8,
  lg: 12,
  '2xl': 24,
  full: 9999,
};

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON BASE COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} SkeletonProps
 * @property {number|string} width - Element width
 * @property {number} height - Element height
 * @property {'sm'|'md'|'lg'|'2xl'|'full'} [borderRadius='md']
 * @property {Object} [style] - Additional styles
 */

/**
 * Base skeleton element with shimmer animation
 *
 * @param {SkeletonProps} props
 */
export function Skeleton({
  width,
  height,
  borderRadius = 'md',
  style,
}) {
  const shimmerAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const animation = Animated.loop(
      Animated.sequence([
        Animated.timing(shimmerAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(shimmerAnim, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    );
    animation.start();
    return () => animation.stop();
  }, [shimmerAnim]);

  const shimmerOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.7],
  });

  return (
    <Animated.View
      style={[
        styles.skeleton,
        {
          width,
          height,
          borderRadius: RADIUS[borderRadius],
          opacity: shimmerOpacity,
        },
        style,
      ]}
    />
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON PRESETS
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Skeleton for text lines
 */
export function SkeletonText({ width = '100%', lines = 1, lineHeight = 16, spacing = 8 }) {
  return (
    <View style={styles.textContainer}>
      {Array.from({ length: lines }).map((_, index) => (
        <Skeleton
          key={index}
          width={index === lines - 1 && lines > 1 ? '70%' : width}
          height={lineHeight}
          borderRadius="sm"
          style={index < lines - 1 ? { marginBottom: spacing } : undefined}
        />
      ))}
    </View>
  );
}

/**
 * Skeleton for avatar/circle elements
 */
export function SkeletonAvatar({ size = 48 }) {
  return (
    <Skeleton
      width={size}
      height={size}
      borderRadius="full"
    />
  );
}

/**
 * Skeleton for TaskCard
 */
export function SkeletonTaskCard() {
  return (
    <View style={styles.taskCard}>
      {/* Header */}
      <View style={styles.taskCardHeader}>
        <SkeletonAvatar size={32} />
        <View style={styles.taskCardHeaderText}>
          <Skeleton width={100} height={14} borderRadius="sm" />
          <Skeleton width={60} height={12} borderRadius="sm" style={{ marginTop: 4 }} />
        </View>
      </View>

      {/* Content */}
      <Skeleton width="90%" height={20} borderRadius="sm" style={{ marginTop: 12 }} />
      <Skeleton width="60%" height={14} borderRadius="sm" style={{ marginTop: 8 }} />

      {/* Footer */}
      <View style={styles.taskCardFooter}>
        <Skeleton width={80} height={24} borderRadius="md" />
        <Skeleton width={100} height={14} borderRadius="sm" />
      </View>
    </View>
  );
}

/**
 * Skeleton for list of TaskCards
 */
export function SkeletonTaskList({ count = 3 }) {
  return (
    <View>
      {Array.from({ length: count }).map((_, index) => (
        <SkeletonTaskCard key={index} />
      ))}
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  skeleton: {
    backgroundColor: COLORS.skeleton.base,
  },
  textContainer: {
    width: '100%',
  },
  taskCard: {
    backgroundColor: 'rgba(28, 28, 30, 0.6)',
    borderRadius: RADIUS['2xl'],
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    padding: 16,
    marginBottom: 12,
  },
  taskCardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  taskCardHeaderText: {
    marginLeft: 12,
  },
  taskCardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 16,
  },
});

export default Skeleton;
