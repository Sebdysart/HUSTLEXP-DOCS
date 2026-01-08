/**
 * INV-1 Kill Test: XP requires RELEASED escrow
 * 
 * PURPOSE: Prove that the database enforces INV-1
 *          This test MUST FAIL if INV-1 enforcement is broken
 * 
 * INVARIANT: XP cannot be awarded unless escrow is RELEASED
 * SPEC: PRODUCT_SPEC §2 (INV-1)
 * ENFORCEMENT: schema.sql trigger `xp_requires_released_escrow`
 * ERROR CODE: HX101
 * 
 * @see schema.sql:L391 for trigger
 * @see EXECUTION_INDEX.md Section 3.1
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { Pool } from 'pg';

// =============================================================================
// TEST DATABASE SETUP
// =============================================================================

const TEST_DB_CONFIG = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  database: process.env.POSTGRES_TEST_DB || 'hustlexp_test',
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
};

let pool: Pool;

beforeAll(async () => {
  pool = new Pool(TEST_DB_CONFIG);
  
  // Verify we're connected to test database
  const result = await pool.query('SELECT current_database()');
  const dbName = result.rows[0].current_database;
  
  if (!dbName.includes('test')) {
    throw new Error(`SAFETY: Refusing to run tests on non-test database: ${dbName}`);
  }
});

afterAll(async () => {
  await pool.end();
});

beforeEach(async () => {
  // Clean up test data in correct order (respect foreign keys)
  await pool.query('DELETE FROM xp_ledger');
  await pool.query('DELETE FROM proofs');
  await pool.query('DELETE FROM escrows');
  await pool.query('DELETE FROM tasks');
  await pool.query('DELETE FROM users WHERE email LIKE $1', ['test-%@hustlexp.test']);
});

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

async function createTestUser(email: string): Promise<string> {
  const result = await pool.query(
    `INSERT INTO users (email, full_name, default_mode)
     VALUES ($1, $2, 'worker')
     RETURNING id`,
    [email, 'Test User']
  );
  return result.rows[0].id;
}

async function createTestTask(posterId: string): Promise<string> {
  const result = await pool.query(
    `INSERT INTO tasks (poster_id, title, description, price, state, requires_proof)
     VALUES ($1, 'Test Task', 'Test Description', 5000, 'COMPLETED', FALSE)
     RETURNING id`,
    [posterId]
  );
  return result.rows[0].id;
}

async function createTestEscrow(taskId: string, state: string = 'PENDING'): Promise<string> {
  const result = await pool.query(
    `INSERT INTO escrows (task_id, amount, state)
     VALUES ($1, 5000, $2)
     RETURNING id`,
    [taskId, state]
  );
  return result.rows[0].id;
}

async function attemptXPAward(
  userId: string, 
  taskId: string, 
  escrowId: string
): Promise<void> {
  await pool.query(
    `INSERT INTO xp_ledger (
      user_id, task_id, escrow_id, base_xp, effective_xp,
      user_xp_before, user_xp_after, user_level_before, user_level_after, user_streak_at_award
    ) VALUES ($1, $2, $3, 100, 100, 0, 100, 1, 1, 0)`,
    [userId, taskId, escrowId]
  );
}

// =============================================================================
// INV-1 KILL TESTS
// =============================================================================

describe('INV-1: XP requires RELEASED escrow', () => {
  
  /**
   * KILL TEST 1: Cannot award XP when escrow is PENDING
   * 
   * EXPECTED: HX101 error
   */
  it('MUST REJECT: XP award when escrow is PENDING', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-1@hustlexp.test');
    const workerId = await createTestUser('test-worker-1@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'PENDING');
    
    // Act & Assert
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: 'HX101',
    });
  });

  /**
   * KILL TEST 2: Cannot award XP when escrow is FUNDED
   * 
   * EXPECTED: HX101 error
   */
  it('MUST REJECT: XP award when escrow is FUNDED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-2@hustlexp.test');
    const workerId = await createTestUser('test-worker-2@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: 'HX101',
    });
  });

  /**
   * KILL TEST 3: Cannot award XP when escrow is LOCKED_DISPUTE
   * 
   * EXPECTED: HX101 error
   */
  it('MUST REJECT: XP award when escrow is LOCKED_DISPUTE', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-3@hustlexp.test');
    const workerId = await createTestUser('test-worker-3@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'LOCKED_DISPUTE');
    
    // Act & Assert
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: 'HX101',
    });
  });

  /**
   * KILL TEST 4: Cannot award XP when escrow is REFUNDED
   * 
   * EXPECTED: HX101 error
   */
  it('MUST REJECT: XP award when escrow is REFUNDED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-4@hustlexp.test');
    const workerId = await createTestUser('test-worker-4@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'REFUNDED');
    
    // Act & Assert
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: 'HX101',
    });
  });

  /**
   * KILL TEST 5: Cannot award XP when escrow is REFUND_PARTIAL
   * 
   * EXPECTED: HX101 error
   */
  it('MUST REJECT: XP award when escrow is REFUND_PARTIAL', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-5@hustlexp.test');
    const workerId = await createTestUser('test-worker-5@hustlexp.test');
    const taskId = await createTestTask(posterId);
    
    // Create partial refund escrow (needs amounts that sum to total)
    const result = await pool.query(
      `INSERT INTO escrows (task_id, amount, state, refund_amount, release_amount)
       VALUES ($1, 5000, 'REFUND_PARTIAL', 2500, 2500)
       RETURNING id`,
      [taskId]
    );
    const escrowId = result.rows[0].id;
    
    // Act & Assert
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: 'HX101',
    });
  });

  /**
   * POSITIVE TEST: CAN award XP when escrow IS RELEASED
   * 
   * This is the ONLY valid case for XP award
   * EXPECTED: Success
   */
  it('MUST ALLOW: XP award when escrow IS RELEASED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-6@hustlexp.test');
    const workerId = await createTestUser('test-worker-6@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'RELEASED');
    
    // Act - should succeed
    await attemptXPAward(workerId, taskId, escrowId);
    
    // Assert - verify XP was recorded
    const result = await pool.query(
      'SELECT * FROM xp_ledger WHERE escrow_id = $1',
      [escrowId]
    );
    expect(result.rows.length).toBe(1);
    expect(result.rows[0].effective_xp).toBe(100);
  });
});

// =============================================================================
// INV-5 KILL TESTS (XP idempotency)
// =============================================================================

describe('INV-5: XP is idempotent per escrow', () => {
  
  /**
   * KILL TEST: Cannot award XP twice for same escrow
   * 
   * EXPECTED: Unique constraint violation
   */
  it('MUST REJECT: duplicate XP award for same escrow', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-dup@hustlexp.test');
    const workerId = await createTestUser('test-worker-dup@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'RELEASED');
    
    // First award - should succeed
    await attemptXPAward(workerId, taskId, escrowId);
    
    // Second award - should fail with unique constraint
    await expect(
      attemptXPAward(workerId, taskId, escrowId)
    ).rejects.toMatchObject({
      code: '23505', // PostgreSQL unique violation
    });
  });

  /**
   * POSITIVE TEST: CAN award XP for different escrows
   * 
   * Same user, different tasks/escrows should all succeed
   * EXPECTED: Success for each
   */
  it('MUST ALLOW: XP awards for different escrows', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-multi@hustlexp.test');
    const workerId = await createTestUser('test-worker-multi@hustlexp.test');
    
    // Create multiple tasks and escrows
    const taskId1 = await createTestTask(posterId);
    const taskId2 = await createTestTask(posterId);
    const escrowId1 = await createTestEscrow(taskId1, 'RELEASED');
    const escrowId2 = await createTestEscrow(taskId2, 'RELEASED');
    
    // Award XP for both - should succeed
    await attemptXPAward(workerId, taskId1, escrowId1);
    await attemptXPAward(workerId, taskId2, escrowId2);
    
    // Assert - both recorded
    const result = await pool.query(
      'SELECT COUNT(*) as count FROM xp_ledger WHERE user_id = $1',
      [workerId]
    );
    expect(parseInt(result.rows[0].count)).toBe(2);
  });
});

// =============================================================================
// XP LEDGER IMMUTABILITY
// =============================================================================

describe('XP Ledger: Append-only enforcement', () => {
  
  /**
   * KILL TEST: Cannot delete XP ledger entries
   * 
   * EXPECTED: HX102 error
   */
  it('MUST REJECT: deletion of XP ledger entry', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-del@hustlexp.test');
    const workerId = await createTestUser('test-worker-del@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'RELEASED');
    
    await attemptXPAward(workerId, taskId, escrowId);
    
    // Get the entry ID
    const entry = await pool.query(
      'SELECT id FROM xp_ledger WHERE escrow_id = $1',
      [escrowId]
    );
    const entryId = entry.rows[0].id;
    
    // Attempt delete - should fail
    await expect(
      pool.query('DELETE FROM xp_ledger WHERE id = $1', [entryId])
    ).rejects.toMatchObject({
      code: 'HX102',
    });
  });
});

// =============================================================================
// ERROR MESSAGE VERIFICATION
// =============================================================================

describe('INV-1: Error messages are actionable', () => {
  
  it('HX101 error message includes escrow ID and current state', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-msg@hustlexp.test');
    const workerId = await createTestUser('test-worker-msg@hustlexp.test');
    const taskId = await createTestTask(posterId);
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    try {
      await attemptXPAward(workerId, taskId, escrowId);
      expect.fail('Should have thrown HX101');
    } catch (error: any) {
      expect(error.code).toBe('HX101');
      expect(error.message).toContain('INV-1_VIOLATION');
      expect(error.message).toContain('RELEASED'); // Mentions required state
      expect(error.message).toContain('FUNDED'); // Mentions current state
    }
  });
});
