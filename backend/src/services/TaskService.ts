/**
 * HustleXP Task Service
 * 
 * PURPOSE: Layer 1 enforcement for task operations
 * AUTHORITY: Submits to Layer 0 (schema.sql) constraints
 * 
 * INVARIANTS ENFORCED BY DATABASE:
 * - INV-3: Cannot complete task unless proof is ACCEPTED (trigger)
 * - Terminal state immutability (trigger)
 * 
 * @see schema.sql for Layer 0 enforcement
 * @see EXECUTION_INDEX.md Section 3.1
 */

import { query, getHustleXPErrorCode } from '../db.js';
import { 
  Task, 
  TaskState, 
  TERMINAL_TASK_STATES,
  ServiceResult,
  success,
  failure
} from '../types.js';

// =============================================================================
// READ OPERATIONS
// =============================================================================

/**
 * Get task by ID
 */
export async function getTaskById(id: string): Promise<Task | null> {
  const result = await query<Task>(
    'SELECT * FROM tasks WHERE id = $1',
    [id]
  );
  return result.rows[0] || null;
}

/**
 * Get tasks by poster
 */
export async function getTasksByPoster(posterId: string): Promise<Task[]> {
  const result = await query<Task>(
    'SELECT * FROM tasks WHERE poster_id = $1 ORDER BY created_at DESC',
    [posterId]
  );
  return result.rows;
}

/**
 * Get tasks by worker
 */
export async function getTasksByWorker(workerId: string): Promise<Task[]> {
  const result = await query<Task>(
    'SELECT * FROM tasks WHERE worker_id = $1 ORDER BY created_at DESC',
    [workerId]
  );
  return result.rows;
}

// =============================================================================
// STATE TRANSITIONS
// =============================================================================

/**
 * Create a new task
 * 
 * STATE: → OPEN
 */
export async function createTask(params: {
  poster_id: string;
  title: string;
  description: string;
  price: number;
  deadline?: Date;
  requirements?: string;
  location?: string;
  category?: string;
  requires_proof?: boolean;
  proof_instructions?: string;
}): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `INSERT INTO tasks (
        poster_id, title, description, price, deadline,
        requirements, location, category, requires_proof, proof_instructions
      )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        params.poster_id,
        params.title,
        params.description,
        params.price,
        params.deadline || null,
        params.requirements || null,
        params.location || null,
        params.category || null,
        params.requires_proof ?? true,
        params.proof_instructions || null,
      ]
    );
    return success(result.rows[0]);
  } catch (error: any) {
    if (error.code === '23503') {
      return failure('Poster not found', 'USER_NOT_FOUND');
    }
    throw error;
  }
}

/**
 * Accept a task (OPEN → ACCEPTED)
 * 
 * PRECONDITIONS:
 * - Task must be in OPEN state
 * - Worker must exist
 * 
 * STATE: OPEN → ACCEPTED
 */
export async function acceptTask(
  taskId: string,
  workerId: string
): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'ACCEPTED',
           worker_id = $2,
           accepted_at = NOW()
       WHERE id = $1 AND state = 'OPEN'
       RETURNING *`,
      [taskId, workerId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in OPEN state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    if (error.code === '23503') {
      return failure('Worker not found', 'USER_NOT_FOUND');
    }
    throw error;
  }
}

/**
 * Submit proof for task (ACCEPTED → PROOF_SUBMITTED)
 * 
 * PRECONDITIONS:
 * - Task must be in ACCEPTED state
 * 
 * STATE: ACCEPTED → PROOF_SUBMITTED
 */
export async function submitProof(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'PROOF_SUBMITTED',
           proof_submitted_at = NOW()
       WHERE id = $1 AND state = 'ACCEPTED'
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in ACCEPTED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Complete a task (PROOF_SUBMITTED → COMPLETED)
 * 
 * PRECONDITIONS:
 * - Task must be in PROOF_SUBMITTED state
 * - Proof must be ACCEPTED (INV-3 - enforced by DB trigger)
 * 
 * STATE: PROOF_SUBMITTED → COMPLETED
 * 
 * INV-3 ENFORCEMENT:
 * The database trigger `task_completed_requires_accepted_proof` will
 * raise error HX301 if no accepted proof exists for this task.
 * This service does NOT pre-check; it relies on Layer 0.
 */
export async function completeTask(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'COMPLETED',
           completed_at = NOW()
       WHERE id = $1 AND state = 'PROOF_SUBMITTED'
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in PROOF_SUBMITTED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    // INV-3 violation from database trigger
    const code = getHustleXPErrorCode(error);
    if (code === 'HX301') {
      return failure(
        'Cannot complete task: no accepted proof exists (INV-3)',
        'INV_3_VIOLATION'
      );
    }
    throw error;
  }
}

/**
 * Reject proof (PROOF_SUBMITTED → ACCEPTED)
 * 
 * PRECONDITIONS:
 * - Task must be in PROOF_SUBMITTED state
 * 
 * STATE: PROOF_SUBMITTED → ACCEPTED
 */
export async function rejectProof(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'ACCEPTED',
           proof_submitted_at = NULL
       WHERE id = $1 AND state = 'PROOF_SUBMITTED'
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in PROOF_SUBMITTED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Open dispute (PROOF_SUBMITTED → DISPUTED)
 * 
 * PRECONDITIONS:
 * - Task must be in PROOF_SUBMITTED state
 * 
 * STATE: PROOF_SUBMITTED → DISPUTED
 */
export async function openDispute(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'DISPUTED'
       WHERE id = $1 AND state = 'PROOF_SUBMITTED'
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in PROOF_SUBMITTED state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Cancel task (OPEN | ACCEPTED → CANCELLED)
 * 
 * PRECONDITIONS:
 * - Task must be in OPEN or ACCEPTED state
 * 
 * STATE: OPEN | ACCEPTED → CANCELLED
 */
export async function cancelTask(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'CANCELLED',
           cancelled_at = NOW()
       WHERE id = $1 AND state IN ('OPEN', 'ACCEPTED')
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found or not in cancellable state', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

/**
 * Expire task (* → EXPIRED)
 * 
 * PRECONDITIONS:
 * - Task must not be in terminal state
 * - Task deadline must have passed
 * 
 * STATE: * → EXPIRED
 */
export async function expireTask(taskId: string): Promise<ServiceResult<Task>> {
  try {
    const result = await query<Task>(
      `UPDATE tasks 
       SET state = 'EXPIRED',
           expired_at = NOW()
       WHERE id = $1 
         AND state NOT IN ('COMPLETED', 'CANCELLED', 'EXPIRED')
         AND deadline IS NOT NULL 
         AND deadline < NOW()
       RETURNING *`,
      [taskId]
    );
    
    if (result.rowCount === 0) {
      return failure('Task not found, already terminal, or not past deadline', 'INVALID_STATE');
    }
    
    return success(result.rows[0]);
  } catch (error: any) {
    throw error;
  }
}

// =============================================================================
// VALIDATION HELPERS
// =============================================================================

/**
 * Check if task is in a terminal state
 */
export function isTerminalState(state: TaskState): boolean {
  return TERMINAL_TASK_STATES.includes(state);
}

/**
 * Get valid transitions from current state
 */
export function getValidTransitions(state: TaskState): TaskState[] {
  switch (state) {
    case 'OPEN':
      return ['ACCEPTED', 'CANCELLED', 'EXPIRED'];
    case 'ACCEPTED':
      return ['PROOF_SUBMITTED', 'CANCELLED', 'EXPIRED'];
    case 'PROOF_SUBMITTED':
      return ['COMPLETED', 'ACCEPTED', 'DISPUTED', 'EXPIRED'];
    case 'DISPUTED':
      return ['COMPLETED', 'CANCELLED'];
    // Terminal states have no transitions
    case 'COMPLETED':
    case 'CANCELLED':
    case 'EXPIRED':
      return [];
    default:
      return [];
  }
}
