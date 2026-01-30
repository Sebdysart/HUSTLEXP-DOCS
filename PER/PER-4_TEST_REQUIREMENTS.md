# PER-4: DETERMINISTIC TEST HARNESS

**STATUS: MANDATORY TEST COVERAGE**
**GATE TYPE: HARD**
**PURPOSE: Tests that fail when constraints are removed**

---

## THE RULE

> Every invariant must have tests that fail when the constraint is removed.
> If removing a constraint doesn't break a test, the test is useless.
> Tests prove the system works. Kill tests prove the constraints matter.

---

## REQUIRED TEST TYPES

### 1. Invariant Tests (CANNOT SKIP)

**Minimum count: 24 tests** (4-5 per core financial invariant)

**Purpose:** Prove that invariants are enforced

```typescript
describe('INV-1: XP requires released escrow', () => {
  it('MUST REJECT XP award when escrow state is PENDING', async () => {
    const escrow = await createEscrow({ state: 'PENDING' });
    await expect(
      awardXP({ escrowId: escrow.id })
    ).rejects.toThrow('HX101');
  });

  it('MUST REJECT XP award when escrow state is FUNDED', async () => {
    const escrow = await createEscrow({ state: 'FUNDED' });
    await expect(
      awardXP({ escrowId: escrow.id })
    ).rejects.toThrow('HX101');
  });

  it('MUST ALLOW XP award when escrow state is RELEASED', async () => {
    const escrow = await createEscrow({ state: 'RELEASED' });
    const result = await awardXP({ escrowId: escrow.id });
    expect(result.success).toBe(true);
  });

  it('MUST create ledger entry on successful XP award', async () => {
    const escrow = await createEscrow({ state: 'RELEASED' });
    await awardXP({ escrowId: escrow.id });
    const entries = await db.xp_ledger.findMany({ where: { escrow_id: escrow.id } });
    expect(entries.length).toBe(1);
  });
});
```

---

### 2. Kill Tests (Prove Constraints Matter)

**Purpose:** Verify that tests fail if constraints are removed

```typescript
describe('Kill Test: INV-4 escrow amount immutable', () => {
  it('MUST FAIL if constraint is removed', async () => {
    // This test exists to verify the constraint matters
    // If this test passes, the constraint can be safely removed
    // If this test fails, the constraint is protecting something

    const escrow = await createEscrow({ amount: 100 });

    // Attempt to modify amount (should be blocked)
    await expect(
      db.escrows.update({
        where: { id: escrow.id },
        data: { amount: 50 }
      })
    ).rejects.toThrow('HX401');

    // Verify amount unchanged
    const updated = await db.escrows.findUnique({ where: { id: escrow.id } });
    expect(updated.amount).toBe(100);
  });

  it('MUST detect if constraint is accidentally removed', async () => {
    // Query the database to verify constraint exists
    const constraints = await db.$queryRaw`
      SELECT conname FROM pg_constraint
      WHERE conname = 'escrow_amount_immutable'
    `;
    expect(constraints.length).toBeGreaterThan(0);
  });
});
```

---

### 3. Idempotency Tests

**Purpose:** Same operation produces same result when repeated

```typescript
describe('Idempotency', () => {
  it('MUST produce same result when XP award called twice', async () => {
    const escrow = await createEscrow({ state: 'RELEASED' });

    // First call succeeds
    const result1 = await awardXP({ escrowId: escrow.id });
    expect(result1.success).toBe(true);

    // Second call should either succeed with same result or fail gracefully
    const result2 = await awardXP({ escrowId: escrow.id });

    // Only ONE ledger entry exists (INV-5)
    const entries = await db.xp_ledger.findMany({
      where: { escrow_id: escrow.id }
    });
    expect(entries.length).toBe(1);
  });

  it('MUST produce same result when escrow release called twice', async () => {
    const task = await createTask({ state: 'COMPLETED' });
    const escrow = await createEscrow({ taskId: task.id, state: 'FUNDED' });

    await releaseEscrow({ escrowId: escrow.id });
    await releaseEscrow({ escrowId: escrow.id }); // Should be no-op

    const updated = await db.escrows.findUnique({ where: { id: escrow.id } });
    expect(updated.state).toBe('RELEASED');
  });
});
```

---

### 4. Permission Boundary Tests

**Purpose:** Layer violations are rejected

```typescript
describe('Permission Boundaries', () => {
  it('MUST REJECT frontend-computed XP values', async () => {
    // Frontend cannot specify XP amount
    await expect(
      api.xp.award.mutate({
        escrowId: 'valid-escrow',
        amount: 100 // Frontend trying to set amount
      })
    ).rejects.toThrow(); // Amount must be server-computed
  });

  it('MUST REJECT direct xp_ledger INSERT from application', async () => {
    // Application cannot bypass XPService
    await expect(
      db.xp_ledger.create({
        data: {
          user_id: 'user-1',
          escrow_id: 'escrow-1',
          amount: 100
        }
      })
    ).rejects.toThrow('HX101'); // Trigger checks escrow state
  });

  it('MUST REJECT AI writing to ledger', async () => {
    // AI has no write access
    const aiService = new AIService({ writeAccess: false });
    await expect(
      aiService.directWrite('xp_ledger', { amount: 100 })
    ).rejects.toThrow(); // AI cannot write
  });
});
```

---

### 5. Failure-Path Tests

**Purpose:** Partial failures roll back cleanly

```typescript
describe('Failure Paths', () => {
  it('MUST rollback on partial failure during escrow release', async () => {
    const task = await createTask({ state: 'COMPLETED' });
    const escrow = await createEscrow({ taskId: task.id, state: 'FUNDED' });

    const initialEscrowState = escrow.state;

    // Simulate failure during release
    jest.spyOn(stripeService, 'transfer').mockRejectedValue(new Error('Stripe error'));

    await expect(
      releaseEscrow({ escrowId: escrow.id })
    ).rejects.toThrow('Stripe error');

    // Verify rollback - escrow state unchanged
    const updated = await db.escrows.findUnique({ where: { id: escrow.id } });
    expect(updated.state).toBe(initialEscrowState);

    // No XP was awarded
    const xpEntries = await db.xp_ledger.findMany({
      where: { escrow_id: escrow.id }
    });
    expect(xpEntries.length).toBe(0);
  });

  it('MUST rollback on transaction timeout', async () => {
    // Simulate long-running transaction that times out
    const initialState = await getSystemState();

    await expect(
      executeWithTimeout(longRunningOperation, 1000)
    ).rejects.toThrow('Timeout');

    const finalState = await getSystemState();
    expect(finalState).toEqual(initialState);
  });
});
```

---

### 6. State Machine Tests

**Purpose:** State transitions follow the machine

```typescript
describe('Task State Machine', () => {
  it('MUST allow OPEN → ACCEPTED transition', async () => {
    const task = await createTask({ state: 'OPEN' });
    const result = await acceptTask({ taskId: task.id, hustlerId: 'hustler-1' });
    expect(result.state).toBe('ACCEPTED');
  });

  it('MUST REJECT OPEN → COMPLETED transition (skips steps)', async () => {
    const task = await createTask({ state: 'OPEN' });
    await expect(
      completeTask({ taskId: task.id })
    ).rejects.toThrow(); // Cannot skip ACCEPTED → WORKING
  });

  it('MUST REJECT any transition from terminal state', async () => {
    const task = await createTask({ state: 'COMPLETED' });
    await expect(
      db.tasks.update({ where: { id: task.id }, data: { state: 'OPEN' } })
    ).rejects.toThrow(); // Terminal states are final
  });
});
```

---

## TEST RULES

### NO MOCKS for Critical Systems

```typescript
// ❌ FORBIDDEN: Mocking money operations
jest.mock('./EscrowService', () => ({
  release: jest.fn().mockResolvedValue({ success: true })
}));

// ❌ FORBIDDEN: Mocking auth
jest.mock('./AuthService', () => ({
  verify: () => true
}));

// ❌ FORBIDDEN: Mocking database state
const mockDb = { escrows: { state: 'RELEASED' } };

// ✅ REQUIRED: Real test database
const testDb = await setupTestDatabase();
await testDb.escrows.create({ data: { state: 'RELEASED', ... } });
```

### Tests MUST Use Real Database

```typescript
// Setup
beforeAll(async () => {
  testDb = await createTestDatabase();
  await runMigrations(testDb);
  await seedTestData(testDb);
});

// Cleanup
afterEach(async () => {
  await testDb.truncateAll();
});

afterAll(async () => {
  await testDb.destroy();
});
```

### Tests MUST Fail If Constraints Removed

```typescript
// This test verifies that the constraint matters
it('MUST FAIL if INV-4 constraint is removed', async () => {
  // Temporarily remove constraint (in test only)
  await testDb.$executeRaw`
    ALTER TABLE escrows DROP CONSTRAINT escrow_amount_immutable
  `;

  try {
    // Now the forbidden operation "succeeds"
    await testDb.escrows.update({
      where: { id: escrowId },
      data: { amount: 0 }
    });

    // But system should detect inconsistency
    await expect(
      validateSystemConsistency()
    ).rejects.toThrow('INCONSISTENT_STATE');
  } finally {
    // Restore constraint
    await testDb.$executeRaw`
      ALTER TABLE escrows ADD CONSTRAINT escrow_amount_immutable ...
    `;
  }
});
```

---

## COVERAGE REQUIREMENTS

| System | Minimum Coverage | Rationale |
|--------|-----------------|-----------|
| Invariant enforcement | 100% | If not tested, it's not enforced |
| Money operations | 95% | Financial integrity |
| Auth/permissions | 95% | Security critical |
| API endpoints | 80% | Contract validation |
| Services | 90% | Business logic |
| UI components | 70% | Display logic |

---

## TEST CATEGORIES BY FILE

| File Pattern | Required Tests |
|--------------|----------------|
| `*Service.ts` | Unit + integration + invariant |
| `*Router.ts` | API contract + permission boundary |
| `schema.sql` | Trigger tests + constraint tests |
| `*Screen.tsx` | Render + props + loading states |

---

## TEST NAMING CONVENTION

```typescript
// Pattern: MUST [action] when [condition]
it('MUST REJECT XP award when escrow not released', ...);
it('MUST ALLOW task acceptance when user is eligible', ...);
it('MUST rollback on partial failure', ...);
it('MUST log audit entry on admin action', ...);
```

---

## BEFORE MERGE CHECKLIST

```
[ ] All invariant tests pass
[ ] Kill tests confirm constraints matter
[ ] Idempotency tests pass
[ ] Permission boundary tests pass
[ ] Failure-path tests pass
[ ] Coverage thresholds met
[ ] No mocks for critical systems
[ ] Real database used in tests
[ ] New code has corresponding tests
[ ] Modified code has updated tests
```

---

**Tests prove it works.**
**Kill tests prove it matters.**
**Without both, you have hope, not confidence.**
