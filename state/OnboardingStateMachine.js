/**
 * OnboardingStateMachine - Role inference + authority priming
 * 
 * SPEC: ONBOARDING_SPEC.md (Full specification)
 * IMPL: BUILD_GUIDE.md §6 (Phase 3: Frontend State)
 * AUTH: ARCHITECTURE.md §7 (AI Containment Model)
 * 
 * VERSION: 1.0.0 (IMMUTABLE - never change weights without new version)
 * 
 * HARDENED FOR:
 * - GAP 1: Confidence threshold tiers
 * - GAP 2: Adversarial/gaming detection
 * - GAP 3: Immutable version lock
 * - GAP 4: Downstream enforcement hooks
 */

// ============================================
// IMMUTABLE VERSION - NEVER CHANGE IN PLACE
// Create new version if weights/probes change
// ============================================
export const ONBOARDING_VERSION = '1.0.0';

// Role enum
export const UserRole = {
  WORKER: 'worker',
  POSTER: 'poster',
};

// ============================================
// GAP 1 FIX: Confidence Certainty Tiers
// ============================================
export const RoleCertainty = {
  STRONG: 'STRONG',     // ≥ 0.75 - High confidence, normal flow
  MODERATE: 'MODERATE', // 0.60-0.74 - Softer confirmation copy
  WEAK: 'WEAK',         // < 0.60 - Force explicit choice, log ambiguity
};

export function getCertaintyTier(confidence) {
  if (confidence >= 0.75) return RoleCertainty.STRONG;
  if (confidence >= 0.60) return RoleCertainty.MODERATE;
  return RoleCertainty.WEAK;
}

// Signal weights (VERSION LOCKED)
const SIGNAL_WEIGHTS = {
  deviceType: 0.05,
  timeOfDay: 0.03,
  referralSource: 0.10,
  motivation: 0.25,
  frustration: 0.20,
  availability: 0.15,
  priceOrientation: 0.12,
  controlPreference: 0.10,
};

// ============================================
// GAP 2 FIX: Inconsistency Detection Rules
// ============================================
const INCONSISTENCY_RULES = [
  {
    id: 'control_availability_mismatch',
    // High control + low availability = contradiction
    check: (responses) => 
      responses.controlPreference === 'autonomous' && 
      responses.availability === 'minimal',
    penalty: 0.15, // Dampen confidence
    flag: 'CONTRADICTORY_CONTROL_AVAILABILITY',
  },
  {
    id: 'price_urgency_mismatch',
    // Price-competitive + low urgency = poster-leaning signal masked
    check: (responses) =>
      responses.priceOrientation === 'competitive' &&
      responses.availability === 'minimal',
    penalty: 0.10,
    flag: 'PRICE_URGENCY_INCONSISTENT',
  },
  {
    id: 'delegation_income_conflict',
    // Wants delegation but claims income motivation
    check: (responses) =>
      responses.controlPreference === 'delegator' &&
      responses.motivation === 'income',
    penalty: 0.20,
    flag: 'DELEGATION_INCOME_CONFLICT',
  },
  {
    id: 'all_worker_signals',
    // Suspiciously perfect worker profile (gaming attempt)
    check: (responses) =>
      responses.motivation === 'income' &&
      responses.frustration === 'payment' &&
      responses.availability === 'flexible' &&
      responses.priceOrientation === 'competitive' &&
      responses.controlPreference === 'autonomous',
    penalty: 0.25,
    flag: 'SUSPICIOUSLY_PERFECT_WORKER',
  },
  {
    id: 'all_poster_signals',
    // Suspiciously perfect poster profile
    check: (responses) =>
      responses.motivation === 'delegation' &&
      responses.frustration === 'finding' &&
      responses.availability === 'minimal' &&
      responses.priceOrientation === 'premium' &&
      responses.controlPreference === 'delegator',
    penalty: 0.25,
    flag: 'SUSPICIOUSLY_PERFECT_POSTER',
  },
];

/**
 * Detect inconsistencies in responses
 * Returns { totalPenalty, flags[] }
 */
export function detectInconsistencies(responses) {
  const flags = [];
  let totalPenalty = 0;

  for (const rule of INCONSISTENCY_RULES) {
    if (rule.check(responses)) {
      flags.push(rule.flag);
      totalPenalty += rule.penalty;
    }
  }

  return {
    totalPenalty: Math.min(totalPenalty, 0.40), // Cap penalty at 40%
    flags,
    hasInconsistencies: flags.length > 0,
  };
}

/**
 * Calibration Questions (VERSION LOCKED)
 */
export const CALIBRATION_QUESTIONS = [
  {
    id: 'motivation',
    prompt: 'Which matters more right now?',
    options: [
      { id: 'income', label: 'Earning extra income', signal: { worker: 0.85, poster: 0.15 } },
      { id: 'delegation', label: 'Getting things done', signal: { worker: 0.15, poster: 0.85 } },
      { id: 'both', label: 'Both equally', signal: { worker: 0.50, poster: 0.50 } },
    ],
  },
  {
    id: 'frustration',
    prompt: 'What frustrates you most about getting help?',
    options: [
      { id: 'finding', label: 'Finding reliable people', signal: { worker: 0.20, poster: 0.80 } },
      { id: 'payment', label: 'Getting paid fairly', signal: { worker: 0.85, poster: 0.15 } },
      { id: 'communication', label: 'Poor communication', signal: { worker: 0.45, poster: 0.55 } },
    ],
  },
  {
    id: 'availability',
    prompt: 'How much time can you commit weekly?',
    options: [
      { id: 'flexible', label: 'Flexible, varies weekly', signal: { worker: 0.75, poster: 0.25 } },
      { id: 'limited', label: 'Limited, specific hours', signal: { worker: 0.60, poster: 0.40 } },
      { id: 'minimal', label: 'Minimal, just oversight', signal: { worker: 0.20, poster: 0.80 } },
    ],
  },
  {
    id: 'priceOrientation',
    prompt: 'When it comes to price:',
    options: [
      { id: 'competitive', label: 'I compete on value', signal: { worker: 0.80, poster: 0.20 } },
      { id: 'premium', label: 'I pay for quality', signal: { worker: 0.15, poster: 0.85 } },
      { id: 'fair', label: 'Fair rates matter most', signal: { worker: 0.50, poster: 0.50 } },
    ],
  },
  {
    id: 'controlPreference',
    prompt: 'Your preferred working style:',
    options: [
      { id: 'autonomous', label: 'Work independently', signal: { worker: 0.80, poster: 0.20 } },
      { id: 'collaborative', label: 'Clear direction helps', signal: { worker: 0.55, poster: 0.45 } },
      { id: 'delegator', label: 'Delegate and verify', signal: { worker: 0.15, poster: 0.85 } },
    ],
  },
];

/**
 * Phase 0: Silent Context Capture
 */
export function captureContext() {
  return {
    capturedAt: new Date().toISOString(),
    deviceType: 'mobile',
    platform: 'ios',
    locale: 'en-US',
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    hourOfDay: new Date().getHours(),
    dayOfWeek: new Date().getDay(),
    referralSource: null,
    campaignId: null,
    signupVelocity: null,
    fieldRevisions: 0,
  };
}

/**
 * Compute role confidence with inconsistency penalties
 */
export function computeRoleConfidence(context, responses) {
  let workerScore = 0;
  let posterScore = 0;
  let totalWeight = 0;

  // Context signals
  if (context.deviceType === 'mobile') {
    workerScore += 0.55 * SIGNAL_WEIGHTS.deviceType;
    posterScore += 0.45 * SIGNAL_WEIGHTS.deviceType;
    totalWeight += SIGNAL_WEIGHTS.deviceType;
  }

  if (context.hourOfDay >= 18 || context.hourOfDay <= 6) {
    workerScore += 0.60 * SIGNAL_WEIGHTS.timeOfDay;
    posterScore += 0.40 * SIGNAL_WEIGHTS.timeOfDay;
    totalWeight += SIGNAL_WEIGHTS.timeOfDay;
  }

  // Calibration responses
  for (const question of CALIBRATION_QUESTIONS) {
    const response = responses[question.id];
    if (response) {
      const option = question.options.find(o => o.id === response);
      if (option) {
        const weight = SIGNAL_WEIGHTS[question.id] || 0.1;
        workerScore += option.signal.worker * weight;
        posterScore += option.signal.poster * weight;
        totalWeight += weight;
      }
    }
  }

  // Normalize
  const total = workerScore + posterScore;
  if (total === 0) {
    return { 
      worker: 0.50, 
      poster: 0.50, 
      confidence: 0,
      certaintyTier: RoleCertainty.WEAK,
      inconsistencies: { totalPenalty: 0, flags: [], hasInconsistencies: false },
    };
  }

  let normalizedWorker = workerScore / total;
  let normalizedPoster = posterScore / total;

  // GAP 2: Apply inconsistency penalties
  const inconsistencies = detectInconsistencies(responses);
  
  if (inconsistencies.hasInconsistencies) {
    // Dampen confidence toward 50/50
    const dampeningFactor = 1 - inconsistencies.totalPenalty;
    normalizedWorker = 0.5 + (normalizedWorker - 0.5) * dampeningFactor;
    normalizedPoster = 0.5 + (normalizedPoster - 0.5) * dampeningFactor;
  }

  // Confidence = how far from 50/50
  const confidence = Math.abs(normalizedWorker - 0.5) * 2;
  
  // GAP 1: Determine certainty tier
  const certaintyTier = getCertaintyTier(Math.max(normalizedWorker, normalizedPoster));

  return {
    worker: Number(normalizedWorker.toFixed(4)),
    poster: Number(normalizedPoster.toFixed(4)),
    confidence: Number(confidence.toFixed(4)),
    certaintyTier,
    inconsistencies,
  };
}

/**
 * Infer role with certainty-aware logic
 */
export function inferRole(roleConfidence) {
  const THRESHOLD = 0.55;
  
  // GAP 1: If WEAK certainty, we still infer but flag it
  if (roleConfidence.worker >= THRESHOLD) {
    return UserRole.WORKER;
  }
  if (roleConfidence.poster >= THRESHOLD) {
    return UserRole.POSTER;
  }
  
  return roleConfidence.worker >= roleConfidence.poster 
    ? UserRole.WORKER 
    : UserRole.POSTER;
}

/**
 * Get confirmation copy based on certainty tier
 * GAP 1: Different UI behavior per tier
 */
export function getConfirmationCopy(certaintyTier, inferredRole) {
  const roleLabel = inferredRole === UserRole.WORKER ? 'Worker' : 'Poster';
  
  switch (certaintyTier) {
    case RoleCertainty.STRONG:
      return {
        headline: "We'll set you up as a",
        subtext: null,
        requiresExplicitChoice: false,
      };
    case RoleCertainty.MODERATE:
      return {
        headline: "Based on your responses, you seem like a",
        subtext: "You can adjust this if it doesn't feel right.",
        requiresExplicitChoice: false,
      };
    case RoleCertainty.WEAK:
      return {
        headline: "We couldn't determine your primary use case",
        subtext: "Please select how you'll mainly use HustleXP:",
        requiresExplicitChoice: true, // Forces explicit selection
      };
    default:
      return {
        headline: "We'll set you up as a",
        subtext: null,
        requiresExplicitChoice: false,
      };
  }
}

/**
 * Compute profile signals
 */
export function computeProfileSignals(context, responses, roleConfidence) {
  let riskTolerance = 0.5;
  if (responses.priceOrientation === 'competitive') riskTolerance += 0.2;
  if (responses.priceOrientation === 'premium') riskTolerance -= 0.1;
  if (responses.controlPreference === 'autonomous') riskTolerance += 0.15;
  if (responses.controlPreference === 'delegator') riskTolerance -= 0.1;

  let urgencyBias = 0.5;
  if (responses.availability === 'flexible') urgencyBias += 0.15;
  if (responses.availability === 'minimal') urgencyBias -= 0.2;
  if (responses.motivation === 'income') urgencyBias += 0.1;

  let authorityExpectation = 0.5;
  if (responses.controlPreference === 'collaborative') authorityExpectation += 0.2;
  if (responses.controlPreference === 'autonomous') authorityExpectation -= 0.15;
  if (responses.frustration === 'communication') authorityExpectation += 0.1;

  return {
    riskTolerance: Math.max(0, Math.min(1, riskTolerance)),
    urgencyBias: Math.max(0, Math.min(1, urgencyBias)),
    authorityExpectation: Math.max(0, Math.min(1, authorityExpectation)),
    priceSensitivity: responses.priceOrientation === 'competitive' ? 0.8 : 
                       responses.priceOrientation === 'premium' ? 0.3 : 0.5,
  };
}

/**
 * GAP 4: Enforcement rules derived from role
 * These will be enforced server-side in Phase 11
 */
export function getEnforcementRules(finalRole, roleConfidence) {
  return {
    // XP accrual rules
    xpAccrualEnabled: finalRole === UserRole.WORKER,
    xpVisibilityLevel: finalRole === UserRole.WORKER ? 'detailed' : 'summary',
    
    // Task visibility rules
    canAcceptTasks: finalRole === UserRole.WORKER,
    canPostTasks: finalRole === UserRole.POSTER,
    
    // Dispute defaults (lower confidence = more scrutiny)
    disputeReviewPriority: roleConfidence.certaintyTier === RoleCertainty.WEAK 
      ? 'high' 
      : 'normal',
    
    // Trust building rules
    trustBuildingRate: roleConfidence.certaintyTier === RoleCertainty.STRONG 
      ? 1.0 
      : roleConfidence.certaintyTier === RoleCertainty.MODERATE 
        ? 0.9 
        : 0.75, // Slower trust building for ambiguous users
  };
}

/**
 * Create complete onboarding result
 * GAP 3: Version is LOCKED and stored
 */
export function createOnboardingResult(context, responses, roleOverride = null) {
  const roleConfidence = computeRoleConfidence(context, responses);
  const inferredRole = inferRole(roleConfidence);
  const finalRole = roleOverride || inferredRole;
  const profileSignals = computeProfileSignals(context, responses, roleConfidence);
  const confirmationCopy = getConfirmationCopy(roleConfidence.certaintyTier, inferredRole);
  const enforcementRules = getEnforcementRules(finalRole, roleConfidence);

  return {
    // GAP 3: IMMUTABLE VERSION
    version: ONBOARDING_VERSION,
    completedAt: new Date().toISOString(),
    
    // Role determination
    roleConfidence: {
      worker: roleConfidence.worker,
      poster: roleConfidence.poster,
      confidence: roleConfidence.confidence,
      certaintyTier: roleConfidence.certaintyTier, // GAP 1
    },
    inferredRole,
    finalRole,
    roleWasOverridden: roleOverride !== null && roleOverride !== inferredRole,
    
    // GAP 1: Certainty tier for UI behavior
    certaintyTier: roleConfidence.certaintyTier,
    confirmationCopy,
    
    // GAP 2: Gaming detection
    inconsistencies: roleConfidence.inconsistencies,
    
    // Profile signals
    profileSignals,
    
    // GAP 4: Enforcement rules (for server-side)
    enforcementRules,
    
    // Raw data
    context,
    responses,
    
    // Derived settings
    settings: {
      defaultAppMode: finalRole,
      xpVisibilityRules: finalRole === UserRole.WORKER ? 'ledger' : 'outcome',
      trustUiDensity: profileSignals.authorityExpectation > 0.6 ? 'detailed' : 'minimal',
      copyToneVariant: finalRole === UserRole.WORKER ? 'earner' : 'delegator',
    },
  };
}

/**
 * Check if re-onboarding is allowed
 * GAP 1: Only allowed in specific cases
 */
export function canReOnboard(existingResult, daysSinceCompletion) {
  // Never allow within first 7 days
  if (daysSinceCompletion < 7) return false;
  
  // Allow if original certainty was WEAK
  if (existingResult.certaintyTier === RoleCertainty.WEAK) return true;
  
  // Allow if user overrode and then switched back
  if (existingResult.roleWasOverridden) return true;
  
  // Otherwise, require admin approval
  return false;
}

export default {
  ONBOARDING_VERSION,
  UserRole,
  RoleCertainty,
  CALIBRATION_QUESTIONS,
  captureContext,
  detectInconsistencies,
  computeRoleConfidence,
  inferRole,
  getConfirmationCopy,
  computeProfileSignals,
  getEnforcementRules,
  createOnboardingResult,
  canReOnboard,
  getCertaintyTier,
};
