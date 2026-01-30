/**
 * Mock Data Index
 * SPEC: MOCK_DATA_SPEC.md
 *
 * Central export for all mock data used during WIRING phase.
 * Import from this file for consistent access to mock data.
 */

// Users
export {
  MOCK_USERS,
  getCurrentUser,
  getAllUsers,
  getUsersByMode,
  getUsersByTrustTier,
} from './users.js';

// Tasks
export {
  MOCK_TASKS,
  TaskState,
  TaskMode,
  TASK_CATEGORIES,
  getTask,
  getAllTasks,
  getTasksForFeed,
  getTasksForUser,
  getActiveTasksForWorker,
  getTasksByState,
  formatPrice,
} from './tasks.js';

// Escrows
export {
  MOCK_ESCROWS,
  EscrowState,
  TERMINAL_ESCROW_STATES,
  getEscrow,
  getEscrowForTask,
  getAllEscrows,
  getEscrowsByState,
  isTerminalState,
  formatAmount,
  calculatePlatformFee,
  calculateWorkerPayout,
} from './escrows.js';

// Proofs
export {
  MOCK_PROOFS,
  ProofState,
  getProof,
  getProofForTask,
  getAllProofs,
} from './proofs.js';

// XP Ledger
export {
  MOCK_XP_LEDGER,
  getXPLedgerForUser,
  getTotalXPForUser,
  getRecentXPEntries,
} from './xp-ledger.js';

// Badges
export {
  BADGE_DEFINITIONS,
  MOCK_USER_BADGES,
  getBadgesForUser,
  getAllBadgeDefinitions,
  getUnlockedBadgeIds,
} from './badges.js';

// Messages
export {
  MOCK_MESSAGES,
  getMessagesForTask,
  addMockMessage,
} from './messages.js';

// Notifications
export {
  MOCK_NOTIFICATIONS,
  getNotificationsForUser,
  getUnreadCount,
  markNotificationRead,
} from './notifications.js';

// Ratings
export {
  MOCK_RATINGS,
  RatingTags,
  getRating,
  getRatingsForTask,
  getRatingsGivenByUser,
  getRatingsReceivedByUser,
  getAverageRatingForUser,
  getRecentRatingsForUser,
  getTopTagsForUser,
  hasUserRatedTask,
} from './ratings.js';

// Verifications
export {
  MOCK_VERIFICATIONS,
  MOCK_CAPABILITY_CLAIMS,
  MOCK_CAPABILITY_PROFILES,
  VerificationType,
  VerificationStatus,
  LicensedTrades,
  getVerification,
  getVerificationsForUser,
  getActiveVerificationsForUser,
  getCapabilityProfile,
  getCapabilityClaims,
  hasVerifiedTrade,
  canAccessRiskLevel,
  getPendingVerificationsCount,
  getExpiringVerifications,
} from './verifications.js';

// AI Outputs
export {
  MOCK_AI_TASK_COMPLETION,
  MOCK_AI_MATCHING_SCORES,
  MOCK_AI_MODERATION,
  MOCK_AI_FRAUD_SCORES,
  AIAuthority,
  TaskAIState,
  AIQuestionType,
  ModerationCategory,
  getAICompletionForTask,
  getMatchingScore,
  getMatchingScoresForUser,
  getModerationResult,
  getFraudScoreForUser,
  getFraudScoreForTask,
  isContentApproved,
} from './ai-outputs.js';

/**
 * Mock API delay simulator
 * Use to simulate network latency in development
 * @param {number} ms - Delay in milliseconds
 * @returns {Promise<void>}
 */
export const mockDelay = (ms = 500) => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

/**
 * Mock API response wrapper
 * Wraps mock data in API-like response format
 * @param {any} data - Data to wrap
 * @param {boolean} success - Success status
 * @param {string} error - Error message (if any)
 * @returns {Object}
 */
export const mockResponse = (data, success = true, error = null) => {
  return {
    success,
    data: success ? data : null,
    error: success ? null : error,
    timestamp: new Date().toISOString(),
  };
};
