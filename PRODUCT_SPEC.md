# HustleXP Product Specification v1.0.1

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Governance:** This document is the root authority. All code, tests, and subsystems derive from it.

---

## §1. Product Overview

### 1.1 What HustleXP Is

HustleXP is a task marketplace where:

1. **Posters** create tasks and fund escrow
2. **Workers** complete tasks and submit proof
3. **Money** is held in escrow until work is verified
4. **XP** is awarded only after successful payment

The system enforces a strict chain of accountability:

```
Task Created → Escrow Funded → Work Completed → Proof Accepted → Escrow Released → XP Awarded
```

Every step must complete before the next can occur. This is not a guideline—it is mechanically enforced.

### 1.2 What HustleXP Is Not

- ❌ A tipping platform (money is locked, not optional)
- ❌ A social network (XP reflects work, not engagement)
- ❌ A gig economy race-to-bottom (minimum task value enforced)
- ❌ A trust-me system (escrow prevents payment disputes)

### 1.3 Core Principle

> **Money moves only when work is proven. XP exists only when money moved.**

If this principle is violated anywhere in the system, the system is broken.

---

## §2. Core Invariants

These five invariants are **mechanically enforced** at the database layer. They cannot be bypassed by application code, API calls, or UI interactions.

### INV-1: XP Requires Released Escrow

```
XP CANNOT be awarded unless the associated escrow state is RELEASED.
```

**Rationale:** XP represents completed economic value exchange. Without payment, there is no value to represent.

**Enforcement:**
- Database trigger: `xp_requires_released_escrow`
- Error code: `HX101`
- Layer: 0 (PostgreSQL)

**Violation Behavior:**
```sql
-- This MUST fail with HX101:
INSERT INTO xp_ledger (user_id, task_id, escrow_id, ...)
WHERE escrow.state != 'RELEASED';
```

### INV-2: Released Escrow Requires Completed Task

```
Escrow CANNOT transition to RELEASED unless the associated task state is COMPLETED.
```

**Rationale:** Money cannot be released for work that hasn't been verified as complete.

**Enforcement:**
- Database trigger: `escrow_released_requires_completed_task`
- Error code: `HX201`
- Layer: 0 (PostgreSQL)

**Violation Behavior:**
```sql
-- This MUST fail with HX201:
UPDATE escrows SET state = 'RELEASED'
WHERE task.state != 'COMPLETED';
```

### INV-3: Completed Task Requires Accepted Proof

```
Task CANNOT transition to COMPLETED unless at least one associated proof state is ACCEPTED.
```

**Rationale:** Work cannot be marked complete without evidence that was reviewed and approved.

**Enforcement:**
- Database trigger: `task_completed_requires_accepted_proof`
- Error code: `HX301`
- Layer: 0 (PostgreSQL)
- Scope: Only tasks where `requires_proof = TRUE`

**Violation Behavior:**
```sql
-- This MUST fail with HX301:
UPDATE tasks SET state = 'COMPLETED'
WHERE NOT EXISTS (SELECT 1 FROM proofs WHERE task_id = task.id AND state = 'ACCEPTED');
```

### INV-4: Escrow Amount Immutable

```
Escrow amount CANNOT be modified after creation.
```

**Rationale:** The agreed price is the agreed price. Post-hoc manipulation is fraud.

**Enforcement:**
- Database trigger: `escrow_amount_immutable`
- Error code: `HX004`
- Layer: 0 (PostgreSQL)

**Violation Behavior:**
```sql
-- This MUST fail with HX004:
UPDATE escrows SET amount = 9999 WHERE id = 'existing-escrow';
```

### INV-5: XP Idempotent Per Escrow

```
Only ONE XP ledger entry may exist per escrow.
```

**Rationale:** Double-awarding XP for the same work inflates the economy.

**Enforcement:**
- Database constraint: `UNIQUE(escrow_id)` on `xp_ledger`
- Error code: `23505` (PostgreSQL unique violation)
- Layer: 0 (PostgreSQL)

**Violation Behavior:**
```sql
-- This MUST fail with unique constraint violation:
INSERT INTO xp_ledger (escrow_id, ...) 
VALUES ('already-awarded-escrow-id', ...);
```

### Invariant Chain

The invariants form a strict dependency chain:

```
INV-1 depends on INV-2
INV-2 depends on INV-3
INV-3 depends on proof submission
Proof submission depends on task acceptance
Task acceptance depends on escrow funding
```

This means: **XP is mathematically impossible without the full chain completing.**

---

## §3. Task Lifecycle

### 3.1 Task States

| State | Terminal | Description |
|-------|----------|-------------|
| `OPEN` | No | Task created, awaiting worker |
| `ACCEPTED` | No | Worker assigned, escrow must be funded |
| `PROOF_SUBMITTED` | No | Worker submitted proof, awaiting review |
| `DISPUTED` | No | Poster disputed proof, awaiting resolution |
| `COMPLETED` | **Yes** | Proof accepted, ready for payout |
| `CANCELLED` | **Yes** | Task cancelled before completion |
| `EXPIRED` | **Yes** | Deadline passed without completion |

### 3.2 State Transitions

```
OPEN ─────────────────┬──→ ACCEPTED ──→ PROOF_SUBMITTED ──┬──→ COMPLETED
  │                   │         │              │          │
  ├──→ CANCELLED      │         │              ├──→ DISPUTED ──→ COMPLETED
  │                   │         │              │          │
  └──→ EXPIRED        │         └──→ CANCELLED │          └──→ CANCELLED
                      │                        │
                      └────────→ EXPIRED ◄─────┘
```

### 3.3 Transition Rules

| Transition | From | To | Guard |
|------------|------|----|----|
| `accept` | OPEN | ACCEPTED | Worker assigned AND escrow FUNDED |
| `submit_proof` | ACCEPTED | PROOF_SUBMITTED | Proof record exists |
| `approve` | PROOF_SUBMITTED | COMPLETED | Proof state = ACCEPTED (INV-3) |
| `reject` | PROOF_SUBMITTED | ACCEPTED | Rejection reason provided |
| `dispute` | PROOF_SUBMITTED | DISPUTED | Dispute record created |
| `resolve` | DISPUTED | COMPLETED | Dispute resolved in worker favor |
| `cancel` | OPEN, ACCEPTED | CANCELLED | Cancellation allowed |
| `expire` | Any non-terminal | EXPIRED | `deadline < NOW()` |

### 3.4 Terminal State Protection

Once a task reaches a terminal state (`COMPLETED`, `CANCELLED`, `EXPIRED`), **no further modifications are allowed**.

**Enforcement:**
- Database trigger: `task_terminal_guard`
- Error code: `HX001`
- Layer: 0 (PostgreSQL)

```sql
-- This MUST fail with HX001:
UPDATE tasks SET title = 'Hacked' WHERE state = 'COMPLETED';
```

**Exception:** Only `updated_at` timestamp may change (for audit purposes).

---

## §4. Escrow System

### 4.1 Escrow States

| State | Terminal | Description |
|-------|----------|-------------|
| `PENDING` | No | Created, awaiting payment |
| `FUNDED` | No | Payment received, money held |
| `LOCKED_DISPUTE` | No | Frozen during dispute resolution |
| `RELEASED` | **Yes** | Paid to worker |
| `REFUNDED` | **Yes** | Returned to poster |
| `REFUND_PARTIAL` | **Yes** | Split between worker and poster |

### 4.2 State Transitions

```
PENDING ──→ FUNDED ──┬──→ RELEASED
                     │
                     ├──→ LOCKED_DISPUTE ──┬──→ RELEASED
                     │                     │
                     │                     ├──→ REFUNDED
                     │                     │
                     │                     └──→ REFUND_PARTIAL
                     │
                     └──→ REFUNDED
```

### 4.3 Transition Rules

| Transition | From | To | Guard |
|------------|------|----|----|
| `fund` | PENDING | FUNDED | Stripe payment_intent succeeded |
| `release` | FUNDED | RELEASED | Task state = COMPLETED (INV-2) |
| `refund` | FUNDED | REFUNDED | Task cancelled or expired |
| `lock` | FUNDED | LOCKED_DISPUTE | Dispute opened |
| `release` | LOCKED_DISPUTE | RELEASED | Dispute resolved for worker |
| `refund` | LOCKED_DISPUTE | REFUNDED | Dispute resolved for poster |
| `partial` | LOCKED_DISPUTE | REFUND_PARTIAL | Split resolution |

### 4.4 Terminal State Protection

Once escrow reaches a terminal state (`RELEASED`, `REFUNDED`, `REFUND_PARTIAL`), **no further modifications are allowed**.

**Enforcement:**
- Database trigger: `escrow_terminal_guard`
- Error code: `HX002`
- Layer: 0 (PostgreSQL)

```sql
-- This MUST fail with HX002:
UPDATE escrows SET state = 'FUNDED' WHERE state = 'RELEASED';
```

### 4.5 Partial Refund Rules

When escrow enters `REFUND_PARTIAL`:
- `refund_amount` + `release_amount` MUST equal `amount`
- Both fields MUST be non-null
- Enforced by: `escrow_partial_sum_check` constraint

### 4.6 Amount Immutability

The `amount` field is set at creation and cannot be modified.

**Enforcement:** INV-4 (see §2)

### 4.7 Stripe Integration

| Escrow State | Stripe Object | Field |
|--------------|---------------|-------|
| FUNDED | PaymentIntent | `stripe_payment_intent_id` |
| RELEASED | Transfer | `stripe_transfer_id` |
| REFUNDED | Refund | `stripe_refund_id` |

All Stripe events are deduplicated via `processed_stripe_events` table.

---

## §5. XP & Progression

### 5.1 XP Fundamentals

**XP (Experience Points)** represents verified economic value created.

- 1 XP ≈ $0.01 of completed work (base rate)
- XP is **earned**, never purchased
- XP is **permanent** once awarded (ledger is append-only)

### 5.2 XP Award Formula

```
effective_xp = base_xp × streak_multiplier × trust_multiplier
```

| Component | Calculation |
|-----------|-------------|
| `base_xp` | `escrow.amount / 100` (cents to XP) |
| `streak_multiplier` | `1.0 + (streak_days × 0.05)` capped at 2.0 |
| `trust_multiplier` | `1.0` (ROOKIE) → `1.5` (VERIFIED) → `2.0` (TRUSTED) |

### 5.3 XP Ledger

Every XP award creates an immutable ledger entry:

```sql
xp_ledger {
  user_id,           -- Who earned
  task_id,           -- For what task
  escrow_id,         -- Linked escrow (UNIQUE - INV-5)
  base_xp,           -- Raw amount
  effective_xp,      -- After multipliers
  user_xp_before,    -- Snapshot before
  user_xp_after,     -- Snapshot after
  user_level_before, -- Level before
  user_level_after,  -- Level after
  user_streak_at_award -- Streak at time of award
}
```

**Append-Only Enforcement:**
- Database trigger: `xp_ledger_no_delete`
- Error code: `HX102`

```sql
-- This MUST fail with HX102:
DELETE FROM xp_ledger WHERE id = 'any-id';
```

### 5.4 Levels

| Level | XP Required | Title |
|-------|-------------|-------|
| 1 | 0 | Rookie |
| 2 | 100 | Beginner |
| 3 | 300 | Apprentice |
| 4 | 600 | Journeyman |
| 5 | 1,000 | Skilled |
| 6 | 1,500 | Expert |
| 7 | 2,100 | Master |
| 8 | 2,800 | Grandmaster |
| 9 | 3,600 | Legend |
| 10 | 4,500 | Mythic |

Level calculation: `floor(sqrt(total_xp / 25)) + 1` capped at 10.

### 5.5 Streaks

A **streak** is consecutive days with at least one completed task.

- Streak increments when: Task completed AND previous completion was yesterday
- Streak resets to 1 when: Task completed AND gap > 1 day
- Streak preserved via: Grace period (configurable, default 24h)

### 5.6 XP Decay (Future)

XP does not currently decay. If implemented:
- Decay applies to `displayed_xp`, not `total_xp`
- Decay rate: 1% per week of inactivity
- Decay floor: Never below earned XP from last 90 days

---

## §6. Proof System

### 6.1 Proof States

| State | Description |
|-------|-------------|
| `PENDING` | Created, awaiting submission |
| `SUBMITTED` | Photos uploaded, awaiting review |
| `ACCEPTED` | Poster approved proof |
| `REJECTED` | Poster rejected proof |
| `EXPIRED` | Review timeout reached |

### 6.2 Proof Requirements

- Minimum 1 photo required (configurable per task)
- Maximum 5 photos allowed
- GPS metadata captured at upload (if available)
- Timestamp verified server-side

### 6.3 Proof Photos

```sql
proof_photos {
  proof_id,          -- Parent proof
  storage_url,       -- R2/S3 URL
  file_size,         -- Bytes
  mime_type,         -- image/jpeg, image/png
  gps_latitude,      -- Optional
  gps_longitude,     -- Optional
  capture_timestamp, -- From EXIF or upload time
  upload_order       -- Sequence
}
```

### 6.4 Review Timeout

If poster does not review within `review_deadline`:
- Proof auto-transitions to `ACCEPTED`
- Task auto-completes
- Escrow auto-releases

Default timeout: 48 hours.

---

## §7. Dispute System

### 7.1 Dispute Triggers

A dispute may be opened when:
- Poster rejects proof and worker contests
- Worker claims poster is unresponsive
- Either party reports fraud

### 7.2 Dispute Resolution

| Resolution | Escrow Result | XP Result |
|------------|---------------|-----------|
| Worker wins | RELEASED | Awarded |
| Poster wins | REFUNDED | Not awarded |
| Split | REFUND_PARTIAL | Partial (proportional) |

### 7.3 Dispute Authority

Disputes are resolved by:
1. AI triage (confidence > 0.9 → auto-resolve)
2. Human review (confidence < 0.9)
3. Founder escalation (edge cases)

AI may **propose** resolutions. Humans **decide**. Database **enforces**.

---

## §8. User Types

### 8.1 Roles

| Role | Can Post Tasks | Can Work Tasks |
|------|----------------|----------------|
| `poster` | ✅ | ❌ |
| `worker` | ❌ | ✅ |
| `dual` | ✅ | ✅ |

Role is determined during onboarding (see ONBOARDING_SPEC.md).

### 8.2 Trust Tiers

| Tier | Requirements | Benefits |
|------|--------------|----------|
| `ROOKIE` | New user | Base rates |
| `VERIFIED` | 5 completed tasks, ID verified | 1.5× XP multiplier |
| `TRUSTED` | 20 completed, 95%+ approval | 2.0× XP multiplier, priority matching |

Trust tier changes are logged in `trust_ledger` (append-only).

---

## §9. Monetary Rules

### 9.1 Minimum Task Value

- Minimum: $5.00 (500 cents)
- Platform fee: 15% (deducted from escrow before release)
- Worker receives: 85% of posted amount

### 9.2 Currency

All amounts stored in **USD cents** (integers). No floating point.

```sql
amount INTEGER NOT NULL CHECK (amount >= 500)  -- $5 minimum
```

### 9.3 Payment Flow

1. Poster creates task with price
2. Stripe PaymentIntent created for `price + platform_fee`
3. Payment captured → escrow state = FUNDED
4. Task completed → escrow state = RELEASED
5. Stripe Transfer created to worker's connected account
6. Platform fee retained in Stripe balance

---

## §10. Error Codes

| Code | Meaning | Trigger |
|------|---------|---------|
| `HX001` | Task terminal state violation | Modify completed/cancelled/expired task |
| `HX002` | Escrow terminal state violation | Modify released/refunded escrow |
| `HX004` | Escrow amount modification | INV-4 violation |
| `HX101` | XP without released escrow | INV-1 violation |
| `HX102` | XP ledger deletion attempt | Append-only violation |
| `HX201` | Release without completed task | INV-2 violation |
| `HX301` | Complete without accepted proof | INV-3 violation |
| `HX401` | Badge deletion attempt | Append-only violation |
| `HX801` | Admin action audit violation | Append-only violation |

All HX error codes are raised by database triggers. Application code cannot suppress them.

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial authoritative specification |
| 1.0.1 | Jan 2025 | HustleXP Core | Fixed: Error codes aligned with schema.sql (HX004, HX401, HX801) |

---

**END OF PRODUCT_SPEC v1.0.1**
