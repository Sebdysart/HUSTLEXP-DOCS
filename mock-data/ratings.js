/**
 * Mock Rating Data
 * SPEC: MOCK_DATA_SPEC.md, PRODUCT_SPEC.md §12
 * SCHEMA: schema.sql ratings table
 *
 * Ratings are bidirectional: both poster and worker rate each other
 * after task completion.
 */

export const RatingTags = {
  // Positive tags
  ON_TIME: 'on_time',
  PROFESSIONAL: 'professional',
  HIGH_QUALITY: 'high_quality',
  GREAT_COMMUNICATION: 'great_communication',
  FRIENDLY: 'friendly',
  WENT_ABOVE_BEYOND: 'went_above_beyond',

  // Constructive tags (for workers rating posters)
  CLEAR_INSTRUCTIONS: 'clear_instructions',
  RESPONSIVE: 'responsive',
  FAIR_PRICE: 'fair_price',

  // Constructive tags (for posters rating workers)
  FAST_COMPLETION: 'fast_completion',
  CAREFUL_WORK: 'careful_work',
  GOOD_UPDATES: 'good_updates',
};

export const MOCK_RATINGS = {
  // Rating from poster to worker for completed task
  'rating-completed-poster-to-worker': {
    id: 'rating-completed-poster-to-worker',
    task_id: 'task-completed',
    rater_id: 'user-poster-active',      // Poster rates worker
    ratee_id: 'user-hustler-active',     // Worker being rated
    stars: 5,
    comment: 'Quick delivery, package was handled carefully. Would definitely use again!',
    tags: [RatingTags.ON_TIME, RatingTags.PROFESSIONAL, RatingTags.GREAT_COMMUNICATION],
    created_at: '2025-01-14T11:00:00Z',
  },

  // Rating from worker to poster for completed task
  'rating-completed-worker-to-poster': {
    id: 'rating-completed-worker-to-poster',
    task_id: 'task-completed',
    rater_id: 'user-hustler-active',     // Worker rates poster
    ratee_id: 'user-poster-active',      // Poster being rated
    stars: 5,
    comment: 'Clear instructions, easy to find the location. Great experience.',
    tags: [RatingTags.CLEAR_INSTRUCTIONS, RatingTags.RESPONSIVE, RatingTags.FAIR_PRICE],
    created_at: '2025-01-14T11:15:00Z',
  },

  // Historical rating - elite worker rated by poster
  'rating-historical-1': {
    id: 'rating-historical-1',
    task_id: 'task-historical-1',
    rater_id: 'user-poster-active',
    ratee_id: 'user-hustler-elite',
    stars: 5,
    comment: 'Incredible work! Assembled the furniture perfectly and cleaned up after.',
    tags: [RatingTags.HIGH_QUALITY, RatingTags.WENT_ABOVE_BEYOND, RatingTags.PROFESSIONAL],
    created_at: '2025-01-10T15:00:00Z',
  },

  // Historical rating - elite worker rates poster
  'rating-historical-2': {
    id: 'rating-historical-2',
    task_id: 'task-historical-1',
    rater_id: 'user-hustler-elite',
    ratee_id: 'user-poster-active',
    stars: 5,
    comment: 'Perfect task description, all materials were ready.',
    tags: [RatingTags.CLEAR_INSTRUCTIONS, RatingTags.RESPONSIVE],
    created_at: '2025-01-10T15:30:00Z',
  },

  // 4-star rating example
  'rating-historical-3': {
    id: 'rating-historical-3',
    task_id: 'task-historical-2',
    rater_id: 'user-poster-new',
    ratee_id: 'user-hustler-active',
    stars: 4,
    comment: 'Good job overall, took a bit longer than expected but quality was great.',
    tags: [RatingTags.HIGH_QUALITY, RatingTags.FRIENDLY],
    created_at: '2025-01-08T12:00:00Z',
  },

  // 3-star rating example
  'rating-historical-4': {
    id: 'rating-historical-4',
    task_id: 'task-historical-3',
    rater_id: 'user-poster-active',
    ratee_id: 'user-hustler-active',
    stars: 3,
    comment: 'Task was completed but communication could have been better.',
    tags: [],
    created_at: '2025-01-05T18:00:00Z',
  },

  // Worker rating poster (3 stars - poster was slow to respond)
  'rating-historical-5': {
    id: 'rating-historical-5',
    task_id: 'task-historical-3',
    rater_id: 'user-hustler-active',
    ratee_id: 'user-poster-active',
    stars: 3,
    comment: 'Task was okay but had to wait a while for proof approval.',
    tags: [],
    created_at: '2025-01-05T18:30:00Z',
  },
};

/**
 * Get a rating by ID
 * @param {string} ratingId
 * @returns {Object|null}
 */
export const getRating = (ratingId) => MOCK_RATINGS[ratingId] || null;

/**
 * Get all ratings for a task
 * @param {string} taskId
 * @returns {Object[]}
 */
export const getRatingsForTask = (taskId) => {
  return Object.values(MOCK_RATINGS).filter(r => r.task_id === taskId);
};

/**
 * Get ratings given by a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getRatingsGivenByUser = (userId) => {
  return Object.values(MOCK_RATINGS).filter(r => r.rater_id === userId);
};

/**
 * Get ratings received by a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getRatingsReceivedByUser = (userId) => {
  return Object.values(MOCK_RATINGS).filter(r => r.ratee_id === userId);
};

/**
 * Calculate average rating for a user
 * @param {string} userId
 * @returns {Object}
 */
export const getAverageRatingForUser = (userId) => {
  const ratings = getRatingsReceivedByUser(userId);

  if (ratings.length === 0) {
    return {
      average: null,
      count: 0,
      distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
    };
  }

  const sum = ratings.reduce((acc, r) => acc + r.stars, 0);
  const average = sum / ratings.length;

  const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  ratings.forEach(r => {
    distribution[r.stars]++;
  });

  return {
    average: Math.round(average * 10) / 10,
    count: ratings.length,
    distribution,
  };
};

/**
 * Get recent ratings for a user (for profile display)
 * @param {string} userId
 * @param {number} limit
 * @returns {Object[]}
 */
export const getRecentRatingsForUser = (userId, limit = 10) => {
  return getRatingsReceivedByUser(userId)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    .slice(0, limit);
};

/**
 * Get most common tags for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getTopTagsForUser = (userId) => {
  const ratings = getRatingsReceivedByUser(userId);
  const tagCounts = {};

  ratings.forEach(r => {
    (r.tags || []).forEach(tag => {
      tagCounts[tag] = (tagCounts[tag] || 0) + 1;
    });
  });

  return Object.entries(tagCounts)
    .map(([tag, count]) => ({ tag, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5);
};

/**
 * Check if task has pending ratings
 * @param {string} taskId
 * @param {string} raterId
 * @returns {boolean}
 */
export const hasUserRatedTask = (taskId, raterId) => {
  return Object.values(MOCK_RATINGS).some(
    r => r.task_id === taskId && r.rater_id === raterId
  );
};

export default MOCK_RATINGS;
