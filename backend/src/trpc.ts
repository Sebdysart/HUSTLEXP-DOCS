/**
 * HustleXP tRPC Configuration
 * 
 * PURPOSE: Type-safe API layer between frontend and backend
 * AUTHORITY: Layer 2 (API Routes) - submits to Layer 1 (Services)
 * 
 * @see EXECUTION_INDEX.md Section 6
 */

import { initTRPC, TRPCError } from '@trpc/server';
import superjson from 'superjson';
import { z } from 'zod';
import type { Pool } from 'pg';

// =============================================================================
// CONTEXT
// =============================================================================

export interface Context {
  db: Pool;
  userId?: string;
  sessionId?: string;
}

export function createContext(db: Pool): Context {
  return {
    db,
    // userId and sessionId will be set by auth middleware
  };
}

// =============================================================================
// TRPC INITIALIZATION
// =============================================================================

const t = initTRPC.context<Context>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        // Include HustleXP error codes in response
        hustleXPCode: error.cause instanceof Error 
          ? (error.cause as any).code 
          : undefined,
      },
    };
  },
});

// =============================================================================
// PROCEDURES
// =============================================================================

/**
 * Public procedure - no auth required
 */
export const publicProcedure = t.procedure;

/**
 * Protected procedure - requires authenticated user
 */
export const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Authentication required',
    });
  }
  return next({
    ctx: {
      ...ctx,
      userId: ctx.userId, // Now guaranteed to exist
    },
  });
});

/**
 * Admin procedure - requires admin role
 */
export const adminProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Authentication required',
    });
  }
  
  // TODO: Check admin role from database
  // For now, block all admin routes
  throw new TRPCError({
    code: 'FORBIDDEN',
    message: 'Admin access required',
  });
});

// =============================================================================
// ROUTER
// =============================================================================

export const router = t.router;
export const middleware = t.middleware;

// =============================================================================
// INPUT VALIDATION SCHEMAS
// =============================================================================

export const schemas = {
  // Common
  uuid: z.string().uuid(),
  
  // Task
  createTask: z.object({
    title: z.string().min(1).max(255),
    description: z.string().min(1),
    price: z.number().int().positive(), // USD cents
    deadline: z.date().optional(),
    requirements: z.string().optional(),
    location: z.string().max(255).optional(),
    category: z.string().max(50).optional(),
    requires_proof: z.boolean().optional(),
    proof_instructions: z.string().optional(),
  }),
  
  // Escrow
  createPaymentIntent: z.object({
    taskId: z.string().uuid(),
  }),
  
  confirmFunding: z.object({
    escrowId: z.string().uuid(),
    stripePaymentIntentId: z.string(),
  }),
  
  releaseEscrow: z.object({
    escrowId: z.string().uuid(),
    stripeTransferId: z.string(),
  }),
  
  // Onboarding (from ONBOARDING_SPEC)
  submitCalibration: z.object({
    responses: z.array(z.object({
      question_id: z.string(),
      answer: z.union([z.string(), z.number(), z.boolean()]),
      time_to_answer_ms: z.number().int().positive(),
    })),
    session_metadata: z.object({
      start_time: z.date(),
      end_time: z.date(),
      device_type: z.string(),
      screen_width: z.number().int().positive(),
    }),
  }),
  
  confirmRole: z.object({
    selected_mode: z.enum(['worker', 'poster']),
    was_override: z.boolean(),
  }),
  
  lockPreferences: z.object({
    xp_visibility_rules: z.enum(['full', 'ledger', 'level-only']),
    trust_ui_density: z.enum(['compact', 'normal', 'detailed']),
    copy_tone_variant: z.enum(['formal', 'neutral', 'casual']),
  }),
};
