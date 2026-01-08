/**
 * HustleXP Button Component
 * 
 * SPEC COMPLIANCE:
 * - A4: Touch targets minimum 44×44px
 * - C3: No gradients on actionable buttons
 */

import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { COLORS, GRAY, STATUS } from '../constants/colors';
import { SPACING, RADIUS, TOUCH } from '../constants/spacing';
import { FONT_SIZE, FONT_WEIGHT } from '../constants/typography';

export function Button({
  title,
  onPress,
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  fullWidth = false,
  style,
  textStyle,
  accessibilityLabel,
}) {
  const isDisabled = disabled || loading;

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={isDisabled}
      activeOpacity={0.7}
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel || title}
      accessibilityState={{ disabled: isDisabled }}
      style={[
        styles.base,
        styles[variant],
        styles[`size_${size}`],
        fullWidth && styles.fullWidth,
        isDisabled && styles.disabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator
          size="small"
          color={variant === 'primary' ? COLORS.textInverse : COLORS.text}
        />
      ) : (
        <Text
          style={[
            styles.text,
            styles[`text_${variant}`],
            styles[`text_${size}`],
            isDisabled && styles.textDisabled,
            textStyle,
          ]}
        >
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    minHeight: TOUCH.min,
    minWidth: TOUCH.min,
    borderRadius: RADIUS.md,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  primary: {
    backgroundColor: GRAY[900],
  },
  secondary: {
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: GRAY[300],
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  danger: {
    backgroundColor: STATUS.error,
  },
  size_sm: {
    minHeight: TOUCH.min,
    paddingHorizontal: SPACING[3],
    paddingVertical: SPACING[2],
  },
  size_md: {
    minHeight: TOUCH.comfortable,
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
  },
  size_lg: {
    minHeight: 56,
    paddingHorizontal: SPACING[6],
    paddingVertical: SPACING[4],
  },
  fullWidth: {
    width: '100%',
  },
  disabled: {
    backgroundColor: COLORS.disabled,
    borderColor: COLORS.disabled,
  },
  text: {
    fontWeight: FONT_WEIGHT.semibold,
    textAlign: 'center',
  },
  text_primary: {
    color: COLORS.textInverse,
  },
  text_secondary: {
    color: COLORS.text,
  },
  text_ghost: {
    color: COLORS.text,
  },
  text_danger: {
    color: COLORS.textInverse,
  },
  text_sm: {
    fontSize: FONT_SIZE.sm,
  },
  text_md: {
    fontSize: FONT_SIZE.base,
  },
  text_lg: {
    fontSize: FONT_SIZE.lg,
  },
  textDisabled: {
    color: COLORS.disabledText,
  },
});

export default Button;
