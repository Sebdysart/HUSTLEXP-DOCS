# HustleXP Product Specification v1.6.0

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** February 2026  
**Version:** v1.6.0 (§21 Marketplace Safety Invariants, §22 Dispute Protocol, §23 Sybil Prevention, §24 Email Verification, §25 I18n. 42-gap audit resolved.)  
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

These invariants are **mechanically enforced** at the database layer. They cannot be bypassed by application code, API calls, or UI interactions.

**Core Invariants (INV-1 through INV-5):** Enforce the money→work→proof→XP chain.

**Eligibility Invariants (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8):** Enforce that task access is impossible without proper credentials and trust tier.

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

### INV-ELIGIBILITY-1: Trust Tier → Risk Clearance Mapping (Immutable)

```
Trust tier determines maximum risk clearance level. The mapping is immutable and cannot be overridden.
```

**Rationale:** Users can only access tasks that match their trust tier. Higher trust tiers unlock higher risk tasks. This mapping ensures legal compliance and prevents unsafe task matching.

**Enforcement:**
- Database check constraint on capability profiles
- Trust tier 1 (ROOKIE) → low risk only
- Trust tier 2 (VERIFIED) → low and medium risk
- Trust tier 3 (TRUSTED) → low and medium risk
- Trust tier 4 (ELITE) → low, medium, and high risk
- Trust tier 5 (MASTER) → low, medium, high, and critical risk

**Violation Behavior:**
If violated, users could access tasks they are not legally or safely qualified for, leading to liability and trust erosion.

---

### INV-ELIGIBILITY-2: Verified Trades Must Have Active Verification

```
A verified trade cannot exist without an active, approved license verification.
```

**Rationale:** Users cannot claim to be qualified for a trade without proof. The system requires verified credentials before allowing access to trade-specific tasks.

**Enforcement:**
- Database foreign key constraint linking verified trades to license verifications
- Capability profile recomputation validates all verified trades have active verifications

**Violation Behavior:**
If violated, users could access licensed trade tasks without valid credentials, leading to legal violations and safety risks.

---

### INV-ELIGIBILITY-3: Expired Credentials Invalidate Capabilities

```
Expired licenses, insurance, or background checks immediately remove access to tasks requiring those credentials.
```

**Rationale:** Credentials have expiry dates. Once expired, they are no longer valid for task eligibility. The system must enforce this automatically to maintain legal compliance.

**Enforcement:**
- Automated expiry detection checks credential expiration dates
- Capability profile recomputation removes expired credentials from eligibility
- Expired credentials are silently removed from user capabilities

**Violation Behavior:**
If violated, users with expired credentials could continue accessing tasks they are no longer qualified for, leading to legal liability and safety violations.

---

### INV-ELIGIBILITY-4: Insurance Validity Gated by Verification

```
Insurance can only be considered valid if an approved insurance verification record exists and is not expired.
```

**Rationale:** Insurance is required for certain high-risk tasks. Users cannot claim insurance without providing proof of coverage that has been verified by the system.

**Enforcement:**
- Database trigger prevents insurance verification without corresponding verified trade
- Capability profile recomputation validates insurance status against verification records
- Insurance validity is derived from verification status, never set directly

**Violation Behavior:**
If violated, users could access high-risk tasks without valid insurance coverage, exposing the platform and users to financial and legal risk.

---

### INV-ELIGIBILITY-5: Background Check Validity Gated by Verification

```
Background check can only be considered valid if an approved background check verification record exists and is not expired.
```

**Rationale:** Critical-risk tasks (such as in-home care) require background checks. Users cannot claim background check clearance without verified proof.

**Enforcement:**
- Database constraint ensures only one active background check per user
- Capability profile recomputation validates background check status against verification records
- Background check validity is derived from verification status, never set directly

**Violation Behavior:**
If violated, users could access critical-risk tasks without proper background checks, creating safety risks for vulnerable populations.

---

### INV-ELIGIBILITY-6: Location State Must Be Valid US State Code

```
User location state must be a valid 2-character US state code for task matching and jurisdiction enforcement.
```

**Rationale:** Licenses, insurance, and task requirements are state-scoped. The system must validate location states to ensure proper jurisdiction matching and legal compliance.

**Enforcement:**
- Database check constraint ensures location state is exactly 2 characters
- Application-level validation ensures state code is in valid US state list
- Tasks also require valid state codes for matching

**Violation Behavior:**
If violated, users could be matched to tasks in incorrect jurisdictions, leading to legal violations (e.g., working without proper state licensing).

---

### INV-ELIGIBILITY-7: Willingness Flags Cannot Override Eligibility

```
User preferences (willingness to do in-home work, high-risk tasks, etc.) cannot grant access if eligibility requirements are not met.
```

**Rationale:** Willingness flags are user preferences, not permissions. Eligibility is determined by verified credentials, trust tier, and risk clearance—not by user preferences alone.

**Enforcement:**
- Feed query logic checks eligibility requirements before considering willingness flags
- Settings UI disables willingness flags if prerequisites are not met
- Willingness flags only filter among eligible tasks; they never create eligibility

**Violation Behavior:**
If violated, users could access tasks they are not qualified for by simply stating they are willing, bypassing credential and trust requirements.

---

### INV-ELIGIBILITY-8: Capability Profile Is Never Mutated Directly

```
Capability profiles are always derived from verification records. They cannot be edited directly by users or administrators.
```

**Rationale:** Capability profiles are computed snapshots of user eligibility. Direct mutation would allow inconsistency between profiles and verification records, breaking trust and legal compliance.

**Enforcement:**
- Application logic prevents direct UPDATE statements on capability profiles (except timestamp fields)
- Profile updates only occur through recomputation function triggered by verification changes
- Code review enforces "no direct profile mutations" rule

**Violation Behavior:**
If violated, capability profiles could drift out of sync with verification records, allowing users to access tasks they should not be eligible for, or blocking access they should have.

---

### INV-PRIVACY-1: Reactive Tracking Only

```
GPS/location tracking activates ONLY during:
  1. Active task (ACCEPTED → COMPLETED state)
  2. EN_ROUTE navigation (worker opted in)
  3. Liveness challenge (time-bounded, explicit consent)

GPS tracking NEVER activates for:
  - Background skill suggestion
  - Market demand analysis
  - Feed personalization
  - Any passive monitoring
```

**Rationale:** Workers are independent contractors operating their own businesses. Background surveillance violates IC classification principles and user trust. All intelligence features must be reactive (triggered by in-app events), never creepy (triggered by passive monitoring).

**Enforcement:**
- Mobile SDK location permissions are requested ONLY at task acceptance, not onboarding
- Location services are disabled on task completion or cancellation
- No background location mode in app manifest
- Error code: `HX901`

**Violation Behavior:**
If GPS fires outside an active task window, this is a **P0 bug requiring immediate hotfix**. Any background location access constitutes a privacy violation and potential IC misclassification risk.

---

### INV-PRIVACY-2: Poster Location Visibility Graduation

```
Poster visibility of worker location graduates with proximity:

  >0.5mi:  ETA countdown only ("~18 min away")
           Worker coordinates NOT transmitted to poster device
           Map shows: task pin only

  ≤0.5mi:  Approximate zone (200m radius circle on map)
           Worker coordinates rounded to 200m grid
           Map shows: shaded circle approaching task pin

  ≤100m:   Precise worker pin on map
           Exact coordinates (verified by proximity check)
           Map shows: worker pin + task pin

  IN_PROGRESS: "Worker is on-site" (no live tracking)
              Worker coordinates NOT transmitted
              Map shows: static task location only
```

**Rationale:** Workers are independent contractors choosing their own route and timing. Exposing exact live location from the moment of acceptance enables poster surveillance of worker movement, which constitutes direction and control — employer behavior under IC classification tests. Graduated visibility provides poster confidence ("worker is coming") without enabling tracking.

**Enforcement:**
- Location graduation logic runs SERVER-SIDE (not client-side)
- WebSocket updates transmit `PosterVisibleLocation` objects, NEVER raw `{lat, lng}` at >100m
- Server applies 200m grid rounding for ≤0.5mi zone
- Error code: `HX902`

**Violation Behavior:**
If raw worker coordinates are transmitted to poster at any distance >100m, this is a **P0 bug requiring immediate hotfix**. Leaking exact worker location constitutes a privacy violation and potential IC misclassification risk.

**Authority:** `SPATIAL_INTELLIGENCE_LOCKED.md` §5

---

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

The eligibility invariants (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8) enforce that **task access is impossible without proper credentials and trust tier**. The privacy invariants (INV-PRIVACY-1, INV-PRIVACY-2) enforce that **location tracking is reactive only — never background surveillance** and that **poster visibility of worker location graduates with proximity**. See §17 for complete eligibility system behavior.

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

### 3.4.1 Task Requirements (System-Determined)

Tasks declare their requirements. Posters describe the work; the system determines eligibility requirements based on risk classification.

**What This Means:**
- Tasks have risk levels (low, medium, high, critical) determined by the system based on task description and category
- Tasks declare required trade (if licensed work), required trust tier, insurance requirement, and background check requirement
- These requirements are **immutable after task creation**—they cannot be modified even by administrators
- Posters cannot choose who is qualified; the system enforces requirements automatically

**Feed Behavior:**
- Users only see tasks they are eligible for (see §17 for eligibility system)
- There are no "disabled" task cards or "you don't qualify" messages in the feed
- If a user cannot see a task, they are not eligible—this is by design, not a bug

**Why This Matters:**
- Prevents unsafe task matching (users cannot accept work they're not qualified for)
- Ensures legal compliance (licensed trades require verified credentials)
- Eliminates rejection friction (users never experience "apply and get rejected")
- Maintains trust with posters (only qualified workers can see their tasks)

---

## §3.5 Task Modes

Every task has exactly one **fulfillment mode**, declared at creation time.

### Mode Definitions

| Mode | Description | Default | Minimum Price |
|------|-------------|---------|---------------|
| `STANDARD` | Normal task feed, no time pressure | ✅ Yes | $5.00 |
| `LIVE` | Real-time fulfillment, elevated visibility | No | $15.00 |

**Mode is immutable after task creation.** A poster cannot switch a STANDARD task to LIVE after the task exists.

### LIVE Mode Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **LIVE-1** | Live tasks require FUNDED escrow before broadcast | DB trigger (HX901) |
| **LIVE-2** | Live tasks require $15.00 minimum price | DB constraint (HX902) |
| **LIVE-3** | Hustlers must explicitly opt into Live Mode | UI + DB state |
| **LIVE-4** | Live broadcasts are geo-bounded (PostGIS `ST_DWithin` on `tasks.location_geog` — SPATIAL_INTELLIGENCE §4) | Backend service |
| **LIVE-5** | Live broadcasts are time-bounded (TTL) | Backend service |
| **LIVE-6** | Live Mode is session-based, not permanent | State machine |
| **LIVE-7** | No auto-accept, no AI task assignment | Constitutional |

### Hustler Live Mode States

```typescript
type HustlerLiveState = 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
```

| State | Meaning | Receives Live Broadcasts |
|-------|---------|--------------------------|
| `OFF` | Not opted in (default) | ❌ |
| `ACTIVE` | Explicitly available | ✅ |
| `COOLDOWN` | Temporary rest after completions | ❌ |
| `PAUSED` | System-triggered (fatigue, decline rate) | ❌ |

### Session Rules

| Trigger | Result |
|---------|--------|
| 2 tasks accepted in session | Automatic COOLDOWN (15 min) |
| 5 declines without acceptance | PAUSED (reduced broadcasts) |
| 3 hours continuous | Fatigue warning |
| 4 hours continuous | Forced COOLDOWN (30 min) |

---

## §3.6 Live Task Lifecycle

### Broadcast Flow

```
1. Poster creates LIVE task (mode = 'LIVE', price ≥ $15)
2. Poster pays → escrow.state = FUNDED
3. task.live_broadcast_started_at = NOW()
4. System broadcasts to hustlers within radius (default: 3 miles)
5. If no acceptance after 60s, radius expands (+2 miles)
6. Continue until acceptance or TTL expires (default: 10 min)
```

### Broadcast Configuration

```typescript
interface LiveBroadcastConfig {
  initial_radius_miles: number;      // Default: 3
  max_radius_miles: number;          // Default: 10
  expansion_interval_seconds: number; // Default: 60
  expansion_step_miles: number;      // Default: 2
  broadcast_ttl_minutes: number;     // Default: 10
}
```

### Live Task State Transitions

```
OPEN (LIVE) ──→ BROADCAST_ACTIVE ──┬──→ ACCEPTED ──→ [standard flow]
                                   │
                                   └──→ BROADCAST_EXPIRED ──→ [poster options]
```

### Poster Options After Broadcast Expiry

If no hustler accepts within TTL:
- **Switch to Standard** — Task joins normal feed
- **Increase Price** — Rebroadcast at higher rate
- **Cancel & Refund** — Full refund to card

Escrow remains FUNDED until poster decides.

### XP and Trust Multipliers

| Metric | Standard | Live |
|--------|----------|------|
| XP multiplier | 1.0× | 1.25× |
| Task completion (trust) | +1 | +1.5 |
| Abandonment (trust) | -2 | **-4** |
| Complete under 30 min (trust) | +0.5 | +1 |

### Live Mode Performance Tracking

```typescript
interface LiveModeStats {
  total_live_tasks: number;
  live_completion_rate: number;      // Must stay > 90%
  average_response_time_seconds: number;
  average_eta_accuracy: number;
  live_earnings_total: number;
}
```

**Consequences:**
- `live_completion_rate < 80%` → PAUSED from Live Mode (7 days)
- `live_completion_rate < 70%` → BANNED from Live Mode (30 days)

---

## §3.7 Global Fatigue System

Fatigue awareness extends **beyond Live Mode** to all activity.

### Fatigue Triggers

| Trigger | Context | Result |
|---------|---------|--------|
| 4 hours total activity | Any mode | Gentle nudge |
| 6 hours total activity | Any mode | Stronger nudge |
| 8 hours total activity | Any mode | Mandatory break (30 min) |
| 7 consecutive active days | Any mode | "Rest day" suggestion |

### Fatigue Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FATIGUE-1** | 8-hour limit triggers mandatory break | Backend service |
| **FATIGUE-2** | Nudges are suggestions, not blocks (except 8h) | UI only |
| **FATIGUE-3** | Activity tracking is per-calendar-day | DB column |
| **FATIGUE-4** | Break timer cannot be bypassed | Backend enforcement |

### Fatigue Tracking

```typescript
interface FatigueState {
  daily_active_minutes: number;
  last_activity_date: Date;
  consecutive_active_days: number;
  last_mandatory_break_at: Date | null;
  current_session_start: Date | null;
}
```

### Break Duration Rules

| Activity Level | Required Break |
|----------------|----------------|
| 4 hours | Suggested: 15 min |
| 6 hours | Suggested: 30 min |
| 8 hours | **Mandatory: 30 min** |
| After mandatory break | Resets daily counter |

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
| `streak_multiplier` | Step function: 0–2 days = 1.00×, 3–6 days = 1.10×, 7–13 days = 1.20×, 14–29 days = 1.30×, 30+ days = 1.50× (cap). See `schema.sql:calculate_streak_multiplier()`. |
| `trust_multiplier` | `1.0` (ROOKIE) → `1.5` (VERIFIED) → `2.0` (TRUSTED) → `2.5` (ELITE) → `3.0` (MASTER) |

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
| 2 | 100 | Apprentice |
| 3 | 300 | Hustler |
| 4 | 700 | Pro |
| 5 | 1,500 | Expert |
| 6 | 2,700 | Veteran |
| 7 | 4,500 | Master |
| 8 | 7,000 | Elite |
| 9 | 10,500 | Legend |
| 10 | 18,500 | Mythic |

Level calculation: See `schema.sql:calculate_level()` function. Thresholds designed for balanced progression curve.

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

**Onboarding and Capability Claims:**
- During onboarding, users declare capabilities (trades they claim to be qualified for, location, willingness flags)
- These declarations create **capability claims**—historical records of what users stated, not permissions
- Capability claims unlock **verification paths**—the ability to verify licenses, insurance, and credentials
- Verification is a separate step after onboarding (see §17 for verification and eligibility system)
- Capability claims do not grant task access; only verified credentials and trust tier determine eligibility

### 8.2 Trust Tiers

| Tier | Name | Requirements | Benefits | Risk Clearance |
|------|------|--------------|----------|----------------|
| 1 | ROOKIE | New user | Base rates | Low risk only |
| 2 | VERIFIED | 5 completed tasks, ID verified | 1.5× XP multiplier | Low and medium risk |
| 3 | TRUSTED | 20 completed, 95%+ approval | 2.0× XP multiplier, priority matching | Low and medium risk |
| 4 | ELITE | 100+ completed, <1% dispute rate, 4.8+ rating | 2.5× XP multiplier, VIP access, priority matching | Low, medium, and high risk |
| 5 | MASTER | 500+ completed, <0.5% dispute rate, 4.9+ rating, background check verified | 3.0× XP multiplier, instant release eligible, critical risk access | Low, medium, high, and critical risk |

Trust tier changes are logged in `trust_ledger` (append-only).

**Risk Clearance Mapping:**
- Trust tier determines the maximum risk level of tasks a user can access (see INV-ELIGIBILITY-1 in §2)
- This mapping is **immutable**—trust tier 1 (ROOKIE) cannot access high-risk tasks, even if the user is willing
- Trust tier 5 (MASTER) is the only tier that can access critical-risk tasks (e.g., in-home care, vulnerable populations)
- Users with trust tier 4 (ELITE) can access low, medium, and high risk levels; users with trust tier 1 (ROOKIE) can only access low-risk tasks
- Risk clearance is derived from trust tier, not stored separately, ensuring consistency
- Users with trust tier 5 (MASTER) can access all risk levels (low, medium, high, critical); trust tier 4 (ELITE) accesses low, medium, and high; trust tier 1 (ROOKIE) can only access low-risk tasks

**What This Prevents:**
- New users accepting high-risk tasks they're not yet trusted to complete
- Legal violations (high-risk tasks may require higher trust for liability reasons)
- Safety issues (critical-risk tasks require highest trust tier)

### 8.3 Private Percentile Status

Hustlers see their relative standing **without public leaderboards**.

#### Percentile Metrics

| Metric | Calculation | Visible To |
|--------|-------------|------------|
| Reliability | Tasks completed / Tasks accepted | Hustler only |
| Response Time | Avg time to accept tasks | Hustler only |
| Completion Rate | Successful / Total tasks | Hustler only |
| Earnings Velocity | Earnings / Active hours | Hustler only |

#### Percentile Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PERC-1** | Percentiles are never public | API guard |
| **PERC-2** | No comparison to named users | UI review |
| **PERC-3** | Percentiles update weekly max | Backend job |
| **PERC-4** | Minimum 100 users for percentile | Statistical validity |
| **PERC-5** | No "rankings" or "leaderboards" | Constitutional |

#### Display Rules

- Format: "Top X% this week" (never "Rank #Y")
- Self-relative only: Compare to own history
- No gamification: No rewards for percentile position

### 8.4 Poster Reputation

Poster reputation is visible **only to hustlers**, never to posters.

#### Reputation Metrics

| Metric | Calculation | Visible To |
|--------|-------------|------------|
| Tasks Posted | COUNT(tasks) in 90 days | Hustlers only |
| Dispute Rate | Disputes / Tasks | Hustlers only |
| Avg Response Time | Avg time to respond to proofs | Hustlers only |
| Hustler Rating | Avg rating from workers | Hustlers only |

#### Reputation Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **POSTER-1** | Reputation never shown to poster | API guard |
| **POSTER-2** | Minimum 5 tasks for reputation | Statistical validity |
| **POSTER-3** | Rolling 90-day window | DB query |
| **POSTER-4** | No "bad poster" labels | UI review |

#### Rating System (Post-Task)

After task completion, hustler can rate poster:
- `GREAT` — No issues
- `OKAY` — Minor issues
- `DIFFICULT` — Significant issues

Optional feedback flags:
- Clearer task description needed
- Faster communication needed
- More reasonable expectations needed

---

## §8a. AI Task Completion System

### 8.1 Core Principle (LOCK THIS)

> **AI does not chat.  
> AI closes gaps in a contract.**

The goal is not conversation.  
The goal is **zero ambiguity before escrow is funded**.

**What This Unlocks:**
- Cleanest tasks in the market
- Directly drives fulfillment speed
- Increases trust
- Increases repeat usage
- Prevents disputes **before** money moves

### 8.2 Task Completion State Machine

The task card exists in **four AI states** before posting:

```
DRAFT → INCOMPLETE → COMPLETE → LOCKED
```

| State | Description | AI Questions Allowed | Escrow Allowed | Can Edit Fields |
|-------|-------------|---------------------|----------------|-----------------|
| **DRAFT** | Initial creation, minimal fields | ✅ Yes | ❌ No | ✅ Yes |
| **INCOMPLETE** | Missing required fields | ✅ Yes | ❌ No | ✅ Yes |
| **COMPLETE** | All required fields satisfied, zero ambiguity | ❌ No | ✅ Yes | ✅ Yes (until escrow funded) |
| **LOCKED** | Escrow funded, task posted | ❌ No | ✅ Already funded | ❌ No (terminal) |

### 8.3 Confidence Threshold Rule

AI questions are triggered **only if required fields cannot be inferred with sufficient confidence**.

```
IF confidence < 0.85 → ASK
IF confidence ≥ 0.85 → AUTO-FILL + CONFIRM
```

**Field Clusters:**
- **Location**: start_location, end_location (if moving), location_clarity
- **Time**: deadline, time_window, live_mode_eligible
- **Scope**: description_clarity, complexity, stairs_involved
- **Proof**: proof_type, proof_requirements

### 8.4 Question Types (Strictly Limited)

AI questions fall into **four and only four categories**:

1. **LOCATION_CLARITY** — Triggered when multiple locations referenced or vague area
2. **TIME_CONSTRAINTS** — Triggered when deadline vague or Live Mode eligibility unclear
3. **TASK_SCOPE** — Triggered when complexity ambiguous or risk of under-specification
4. **PROOF_EXPECTATION** — Triggered when outcome could be subjective

### 8.5 AI Auto-Fill + Confirm Pattern

When AI confidence ≥ 0.85, it does **not ask** — it **proposes**.

Example:
```
✓ We've assumed this task will take 30–45 minutes.
  [ Adjust time estimate ]

✓ We've set proof type to "Photo at destination".
  [ Change proof type ]
```

Poster can edit any auto-filled field. AI never **forces** a choice.

### 8.6 "Flawless Execution" Guarantee

When a task reaches **COMPLETE** state, the system can assert:

- ✅ **Scope is explicit** — No "that's not what I meant"
- ✅ **Time window is bounded** — No "I thought it was ASAP"
- ✅ **Proof expectations are clear** — No "I wanted proof differently"
- ✅ **Price is within rational range** — No "this should've cost less"
- ✅ **Location is unambiguous** — No "I thought it was closer"
- ✅ **Dispute probability is minimized** — All edge cases addressed

### 8.7 Live Mode Integration

If poster enables **LIVE MODE**, AI must ask **additional mandatory questions**:

- "Are you available to respond within 30 minutes?" (Yes / No)
- "Is the task accessible immediately?" (Yes / No)
- "Is the price final?" (Yes / No)

**If any answer is "no" → Live Mode is blocked.**

### 8.8 AI Voice Rules (Non-Negotiable)

The AI voice must be:

- ✅ **Neutral** — No bias, no judgment
- ✅ **Precise** — No ambiguity in language
- ✅ **Slightly formal** — Professional, not casual
- ✅ **Outcome-focused** — Get to completion, not conversation

**Forbidden patterns:**
- Casual ("Hey! Just need a quick question...")
- Playful ("Just curious! 😊")
- Apologetic ("Sorry to bother you, but...")
- Salesy ("Want to boost your task visibility?")

### 8.9 AI Task Completion Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **COMPLETE-1** | AI questions only allowed in DRAFT/INCOMPLETE | Backend service |
| **COMPLETE-2** | COMPLETE requires zero unresolved ambiguity | Backend validation |
| **COMPLETE-3** | LOCKED disables AI entirely | DB trigger + backend |
| **COMPLETE-4** | Escrow cannot fund unless state = COMPLETE | DB trigger (HX704) |
| **COMPLETE-5** | Only 4 question types allowed | Backend validation |
| **COMPLETE-6** | Confidence threshold cannot be bypassed | Backend validation |

### 8.10 Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| % tasks reaching COMPLETE without edits | >70% | Backend analytics |
| Dispute rate: AI-assisted vs manual | <50% of manual | Dispute tracking |
| Average completion time | <5 min | Task creation to posting |
| Proof rejection rate | <5% | Proof acceptance tracking |
| Live Mode fulfillment speed | <10 min avg | Live Mode analytics |

### 8.11 Error Codes

| Code | Meaning | Trigger |
|------|---------|---------|
| `HX701` | AI question attempted after LOCKED | COMPLETE-3 violation |
| `HX702` | Escrow funding attempted before COMPLETE | COMPLETE-4 violation |
| `HX703` | Invalid question type (not in 4 allowed types) | COMPLETE-5 violation |
| `HX704` | Confidence threshold bypass attempt | COMPLETE-6 violation |

**Detailed specification:** See `specs/02-architecture/subsystems/AI_TASK_COMPLETION_LOCKED.md`

---

## §9. Task Discovery & Matching System

### 9.1 Core Principle (LOCK THIS)

> **Task discovery is not a feed. It is a personalized matching engine.**

Hustlers don't browse. They **match** with tasks that fit their profile, skills, location, and preferences.

**What This Unlocks:**
- Highest task acceptance rates
- Fastest fulfillment
- Best earning potential for hustlers
- Highest satisfaction for posters

### 9.2 Matching Score Formula

Every task-hustler pair has a **matching score** (0.0 to 1.0):

```
matching_score = (
  trust_multiplier × 0.30 +
  distance_score × 0.25 +
  category_match × 0.20 +
  price_attractiveness × 0.15 +
  time_match × 0.10
)
```

Tasks below 0.20 matching score are hidden from feed unless explicitly searched.

### 9.3 Feed Ranking Algorithm

Tasks are ranked by **relevance score**, not just matching score:

```
relevance_score = (
  matching_score × 0.70 +
  recency_boost × 0.15 +
  urgency_boost × 0.10 +
  poster_quality_boost × 0.05
)
```

### 9.4 Filter & Sort Options

**Filters:** Category, price range, distance, time window, trust tier, mode (STANDARD/LIVE), escrow status  
**Sort Options:** Relevance (default), distance, price (high/low), deadline, trust tier, recently posted  
**Search:** Full-text search on title, description, location, category

### 9.5 "Why This Task?" Explanations

For each task in feed, show AI-generated explanation:
- Top 3 reasons why task matches
- Confidence score (0.0 to 1.0)
- Advisory only (A1 authority)

### 9.6 Task Discovery Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **DISCOVERY-1** | Matching score is always 0.0 to 1.0 | Backend validation |
| **DISCOVERY-2** | Tasks below 0.20 score are hidden from feed | Backend filter |
| **DISCOVERY-3** | Relevance score combines matching + boosts | Backend calculation |
| **DISCOVERY-4** | Filters never bypass trust tier requirements | Backend validation |
| **DISCOVERY-5** | Explanations are advisory only (A1) | AI authority model |

**Detailed specification:** See `specs/01-product/features/TASK_DISCOVERY_LOCKED.md`

---

## §10. In-App Messaging System

### 10.1 Core Principle (LOCK THIS)

> **Messaging exists to coordinate task completion, not to socialize.**

Every message is **task-scoped**. No general chat. No DMs. Only task-specific coordination.

**What This Unlocks:**
- Prevents disputes (coordination reduces misunderstandings)
- Reduces "no show" rate (real-time updates)
- Builds trust (transparent communication)
- Provides dispute evidence (chat history)

### 10.2 Task-Scoped Messaging

**Allowed:**
- ✅ Poster and worker can message during task lifecycle (ACCEPTED, PROOF_SUBMITTED, DISPUTED)
- ✅ Messages are scoped to specific task_id
- ✅ Messages are visible to both parties + admins (for disputes)

**Forbidden:**
- ❌ General DMs (no task context)
- ❌ Messages after task COMPLETED/CANCELLED (read-only archive)
- ❌ Messages before task ACCEPTED (no worker assigned)

### 10.3 Message Types

- **Text Messages:** Maximum 500 characters, no links
- **Auto-Messages:** Quick responses ("On my way", "Running late", "Completed")
- **Photo Sharing:** Maximum 3 photos per message, stored in evidence table
- **Location Sharing:** One-time "I'm here" location (optional, expires after 15 minutes)

### 10.4 Content Moderation

All messages scanned via AI (A2 authority):
- High confidence (>0.9): Auto-block
- Medium confidence (0.7-0.9): Flag for review
- Low confidence (<0.7): Approve, monitor

### 10.5 Messaging Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MSG-1** | Messages only allowed during ACCEPTED/PROOF_SUBMITTED/DISPUTED | Backend validation |
| **MSG-2** | Sender must be poster or worker for task | Backend validation |
| **MSG-3** | Maximum 3 photos per message | DB constraint |
| **MSG-4** | Maximum 500 characters per text message | DB constraint (schema.sql line 1535) |
| **MSG-5** | Chat history is immutable after task COMPLETED | Backend validation |

**Detailed specification:** See `specs/01-product/features/MESSAGING_SPEC.md`

---

## §11. Notification System

### 11.1 Core Principle (LOCK THIS)

> **Notifications are information, not interruptions.**

Users receive **only actionable, relevant notifications**. No spam. No marketing. No noise.

**What This Unlocks:**
- Faster task acceptance (instant alerts)
- Better coordination (real-time updates)
- Higher completion rates (deadline reminders)
- Reduced disputes (status updates)

### 11.2 Notification Categories

**Task-Related:** Task accepted, completed, proof submitted/approved/rejected, cancelled, expired, new matching task, Live Mode task  
**Message:** New message, unread messages (3+)  
**Trust & Reputation:** Trust tier upgraded, badge earned, dispute opened/resolved  
**Escrow & Payment:** Escrow funded, payment released, refund issued  
**System & Safety:** Account suspended, security alert, password changed

### 11.3 Delivery Rules

- **Do Not Disturb (DND):** User-configurable quiet hours (default: 10 PM - 7 AM)
- **DND Exceptions:** Task accepted, payment released, security alerts (always notify)
- **Frequency Limits:** Per-category limits prevent spam (e.g., 5 "new matching task" per hour max)
- **Grouping:** Similar notifications grouped (e.g., "3 tasks accepted")

### 11.4 Notification Preferences

User can control per category:
- Enable/Disable
- Sound (on/off)
- Badge (on/off)
- Quiet hours override (yes/no)

### 11.5 Notification Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **NOTIF-1** | Notifications only sent to task participants (poster/worker) | Backend validation |
| **NOTIF-2** | HIGH priority notifications bypass quiet hours | Backend logic |
| **NOTIF-3** | Frequency limits enforced per category | Backend rate limiting |
| **NOTIF-4** | Deep links must be valid (task exists, user has access) | Backend validation |
| **NOTIF-5** | Notifications expire after 30 days | Backend cleanup job |

**Detailed specification:** See `specs/01-product/features/NOTIFICATION_SPEC.md`

---

## §12. Bidirectional Rating System

### 12.1 Core Principle (LOCK THIS)

> **Ratings are mutual, mandatory, and immutable.**

Both worker and poster rate each other after task completion. Ratings cannot be changed. This builds trust, accountability, and quality on both sides.

**What This Unlocks:**
- Quality filtering (posters see worker ratings, workers see poster ratings)
- Trust building (ratings inform trust tier calculations)
- Accountability (both sides responsible for quality)
- Dispute prevention (ratings encourage good behavior)

### 12.2 Rating Flow

**Ratings are required after task COMPLETED:**
1. Task reaches COMPLETED state (proof approved, payment released)
2. Both parties receive notification: "Rate your experience"
3. Rating window: 7 days after completion
4. If not rated within 7 days: Auto-rating (5 stars, no comment)
5. Ratings are **blind** until both parties submit (or 7 days expire)

### 12.3 Rating Components

**Each rating includes:**
- **Star Rating:** 1-5 stars (required)
- **Comment:** Text (max 500 chars, optional)
- **Tags:** Multi-select (optional, e.g., "On Time", "Professional", "High Quality")

### 12.4 Rating Display

**Worker Profile (visible to posters):**
- Aggregated stats: Average rating, total ratings, star distribution
- Recent feedback: Last 10 public ratings with comments and tags

**Poster Profile (visible to workers):**
- Aggregated stats: Average rating, total ratings
- Recent feedback: Last 10 public ratings

### 12.5 Rating Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **RATE-1** | Rating only allowed after task COMPLETED | Backend validation |
| **RATE-2** | Rating window: 7 days after completion | Backend validation |
| **RATE-3** | Both parties must rate (or auto-rated after 7 days) | Backend logic |
| **RATE-4** | Ratings are immutable (cannot edit/delete) | DB constraint + backend validation |
| **RATE-5** | One rating per pair per task | DB UNIQUE constraint |
| **RATE-6** | Stars must be 1-5 | DB CHECK constraint |
| **RATE-7** | Comment must be ≤500 characters | DB CHECK constraint (schema.sql line 1644) |

**Detailed specification:** See `specs/01-product/features/RATING_SYSTEM_SPEC.md`

---

## §13. Analytics Infrastructure

### 13.1 Core Principle (LOCK THIS)

> **You cannot improve what you do not measure.**

Every user action is tracked. Every conversion is measured. Every decision is data-driven.

**What This Unlocks:**
- Identify bottlenecks (where users drop off)
- Optimize conversion (signup → first task → repeat)
- Measure feature impact (A/B testing)
- Track retention (cohort analysis)
- Drive product decisions (data, not intuition)

### 13.2 Event Tracking

**Event Categories:**
- **User Actions:** Task viewed, accepted, proof submitted, etc.
- **System Events:** Escrow funded, payment released, dispute opened
- **Error Events:** Payment failed, validation error, invariant violation
- **Performance:** API latency, DB query time, cache hit rate

### 13.3 Conversion Funnels

- **Signup Funnel:** Landing → Signup → Onboarding → First Action
- **Task Posting Funnel:** Create → AI Completion → Escrow Funded → Accepted → Completed
- **Task Acceptance Funnel:** Viewed → Details → Accepted → Started → Proof Submitted → Completed

### 13.4 Cohort Analysis

- **Retention Cohorts:** Day 1, Day 7, Day 30 retention by signup week/month
- **Revenue Cohorts:** Revenue per user (RPU), lifetime value (LTV), average revenue per user (ARPU)

### 13.5 A/B Testing Framework

- Consistent variant assignment (per user_id hash)
- Traffic split (default: 50/50)
- Statistical significance calculation (p-value < 0.05)

### 13.6 Privacy & Compliance

- Anonymized fields: IP address (hash), user agent (generalized)
- Retention: Raw events 90 days, aggregated metrics 2 years
- GDPR compliance: User can export/delete all events

**Detailed specification:** See `specs/02-architecture/subsystems/ANALYTICS_LOCKED.md`

---

## §14. Fraud Detection System

### 14.1 Core Principle (LOCK THIS)

> **Fraud detection prevents platform abuse before it causes damage.**

Every user, task, and transaction is risk-scored. Suspicious patterns trigger automated flags. High-risk activities require manual review before proceeding.

**What This Unlocks:**
- Prevents fake tasks (self-matching, payment fraud)
- Detects account abuse (multiple accounts, identity fraud)
- Protects platform integrity (trust, reputation)
- Reduces financial losses (chargebacks, refunds)
- Maintains legal compliance (AML, KYC)

### 14.2 Risk Scoring System

**Risk Score:** 0.0 (no risk) to 1.0 (maximum risk)

| Score Range | Label | Action |
|-------------|-------|--------|
| **0.0 - 0.3** | LOW | Auto-approve, monitor |
| **0.3 - 0.6** | MEDIUM | Review queue, additional verification |
| **0.6 - 0.8** | HIGH | Manual review required, flag account |
| **0.8 - 1.0** | CRITICAL | Auto-reject, suspend account, alert admins |

### 14.3 Fraud Patterns

**Account-Level:** Multiple accounts (same device/IP), rapid account creation, suspicious identity, device sharing, VPN/proxy usage  
**Task-Level:** Self-matching, circular matching, fake task patterns, price manipulation, rapid task creation  
**Payment-Level:** Chargeback history, failed payment methods, rapid escrow funding, high-value transactions, Stripe Radar flags  
**Behavioral:** Velocity abuse, dispute abuse, proof rejection abuse, rating manipulation, message spam

### 14.4 Automated Flagging

**Auto-Flag Conditions:**
- User risk score ≥ 0.6
- Task risk score ≥ 0.6
- Transaction risk score ≥ 0.6
- Self-match detected (risk score = 1.0)
- Stripe Radar score ≥ 0.8
- Chargeback detected

### 14.5 Fraud Detection Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FRAUD-1** | Risk scores are calculated for all users/tasks/transactions | Background job |
| **FRAUD-2** | High-risk (≥0.6) entities require manual review | Backend validation |
| **FRAUD-3** | Critical-risk (≥0.8) entities are auto-rejected | Backend validation |
| **FRAUD-4** | Self-match (risk = 1.0) is always blocked | Backend validation |

**Detailed specification:** See `specs/02-architecture/subsystems/RISK_TRUST_ENGINE_LOCKED.md`

---

## §15. Content Moderation Workflow

### 15.1 Core Principle (LOCK THIS)

> **Content moderation protects platform quality and user safety.**

All user-generated content is scanned automatically. Flagged content enters a review queue. Users can report violations. Escalation rules ensure swift action on serious issues.

**What This Unlocks:**
- Prevents harassment, spam, and abuse
- Maintains platform quality (no inappropriate content)
- Builds trust (users feel safe)
- Legal compliance (removes liability)
- Scalable moderation (automated + human)

### 15.2 Content Types to Moderate

Task descriptions, task titles, messages, profile descriptions, ratings/comments, photos (task proof), profile photos

### 15.3 Moderation Categories

| Category | Severity | Action |
|----------|----------|--------|
| **Profanity** | Low | Auto-flag, review |
| **Harassment** | High | Auto-flag, immediate review |
| **Spam** | Medium | Auto-flag, review |
| **Inappropriate** | Critical | Auto-flag, immediate removal |
| **Personal Info** | Medium | Auto-redact, review |
| **Phishing** | High | Auto-block, review |

### 15.4 Automated Content Scanning

**AI Scanning (A2 Authority):**
- AI confidence ≥ 0.9: Auto-block, quarantine
- AI confidence 0.7-0.9: Flag, send to review queue
- AI confidence < 0.7: Approve, monitor

### 15.5 Human Review Queue

**Priority Levels:**
- **CRITICAL:** Harassment, threats, illegal content (SLA: 1 hour)
- **HIGH:** Spam, phishing, inappropriate (SLA: 4 hours)
- **MEDIUM:** Profanity, personal info (SLA: 24 hours)
- **LOW:** Misleading, borderline (SLA: 48 hours)

### 15.6 User Reporting System

Users can report content with categories: Harassment, Spam, Inappropriate, Fake Task, Personal Info, Other

### 15.7 Content Moderation Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MOD-1** | All user-generated content is scanned | Backend trigger on create/update |
| **MOD-2** | CRITICAL content is auto-quarantined | Backend validation |
| **MOD-3** | Review queue items have SLA deadlines | Backend calculation |
| **MOD-4** | Appeals are reviewed by different admin | Backend assignment |

**Detailed specification:** See `specs/02-architecture/subsystems/CONTENT_MODERATION_LOCKED.md`

---

## §16. GDPR Compliance & Privacy

### 16.1 Core Principle (LOCK THIS)

> **User data belongs to users. They control it.**

GDPR compliance is not optional. It's a legal requirement. Users have the right to access, export, delete, and control their data.

**What This Unlocks:**
- Legal compliance (no fines, no shutdown risk)
- User trust (transparent data handling)
- Competitive advantage (users trust us with their data)
- Scalability (ready for EU expansion)

### 16.2 User Rights

| Right | Implementation |
|-------|----------------|
| **Right to Access** | Export feature (JSON/CSV/PDF) |
| **Right to Rectification** | Profile edit, data correction |
| **Right to Erasure** | Account deletion, data purge |
| **Right to Data Portability** | Data export feature |
| **Right to Restrict Processing** | Opt-out preferences |
| **Right to Object** | Opt-out preferences |
| **Right to Withdraw Consent** | Consent management |

### 16.3 Data Export Feature

**Export Includes:** Account info, profile data, task history, transaction history, message history (90 days), rating history, trust tier history, analytics events (90 days)

**Export Format:** JSON (structured), CSV (spreadsheet), PDF (human-readable)  
**Export Process:** User requests → System generates (async) → Email with download link (expires 7 days)  
**SLA:** Export generated within 30 days (GDPR requirement)

### 16.4 Data Deletion Feature

**Immediate Deletion:** Account data, profile data, preferences, location data (30 days), analytics events (90 days)  
**Legal Retention (7 years):** Transaction data, task data, dispute records, tax documents  
**Anonymization:** Tasks and transactions anonymized (remove user_id) but kept for legal/tax requirements

**Deletion Process:** User requests → 7-day grace period (can cancel) → Permanent deletion  
**Grace Period:** Account suspended, user can cancel deletion within 7 days

### 16.5 Consent Management

**Consent Types:**
- Account Creation: Required, not withdrawable
- Email Notifications: Optional, withdrawable
- Marketing Emails: Optional, withdrawable
- Analytics Tracking: Optional, withdrawable
- Location Tracking: Required for matching, withdrawable (opt-out)
- Photo Storage: Required for tasks, not withdrawable

### 16.6 Data Breach Notification

**Within 72 Hours (GDPR Requirement):**
1. Detect breach
2. Assess impact (what data, how many users)
3. Report to Data Protection Authority (DPA)
4. Notify affected users (if high risk)
5. Document breach (for audit)

### 16.7 GDPR Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **GDPR-1** | Data export requests processed within 30 days | Backend SLA enforcement |
| **GDPR-2** | Data deletion requests processed within 7 days | Backend SLA enforcement |
| **GDPR-3** | User consent records are immutable (append-only) | DB constraint |
| **GDPR-4** | Legal retention periods enforced (7 years for transactions) | Backend validation |
| **GDPR-5** | Data breach notifications sent within 72 hours | Backend alerting |

**Detailed specification:** See `specs/02-architecture/subsystems/GDPR_COMPLIANCE_LOCKED.md`

---

## §17. Capability-Driven Eligibility System

### 17.1 Core Principle (Non-Negotiable)

> **Users do not apply to gigs.  
> Gigs appear only if the user is eligible.**

This is the fundamental rule. Everything else is implementation detail.

**What This Means:**
- Users never see tasks they cannot accept
- There are no "disabled" task cards or "you don't qualify" messages in the feed
- If a task appears in a user's feed, they are eligible to accept it—no exceptions
- Rejection never happens at the task level; eligibility is determined before tasks are shown

**Why This Matters:**
- Prevents unsafe task matching (users cannot attempt work they're not qualified for)
- Eliminates rejection friction (users never experience "apply and get rejected")
- Ensures legal compliance (licensed tasks only shown to verified workers)
- Maintains trust with posters (only qualified workers see their tasks)

---

### 17.2 Capability Claims vs Capability Profile

**Capability Claims (Historical Record):**
- Created during onboarding when users declare their capabilities
- Stores what users stated: claimed trades, location, willingness flags
- Immutable after creation—never changes, never expires
- Does not grant access—claims are historical facts, not permissions

**Capability Profile (Eligibility Authority):**
- Derived from verification records, trust tier, and credential status
- Single source of truth for feed eligibility
- Recomputed automatically when verifications change
- Never edited directly—always derived from source data

**The Flow:**
```
Onboarding → Capability Claims (historical record)
  ↓
Verification → Capability Profile recomputed
  ↓
Feed Query → Only eligible tasks shown
```

Claims unlock verification paths. Verifications update the profile. Profile determines feed.

---

### 17.3 Verification as Prerequisite, Not Access

**Verification does not grant immediate access.**

Verification:
- Validates facts (license exists, insurance is active, background check passed)
- Updates capability profile (derived snapshot of eligibility)
- Unlocks task visibility (tasks requiring those credentials now appear in feed)

Verification does not:
- Grant access directly (access is derived via profile recomputation)
- Override trust tier requirements (trust tier caps risk clearance)
- Bypass location matching (tasks must match user's work state)

**Example:**
- User verifies electrician license → License verification status = "verified"
- Capability profile recomputed → Verified trades updated
- Feed query runs → Electrical tasks in user's state now appear
- User did not "unlock access"—access was computed from verified facts

---

### 17.4 Feed Shows Only Eligible Gigs

**The Feed Promise:**
If a task appears in your feed, you can accept it. Period.

**What Users See:**
- Only tasks they are eligible for (based on capability profile)
- No disabled buttons
- No "requires verification" messages
- No "upgrade to unlock" prompts

**What Users Do Not See:**
- Tasks requiring licenses they don't have
- Tasks requiring trust tiers above their current tier
- Tasks requiring insurance they haven't verified
- Tasks in states where their credentials aren't valid

**If a user cannot see a task:**
- They are not eligible (by design, not a bug)
- They can check Settings → Work Eligibility to see what they're missing
- They can complete verification to become eligible
- The system never shows tasks they cannot accept

---

### 17.5 Expiry Behavior (Silent Removal)

**When Credentials Expire:**
- Capability profile recomputed automatically (expired credentials removed)
- Feed cache invalidated
- Tasks requiring those credentials disappear from feed
- User sees notification in Settings (not in feed)

**What Users Experience:**
- Tasks silently disappear from feed (no warnings, no countdown)
- Settings shows expired credential alert
- Clear renewal path (Settings → Work Eligibility → Renew)
- Feed updates within 60 seconds (cache TTL)

**Why Silent Removal:**
- Prevents confusion (no "task locked" messages)
- Maintains trust (users never see tasks they can't access)
- Encourages renewal (clear upgrade path in Settings)
- Legal compliance (expired credentials cannot grant access)

---

### 17.6 No Appeals, No Overrides

**Eligibility is deterministic.**
- Eligibility is computed from verified facts, not preferences
- There are no exceptions, appeals, or temporary overrides
- Support cannot "unlock" access without verification
- Administrators cannot grant access bypassing requirements

**Why This Matters:**
- Prevents trust leaks (no special cases, no favoritism)
- Ensures legal compliance (credentials cannot be bypassed)
- Maintains system integrity (eligibility is computed, not negotiated)
- Protects users (no unsafe task matching)

**What Support Can Do:**
- Help users complete verification
- Explain why eligibility requirements exist
- Guide users through Settings → Work Eligibility
- Process verification renewals

**What Support Cannot Do:**
- Override eligibility requirements
- Grant access without verification
- Bypass trust tier restrictions
- Create special exceptions

---

### 17.7 Eligibility Components

**Verified Trades:**
- Derived from license verifications (see INV-ELIGIBILITY-2)
- Required for tasks in licensed trades (electrical, plumbing, HVAC, etc.)
- Expiry-triggered removal (see INV-ELIGIBILITY-3)

**Trust Tier:**
- Determines maximum risk clearance level (see INV-ELIGIBILITY-1)
- Trust tier 1 (ROOKIE) → low risk only
- Trust tier 2/3 (VERIFIED/TRUSTED) → low and medium risk
- Trust tier 4 (ELITE) → low, medium, and high risk

**Insurance:**
- Required for high-risk tasks (in-home work, property damage risk)
- Derived from insurance verifications (see INV-ELIGIBILITY-4)
- Cannot be valid without verified trade (insurance is trade-scoped)

**Background Checks:**
- Required for critical-risk tasks (in-home care, vulnerable populations)
- Derived from background check verifications (see INV-ELIGIBILITY-5)
- Expires on schedule, requires renewal

**Location State:**
- Must match task location state (see INV-ELIGIBILITY-6)
- Licenses are state-scoped (cannot use WA license for CA tasks)
- Legal compliance requires jurisdiction matching

**Willingness Flags:**
- User preferences (in-home work, high-risk tasks, urgent jobs)
- Cannot override eligibility (see INV-ELIGIBILITY-7)
- Only filter among eligible tasks; never create eligibility

---

### 17.8 Settings as Eligibility Control Room

**Settings → Work Eligibility is the single place users understand their eligibility.**

**What Users See:**
- Current trust tier and risk clearance level
- Verified trades (with expiry dates)
- Insurance status (valid/expired)
- Background check status (valid/expired)
- Upgrade opportunities (computed, not estimated)

**What Users Can Do:**
- Start verification for trades they've claimed
- Renew expired credentials
- View eligibility summary (what they can/cannot access)

**What Users Cannot Do:**
- Toggle eligibility (eligibility is derived, not editable)
- Request exceptions (no "enable anyway" buttons)
- Bypass requirements (no shortcuts)

---

### 17.9 Integration with Existing Systems

**Tasks (§3):**
- Tasks declare requirements (risk level, trade, trust tier, insurance, background check)
- Requirements are immutable after creation (see §3.4.1)
- Feed only shows tasks matching user's capability profile

**Trust Tiers (§8.2):**
- Trust tier determines risk clearance level (see INV-ELIGIBILITY-1)
- Risk clearance caps task visibility (high-risk tasks require trust tier 4/ELITE)
- Trust tier changes trigger capability profile recomputation

**Onboarding (§8.1):**
- Onboarding collects capability claims (historical record)
- Claims unlock verification paths, not task access
- Verification (separate step) updates capability profile

**For Implementation Details:**
- See `specs/02-architecture/subsystems/CAPABILITY_ONBOARDING_AND_FEED_FILTERING_LOCKED.md`
- See `specs/02-architecture/subsystems/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
- See `specs/02-architecture/subsystems/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`

---

## §18. Monetary Rules

### 18.1 Minimum Task Value

- Minimum: $5.00 (500 cents)
- Platform fee: 15% (deducted from escrow before release)
- Worker receives: 85% of posted amount

### 18.2 Currency

All amounts stored in **USD cents** (integers). No floating point.

```sql
amount INTEGER NOT NULL CHECK (amount >= 500)  -- $5 minimum
```

### 18.3 Payment Flow

1. Poster creates task with price
2. Stripe PaymentIntent created for `price + platform_fee`
3. Payment captured → escrow state = FUNDED
4. Task completed → escrow state = RELEASED
5. Stripe Transfer created to worker's connected account
6. Platform fee retained in Stripe balance

---

## §19. Error Codes

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
| `HX505` | Admin action audit violation | Append-only violation |
| `HX901` | Live broadcast without funded escrow | LIVE-1 violation |
| `HX902` | Live task below price floor | LIVE-2 violation |
| `HX903` | Hustler not in ACTIVE state | Live accept while OFF/COOLDOWN/PAUSED |
| `HX904` | Live Mode toggle cooldown | Toggle attempt within 5 minutes |
| `HX905` | Live Mode banned | Attempt to enable while banned |
| `HX601` | Fatigue break bypass | FATIGUE-4 violation |
| `HX602` | Pause state violation | PAUSE-* violation |
| `HX603` | Poster rep access by poster | POSTER-1 violation |
| `HX604` | Percentile public exposure | PERC-1 violation |
| `HX605` | Trust tier / risk clearance mismatch | INV-ELIGIBILITY-1 violation |
| `HX606` | Verified trade without active license | INV-ELIGIBILITY-2 violation |
| `HX607` | Expired credential access attempt | INV-ELIGIBILITY-3 violation |
| `HX608` | Insurance without verified trade | INV-ELIGIBILITY-4 violation |
| `HX609` | Ineligible task access attempt | INV-ELIGIBILITY-5 through INV-ELIGIBILITY-8 violation |
| `HX701` | AI question attempted after LOCKED | COMPLETE-3 violation |
| `HX702` | Escrow funding attempted before COMPLETE | COMPLETE-4 violation |
| `HX703` | Invalid question type (not in 4 allowed types) | COMPLETE-5 violation |
| `HX704` | Confidence threshold bypass attempt | COMPLETE-6 violation |
| `HX801` | Message sent outside allowed task states | MSG-1 violation |
| `HX802` | Message sender not task participant | MSG-2 violation |
| `HX803` | Message photo count exceeds limit (3) | MSG-3 violation |
| `HX804` | Message content exceeds limit (500 chars) | MSG-4 violation |
| `HX805` | Notification sent to non-participant | NOTIF-1 violation |
| `HX806` | Notification frequency limit exceeded | NOTIF-3 violation |
| `HX807` | Rating submitted before task COMPLETED | RATE-1 violation |
| `HX808` | Rating submitted after 7-day window | RATE-2 violation |
| `HX809` | Rating edit/delete attempted | RATE-4 violation |
| `HX810` | Rating stars out of range (1-5) | RATE-6 violation |
| `HX811` | Rating comment exceeds limit (500 chars) | RATE-7 violation |
| `HX911` | Risk score calculation failed | FRAUD-1 violation |
| `HX912` | High-risk entity bypassed review | FRAUD-2 violation |
| `HX913` | Critical-risk entity not auto-rejected | FRAUD-3 violation |
| `HX914` | Self-match not blocked | FRAUD-4 violation |
| `HX951` | Content moderation scan failed | MOD-1 violation |
| `HX952` | CRITICAL content not auto-quarantined | MOD-2 violation |
| `HX953` | Review queue SLA deadline missing | MOD-3 violation |
| `HX954` | Appeal reviewed by same admin | MOD-4 violation |
| `HX971` | GDPR export request not processed within 30 days | GDPR-1 violation |
| `HX972` | GDPR deletion request not processed within 7 days | GDPR-2 violation |
| `HX973` | Consent record modified (append-only violation) | GDPR-3 violation |
| `HX974` | Legal retention period violated | GDPR-4 violation |
| `HX975` | Data breach not notified within 72 hours | GDPR-5 violation |

All HX error codes are raised by database triggers or backend validation. Application code cannot suppress them.

---

## §20. Account Pause State

Users can **pause their account** without losing progress.

### 20.1 Account States

```typescript
type AccountStatus = 'ACTIVE' | 'PAUSED' | 'SUSPENDED';
```

| Status | User Action | Task Visibility | Notifications |
|--------|-------------|-----------------|---------------|
| `ACTIVE` | Full access | Visible | Enabled |
| `PAUSED` | View only | Hidden from feed | Disabled |
| `SUSPENDED` | None (admin action) | Hidden | Disabled |

### 20.2 What's Protected During Pause

| Aspect | During Pause | After Resume |
|--------|--------------|--------------|
| XP | No decay | Intact |
| Level | Frozen | Intact |
| Trust Tier | Frozen | Intact |
| Badges | Permanent | Intact |
| Earnings History | Preserved | Intact |
| Task History | Preserved | Intact |

### 20.3 Streak Grace Period

| Pause Duration | Streak Effect | Trust Effect |
|----------------|---------------|--------------|
| Up to 14 days | Full streak preserved | Full protection |
| 15-30 days | Streak resets to 1 | Trust tier preserved |
| 31-90 days | Streak resets to 1 | Trust tier preserved |
| 90+ days | Streak resets to 1 | Trust tier drops one level |

### 20.4 Pause Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PAUSE-1** | XP never decays during pause | Backend logic |
| **PAUSE-2** | Badges are permanent regardless | DB constraint |
| **PAUSE-3** | Pause is always available | UI always shows option |
| **PAUSE-4** | Resume is instant | No "reactivation" delay |
| **PAUSE-5** | No punitive notifications during pause | Notification service |

### 20.5 Pause Tracking

```typescript
interface PauseState {
  account_status: 'ACTIVE' | 'PAUSED' | 'SUSPENDED';
  paused_at: Date | null;
  pause_streak_snapshot: number;
  pause_trust_tier_snapshot: number;
  pause_reason: string | null;
}
```

---

## §21. Marketplace Safety Invariants

### 21.1 Concurrent Task Limit (INV-TASK-1)

```
Workers may have at most MAX_ACTIVE_TASKS tasks in ACCEPTED or IN_PROGRESS state simultaneously.
```

| Trust Tier | MAX_ACTIVE_TASKS |
|---|---|
| 1 (ROOKIE) | 2 |
| 2 (VERIFIED) | 3 |
| 3 (TRUSTED) | 5 |
| 4 (ELITE) | 7 |
| 5 (MASTER) | 10 |

**Enforcement:**
- Application guard on `task.accept` endpoint: count active tasks before accepting
- Error code: `HX302` — "Maximum active tasks reached"
- UI: "Complete or cancel an active task before accepting another"

**Rationale:** Without this limit, one bad-faith worker can lock up dozens of posters' tasks and escrows. This is the #1 marketplace abuse vector.

### 21.2 Proof Rejection Loop Protection (INV-PROOF-1)

```
After MAX_REJECTIONS proof rejections on the same task, the system automatically opens a dispute.
```

**MAX_REJECTIONS = 3**

**Enforcement:**
- Track `rejection_count` per task (incremented on each `reject` transition)
- On 3rd rejection: system auto-transitions task to DISPUTED, creates dispute record with reason `EXCESSIVE_REJECTIONS`
- Poster can no longer reject proof; only dispute resolution can proceed
- Error code: `HX303` — "Maximum proof rejections reached, dispute auto-opened"

**Rationale:** Without this, abusive posters can extract free labor by endlessly rejecting adequate proof. Workers have no recourse.

### 21.3 Maximum Task Price (INV-PRICE-1)

```
Task price CANNOT exceed MAX_PRICE per task mode.
```

| Mode | Minimum | Maximum |
|---|---|---|
| STANDARD | $5.00 (500¢) | $500.00 (50,000¢) |
| LIVE | $15.00 (1,500¢) | $1,000.00 (100,000¢) |

**Enforcement:**
- Database check constraint: `amount <= 50000` for STANDARD, `amount <= 100000` for LIVE
- Error code: `HX304` — "Task price exceeds maximum"
- Tasks requiring higher amounts: contact support for manual approval (post-launch)

**Rationale:** No ceiling = money laundering vector, chargeback exposure, Stripe account risk.

### 21.4 Stale Acceptance Timeout (INV-ACCEPT-1)

```
ACCEPTED tasks auto-cancel if worker does not transition to EN_ROUTE within the acceptance window.
```

**Default acceptance window:** 4 hours (or task deadline minus 2 hours, whichever is sooner).

**Enforcement:**
- Background job checks ACCEPTED tasks every 15 minutes
- At `acceptance_window - 60min`: push notification "Reminder: you accepted [task]. Start soon or it will be reassigned."
- At `acceptance_window - 30min`: push notification "Final reminder: [task] will be reassigned in 30 minutes."
- At `acceptance_window`: system auto-cancels task, returns to OPEN state, increments worker `cancellation_count`
- Worker's `cancellation_count` incremented (counts toward trust impact)
- Poster receives notification: "Your task is available again."

**Rationale:** Without this, accepted tasks rot indefinitely. Posters can't reassign and will churn.

### 21.5 Cancellation Policy

**Early Cancellation (>2 hours before deadline):**
- Worker: No trust impact. Task returns to OPEN.
- Poster: Full escrow refund. Task cancelled.

**Late Cancellation (<2 hours before deadline):**
- Worker: `cancellation_count` incremented. Trust tier impact at thresholds:
  - 3 late cancels in 30 days → warning notification
  - 5 late cancels in 30 days → 24h task acceptance cooldown
  - 10 late cancels in 30 days → trust tier review
- Poster: Full escrow refund. Worker receives notification.

**No-Show (worker doesn't arrive within 30 min of deadline):**
- System auto-cancels task
- Worker: `no_show_count` incremented, shadow flag `NO_SHOW_PATTERN` added
- 2 no-shows in 30 days → 48h acceptance cooldown
- 5 no-shows in 30 days → trust tier demotion

**Poster Late Cancel After Acceptance (worker already EN_ROUTE):**
- Poster: 15% cancellation fee from escrow (covers worker's wasted travel time)
- Worker: receives cancellation fee via Stripe transfer
- Remaining 85% of escrow refunded to poster

**Enforcement:**
- `cancellation_count`, `no_show_count`, `last_cancellation_at` columns on users table
- Background job monitors no-show patterns
- Cancellation fee calculated at API layer, processed via Stripe

### 21.6 API Rate Limiting

All API endpoints are rate-limited per authenticated user and per IP address.

| Endpoint Category | Per-User Limit | Per-IP Limit |
|---|---|---|
| task.create | 10/hour | 20/hour |
| task.accept | 20/hour | 30/hour |
| task.list / task.getFeed | 60/min | 120/min |
| messaging.send | 60/min | 100/min |
| proof.submit | 10/hour | 20/hour |
| user.* (reads) | 120/min | 200/min |
| user.* (writes) | 20/min | 30/min |
| auth.* | 5/min | 10/min |
| admin.* | 60/min | N/A |
| WebSocket connections | 5 concurrent | 10 concurrent |

**Enforcement:**
- Redis sliding window counter (BACKEND_STACK_LOCK: Redis is in stack)
- Response: HTTP 429 with `Retry-After` header (seconds)
- Error code: `RATE_LIMITED` — "Rate limit exceeded"
- Burst allowance: 2× limit for 10-second window, then hard block

### 21.7 User Block/Mute

Users can block other users to prevent future interactions.

**Block effects:**
- Blocked user's tasks do not appear in blocker's feed
- Blocker's tasks do not appear in blocked user's feed
- Blocked user cannot send messages to blocker (and vice versa)
- Existing message threads become read-only for both parties
- Block is bidirectional for feed visibility, unidirectional for control (only the blocker can unblock)

**Enforcement:**
- `user_blocks` table: `blocker_id`, `blocked_id`, `created_at`, `reason`
- Feed query joins against `user_blocks` to filter results
- Messaging endpoint checks block status before allowing send
- API: `user.block`, `user.unblock`, `user.getBlockList`
- Maximum blocks per user: 100 (prevents abuse of block system for feed manipulation)

---

## §22. Dispute Resolution Protocol (Expanded)

Supersedes §7 for implementation detail. §7 remains as summary.

### 22.1 Dispute Timeline SLAs

| Phase | SLA | Action if Breached |
|---|---|---|
| AI Triage | 1 hour | Auto-escalate to human review |
| Human Review | 72 hours | Alert operations team |
| Admin Decision | 7 days | Escalate to founder |
| Founder Decision | 14 days | Auto-release to worker (worker-favorable default) |
| **Total Maximum** | **21 days** | Escrow auto-releases to worker |

**Rationale:** Worker-favorable default on timeout — the work was done, the poster is unresponsive. Funds should not be frozen indefinitely.

### 22.2 Evidence Requirements

| Evidence Type | Required From | Weight |
|---|---|---|
| Proof photos (existing) | Worker | High |
| Task description (existing) | System | High |
| Message history (existing) | System | Medium |
| GPS movement data | System | Medium |
| Additional photos/screenshots | Either party | Medium |
| Written statement (500 char max) | Either party | Low |

### 22.3 Resolution Options

| Outcome | Escrow | XP | Trust Impact |
|---|---|---|---|
| Worker wins (100%) | RELEASED | Full award | Poster: dispute_loss_count++ |
| Poster wins (100%) | REFUNDED | None | Worker: dispute_loss_count++ |
| Split (custom %) | REFUND_PARTIAL | Proportional | Both: neutral |
| Mutual cancel | REFUNDED | None | Neither impacted |

### 22.4 Appeal Process

- Either party may appeal within 48 hours of resolution
- Appeal requires new evidence not previously submitted
- Appeal reviewed by different admin than original decision
- Maximum 1 appeal per dispute
- Appeal decision is final

### 22.5 Duplicate Dispute Prevention

- Only ONE active dispute per task at any time
- If both parties file simultaneously, merge into single dispute
- Resolved disputes cannot be re-opened (appeal process is the only recourse)

---

## §23. Sybil Prevention & Identity Verification

### 23.1 Phone Number Verification

- Required during signup (after Firebase Auth email, before onboarding)
- One phone number per account (UNIQUE constraint)
- SMS verification code (6 digits, 5-minute expiry)
- Banned phone numbers cannot create new accounts
- VoIP numbers blocked (Twilio Lookup API carrier type check)

### 23.2 Device Fingerprinting

- Device fingerprint collected at signup and login
- Fingerprint includes: OS version, device model, screen resolution, timezone, language
- `device_fingerprints` table tracks all devices per user
- Alert if >3 accounts share same device fingerprint
- Banned user's device fingerprints are blocklisted

### 23.3 Stripe Connect Deduplication

- Stripe Connect account ID is UNIQUE per platform
- SSN/EIN used for Stripe identity verification prevents duplicate workers
- Cross-reference: if Stripe reports same SSN on two accounts → flag for review

### 23.4 Ban Evasion Detection

When a user is suspended/banned, the system records:
- Phone number → `banned_phones` table
- Device fingerprints → `banned_devices` table  
- Stripe account ID → `banned_stripe_accounts` table
- Email domain pattern (if disposable email service)

New signups are checked against all ban lists. Match → account creation blocked with generic "Unable to create account" message (no information leakage about why).

---

## §24. Email Verification

- Firebase Auth sends verification email on signup
- Account is created but `email_verified = false`
- User can browse app but CANNOT: create tasks, accept tasks, send messages, or set up Stripe
- Verification link expires after 24 hours
- Resend verification: max 3 per hour
- After verification: `email_verified = true`, full access granted

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial authoritative specification |
| 1.0.1 | Jan 2025 | HustleXP Core | Fixed: Error codes aligned with schema.sql (HX004, HX401, HX801) |
| 1.1.0 | Jan 2025 | HustleXP Core | Added: §3.5 Task Modes, §3.6 Live Task Lifecycle, HX9XX error codes |
| 1.2.0 | Jan 2025 | HustleXP Core | Added: §3.7 Global Fatigue, §8.3 Private Percentile, §8.4 Poster Reputation, §19 Account Pause |
| 1.3.0 | Jan 2025 | HustleXP Core | Added: §8 AI Task Completion System (contract-completion engine) |
| 1.4.0 | Jan 2025 | HustleXP Core | Added: §9 Task Discovery, §10 Messaging, §11 Notifications, §12 Ratings, §13 Analytics, §14 Fraud Detection, §15 Content Moderation, §16 GDPR Compliance |
| 1.5.0 | Jan 2025 | HustleXP Core | Added: §17 Capability-Driven Eligibility System, integrated 8 eligibility invariants (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8), updated §3 (Task Requirements), §8 (Trust Tiers + Onboarding), renumbered sections 17→18, 18→19, 19→20 |
| 1.6.0 | Feb 2026 | HustleXP Core | Added: §21 Marketplace Safety Invariants (concurrent task limit, rejection loop, max price, stale timeout, cancellation policy, rate limiting, user blocking), §22 Expanded Dispute Protocol, §23 Sybil Prevention, §24 Email Verification, §25 Language & Internationalization. Fixes 42-gap audit. |

---

## §25. Language & Internationalization

**v1 is English-only.** All UI copy, error messages, notification text, stitch prompts, AI-generated content, and legal documents are in US English.

**Internationalization readiness rules:**
- All user-facing strings SHOULD be referenced by i18n key (e.g., `i18n('task.created.success')`) even if the translation file only contains English values
- Error messages in API responses use error codes (HX-series) as the canonical identifier; human-readable text is for developer convenience only — clients render their own localized copy
- Stitch prompts contain hardcoded English copy; future i18n requires a copy extraction pass
- Legal documents (ToS, Privacy Policy, IC Agreement) are English-only; translated versions require legal review before deployment
- Date/time formatting uses ISO 8601 for storage and transfer; client formats per device locale
- Currency is USD only (v1); amounts stored in cents as integers

**Future i18n scope (not v1):** Spanish (US market), currency localization, RTL support.

---

**END OF PRODUCT_SPEC v1.6.0**
