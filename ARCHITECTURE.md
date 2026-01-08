# HustleXP Architecture Specification v1.0.0

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Governance:** This document defines jurisdictional authority. Violations are system failures.

---

## §1. Authority Model

### 1.1 Prime Directive

```
AI proposes.
Deterministic systems decide.
Databases enforce.
UI reveals.
```

This is not a suggestion. It is the only legal information flow.

Any component that violates this ordering is **broken by definition**, regardless of whether it "works."

### 1.2 Why Smart Clients Are Forbidden

A "smart client" is any frontend that:
- Computes business logic locally
- Optimistically assumes server state
- Makes decisions without server validation

HustleXP forbids smart clients because:

1. **Money is involved.** Optimistic updates on money = fraud vectors.
2. **XP is permanent.** Once awarded, it cannot be revoked. Client-side XP logic = inflation.
3. **Trust is auditable.** Every trust change must trace to a server decision.
4. **Disputes require evidence.** Client state is not admissible.

**Rule:** The frontend may cache for display. It may never cache for decision-making.

### 1.3 Immutable vs Reversible Actions

| Action Type | Examples | Authority |
|-------------|----------|-----------|
| **Immutable** | XP award, badge grant, escrow release, admin audit entry | Database only (Layer 0) |
| **Reversible** | Task draft, user preferences, UI state | Any layer with proper guards |

**Principle:** If an action cannot be undone, only Layer 0 may execute it.

### 1.4 Authority Violation Consequences

| Violation | Consequence |
|-----------|-------------|
| UI attempts immutable action directly | Request rejected by API |
| Backend bypasses DB constraint | Transaction rolled back |
| AI writes to ledger | System crash (this path does not exist) |
| Admin mutates history | Audit log created, action flagged |

There is no "silent" violation. Every boundary crossing is logged or rejected.

---

## §2. Layer Hierarchy

HustleXP operates on a strict 7-layer authority hierarchy. Higher numbers have less authority.

```
Layer 0: Database (PostgreSQL)     ← HIGHEST AUTHORITY
Layer 1: Backend Services          
Layer 2: API Gateway (tRPC)        
Layer 3: AI Systems                
Layer 4: Frontend Logic            
Layer 5: UI / Animation            
Layer 6: Human Override            ← BOUNDED AUTHORITY
```

### 2.0 Layer 0 — Database

**Name:** PostgreSQL with constitutional schema  
**Authority:** Absolute truth and enforcement  
**Location:** `schema.sql`

**Can:**
- Reject invalid state transitions
- Enforce invariants (INV-1 through INV-5)
- Maintain append-only ledgers
- Be the single source of truth for all canonical state

**Cannot:**
- Be bypassed by any layer
- Have constraints relaxed at runtime
- Trust input from any layer without validation

**Violation Behavior:**
- Invalid operations raise HX error codes
- Transactions roll back atomically
- No partial state corruption is possible

**Cross-Reference:**
- PRODUCT_SPEC §2 (Core Invariants)
- PRODUCT_SPEC §10 (Error Codes)

### 2.1 Layer 1 — Backend Services

**Name:** TypeScript services (Node.js)  
**Authority:** Orchestration and business logic  
**Location:** `hustlexp-ai-backend/backend/src/services/`

**Can:**
- Coordinate multi-step operations
- Call Layer 0 within transactions
- Validate inputs before submission to DB
- Compute derived values (XP formulas, trust calculations)
- Interface with external services (Stripe, AI providers)

**Cannot:**
- Store authoritative state (that's Layer 0)
- Override DB constraints
- Make irreversible decisions without DB confirmation
- Trust client input without validation

**Services Defined:**
| Service | Responsibility | Invariants |
|---------|----------------|------------|
| `TaskService` | Task lifecycle orchestration | INV-3 |
| `EscrowService` | Payment state management | INV-2, INV-4 |
| `XPService` | XP calculation and award | INV-1, INV-5 |
| `ProofService` | Proof submission and review | — |
| `DisputeService` | Dispute lifecycle | — |
| `TrustService` | Trust tier management | INV-TRUST-* |
| `StripeWebhookHandler` | Payment event processing | Idempotency |

### 2.2 Layer 2 — API Gateway

**Name:** tRPC router  
**Authority:** Transport and access control  
**Location:** `hustlexp-ai-backend/backend/src/routers/`

**Can:**
- Authenticate requests
- Route to appropriate services
- Validate request schemas (Zod)
- Rate limit
- Log access

**Cannot:**
- Contain business logic
- Make decisions about state
- Transform data beyond serialization
- Cache authoritative state

**Rule:** If you're writing an `if` statement in a router that isn't about auth or validation, you're in the wrong layer.

### 2.3 Layer 3 — AI Systems

**Name:** LLM orchestration, classifiers, vision models  
**Authority:** Proposals only  
**Location:** `hustlexp-ai-backend/src/ai/`

**Can:**
- Analyze inputs and generate proposals
- Compute confidence scores
- Process evidence (photos, text)
- Suggest dispute resolutions
- Infer user intent (onboarding)

**Cannot:**
- Write to any ledger (XP, trust, badges)
- Mutate task/escrow/proof state
- Make final decisions on money
- Operate without human-reviewable audit trail
- Execute actions above confidence threshold without confirmation

**Authority Levels:**
| Level | Name | Capability |
|-------|------|------------|
| A0 | Forbidden | Cannot access (money, core state) |
| A1 | Read-Only | Can read for context |
| A2 | Propose | Can generate proposals for human/system review |
| A3 | Auto-Execute | Can execute if confidence > threshold AND stakes < limit |

**Cross-Reference:**
- AI_INFRASTRUCTURE.md §3 (Authority Model)
- PRODUCT_SPEC §7.3 (Dispute Authority)

### 2.4 Layer 4 — Frontend Logic

**Name:** React Native state management  
**Authority:** UX state only  
**Location:** Mobile app `state/` directory

**Can:**
- Manage navigation state
- Cache server responses for display
- Track UI interaction state (forms, modals)
- Optimistically update non-critical UI
- Validate inputs before submission

**Cannot:**
- Compute XP, trust, or badge state
- Assume server state without confirmation
- Make decisions about money
- Store authoritative business state

**State Machines Defined:**
| Machine | Purpose | Authority |
|---------|---------|-----------|
| `TaskStateMachine` | Display task state transitions | Read-only mirror of DB |
| `EscrowStateMachine` | Display escrow state | Read-only mirror of DB |
| `ProofStateMachine` | Track proof submission flow | Local UX only |
| `OnboardingStateMachine` | Guide onboarding screens | Local UX only |

**Rule:** Frontend state machines are for **display logic**, not **business logic**. They reflect server truth; they do not create it.

### 2.5 Layer 5 — UI / Animation

**Name:** React Native components, Rive animations  
**Authority:** Visual representation only  
**Location:** Mobile app `components/`, `screens/`

**Can:**
- Render state received from Layer 4
- Play animations based on state changes
- Respect accessibility settings
- Apply visual styling

**Cannot:**
- Compute what to display (that's Layer 4)
- Trigger state changes (only request them)
- Assume meaning from visual state
- Animate without server-confirmed state change

**Cross-Reference:**
- UI_SPEC.md (when created) for animation rules
- PRODUCT_SPEC §5.4 (XP ledger as source of truth)

### 2.6 Layer 6 — Human Override

**Name:** Admin actions, founder escalation  
**Authority:** Bounded manual intervention  
**Location:** Admin dashboard, manual DB operations

**Can:**
- Resolve edge-case disputes
- Issue manual refunds (with audit)
- Suspend/ban users (with audit)
- Override AI decisions (with audit)

**Cannot:**
- Delete ledger entries (append-only)
- Modify historical XP awards
- Bypass DB constraints
- Act without audit trail

**Audit Requirement:**
Every admin action creates an entry in `admin_actions` table:
```sql
admin_actions {
  admin_id,      -- Who
  action_type,   -- What
  target_type,   -- On what entity type
  target_id,     -- Which entity
  reason,        -- Why
  metadata,      -- Details (JSONB)
  created_at     -- When
}
```

This table is append-only (trigger: `admin_actions_no_delete`).

---

## §3. XP System Authority

### 3.1 Why XP Cannot Be Awarded by AI or UI

XP represents **verified economic value**. It is:
- Permanent once awarded
- Used for trust calculations
- Visible to other users
- Part of the user's permanent record

If AI could award XP:
- Hallucinations become permanent economic facts
- Gaming the AI = gaming the economy
- No audit trail for "why this XP exists"

If UI could award XP:
- Client manipulation = infinite XP
- No server validation = no truth
- Disputes become unresolvable

**Rule:** XP awards flow through exactly one path:
```
EscrowService.release() 
  → Database (INV-2 check) 
  → XPService.award() 
  → Database (INV-1 check) 
  → xp_ledger entry created
```

### 3.2 Why XP Must Be Ledger-Based

The `xp_ledger` table is the **only** authoritative record of XP.

```sql
xp_ledger {
  id,
  user_id,
  task_id,
  escrow_id,         -- UNIQUE constraint (INV-5)
  base_xp,
  effective_xp,
  user_xp_before,    -- Snapshot
  user_xp_after,     -- Snapshot
  ...
}
```

**Why snapshots?**
- `user_xp_before` and `user_xp_after` capture state at award time
- If we only stored deltas, corruption could cascade
- Snapshots make each entry independently verifiable

**Append-Only Enforcement:**
- Trigger: `xp_ledger_no_delete`
- Error: HX102
- No row in `xp_ledger` can ever be deleted

### 3.3 Why Totals Are Derived, Not Stored

The `users.total_xp` column is a **cache**, not truth.

Truth = `SUM(effective_xp) FROM xp_ledger WHERE user_id = ?`

**Why?**
- If `total_xp` and ledger disagree, ledger wins
- Derived values can be recomputed; stored lies cannot
- Auditors can verify totals independently

**Sync Rule:**
- `total_xp` is updated atomically with ledger insert
- Periodic reconciliation job verifies consistency
- Mismatch = critical alert, manual review

### 3.4 Decay Authority

XP decay (if implemented) follows these rules:

| Aspect | Authority |
|--------|-----------|
| Decay rate | Defined in PRODUCT_SPEC §5.6 |
| Decay computation | Backend service (scheduled job) |
| Decay storage | `displayed_xp` column (not `total_xp`) |
| Decay enforcement | Database constraint |

**Principle:** `total_xp` never decreases. Only `displayed_xp` (a computed view) can show decay.

---

## §4. Trust Tier Authority

### 4.1 Trust Tiers Defined

| Tier | Name | Requirements |
|------|------|--------------|
| 0 | ROOKIE | Default for new users |
| 1 | VERIFIED | 5 completed tasks + ID verification |
| 2 | TRUSTED | 20 completed tasks + 95% approval rate |

### 4.2 Promotion Authority

**Who can promote a user's trust tier?**

| Actor | Can Promote? | Conditions |
|-------|--------------|------------|
| User | ❌ No | — |
| UI | ❌ No | — |
| AI | ❌ No | Can only *propose* promotion |
| Backend Service | ✅ Yes | If all criteria met |
| Admin | ✅ Yes | With audit entry |
| Database | ✅ Yes | Enforces constraints |

**Promotion Flow:**
```
TrustService.checkPromotion(userId)
  → Verify criteria from DB
  → If eligible: UPDATE users SET trust_tier = ?
  → Insert trust_ledger entry
  → Return new tier
```

### 4.3 Decay Authority

Trust tiers can decay based on:
- Inactivity (no completed tasks in 90 days)
- SLA breaches (task abandonment, proof rejection rate)
- Dispute losses

**Decay is computed by:** Backend scheduled job (daily)  
**Decay is enforced by:** Database constraint on valid tier values  
**Decay is logged in:** `trust_ledger` (append-only)

### 4.4 Penalty Authority

| Penalty | Authority | Audit Required |
|---------|-----------|----------------|
| Tier downgrade | Backend service | Yes |
| Temporary suspension | Backend service | Yes |
| Permanent ban | Admin only | Yes |

**Rule:** No penalty can be applied silently. Every penalty creates a `trust_ledger` entry.

### 4.5 Trust Ledger

```sql
trust_ledger {
  id,
  user_id,
  old_tier,
  new_tier,
  reason,           -- 'PROMOTION', 'DECAY', 'PENALTY', 'ADMIN_OVERRIDE'
  evidence_id,      -- Optional link to evidence
  created_at
}
```

**Trigger:** `trust_tier_audit` — automatically logs all tier changes.

### 4.6 Why UI Cannot Imply Trust Changes

The UI may:
- Display current trust tier
- Show progress toward next tier
- Explain tier benefits

The UI may **never**:
- Show a tier the user hasn't achieved
- Animate a promotion before server confirms
- Imply trust without server validation

**Violation:** Showing unearned trust = misleading users = legal liability.

---

## §5. Badge System Authority

### 5.1 Badge Unlock Authority

| Actor | Can Grant Badge? | Conditions |
|-------|------------------|------------|
| User | ❌ No | — |
| UI | ❌ No | — |
| AI | ❌ No | — |
| Backend Service | ✅ Yes | If unlock criteria met |
| Admin | ✅ Yes | With audit entry |

**Unlock Flow:**
```
BadgeService.checkUnlock(userId, badgeType)
  → Verify criteria from DB
  → If eligible: INSERT INTO badges (user_id, badge_type, ...)
  → Return badge record
```

### 5.2 Permanence Rules

Once a badge is granted:
- It cannot be revoked
- It cannot be downgraded
- It remains visible forever

**Enforcement:**
- Trigger: `badge_no_delete`
- Error: HX501
- No row in `badges` can ever be deleted

**Exception:** Badges granted in error require admin intervention + audit entry explaining the correction (via a "revoked" flag, not deletion).

### 5.3 Why Badges Are Append-Only

Badges represent **achievement milestones**. If badges could be deleted:
- Users lose proof of accomplishment
- Historical records become unreliable
- Disputes about "did I earn this?" become unresolvable

**Rule:** The `badges` table only grows. It never shrinks.

### 5.4 Animation Tracking

Badge unlock animations should play **exactly once** per user per badge.

**Tracking:**
```sql
badges {
  ...
  animation_shown_at TIMESTAMPTZ,  -- NULL = not yet shown
  ...
}
```

**Rule:** Server sets `animation_shown_at` after client confirms animation played. Client checks this before animating.

This prevents:
- Animation replay on re-login
- Animation on multiple devices
- Animation without actual unlock

---

## §6. Stripe & Money Authority

### 6.1 Source of Truth for Money

| Question | Source of Truth |
|----------|-----------------|
| Has user paid? | Stripe PaymentIntent status |
| Is escrow funded? | `escrows.state` = FUNDED |
| Has worker been paid? | Stripe Transfer status |
| What is the amount? | `escrows.amount` (immutable after creation) |

**Hierarchy:**
```
Stripe API > escrows table > backend cache > UI display
```

If Stripe and DB disagree, Stripe wins. Reconciliation job fixes DB.

### 6.2 Why Stripe ≠ Database

Stripe is the **external** source of truth for:
- Payment capture success/failure
- Transfer completion
- Refund status

Database is the **internal** source of truth for:
- Escrow state machine
- Task-escrow linkage
- Business logic decisions

**Rule:** Never trust `escrows.state` without verifying Stripe status for financial operations.

### 6.3 Idempotency Hierarchy

Every Stripe event must be processed exactly once.

**Mechanism:**
```sql
processed_stripe_events {
  event_id VARCHAR(255) PRIMARY KEY,  -- Stripe event ID
  event_type VARCHAR(100),
  processed_at TIMESTAMPTZ,
  result JSONB
}
```

**Flow:**
```
Stripe webhook received
  → Check: event_id in processed_stripe_events?
  → If yes: Return 200 (already processed)
  → If no: Process event, insert into processed_stripe_events, return 200
```

### 6.4 Dispute Authority Boundaries

| Dispute Stage | Authority |
|---------------|-----------|
| Dispute opened | Backend (locks escrow) |
| Evidence collection | AI (proposals) + Users (uploads) |
| Resolution proposal | AI (confidence scored) |
| Resolution decision | Admin (if AI confidence < 0.9) |
| Escrow release/refund | Backend (executes decision) |

**Rule:** AI never directly releases or refunds money. AI proposes; humans or high-confidence automation decides; backend executes.

### 6.5 Partial Refund Logic Ownership

When a dispute results in partial refund:

**Computation:** Backend service calculates split  
**Validation:** Database constraint `escrow_partial_sum_check`  
**Execution:** Backend initiates both Transfer and Refund via Stripe  
**Recording:** `escrows.refund_amount` + `escrows.release_amount`

```sql
CONSTRAINT escrow_partial_sum_check 
  CHECK (
    state != 'REFUND_PARTIAL' OR 
    (refund_amount + release_amount = amount)
  )
```

---

## §7. AI Containment Model

### 7.1 Authority Levels

| Level | Name | Description |
|-------|------|-------------|
| **A0** | Forbidden | AI cannot access or influence |
| **A1** | Read-Only | AI can read for context, cannot write |
| **A2** | Propose | AI generates proposals for review |
| **A3** | Auto-Execute | AI can execute if confidence > threshold |

### 7.2 Domain Mapping

| Domain | AI Level | Rationale |
|--------|----------|-----------|
| XP ledger | A0 | Permanent economic record |
| Escrow state | A0 | Money movement |
| Trust tier changes | A0 | Affects user capabilities |
| Badge grants | A0 | Permanent achievement |
| Task state | A1 | Can read, cannot change |
| Proof analysis | A2 | Can propose accept/reject |
| Dispute resolution | A2 | Can propose, human decides |
| Onboarding inference | A3 | Low stakes, high confidence |
| Content moderation | A2 | Can flag, human reviews |

### 7.3 What AI Is Forbidden To Do

AI systems in HustleXP may **never**:

1. Insert rows into `xp_ledger`
2. Update `escrows.state`
3. Update `users.trust_tier`
4. Insert rows into `badges`
5. Delete any row from any table
6. Execute Stripe API calls directly
7. Approve payments without human checkpoint
8. Override database constraints
9. Access raw payment credentials
10. Operate without audit logging

**Enforcement:** These paths do not exist in code. AI services have no write access to these tables.

### 7.4 Why AI Decisions Must Be Reviewable

Every AI decision creates a record:

```sql
ai_decisions {
  id,
  job_id,              -- Link to ai_jobs
  decision_type,       -- 'ONBOARDING_ROLE', 'PROOF_QUALITY', etc.
  input_hash,          -- Hash of input for reproducibility
  output,              -- The decision (JSONB)
  confidence,          -- 0.0 to 1.0
  model_version,       -- Which model made this
  tokens_used,
  latency_ms,
  created_at
}
```

**Why?**
- Users can appeal decisions
- Admins can audit patterns
- Model drift can be detected
- Legal compliance requires explainability

### 7.5 Evidence Requirements

For AI to make a proposal, it must have:

| Decision Type | Required Evidence |
|---------------|-------------------|
| Proof quality | Photo URLs, GPS data, timestamps |
| Dispute resolution | Both parties' submissions, chat history |
| Content moderation | Flagged content, context |
| Onboarding inference | User responses, timing data |

Evidence is stored in `evidence` table and linked to `ai_decisions`.

### 7.6 Kill Conditions

AI systems are automatically disabled when:

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Error rate | > 5% in 1 hour | Disable auto-execute |
| Latency | > 10s p99 | Fallback to human |
| Confidence drop | Avg < 0.7 for 1 hour | Alert + review |
| Cost spike | > 2× daily budget | Rate limit |

Kill switch: `AI_ENABLED` environment variable. Set to `false` = all AI returns fallback responses.

---

## §8. Failure Modes & Anti-Patterns

These situations must **never** occur. If they do, the system is compromised.

### 8.1 UI Triggering Irreversible State

**Anti-Pattern:**
```javascript
// ILLEGAL: UI directly calling state change
await updateTaskState(taskId, 'COMPLETED');
```

**Correct Pattern:**
```javascript
// LEGAL: UI requests action, server validates and executes
await api.task.complete.mutate({ taskId, proofId });
// Server checks INV-3 before allowing
```

### 8.2 AI Writing Directly to Ledgers

**Anti-Pattern:**
```python
# ILLEGAL: AI service has DB write access
db.execute("INSERT INTO xp_ledger ...")
```

**Correct Pattern:**
```python
# LEGAL: AI returns proposal, backend service decides
proposal = ai_service.compute_xp_recommendation(...)
if proposal.confidence > 0.95:
    xp_service.award(...)  # Backend service with proper authority
```

### 8.3 Backend Bypassing DB Constraints

**Anti-Pattern:**
```typescript
// ILLEGAL: Backend assumes it can bypass constraints
await db.query(`
  UPDATE escrows SET state = 'RELEASED' 
  WHERE id = $1
`, [escrowId]);  // No check if task is COMPLETED
```

**Correct Pattern:**
```typescript
// LEGAL: Let DB enforce constraints
try {
  await db.query(`UPDATE escrows SET state = 'RELEASED' WHERE id = $1`, [escrowId]);
} catch (error) {
  if (error.code === 'HX201') {
    throw new Error('Cannot release: task not completed');
  }
}
```

### 8.4 Admin Silently Mutating History

**Anti-Pattern:**
```sql
-- ILLEGAL: Admin directly modifies ledger
UPDATE xp_ledger SET effective_xp = 0 WHERE id = '...';
```

**Correct Pattern:**
```sql
-- LEGAL: This will fail due to trigger
-- Admin must use compensation entry instead:
INSERT INTO xp_ledger (user_id, task_id, escrow_id, base_xp, effective_xp, reason)
VALUES (..., ..., NULL, -100, -100, 'ADMIN_CORRECTION: ...');
-- Note: This still requires special handling since escrow_id is UNIQUE
```

**For true corrections:** Admin flags the entry and creates audit record explaining the issue. The entry remains but is marked.

### 8.5 Optimistic UI Without Server Confirmation

**Anti-Pattern:**
```javascript
// ILLEGAL: Show XP before server confirms
setUserXP(currentXP + 100);  // Optimistic
await api.xp.award.mutate(...);  // Then call server
```

**Correct Pattern:**
```javascript
// LEGAL: Wait for server confirmation
const result = await api.xp.award.mutate(...);
setUserXP(result.newTotal);  // Server-confirmed value
```

### 8.6 Caching Authoritative State

**Anti-Pattern:**
```javascript
// ILLEGAL: Trusting cached escrow state for decision
const cachedEscrow = localStorage.get('escrow_' + id);
if (cachedEscrow.state === 'FUNDED') {
  proceedWithRelease();  // Using stale data
}
```

**Correct Pattern:**
```javascript
// LEGAL: Always fetch current state for decisions
const escrow = await api.escrow.getById.query({ id });
if (escrow.state === 'FUNDED') {
  await api.escrow.release.mutate({ id });
}
```

---

## §9. Architectural Invariants

These invariants define architectural correctness. Violation = broken system.

### 9.1 Layer Isolation Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| ARCH-1 | Layer N cannot bypass Layer N-1 | Code review, no direct DB access from UI |
| ARCH-2 | Only Layer 0 can enforce invariants | Triggers in schema.sql |
| ARCH-3 | AI (Layer 3) cannot write to Layer 0 | No DB credentials for AI services |
| ARCH-4 | UI (Layer 5) cannot call Layer 0 directly | API gateway required |

### 9.2 Data Flow Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| DATA-1 | Authoritative state flows down only | Layer 0 → 1 → 2 → 4 → 5 |
| DATA-2 | Requests flow up only | Layer 5 → 4 → 2 → 1 → 0 |
| DATA-3 | No layer caches another layer's authoritative state | Code review |
| DATA-4 | All state changes are transactional | DB transactions |

### 9.3 Audit Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| AUDIT-1 | Every XP change creates ledger entry | INV-1, INV-5 |
| AUDIT-2 | Every trust change creates ledger entry | `trust_tier_audit` trigger |
| AUDIT-3 | Every admin action creates audit entry | `admin_actions` table |
| AUDIT-4 | Every AI decision creates decision record | `ai_decisions` table |
| AUDIT-5 | Audit tables are append-only | `*_no_delete` triggers |

### 9.4 Cross-Reference Matrix

| Invariant | PRODUCT_SPEC | schema.sql | This Document |
|-----------|--------------|------------|---------------|
| INV-1 | §2 | L391 | §3.1 |
| INV-2 | §2 | L842 | §6.4 |
| INV-3 | §2 | L869 | §3.1 |
| INV-4 | §2 | L266 | §6.5 |
| INV-5 | §2 | L378 | §3.2 |
| Terminal guards | §3.4, §4.4 | L168, L243 | §8.3 |
| Append-only ledgers | §5.3 | L413, L497, L825 | §3.2, §5.3, §2.6 |
| AI containment | — | — | §7 |
| Layer hierarchy | — | — | §2 |

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial authority specification |

---

**END OF ARCHITECTURE v1.0.0**
