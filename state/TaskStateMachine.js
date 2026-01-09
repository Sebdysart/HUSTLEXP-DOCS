/**
 * TaskStateMachine - Task lifecycle state management
 * 
 * SPEC: PRODUCT_SPEC.md §3 (Task Lifecycle)
 * IMPL: BUILD_GUIDE.md §6 (Phase 3: Frontend State)
 * RIVE COMPATIBLE: Explicit states, explicit conditions
 * 
 * States:
 * - OPEN: Task created, waiting for hustler
 * - ACCEPTED: Hustler accepted, escrow funded
 * - PROOF_SUBMITTED: Hustler submitted proof
 * - DISPUTED: Client disputed proof
 * - COMPLETED: Task done, escrow released (TERMINAL)
 * - CANCELLED: Task cancelled (TERMINAL)
 * - EXPIRED: Task deadline passed (TERMINAL)
 */

// Explicit state enum (Rive-mappable)
export const TaskState = {
  OPEN: 'OPEN',
  ACCEPTED: 'ACCEPTED',
  PROOF_SUBMITTED: 'PROOF_SUBMITTED',
  DISPUTED: 'DISPUTED',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
};

// Terminal states (no further transitions allowed)
export const TERMINAL_STATES = [
  TaskState.COMPLETED,
  TaskState.CANCELLED,
  TaskState.EXPIRED,
];

// Valid transitions (Rive-mappable: from → [to])
export const TASK_TRANSITIONS = {
  [TaskState.OPEN]: [
    TaskState.ACCEPTED,
    TaskState.CANCELLED,
    TaskState.EXPIRED,
  ],
  [TaskState.ACCEPTED]: [
    TaskState.PROOF_SUBMITTED,
    TaskState.CANCELLED,
    TaskState.EXPIRED,
  ],
  [TaskState.PROOF_SUBMITTED]: [
    TaskState.COMPLETED,
    TaskState.DISPUTED,
    TaskState.CANCELLED,
  ],
  [TaskState.DISPUTED]: [
    TaskState.COMPLETED,
    TaskState.CANCELLED,
  ],
  // Terminal states - no transitions
  [TaskState.COMPLETED]: [],
  [TaskState.CANCELLED]: [],
  [TaskState.EXPIRED]: [],
};

/**
 * Transition guards (Rive-mappable boolean conditions)
 * Each guard returns true/false - no natural language
 */
export const TaskGuards = {
  // OPEN → ACCEPTED
  canAccept: (task, context) => {
    return (
      task.state === TaskState.OPEN &&
      context.hustlerId !== null &&
      context.escrowState === 'FUNDED'
    );
  },

  // ACCEPTED → PROOF_SUBMITTED
  canSubmitProof: (task, context) => {
    return (
      task.state === TaskState.ACCEPTED &&
      context.proofId !== null
    );
  },

  // PROOF_SUBMITTED → COMPLETED (INV-3: requires ACCEPTED proof)
  canComplete: (task, context) => {
    return (
      task.state === TaskState.PROOF_SUBMITTED &&
      context.proofState === 'ACCEPTED'
    );
  },

  // DISPUTED → COMPLETED (after resolution)
  canCompleteFromDispute: (task, context) => {
    return (
      task.state === TaskState.DISPUTED &&
      context.disputeResolution === 'HUSTLER_WINS'
    );
  },

  // PROOF_SUBMITTED → DISPUTED
  canDispute: (task, context) => {
    return (
      task.state === TaskState.PROOF_SUBMITTED &&
      context.clientId === task.clientId
    );
  },

  // Any non-terminal → CANCELLED
  canCancel: (task, context) => {
    return (
      !TERMINAL_STATES.includes(task.state) &&
      (context.role === 'admin' || context.userId === task.clientId)
    );
  },

  // OPEN/ACCEPTED → EXPIRED (time-based)
  canExpire: (task, context) => {
    return (
      (task.state === TaskState.OPEN || task.state === TaskState.ACCEPTED) &&
      context.now > task.deadline
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
  const allowed = TASK_TRANSITIONS[from];
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
 * @param {object} task - Current task
 * @param {string} targetState - Target state
 * @param {object} context - Transition context
 * @returns {{ success: boolean, error?: string, task?: object }}
 */
export function transitionTask(task, targetState, context) {
  // Guard: Cannot transition from terminal state
  if (isTerminalState(task.state)) {
    return {
      success: false,
      error: `Cannot transition from terminal state: ${task.state}`,
    };
  }

  // Guard: Transition must be valid
  if (!isValidTransition(task.state, targetState)) {
    return {
      success: false,
      error: `Invalid transition: ${task.state} → ${targetState}`,
    };
  }

  // Apply specific guards
  const guardMap = {
    [TaskState.ACCEPTED]: TaskGuards.canAccept,
    [TaskState.PROOF_SUBMITTED]: TaskGuards.canSubmitProof,
    [TaskState.COMPLETED]: task.state === TaskState.DISPUTED 
      ? TaskGuards.canCompleteFromDispute 
      : TaskGuards.canComplete,
    [TaskState.DISPUTED]: TaskGuards.canDispute,
    [TaskState.CANCELLED]: TaskGuards.canCancel,
    [TaskState.EXPIRED]: TaskGuards.canExpire,
  };

  const guard = guardMap[targetState];
  if (guard && !guard(task, context)) {
    return {
      success: false,
      error: `Guard failed for transition to ${targetState}`,
    };
  }

  // Execute transition
  const updatedTask = {
    ...task,
    state: targetState,
    updatedAt: new Date().toISOString(),
  };

  // Add state-specific timestamps
  if (targetState === TaskState.ACCEPTED) {
    updatedTask.acceptedAt = new Date().toISOString();
  }
  if (targetState === TaskState.COMPLETED) {
    updatedTask.completedAt = new Date().toISOString();
  }

  return {
    success: true,
    task: updatedTask,
  };
}

export default {
  TaskState,
  TERMINAL_STATES,
  TASK_TRANSITIONS,
  TaskGuards,
  isValidTransition,
  isTerminalState,
  transitionTask,
};
