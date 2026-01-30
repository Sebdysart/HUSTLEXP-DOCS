/**
 * Badge Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §6
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Status badges with semantic color variants.
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const VARIANT_COLORS = {
  default: {
    background: 'rgba(142, 142, 147, 0.2)', // Apple gray with opacity
    text: '#E5E5EA',
  },
  success: {
    background: 'rgba(52, 199, 89, 0.2)',  // Apple green with opacity
    text: '#34C759',
  },
  warning: {
    background: 'rgba(255, 149, 0, 0.2)',  // Apple orange with opacity
    text: '#FF9500',
  },
  error: {
    background: 'rgba(255, 59, 48, 0.2)',  // Apple red with opacity
    text: '#FF3B30',
  },
  info: {
    background: 'rgba(0, 122, 255, 0.2)',  // Apple blue with opacity
    text: '#007AFF',
  },
  live: {
    background: 'rgba(255, 59, 48, 0.2)',  // Apple red with opacity
    text: '#FF3B30',
    showDot: true,
  },
};

const SIZE_CONFIG = {
  sm: { height: 20, paddingH: 6, fontSize: 11 },
  md: { height: 24, paddingH: 8, fontSize: 12 },
};

// ═══════════════════════════════════════════════════════════════════════════
// BADGE COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} BadgeProps
 * @property {string} label - Badge text
 * @property {'default'|'success'|'warning'|'error'|'info'|'live'} [variant='default']
 * @property {'sm'|'md'} [size='md']
 * @property {React.ReactNode} [icon] - Leading icon
 */

/**
 * Status badge with semantic color variants
 *
 * @param {BadgeProps} props
 */
export function Badge({
  label,
  variant = 'default',
  size = 'md',
  icon,
}) {
  const variantConfig = VARIANT_COLORS[variant];
  const sizeConfig = SIZE_CONFIG[size];

  return (
    <View
      style={[
        styles.container,
        {
          height: sizeConfig.height,
          paddingHorizontal: sizeConfig.paddingH,
          backgroundColor: variantConfig.background,
          borderRadius: sizeConfig.height / 2,
        },
      ]}
    >
      {/* Live dot animation indicator */}
      {variantConfig.showDot && (
        <View style={[styles.liveDot, { backgroundColor: variantConfig.text }]} />
      )}

      {/* Leading icon */}
      {icon && <View style={styles.iconContainer}>{icon}</View>}

      {/* Label text */}
      <Text
        style={[
          styles.label,
          {
            fontSize: sizeConfig.fontSize,
            color: variantConfig.text,
          },
        ]}
      >
        {label}
      </Text>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
  },
  liveDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 4,
  },
  iconContainer: {
    marginRight: 4,
  },
  label: {
    fontWeight: '600',
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
});

export default Badge;
