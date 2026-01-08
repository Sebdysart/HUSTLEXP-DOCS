/**
 * HustleXP Card Component
 */

import React from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { COLORS, GRAY } from '../constants/colors';
import { SPACING, RADIUS } from '../constants/spacing';

export function Card({
  children,
  variant = 'elevated',
  padding = 4,
  onPress,
  style,
}) {
  const cardStyle = [
    styles.base,
    styles[variant],
    { padding: SPACING[padding] },
    style,
  ];

  if (onPress) {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          cardStyle,
          pressed && styles.pressed,
        ]}
        accessibilityRole="button"
      >
        {children}
      </Pressable>
    );
  }

  return <View style={cardStyle}>{children}</View>;
}

const styles = StyleSheet.create({
  base: {
    borderRadius: RADIUS.lg,
    overflow: 'hidden',
  },
  elevated: {
    backgroundColor: COLORS.background,
    shadowColor: GRAY[900],
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 2,
  },
  outlined: {
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  filled: {
    backgroundColor: COLORS.backgroundSecondary,
  },
  pressed: {
    opacity: 0.9,
    transform: [{ scale: 0.99 }],
  },
});

export default Card;
