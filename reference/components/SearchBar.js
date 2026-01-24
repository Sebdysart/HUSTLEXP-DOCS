/**
 * SearchBar Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §8
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Search input with cancel button and clear functionality.
 */

import React, { useState, useRef } from 'react';
import {
  View,
  TextInput,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
} from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: {
    elevated: '#1C1C1E',
  },
  text: {
    primary: '#FFFFFF',
    muted: '#8E8E93',
  },
  apple: {
    blue: '#007AFF',
    gray: '#8E8E93',
  },
};

const SPACING = {
  2: 8,
  3: 12,
  4: 16,
};

const RADIUS = {
  lg: 12,
};

// ═══════════════════════════════════════════════════════════════════════════
// SEARCHBAR COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} SearchBarProps
 * @property {string} value - Current search value
 * @property {(text: string) => void} onChangeText - Text change handler
 * @property {string} [placeholder='Search'] - Placeholder text
 * @property {boolean} [showCancel=false] - Show cancel button when focused
 * @property {() => void} [onCancel] - Cancel button handler
 * @property {() => void} [onFocus] - Focus handler
 * @property {() => void} [onBlur] - Blur handler
 * @property {() => void} [onSubmit] - Submit handler
 * @property {boolean} [autoFocus=false] - Auto focus on mount
 */

/**
 * Search input with iOS-style cancel button
 *
 * @param {SearchBarProps} props
 */
export function SearchBar({
  value,
  onChangeText,
  placeholder = 'Search',
  showCancel = false,
  onCancel,
  onFocus,
  onBlur,
  onSubmit,
  autoFocus = false,
}) {
  const [isFocused, setIsFocused] = useState(false);
  const inputRef = useRef(null);
  const cancelWidth = useRef(new Animated.Value(0)).current;

  const handleFocus = () => {
    setIsFocused(true);
    if (showCancel) {
      Animated.timing(cancelWidth, {
        toValue: 60,
        duration: 200,
        useNativeDriver: false,
      }).start();
    }
    onFocus?.();
  };

  const handleBlur = () => {
    setIsFocused(false);
    if (showCancel && !value) {
      Animated.timing(cancelWidth, {
        toValue: 0,
        duration: 200,
        useNativeDriver: false,
      }).start();
    }
    onBlur?.();
  };

  const handleCancel = () => {
    onChangeText('');
    inputRef.current?.blur();
    Animated.timing(cancelWidth, {
      toValue: 0,
      duration: 200,
      useNativeDriver: false,
    }).start();
    onCancel?.();
  };

  const handleClear = () => {
    onChangeText('');
    inputRef.current?.focus();
  };

  return (
    <View style={styles.container}>
      <View style={styles.inputContainer}>
        {/* Search Icon */}
        <Text style={styles.searchIcon}>🔍</Text>

        {/* Input */}
        <TextInput
          ref={inputRef}
          style={styles.input}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={COLORS.text.muted}
          onFocus={handleFocus}
          onBlur={handleBlur}
          onSubmitEditing={onSubmit}
          returnKeyType="search"
          autoFocus={autoFocus}
          autoCapitalize="none"
          autoCorrect={false}
        />

        {/* Clear Button */}
        {value.length > 0 && (
          <TouchableOpacity onPress={handleClear} style={styles.clearButton}>
            <Text style={styles.clearIcon}>✕</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Cancel Button */}
      {showCancel && (
        <Animated.View style={[styles.cancelContainer, { width: cancelWidth }]}>
          <TouchableOpacity onPress={handleCancel}>
            <Text style={styles.cancelText}>Cancel</Text>
          </TouchableOpacity>
        </Animated.View>
      )}
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
  },
  inputContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.background.elevated,
    borderRadius: RADIUS.lg,
    paddingHorizontal: SPACING[3],
    height: 44,
  },
  searchIcon: {
    fontSize: 14,
    marginRight: SPACING[2],
    opacity: 0.6,
  },
  input: {
    flex: 1,
    color: COLORS.text.primary,
    fontSize: 16,
    padding: 0,
  },
  clearButton: {
    marginLeft: SPACING[2],
    padding: 4,
  },
  clearIcon: {
    color: COLORS.apple.gray,
    fontSize: 14,
  },
  cancelContainer: {
    overflow: 'hidden',
    justifyContent: 'center',
  },
  cancelText: {
    color: COLORS.apple.blue,
    fontSize: 16,
    marginLeft: SPACING[3],
  },
});

export default SearchBar;
