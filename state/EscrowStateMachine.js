/**
 * EscrowStateMachine - Escrow/payment state management
 * 
 * SPEC: BUILD_GUIDE.md §2.2
 * RIVE COMPATIBLE: Explicit states, explicit conditions
 * AUDIT-2: Escrow state machine transitions
 * 
 * States:
 * - PENDING: Escrow created, awaiting payment
 * - FUNDED: Payment received, funds held
 * - LOCKED_DISPUTE: Dispute opened, funds frozen
 * - RELEASED: Funds sent to hustler (TERMINAL)
 * - REFUNDED: Funds returned to client (TERMINAL)
 * - REFUND_PARTIAL: Split refund after dispute (TERMINAL)
 */

// Explicit state enum (Rive-mappable)
export const EscrowState = {
  PENDING: 'PENDING',
  FUNDED: 'FUNDED',
  LOCKED_DISPUTE: 'LOCKED_DISPUTE',
  RELEASED: 'RELEASED',
  REFUNDED: 'REFUNDED',
  REFUND_PARTIAL: 'REFUND_PARTIAL',
};

// Terminal states (no further transitions allowed)
export const TERMINAL_STATES = [
  EscrowState.RELEASED,
  EscrowState.REFUNDED,
  EscrowState.REFUND_PARTIAL,
];

// Valid transitions (Rive-mappable: from → [to])
export const ESCROW_TRANSITIONS = {
  [EscrowState.PENDING]: [
    EscrowState.FUNDED,
    EscrowState.REFUNDED,
  ],
  [EscrowState.FUNDED]: [
    EscrowState.RELEASED,
    EscrowState.REFUNDED,
    EscrowState.LOCKED_DISPUTE,
  ],
  [EscrowState.LOCKED_DISPUTE]: [
    EscrowState.RELEASED,
    EscrowState.REFUNDED,
    EscrowState.REFUND_PARTIAL,
  ],
  // Terminal states - no transitions
  [EscrowState.RELEASED]: [],
  [EscrowState.REFUNDED]: [],
  [EscrowState.REFUND_PARTIAL]: [],
};

/**
 * Transition guards (Rive-mappable boolean conditions)
 * INV-STRIPE-2: Stripe is authoritative for payment state
 */
export const EscrowGuards = {
  // PENDING → FUNDED (Stripe payment_intent.succeeded)
  canFund: (escrow, context) => {
    return (
      escrow.state === EscrowState.PENDING &&
      context.stripeEvent === 'payment_intent.succeeded'
    );
  },

  // FUNDED → RELEASED (INV-2: requires COMPLETED task)
  canRelease: (escrow, context) => {
    return (
      escrow.state === EscrowState.FUNDED &&
      context.taskState === 'COMPLETED'
    );
  },

  // LOCKED_DISPUTE → RELEASED (dispute resolved for hustler)
  canReleaseFromDispute: (escrow, context) => {
    return (
      escrow.state === EscrowState.LOCKED_DISPUTE &&
      context.disputeResolution === 'HUSTLER_WINS'
    );
  },

  // PENDING → REFUNDED (payment cancelled)
  canRefundFromPending: (escrow, context) => {
    return (
      escrow.state === EscrowState.PENDING &&
      context.stripeEvent === 'payment_intent.canceled'
    );
  },

  // FUNDED → REFUNDED (task cancelled before completion)
  canRefundFromFunded: (escrow, context) => {
    return (
      escrow.state === EscrowState.FUNDED &&
      context.taskState === 'CANCELLED'
    );
  },

  // LOCKED_DISPUTE → REFUNDED (client wins dispute fully)
  canRefundFromDispute: (escrow, context) => {
    return (
      escrow.state === EscrowState.LOCKED_DISPUTE &&
      context.disputeResolution === 'CLIENT_WINS'
    );
  },

  // LOCKED_DISPUTE → REFUND_PARTIAL (split decision)
  canRefundPartial: (escrow, context) => {
    return (
      escrow.state === EscrowState.LOCKED_DISPUTE &&
      context.disputeResolution === 'SPLIT' &&
      typeof context.splitPercent === 'number' &&
      context.splitPercent > 0 &&
      context.splitPercent < 100
    );
  },

  // FUNDED → LOCKED_DISPUTE (dispute opened)
  canLockForDispute: (escrow, context) => {
    return (
      escrow.state === EscrowState.FUNDED &&
      context.taskState === 'DISPUTED'
    );
  },
};

/**
 * Validate transition is allowed
 * @param {string} from - Current state
 * @param {string} to - Target state
 * @returns {boolean}
 */
export function isValidTransition(from, to) {
  const allowed = ESCROW_TRANSITIONS[from];
  return allowed ? allowed.includes(to) : false;
}

/**
 * Check if state is terminal
 * @param {string} state
 * @returns {boolean}
 */
export function isTerminalState(state) {
  return TERMINAL_STATES.includes(state);
}

/**
 * Execute state transition with guards
 * INV-4: Escrow amount is immutable (not modified in transitions)
 * 
 * @param {object} escrow - Current escrow
 * @param {string} targetState - Target state
 * @param {object} context - Transition context
 * @returns {{ success: boolean, error?: string, escrow?: object }}
 */
export function transitionEscrow(escrow, targetState, context) {
  // Guard: Cannot transition from terminal state
  if (isTerminalState(escrow.state)) {
    return {
      success: false,
      error: `Cannot transition from terminal state: ${escrow.state}`,
    };
  }

  // Guard: Transition must be valid
  if (!isValidTransition(escrow.state, targetState)) {
    return {
      success: false,
      error: `Invalid transition: ${escrow.state} → ${targetState}`,
    };
  }

  // Apply specific guards
  let guardPassed = false;

  switch (targetState) {
    case EscrowState.FUNDED:
      guardPassed = EscrowGuards.canFund(escrow, context);
      break;
    case EscrowState.RELEASED:
      guardPassed = escrow.state === EscrowState.LOCKED_DISPUTE
        ? EscrowGuards.canReleaseFromDispute(escrow, context)
        : EscrowGuards.canRelease(escrow, context);
      break;
    case EscrowState.REFUNDED:
      if (escrow.state === EscrowState.PENDING) {
        guardPassed = EscrowGuards.canRefundFromPending(escrow, context);
      } else if (escrow.state === EscrowState.FUNDED) {
        guardPassed = EscrowGuards.canRefundFromFunded(escrow, context);
      } else if (escrow.state === EscrowState.LOCKED_DISPUTE) {
        guardPassed = EscrowGuards.canRefundFromDispute(escrow, context);
      }
      break;
    case EscrowState.REFUND_PARTIAL:
      guardPassed = EscrowGuards.canRefundPartial(escrow, context);
      break;
    case EscrowState.LOCKED_DISPUTE:
      guardPassed = EscrowGuards.canLockForDispute(escrow, context);
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

  // Execute transition (INV-4: amount not modified)
  const updatedEscrow = {
    ...escrow,
    state: targetState,
    updatedAt: new Date().toISOString(),
  };

  // Add state-specific timestamps
  if (targetState === EscrowState.FUNDED) {
    updatedEscrow.fundedAt = new Date().toISOString();
  }
  if (targetState === EscrowState.RELEASED) {
    updatedEscrow.releasedAt = new Date().toISOString();
  }

  // Add split info for partial refunds
  if (targetState === EscrowState.REFUND_PARTIAL) {
    updatedEscrow.splitPercent = context.splitPercent;
    updatedEscrow.hustlerAmount = Math.floor(escrow.amount * (context.splitPercent / 100));
    updatedEscrow.clientAmount = escrow.amount - updatedEscrow.hustlerAmount;
  }

  return {
    success: true,
    escrow: updatedEscrow,
  };
}

export default {
  EscrowState,
  TERMINAL_STATES,
  ESCROW_TRANSITIONS,
  EscrowGuards,
  isValidTransition,
  isTerminalState,
  transitionEscrow,
};
