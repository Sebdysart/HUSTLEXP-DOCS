/**
 * HustleXP Input Component
 * 
 * SPEC COMPLIANCE:
 * - A4: Touch targets minimum 44×44px
 * - A2: Focus states visible
 */

import React, { useState } from 'react';
import { View, TextInput, Text, StyleSheet } from 'react-native';
import { COLORS, STATUS } from '../constants/colors';
import { SPACING, RADIUS, TOUCH } from '../constants/spacing';
import { FONT_SIZE, FONT_WEIGHT } from '../constants/typography';

export function Input({
  label,
  error,
  hint,
  containerStyle,
  ...textInputProps
}) {
  const [isFocused, setIsFocused] = useState(false);

  const getBorderColor = () => {
    if (error) return STATUS.error;
    if (isFocused) return '#111827';
    return COLORS.border;
  };

  return (
    <View style={[styles.container, containerStyle]}>
      {label && <Text style={styles.label}>{label}</Text>}
      
      <TextInput
        {...textInputProps}
        style={[
          styles.input,
          { borderColor: getBorderColor() },
          isFocused && styles.inputFocused,
          error && styles.inputError,
        ]}
        placeholderTextColor={COLORS.textTertiary}
        onFocus={(e) => {
          setIsFocused(true);
          textInputProps.onFocus?.(e);
        }}
        onBlur={(e) => {
          setIsFocused(false);
          textInputProps.onBlur?.(e);
        }}
        accessibilityLabel={label || textInputProps.placeholder}
      />
      
      {error && <Text style={styles.error}>{error}</Text>}
      {hint && !error && <Text style={styles.hint}>{hint}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  label: {
    fontSize: FONT_SIZE.sm,
    fontWeight: FONT_WEIGHT.medium,
    color: COLORS.text,
    marginBottom: SPACING[2],
  },
  input: {
    minHeight: TOUCH.comfortable,
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    fontSize: FONT_SIZE.base,
    color: COLORS.text,
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: RADIUS.md,
  },
  inputFocused: {
    borderWidth: 2,
  },
  inputError: {
    borderColor: STATUS.error,
  },
  error: {
    fontSize: FONT_SIZE.sm,
    color: STATUS.error,
    marginTop: SPACING[1],
  },
  hint: {
    fontSize: FONT_SIZE.sm,
    color: COLORS.textSecondary,
    marginTop: SPACING[1],
  },
});

export default Input;
