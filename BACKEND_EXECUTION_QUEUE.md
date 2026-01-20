# BACKEND EXECUTION QUEUE — HUSTLEXP v1.0

**STATUS: ACTIVE — This is the ONLY file Claude Code reads during backend build**
**Authority:** BUILD_GUIDE.md, ARCHITECTURE.md, schema.sql
**Rule: Execute steps in order. No skipping. No inventing. No "improving."**

---

## QUEUE FORMAT

```
STEP XXX: [Action]
Input: [Spec file]
Output: [File path]
Depends: [Previous step or "none"]
Constraints: [Hard rules]
Done: [ ] (check when complete)
```

---

## PHASE 0: SCHEMA DEPLOYMENT (Steps B001-B005)

### STEP B001: Verify PostgreSQL Connection
```
Input: BUILD_GUIDE.md §3.2
Output: Verified database connection
Depends: none
Constraints:
  - PostgreSQL 14+ installed
  - DATABASE_URL environment variable set
  - Connection successful
Done: [ ]
```

### STEP B002: Deploy Core Schema
```
Input: specs/02-architecture/schema.sql
Output: Database with all tables created
Depends: STEP B001
Constraints:
  - Run schema.sql against database
  - Verify 18+ tables created
  - No errors during execution
Done: [ ]
```

### STEP B003: Verify Triggers Exist
```
Input: BUILD_GUIDE.md §3.4.2
Output: Trigger verification log
Depends: STEP B002
Constraints:
  - task_terminal_guard exists
  - escrow_terminal_guard exists
  - escrow_amount_immutable exists
  - xp_requires_released_escrow exists
  - xp_ledger_no_delete exists
  - At least 10 triggers total
Done: [ ]
```

### STEP B004: Test INV-1 Enforcement
```
Input: BUILD_GUIDE.md §3.4.3
Output: Test result showing HX101 error
Depends: STEP B003
Constraints:
  - Attempt to insert XP without RELEASED escrow
  - Must fail with HX101 error code
  - Rollback test transaction
Done: [ ]
```

### STEP B005: Schema Gate Complete
```
Input: All B001-B004
Output: Schema deployment verified
Depends: STEP B004
Constraints:
  - All tables exist
  - All triggers exist
  - INV-1 enforcement verified
  - schema_versions shows 1.0.0
Done: [ ]
```

---

## PHASE 1: BACKEND SERVICES (Steps B010-B025)

### STEP B010: Create Database Client
```
Input: BUILD_GUIDE.md §4.3
Output: src/services/db.ts
Depends: STEP B005
Constraints:
  - Uses pg library
  - Connection pooling
  - Transaction helper function
  - Error handling for HX codes
Done: [ ]
```

### STEP B011: Create Shared Types
```
Input: schema.sql, PRODUCT_SPEC.md
Output: src/services/types.ts
Depends: STEP B010
Constraints:
  - TaskState enum matching schema
  - EscrowState enum matching schema
  - ProofState enum matching schema
  - User, Task, Escrow, Proof interfaces
  - ServiceResult<T> type
Done: [ ]
```

### STEP B012: Create TaskService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §3
Output: src/services/TaskService.ts
Depends: STEP B011
Constraints:
  - create(): Create new task
  - accept(): Assign worker to task
  - submitProof(): Transition to PROOF_SUBMITTED
  - complete(): Transition to COMPLETED (requires ACCEPTED proof)
  - cancel(): Transition to CANCELLED
  - getById(): Fetch single task
  - list(): Fetch tasks with filters
  - All methods use transactions
  - All methods return ServiceResult<T>
Done: [ ]
```

### STEP B013: Create EscrowService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §4
Output: src/services/EscrowService.ts
Depends: STEP B012
Constraints:
  - createPaymentIntent(): Create Stripe PaymentIntent
  - handlePaymentSuccess(): Transition to FUNDED
  - release(): Transition to RELEASED (requires COMPLETED task)
  - refund(): Transition to REFUNDED
  - lockForDispute(): Transition to LOCKED_DISPUTE
  - getById(): Fetch single escrow
  - getByTaskId(): Fetch escrow for task
  - INV-4 enforced (amount immutable)
Done: [ ]
```

### STEP B014: Create ProofService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §3.2
Output: src/services/ProofService.ts
Depends: STEP B013
Constraints:
  - create(): Create proof record
  - submit(): Submit proof with photos
  - accept(): Accept proof (requires reviewer)
  - reject(): Reject proof with reason
  - getById(): Fetch single proof
  - getByTaskId(): Fetch proof for task
  - uploadPhoto(): Handle photo storage
Done: [ ]
```

### STEP B015: Create XPService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §5
Output: src/services/XPService.ts
Depends: STEP B014
Constraints:
  - award(): Award XP (requires RELEASED escrow - INV-1)
  - calculateBase(): Calculate base XP from task price
  - calculateStreak(): Calculate streak multiplier
  - calculateEffective(): Calculate final XP
  - getUserXP(): Get user's total XP
  - getXPLedger(): Get XP history for user
  - Idempotent by escrow_id (INV-5)
Done: [ ]
```

### STEP B016: Create TrustService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §6
Output: src/services/TrustService.ts
Depends: STEP B015
Constraints:
  - calculateTier(): Calculate trust tier from metrics
  - updateUserTrust(): Update user's trust tier
  - getTrustHistory(): Get trust changes for user
  - checkEligibility(): Check if user meets task requirements
  - Tier 1-4 thresholds per spec
Done: [ ]
```

### STEP B017: Create BadgeService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §5
Output: src/services/BadgeService.ts
Depends: STEP B016
Constraints:
  - checkAndAward(): Check and award badges after XP
  - getUserBadges(): Get badges for user
  - getBadgeDefinitions(): Get all badge definitions
  - Append-only badges (no delete)
Done: [ ]
```

### STEP B018: Create DisputeService
```
Input: BUILD_GUIDE.md §4.3, PRODUCT_SPEC.md §4.3
Output: src/services/DisputeService.ts
Depends: STEP B017
Constraints:
  - create(): Create dispute (locks escrow)
  - resolve(): Resolve dispute with outcome
  - getById(): Fetch single dispute
  - getByTaskId(): Fetch dispute for task
  - Handles HUSTLER_WINS, CLIENT_WINS, SPLIT outcomes
Done: [ ]
```

### STEP B019: Create StripeWebhookHandler
```
Input: BUILD_GUIDE.md §4.3
Output: src/services/StripeWebhookHandler.ts
Depends: STEP B018
Constraints:
  - handlePaymentIntentSucceeded(): Fund escrow
  - handlePaymentIntentCanceled(): Refund escrow
  - handleTransferCreated(): Track transfer
  - Idempotent by stripe event ID
  - Event signature verification
Done: [ ]
```

### STEP B020: Create UserService
```
Input: schema.sql users table
Output: src/services/UserService.ts
Depends: STEP B019
Constraints:
  - create(): Create user
  - getById(): Fetch user
  - getByEmail(): Fetch by email
  - update(): Update profile
  - completeOnboarding(): Mark onboarding complete
Done: [ ]
```

### STEP B021: Create Kill Tests - INV-1
```
Input: BUILD_GUIDE.md §4.5
Output: tests/invariants/inv-1.test.ts
Depends: STEP B020
Constraints:
  - Test: XP without RELEASED escrow MUST FAIL with HX101
  - Test: XP with RELEASED escrow MUST SUCCEED
  - At least 8 assertions
Done: [ ]
```

### STEP B022: Create Kill Tests - INV-2
```
Input: BUILD_GUIDE.md §4.5
Output: tests/invariants/inv-2.test.ts
Depends: STEP B021
Constraints:
  - Test: RELEASED without COMPLETED task MUST FAIL with HX201
  - Test: RELEASED with COMPLETED task MUST SUCCEED
  - At least 8 assertions
Done: [ ]
```

### STEP B023: Create Kill Tests - INV-3
```
Input: BUILD_GUIDE.md §4.5
Output: tests/invariants/inv-3.test.ts
Depends: STEP B022
Constraints:
  - Test: COMPLETED without ACCEPTED proof MUST FAIL with HX301
  - Test: COMPLETED with ACCEPTED proof MUST SUCCEED
  - At least 8 assertions
Done: [ ]
```

### STEP B024: Create Kill Tests - Terminal States
```
Input: BUILD_GUIDE.md §4.5
Output: tests/invariants/terminal-states.test.ts
Depends: STEP B023
Constraints:
  - Test: Cannot modify COMPLETED task
  - Test: Cannot modify RELEASED escrow
  - Test: Cannot delete XP ledger entry
  - Test: Cannot delete badge entry
Done: [ ]
```

### STEP B025: Services Gate Complete
```
Input: All B010-B024
Output: All services implemented and tested
Depends: STEP B024
Constraints:
  - All 10 services implemented
  - All 4 kill test files pass
  - npm test exits 0
Done: [ ]
```

---

## PHASE 2: API LAYER (Steps B030-B050)

### STEP B030: Setup tRPC Router
```
Input: BUILD_GUIDE.md §5.2
Output: src/routers/index.ts
Depends: STEP B025
Constraints:
  - tRPC router configured
  - Context with userId from auth
  - Error formatter for HX codes
Done: [ ]
```

### STEP B031: Create Auth Middleware
```
Input: BUILD_GUIDE.md §5.2
Output: src/middleware/auth.ts
Depends: STEP B030
Constraints:
  - Firebase Admin token verification
  - Extract userId from token
  - protectedProcedure wrapper
  - adminProcedure wrapper
Done: [ ]
```

### STEP B032: Create Task Router
```
Input: BUILD_GUIDE.md §5.5, API_CONTRACT.md
Output: src/routers/task.ts
Depends: STEP B031
Constraints:
  - task.create (mutation, protected)
  - task.accept (mutation, protected)
  - task.submitProof (mutation, protected)
  - task.complete (mutation, protected)
  - task.cancel (mutation, protected)
  - task.getById (query, protected)
  - task.list (query, protected)
  - Zod validation on all inputs
Done: [ ]
```

### STEP B033: Create Escrow Router
```
Input: BUILD_GUIDE.md §5.5, API_CONTRACT.md
Output: src/routers/escrow.ts
Depends: STEP B032
Constraints:
  - escrow.createIntent (mutation, protected)
  - escrow.release (mutation, protected)
  - escrow.refund (mutation, protected)
  - escrow.getByTaskId (query, protected)
Done: [ ]
```

### STEP B034: Create Proof Router
```
Input: BUILD_GUIDE.md §5.5, API_CONTRACT.md
Output: src/routers/proof.ts
Depends: STEP B033
Constraints:
  - proof.submit (mutation, protected)
  - proof.accept (mutation, protected)
  - proof.reject (mutation, protected)
  - proof.getByTaskId (query, protected)
Done: [ ]
```

### STEP B035: Create User Router
```
Input: BUILD_GUIDE.md §5.5, API_CONTRACT.md
Output: src/routers/user.ts
Depends: STEP B034
Constraints:
  - user.getProfile (query, protected)
  - user.updateProfile (mutation, protected)
  - user.getXP (query, protected)
  - user.getBadges (query, protected)
  - user.getTrustTier (query, protected)
Done: [ ]
```

### STEP B036: Create Dispute Router
```
Input: BUILD_GUIDE.md §5.5, API_CONTRACT.md
Output: src/routers/dispute.ts
Depends: STEP B035
Constraints:
  - dispute.create (mutation, protected)
  - dispute.resolve (mutation, admin only)
  - dispute.getByTaskId (query, protected)
Done: [ ]
```

### STEP B037: Create Messaging Router
```
Input: MESSAGING_SPEC.md, API_CONTRACT.md
Output: src/routers/messaging.ts
Depends: STEP B036
Constraints:
  - messaging.getThread (query, protected)
  - messaging.sendMessage (mutation, protected)
  - messaging.markRead (mutation, protected)
  - Task-scoped messaging only
Done: [ ]
```

### STEP B038: Create Notification Router
```
Input: NOTIFICATION_SPEC.md, API_CONTRACT.md
Output: src/routers/notification.ts
Depends: STEP B037
Constraints:
  - notification.list (query, protected)
  - notification.markRead (mutation, protected)
  - notification.getPreferences (query, protected)
  - notification.updatePreferences (mutation, protected)
Done: [ ]
```

### STEP B039: Create Stripe Webhook Endpoint
```
Input: BUILD_GUIDE.md §5.5
Output: src/routes/webhooks/stripe.ts
Depends: STEP B038
Constraints:
  - POST /webhooks/stripe
  - Signature verification
  - Routes to StripeWebhookHandler
  - Returns 200 on success
Done: [ ]
```

### STEP B040: Create API Tests - Task Router
```
Input: BUILD_GUIDE.md §5.6
Output: tests/api/task.test.ts
Depends: STEP B039
Constraints:
  - Happy path test for each endpoint
  - Auth test (unauthenticated rejected)
  - Validation test (invalid input rejected)
  - Error propagation test
Done: [ ]
```

### STEP B041: Create API Tests - Escrow Router
```
Input: BUILD_GUIDE.md §5.6
Output: tests/api/escrow.test.ts
Depends: STEP B040
Constraints:
  - Happy path test for each endpoint
  - Auth test
  - Validation test
  - Error propagation test
Done: [ ]
```

### STEP B042: Create API Tests - Other Routers
```
Input: BUILD_GUIDE.md §5.6
Output: tests/api/*.test.ts (proof, user, dispute, messaging, notification)
Depends: STEP B041
Constraints:
  - Happy path tests
  - Auth tests
  - Validation tests
Done: [ ]
```

### STEP B043: API Gate Complete
```
Input: All B030-B042
Output: All API endpoints implemented and tested
Depends: STEP B042
Constraints:
  - All routers implemented
  - All endpoint tests pass
  - npm run test:api exits 0
Done: [ ]
```

---

## PHASE 3: INTEGRATION (Steps B050-B060)

### STEP B050: Create E2E Test - Happy Path
```
Input: BUILD_GUIDE.md §8.3
Output: tests/e2e/happy-path.test.ts
Depends: STEP B043
Constraints:
  - Post → Accept → Proof → Complete → Pay → XP
  - Full lifecycle with real services
  - All states verified
  - XP awarded correctly
Done: [ ]
```

### STEP B051: Create E2E Test - Dispute Flow
```
Input: BUILD_GUIDE.md §8.3
Output: tests/e2e/dispute.test.ts
Depends: STEP B050
Constraints:
  - Post → Accept → Proof → Reject → Dispute → Resolve
  - HUSTLER_WINS outcome tested
  - CLIENT_WINS outcome tested
  - SPLIT outcome tested
  - Escrow handled correctly
Done: [ ]
```

### STEP B052: Create E2E Test - Cancellation
```
Input: BUILD_GUIDE.md §8.3
Output: tests/e2e/cancellation.test.ts
Depends: STEP B051
Constraints:
  - Post → Cancel (before accept)
  - Post → Accept → Cancel (after accept)
  - Escrow refunded correctly
  - No XP awarded
Done: [ ]
```

### STEP B053: Create E2E Test - Expiration
```
Input: BUILD_GUIDE.md §8.3
Output: tests/e2e/expiration.test.ts
Depends: STEP B052
Constraints:
  - Post → (timeout) → Expire
  - Escrow refunded
  - No XP awarded
Done: [ ]
```

### STEP B054: Verify Stripe Integration
```
Input: BUILD_GUIDE.md §8.5
Output: Stripe test mode verification
Depends: STEP B053
Constraints:
  - Send test webhook events
  - Verify escrow state changes
  - Verify transfer created on release
Done: [ ]
```

### STEP B055: Integration Gate Complete
```
Input: All B050-B054
Output: All E2E tests pass
Depends: STEP B054
Constraints:
  - Happy path E2E passes
  - Dispute flow E2E passes
  - Cancellation E2E passes
  - Stripe verified
  - npm run test:e2e exits 0
Done: [ ]
```

---

## PHASE 4: DEPLOYMENT PREP (Steps B060-B065)

### STEP B060: Create CI Configuration
```
Input: BUILD_GUIDE.md §12.1
Output: .github/workflows/ci.yml
Depends: STEP B055
Constraints:
  - Lint step
  - Type check step
  - Unit tests step
  - Kill tests step
  - API tests step
Done: [ ]
```

### STEP B061: Create Environment Configuration
```
Input: BUILD_GUIDE.md §9
Output: .env.example, src/config.ts
Depends: STEP B060
Constraints:
  - DATABASE_URL
  - STRIPE_SECRET_KEY
  - STRIPE_WEBHOOK_SECRET
  - FIREBASE_PROJECT_ID
  - All secrets from env vars
Done: [ ]
```

### STEP B062: Create Health Check Endpoint
```
Input: BUILD_GUIDE.md §9.3
Output: src/routes/health.ts
Depends: STEP B061
Constraints:
  - GET /health returns 200
  - Checks database connection
  - Returns version info
Done: [ ]
```

### STEP B063: Create Production Verification Queries
```
Input: BUILD_GUIDE.md §9.4
Output: scripts/verify-production.sql
Depends: STEP B062
Constraints:
  - Verify schema version
  - Verify trigger count
  - Verify table count
  - Can run against production
Done: [ ]
```

### STEP B064: Deployment Gate Complete
```
Input: All B060-B063
Output: Backend ready for deployment
Depends: STEP B063
Constraints:
  - CI passes
  - Environment configured
  - Health check works
  - Verification queries ready
Done: [ ]
```

---

## QUEUE RULES

1. **Execute steps in order. No skipping.**
2. **Mark "Done: [x]" only when step passes.**
3. **If a step fails, stop and fix before proceeding.**
4. **No step may add features not in its spec.**
5. **No step may modify previous steps without approval.**
6. **If unclear, STOP and ask. Do not guess.**

---

## CLAUDE CODE COMMAND

When starting a build session, Claude Code should run:

```
Read BACKEND_EXECUTION_QUEUE.md
Find first step where Done: [ ]
Execute that step only
Mark Done: [x] when complete
Stop
```

**Claude Code does NOT:**
- Look ahead
- Plan multiple steps
- Suggest improvements
- Refactor existing code
- Add features not in current step
- Touch frontend code

---

## CROSS-REFERENCE

| Backend Step | Frontend Dependency | Notes |
|--------------|--------------------|----- |
| B043 (API Gate) | STEP 100 (Wiring Gate) | Frontend can swap mock for real API |
| B055 (E2E Gate) | - | Backend fully functional |
| B064 (Deploy Gate) | - | Ready for production |

---

**END OF BACKEND EXECUTION QUEUE**
