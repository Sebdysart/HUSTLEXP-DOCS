/**
 * HustleXP Database Client
 * 
 * PURPOSE: Single connection to Layer 0 (PostgreSQL)
 * AUTHORITY: This module connects to the constitutional schema.
 *            All invariants are enforced at the database level.
 * 
 * @see schema.sql for constitutional constraints
 * @see EXECUTION_INDEX.md for invariant mapping
 */

import { Pool, PoolClient, QueryResult } from 'pg';

// =============================================================================
// CONFIGURATION
// =============================================================================

const config = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  database: process.env.POSTGRES_DB || 'hustlexp',
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// =============================================================================
// CONNECTION POOL
// =============================================================================

let pool: Pool | null = null;

export function getPool(): Pool {
  if (!pool) {
    pool = new Pool(config);
    
    // Log connection errors
    pool.on('error', (err) => {
      console.error('[DB] Unexpected pool error:', err);
    });
  }
  return pool;
}

// =============================================================================
// QUERY HELPERS
// =============================================================================

/**
 * Execute a single query
 */
export async function query<T = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> {
  const start = Date.now();
  const result = await getPool().query<T>(text, params);
  const duration = Date.now() - start;
  
  if (process.env.LOG_QUERIES === 'true') {
    console.log('[DB] Query executed', { text: text.substring(0, 100), duration, rows: result.rowCount });
  }
  
  return result;
}

/**
 * Get a client for transaction use
 */
export async function getClient(): Promise<PoolClient> {
  return getPool().connect();
}

// =============================================================================
// TRANSACTION HELPERS
// =============================================================================

/**
 * Execute a function within a transaction
 * Automatically commits on success, rolls back on error
 * 
 * CRITICAL: All multi-step operations MUST use this.
 * The schema enforces invariants, but transactions ensure atomicity.
 */
export async function withTransaction<T>(
  fn: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * Execute a function with SERIALIZABLE isolation
 * Use for operations that must see a consistent snapshot
 */
export async function withSerializableTransaction<T>(
  fn: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await getClient();
  
  try {
    await client.query('BEGIN ISOLATION LEVEL SERIALIZABLE');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// =============================================================================
// ERROR HANDLING
// =============================================================================

/**
 * HustleXP error codes from schema.sql
 * These are raised by database triggers when invariants are violated
 */
export const DB_ERROR_CODES = {
  // Terminal state violations
  HX001: 'TERMINAL_STATE_VIOLATION (Task)',
  HX002: 'TERMINAL_STATE_VIOLATION (Escrow)',
  
  // Core invariant violations
  HX004: 'INV-4 (Escrow amount immutability)',
  HX101: 'INV-1 (XP requires RELEASED escrow)',
  HX102: 'XP ledger immutability',
  HX201: 'INV-2 (RELEASED requires COMPLETED task)',
  HX301: 'INV-3 (COMPLETED requires ACCEPTED proof)',
  HX401: 'INV-BADGE-2 (Badge delete attempt)',
  HX801: 'Admin action audit immutability',
} as const;

export type DBErrorCode = keyof typeof DB_ERROR_CODES;

/**
 * Check if a PostgreSQL error is a HustleXP invariant violation
 */
export function isInvariantViolation(error: any): error is { code: string; message: string } {
  return (
    error &&
    typeof error.code === 'string' &&
    error.code in DB_ERROR_CODES
  );
}

/**
 * Extract the HustleXP error code from a PostgreSQL error
 */
export function getHustleXPErrorCode(error: any): DBErrorCode | null {
  if (isInvariantViolation(error)) {
    return error.code as DBErrorCode;
  }
  return null;
}

// =============================================================================
// SHUTDOWN
// =============================================================================

export async function closePool(): Promise<void> {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

// =============================================================================
// HEALTH CHECK
// =============================================================================

export async function healthCheck(): Promise<boolean> {
  try {
    const result = await query('SELECT 1 as health');
    return result.rows[0]?.health === 1;
  } catch {
    return false;
  }
}

/**
 * Verify schema version matches expected
 */
export async function verifySchemaVersion(expected: string): Promise<boolean> {
  try {
    const result = await query<{ version: string }>(
      'SELECT version FROM schema_versions ORDER BY applied_at DESC LIMIT 1'
    );
    return result.rows[0]?.version === expected;
  } catch {
    return false;
  }
}
