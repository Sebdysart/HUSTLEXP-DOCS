# HustleXP Specification Clarifications v1.0.0

**STATUS: CONSTITUTIONAL CLARIFICATION**
**Purpose:** Resolve ambiguities and conflicts between spec documents
**Authority:** This document takes precedence when specs conflict

---

## Table of Contents

1. [Eligibility Precedence](#eligibility-precedence)
2. [Rating System Timing](#rating-system-timing)
3. [XP Award Timing](#xp-award-timing)
4. [Trust Tier Definitions](#trust-tier-definitions)
5. [Price Minimums](#price-minimums)
6. [State Transition Rules](#state-transition-rules)

---

## 1. Eligibility Precedence

### Conflict
PRODUCT_SPEC §8.2 implies trust tier alone determines task eligibility, while §17.1 describes license requirements. The precedence was unclear.

### Resolution

**Eligibility is checked in this order (ALL must pass):**

```
1. Location State Match (REQUIRED)
   - Hustler's work_state must match task's location_state
   - No exceptions

2. Trade Verification (IF REQUIRED)
   - If task.required_trade is set:
     → Hustler must have VERIFIED status for that trade in that state
   - License verification supersedes trust tier for licensed work

3. Trust Tier (ALWAYS CHECKED)
   - Hustler's trust_tier >= task.required_trust_tier
   - Trust tier is necessary but not sufficient for licensed work

4. Risk Clearance (ALWAYS CHECKED)
   - Hustler's risk_clearance must include task.risk_level
   - Derived from trust tier (see mapping below)

5. Insurance (IF REQUIRED)
   - If task.insurance_required = true:
     → Hustler must have insurance_valid = true for the trade

6. Background Check (IF REQUIRED)
   - If task.background_check_required = true:
     → Hustler must have background_check_valid = true
```

### License vs Trust Tier Rule

**CLARIFICATION:** License verification and trust tier are independent requirements.

```
A task requiring "electrician" trade:
  - Trust tier 4 hustler WITHOUT verified electrician license: NOT ELIGIBLE
  - Trust tier 2 hustler WITH verified electrician license: ELIGIBLE (if tier >= required_trust_tier)
```

**Implementation:**
```typescript
function isEligible(hustler: CapabilityProfile, task: Task): boolean {
  // 1. Location check
  if (hustler.location_state !== task.location_state) return false;

  // 2. Trade verification (if required)
  if (task.required_trade) {
    const hasVerifiedTrade = hustler.verified_trades.some(
      t => t.trade === task.required_trade &&
           t.state === task.location_state &&
           t.status === 'verified' &&
           (t.expires_at === null || new Date(t.expires_at) > new Date())
    );
    if (!hasVerifiedTrade) return false;
  }

  // 3. Trust tier
  if (hustler.trust_tier < task.required_trust_tier) return false;

  // 4. Risk clearance
  if (!hustler.risk_clearance.includes(task.risk_level)) return false;

  // 5. Insurance
  if (task.insurance_required && !hustler.insurance_valid) return false;

  // 6. Background check
  if (task.background_check_required && !hustler.background_check_valid) return false;

  return true;
}
```

---

## 2. Rating System Timing

### Conflict
PRODUCT_SPEC mentions "blind ratings" but the exact timing of when ratings are revealed was not specified.

### Resolution

**Blind Rating Rules:**

```
1. Rating Window Opens:
   - When task.state transitions to COMPLETED
   - Window duration: 7 days

2. Rating Submission:
   - Both poster and hustler can submit ratings independently
   - Ratings are stored with is_blind = true

3. Rating Reveal:
   REVEAL_CONDITION = (both_parties_rated) OR (7_days_elapsed)

   If REVEAL_CONDITION met:
     - Both ratings become visible (is_blind = false)
     - is_public = true (visible to rated party)

4. Auto-Rating:
   If only one party rated after 7 days:
     - Other party receives auto-generated 4-star rating
     - is_auto_rated = true

5. No-Rating Scenario:
   If neither party rated after 7 days:
     - No ratings created
     - Does not affect trust tier or statistics
```

**State Machine:**
```
┌─────────────────────────────────────────────────────────────────┐
│                     RATING STATE MACHINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [TASK_COMPLETED]                                                │
│        │                                                         │
│        ▼                                                         │
│  ┌──────────────────────┐                                        │
│  │  RATING_WINDOW_OPEN  │◄───────────────────────────────────┐   │
│  │  (7 day timer start) │                                    │   │
│  └──────────┬───────────┘                                    │   │
│             │                                                 │   │
│    ┌────────┴────────┐                                       │   │
│    │                 │                                       │   │
│    ▼                 ▼                                       │   │
│  [Poster Rates]   [Hustler Rates]                           │   │
│    │                 │                                       │   │
│    └────────┬────────┘                                       │   │
│             │                                                 │   │
│             ▼                                                 │   │
│  ┌──────────────────────┐                                    │   │
│  │   BOTH_RATED         │──── REVEAL immediately ────────────┘   │
│  └──────────────────────┘                                        │
│                                                                  │
│        OR                                                        │
│                                                                  │
│  [7 days elapsed]                                                │
│        │                                                         │
│        ▼                                                         │
│  ┌──────────────────────┐                                        │
│  │  WINDOW_CLOSED       │                                        │
│  │  - Auto-rate missing │                                        │
│  │  - Reveal all        │                                        │
│  └──────────────────────┘                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Database Update:**
```sql
-- Cron job: runs daily to process rating reveals
UPDATE task_ratings
SET
  is_blind = false,
  is_public = true,
  updated_at = NOW()
WHERE task_id IN (
  SELECT DISTINCT task_id
  FROM task_ratings
  WHERE is_blind = true
  GROUP BY task_id
  HAVING COUNT(*) = 2  -- Both parties rated
     OR MIN(created_at) < NOW() - INTERVAL '7 days'  -- Window elapsed
);
```

---

## 3. XP Award Timing

### Conflict
Unclear when exactly XP is awarded: when escrow is released, when funds settle, or when task completes.

### Resolution

**XP is awarded when escrow state transitions to RELEASED.**

This is already enforced by INV-1 in schema.sql, but for clarity:

```
XP Award Trigger: escrow.state = 'RELEASED'

Timeline:
  1. Poster accepts proof → task.state = COMPLETED
  2. task.complete() releases escrow → escrow.state = RELEASED
  3. Escrow release triggers XP calculation → xp_ledger entry created
  4. XP is immediately visible to user

XP is NOT tied to:
  - Stripe transfer completion (async, may take days)
  - Hustler withdrawing funds
  - Rating submission
```

**Implementation (already in schema.sql):**
```sql
-- INV-1: XP requires RELEASED escrow (trigger already exists)
CREATE OR REPLACE FUNCTION enforce_xp_requires_released_escrow()
RETURNS TRIGGER AS $$
DECLARE
    escrow_state VARCHAR(20);
BEGIN
    SELECT state INTO escrow_state FROM escrows WHERE id = NEW.escrow_id;

    IF escrow_state != 'RELEASED' THEN
        RAISE EXCEPTION 'INV-1_VIOLATION: Cannot award XP - escrow must be RELEASED';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Sequence Diagram:**
```
Poster          Backend         Database        Hustler UI
  │                │                │                │
  │ Accept Proof   │                │                │
  ├───────────────►│                │                │
  │                │ task.complete()│                │
  │                ├───────────────►│                │
  │                │                │ UPDATE task    │
  │                │                │ state=COMPLETED│
  │                │                │                │
  │                │ escrow.release()               │
  │                ├───────────────►│                │
  │                │                │ UPDATE escrow  │
  │                │                │ state=RELEASED │
  │                │                │                │
  │                │                │ INV-1 CHECK    │
  │                │                │ (escrow=RELEASED)
  │                │                │                │
  │                │ INSERT xp_ledger               │
  │                ├───────────────►│                │
  │                │                │ ✓ XP Awarded   │
  │                │                │                │
  │                │                │                │ XP Update Event
  │                │                ├───────────────►│
  │                │                │                │ Show +XP animation
```

---

## 4. Trust Tier Definitions

### Conflict
Different parts of spec used different tier numbering (1-4 numeric vs A-D letter).

### Resolution

**Canonical Trust Tier Mapping:**

| Numeric | Letter | Name | Risk Clearance |
|---------|--------|------|----------------|
| 1 | A | ROOKIE | ['low'] |
| 2 | B | VERIFIED | ['low', 'medium'] |
| 3 | C | TRUSTED | ['low', 'medium'] |
| 4 | D | ELITE | ['low', 'medium', 'high'] |

**Usage Rules:**
- Database stores: numeric (1-4)
- API returns: numeric (1-4)
- capability_profiles uses: letter (A-D) - but this should be migrated
- UI displays: name (ROOKIE, VERIFIED, TRUSTED, ELITE)

**Migration Required:**
```sql
-- Standardize capability_profiles to use numeric trust_tier
ALTER TABLE capability_profiles
  DROP CONSTRAINT IF EXISTS capability_profiles_trust_tier_check;

ALTER TABLE capability_profiles
  ALTER COLUMN trust_tier TYPE INTEGER
  USING CASE
    WHEN trust_tier = 'A' THEN 1
    WHEN trust_tier = 'B' THEN 2
    WHEN trust_tier = 'C' THEN 3
    WHEN trust_tier = 'D' THEN 4
    ELSE trust_tier::INTEGER
  END;

ALTER TABLE capability_profiles
  ADD CONSTRAINT capability_profiles_trust_tier_check
  CHECK (trust_tier >= 1 AND trust_tier <= 4);
```

---

## 5. Price Minimums

### Conflict
Different minimums mentioned in different places.

### Resolution

**Canonical Price Minimums:**

| Mode | Minimum (cents) | Minimum (USD) | Rationale |
|------|-----------------|---------------|-----------|
| STANDARD | 500 | $5.00 | Covers platform fee + makes escrow worthwhile |
| LIVE | 1500 | $15.00 | Higher urgency premium, covers expedited matching |

**Enforcement Points:**
1. API validation (API_CONTRACT.md task.create)
2. Database constraint (schema.sql LIVE-2 trigger)
3. Frontend form validation (prevent submission)

**Code Reference:**
```typescript
// Backend validation
const PRICE_MINIMUMS = {
  STANDARD: 500,  // $5.00
  LIVE: 1500,     // $15.00
} as const;

function validateTaskPrice(price: number, mode: 'STANDARD' | 'LIVE'): void {
  const minimum = PRICE_MINIMUMS[mode];
  if (price < minimum) {
    throw new ValidationError(`Minimum price for ${mode} tasks is $${minimum / 100}`);
  }
}
```

---

## 6. State Transition Rules

### Conflict
Some edge cases in state transitions were not explicitly defined.

### Resolution

**Task State Transitions (Definitive):**

```
                                    ┌──────────────┐
                                    │   EXPIRED    │
                                    │  (terminal)  │
                                    └──────────────┘
                                          ▲
                                          │ deadline passed
                                          │ (cron job)
┌──────────┐    accept    ┌───────────┐   │
│   OPEN   │─────────────►│ ACCEPTED  │───┘
│          │              │           │
└────┬─────┘              └─────┬─────┘
     │                          │
     │ cancel                   │ submit_proof
     │ (poster only)            │ (worker only)
     ▼                          ▼
┌──────────────┐         ┌─────────────────┐
│  CANCELLED   │         │ PROOF_SUBMITTED │
│  (terminal)  │         │                 │
└──────────────┘         └────────┬────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    │ accept      │ reject      │ open_dispute
                    │ (poster)    │ (poster)    │ (either)
                    ▼             ▼             ▼
             ┌───────────┐  ┌───────────┐  ┌───────────┐
             │ COMPLETED │  │ ACCEPTED  │  │ DISPUTED  │
             │ (terminal)│  │ (re-do)   │  │           │
             └───────────┘  └───────────┘  └─────┬─────┘
                                                 │
                                                 │ resolve
                                                 │ (admin)
                                                 ▼
                                    ┌───────────────────────┐
                                    │ COMPLETED / CANCELLED │
                                    │     (terminal)        │
                                    └───────────────────────┘
```

**Escrow State Transitions:**

```
┌─────────┐   fund    ┌────────┐
│ PENDING │─────────► │ FUNDED │
└────┬────┘           └────┬───┘
     │                     │
     │ cancel              ├──────────────┬──────────────┐
     │ (before fund)       │              │              │
     ▼                     │ release      │ refund       │ dispute
┌──────────────┐          │ (task done)  │ (cancel)     │
│  CANCELLED   │          ▼              ▼              ▼
│  (terminal)  │   ┌──────────┐   ┌──────────┐   ┌─────────────┐
└──────────────┘   │ RELEASED │   │ REFUNDED │   │LOCKED_DISPUTE│
                   │(terminal)│   │(terminal)│   └──────┬──────┘
                   └──────────┘   └──────────┘          │
                                                        │ resolve
                                                        ▼
                                              ┌──────────────────┐
                                              │ RELEASED/REFUNDED│
                                              │ /REFUND_PARTIAL  │
                                              │    (terminal)    │
                                              └──────────────────┘
```

**Proof Rejected → Task Re-do:**
When poster rejects proof:
1. Proof state → REJECTED
2. Task state → ACCEPTED (worker can try again)
3. Worker can submit new proof
4. Original proof record preserved for audit

**Cron Jobs Required:**
```typescript
// 1. Task expiration (runs every 5 minutes)
async function expireOverdueTasks() {
  await db.query(`
    UPDATE tasks
    SET state = 'EXPIRED', expired_at = NOW()
    WHERE state = 'OPEN'
      AND deadline < NOW()
  `);
}

// 2. Rating window closure (runs daily)
async function processRatingWindows() {
  // See Rating System Timing section above
}

// 3. Live broadcast expiration (runs every 30 seconds)
async function expireLiveBroadcasts() {
  await db.query(`
    UPDATE live_broadcasts
    SET expired_at = NOW()
    WHERE expired_at IS NULL
      AND accepted_at IS NULL
      AND started_at < NOW() - INTERVAL '5 minutes'
  `);
}
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial clarifications for eligibility, ratings, XP timing, trust tiers, prices, state transitions |

---

**END OF SPECIFICATION CLARIFICATIONS**
