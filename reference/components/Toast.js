/**
 * Toast Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §14
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Toast notification system with hook-based API.
 */

import React, { createContext, useContext, useState, useCallback, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  glass: {
    surface: 'rgba(28, 28, 30, 0.95)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  text: {
    primary: '#FFFFFF',
  },
  success: '#34C759',
  error: '#FF3B30',
  warning: '#FF9500',
  info: '#007AFF',
};

const SPACING = {
  3: 12,
  4: 16,
};

const RADIUS = {
  lg: 12,
};

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const VARIANT_COLORS = {
  default: { accent: COLORS.text.primary, icon: null },
  success: { accent: COLORS.success, icon: '✓' },
  error: { accent: COLORS.error, icon: '✕' },
  warning: { accent: COLORS.warning, icon: '!' },
  info: { accent: COLORS.info, icon: 'ℹ' },
};

// ═══════════════════════════════════════════════════════════════════════════
// TOAST CONTEXT
// ═══════════════════════════════════════════════════════════════════════════

const ToastContext = createContext(null);

/**
 * @typedef {Object} ToastOptions
 * @property {string} message - Toast message
 * @property {'default'|'success'|'error'|'warning'|'info'} [variant='default']
 * @property {number} [duration=3000] - Auto-dismiss duration (ms)
 * @property {{ label: string, onPress: () => void }} [action] - Action button
 */

/**
 * Toast provider component
 */
export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);
  const toastId = useRef(0);

  const show = useCallback((options) => {
    const id = ++toastId.current;
    const toast = {
      id,
      message: options.message,
      variant: options.variant || 'default',
      duration: options.duration ?? 3000,
      action: options.action,
    };

    setToasts((prev) => [...prev, toast]);

    // Auto-dismiss
    if (toast.duration > 0) {
      setTimeout(() => {
        dismiss(id);
      }, toast.duration);
    }

    return id;
  }, []);

  const dismiss = useCallback((id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const dismissAll = useCallback(() => {
    setToasts([]);
  }, []);

  return (
    <ToastContext.Provider value={{ show, dismiss, dismissAll }}>
      {children}
      <ToastContainer toasts={toasts} onDismiss={dismiss} />
    </ToastContext.Provider>
  );
}

/**
 * Hook to access toast functions
 *
 * @returns {{ show: (options: ToastOptions) => number, dismiss: (id: number) => void, dismissAll: () => void }}
 */
export function useToast() {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
}

// ═══════════════════════════════════════════════════════════════════════════
// TOAST CONTAINER
// ═══════════════════════════════════════════════════════════════════════════

function ToastContainer({ toasts, onDismiss }) {
  // Note: useSafeAreaInsets requires SafeAreaProvider
  // Fallback values provided for reference implementation
  const insets = { top: 59, bottom: 34 };

  return (
    <View style={[styles.container, { top: insets.top + SPACING[4] }]}>
      {toasts.map((toast) => (
        <ToastItem
          key={toast.id}
          toast={toast}
          onDismiss={() => onDismiss(toast.id)}
        />
      ))}
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TOAST ITEM
// ═══════════════════════════════════════════════════════════════════════════

function ToastItem({ toast, onDismiss }) {
  const translateY = useRef(new Animated.Value(-100)).current;
  const opacity = useRef(new Animated.Value(0)).current;
  const variantConfig = VARIANT_COLORS[toast.variant];

  useEffect(() => {
    Animated.parallel([
      Animated.spring(translateY, {
        toValue: 0,
        friction: 8,
        tension: 80,
        useNativeDriver: true,
      }),
      Animated.timing(opacity, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start();
  }, [translateY, opacity]);

  return (
    <Animated.View
      style={[
        styles.toast,
        {
          transform: [{ translateY }],
          opacity,
          borderLeftColor: variantConfig.accent,
        },
      ]}
    >
      {/* Icon */}
      {variantConfig.icon && (
        <View style={[styles.iconContainer, { backgroundColor: variantConfig.accent }]}>
          <Text style={styles.icon}>{variantConfig.icon}</Text>
        </View>
      )}

      {/* Content */}
      <View style={styles.content}>
        <Text style={styles.message} numberOfLines={2}>
          {toast.message}
        </Text>

        {/* Action */}
        {toast.action && (
          <TouchableOpacity
            onPress={() => {
              toast.action.onPress();
              onDismiss();
            }}
            style={styles.actionButton}
          >
            <Text style={[styles.actionText, { color: variantConfig.accent }]}>
              {toast.action.label}
            </Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Dismiss */}
      <TouchableOpacity onPress={onDismiss} style={styles.dismissButton}>
        <Text style={styles.dismissIcon}>✕</Text>
      </TouchableOpacity>
    </Animated.View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    left: SPACING[4],
    right: SPACING[4],
    zIndex: 9999,
  },
  toast: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.glass.surface,
    borderRadius: RADIUS.lg,
    borderWidth: 1,
    borderColor: COLORS.glass.border,
    borderLeftWidth: 4,
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    marginBottom: SPACING[3],
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  iconContainer: {
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING[3],
  },
  icon: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700',
  },
  content: {
    flex: 1,
  },
  message: {
    color: COLORS.text.primary,
    fontSize: 14,
    fontWeight: '500',
    lineHeight: 20,
  },
  actionButton: {
    marginTop: 4,
  },
  actionText: {
    fontSize: 14,
    fontWeight: '600',
  },
  dismissButton: {
    marginLeft: SPACING[3],
    padding: 4,
  },
  dismissIcon: {
    color: '#8E8E93',
    fontSize: 12,
  },
});

export default { ToastProvider, useToast };
