/**
 * INV-2 Kill Test: RELEASED escrow requires COMPLETED task
 * 
 * PURPOSE: Prove that the database enforces INV-2
 *          This test MUST FAIL if INV-2 enforcement is broken
 * 
 * INVARIANT: RELEASED requires COMPLETED task
 * SPEC: PRODUCT_SPEC §2 (INV-2)
 * ENFORCEMENT: schema.sql trigger `escrow_released_requires_completed_task`
 * ERROR CODE: HX201
 * 
 * @see schema.sql:L842 for trigger
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

async function createTestTask(posterId: string, state: string = 'OPEN'): Promise<string> {
  const result = await pool.query(
    `INSERT INTO tasks (poster_id, title, description, price, state)
     VALUES ($1, 'Test Task', 'Test Description', 5000, $2)
     RETURNING id`,
    [posterId, state]
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

async function setTaskState(taskId: string, state: string): Promise<void> {
  // Direct update - bypasses normal state machine for testing
  await pool.query(
    `UPDATE tasks SET state = $2, requires_proof = FALSE WHERE id = $1`,
    [taskId, state]
  );
}

// =============================================================================
// INV-2 KILL TESTS
// =============================================================================

describe('INV-2: RELEASED escrow requires COMPLETED task', () => {
  
  /**
   * KILL TEST 1: Cannot release escrow when task is OPEN
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is OPEN', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-1@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * KILL TEST 2: Cannot release escrow when task is ACCEPTED
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is ACCEPTED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-2@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'ACCEPTED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * KILL TEST 3: Cannot release escrow when task is PROOF_SUBMITTED
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is PROOF_SUBMITTED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-3@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'PROOF_SUBMITTED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * KILL TEST 4: Cannot release escrow when task is DISPUTED
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is DISPUTED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-4@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'DISPUTED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * KILL TEST 5: Cannot release escrow when task is CANCELLED
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is CANCELLED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-5@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'CANCELLED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * KILL TEST 6: Cannot release escrow when task is EXPIRED
   * 
   * EXPECTED: HX201 error
   */
  it('MUST REJECT: release escrow when task is EXPIRED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-6@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'EXPIRED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    await expect(
      pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX201',
    });
  });

  /**
   * POSITIVE TEST: CAN release escrow when task IS COMPLETED
   * 
   * This is the ONLY valid case for escrow release
   * EXPECTED: Success
   */
  it('MUST ALLOW: release escrow when task IS COMPLETED', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-7@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'COMPLETED');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act
    const result = await pool.query(
      `UPDATE escrows SET state = 'RELEASED', released_at = NOW() 
       WHERE id = $1 RETURNING state`,
      [escrowId]
    );
    
    // Assert
    expect(result.rows[0].state).toBe('RELEASED');
  });

  /**
   * EDGE TEST: Cannot release already-released escrow
   * 
   * Even if task is COMPLETED, terminal escrow state is immutable
   * EXPECTED: No rows updated (terminal state guard)
   */
  it('MUST REJECT: re-release already RELEASED escrow', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-8@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    await setTaskState(taskId, 'COMPLETED');
    const escrowId = await createTestEscrow(taskId, 'RELEASED');
    
    // Act & Assert - terminal state trigger should fire
    await expect(
      pool.query(
        `UPDATE escrows SET stripe_transfer_id = 'tr_new' WHERE id = $1`,
        [escrowId]
      )
    ).rejects.toMatchObject({
      code: 'HX002', // Terminal state violation for escrow
    });
  });
});

// =============================================================================
// ERROR MESSAGE VERIFICATION
// =============================================================================

describe('INV-2: Error messages are actionable', () => {
  
  it('HX201 error message includes escrow ID and task state', async () => {
    // Arrange
    const posterId = await createTestUser('test-poster-msg@hustlexp.test');
    const taskId = await createTestTask(posterId, 'OPEN');
    const escrowId = await createTestEscrow(taskId, 'FUNDED');
    
    // Act & Assert
    try {
      await pool.query(
        `UPDATE escrows SET state = 'RELEASED' WHERE id = $1`,
        [escrowId]
      );
      expect.fail('Should have thrown HX201');
    } catch (error: any) {
      expect(error.code).toBe('HX201');
      expect(error.message).toContain('INV-2_VIOLATION');
      expect(error.message).toContain('COMPLETED'); // Mentions required state
    }
  });
});
