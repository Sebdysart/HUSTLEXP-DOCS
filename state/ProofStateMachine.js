/**
 * ProofStateMachine - Proof verification state management
 * 
 * SPEC: BUILD_GUIDE.md §1.1 (Proof Table)
 * RIVE COMPATIBLE: Explicit states, explicit conditions
 * AUDIT-3: Proof verification workflow
 * 
 * States:
 * - PENDING: Proof submitted, awaiting review
 * - ACCEPTED: Client approved proof (TERMINAL)
 * - REJECTED: Client rejected proof (TERMINAL)
 * 
 * Quality Tiers:
 * - BASIC: Text only
 * - STANDARD: 1+ photos
 * - COMPREHENSIVE: Before/after + description
 */

// Explicit state enum (Rive-mappable)
export const ProofState = {
  PENDING: 'PENDING',
  ACCEPTED: 'ACCEPTED',
  REJECTED: 'REJECTED',
};

// Quality tiers (P1-11 from PRODUCT_SPEC)
export const ProofQuality = {
  BASIC: 'BASIC',           // Text only
  STANDARD: 'STANDARD',     // 1+ photos
  COMPREHENSIVE: 'COMPREHENSIVE', // Before/after + description
};

// Terminal states
export const TERMINAL_STATES = [
  ProofState.ACCEPTED,
  ProofState.REJECTED,
];

// Valid transitions (Rive-mappable: from → [to])
export const PROOF_TRANSITIONS = {
  [ProofState.PENDING]: [
    ProofState.ACCEPTED,
    ProofState.REJECTED,
  ],
  // Terminal states - no transitions
  [ProofState.ACCEPTED]: [],
  [ProofState.REJECTED]: [],
};

/**
 * Transition guards (Rive-mappable boolean conditions)
 */
export const ProofGuards = {
  // PENDING → ACCEPTED
  canAccept: (proof, context) => {
    return (
      proof.state === ProofState.PENDING &&
      context.reviewerId === proof.taskClientId &&
      context.decision === 'ACCEPT'
    );
  },

  // PENDING → REJECTED
  canReject: (proof, context) => {
    return (
      proof.state === ProofState.PENDING &&
      context.reviewerId === proof.taskClientId &&
      context.decision === 'REJECT' &&
      typeof context.rejectionReason === 'string' &&
      context.rejectionReason.length > 0
    );
  },
};

/**
 * Determine proof quality tier
 * @param {object} proof
 * @returns {string} Quality tier
 */
export function determineQuality(proof) {
  const hasPhotos = Array.isArray(proof.photoUrls) && proof.photoUrls.length > 0;
  const hasDescription = typeof proof.description === 'string' && proof.description.length >= 50;
  const hasBeforeAfter = proof.photoUrls?.length >= 2 && proof.beforeAfterMarked === true;

  if (hasBeforeAfter && hasDescription) {
    return ProofQuality.COMPREHENSIVE;
  }
  if (hasPhotos) {
    return ProofQuality.STANDARD;
  }
  return ProofQuality.BASIC;
}

/**
 * Validate transition is allowed
 */
export function isValidTransition(from, to) {
  const allowed = PROOF_TRANSITIONS[from];
  return allowed ? allowed.includes(to) : false;
}

/**
 * Check if state is terminal
 */
export function isTerminalState(state) {
  return TERMINAL_STATES.includes(state);
}

/**
 * Execute state transition with guards
 * @param {object} proof - Current proof
 * @param {string} targetState - Target state
 * @param {object} context - Transition context
 * @returns {{ success: boolean, error?: string, proof?: object }}
 */
export function transitionProof(proof, targetState, context) {
  // Guard: Cannot transition from terminal state
  if (isTerminalState(proof.state)) {
    return {
      success: false,
      error: `Cannot transition from terminal state: ${proof.state}`,
    };
  }

  // Guard: Transition must be valid
  if (!isValidTransition(proof.state, targetState)) {
    return {
      success: false,
      error: `Invalid transition: ${proof.state} → ${targetState}`,
    };
  }

  // Apply specific guards
  let guardPassed = false;

  switch (targetState) {
    case ProofState.ACCEPTED:
      guardPassed = ProofGuards.canAccept(proof, context);
      break;
    case ProofState.REJECTED:
      guardPassed = ProofGuards.canReject(proof, context);
      break;
    default:
      guardPassed = false;
  }

  if (!guardPassed) {
    return {
      success: false,
      error: `Guard failed for transition to ${targetState}`,
    };
  }

  // Execute transition
  const updatedProof = {
    ...proof,
    state: targetState,
    reviewedAt: new Date().toISOString(),
    reviewerId: context.reviewerId,
  };

  // Add rejection reason if rejected
  if (targetState === ProofState.REJECTED) {
    updatedProof.rejectionReason = context.rejectionReason;
  }

  return {
    success: true,
    proof: updatedProof,
  };
}

/**
 * Create new proof submission
 * @param {object} params
 * @returns {object} New proof object
 */
export function createProof(params) {
  const { taskId, hustlerId, taskClientId, description, photoUrls = [], beforeAfterMarked = false } = params;

  const proof = {
    id: `proof_${Date.now()}`, // Will be UUID in real implementation
    taskId,
    hustlerId,
    taskClientId,
    description,
    photoUrls,
    beforeAfterMarked,
    state: ProofState.PENDING,
    quality: null, // Set below
    submittedAt: new Date().toISOString(),
    reviewedAt: null,
    reviewerId: null,
    rejectionReason: null,
  };

  // Determine quality tier
  proof.quality = determineQuality(proof);

  return proof;
}

export default {
  ProofState,
  ProofQuality,
  TERMINAL_STATES,
  PROOF_TRANSITIONS,
  ProofGuards,
  determineQuality,
  isValidTransition,
  isTerminalState,
  transitionProof,
  createProof,
};
