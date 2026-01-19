/**
 * API Client Tests
 * 
 * Tests for backend integration helpers
 */

import apiClient from '../apiClient';

// Mock fetch
global.fetch = jest.fn();

describe('APIClient', () => {
  beforeEach(() => {
    fetch.mockClear();
    apiClient.setAuthToken(null);
  });

  describe('shouldShowFirstXPCelebration', () => {
    it('should return true when celebration should be shown', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          shouldShow: true,
          xpFirstCelebrationShownAt: null,
        }),
      });

      const result = await apiClient.shouldShowFirstXPCelebration('user123');
      expect(result).toBe(true);
    });

    it('should return false when celebration already shown', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          shouldShow: false,
          xpFirstCelebrationShownAt: '2025-01-01T00:00:00Z',
        }),
      });

      const result = await apiClient.shouldShowFirstXPCelebration('user123');
      expect(result).toBe(false);
    });

    it('should default to true on error', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      const result = await apiClient.shouldShowFirstXPCelebration('user123');
      expect(result).toBe(true);
    });
  });

  describe('markFirstXPCelebrationShown', () => {
    it('should mark celebration as shown', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({}),
      });

      await apiClient.markFirstXPCelebrationShown('user123');
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/users/user123/xp-celebration-shown'),
        expect.objectContaining({
          method: 'POST',
        })
      );
    });

    it('should not throw on error', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      await expect(apiClient.markFirstXPCelebrationShown('user123')).resolves.not.toThrow();
    });
  });

  describe('getTaskState', () => {
    it('should fetch task state from server', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ state: 'COMPLETED' }),
      });

      const state = await apiClient.getTaskState('task123');
      expect(state).toBe('COMPLETED');
    });
  });

  describe('getEscrowState', () => {
    it('should fetch escrow state from server', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ state: 'RELEASED' }),
      });

      const state = await apiClient.getEscrowState('escrow123');
      expect(state).toBe('RELEASED');
    });
  });

  describe('reportViolation', () => {
    it('should report violation to backend', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({}),
      });

      const violation = {
        type: 'COLOR',
        rule: 'xp_color_outside_context',
        component: 'HomeScreen',
        context: {},
      };

      await apiClient.reportViolation(violation);
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/ui/violations'),
        expect.objectContaining({
          method: 'POST',
        })
      );
    });

    it('should not throw on error', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      await expect(apiClient.reportViolation({})).resolves.not.toThrow();
    });
  });

  describe('getUserOnboardingStatus', () => {
    it('should fetch onboarding status', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          onboardingComplete: true,
          role: 'worker',
          xpFirstCelebrationShownAt: '2025-01-01T00:00:00Z',
        }),
      });

      const status = await apiClient.getUserOnboardingStatus('user123');
      expect(status.isOnboarded).toBe(true);
      expect(status.role).toBe('worker');
      expect(status.hasCompletedFirstTask).toBe(true);
    });
  });
});
