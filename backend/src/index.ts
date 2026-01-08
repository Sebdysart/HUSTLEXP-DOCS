/**
 * HustleXP Backend Entry Point
 * 
 * PURPOSE: Initialize database, configure tRPC, expose API
 * AUTHORITY: Layer 2 (API) - coordinates Layer 1 (Services)
 * 
 * @see EXECUTION_INDEX.md for implementation status
 */

import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { router } from './trpc.js';
import { getPool, healthCheck, verifySchemaVersion, closePool } from './db.js';
import { escrowRouter } from './routers/escrow.js';

// =============================================================================
// APP ROUTER
// =============================================================================

export const appRouter = router({
  escrow: escrowRouter,
  // TODO: Add more routers as implemented
  // task: taskRouter,
  // onboarding: onboardingRouter,
  // evidence: evidenceRouter,
  // user: userRouter,
});

export type AppRouter = typeof appRouter;

// =============================================================================
// SERVER
// =============================================================================

const PORT = parseInt(process.env.PORT || '3000');
const SCHEMA_VERSION = '1.0.0';

async function main() {
  console.log('[SERVER] Starting HustleXP Backend...');
  
  // Verify database connection
  const dbHealthy = await healthCheck();
  if (!dbHealthy) {
    console.error('[SERVER] ❌ Database connection failed');
    process.exit(1);
  }
  console.log('[SERVER] ✅ Database connected');
  
  // Verify schema version
  const schemaValid = await verifySchemaVersion(SCHEMA_VERSION);
  if (!schemaValid) {
    console.error(`[SERVER] ❌ Schema version mismatch. Expected: ${SCHEMA_VERSION}`);
    console.error('[SERVER] Run: npm run db:migrate');
    process.exit(1);
  }
  console.log(`[SERVER] ✅ Schema version: ${SCHEMA_VERSION}`);
  
  // Create HTTP server
  const server = createHTTPServer({
    router: appRouter,
    createContext: () => ({
      db: getPool(),
      // Auth middleware will set userId/sessionId
    }),
  });
  
  server.listen(PORT);
  console.log(`[SERVER] ✅ Listening on http://localhost:${PORT}`);
  console.log('[SERVER] Ready to receive requests');
}

// =============================================================================
// GRACEFUL SHUTDOWN
// =============================================================================

async function shutdown() {
  console.log('[SERVER] Shutting down...');
  await closePool();
  console.log('[SERVER] Database connections closed');
  process.exit(0);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// =============================================================================
// START
// =============================================================================

main().catch((error) => {
  console.error('[SERVER] Fatal error:', error);
  process.exit(1);
});
