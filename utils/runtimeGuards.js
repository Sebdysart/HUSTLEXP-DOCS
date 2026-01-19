/**
 * Runtime Guards - UI_SPEC Enforcement (UI_SPEC §8.2)
 * 
 * These guards enforce constitutional UI rules at runtime:
 * - Animation constraints
 * - Color authority
 * - State confirmation
 * - Reduced motion
 * - First-time animation tracking
 * 
 * SPEC: UI_SPEC.md §8.2
 */

import { DURATION, FORBIDDEN_PATTERNS, MAX_QUEUED_ANIMATIONS } from '../constants/animations';

// ============================================================================
// Animation Guards
// ============================================================================

/**
 * AnimationDurationGuard - Enforces maximum animation duration (UI_SPEC §3.3)
 */
export class AnimationDurationGuard {
  static validate(duration, type) {
    const maxDuration = DURATION[type];
    if (maxDuration === null) return true; // Loading animations are indefinite
    
    if (duration > maxDuration) {
      console.warn(`[UI_SPEC Violation] Animation duration ${duration}ms exceeds maximum ${maxDuration}ms for type ${type}`);
      return false;
    }
    return true;
  }
}

/**
 * ReducedMotionGuard - Respects prefers-reduced-motion (UI_SPEC §3.6)
 */
export class ReducedMotionGuard {
  static _reducedMotionEnabled = null;

  static async init() {
    try {
      const { AccessibilityInfo } = require('react-native');
      const isReduceMotionEnabled = await AccessibilityInfo.isReduceMotionEnabled();
      this._reducedMotionEnabled = isReduceMotionEnabled;
      
      // Listen for changes
      AccessibilityInfo.addEventListener('reduceMotionChanged', (isReduceMotionEnabled) => {
        this._reducedMotionEnabled = isReduceMotionEnabled;
      });
    } catch (error) {
      console.warn('[ReducedMotionGuard] AccessibilityInfo not available, defaulting to motion enabled');
      this._reducedMotionEnabled = false;
    }
  }

  static shouldReduceMotion() {
    // If not initialized, return false (assume motion is allowed until checked)
    if (this._reducedMotionEnabled === null) {
      this.init(); // Initialize async
      return false;
    }
    return this._reducedMotionEnabled;
  }

  static applyReducedMotion(animationConfig) {
    if (this.shouldReduceMotion()) {
      return {
        ...animationConfig,
        duration: 0, // Instant
        useNativeDriver: false,
      };
    }
    return animationConfig;
  }
}

/**
 * FirstTimeAnimationGuard - Tracks first-time animations (UI_SPEC §3.5)
 */
export class FirstTimeAnimationGuard {
  static apiClient = null;

  static setAPIClient(client) {
    this.apiClient = client;
  }

  static async shouldShowAnimation(animationType, userId) {
    if (!this.apiClient || !userId) {
      console.warn('[FirstTimeAnimationGuard] API client or userId not set');
      return true; // Default to showing if not configured
    }

    try {
      switch (animationType) {
        case 'first_xp_celebration':
          return await this.apiClient.shouldShowFirstXPCelebration(userId);
        case 'badge_unlock':
          // Requires badgeId, handled by component
          return true;
        default:
          return true;
      }
    } catch (error) {
      console.warn(`[FirstTimeAnimationGuard] Failed to check ${animationType}`, error);
      return true; // Default to showing if check fails
    }
  }

  static async markAnimationShown(animationType, userId, badgeId = null) {
    if (!this.apiClient || !userId) {
      console.warn('[FirstTimeAnimationGuard] API client or userId not set');
      return;
    }

    try {
      switch (animationType) {
        case 'first_xp_celebration':
          await this.apiClient.markFirstXPCelebrationShown(userId);
          break;
        case 'badge_unlock':
          if (badgeId) {
            await this.apiClient.markBadgeAnimationShown(userId, badgeId);
          }
          break;
        default:
          console.warn(`[FirstTimeAnimationGuard] Unknown animation type: ${animationType}`);
      }
    } catch (error) {
      console.error(`[FirstTimeAnimationGuard] Failed to mark ${animationType} as shown`, error);
    }
  }
}

/**
 * AnimationContextGuard - Blocks animations in inappropriate contexts (UI_SPEC §3.5)
 */
export class AnimationContextGuard {
  static canAnimate(context) {
    const { screen, hasActiveDispute, isOnboarding } = context;

    // No celebration during dispute
    if (hasActiveDispute) {
      console.warn('[UI_SPEC Violation] Cannot animate celebration during active dispute');
      return false;
    }

    // No celebration during onboarding
    if (isOnboarding) {
      console.warn('[UI_SPEC Violation] Cannot animate celebration during onboarding');
      return false;
    }

    // No celebration during pending payments
    if (context.hasPendingPayment) {
      console.warn('[UI_SPEC Violation] Cannot animate celebration during pending payment');
      return false;
    }

    return true;
  }
}

/**
 * ForbiddenAnimationGuard - Blocks forbidden animation patterns (UI_SPEC §3.2)
 */
export class ForbiddenAnimationGuard {
  static isForbidden(pattern) {
    return Object.values(FORBIDDEN_PATTERNS).includes(pattern);
  }

  static validate(pattern) {
    if (this.isForbidden(pattern)) {
      console.error(`[UI_SPEC Violation] Forbidden animation pattern: ${pattern}`);
      return false;
    }
    return true;
  }
}

// ============================================================================
// Color Guards
// ============================================================================

/**
 * ColorContextGuard - Validates color usage context (UI_SPEC §2, §6.1)
 */
export class ColorContextGuard {
  static validateXPColor(context) {
    const allowedContexts = [
      'xp_display',
      'level_indicator',
      'streak_counter',
      'progression_bar',
      'level_up_celebration',
    ];

    if (!allowedContexts.includes(context)) {
      console.warn(`[UI_SPEC Violation] XP color used in forbidden context: ${context}`);
      return false;
    }
    return true;
  }

  static validateMoneyColor(context) {
    const allowedContexts = [
      'escrow_state',
      'payment_amount',
      'wallet_balance',
      'transaction_history',
    ];

    if (!allowedContexts.includes(context)) {
      console.warn(`[UI_SPEC Violation] Money color used in forbidden context: ${context}`);
      return false;
    }
    return true;
  }

  static validateStatusColor(context) {
    const allowedContexts = [
      'success_confirmation',
      'warning_caution',
      'error_failure',
      'info_message',
    ];

    if (!allowedContexts.includes(context)) {
      console.warn(`[UI_SPEC Violation] Status color used in forbidden context: ${context}`);
      return false;
    }
    return true;
  }
}

// ============================================================================
// State Guards
// ============================================================================

/**
 * StateConfirmationGuard - Ensures UI only displays server-confirmed state (UI_SPEC §9.1)
 */
export class StateConfirmationGuard {
  static apiClient = null;

  static setAPIClient(client) {
    this.apiClient = client;
  }

  static canDisplayState(state, serverState) {
    if (state !== serverState) {
      console.error(`[UI_SPEC Violation] Displaying unconfirmed state: ${state} (server: ${serverState})`);
      ViolationTracker.log('STATE', 'unconfirmed_state', 'StateConfirmationGuard', {
        localState: state,
        serverState,
      });
      return false;
    }
    return true;
  }

  static blockOptimisticUpdate(state, serverState) {
    // Block optimistic updates that don't match server
    return this.canDisplayState(state, serverState);
  }

  static async getServerState(entityType, entityId) {
    if (!this.apiClient) {
      console.warn('[StateConfirmationGuard] API client not set');
      return null;
    }

    try {
      switch (entityType) {
        case 'task':
          return await this.apiClient.getTaskState(entityId);
        case 'escrow':
          return await this.apiClient.getEscrowState(entityId);
        default:
          console.warn(`[StateConfirmationGuard] Unknown entity type: ${entityType}`);
          return null;
      }
    } catch (error) {
      console.error(`[StateConfirmationGuard] Failed to get server state for ${entityType}`, error);
      return null;
    }
  }
}

// ============================================================================
// Screen Context Guards
// ============================================================================

/**
 * ScreenContextGuard - Enforces screen-specific rules (UI_SPEC §6)
 */
export class ScreenContextGuard {
  static canShowXPColors(screen) {
    const allowedScreens = ['home', 'dashboard', 'profile'];
    if (!allowedScreens.includes(screen)) {
      console.warn(`[UI_SPEC Violation] XP colors forbidden on screen: ${screen}`);
      return false;
    }
    return true;
  }

  static canShowMoneyColors(screen) {
    const allowedScreens = ['home', 'dashboard', 'task_detail', 'wallet', 'profile', 'dispute'];
    if (!allowedScreens.includes(screen)) {
      console.warn(`[UI_SPEC Violation] Money colors forbidden on screen: ${screen}`);
      return false;
    }
    return true;
  }

  static canShowCelebration(screen, context) {
    // No celebration on task feed
    if (screen === 'task_feed') {
      return false;
    }

    // No celebration on task detail (unless just completed)
    if (screen === 'task_detail' && !context.justCompleted) {
      return false;
    }

    // No celebration on dispute screen
    if (screen === 'dispute') {
      return false;
    }

    // No celebration during onboarding
    if (screen === 'onboarding') {
      return false;
    }

    return true;
  }
}

// ============================================================================
// Violation Tracking
// ============================================================================

/**
 * ViolationTracker - Logs UI_SPEC violations (UI_SPEC §8.4)
 */
export class ViolationTracker {
  static violations = [];
  static apiClient = null;

  static setAPIClient(client) {
    this.apiClient = client;
  }

  static log(type, rule, component, context) {
    const violation = {
      type, // 'COLOR' | 'ANIMATION' | 'COPY' | 'ACCESSIBILITY' | 'STATE'
      rule,
      component,
      context,
      timestamp: new Date(),
      severity: this.getSeverity(type),
    };

    this.violations.push(violation);

    // In development, log to console
    if (__DEV__) {
      console.warn('[UI_SPEC Violation]', violation);
    }

    // In production, send to monitoring
    if (this.apiClient && !__DEV__) {
      this.apiClient.reportViolation(violation).catch(() => {
        // Silently fail - violation reporting should not break UX
      });
    }
  }

  static getSeverity(type) {
    const severityMap = {
      COLOR: 'ERROR',
      ANIMATION: 'ERROR',
      COPY: 'ERROR',
      ACCESSIBILITY: 'ERROR',
    };
    return severityMap[type] || 'WARNING';
  }

  static getViolations() {
    return this.violations;
  }

  static clear() {
    this.violations = [];
  }
}

export default {
  AnimationDurationGuard,
  ReducedMotionGuard,
  FirstTimeAnimationGuard,
  AnimationContextGuard,
  ForbiddenAnimationGuard,
  ColorContextGuard,
  StateConfirmationGuard,
  ScreenContextGuard,
  ViolationTracker,
};
