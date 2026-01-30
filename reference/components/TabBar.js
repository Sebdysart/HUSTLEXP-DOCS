/**
 * TabBar Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §15
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Bottom tab bar navigation with glassmorphism styling.
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  glass: {
    surface: 'rgba(28, 28, 30, 0.8)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  text: {
    primary: '#FFFFFF',
    muted: '#8E8E93',
  },
  brand: {
    primary: '#1FAD7E',
  },
};

const SPACING = {
  1: 4,
  2: 8,
};

// ═══════════════════════════════════════════════════════════════════════════
// TABBAR COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} TabItem
 * @property {string} key - Tab identifier
 * @property {string} label - Tab label
 * @property {string} icon - Tab icon (emoji or icon name)
 * @property {string} [activeIcon] - Icon when active
 * @property {number} [badge] - Badge count
 */

/**
 * @typedef {Object} TabBarProps
 * @property {TabItem[]} tabs - Tab items
 * @property {string} activeTab - Currently active tab key
 * @property {(key: string) => void} onTabPress - Tab press handler
 * @property {number} [bottomInset=0] - Safe area bottom inset
 */

/**
 * Bottom tab bar with glassmorphism
 *
 * @param {TabBarProps} props
 */
export function TabBar({
  tabs,
  activeTab,
  onTabPress,
  bottomInset = 0,
}) {
  return (
    <View style={[styles.container, { paddingBottom: bottomInset }]}>
      <View style={styles.tabsRow}>
        {tabs.map((tab) => {
          const isActive = activeTab === tab.key;

          return (
            <TouchableOpacity
              key={tab.key}
              style={styles.tab}
              onPress={() => onTabPress(tab.key)}
              activeOpacity={0.7}
            >
              {/* Icon */}
              <View style={styles.iconContainer}>
                <Text
                  style={[
                    styles.icon,
                    isActive && styles.iconActive,
                  ]}
                >
                  {isActive && tab.activeIcon ? tab.activeIcon : tab.icon}
                </Text>

                {/* Badge */}
                {tab.badge !== undefined && tab.badge > 0 && (
                  <View style={styles.badge}>
                    <Text style={styles.badgeText}>
                      {tab.badge > 99 ? '99+' : tab.badge}
                    </Text>
                  </View>
                )}
              </View>

              {/* Label */}
              <Text
                style={[
                  styles.label,
                  isActive && styles.labelActive,
                ]}
              >
                {tab.label}
              </Text>
            </TouchableOpacity>
          );
        })}
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
    borderTopWidth: 1,
    borderTopColor: COLORS.glass.border,
  },
  tabsRow: {
    flexDirection: 'row',
    height: 49,
  },
  tab: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: SPACING[1],
  },
  iconContainer: {
    position: 'relative',
    marginBottom: SPACING[1],
  },
  icon: {
    fontSize: 24,
    opacity: 0.6,
  },
  iconActive: {
    opacity: 1,
  },
  badge: {
    position: 'absolute',
    top: -4,
    right: -10,
    minWidth: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: '#FF3B30',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 4,
  },
  badgeText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '700',
  },
  label: {
    color: COLORS.text.muted,
    fontSize: 10,
    fontWeight: '500',
  },
  labelActive: {
    color: COLORS.brand.primary,
  },
});

export default TabBar;
