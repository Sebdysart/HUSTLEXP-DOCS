/**
 * Mock AI Outputs Data
 * SPEC: ARCHITECTURE.md §13 (AI Authority Hierarchy)
 * SPEC: PRODUCT_SPEC.md §8 (AI Task Completion), §9 (Task Discovery)
 *
 * AI outputs include:
 * - Task completion confidence scores
 * - Matching scores for feed
 * - Content moderation flags
 * - AI-generated explanations
 */

// AI Authority Levels (from ARCHITECTURE.md)
export const AIAuthority = {
  A0: 'OBSERVATIONAL',     // Read-only, no influence
  A1: 'ADVISORY',          // Suggestions, user decides
  A2: 'GATED_AUTOMATION',  // Auto-act with human override
  A3: 'DELEGATED',         // Auto-act, audit only
  A4: 'CONSTITUTIONAL',    // Reserved for invariants
};

// Task AI Completion States (from PRODUCT_SPEC.md §8.2)
export const TaskAIState = {
  DRAFT: 'DRAFT',
  INCOMPLETE: 'INCOMPLETE',
  COMPLETE: 'COMPLETE',
  LOCKED: 'LOCKED',
};

// AI Question Types (from PRODUCT_SPEC.md §8.4)
export const AIQuestionType = {
  LOCATION_CLARITY: 'LOCATION_CLARITY',
  TIME_CONSTRAINTS: 'TIME_CONSTRAINTS',
  TASK_SCOPE: 'TASK_SCOPE',
  PROOF_EXPECTATION: 'PROOF_EXPECTATION',
};

// Content Moderation Categories
export const ModerationCategory = {
  SAFE: 'safe',
  PROFANITY: 'profanity',
  HARASSMENT: 'harassment',
  SPAM: 'spam',
  INAPPROPRIATE: 'inappropriate',
  PERSONAL_INFO: 'personal_info',
  PHISHING: 'phishing',
};

/**
 * Mock AI task completion outputs
 * These track the AI-assisted task creation process
 */
export const MOCK_AI_TASK_COMPLETION = {
  // Task that went through AI completion successfully
  'ai-completion-task-open-1': {
    task_id: 'task-open-1',
    ai_state: TaskAIState.LOCKED,
    confidence_score: 0.95,
    questions_asked: [
      {
        type: AIQuestionType.LOCATION_CLARITY,
        question: 'Is the delivery address at ground level or will stairs be involved?',
        answer: 'Second floor, elevator available',
        confidence_before: 0.72,
        confidence_after: 0.88,
      },
      {
        type: AIQuestionType.PROOF_EXPECTATION,
        question: 'What photo proof would confirm task completion?',
        answer: 'Photo of couch in final location',
        confidence_before: 0.88,
        confidence_after: 0.95,
      },
    ],
    auto_filled_fields: {
      estimated_duration_minutes: 45,
      complexity: 'medium',
      requires_vehicle: false,
    },
    completed_at: '2025-01-15T10:00:00Z',
  },

  // Task currently in INCOMPLETE state (needs more info)
  'ai-completion-draft-example': {
    task_id: 'task-draft-example',
    ai_state: TaskAIState.INCOMPLETE,
    confidence_score: 0.62,
    missing_fields: ['proof_instructions', 'deadline'],
    pending_question: {
      type: AIQuestionType.TIME_CONSTRAINTS,
      question: 'When do you need this task completed by?',
      options: ['Within 2 hours', 'Today', 'Within 3 days', 'Flexible'],
    },
    auto_filled_fields: {
      estimated_duration_minutes: 30,
      complexity: 'low',
    },
    updated_at: '2025-01-15T14:00:00Z',
  },
};

/**
 * Mock AI matching scores for feed
 * Each task-user pair has a computed matching score
 */
export const MOCK_AI_MATCHING_SCORES = {
  // High match - elite user with moving task
  'match-elite-task-open-1': {
    task_id: 'task-open-1',
    user_id: 'user-hustler-elite',
    matching_score: 0.87,
    relevance_score: 0.91,
    score_breakdown: {
      trust_multiplier: 0.30 * 1.0,      // 0.30 (max trust tier)
      distance_score: 0.25 * 0.85,       // 0.21 (2.3 miles away)
      category_match: 0.20 * 0.90,       // 0.18 (has moving experience)
      price_attractiveness: 0.15 * 0.80, // 0.12 (good $/hr)
      time_match: 0.10 * 0.70,           // 0.07 (available time)
    },
    explanation: [
      'High trust tier qualifies you for this task',
      'Located 2.3 miles from your current location',
      'Based on your moving task history',
    ],
    computed_at: '2025-01-15T14:30:00Z',
  },

  // Medium match - active user with grocery task
  'match-active-task-open-2': {
    task_id: 'task-open-2',
    user_id: 'user-hustler-active',
    matching_score: 0.58,
    relevance_score: 0.62,
    score_breakdown: {
      trust_multiplier: 0.30 * 0.66,     // 0.20 (tier 2)
      distance_score: 0.25 * 0.60,       // 0.15 (4.1 miles)
      category_match: 0.20 * 0.50,       // 0.10 (limited errand history)
      price_attractiveness: 0.15 * 0.60, // 0.09 (moderate $/hr)
      time_match: 0.10 * 0.40,           // 0.04 (tight deadline)
    },
    explanation: [
      'Errands category is new for you',
      'Requires vehicle (matches your profile)',
      'Moderate distance at 4.1 miles',
    ],
    computed_at: '2025-01-15T14:30:00Z',
  },

  // Low match - hidden from feed (below 0.20 threshold)
  'match-new-task-open-3': {
    task_id: 'task-open-3',
    user_id: 'user-hustler-new',
    matching_score: 0.18,
    relevance_score: 0.15,
    score_breakdown: {
      trust_multiplier: 0.30 * 0.33,     // 0.10 (tier 1)
      distance_score: 0.25 * 0.20,       // 0.05 (8.2 miles)
      category_match: 0.20 * 0.10,       // 0.02 (no assembly history)
      price_attractiveness: 0.15 * 0.05, // 0.01 (low perceived value)
      time_match: 0.10 * 0.00,           // 0.00 (conflict)
    },
    hidden_from_feed: true,
    hidden_reason: 'matching_score_below_threshold',
    computed_at: '2025-01-15T14:30:00Z',
  },
};

/**
 * Mock content moderation outputs
 */
export const MOCK_AI_MODERATION = {
  // Safe content example
  'moderation-message-safe': {
    content_id: 'msg-123',
    content_type: 'message',
    category: ModerationCategory.SAFE,
    confidence: 0.98,
    action: 'approve',
    scanned_at: '2025-01-15T12:00:00Z',
  },

  // Flagged content example (medium confidence)
  'moderation-task-flagged': {
    content_id: 'task-flagged-example',
    content_type: 'task_description',
    category: ModerationCategory.PERSONAL_INFO,
    confidence: 0.75,
    action: 'flag_for_review',
    flagged_text: 'Call me at 555-123-4567',
    suggested_redaction: 'Call me at [PHONE REDACTED]',
    scanned_at: '2025-01-15T11:30:00Z',
  },

  // Auto-blocked content example (high confidence)
  'moderation-message-blocked': {
    content_id: 'msg-blocked-example',
    content_type: 'message',
    category: ModerationCategory.HARASSMENT,
    confidence: 0.94,
    action: 'block',
    flagged_text: '[blocked content]',
    scanned_at: '2025-01-15T11:00:00Z',
  },
};

/**
 * Mock AI fraud detection scores
 */
export const MOCK_AI_FRAUD_SCORES = {
  // Low risk user
  'fraud-user-elite': {
    user_id: 'user-hustler-elite',
    risk_score: 0.05,
    risk_label: 'LOW',
    factors: {
      account_age_days: 220,
      verified_identity: true,
      completed_tasks: 150,
      dispute_rate: 0.01,
      chargeback_history: false,
    },
    computed_at: '2025-01-15T00:00:00Z',
  },

  // Medium risk user (new account)
  'fraud-user-new': {
    user_id: 'user-hustler-new',
    risk_score: 0.35,
    risk_label: 'MEDIUM',
    factors: {
      account_age_days: 1,
      verified_identity: false,
      completed_tasks: 0,
      dispute_rate: null,
      new_account_flag: true,
    },
    computed_at: '2025-01-15T10:00:00Z',
  },

  // Low risk task
  'fraud-task-open-1': {
    task_id: 'task-open-1',
    risk_score: 0.08,
    risk_label: 'LOW',
    factors: {
      poster_risk_score: 0.10,
      price_anomaly: false,
      location_verified: true,
      description_quality: 0.85,
    },
    computed_at: '2025-01-15T10:00:00Z',
  },
};

// === Helper Functions ===

/**
 * Get AI completion status for a task
 * @param {string} taskId
 * @returns {Object|null}
 */
export const getAICompletionForTask = (taskId) => {
  return Object.values(MOCK_AI_TASK_COMPLETION).find(c => c.task_id === taskId) || null;
};

/**
 * Get matching score for a task-user pair
 * @param {string} taskId
 * @param {string} userId
 * @returns {Object|null}
 */
export const getMatchingScore = (taskId, userId) => {
  return Object.values(MOCK_AI_MATCHING_SCORES).find(
    m => m.task_id === taskId && m.user_id === userId
  ) || null;
};

/**
 * Get all matching scores for a user (for feed)
 * @param {string} userId
 * @returns {Object[]}
 */
export const getMatchingScoresForUser = (userId) => {
  return Object.values(MOCK_AI_MATCHING_SCORES)
    .filter(m => m.user_id === userId && !m.hidden_from_feed)
    .sort((a, b) => b.relevance_score - a.relevance_score);
};

/**
 * Get moderation result for content
 * @param {string} contentId
 * @returns {Object|null}
 */
export const getModerationResult = (contentId) => {
  return Object.values(MOCK_AI_MODERATION).find(m => m.content_id === contentId) || null;
};

/**
 * Get fraud score for user
 * @param {string} userId
 * @returns {Object|null}
 */
export const getFraudScoreForUser = (userId) => {
  return Object.values(MOCK_AI_FRAUD_SCORES).find(f => f.user_id === userId) || null;
};

/**
 * Get fraud score for task
 * @param {string} taskId
 * @returns {Object|null}
 */
export const getFraudScoreForTask = (taskId) => {
  return Object.values(MOCK_AI_FRAUD_SCORES).find(f => f.task_id === taskId) || null;
};

/**
 * Check if content passes moderation
 * @param {string} contentId
 * @returns {boolean}
 */
export const isContentApproved = (contentId) => {
  const result = getModerationResult(contentId);
  return result?.action === 'approve';
};

export default {
  MOCK_AI_TASK_COMPLETION,
  MOCK_AI_MATCHING_SCORES,
  MOCK_AI_MODERATION,
  MOCK_AI_FRAUD_SCORES,
  AIAuthority,
  TaskAIState,
  AIQuestionType,
  ModerationCategory,
};
