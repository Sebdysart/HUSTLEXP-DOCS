/**
 * HustleXP Escrow Service
 * 
 * PURPOSE: Layer 1 enforcement for escrow operations
 * AUTHORITY: Submits to Layer 0 (schema.sql) constraints
 * 
 * INVARIANTS ENFORCED BY DATABASE:
 * - INV-2: Cannot release escrow unless task is COMPLETED (trigger)
 * - INV-4: Escrow amount immutable after funding (trigger)
 * - Terminal state immutability (trigger)
 * 
 * @see schema.sql for Layer 0 enforcement
 * @see EXECUTION_INDEX.md Section 3.1
 */

import { PoolClient } from 'pg';
import { query, withTransaction, getHustleXPErrorCode, DB_ERROR_CODES } from '../db.js';
import { 
  Escrow, 
  EscrowState, 
  Task, 
  TERMINAL_ESCROW_STATES,
  ServiceResult,
  success,
  failure
} from '../types.js';

// =============================================================================
// READ OPERATIONS
// =============================================================================

/**
 * Get escrow by ID
 */
export async function getEscrowById(id: string): Promise<Escrow | null> {
  const result = await query<Escrow>(
    'SELECT * FROM escrows WHERE id = $1',
    [id]
  );
  return result.rows[0] || null;
}

/**
 * Get escrow by task ID
 */
export async function getEscrowByTaskId(taskId: string): Promise<Escrow | null> {
  const result = await query<Escrow>(
    'SELECT * FROM escrows WHERE task_id = $1',
    [taskId]
  );
  return result.rows[0] || null;
}

// =============================================================================
// STATE TRANSITIONS
// =============================================================================

/**
 * Create a new escrow for a task
 * 
 * PRECONDITIONS:
 * - Task must exist
 * - Task must not already have an escrow
 * 
 * STATE: → PENDING
 */
export async function createEscrow(
  taskId: string,
  amount: number
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `INSERT INTO escrows (task_id, amount, state)
       VALUES ($1, $2, 'PENDING')
       RETURNING *`,
      [taskId, amount]
    );
    return success(result.rows[0]);
  } catch (error: any) {
    // Check for unique constraint violation (task already has escrow)
    if (error.code === '23505') {
      return failure('Task already has an escrow', 'DUPLICATE_ESCROW');
    }
    // Check for foreign key violation (task doesn't exist)
    if (error.code === '23503') {
      return failure('Task not found', 'TASK_NOT_FOUND');
    }
    throw error;
  }
}

/**
 * Fund an escrow (PENDING → FUNDED)
 * 
 * PRECONDITIONS:
 * - Escrow must be in PENDING state
 * - Payment intent must be valid
 * 
 * STATE: PENDING → FUNDED
 */
export async function fundEscrow(
  escrowId: string,
  stripePaymentIntentId: string
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `UPDATE escrows 
       SET state = 'FUNDED',
           stripe_payment_intent_id = $2,
           funded_at = NOW()
       WHERE id = $1 AND state = 'PENDING'
       RETURNING *`,
      [escrowId, stripePaymentIntentId]
    );
    
    if (result.rowCount === 0) {
      return failure('Escrow not found or not in PENDING state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Release escrow to worker (FUNDED → RELEASED)
 * 
 * PRECONDITIONS:
 * - Escrow must be in FUNDED state
 * - Task must be in COMPLETED state (INV-2 - enforced by DB trigger)
 * 
 * STATE: FUNDED → RELEASED
 * 
 * INV-2 ENFORCEMENT:
 * The database trigger `escrow_released_requires_completed_task` will
 * raise error HX201 if the associated task is not in COMPLETED state.
 * This service does NOT pre-check; it relies on Layer 0.
 */
export async function releaseEscrow(
  escrowId: string,
  stripeTransferId: string
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `UPDATE escrows 
       SET state = 'RELEASED',
           stripe_transfer_id = $2,
           released_at = NOW()
       WHERE id = $1 AND state = 'FUNDED'
       RETURNING *`,
      [escrowId, stripeTransferId]
    );
    
    if (result.rowCount === 0) {
      return failure('Escrow not found or not in FUNDED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    // INV-2 violation from database trigger
    const code = getHustleXPErrorCode(error);
    if (code === 'HX201') {
      return failure(
        'Cannot release escrow: task is not in COMPLETED state (INV-2)',
        'INV_2_VIOLATION'
      );
    }
    throw error;
  }
}

/**
 * Refund escrow to poster (FUNDED/LOCKED_DISPUTE → REFUNDED)
 * 
 * PRECONDITIONS:
 * - Escrow must be in FUNDED or LOCKED_DISPUTE state
 * 
 * STATE: FUNDED | LOCKED_DISPUTE → REFUNDED
 */
export async function refundEscrow(
  escrowId: string,
  stripeRefundId: string
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `UPDATE escrows 
       SET state = 'REFUNDED',
           stripe_refund_id = $2,
           refunded_at = NOW()
       WHERE id = $1 AND state IN ('FUNDED', 'LOCKED_DISPUTE')
       RETURNING *`,
      [escrowId, stripeRefundId]
    );
    
    if (result.rowCount === 0) {
      return failure('Escrow not found or not in refundable state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Lock escrow for dispute (FUNDED → LOCKED_DISPUTE)
 * 
 * PRECONDITIONS:
 * - Escrow must be in FUNDED state
 * 
 * STATE: FUNDED → LOCKED_DISPUTE
 */
export async function lockEscrowForDispute(
  escrowId: string
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `UPDATE escrows 
       SET state = 'LOCKED_DISPUTE'
       WHERE id = $1 AND state = 'FUNDED'
       RETURNING *`,
      [escrowId]
    );
    
    if (result.rowCount === 0) {
      return failure('Escrow not found or not in FUNDED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Partial refund from dispute resolution (LOCKED_DISPUTE → REFUND_PARTIAL)
 * 
 * PRECONDITIONS:
 * - Escrow must be in LOCKED_DISPUTE state
 * - refundAmount + releaseAmount must equal escrow amount
 * 
 * STATE: LOCKED_DISPUTE → REFUND_PARTIAL
 */
export async function partialRefundEscrow(
  escrowId: string,
  refundAmount: number,
  releaseAmount: number,
  stripeRefundId: string,
  stripeTransferId: string
): Promise<ServiceResult<Escrow>> {
  try {
    const result = await query<Escrow>(
      `UPDATE escrows 
       SET state = 'REFUND_PARTIAL',
           refund_amount = $2,
           release_amount = $3,
           stripe_refund_id = $4,
           stripe_transfer_id = $5,
           refunded_at = NOW(),
           released_at = NOW()
       WHERE id = $1 AND state = 'LOCKED_DISPUTE'
       RETURNING *`,
      [escrowId, refundAmount, releaseAmount, stripeRefundId, stripeTransferId]
    );
    
    if (result.rowCount === 0) {
      return failure('Escrow not found or not in LOCKED_DISPUTE state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    // Check constraint: refund_amount + release_amount = amount
    if (error.code === '23514') {
      return failure(
        'Partial amounts must sum to total escrow amount',
        'INVALID_PARTIAL_AMOUNTS'
      );
    }
    throw error;
  }
}

// =============================================================================
// VALIDATION HELPERS
// =============================================================================

/**
 * Check if escrow is in a terminal state
 */
export function isTerminalState(state: EscrowState): boolean {
  return TERMINAL_ESCROW_STATES.includes(state);
}

/**
 * Get valid transitions from current state
 */
export function getValidTransitions(state: EscrowState): EscrowState[] {
  switch (state) {
    case 'PENDING':
      return ['FUNDED'];
    case 'FUNDED':
      return ['RELEASED', 'REFUNDED', 'LOCKED_DISPUTE'];
    case 'LOCKED_DISPUTE':
      return ['REFUNDED', 'REFUND_PARTIAL'];
    // Terminal states have no transitions
    case 'RELEASED':
    case 'REFUNDED':
    case 'REFUND_PARTIAL':
      return [];
    default:
      return [];
  }
}
