/**
 * Header Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §16
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Navigation header with back button, title, and action buttons.
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: '#000000',
  glass: {
    surface: 'rgba(0, 0, 0, 0.8)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  text: {
    primary: '#FFFFFF',
    muted: '#8E8E93',
  },
  apple: {
    blue: '#007AFF',
  },
};

const SPACING = {
  2: 8,
  3: 12,
  4: 16,
};

// ═══════════════════════════════════════════════════════════════════════════
// HEADER COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} HeaderAction
 * @property {string} icon - Action icon (emoji or icon name)
 * @property {() => void} onPress - Action press handler
 * @property {string} [label] - Accessibility label
 */

/**
 * @typedef {Object} HeaderProps
 * @property {string} [title] - Header title
 * @property {string} [subtitle] - Header subtitle
 * @property {() => void} [onBack] - Back button handler
 * @property {string} [backLabel='Back'] - Back button label
 * @property {HeaderAction[]} [rightActions] - Right side actions
 * @property {boolean} [transparent=false] - Transparent background
 * @property {boolean} [showBorder=true] - Show bottom border
 * @property {number} [topInset=0] - Safe area top inset
 * @property {React.ReactNode} [titleComponent] - Custom title component
 */

/**
 * Navigation header with iOS styling
 *
 * @param {HeaderProps} props
 */
export function Header({
  title,
  subtitle,
  onBack,
  backLabel = 'Back',
  rightActions = [],
  transparent = false,
  showBorder = true,
  topInset = 0,
  titleComponent,
}) {
  return (
    <View
      style={[
        styles.container,
        transparent && styles.transparent,
        showBorder && styles.bordered,
        { paddingTop: topInset },
      ]}
    >
      <View style={styles.content}>
        {/* Left Section - Back Button */}
        <View style={styles.leftSection}>
          {onBack && (
            <TouchableOpacity
              onPress={onBack}
              style={styles.backButton}
              hitSlop={{ top: 10, right: 10, bottom: 10, left: 10 }}
            >
              <Text style={styles.backIcon}>‹</Text>
              <Text style={styles.backLabel}>{backLabel}</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Center Section - Title */}
        <View style={styles.centerSection}>
          {titleComponent ? (
            titleComponent
          ) : (
            <>
              {title && (
                <Text style={styles.title} numberOfLines={1}>
                  {title}
                </Text>
              )}
              {subtitle && (
                <Text style={styles.subtitle} numberOfLines={1}>
                  {subtitle}
                </Text>
              )}
            </>
          )}
        </View>

        {/* Right Section - Actions */}
        <View style={styles.rightSection}>
          {rightActions.map((action, index) => (
            <TouchableOpacity
              key={index}
              onPress={action.onPress}
              style={styles.actionButton}
              hitSlop={{ top: 10, right: 10, bottom: 10, left: 10 }}
              accessibilityLabel={action.label}
            >
              <Text style={styles.actionIcon}>{action.icon}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LARGE HEADER VARIANT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} LargeHeaderProps
 * @property {string} title - Large title text
 * @property {string} [subtitle] - Subtitle text
 * @property {React.ReactNode} [rightComponent] - Right side component
 * @property {number} [topInset=0] - Safe area top inset
 */

/**
 * Large title header (iOS style)
 *
 * @param {LargeHeaderProps} props
 */
export function LargeHeader({
  title,
  subtitle,
  rightComponent,
  topInset = 0,
}) {
  return (
    <View style={[styles.largeContainer, { paddingTop: topInset + SPACING[4] }]}>
      <View style={styles.largeContent}>
        <View style={styles.largeTitleSection}>
          <Text style={styles.largeTitle}>{title}</Text>
          {subtitle && <Text style={styles.largeSubtitle}>{subtitle}</Text>}
        </View>

        {rightComponent && (
          <View style={styles.largeRightSection}>{rightComponent}</View>
        )}
      </View>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    backgroundColor: COLORS.glass.surface,
  },
  transparent: {
    backgroundColor: 'transparent',
  },
  bordered: {
    borderBottomWidth: 1,
    borderBottomColor: COLORS.glass.border,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 44,
    paddingHorizontal: SPACING[2],
  },
  leftSection: {
    flex: 1,
    alignItems: 'flex-start',
  },
  centerSection: {
    flex: 2,
    alignItems: 'center',
  },
  rightSection: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: SPACING[2],
  },
  backIcon: {
    color: COLORS.apple.blue,
    fontSize: 28,
    fontWeight: '300',
    marginRight: -2,
  },
  backLabel: {
    color: COLORS.apple.blue,
    fontSize: 17,
  },
  title: {
    color: COLORS.text.primary,
    fontSize: 17,
    fontWeight: '600',
  },
  subtitle: {
    color: COLORS.text.muted,
    fontSize: 12,
    marginTop: 1,
  },
  actionButton: {
    paddingHorizontal: SPACING[2],
    paddingVertical: SPACING[2],
  },
  actionIcon: {
    fontSize: 22,
  },

  // Large Header
  largeContainer: {
    backgroundColor: COLORS.background,
    paddingHorizontal: SPACING[4],
    paddingBottom: SPACING[3],
  },
  largeContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
  largeTitleSection: {
    flex: 1,
  },
  largeTitle: {
    color: COLORS.text.primary,
    fontSize: 34,
    fontWeight: '700',
    letterSpacing: -0.5,
  },
  largeSubtitle: {
    color: COLORS.text.muted,
    fontSize: 14,
    marginTop: 4,
  },
  largeRightSection: {
    marginLeft: SPACING[4],
  },
});

export default Header;
