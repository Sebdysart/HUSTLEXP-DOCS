/**
 * Modal Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §9
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Centered modal overlay with glassmorphism styling.
 */

import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  Modal as RNModal,
  TouchableOpacity,
  TouchableWithoutFeedback,
  StyleSheet,
  Animated,
  Dimensions,
} from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: '#000000',
  glass: {
    surface: 'rgba(28, 28, 30, 0.95)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  text: {
    primary: '#FFFFFF',
    muted: '#8E8E93',
  },
  overlay: 'rgba(0, 0, 0, 0.6)',
};

const SPACING = {
  3: 12,
  4: 16,
  5: 20,
  6: 24,
};

const RADIUS = {
  '2xl': 24,
};

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const SIZE_CONFIG = {
  sm: { width: SCREEN_WIDTH * 0.75, maxWidth: 280 },
  md: { width: SCREEN_WIDTH * 0.85, maxWidth: 340 },
  lg: { width: SCREEN_WIDTH * 0.92, maxWidth: 420 },
};

// ═══════════════════════════════════════════════════════════════════════════
// MODAL COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} ModalProps
 * @property {boolean} visible - Modal visibility
 * @property {() => void} onClose - Close handler
 * @property {string} [title] - Modal title
 * @property {React.ReactNode} children - Modal content
 * @property {'sm'|'md'|'lg'} [size='md'] - Modal size
 * @property {boolean} [showCloseButton=true] - Show close button
 * @property {boolean} [closeOnBackdrop=true] - Close when tapping backdrop
 */

/**
 * Centered modal with glassmorphism styling
 *
 * @param {ModalProps} props
 */
export function Modal({
  visible,
  onClose,
  title,
  children,
  size = 'md',
  showCloseButton = true,
  closeOnBackdrop = true,
}) {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.9)).current;
  const sizeConfig = SIZE_CONFIG[size];

  useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 200,
          useNativeDriver: true,
        }),
        Animated.spring(scaleAnim, {
          toValue: 1,
          friction: 8,
          tension: 100,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      fadeAnim.setValue(0);
      scaleAnim.setValue(0.9);
    }
  }, [visible, fadeAnim, scaleAnim]);

  const handleBackdropPress = () => {
    if (closeOnBackdrop) {
      onClose();
    }
  };

  return (
    <RNModal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={onClose}
    >
      <TouchableWithoutFeedback onPress={handleBackdropPress}>
        <Animated.View style={[styles.overlay, { opacity: fadeAnim }]}>
          <TouchableWithoutFeedback>
            <Animated.View
              style={[
                styles.container,
                {
                  width: sizeConfig.width,
                  maxWidth: sizeConfig.maxWidth,
                  transform: [{ scale: scaleAnim }],
                  opacity: fadeAnim,
                },
              ]}
            >
              {/* Header */}
              {(title || showCloseButton) && (
                <View style={styles.header}>
                  {title && <Text style={styles.title}>{title}</Text>}
                  {showCloseButton && (
                    <TouchableOpacity
                      onPress={onClose}
                      style={styles.closeButton}
                      hitSlop={{ top: 10, right: 10, bottom: 10, left: 10 }}
                    >
                      <Text style={styles.closeIcon}>✕</Text>
                    </TouchableOpacity>
                  )}
                </View>
              )}

              {/* Content */}
              <View style={styles.content}>{children}</View>
            </Animated.View>
          </TouchableWithoutFeedback>
        </Animated.View>
      </TouchableWithoutFeedback>
    </RNModal>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: COLORS.overlay,
    justifyContent: 'center',
    alignItems: 'center',
    padding: SPACING[4],
  },
  container: {
    backgroundColor: COLORS.glass.surface,
    borderRadius: RADIUS['2xl'],
    borderWidth: 1,
    borderColor: COLORS.glass.border,
    overflow: 'hidden',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: SPACING[5],
    paddingTop: SPACING[5],
    paddingBottom: SPACING[3],
  },
  title: {
    color: COLORS.text.primary,
    fontSize: 20,
    fontWeight: '600',
    flex: 1,
  },
  closeButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: SPACING[3],
  },
  closeIcon: {
    color: COLORS.text.muted,
    fontSize: 14,
    fontWeight: '600',
  },
  content: {
    paddingHorizontal: SPACING[5],
    paddingBottom: SPACING[5],
  },
});

export default Modal;
