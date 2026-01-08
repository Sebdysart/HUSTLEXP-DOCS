/**
 * HustleXP Type Definitions
 * 
 * AUTHORITY: These types are derived from schema.sql
 *            They MUST match the database schema exactly.
 * 
 * @see schema.sql for canonical definitions
 */

// =============================================================================
// TASK TYPES (PRODUCT_SPEC §3)
// =============================================================================

export type TaskState = 
  | 'OPEN'           // Visible, accepting applications
  | 'ACCEPTED'       // Worker assigned, work in progress
  | 'PROOF_SUBMITTED'// Awaiting poster review
  | 'DISPUTED'       // Under admin review
  | 'COMPLETED'      // TERMINAL: Successfully finished
  | 'CANCELLED'      // TERMINAL: Terminated by poster/admin
  | 'EXPIRED';       // TERMINAL: Time limit exceeded

export const TERMINAL_TASK_STATES: TaskState[] = ['COMPLETED', 'CANCELLED', 'EXPIRED'];

export interface Task {
  id: string;
  poster_id: string;
  worker_id: string | null;
  title: string;
  description: string;
  requirements: string | null;
  location: string | null;
  category: string | null;
  price: number; // USD cents
  scope_hash: string | null;
  state: TaskState;
  deadline: Date | null;
  accepted_at: Date | null;
  proof_submitted_at: Date | null;
  completed_at: Date | null;
  cancelled_at: Date | null;
  expired_at: Date | null;
  requires_proof: boolean;
  proof_instructions: string | null;
  created_at: Date;
  updated_at: Date;
}

// =============================================================================
// ESCROW TYPES (PRODUCT_SPEC §4)
// =============================================================================

export type EscrowState =
  | 'PENDING'        // Awaiting payment
  | 'FUNDED'         // Money held in escrow
  | 'LOCKED_DISPUTE' // Frozen during dispute
  | 'RELEASED'       // TERMINAL: Paid to worker
  | 'REFUNDED'       // TERMINAL: Returned to poster
  | 'REFUND_PARTIAL';// TERMINAL: Split resolution

export const TERMINAL_ESCROW_STATES: EscrowState[] = ['RELEASED', 'REFUNDED', 'REFUND_PARTIAL'];

export interface Escrow {
  id: string;
  task_id: string;
  amount: number; // USD cents - IMMUTABLE after funding (INV-4)
  state: EscrowState;
  refund_amount: number | null;
  release_amount: number | null;
  stripe_payment_intent_id: string | null;
  stripe_transfer_id: string | null;
  stripe_refund_id: string | null;
  funded_at: Date | null;
  released_at: Date | null;
  refunded_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

// =============================================================================
// PROOF TYPES (PRODUCT_SPEC §3.2)
// =============================================================================

export type ProofState =
  | 'PENDING'   // Not yet submitted
  | 'SUBMITTED' // Awaiting review
  | 'ACCEPTED'  // Approved by poster
  | 'REJECTED'  // Rejected by poster
  | 'EXPIRED';  // Review window passed

export interface Proof {
  id: string;
  task_id: string;
  submitter_id: string;
  state: ProofState;
  description: string | null;
  reviewed_by: string | null;
  reviewed_at: Date | null;
  rejection_reason: string | null;
  submitted_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

// =============================================================================
// USER TYPES (PRODUCT_SPEC §5, ONBOARDING_SPEC)
// =============================================================================

export type UserMode = 'worker' | 'poster';
export type RoleCertainty = 'STRONG' | 'MODERATE' | 'WEAK';
export type TrustTier = 1 | 2 | 3 | 4;

export interface User {
  id: string;
  email: string;
  phone: string | null;
  full_name: string;
  avatar_url: string | null;
  default_mode: UserMode;
  onboarding_version: string | null;
  onboarding_completed_at: Date | null;
  role_confidence_worker: number | null;
  role_confidence_poster: number | null;
  role_certainty_tier: RoleCertainty | null;
  role_was_overridden: boolean;
  inconsistency_flags: string[] | null;
  trust_tier: TrustTier;
  xp_total: number;
  current_level: number;
  current_streak: number;
  last_task_completed_at: Date | null;
  streak_grace_expires_at: Date | null;
  is_verified: boolean;
  verified_at: Date | null;
  stripe_customer_id: string | null;
  stripe_connect_id: string | null;
  created_at: Date;
  updated_at: Date;
}

// =============================================================================
// XP TYPES (PRODUCT_SPEC §5)
// =============================================================================

export interface XPLedgerEntry {
  id: string;
  user_id: string;
  task_id: string;
  escrow_id: string; // UNIQUE - INV-5
  base_xp: number;
  streak_multiplier: number;
  decay_factor: number;
  effective_xp: number;
  reason: string;
  user_xp_before: number;
  user_xp_after: number;
  user_level_before: number;
  user_level_after: number;
  user_streak_at_award: number;
  awarded_at: Date;
}

// =============================================================================
// BADGE TYPES (ARCHITECTURE §2.3)
// =============================================================================

export type BadgeTier = 1 | 2 | 3 | 4;

export interface Badge {
  id: string;
  user_id: string;
  badge_type: string;
  badge_tier: BadgeTier;
  animation_shown_at: Date | null; // Server-side tracking (INV-BADGE-3)
  awarded_for: string | null;
  task_id: string | null;
  awarded_at: Date;
}

// =============================================================================
// DISPUTE TYPES
// =============================================================================

export type DisputeState =
  | 'OPEN'
  | 'EVIDENCE_REQUESTED'
  | 'RESOLVED'
  | 'ESCALATED';

export type DisputeOutcome = 'RELEASE' | 'REFUND' | 'SPLIT';

export interface Dispute {
  id: string;
  task_id: string;
  escrow_id: string;
  initiated_by: string;
  poster_id: string;
  worker_id: string;
  state: DisputeState;
  reason: string;
  description: string;
  resolution: string | null;
  resolution_notes: string | null;
  resolved_by: string | null;
  resolved_at: Date | null;
  outcome_escrow_action: DisputeOutcome | null;
  outcome_worker_penalty: boolean;
  outcome_poster_penalty: boolean;
  created_at: Date;
  updated_at: Date;
}

// =============================================================================
// SERVICE RESULT TYPES
// =============================================================================

export type ServiceResult<T> = 
  | { success: true; data: T }
  | { success: false; error: string; code?: string };

export function success<T>(data: T): ServiceResult<T> {
  return { success: true, data };
}

export function failure<T>(error: string, code?: string): ServiceResult<T> {
  return { success: false, error, code };
}
