/**
 * HustleXP Escrow Router
 * 
 * PURPOSE: tRPC routes for escrow operations
 * AUTHORITY: Layer 2 (API Routes) - calls Layer 1 (EscrowService)
 * 
 * INVARIANTS (enforced by Layer 0):
 * - INV-2: Cannot release escrow unless task is COMPLETED
 * - INV-4: Escrow amount is immutable after funding
 * 
 * @see EXECUTION_INDEX.md Section 6.3
 */

import { TRPCError } from '@trpc/server';
import { router, protectedProcedure, schemas } from '../trpc.js';
import * as EscrowService from '../services/EscrowService.js';

export const escrowRouter = router({
  /**
   * Get escrow by task ID
   */
  getByTaskId: protectedProcedure
    .input(schemas.uuid)
    .query(async ({ input: taskId }) => {
      const escrow = await EscrowService.getEscrowByTaskId(taskId);
      
      if (!escrow) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Escrow not found for this task',
        });
      }
      
      return escrow;
    }),

  /**
   * Get escrow by ID
   */
  getById: protectedProcedure
    .input(schemas.uuid)
    .query(async ({ input: escrowId }) => {
      const escrow = await EscrowService.getEscrowById(escrowId);
      
      if (!escrow) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Escrow not found',
        });
      }
      
      return escrow;
    }),

  /**
   * Confirm escrow funding after Stripe payment
   * 
   * STATE: PENDING → FUNDED
   */
  confirmFunding: protectedProcedure
    .input(schemas.confirmFunding)
    .mutation(async ({ input }) => {
      const result = await EscrowService.fundEscrow(
        input.escrowId,
        input.stripePaymentIntentId
      );
      
      if (!result.success) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: result.error,
          cause: { code: result.code },
        });
      }
      
      return result.data;
    }),

  /**
   * Release escrow to worker
   * 
   * STATE: FUNDED → RELEASED
   * 
   * CRITICAL: This will fail with INV_2_VIOLATION if the task
   * is not in COMPLETED state. The database enforces this.
   */
  release: protectedProcedure
    .input(schemas.releaseEscrow)
    .mutation(async ({ input }) => {
      const result = await EscrowService.releaseEscrow(
        input.escrowId,
        input.stripeTransferId
      );
      
      if (!result.success) {
        // Map invariant violations to appropriate error codes
        if (result.code === 'INV_2_VIOLATION') {
          throw new TRPCError({
            code: 'PRECONDITION_FAILED',
            message: result.error,
            cause: { code: 'INV-2', dbCode: 'HX201' },
          });
        }
        
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: result.error,
          cause: { code: result.code },
        });
      }
      
      return result.data;
    }),

  /**
   * Refund escrow to poster
   * 
   * STATE: FUNDED | LOCKED_DISPUTE → REFUNDED
   */
  refund: protectedProcedure
    .input(schemas.releaseEscrow) // Same shape
    .mutation(async ({ input }) => {
      const result = await EscrowService.refundEscrow(
        input.escrowId,
        input.stripeTransferId // Actually stripeRefundId for this endpoint
      );
      
      if (!result.success) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: result.error,
          cause: { code: result.code },
        });
      }
      
      return result.data;
    }),

  /**
   * Lock escrow for dispute
   * 
   * STATE: FUNDED → LOCKED_DISPUTE
   */
  lockForDispute: protectedProcedure
    .input(schemas.uuid)
    .mutation(async ({ input: escrowId }) => {
      const result = await EscrowService.lockEscrowForDispute(escrowId);
      
      if (!result.success) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: result.error,
          cause: { code: result.code },
        });
      }
      
      return result.data;
    }),
});
