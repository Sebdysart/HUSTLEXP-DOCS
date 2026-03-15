# Domain-Based Backend Reorganization — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add role-based tRPC procedures (`hustlerProcedure`, `posterProcedure`) and apply them to all 49 routers, then reorganize routers/index.ts by domain. Zero functional changes to the public API surface.

**Architecture:** The `User` type already contains `default_mode: UserMode` (`'worker' | 'poster'`), and `createContext` does `SELECT * FROM users` — so `ctx.user.default_mode` is available at zero cost. We add two middleware procedures that check this field, then swap `protectedProcedure` for the role-specific variant on every procedure that should be guarded.

**Tech Stack:** tRPC v11, Zod, Vitest, Hono

**Risk Assessment:**
- Router tests mock at the *service* level (call `TaskService.getById()` directly), not through tRPC — so role guard changes don't break them
- The `trpc.test.ts` already uses `default_mode: 'worker'` — role procedures for Hustler work immediately
- Poster procedure tests will need mock user with `default_mode: 'poster'`
- iOS app sees zero changes — same procedure names, same paths

---

## Phase 1: Role Enforcement (High Value, Low Risk)

### Task 1: Add `hustlerProcedure` and `posterProcedure` to `trpc.ts`

**Files:**
- Modify: `backend/src/trpc.ts:148-185`
- Test: `backend/tests/unit/trpc.test.ts`

**Step 1: Add the role middleware and exports to trpc.ts**

After the existing `isAdmin` middleware (line 183-185), add:

```typescript
// Middleware: require Hustler role (default_mode = 'worker')
const isHustler = t.middleware(async ({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Authentication required',
    });
  }
  if (ctx.user.default_mode !== 'worker') {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'Hustler access required',
    });
  }
  return next({ ctx: { ...ctx, user: ctx.user } });
});

export const hustlerProcedure = t.procedure.use(isHustler);

// Middleware: require Poster role (default_mode = 'poster')
const isPoster = t.middleware(async ({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Authentication required',
    });
  }
  if (ctx.user.default_mode !== 'poster') {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'Poster access required',
    });
  }
  return next({ ctx: { ...ctx, user: ctx.user } });
});

export const posterProcedure = t.procedure.use(isPoster);
```

**Step 2: Add tests for role procedures**

Add to `backend/tests/unit/trpc.test.ts`:

```typescript
describe('hustlerProcedure', () => {
  it('should allow worker role', async () => {
    // mock user has default_mode: 'worker' — should pass
    // test via importing hustlerProcedure and creating a test router
  });

  it('should reject poster role', async () => {
    // mock user with default_mode: 'poster' — should throw FORBIDDEN
  });

  it('should reject unauthenticated', async () => {
    // null user — should throw UNAUTHORIZED
  });
});

describe('posterProcedure', () => {
  it('should allow poster role', async () => {
    // mock user with default_mode: 'poster' — should pass
  });

  it('should reject worker role', async () => {
    // mock user with default_mode: 'worker' — should throw FORBIDDEN
  });
});
```

**Step 3: Run tests**

```bash
npx vitest run backend/tests/unit/trpc.test.ts
```

**Step 4: Commit**

```bash
git add backend/src/trpc.ts backend/tests/unit/trpc.test.ts
git commit -m "feat: add hustlerProcedure and posterProcedure role guards to tRPC layer"
```

---

### Task 2: Apply role guards to `task.ts` (the biggest mixed router)

**Files:**
- Modify: `backend/src/routers/task.ts`

**Procedure classification (from audit):**

| Procedure | Current | Target | Reason |
|-----------|---------|--------|--------|
| `getById` | protectedProcedure | protectedProcedure | Both roles view tasks |
| `getState` | protectedProcedure | protectedProcedure | Both roles confirm state |
| `listByPoster` | protectedProcedure | posterProcedure | Poster lists own posted tasks |
| `listByWorker` | protectedProcedure | hustlerProcedure | Worker lists own accepted tasks |
| `listOpen` | protectedProcedure | hustlerProcedure | Feed for workers to discover tasks |
| `create` | protectedProcedure | posterProcedure | Only posters create tasks |
| `accept` | protectedProcedure | hustlerProcedure | Worker accepts task |
| `start` | protectedProcedure | hustlerProcedure | Worker begins task |
| `getProof` | protectedProcedure | protectedProcedure | Both roles view proof |
| `submitProof` | protectedProcedure | hustlerProcedure | Worker submits proof |
| `reviewProof` | protectedProcedure | posterProcedure | Poster reviews proof |
| `complete` | protectedProcedure | posterProcedure | Poster marks complete |
| `cancel` | protectedProcedure | posterProcedure | Poster cancels task |
| `applyForTask` | protectedProcedure | hustlerProcedure | Worker applies for task |
| `listApplicants` | protectedProcedure | posterProcedure | Poster views applicants |
| `assignWorker` | protectedProcedure | posterProcedure | Poster selects worker |
| `rejectApplicant` | protectedProcedure | posterProcedure | Poster rejects applicant |
| `withdrawApplication` | protectedProcedure | hustlerProcedure | Worker withdraws application |

**Step 1: Update import**

```typescript
// Change line 10 from:
import { router, protectedProcedure, Schemas } from '../trpc.js';
// To:
import { router, protectedProcedure, hustlerProcedure, posterProcedure, Schemas } from '../trpc.js';
```

**Step 2: Replace procedure types**

Replace `protectedProcedure` with `hustlerProcedure` on lines: 120 (listByWorker), 153 (listOpen), 211 (accept), 234 (start), 294 (submitProof), 512 (applyForTask), 696 (withdrawApplication).

Replace `protectedProcedure` with `posterProcedure` on lines: 81 (listByPoster), 175 (create), 359 (reviewProof), 443 (complete), 471 (cancel), 564 (listApplicants), 601 (assignWorker), 660 (rejectApplicant).

Keep `protectedProcedure` on: 27 (getById), 47 (getState), 265 (getProof).

**Step 3: Run tests**

```bash
npx vitest run backend/tests/integration/routers/task-router.test.ts
```

**Step 4: Commit**

```bash
git add backend/src/routers/task.ts
git commit -m "feat(task): apply hustler/poster role guards to all task procedures"
```

---

### Task 3: Apply role guards to `squad.ts` (second mixed router)

**Files:**
- Modify: `backend/src/routers/squad.ts`

**Procedure classification:**

| Procedure | Target | Reason |
|-----------|--------|--------|
| `create` | posterProcedure | Organizer creates squad |
| `listMine` | protectedProcedure | Both roles can see their squads |
| `getById` | protectedProcedure | Both roles view squad details |
| `invite` | posterProcedure | Organizer invites |
| `respondToInvite` | hustlerProcedure | Worker responds |
| `listInvites` | hustlerProcedure | Worker views invites |
| `leave` | hustlerProcedure | Worker leaves |
| `disband` | posterProcedure | Organizer disbands |
| `createTeamTask` | posterProcedure | Organizer creates task |
| `listTasks` | protectedProcedure | Both roles view tasks |
| `getTeamTask` | protectedProcedure | Both roles view details |
| `startTeamTask` | posterProcedure | Organizer starts |
| `withdrawFromTeamTask` | hustlerProcedure | Worker withdraws |
| `acceptTask` | hustlerProcedure | Worker accepts |
| `leaderboard` | protectedProcedure | Both roles view |

**Step 1: Update import**

```typescript
import { router, protectedProcedure, hustlerProcedure, posterProcedure, Schemas } from '../trpc.js';
```

**Step 2: Replace procedure types per table above**

**Step 3: Run tests**

```bash
npx vitest run backend/tests/integration/routers/squad-procedures.test.ts
```

**Step 4: Commit**

```bash
git add backend/src/routers/squad.ts
git commit -m "feat(squad): apply hustler/poster role guards to squad procedures"
```

---

### Task 4: Apply role guards to all Hustler-only routers

**Files to modify (all procedures → `hustlerProcedure`):**

| Router File | Procedure Count | Notes |
|-------------|-----------------|-------|
| `instant.ts` | 4 | listAvailable, accept, dismiss, metrics |
| `taskDiscovery.ts` | 11 | browseTasks, getFeed, search, etc. |
| `live.ts` | 3 | toggle, getStatus, listBroadcasts |
| `stripeConnect.ts` | 11 | All — worker Stripe onboarding |
| `xpTax.ts` | 4 | getTaxStatus, getTaxHistory, etc. |
| `skills.ts` | 3 | listSkills, addSkills, removeSkill |
| `referral.ts` | 3 | generateCode, submitCode, getEarnings |
| `geofence.ts` | ~3 | Worker geofence management |
| `tracking.ts` | ~3 | Worker location tracking |
| `heatmap.ts` | ~2 | Task heatmaps for workers |
| `insurance.ts` | ~3 | Self-insurance pool |
| `challenges.ts` | ~2 | Daily challenges |
| `capability.ts` | ~2 | Worker capability assessment |
| `batching.ts` | ~2 | AI task batching |
| `tipping.ts` | ~2 | Receive tips |
| `expertiseSupply.ts` | ~2 | Declare expertise |
| `biometric.ts` | ~2 | Biometric verification |
| `ai.ts` | ~2 | AI calibration |
| `intent.ts` | ~2 | NLP task parsing |

**For each file:**
1. Update import: add `hustlerProcedure`
2. Replace all `protectedProcedure` with `hustlerProcedure`
3. Run individual test if exists

**Step N: Commit**

```bash
git add backend/src/routers/{instant,taskDiscovery,live,stripeConnect,xpTax,skills,referral,geofence,tracking,heatmap,insurance,challenges,capability,batching,tipping,expertiseSupply,biometric,ai,intent}.ts
git commit -m "feat: apply hustlerProcedure role guard to all Hustler-only routers"
```

---

### Task 5: Apply role guards to all Poster-only routers

**Files to modify (all procedures → `posterProcedure`):**

| Router File | Procedure Count | Notes |
|-------------|-----------------|-------|
| `recurringTask.ts` | 10 | All — poster manages recurring series |
| `featured.ts` | 1 | createFeaturingAd |
| `pricing.ts` | 1 | getSmartPrice |
| `subscription.ts` | ~3 | Poster subscription management |

**For each file:**
1. Update import: add `posterProcedure`
2. Replace all `protectedProcedure` with `posterProcedure`

**Step N: Commit**

```bash
git add backend/src/routers/{recurringTask,featured,pricing,subscription}.ts
git commit -m "feat: apply posterProcedure role guard to all Poster-only routers"
```

---

### Task 6: Apply role guards to `escrow.ts`

**Files:**
- Modify: `backend/src/routers/escrow.ts`

**Procedure classification:**

| Procedure | Target | Reason |
|-----------|--------|--------|
| `getById` | protectedProcedure | Both roles view |
| `getState` | protectedProcedure | Both roles confirm |
| `getByTaskId` | protectedProcedure | Both roles view |
| `createPaymentIntent` | posterProcedure | Poster pays |
| `confirmFunding` | posterProcedure | Poster confirms |
| `release` | posterProcedure | Poster releases |
| `refund` | posterProcedure | Poster requests refund |
| `lockForDispute` | protectedProcedure | Either party can lock |
| `getHistory` | protectedProcedure | Both roles view |
| `awardXP` | hustlerProcedure | Worker claims XP |

**Commit:**

```bash
git add backend/src/routers/escrow.ts
git commit -m "feat(escrow): apply hustler/poster role guards to escrow procedures"
```

---

### Task 7: Run full test suite and fix any failures

```bash
npx vitest run
```

**Expected:** All 5,448+ tests pass. If any fail:
- Check if test mock user has wrong `default_mode` for the procedure being tested
- Fix mock: set `default_mode: 'poster'` for poster procedure tests
- Do NOT remove the role guard — fix the test

**Commit fixes:**

```bash
git commit -m "test: fix mock user default_mode for role-guarded procedure tests"
```

---

### Task 8: Reorganize `routers/index.ts` by domain

**Files:**
- Modify: `backend/src/routers/index.ts`

Reorganize the imports and appRouter into clear domain sections:

```typescript
// ── HUSTLER DOMAIN ──────────────────────────────────────────────────────
import { instantRouter } from './instant.js';
import { taskDiscoveryRouter } from './taskDiscovery.js';
import { liveRouter } from './live.js';
import { stripeConnectRouter } from './stripeConnect.js';
import { xpTaxRouter } from './xpTax.js';
import { skillsRouter } from './skills.js';
import { referralRouter } from './referral.js';
// ... etc

// ── POSTER DOMAIN ───────────────────────────────────────────────────────
import { recurringTaskRouter } from './recurringTask.js';
import { featuredRouter } from './featured.js';
import { pricingRouter } from './pricing.js';
import { subscriptionRouter } from './subscription.js';

// ── SHARED DOMAIN ───────────────────────────────────────────────────────
import { taskRouter } from './task.js';
import { escrowRouter } from './escrow.js';
import { messagingRouter } from './messaging.js';
// ... etc

// ── ADMIN DOMAIN ────────────────────────────────────────────────────────
import { adminRouter } from './admin.js';
// ... etc

// ── SYSTEM DOMAIN ───────────────────────────────────────────────────────
import { healthRouter } from './health.js';
// ... etc
```

**Commit:**

```bash
git add backend/src/routers/index.ts
git commit -m "refactor: reorganize routers/index.ts into domain sections"
```

---

### Task 9: Add CODEOWNERS file

**Files:**
- Create: `backend/CODEOWNERS`

```
# Hustler domain
backend/src/routers/instant.ts          @hustlexp/hustler-team
backend/src/routers/taskDiscovery.ts    @hustlexp/hustler-team
backend/src/routers/live.ts             @hustlexp/hustler-team
backend/src/routers/stripeConnect.ts    @hustlexp/hustler-team

# Poster domain
backend/src/routers/recurringTask.ts    @hustlexp/poster-team
backend/src/routers/featured.ts         @hustlexp/poster-team
backend/src/routers/pricing.ts          @hustlexp/poster-team

# Financial (requires review from payments lead)
backend/src/routers/escrow.ts           @hustlexp/payments-team
backend/src/services/EscrowService.ts   @hustlexp/payments-team
backend/src/services/StripeService.ts   @hustlexp/payments-team

# Admin (requires review from platform lead)
backend/src/routers/admin.ts            @hustlexp/platform-team
```

**Commit:**

```bash
git add backend/CODEOWNERS
git commit -m "feat: add CODEOWNERS for domain-based code ownership"
```

---

## Phase 2: Folder Reorganization (Separate Sprint — High Risk)

### Task 10: Create domain folder structure

```bash
mkdir -p backend/src/routers/{hustler,poster,shared,admin,system}
mkdir -p backend/src/services/{task,payments,identity,gamification,messaging,ai,instant,platform}
```

### Task 11-18: Move files into domain folders

Each task moves one domain's files:
- Update all import paths in moved files
- Update all import paths in files that reference moved files
- Run full test suite after each domain move

**This phase is estimated at 4-6 hours and should be done in a git worktree for safety.**

---

## Verification Checklist

After Phase 1:
- [ ] `hustlerProcedure` and `posterProcedure` exported from trpc.ts
- [ ] All Hustler-only routers use `hustlerProcedure`
- [ ] All Poster-only routers use `posterProcedure`
- [ ] Mixed routers (task, squad, escrow) have correct per-procedure guards
- [ ] Shared procedures still use `protectedProcedure`
- [ ] Admin procedures still use `adminProcedure`
- [ ] All 5,448+ tests pass
- [ ] routers/index.ts organized by domain
- [ ] CODEOWNERS file exists

## Routers That Stay `protectedProcedure` (Shared)

These routers serve both roles and should NOT get role guards:
- `messaging.ts` — both roles message
- `notification.ts` — both roles receive notifications
- `rating.ts` — both roles rate each other
- `user.ts` — both roles manage profile (except verification endpoints → hustlerProcedure)
- `upload.ts` — both roles upload files
- `jury.ts` — both roles vote in disputes
- `analytics.ts` — both roles track events
- `gdpr.ts` — both roles exercise data rights
- `tutorial.ts` — both roles access tutorials
- `batchQuest.ts` — gamification for both
- `ui.ts` — UI state tracking
- `health.ts` — system health (publicProcedure)
- `flags.ts` — feature flags (system)
- `fraud.ts` — fraud detection (system)
- `alpha-telemetry.ts` — telemetry (system)

## Special Cases

| Procedure | Decision | Reasoning |
|-----------|----------|-----------|
| `user.getVerificationUnlockStatus` | `hustlerProcedure` | Only workers earn verification |
| `user.checkVerificationEligibility` | `hustlerProcedure` | Only workers verify |
| `user.getVerificationEarningsLedger` | `hustlerProcedure` | Only workers track earnings |
| `escrow.awardXP` | `hustlerProcedure` | Only workers claim XP |
| `escrow.createPaymentIntent` | `posterProcedure` | Only posters fund escrow |
| `escrow.release` | `posterProcedure` | Only posters release funds |
| `listByPoster` | `posterProcedure` | Poster's own task list |
| `listByWorker` | `hustlerProcedure` | Worker's own task list |
