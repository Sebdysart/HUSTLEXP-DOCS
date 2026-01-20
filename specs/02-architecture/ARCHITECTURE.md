# HustleXP Architecture Specification v1.2.0

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Version:** v1.2.0 (Added §11 Capability Profile Authority, §12 Verification Pipeline Authority, §13 Feed Eligibility Authority)  
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
| 1 | ROOKIE | Default for new users |
| 2 | VERIFIED | 5 completed tasks + ID verification |
| 3 | TRUSTED | 20 completed tasks + 95% approval rate |
| 4 | ELITE | 50 completed tasks + 98% approval rate + verified insurance |

**Note:** Tiers are 1-indexed (1-4) to match database schema and API contract. See schema.sql `users.trust_tier` column.

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

## §10. Live Mode Authority

Live Mode is a **real-time task fulfillment system** that requires special authority considerations.

### 10.1 Core Principle

> Live Mode turns HustleXP into a real-time marketplace — but only when both sides explicitly opt in.

**This is a mode switch, not a feature.** It activates a higher-intensity, higher-trust marketplace layer.

### 10.2 Authority Distribution

| Layer | Authority | Live Mode Scope |
|-------|-----------|-----------------|
| Layer 0 (Database) | Highest | LIVE-1, LIVE-2 enforcement via triggers |
| Layer 1 (Backend) | High | Broadcast routing, geo-matching, session management |
| Layer 2 (API) | Medium | Mode switching, availability state changes |
| Layer 3 (AI) | Advisory Only | Recommendations only, never decisions |
| Layer 4 (Frontend) | Low | UI mode shifts, notification display |

### 10.3 Live Mode Invariants (Cross-Reference)

| ID | Invariant | Spec Reference | Enforcement |
|----|-----------|----------------|-------------|
| LIVE-1 | Live tasks require FUNDED escrow | PRODUCT_SPEC §3.5 | DB trigger (HX901) |
| LIVE-2 | Live tasks require $15 minimum | PRODUCT_SPEC §3.5 | DB constraint (HX902) |
| LIVE-3 | Hustlers must opt in explicitly | PRODUCT_SPEC §3.5 | UI + DB state |
| LIVE-4 | Broadcasts are geo-bounded | PRODUCT_SPEC §3.6 | Backend service |
| LIVE-5 | Broadcasts are time-bounded | PRODUCT_SPEC §3.6 | Backend service |
| LIVE-6 | Session-based, not permanent | PRODUCT_SPEC §3.5 | State machine |
| LIVE-7 | No auto-accept, no AI decisions | Constitutional | Code review |

### 10.4 Broadcast Service Authority

The `LiveBroadcastService` has the following authority:

**CAN:**
- Route broadcasts to hustlers within radius
- Expand radius over time
- Expire broadcasts after TTL
- Track broadcast metrics

**CANNOT:**
- Auto-match hustlers to tasks
- Override hustler availability state
- Bypass escrow funding requirement
- Modify pricing

### 10.5 AI Constraints in Live Mode

AI is **strictly advisory** (A1 authority per AI_INFRASTRUCTURE §3).

**AI CAN:**
- Recommend when to enable Live Mode
- Predict earnings potential
- Suggest optimal availability windows
- Summarize session performance

**AI CANNOT:**
- Force Live Mode on/off
- Auto-accept tasks for hustlers
- Override pricing
- Change broadcast ordering authority
- Make accept/decline decisions

### 10.6 Session Management Authority

| Actor | Can Start Session | Can End Session | Can Force Cooldown |
|-------|-------------------|-----------------|-------------------|
| Hustler | ✅ Yes (toggle ON) | ✅ Yes (toggle OFF) | ❌ No |
| System | ❌ No | ✅ Yes (fatigue rules) | ✅ Yes (fatigue rules) |
| AI | ❌ No | ❌ No | ❌ No |
| Admin | ✅ Override only | ✅ Override only | ✅ Override only |

### 10.7 Abuse Prevention Authority

| Abuse Scenario | Detection Layer | Enforcement Layer |
|---------------|-----------------|-------------------|
| Toggle spam | Layer 1 (Backend) | Layer 0 (DB - HX904) |
| Abandonment pattern | Layer 1 (Backend) | Layer 0 (DB - HX905 ban) |
| Location spoofing | Layer 1 (Backend) | Layer 1 (permanent ban) |
| Fake task spam | Layer 0 (escrow required) | Layer 0 (money committed) |
| Griefing (accept-cancel) | Layer 1 (pattern detection) | Layer 1 (PAUSED state) |

---

## §11. Capability Profile Authority

### 11.1 Core Rule (Non-Negotiable)

> **Capability Profile is never mutated directly. It is always re-derived from verification records.**

If this rule is violated, trust leaks and eligibility becomes inconsistent.

**Cross-Reference:** PRODUCT_SPEC §17.2 (Capability Claims vs Capability Profile)

### 11.2 Source Records vs Derived Records

**Source Records (Mutable Authority):**
- `license_verifications` table — License verification status and expiry
- `insurance_verifications` table — Insurance verification status and expiry
- `background_checks` table — Background check status and expiry
- `users.trust_tier` — Trust tier (managed by TrustService)
- These are the **only** layers that can be directly updated

**Derived Record (Immutable After Recompute):**
- `capability_profiles` table — Single source of truth for eligibility
- **Never edited directly** — Always re-derived from source records
- Recomputed atomically when source records change

**Authority Hierarchy:**
```
Source Records (license_verifications, insurance_verifications, background_checks, users.trust_tier)
  ↓
Recompute Engine (CapabilityProfileService.recompute())
  ↓
Capability Profile (capability_profiles table)
```

Source records > Derived record.

### 11.3 Recompute-Only Rule

**Who Can Trigger Recomputation:**
- Backend service (Layer 1) — `CapabilityProfileService.recompute()`
- Admin (Layer 6) — Via backend service only, with audit
- AI — ❌ No (cannot trigger recompute)
- Frontend — ❌ No (cannot trigger recompute)

**When Recomputation Happens:**
1. License verification approved/rejected/expired
2. Insurance verification approved/rejected/expired
3. Background check approved/rejected/expired
4. Trust tier promotion/demotion (via TrustService)
5. Credential expiry detection (cron job)

**Where Recomputation Happens:**
- Backend service (`CapabilityProfileService.recompute()`)
- Atomic transaction (same transaction as source record update)
- Cannot bypass — No direct UPDATE on `capability_profiles` (except `updated_at` timestamp)

**Recomputation Flow:**
```
Source record change (e.g., license verified)
  → Same transaction: Trigger recompute
  → Load all source records (licenses, insurance, background checks, trust tier)
  → Re-evaluate verified_trades from license_verifications
  → Re-evaluate risk_clearance from trust_tier
  → Re-evaluate insurance_valid from insurance_verifications
  → Re-evaluate background_check_valid from background_checks
  → Update capability_profiles (atomic)
  → Invalidate feed cache
```

### 11.4 Authority Distribution

| Layer | Authority | Can/Cannot |
|-------|-----------|------------|
| Layer 0 (Database) | Enforces constraints | CHECK constraints on `risk_clearance` mapping, FK constraints, triggers preventing direct mutation |
| Layer 1 (Backend) | Recompute engine | Can recompute (`CapabilityProfileService.recompute()`), cannot mutate directly (except `updated_at`) |
| Layer 3 (AI) | Read-only | Can read for context (eligibility inference), cannot trigger recompute |
| Layer 4 (Frontend) | Display only | Cannot compute eligibility, cannot cache profile for decisions (display only) |

**Violation Behavior:**
- Direct UPDATE on `capability_profiles` (except `updated_at`) → Transaction rollback (if constraint violated) or audit log (if application logic bypassed)
- Client-side eligibility computation → Undefined behavior, trust leak
- Caching profile for decision-making → Stale eligibility, unsafe matching

### 11.5 Anti-Patterns (Never Allow)

**❌ Direct UPDATE on `capability_profiles`:**
```typescript
// ILLEGAL: Direct mutation of capability profile
await db.query(`
  UPDATE capability_profiles 
  SET verified_trades = ARRAY['electrician'] 
  WHERE user_id = $1
`, [userId]);
```

**Correct Pattern:**
```typescript
// LEGAL: Update source record, trigger recompute
await db.query(`
  UPDATE license_verifications 
  SET status = 'verified' 
  WHERE id = $1
`, [verificationId]);
await capabilityProfileService.recompute(userId); // Triggers recompute
```

**❌ Client-Side Eligibility Computation:**
```javascript
// ILLEGAL: Computing eligibility in frontend
const isEligible = user.verified_trades.includes(task.required_trade);
if (isEligible) {
  showTask(task);
}
```

**Correct Pattern:**
```javascript
// LEGAL: Server filters feed before sending
const feed = await api.feed.get.query({ userId });
// All tasks in feed are already eligible (server-filtered)
```

**❌ Caching Profile for Decision-Making:**
```javascript
// ILLEGAL: Using cached profile for eligibility decisions
const cachedProfile = localStorage.get('capability_profile');
if (cachedProfile.trust_tier >= task.required_tier) {
  enableApplyButton();
}
```

**Correct Pattern:**
```javascript
// LEGAL: Caching profile for display only
const profile = await api.capabilityProfile.get.query({ userId });
displayTrustTier(profile.trust_tier); // Display only
// Eligibility decisions always made server-side
```

**✅ Caching Profile for Display Only:**
```javascript
// LEGAL: Caching profile for UI display (not decisions)
const profile = await api.capabilityProfile.get.query({ userId });
cacheForDisplay('capability_profile', profile);
// Never use cached profile for eligibility logic
```

### 11.6 Database Schema Authority

**Enforcement Mechanisms:**
- CHECK constraint on `risk_clearance` mapping (INV-ELIGIBILITY-1)
- Foreign key constraints on `verified_trades.verification_id`
- Trigger preventing direct mutation (except `updated_at`)
- Recomputation trigger (on source record changes)

**Cross-Reference:**
- `schema.sql` — `capability_profiles` table definition
- `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` — Complete schema spec

---

## §12. Verification Pipeline Authority

### 12.1 Core Rule (Non-Negotiable)

> **Verification never grants access directly. Verification only updates source-of-truth records. Access is derived exclusively via recomputation.**

If this rule is violated, trust leaks, legal compliance fails, and unsafe matching occurs.

**Cross-Reference:** PRODUCT_SPEC §17.3 (Verification as Prerequisite, Not Access)

### 12.2 Where Truth Lives

**License Verifications:**
- `license_verifications` table — Single source of truth for license verification status
- Mutable layer — Only layer that can be directly updated for license status

**Insurance Verifications:**
- `insurance_verifications` table — Single source of truth for insurance verification status
- Mutable layer — Only layer that can be directly updated for insurance status

**Background Checks:**
- `background_checks` table — Single source of truth for background check status
- Mutable layer — Only layer that can be directly updated for background check status

**These are the only mutable layers for verification status.**

Verification records are the **authority**. Capability profiles are **derived**.

### 12.3 What Triggers Recomputation

**Recomputation is triggered by:**
1. License verification approved/rejected/expired
2. Insurance verification approved/rejected/expired
3. Background check approved/rejected/expired
4. Trust tier promotion/demotion (via TrustService)
5. Credential expiry detection (cron job)

**Recomputation Flow:**
```
Verification record updated (e.g., status = 'verified')
  → Same transaction: Trigger recompute
  → CapabilityProfileService.recompute(userId)
  → Re-evaluate capability profile from all source records
  → Update capability_profiles (atomic)
  → Invalidate feed cache
```

**Rule:** Every verification state change triggers recompute **atomically** (same transaction). No exceptions.

### 12.4 Verification Flow Authority

**End-to-End Flow:**
```
User submits credential (via Settings → Work Eligibility)
  → Backend service creates verification record (status = 'pending')
  → Verification processor runs (automated registry lookup or manual review)
  → Record updated (status = 'verified' or 'failed')
  → Recompute triggered (atomic, same transaction)
  → Feed cache invalidated
```

**Authority Boundaries:**

| Actor | Can Create Verification | Can Approve Verification | Can Trigger Recompute |
|-------|------------------------|--------------------------|----------------------|
| User | ✅ Yes (via Settings UI) | ❌ No | ❌ No |
| Backend Service | ✅ Yes | ✅ Yes (if automated) | ✅ Yes |
| Admin | ✅ Yes | ✅ Yes (manual review) | ✅ Yes |
| AI | ❌ No | ❌ No | ❌ No |
| Frontend | ❌ No | ❌ No | ❌ No |

**Verification Never Grants Access Directly:**
- Verification updates `license_verifications.status`
- Recompute reads `license_verifications` and updates `capability_profiles`
- Feed reads `capability_profiles` to filter tasks
- Access is **derived**, not **granted**

### 12.5 Verification Record Authority

**License Verification Record:**
- Created by: Backend service (on user submission)
- Updated by: Verification processor (automated or manual)
- Cannot be: Created by AI, updated by frontend, bypassed by admin

**Insurance Verification Record:**
- Created by: Backend service (on user submission)
- Updated by: Verification processor (automated OCR or manual review)
- Cannot be: Created by AI, updated by frontend, bypassed without audit

**Background Check Record:**
- Created by: Backend service (on user opt-in + task requirement)
- Updated by: Third-party provider (via webhook or polling)
- Cannot be: Created by AI, updated by frontend, bypassed without audit

### 12.6 Payment Gating (Reference)

**Payment Authority:**
- Payment is downstream of eligibility pre-check, upstream of verification execution
- Payment UI appears only in Settings → Work Eligibility (not in feed, not in task cards)
- Payment unlocks verification processing, not access (access comes from recompute)

**Cross-Reference:**
- `VERIFICATION_PAYMENT_UX_AND_COPY_LOCKED.md` — Payment UX authority spec
- PRODUCT_SPEC §17.6 (No Appeals, No Overrides) — Payment cannot bypass eligibility

**Payment Flow:**
```
User clicks "Verify License" (eligible pre-check passed)
  → Payment screen shown (Settings → Work Eligibility)
  → Payment processed (Stripe)
  → Verification record created (status = 'pending')
  → Verification processor runs (async)
  → Record updated (status = 'verified' or 'failed')
  → Recompute triggered (if verified)
  → Access derived (via capability profile recompute)
```

Payment → Verification → Recomputation → Access (derived).

### 12.7 Anti-Patterns (Never Allow)

**❌ Verification Grants Access Directly:**
```typescript
// ILLEGAL: Granting access from verification service
await db.query(`
  UPDATE license_verifications SET status = 'verified' WHERE id = $1
`, [verificationId]);
await db.query(`
  UPDATE capability_profiles 
  SET verified_trades = ARRAY['electrician'] 
  WHERE user_id = $2
`, [verificationId, userId]); // Direct mutation, bypassing recompute
```

**Correct Pattern:**
```typescript
// LEGAL: Update verification, trigger recompute
await db.query(`
  UPDATE license_verifications SET status = 'verified' WHERE id = $1
`, [verificationId]);
await capabilityProfileService.recompute(userId); // Recompute triggers access
```

**❌ AI Approving Verifications:**
```typescript
// ILLEGAL: AI directly approving verification
const aiResult = await aiService.verifyLicense(licenseDetails);
if (aiResult.confidence > 0.9) {
  await db.query(`
    UPDATE license_verifications SET status = 'verified' WHERE id = $1
  `, [verificationId]);
}
```

**Correct Pattern:**
```typescript
// LEGAL: AI proposes, human/admin decides
const aiProposal = await aiService.proposeLicenseVerification(licenseDetails);
if (aiProposal.confidence > 0.95) {
  // Still requires human/admin review for high-stakes verifications
  await verificationService.submitForReview(verificationId, aiProposal);
}
```

### 12.8 Database Schema Authority

**Enforcement Mechanisms:**
- Foreign key constraints on `verified_trades.verification_id`
- CHECK constraints on verification status transitions
- Trigger enforcing recompute on verification state change
- Trigger preventing direct mutation of `capability_profiles`

**Cross-Reference:**
- `schema.sql` — `license_verifications`, `insurance_verifications`, `background_checks` tables
- `VERIFICATION_PIPELINE_LOCKED.md` — Complete pipeline spec
- §11 (Capability Profile Authority) — Recomputation destination

---

## §13. Feed Eligibility Authority

### 13.1 Core Rule (Non-Negotiable)

> **If a task appears in a user's feed, the user is eligible to accept it. There are no exceptions, warnings, disabled buttons, or soft blocks.**

If this rule is violated, trust leaks, users experience rejection, and the system becomes untrustworthy.

**Cross-Reference:** PRODUCT_SPEC §17.4 (Feed Shows Only Eligible Gigs)

### 13.2 Feed Is a Join, Not a Filter

**Feed Query Structure:**
```sql
SELECT t.* 
FROM tasks t
JOIN capability_profiles cp ON cp.user_id = :user_id
WHERE t.location_state = cp.location_state
  AND (t.required_trade IS NULL OR t.required_trade = ANY(cp.verified_trades))
  AND cp.trust_tier >= t.required_trust_tier
  AND (t.insurance_required = FALSE OR cp.insurance_valid = TRUE)
  AND (t.background_check_required = FALSE OR cp.background_check_valid = TRUE)
  AND t.status = 'open'
ORDER BY t.created_at DESC
LIMIT :limit;
```

**Join Conditions Enforce Eligibility:**
- Location state match (`t.location_state = cp.location_state`)
- Trade requirement match (`t.required_trade = ANY(cp.verified_trades)`)
- Trust tier requirement (`cp.trust_tier >= t.required_trust_tier`)
- Insurance requirement (`t.insurance_required = FALSE OR cp.insurance_valid = TRUE`)
- Background check requirement (`t.background_check_required = FALSE OR cp.background_check_valid = TRUE`)

**If Join Fails:**
- Task doesn't appear in feed (doesn't exist for that user)
- No post-filtering in application code
- No "disabled" task cards
- No "you don't qualify" messages

**Feed is a SQL join. If the join fails, the task is invisible to that user.**

### 13.3 Eligibility Predicate Location

**Primary Location: SQL Query (WHERE Clause)**
- Feed query filters tasks by eligibility at SQL level
- Join conditions enforce all eligibility rules
- No tasks are fetched if join fails
- Authority: Layer 0 (Database) + Layer 1 (Backend service)

**Secondary Location: `isEligible()` Pure Function (Defense-in-Depth)**
- Pure function (deterministic, side-effect free)
- Compares task requirements against capability profile
- Returns boolean (eligible or not)
- Used by: Feed query (SQL filter), task detail prefetch, apply endpoint
- Authority: Layer 1 (Backend service)

**Function Signature:**
```typescript
function isEligible(
  task: Task,
  capabilityProfile: CapabilityProfile
): boolean
```

**Cannot Be in Client:**
- Eligibility computation never happens in frontend
- Client receives pre-filtered tasks (all eligible)
- Client never decides eligibility
- Client never shows disabled buttons

### 13.4 Defense-in-Depth (Apply Endpoint Recheck)

**Even Though Feed Is Filtered:**
- Apply endpoint rechecks eligibility before accepting task
- Protects against: Stale cache, race conditions, malicious clients
- Location: Backend service (Layer 1)
- Failure behavior: 403 Forbidden (not "try anyway")

**Apply Endpoint Flow:**
```
Client requests task acceptance
  → Backend service loads latest capability profile
  → Backend service checks eligibility (isEligible(task, profile))
  → If eligible: Accept task, update task.assigned_to
  → If not eligible: Return 403 Forbidden (do not accept)
```

**Why Recheck?**
- Feed cache may be stale (TTL: 60 seconds)
- Capability profile may have changed between feed load and apply
- Client may be malicious (attempting to accept ineligible tasks)
- Race conditions (multiple users applying simultaneously)

**Recheck Never Shows UI:**
- If recheck fails, return 403 Forbidden
- No "you're not eligible" message
- No "try anyway" button
- If task was in feed but recheck fails, feed cache was stale (refresh feed)

### 13.5 Authority Chain

**Eligibility Determination Flow:**
```
Tasks (immutable requirements: trade, trust tier, insurance, background check, location)
  ↓
Capability Profile (latest derived snapshot from §11)
  ↓
Eligibility Resolver (pure function isEligible(), SQL WHERE clause)
  ↓
Feed Query (SQL join: tasks JOIN capability_profiles)
  ↓
Client Render (dumb: displays pre-filtered tasks)
```

**Authority Distribution:**

| Layer | Authority | Responsibility |
|-------|-----------|----------------|
| Layer 0 (Database) | SQL WHERE clause | Joins tasks with profiles, filters by eligibility |
| Layer 1 (Backend) | `isEligible()` function | Defense-in-depth recheck (apply endpoint) |
| Layer 2 (API) | Request routing | Routes feed request to backend service |
| Layer 4 (Frontend) | Display only | Renders pre-filtered tasks (never computes eligibility) |

**Client Never Decides Eligibility:**
- Client receives feed (pre-filtered by server)
- Client displays tasks (all eligible)
- Client requests acceptance (server rechecks)
- Client never computes eligibility

### 13.6 Cache Strategy

**Feed Cache Key:**
```
feed:{user_id}:{feed_mode}:{page_cursor_hash}
```

**Cache TTL:**
- Normal feed: 60 seconds
- Urgent feed: 15 seconds
- Nearby feed: 60 seconds (location may change)

**Cache Invalidation Triggers:**
1. Capability profile recompute (verification change, trust tier change, expiry)
2. Task created/closed (new tasks appear, closed tasks disappear)
3. Verification expiry (credentials expire, tasks disappear)

**Cache Invalidation Rule:**
- If in doubt, invalidate. Freshness > cost.
- Feed cache staleness can cause users to see ineligible tasks (apply endpoint recheck prevents acceptance, but feed should be accurate)

**Cache Authority:**
- Backend service (Layer 1) manages cache
- Cache invalidation triggered by recompute (same transaction)
- Frontend never caches feed for decisions (display only)

### 13.7 Forbidden Patterns (Never Allow)

**❌ Fetch All Tasks Then Filter in JS:**
```typescript
// ILLEGAL: Post-filtering in application code
const allTasks = await db.query('SELECT * FROM tasks WHERE status = "open"');
const eligibleTasks = allTasks.filter(task => isEligible(task, profile));
return eligibleTasks;
```

**Correct Pattern:**
```typescript
// LEGAL: Filter at SQL level (join enforces eligibility)
const eligibleTasks = await db.query(`
  SELECT t.* FROM tasks t
  JOIN capability_profiles cp ON cp.user_id = $1
  WHERE t.location_state = cp.location_state
    AND (t.required_trade IS NULL OR t.required_trade = ANY(cp.verified_trades))
    -- ... other eligibility conditions
`, [userId]);
```

**❌ "Show But Disable" UI:**
```javascript
// ILLEGAL: Showing ineligible tasks with disabled buttons
const feed = await fetchAllTasks();
feed.forEach(task => {
  const isEligible = computeEligibility(task, userProfile);
  if (isEligible) {
    renderTask(task, { enableApply: true });
  } else {
    renderTask(task, { enableApply: false }); // Never show ineligible tasks
  }
});
```

**Correct Pattern:**
```javascript
// LEGAL: Server filters feed before sending (only eligible tasks)
const feed = await api.feed.get.query({ userId });
// All tasks in feed are eligible (server-filtered)
feed.forEach(task => {
  renderTask(task, { enableApply: true }); // All tasks are eligible
});
```

**❌ "Apply Anyway" Flows:**
```typescript
// ILLEGAL: Allowing users to apply to ineligible tasks
if (!isEligible(task, profile)) {
  return {
    error: 'You are not eligible for this task',
    action: 'request_exception' // Never allow this
  };
}
```

**Correct Pattern:**
```typescript
// LEGAL: Return 403 Forbidden (no "try anyway")
if (!isEligible(task, profile)) {
  return new ForbiddenError('Task not eligible'); // No exception path
}
```

**❌ Trust Logic in Client:**
```javascript
// ILLEGAL: Computing eligibility in frontend
const canAccessHighRiskTasks = user.trust_tier >= 'D';
if (canAccessHighRiskTasks) {
  showHighRiskTasks();
}
```

**Correct Pattern:**
```javascript
// LEGAL: Server filters feed (trust logic in SQL WHERE clause)
const feed = await api.feed.get.query({ userId });
// Feed only contains tasks user is eligible for (trust tier checked server-side)
renderFeed(feed);
```

**❌ Eligibility Computation in Frontend:**
```javascript
// ILLEGAL: Computing eligibility client-side
function isTaskEligible(task, user) {
  return user.verified_trades.includes(task.required_trade)
    && user.trust_tier >= task.required_trust_tier
    && (task.insurance_required ? user.insurance_valid : true);
}
```

**Correct Pattern:**
```javascript
// LEGAL: Server computes eligibility (SQL join filters feed)
const feed = await api.feed.get.query({ userId });
// Feed is pre-filtered (eligibility computed server-side)
renderFeed(feed);
```

### 13.8 Database Schema Authority

**Enforcement Mechanisms:**
- SQL WHERE clause enforces eligibility (join conditions)
- Foreign key constraints on task requirements (trade, trust tier, insurance, background check)
- CHECK constraints on task requirements (immutable after creation)
- Trigger preventing task requirement downgrade

**Cross-Reference:**
- `schema.sql` — `tasks` table definition, `capability_profiles` table definition
- `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` — Complete feed query spec
- §11 (Capability Profile Authority) — Profile source
- §12 (Verification Pipeline Authority) — Recomputation triggers

---

## §14. Task State Machine Authority

### 14.1 Canonical State Machine

**Execution Flow (Canonical):**
```
OPEN → EN_ROUTE (ACCEPTED) → WORKING → COMPLETED
```

**Terminal States:**
- `COMPLETED` - Task finished successfully
- `CANCELLED` - Task terminated by poster/admin
- `EXPIRED` - Task deadline exceeded

**State Mappings:**
- `OPEN` (schema) = `AVAILABLE` (conceptual)
- `ACCEPTED` (schema) = `EN_ROUTE` (conceptual)
- `WORKING` (schema) = `WORKING` (conceptual)
- `COMPLETED` (schema) = `COMPLETED` (conceptual)

**Legacy States (kept for compatibility):**
- `PROOF_SUBMITTED` - Awaiting poster review (not used in execution flow)
- `DISPUTED` - Under admin review (not used in execution flow)

### 14.2 State Transitions (Server-Enforced)

**Legal Transitions:**
- `OPEN` → `ACCEPTED` (EN_ROUTE) - Hustler accepts task
- `ACCEPTED` (EN_ROUTE) → `WORKING` - Hustler arrives onsite
- `WORKING` → `COMPLETED` - Task completed

**Terminal State Rule:**
- Once a task reaches `COMPLETED`, `CANCELLED`, or `EXPIRED`, no further state changes are allowed
- Database trigger `task_terminal_guard` enforces this at Layer 0

### 14.3 Execution Timestamps (Canonical)

**Timestamps (first-class fields):**
- `accepted_at` - Hustler accepted task
- `en_route_at` - Hustler started travel (set on accept)
- `arrived_at` - Hustler arrived onsite
- `completed_at` - Task completed

**Purpose:**
- Accurate SLAs (time tracking)
- Dispute timelines (evidence of timestamps)
- Analytics (execution duration analysis)
- Future trust adjustments (performance metrics)

**Rule:** Do not overload `updated_at` for execution events. Use dedicated timestamp fields.

### 14.4 Assignment Field (Canonical)

**Single Source of Truth:**
- `assigned_hustler_id` - Canonical assignment field
- `worker_id` - Deprecated (legacy, read-only for compatibility)

**Authority:**
- All execution authority checks reference `assigned_hustler_id`
- Only `assigned_hustler_id` is written on task acceptance
- `worker_id` is never written (leave untouched)

### 14.5 State Transition Enforcement

**Location:** Backend handlers (Layer 1) + Database triggers (Layer 0)

**Enforcement Mechanisms:**
1. **Handler-level validation:**
   - State machine helper asserts legal transitions
   - Illegal transitions rejected with 409 Conflict

2. **Database-level enforcement:**
   - CHECK constraint on `tasks.state`
   - Trigger `task_terminal_guard` prevents terminal state mutations

**Example (Handler Validation):**
```typescript
// Legal transitions are enforced server-side
const LEGAL_TRANSITIONS: Record<TaskState, TaskState[]> = {
  OPEN: ['ACCEPTED'],
  ACCEPTED: ['WORKING'],
  WORKING: ['COMPLETED'],
  // ...
};

function assertTransition(from: TaskState, to: TaskState) {
  if (!LEGAL_TRANSITIONS[from]?.includes(to)) {
    throw new TRPCError({ code: 'CONFLICT', message: 'Illegal transition' });
  }
}
```

### 14.6 Maps Gate (Execution Visualization)

**Unlock Condition:**
- Maps render **only** when `tasks.getState === EN_ROUTE` (ACCEPTED in schema)

**Hustler POV:**
- Route to jobsite
- ETA
- **Forbidden:** Discovery, eligibility checks, task lists

**Poster POV:**
- Hustler live location
- Status ("On the way")
- **Forbidden:** Control, messaging that implies permission changes

**Authority Rule:** Maps are **execution visualizations**, not navigation or discovery surfaces.

### 14.7 Forbidden State Writes

**Phase N2.2 Rules (Execution-Critical Writes Only):**
- ✅ Task lifecycle state writes (accept, arrived, complete)
- ❌ Capability profile writes (recomputed only)
- ❌ Verification table writes (separate pipeline)
- ❌ Payout logic (handled later)
- ❌ XP grants (handled later)
- ❌ Trust tier changes (handled later)

**Reference:** Phase N2.2 Execution-Critical Writes Checklist

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial authority specification |
| 1.1.0 | Jan 2025 | HustleXP Core | Added: §10 Live Mode Authority |
| 1.2.0 | Jan 2025 | HustleXP Core | Added: §11 Capability Profile Authority, §12 Verification Pipeline Authority, §13 Feed Eligibility Authority |
| 1.3.0 | Jan 2025 | HustleXP Core | Added: §14 Task State Machine Authority (Phase N2.2 cleanup) |

---

**END OF ARCHITECTURE v1.3.0**
