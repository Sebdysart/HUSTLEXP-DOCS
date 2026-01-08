# HustleXP Build Guide v1.0.0

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Governance:** This document defines execution order. Skipping steps is a build failure.

---

## §1. Purpose

This document answers one question:

**How do we build HustleXP without interpretation?**

It is not a tutorial. It is not documentation. It is the **execution contract**.

If this guide says "do X before Y," then doing Y before X is **wrong by definition**, regardless of whether it "works."

---

## §2. Build Phases

HustleXP is built in **strict phase order**. Each phase has gates. Gates cannot be skipped.

```
Phase 0: Schema Deployment
    ↓ [Gate: All triggers verified]
Phase 1: Backend Services
    ↓ [Gate: All invariant tests pass]
Phase 2: API Layer
    ↓ [Gate: All endpoints tested]
Phase 3: Frontend State
    ↓ [Gate: State machines match backend]
Phase 4: Frontend UI
    ↓ [Gate: ESLint + runtime guards pass]
Phase 5: Integration
    ↓ [Gate: E2E tests pass]
Phase 6: Deployment
    ↓ [Gate: Production verification]
DONE
```

**Rule:** You cannot begin Phase N+1 until Phase N gate passes.

---

## §3. Phase 0: Schema Deployment

### 3.1 What This Phase Does

Deploys `schema.sql` to PostgreSQL, establishing Layer 0 enforcement.

### 3.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| PostgreSQL 14+ | `psql --version` |
| Database created | `\l` shows database |
| Connection string | `DATABASE_URL` set |
| schema.sql accessible | File exists, readable |

### 3.3 Execution Steps

```bash
# Step 1: Connect to database
psql $DATABASE_URL

# Step 2: Apply schema
\i schema.sql

# Step 3: Verify version
SELECT * FROM schema_versions;
-- Must show: version = '1.0.0'
```

### 3.4 Verification Queries

Run **all** verification queries. Any failure = Phase 0 incomplete.

#### 3.4.1 Table Existence

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
  'users', 'tasks', 'escrows', 'proofs', 'proof_photos',
  'xp_ledger', 'trust_ledger', 'badges', 'disputes',
  'processed_stripe_events', 'ai_events', 'ai_jobs',
  'ai_proposals', 'ai_decisions', 'evidence',
  'admin_roles', 'admin_actions', 'schema_versions'
);
-- Must return: 18 rows
```

#### 3.4.2 Trigger Existence

```sql
SELECT tgname FROM pg_trigger 
WHERE tgname IN (
  'task_terminal_guard',
  'escrow_terminal_guard',
  'escrow_amount_immutable',
  'xp_requires_released_escrow',
  'xp_ledger_no_delete',
  'badge_no_delete',
  'escrow_released_requires_completed_task',
  'task_completed_requires_accepted_proof',
  'trust_tier_audit',
  'admin_actions_no_delete'
);
-- Must return: 10 rows (minimum core triggers)
```

#### 3.4.3 Invariant Enforcement Test

```sql
-- Test INV-1: XP without RELEASED escrow
-- This MUST fail with HX101
BEGIN;
INSERT INTO users (id, email, full_name, user_type) 
VALUES ('test-user', 'test@test.com', 'Test', 'worker');

INSERT INTO tasks (id, poster_id, title, description, price, state) 
VALUES ('test-task', 'test-user', 'Test', 'Test', 1000, 'OPEN');

INSERT INTO escrows (id, task_id, payer_id, payee_id, amount, state) 
VALUES ('test-escrow', 'test-task', 'test-user', 'test-user', 1000, 'FUNDED');

-- This should fail:
INSERT INTO xp_ledger (user_id, task_id, escrow_id, base_xp, effective_xp, 
  user_xp_before, user_xp_after, user_level_before, user_level_after, user_streak_at_award)
VALUES ('test-user', 'test-task', 'test-escrow', 100, 100, 0, 100, 1, 1, 0);
-- Expected: ERROR with SQLSTATE 'HX101'

ROLLBACK;
```

### 3.5 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| 18 tables exist | Query 3.4.1 |
| 10+ triggers exist | Query 3.4.2 |
| INV-1 enforced | Query 3.4.3 fails correctly |
| INV-2 enforced | Similar test for escrow release |
| INV-3 enforced | Similar test for task completion |
| Schema version recorded | `schema_versions` has entry |

**Gate Status:** ✅ PASS or ❌ FAIL (no partial)

---

## §4. Phase 1: Backend Services

### 4.1 What This Phase Does

Implements TypeScript services that orchestrate Layer 0 operations.

### 4.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 0 gate passed | All verification queries pass |
| Node.js 18+ | `node --version` |
| TypeScript configured | `tsconfig.json` exists |
| Database client installed | `pg` in package.json |

### 4.3 Service Implementation Order

Services must be implemented in this order due to dependencies:

```
1. db.ts (database client)
   ↓
2. types.ts (shared types)
   ↓
3. TaskService.ts
   ↓
4. EscrowService.ts (depends on TaskService for INV-2)
   ↓
5. ProofService.ts
   ↓
6. XPService.ts (depends on EscrowService for INV-1)
   ↓
7. TrustService.ts
   ↓
8. BadgeService.ts
   ↓
9. DisputeService.ts
   ↓
10. StripeWebhookHandler.ts
```

### 4.4 Service Requirements

Each service must:

1. **Use transactions** for multi-step operations
2. **Catch HX errors** and translate to user-friendly messages
3. **Never bypass** database constraints
4. **Log** all state transitions
5. **Return** `ServiceResult<T>` with success/failure

```typescript
type ServiceResult<T> = 
  | { success: true; data: T }
  | { success: false; error: string; code: string };
```

### 4.5 Kill Tests (Invariant Tests)

Before gate, **all kill tests must pass**.

Kill tests verify that the database rejects invalid operations.

#### 4.5.1 Required Kill Tests

| Test File | Invariant | Must Fail With |
|-----------|-----------|----------------|
| `inv-1.test.ts` | XP without RELEASED | HX101 |
| `inv-2.test.ts` | RELEASED without COMPLETED | HX201 |
| `inv-3.test.ts` | COMPLETED without ACCEPTED proof | HX301 |
| `inv-4.test.ts` | Escrow amount modification | HX401 |
| `inv-5.test.ts` | Duplicate XP award | 23505 |
| `terminal-task.test.ts` | Modify COMPLETED task | HX001 |
| `terminal-escrow.test.ts` | Modify RELEASED escrow | HX002 |
| `append-only.test.ts` | Delete XP/badge entry | HX102/HX501 |

#### 4.5.2 Kill Test Structure

Every kill test follows this pattern:

```typescript
describe('INV-X: [Invariant Name]', () => {
  it('MUST FAIL: [violation description]', async () => {
    // Setup: Create valid precondition state
    // Action: Attempt invalid operation
    // Assert: Specific error code thrown
    await expect(invalidOperation()).rejects.toMatchObject({
      code: 'HXXXX'
    });
  });

  it('MUST SUCCEED: [valid operation]', async () => {
    // Setup: Create valid precondition state
    // Action: Perform valid operation
    // Assert: Operation completes
    const result = await validOperation();
    expect(result.success).toBe(true);
  });
});
```

### 4.6 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| All 10 services implemented | Files exist with exports |
| All services use transactions | Code review |
| All kill tests pass | `npm test` exits 0 |
| INV-1 test: 8+ assertions | Test file review |
| INV-2 test: 8+ assertions | Test file review |
| No direct SQL in services | Only via db.ts |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §5. Phase 2: API Layer

### 5.1 What This Phase Does

Exposes services via tRPC endpoints with validation and auth.

### 5.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 1 gate passed | All kill tests pass |
| tRPC installed | `@trpc/server` in package.json |
| Zod installed | `zod` in package.json |
| Auth middleware ready | Firebase Admin configured |

### 5.3 Router Structure

```
src/routers/
├── index.ts (root router)
├── task.ts
├── escrow.ts
├── proof.ts
├── user.ts
├── dispute.ts
├── ai.ts (onboarding, evidence)
└── admin.ts
```

### 5.4 Endpoint Requirements

Each endpoint must:

1. **Validate input** with Zod schema
2. **Authenticate** request (except public endpoints)
3. **Authorize** action (user owns resource, etc.)
4. **Call service** (never direct DB access)
5. **Return typed response**

```typescript
// Example structure
export const taskRouter = router({
  create: protectedProcedure
    .input(createTaskSchema)
    .mutation(async ({ input, ctx }) => {
      // Auth: ctx.userId exists
      // Authz: N/A (any user can create)
      // Service: TaskService.create()
      return TaskService.create({
        ...input,
        poster_id: ctx.userId
      });
    }),
});
```

### 5.5 Required Endpoints

| Router | Endpoint | Method | Auth | Service |
|--------|----------|--------|------|---------|
| task | create | mutation | ✅ | TaskService.create |
| task | accept | mutation | ✅ | TaskService.accept |
| task | submitProof | mutation | ✅ | TaskService.submitProof |
| task | complete | mutation | ✅ | TaskService.complete |
| task | cancel | mutation | ✅ | TaskService.cancel |
| task | getById | query | ✅ | TaskService.getById |
| task | list | query | ✅ | TaskService.list |
| escrow | createIntent | mutation | ✅ | EscrowService.createPaymentIntent |
| escrow | release | mutation | ✅ | EscrowService.release |
| escrow | refund | mutation | ✅ | EscrowService.refund |
| proof | upload | mutation | ✅ | ProofService.upload |
| proof | review | mutation | ✅ | ProofService.review |
| user | getProfile | query | ✅ | UserService.getProfile |
| user | getXP | query | ✅ | XPService.getUserXP |
| dispute | create | mutation | ✅ | DisputeService.create |
| dispute | resolve | mutation | ✅ Admin | DisputeService.resolve |
| ai.onboarding | submit | mutation | ✅ | OnboardingService.submit |
| ai.onboarding | confirm | mutation | ✅ | OnboardingService.confirm |

### 5.6 Endpoint Tests

Each endpoint requires:

1. **Happy path test** — Valid input, expected output
2. **Auth test** — Unauthenticated request rejected
3. **Validation test** — Invalid input rejected with Zod error
4. **Error propagation test** — Service errors surface correctly

### 5.7 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| All 18+ endpoints implemented | Router files exist |
| All endpoints use services | No direct DB calls |
| Input validation on all mutations | Zod schemas defined |
| Auth middleware applied | Protected procedures used |
| Endpoint tests pass | `npm test:api` exits 0 |
| Error codes propagate | HX errors reach client |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §6. Phase 3: Frontend State

### 6.1 What This Phase Does

Implements frontend state machines that **mirror** backend state.

### 6.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 2 gate passed | All API tests pass |
| React Native configured | `react-native` installed |
| tRPC client installed | `@trpc/react-query` |
| State library chosen | XState or custom FSM |

### 6.3 State Machine Parity

Frontend state machines must **exactly match** backend definitions.

| Machine | Backend Source | Frontend File |
|---------|----------------|---------------|
| TaskStateMachine | TaskService states | `state/TaskStateMachine.ts` |
| EscrowStateMachine | EscrowService states | `state/EscrowStateMachine.ts` |
| ProofStateMachine | ProofService states | `state/ProofStateMachine.ts` |
| OnboardingStateMachine | ONBOARDING_SPEC | `state/OnboardingStateMachine.ts` |

### 6.4 State Machine Rules

1. **States must match exactly** — Same names, same terminal flags
2. **Transitions must match exactly** — Same guards, same targets
3. **No local-only states** — Every state exists on backend
4. **No optimistic transitions** — Wait for server confirmation

### 6.5 tRPC Client Setup

```typescript
// src/api/client.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from 'hustlexp-backend';

export const trpc = createTRPCReact<AppRouter>();
```

### 6.6 State Sync Pattern

```typescript
// Correct: Wait for server, then update local state
const completeTask = async (taskId: string) => {
  const result = await trpc.task.complete.mutate({ taskId });
  if (result.success) {
    setTaskState(result.data.state); // Server-confirmed
  } else {
    showError(result.error);
  }
};

// WRONG: Optimistic update
const completeTask = async (taskId: string) => {
  setTaskState('COMPLETED'); // NO! Not confirmed
  await trpc.task.complete.mutate({ taskId });
};
```

### 6.7 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| All 4 state machines exist | Files present |
| States match backend exactly | Diff comparison |
| Transitions match backend | Diff comparison |
| tRPC client configured | API calls work |
| No optimistic updates | Code review |
| State sync tests pass | `npm test:state` |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §7. Phase 4: Frontend UI

### 7.1 What This Phase Does

Implements screens and components that **express** state.

### 7.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 3 gate passed | State machines verified |
| UI_SPEC.md reviewed | Team acknowledges constraints |
| ESLint rules implemented | Custom rules in config |
| Component library chosen | (If using one) |

### 7.3 ESLint Rules Implementation

Implement all rules from UI_SPEC §8.1:

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'hustlexp/no-xp-color-outside-context': 'error',
    'hustlexp/no-money-color-decorative': 'error',
    'hustlexp/no-success-without-confirmation': 'error',
    'hustlexp/no-forbidden-animation': 'error',
    'hustlexp/max-animation-duration': 'warn',
    'hustlexp/no-shame-copy': 'error',
    'hustlexp/no-false-urgency': 'error',
    'hustlexp/badge-tier-material-match': 'error',
    'hustlexp/touch-target-minimum': 'error',
    'hustlexp/color-contrast-minimum': 'warn',
  }
};
```

### 7.4 Runtime Guards Implementation

Implement all guards from UI_SPEC §8.2:

```typescript
// src/guards/index.ts
export { AnimationContextGuard } from './AnimationContextGuard';
export { ReducedMotionGuard } from './ReducedMotionGuard';
export { FirstTimeAnimationGuard } from './FirstTimeAnimationGuard';
export { ColorContextGuard } from './ColorContextGuard';
export { StateConfirmationGuard } from './StateConfirmationGuard';
```

### 7.5 Screen Implementation Order

Implement in order of dependency:

```
1. Auth screens (Login, Signup, ForgotPassword)
   ↓
2. Onboarding screens (Calibration, RoleConfirmation, PreferenceLock)
   ↓
3. Tab screens (Home, Tasks, Wallet, Profile)
   ↓
4. Detail screens (TaskDetail, ProofSubmission, DisputeView)
   ↓
5. Modal screens (Confirmation, Error, Success)
```

### 7.6 Screen Requirements

Each screen must:

1. **Fetch state from server** (not local cache)
2. **Show loading state** during fetch
3. **Handle errors** gracefully
4. **Respect screen rules** from UI_SPEC §6
5. **Pass ESLint** with zero errors

### 7.7 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| ESLint rules implemented | 10 custom rules exist |
| Runtime guards implemented | 5 guard files exist |
| ESLint passes with 0 errors | `npm run lint` |
| All screens implemented | Files exist |
| Accessibility audit passes | 44×44 targets, contrast |
| No forbidden animations | Code review + guard logs |
| Screen context rules followed | UI_SPEC §6 audit |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §8. Phase 5: Integration

### 8.1 What This Phase Does

Verifies end-to-end flows work correctly.

### 8.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 4 gate passed | ESLint + guards pass |
| Test database available | Separate from production |
| Stripe test mode configured | Test keys in env |
| E2E test framework ready | Detox or similar |

### 8.3 Required E2E Tests

| Test | Flow | Assertions |
|------|------|------------|
| Happy Path | Post → Accept → Proof → Complete → Pay → XP | All states correct, XP awarded |
| Dispute Flow | Post → Accept → Proof → Reject → Dispute → Resolve | Escrow handled correctly |
| Cancellation | Post → Cancel | Escrow refunded, no XP |
| Expiration | Post → (timeout) → Expire | Escrow refunded, no XP |
| Onboarding | Start → Calibration → Role → Lock | User type set correctly |

### 8.4 E2E Test Structure

```typescript
describe('E2E: Happy Path', () => {
  it('completes full task lifecycle with XP award', async () => {
    // 1. Poster creates task
    const task = await createTask(posterUser);
    expect(task.state).toBe('OPEN');

    // 2. Worker accepts
    await acceptTask(workerUser, task.id);
    expect(await getTask(task.id).state).toBe('ACCEPTED');
    expect(await getEscrow(task.id).state).toBe('FUNDED');

    // 3. Worker submits proof
    await submitProof(workerUser, task.id, proofPhotos);
    expect(await getTask(task.id).state).toBe('PROOF_SUBMITTED');

    // 4. Poster approves
    await approveProof(posterUser, task.id);
    expect(await getTask(task.id).state).toBe('COMPLETED');

    // 5. Escrow released
    expect(await getEscrow(task.id).state).toBe('RELEASED');

    // 6. XP awarded
    const xp = await getXP(workerUser);
    expect(xp.total).toBeGreaterThan(0);
  });
});
```

### 8.5 Integration Verification

| Check | Method |
|-------|--------|
| Stripe webhooks work | Send test events |
| XP calculations correct | Compare ledger to expected |
| State sync correct | UI matches DB |
| Error propagation | Trigger errors, verify UI |
| Auth flows | Login/logout cycle |

### 8.6 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| Happy path E2E passes | Test exits 0 |
| Dispute flow E2E passes | Test exits 0 |
| Cancellation E2E passes | Test exits 0 |
| Onboarding E2E passes | Test exits 0 |
| Stripe integration verified | Test webhooks work |
| No console errors | Clean test logs |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §9. Phase 6: Deployment

### 9.1 What This Phase Does

Deploys to production with verification.

### 9.2 Prerequisites

| Requirement | Verification |
|-------------|--------------|
| Phase 5 gate passed | All E2E tests pass |
| Production database ready | Connection verified |
| Stripe live mode configured | Live keys ready |
| Monitoring configured | Logs, alerts |

### 9.3 Deployment Checklist

```
[ ] Schema deployed to production DB
[ ] Schema version verified (1.0.0)
[ ] All triggers verified in production
[ ] Backend deployed
[ ] Health check passing
[ ] API endpoints responding
[ ] Frontend deployed
[ ] App loads successfully
[ ] Auth flow works
[ ] Smoke test: Create task
[ ] Smoke test: Accept task
[ ] Smoke test: Submit proof
[ ] Stripe webhook verified
[ ] Error monitoring active
[ ] Performance baseline established
```

### 9.4 Production Verification Queries

Run against production database:

```sql
-- Verify schema version
SELECT * FROM schema_versions 
ORDER BY applied_at DESC LIMIT 1;
-- Must show 1.0.0

-- Verify trigger count
SELECT COUNT(*) FROM pg_trigger 
WHERE tgname LIKE '%guard%' 
   OR tgname LIKE '%immutable%'
   OR tgname LIKE '%requires%'
   OR tgname LIKE '%no_delete%';
-- Must be >= 10

-- Verify tables exist
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public';
-- Must be >= 18
```

### 9.5 Rollback Plan

If production verification fails:

1. **Immediate:** Route traffic to maintenance page
2. **Assess:** Identify failing component
3. **Rollback DB:** `\i schema_rollback.sql` (if exists)
4. **Rollback backend:** Deploy previous version
5. **Rollback frontend:** Deploy previous version
6. **Verify:** All checks pass
7. **Postmortem:** Document failure, fix, re-attempt

### 9.6 Gate Criteria

| Criterion | Verification |
|-----------|--------------|
| Production schema verified | Queries pass |
| Health checks passing | HTTP 200 |
| Auth flow works | Manual test |
| Task creation works | Manual test |
| Stripe webhook works | Test event |
| Monitoring active | Alerts configured |
| Rollback plan tested | Documented and rehearsed |

**Gate Status:** ✅ PASS or ❌ FAIL

---

## §10. Definition of Done

### 10.1 Phase Completion

A phase is **done** when:
1. All implementation complete
2. All tests pass
3. Gate criteria met
4. Gate explicitly marked ✅ PASS

A phase is **not done** if:
- Any test fails
- Any gate criterion unmet
- Gate not explicitly passed

### 10.2 Feature Completion

A feature is **done** when:
1. Backend service implemented with tests
2. API endpoint implemented with tests
3. Frontend state machine matches backend
4. UI screens implemented and pass ESLint
5. E2E test covers the flow
6. Documentation updated (EXECUTION_INDEX)

### 10.3 Bug Fix Completion

A bug fix is **done** when:
1. Root cause identified
2. Fix implemented
3. Regression test added
4. Original issue verified fixed
5. No new failures introduced

### 10.4 Invariant Completion

An invariant is **verified** when:
1. Database trigger exists
2. Kill test exists and passes
3. Kill test fails correctly (rejects invalid operation)
4. Kill test succeeds correctly (allows valid operation)
5. EXECUTION_INDEX updated with ✅

---

## §11. What Cannot Be Skipped

### 11.1 Absolute Requirements

These steps **cannot be skipped under any circumstance**:

| Step | Reason |
|------|--------|
| Schema deployment before services | Services depend on DB |
| Kill tests before Phase 1 gate | Invariants must be verified |
| ESLint rules before Phase 4 gate | UI violations compile silently |
| E2E tests before deployment | Integration failures are production failures |
| Production verification | "It works on my machine" ≠ production ready |

### 11.2 No Shortcuts

| Shortcut Attempt | Why It Fails |
|------------------|--------------|
| "We'll add tests later" | Untested code accumulates |
| "Skip kill tests, triggers exist" | Trigger logic may be wrong |
| "ESLint rules aren't critical" | UI violations ship silently |
| "Manual testing is enough" | Humans miss edge cases |
| "We'll fix it in production" | Production is not a test environment |

### 11.3 Phase Skip Prevention

The EXECUTION_INDEX must track:
- Gate status for each phase
- Date gate passed
- Who verified gate

If Phase N gate is not ✅ PASS, Phase N+1 work **must not begin**.

---

## §12. Continuous Verification

### 12.1 CI Pipeline Requirements

Every commit must run:

```yaml
steps:
  - name: Lint
    run: npm run lint
    # Must exit 0
    
  - name: Type Check
    run: npm run typecheck
    # Must exit 0
    
  - name: Unit Tests
    run: npm test
    # Must exit 0
    
  - name: Kill Tests
    run: npm run test:invariants
    # Must exit 0
    
  - name: API Tests
    run: npm run test:api
    # Must exit 0
```

### 12.2 Merge Requirements

PRs may only merge if:
1. All CI checks pass
2. Code review approved
3. EXECUTION_INDEX updated (if applicable)
4. No new ESLint warnings

### 12.3 Weekly Verification

Run weekly (automated):

```bash
# Verify all triggers still exist
./scripts/verify-triggers.sh

# Verify all kill tests still pass
npm run test:invariants

# Verify E2E still works
npm run test:e2e

# Verify production matches schema
./scripts/verify-production-schema.sh
```

---

## §13. Cross-Reference Matrix

| BUILD_GUIDE Section | PRODUCT_SPEC | ARCHITECTURE | UI_SPEC |
|---------------------|--------------|--------------|---------|
| §3 Schema Deployment | §2 (Invariants) | §2.0 (Layer 0) | — |
| §4 Backend Services | §3, §4, §5, §6 | §2.1 (Layer 1) | — |
| §5 API Layer | — | §2.2 (Layer 2) | — |
| §6 Frontend State | §3, §4 | §2.4 (Layer 4) | — |
| §7 Frontend UI | — | §2.5 (Layer 5) | §1-§11 |
| §8 Integration | Full flow | Full stack | Full rules |

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial execution contract |

---

**END OF BUILD_GUIDE v1.0.0**
