# HustleXP Product Specification v1.2.0

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
| **LIVE-4** | Live broadcasts are geo-bounded | Backend service |
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

## §8. AI Task Completion System

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

**Detailed specification:** See `staging/AI_TASK_COMPLETION_SPEC.md`

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

**Detailed specification:** See `staging/TASK_DISCOVERY_SPEC.md`

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
| **MSG-4** | Maximum 500 characters per text message | Backend validation |
| **MSG-5** | Chat history is immutable after task COMPLETED | Backend validation |

**Detailed specification:** See `staging/MESSAGING_SPEC.md`

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

**Detailed specification:** See `staging/NOTIFICATION_SPEC.md`

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

**Detailed specification:** See `staging/RATING_SYSTEM_SPEC.md`

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

**Detailed specification:** See `staging/ANALYTICS_SPEC.md`

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

**Detailed specification:** See `staging/FRAUD_DETECTION_SPEC.md`

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

**Detailed specification:** See `staging/CONTENT_MODERATION_SPEC.md`

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

**Detailed specification:** See `staging/GDPR_COMPLIANCE_SPEC.md`

---

## §17. Monetary Rules

### 17.1 Minimum Task Value

- Minimum: $5.00 (500 cents)
- Platform fee: 15% (deducted from escrow before release)
- Worker receives: 85% of posted amount

### 17.2 Currency

All amounts stored in **USD cents** (integers). No floating point.

```sql
amount INTEGER NOT NULL CHECK (amount >= 500)  -- $5 minimum
```

### 17.3 Payment Flow

1. Poster creates task with price
2. Stripe PaymentIntent created for `price + platform_fee`
3. Payment captured → escrow state = FUNDED
4. Task completed → escrow state = RELEASED
5. Stripe Transfer created to worker's connected account
6. Platform fee retained in Stripe balance

---

## §18. Error Codes

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
| `HX901` | Live broadcast without funded escrow | LIVE-1 violation |
| `HX902` | Live task below price floor | LIVE-2 violation |
| `HX903` | Hustler not in ACTIVE state | Live accept while OFF/COOLDOWN/PAUSED |
| `HX904` | Live Mode toggle cooldown | Toggle attempt within 5 minutes |
| `HX905` | Live Mode banned | Attempt to enable while banned |
| `HX601` | Fatigue break bypass | FATIGUE-4 violation (reserved) |
| `HX602` | Pause state violation | PAUSE-* violation (reserved) |
| `HX603` | Poster rep access by poster | POSTER-1 violation (reserved) |
| `HX604` | Percentile public exposure | PERC-1 violation (reserved) |
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
| `HX901` | Risk score calculation failed | FRAUD-1 violation |
| `HX902` | High-risk entity bypassed review | FRAUD-2 violation |
| `HX903` | Critical-risk entity not auto-rejected | FRAUD-3 violation |
| `HX904` | Self-match not blocked | FRAUD-4 violation |
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

## §19. Account Pause State

Users can **pause their account** without losing progress.

### 19.1 Account States

```typescript
type AccountStatus = 'ACTIVE' | 'PAUSED' | 'SUSPENDED';
```

| Status | User Action | Task Visibility | Notifications |
|--------|-------------|-----------------|---------------|
| `ACTIVE` | Full access | Visible | Enabled |
| `PAUSED` | View only | Hidden from feed | Disabled |
| `SUSPENDED` | None (admin action) | Hidden | Disabled |

### 19.2 What's Protected During Pause

| Aspect | During Pause | After Resume |
|--------|--------------|--------------|
| XP | No decay | Intact |
| Level | Frozen | Intact |
| Trust Tier | Frozen | Intact |
| Badges | Permanent | Intact |
| Earnings History | Preserved | Intact |
| Task History | Preserved | Intact |

### 19.3 Streak Grace Period

| Pause Duration | Streak Effect | Trust Effect |
|----------------|---------------|--------------|
| Up to 14 days | Full streak preserved | Full protection |
| 15-30 days | Streak resets to 1 | Trust tier preserved |
| 31-90 days | Streak resets to 1 | Trust tier preserved |
| 90+ days | Streak resets to 1 | Trust tier drops one level |

### 19.4 Pause Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PAUSE-1** | XP never decays during pause | Backend logic |
| **PAUSE-2** | Badges are permanent regardless | DB constraint |
| **PAUSE-3** | Pause is always available | UI always shows option |
| **PAUSE-4** | Resume is instant | No "reactivation" delay |
| **PAUSE-5** | No punitive notifications during pause | Notification service |

### 19.5 Pause Tracking

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

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial authoritative specification |
| 1.0.1 | Jan 2025 | HustleXP Core | Fixed: Error codes aligned with schema.sql (HX004, HX401, HX801) |
| 1.1.0 | Jan 2025 | HustleXP Core | Added: §3.5 Task Modes, §3.6 Live Task Lifecycle, HX9XX error codes |
| 1.2.0 | Jan 2025 | HustleXP Core | Added: §3.7 Global Fatigue, §8.3 Private Percentile, §8.4 Poster Reputation, §19 Account Pause |
| 1.3.0 | Jan 2025 | HustleXP Core | Added: §8 AI Task Completion System (contract-completion engine) |
| 1.4.0 | Jan 2025 | HustleXP Core | Added: §9 Task Discovery, §10 Messaging, §11 Notifications, §12 Ratings, §13 Analytics, §14 Fraud Detection, §15 Content Moderation, §16 GDPR Compliance |

---

**END OF PRODUCT_SPEC v1.4.0**
