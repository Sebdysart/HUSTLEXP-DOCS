/**
 * BottomSheet Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §10
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * iOS-style bottom sheet with drag-to-dismiss and snap points.
 */

import React, { useEffect, useRef } from 'react';
import {
  View,
  Modal,
  TouchableWithoutFeedback,
  StyleSheet,
  Animated,
  PanResponder,
  Dimensions,
} from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  glass: {
    surface: 'rgba(28, 28, 30, 0.95)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  overlay: 'rgba(0, 0, 0, 0.5)',
  handle: 'rgba(255, 255, 255, 0.3)',
};

const SPACING = {
  2: 8,
  3: 12,
  4: 16,
};

const RADIUS = {
  '2xl': 24,
};

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOMSHEET COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} BottomSheetProps
 * @property {boolean} visible - Sheet visibility
 * @property {() => void} onClose - Close handler
 * @property {React.ReactNode} children - Sheet content
 * @property {string[]} [snapPoints=['50%']] - Snap point percentages
 * @property {boolean} [enablePanDownToClose=true] - Enable drag to close
 * @property {boolean} [showHandle=true] - Show drag handle
 */

/**
 * iOS-style bottom sheet with drag-to-dismiss
 *
 * @param {BottomSheetProps} props
 */
export function BottomSheet({
  visible,
  onClose,
  children,
  snapPoints = ['50%'],
  enablePanDownToClose = true,
  showHandle = true,
}) {
  const translateY = useRef(new Animated.Value(SCREEN_HEIGHT)).current;
  const overlayOpacity = useRef(new Animated.Value(0)).current;

  // Parse snap point percentage to pixels
  const parseSnapPoint = (point) => {
    const percentage = parseInt(point.replace('%', ''), 10);
    return SCREEN_HEIGHT * (1 - percentage / 100);
  };

  const sheetHeight = SCREEN_HEIGHT - parseSnapPoint(snapPoints[0]);

  useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.spring(translateY, {
          toValue: parseSnapPoint(snapPoints[0]),
          friction: 8,
          tension: 65,
          useNativeDriver: true,
        }),
        Animated.timing(overlayOpacity, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      Animated.parallel([
        Animated.timing(translateY, {
          toValue: SCREEN_HEIGHT,
          duration: 250,
          useNativeDriver: true,
        }),
        Animated.timing(overlayOpacity, {
          toValue: 0,
          duration: 200,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [visible, translateY, overlayOpacity, snapPoints]);

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => enablePanDownToClose,
      onMoveShouldSetPanResponder: (_, gestureState) =>
        enablePanDownToClose && gestureState.dy > 5,
      onPanResponderMove: (_, gestureState) => {
        if (gestureState.dy > 0) {
          translateY.setValue(parseSnapPoint(snapPoints[0]) + gestureState.dy);
        }
      },
      onPanResponderRelease: (_, gestureState) => {
        if (gestureState.dy > 100 || gestureState.vy > 0.5) {
          onClose();
        } else {
          Animated.spring(translateY, {
            toValue: parseSnapPoint(snapPoints[0]),
            friction: 8,
            tension: 65,
            useNativeDriver: true,
          }).start();
        }
      },
    })
  ).current;

  return (
    <Modal visible={visible} transparent animationType="none" onRequestClose={onClose}>
      {/* Backdrop */}
      <TouchableWithoutFeedback onPress={onClose}>
        <Animated.View style={[styles.overlay, { opacity: overlayOpacity }]} />
      </TouchableWithoutFeedback>

      {/* Sheet */}
      <Animated.View
        style={[
          styles.sheet,
          {
            height: sheetHeight + 100, // Extra for overscroll
            transform: [{ translateY }],
          },
        ]}
        {...panResponder.panHandlers}
      >
        {/* Handle */}
        {showHandle && (
          <View style={styles.handleContainer}>
            <View style={styles.handle} />
          </View>
        )}

        {/* Content */}
        <View style={styles.content}>{children}</View>
      </Animated.View>
    </Modal>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: COLORS.overlay,
  },
  sheet: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: COLORS.glass.surface,
    borderTopLeftRadius: RADIUS['2xl'],
    borderTopRightRadius: RADIUS['2xl'],
    borderTopWidth: 1,
    borderLeftWidth: 1,
    borderRightWidth: 1,
    borderColor: COLORS.glass.border,
  },
  handleContainer: {
    alignItems: 'center',
    paddingVertical: SPACING[3],
  },
  handle: {
    width: 36,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: COLORS.handle,
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING[4],
  },
});

export default BottomSheet;
