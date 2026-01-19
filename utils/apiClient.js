/**
 * API Client - Backend Integration for UI_SPEC Compliance
 * 
 * Provides helpers for:
 * - Server-tracked animations (xp_first_celebration_shown_at)
 * - State confirmation (server-authoritative state)
 * - Violation reporting
 * 
 * SPEC: UI_SPEC.md §8.2, §9.1, ONBOARDING_SPEC.md §13.4
 */

// ============================================================================
// Configuration
// ============================================================================

const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'https://hustlexp-ai-backend-production.up.railway.app';

// ============================================================================
// API Client
// ============================================================================

class APIClient {
  constructor(baseURL = API_BASE_URL) {
    this.baseURL = baseURL;
    this.authToken = null;
  }

  setAuthToken(token) {
    this.authToken = token;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.authToken) {
      headers.Authorization = `Bearer ${this.authToken}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      if (!response.ok) {
        const error = await response.json().catch(() => ({ message: 'Unknown error' }));
        throw new Error(error.message || `HTTP ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`[APIClient] Request failed: ${endpoint}`, error);
      throw error;
    }
  }

  // ============================================================================
  // Animation Tracking (ONBOARDING_SPEC §13.4)
  // ============================================================================

  /**
   * Check if first XP celebration should be shown
   * @param {string} userId - User ID
   * @returns {Promise<boolean>} - True if celebration should be shown
   */
  async shouldShowFirstXPCelebration(userId) {
    try {
      const response = await this.request(`/api/users/${userId}/xp-celebration-status`);
      return response.shouldShow === true && response.xpFirstCelebrationShownAt === null;
    } catch (error) {
      console.warn('[APIClient] Failed to check celebration status, defaulting to show', error);
      return true; // Default to showing if check fails
    }
  }

  /**
   * Mark first XP celebration as shown
   * @param {string} userId - User ID
   * @returns {Promise<void>}
   */
  async markFirstXPCelebrationShown(userId) {
    try {
      await this.request(`/api/users/${userId}/xp-celebration-shown`, {
        method: 'POST',
        body: JSON.stringify({ timestamp: new Date().toISOString() }),
      });
    } catch (error) {
      console.error('[APIClient] Failed to mark celebration as shown', error);
      // Don't throw - this is not critical for UX
    }
  }

  /**
   * Check if badge animation should be shown
   * @param {string} userId - User ID
   * @param {string} badgeId - Badge ID
   * @returns {Promise<boolean>} - True if animation should be shown
   */
  async shouldShowBadgeAnimation(userId, badgeId) {
    try {
      const response = await this.request(`/api/users/${userId}/badges/${badgeId}/animation-status`);
      return response.shouldShow === true && response.animationShownAt === null;
    } catch (error) {
      console.warn('[APIClient] Failed to check badge animation status', error);
      return true; // Default to showing if check fails
    }
  }

  /**
   * Mark badge animation as shown
   * @param {string} userId - User ID
   * @param {string} badgeId - Badge ID
   * @returns {Promise<void>}
   */
  async markBadgeAnimationShown(userId, badgeId) {
    try {
      await this.request(`/api/users/${userId}/badges/${badgeId}/animation-shown`, {
        method: 'POST',
        body: JSON.stringify({ timestamp: new Date().toISOString() }),
      });
    } catch (error) {
      console.error('[APIClient] Failed to mark badge animation as shown', error);
    }
  }

  // ============================================================================
  // State Confirmation (UI_SPEC §9.1)
  // ============================================================================

  /**
   * Get server-authoritative task state
   * @param {string} taskId - Task ID
   * @returns {Promise<object>} - Task state from server
   */
  async getTaskState(taskId) {
    try {
      const response = await this.request(`/api/tasks/${taskId}/state`);
      return response.state;
    } catch (error) {
      console.error('[APIClient] Failed to get task state', error);
      throw error;
    }
  }

  /**
   * Get server-authoritative escrow state
   * @param {string} escrowId - Escrow ID
   * @returns {Promise<object>} - Escrow state from server
   */
  async getEscrowState(escrowId) {
    try {
      const response = await this.request(`/api/escrows/${escrowId}/state`);
      return response.state;
    } catch (error) {
      console.error('[APIClient] Failed to get escrow state', error);
      throw error;
    }
  }

  // ============================================================================
  // Violation Reporting (UI_SPEC §8.4)
  // ============================================================================

  /**
   * Report UI_SPEC violation to backend
   * @param {object} violation - Violation object
   * @returns {Promise<void>}
   */
  async reportViolation(violation) {
    try {
      await this.request('/api/ui/violations', {
        method: 'POST',
        body: JSON.stringify({
          ...violation,
          timestamp: new Date().toISOString(),
          userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : 'React Native',
        }),
      });
    } catch (error) {
      // Don't throw - violation reporting should not break UX
      console.warn('[APIClient] Failed to report violation', error);
    }
  }

  // ============================================================================
  // User State (for gamification checks)
  // ============================================================================

  /**
   * Get user onboarding status
   * @param {string} userId - User ID
   * @returns {Promise<object>} - User onboarding data
   */
  async getUserOnboardingStatus(userId) {
    try {
      const response = await this.request(`/api/users/${userId}/onboarding-status`);
      return {
        isOnboarded: response.onboardingComplete === true,
        role: response.role,
        xpFirstCelebrationShownAt: response.xpFirstCelebrationShownAt,
        hasCompletedFirstTask: response.xpFirstCelebrationShownAt !== null,
      };
    } catch (error) {
      console.error('[APIClient] Failed to get onboarding status', error);
      throw error;
    }
  }
}

// ============================================================================
// Singleton Instance
// ============================================================================

export const apiClient = new APIClient();

export default apiClient;
