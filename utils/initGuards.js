/**
 * Initialize Runtime Guards
 * 
 * Sets up runtime guards with API client and initializes reduced motion detection
 * 
 * Call this in App.js or index.js before rendering
 */

import { ReducedMotionGuard, FirstTimeAnimationGuard, StateConfirmationGuard, ViolationTracker } from './runtimeGuards';
import apiClient from './apiClient';

/**
 * Initialize all runtime guards
 * @param {string} authToken - Optional auth token for API client
 */
export async function initRuntimeGuards(authToken = null) {
  // Set auth token if provided
  if (authToken) {
    apiClient.setAuthToken(authToken);
  }

  // Initialize reduced motion detection
  await ReducedMotionGuard.init();

  // Connect guards to API client
  FirstTimeAnimationGuard.setAPIClient(apiClient);
  StateConfirmationGuard.setAPIClient(apiClient);
  ViolationTracker.setAPIClient(apiClient);

  console.log('[initGuards] Runtime guards initialized');
}

export default initRuntimeGuards;
