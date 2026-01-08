/**
 * State Machine Exports
 * 
 * SPEC: BUILD_GUIDE.md §2
 * RIVE COMPATIBLE: All state machines use explicit states and conditions
 * 
 * Invariants enforced:
 * - INV-2: RELEASED requires COMPLETED task
 * - INV-3: COMPLETED requires ACCEPTED proof
 * - INV-4: Escrow amount immutable
 * - AUDIT-2: Escrow state machine transitions
 * - AUDIT-3: Proof verification workflow
 */

// Core state machines
export * from './TaskStateMachine';
export * from './EscrowStateMachine';
export * from './ProofStateMachine';

// Onboarding state machine (Role inference)
export * from './OnboardingStateMachine';

// Re-export defaults
export { default as TaskStateMachine } from './TaskStateMachine';
export { default as EscrowStateMachine } from './EscrowStateMachine';
export { default as ProofStateMachine } from './ProofStateMachine';
export { default as OnboardingStateMachine } from './OnboardingStateMachine';
