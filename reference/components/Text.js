/**
 * HustleXP Text Component
 */

import React from 'react';
import { Text as RNText, StyleSheet } from 'react-native';
import { COLORS } from '../constants/colors';
import { FONT_SIZE, FONT_WEIGHT, LINE_HEIGHT } from '../constants/typography';

export function HXText({
  variant = 'body',
  color = 'primary',
  weight,
  align,
  style,
  children,
  ...props
}) {
  return (
    <RNText
      {...props}
      style={[
        styles[variant],
        colorStyles[color],
        weight && { fontWeight: FONT_WEIGHT[weight] },
        align && { textAlign: align },
        style,
      ]}
    >
      {children}
    </RNText>
  );
}

const styles = StyleSheet.create({
  h1: {
    fontSize: FONT_SIZE['4xl'],
    fontWeight: FONT_WEIGHT.bold,
    lineHeight: FONT_SIZE['4xl'] * LINE_HEIGHT.tight,
  },
  h2: {
    fontSize: FONT_SIZE['3xl'],
    fontWeight: FONT_WEIGHT.bold,
    lineHeight: FONT_SIZE['3xl'] * LINE_HEIGHT.tight,
  },
  h3: {
    fontSize: FONT_SIZE['2xl'],
    fontWeight: FONT_WEIGHT.semibold,
    lineHeight: FONT_SIZE['2xl'] * LINE_HEIGHT.tight,
  },
  h4: {
    fontSize: FONT_SIZE.xl,
    fontWeight: FONT_WEIGHT.semibold,
    lineHeight: FONT_SIZE.xl * LINE_HEIGHT.normal,
  },
  body: {
    fontSize: FONT_SIZE.base,
    fontWeight: FONT_WEIGHT.normal,
    lineHeight: FONT_SIZE.base * LINE_HEIGHT.normal,
  },
  bodySmall: {
    fontSize: FONT_SIZE.sm,
    fontWeight: FONT_WEIGHT.normal,
    lineHeight: FONT_SIZE.sm * LINE_HEIGHT.normal,
  },
  caption: {
    fontSize: FONT_SIZE.xs,
    fontWeight: FONT_WEIGHT.normal,
    lineHeight: FONT_SIZE.xs * LINE_HEIGHT.normal,
  },
  label: {
    fontSize: FONT_SIZE.sm,
    fontWeight: FONT_WEIGHT.medium,
    lineHeight: FONT_SIZE.sm * LINE_HEIGHT.normal,
  },
});

const colorStyles = StyleSheet.create({
  primary: { color: COLORS.text },
  secondary: { color: COLORS.textSecondary },
  tertiary: { color: COLORS.textTertiary },
  inverse: { color: COLORS.textInverse },
  error: { color: '#111827' },
});

export default HXText;
