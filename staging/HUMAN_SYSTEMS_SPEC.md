# HustleXP Human Systems Specification v0.1.0

**STATUS: STAGING — PENDING INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Bridge the gap from "best gig app" to "best *money* app"

---

## §0. Executive Summary

HustleXP is **structurally correct** — money moves correctly, XP is enforced, escrow is sound.

To become the **best gig money app**, it must also be:
- **Legible** — Users understand their financial state at a glance
- **Anti-fragile** — Failures are survivable, not catastrophic
- **Self-correcting** — Systems nudge toward healthy behavior

This spec defines the **human systems** that separate "impressive" from "inevitable."

---

## §1. Gap Analysis

| Gap | Description | Current State | Priority |
|-----|-------------|---------------|----------|
| **GAP-1** | Money Legibility (Money Timeline) | ❌ Missing | CRITICAL |
| **GAP-2** | Failure Recovery UX | ❌ Missing | HIGH |
| **GAP-3** | Earning Predictability (AI Forecast) | 🟡 Partial | HIGH |
| **GAP-4** | Private Percentile Status | ❌ Missing | MEDIUM |
| **GAP-5** | Anti-Burnout System | ✅ Covered (Live Mode) | EXTEND |
| **GAP-6** | Poster Quality Filtering | ❌ Missing | HIGH |
| **GAP-7** | Exit With Dignity (Pause State) | 🟡 Partial | MEDIUM |

---

## §2. GAP-1: Money Legibility System (CRITICAL)

### §2.1 Problem Statement

Users don't churn from gig apps because of UX.
They churn because they feel **financially blind**.

Money moves correctly, but users don't **feel** financially intelligent.

### §2.2 Solution: Money Timeline

A temporal view of money that answers:
- What money do I have **now**?
- What money is **coming**?
- What money is **blocked**?

### §2.3 Money Timeline UI

```
┌─────────────────────────────────────────────────────────┐
│  YOUR MONEY                                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  AVAILABLE NOW                                          │
│  $127.50                                                │
│  [ Transfer to Bank ]                                   │
│                                                         │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  TODAY                                                  │
│  + $21.25   Couch move — Released 2:34 PM              │
│  + $15.00   Grocery pickup — Released 11:20 AM         │
│                                                         │
│  COMING SOON                                            │
│  + $40.00   Deep cleaning — In escrow (task active)    │
│  + $25.00   Package delivery — In escrow (proof sent)  │
│                                                         │
│  BLOCKED                                                │
│  ⚠️ $15.00   Furniture assembly — Under review          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §2.4 Money Timeline Rules

| Category | Meaning | Color | Inclusion Criteria |
|----------|---------|-------|---------------------|
| **AVAILABLE NOW** | Withdrawable balance | Green | `escrow.state = RELEASED` AND transferred |
| **TODAY** | Recent releases | Green | Released in last 24h |
| **COMING SOON** | Earned but not released | Amber | `escrow.state = FUNDED` AND task in progress |
| **BLOCKED** | Frozen in dispute | Red | `escrow.state = LOCKED_DISPUTE` |

### §2.5 Money Timeline Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MONEY-1** | Timeline reflects actual escrow states | DB query |
| **MONEY-2** | No charts, no graphs, no gambling visuals | UI review |
| **MONEY-3** | Time + certainty only | UI review |
| **MONEY-4** | COMING SOON shows expected release date | Backend calculation |

### §2.6 Schema Additions

```sql
-- No new tables needed
-- View created from existing escrows + tasks

CREATE VIEW money_timeline AS
SELECT 
    e.id,
    e.amount_cents,
    e.state,
    e.released_at,
    t.title as task_title,
    t.state as task_state,
    CASE 
        WHEN e.state = 'RELEASED' THEN 'AVAILABLE'
        WHEN e.state = 'FUNDED' AND t.state IN ('ACCEPTED', 'PROOF_SUBMITTED') THEN 'COMING_SOON'
        WHEN e.state = 'LOCKED_DISPUTE' THEN 'BLOCKED'
        ELSE 'PENDING'
    END as timeline_category
FROM escrows e
JOIN tasks t ON e.task_id = t.id
WHERE e.worker_id = :current_user_id;
```

---

## §3. GAP-2: Failure Recovery UX (HIGH)

### §3.1 Problem Statement

When things go wrong, users feel:
- Punished silently
- Confused about consequences
- Unsure how to recover

**Best money apps explain consequences, not just apply them.**

### §3.2 Solution: Graceful Failure Paths

Every negative outcome has:
1. Clear explanation of what happened
2. Concrete impact (if any)
3. Specific next step
4. No shame language

### §3.3 Failure Recovery Screens

#### Task Failed (Hustler View)

**WRONG:**
```
Task failed. Trust penalty applied.
```

**CORRECT:**
```
┌─────────────────────────────────────────────────────────┐
│  This task didn't complete successfully                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  WHAT HAPPENED                                          │
│  The poster reported the task wasn't completed          │
│  as described.                                          │
│                                                         │
│  IMPACT                                                 │
│  • No payment for this task                             │
│  • Trust score: No change (first occurrence)            │
│                                                         │
│  WHAT YOU CAN DO                                        │
│  [ Dispute This Decision ]                              │
│  [ Accept and Move On ]                                 │
│                                                         │
│  Your next completed task restores normal standing.     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Trust Tier Demotion

```
┌─────────────────────────────────────────────────────────┐
│  Your trust tier has changed                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  VERIFIED → STANDARD                                    │
│                                                         │
│  WHY THIS HAPPENED                                      │
│  2 tasks weren't completed successfully in the          │
│  past 30 days.                                          │
│                                                         │
│  WHAT THIS MEANS                                        │
│  • Some task types may be less visible to you           │
│  • Your earnings potential is unchanged                 │
│                                                         │
│  HOW TO RECOVER                                         │
│  Complete 5 tasks successfully to restore VERIFIED.     │
│                                                         │
│  Progress: 0 / 5                                        │
│  ○ ○ ○ ○ ○                                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Dispute Lost

```
┌─────────────────────────────────────────────────────────┐
│  Dispute resolved                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  DECISION: In favor of poster                           │
│                                                         │
│  WHAT THIS MEANS                                        │
│  • Payment of $25.00 refunded to poster                 │
│  • This counts as an incomplete task                    │
│                                                         │
│  WHY THIS DECISION                                      │
│  The submitted proof didn't match the task              │
│  requirements. [View Details]                           │
│                                                         │
│  MOVING FORWARD                                         │
│  This is one outcome. Your overall record still         │
│  shows 47 successful completions.                       │
│                                                         │
│  [ Got It ]                                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §3.4 Failure Recovery Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FAIL-1** | Every negative outcome has explanation | UI review |
| **FAIL-2** | Every explanation has next step | UI review |
| **FAIL-3** | No shame language | Copy review |
| **FAIL-4** | Recovery path is always visible | UI component |
| **FAIL-5** | Impact is specific, not vague | Copy review |

### §3.5 Forbidden Copy Patterns

```javascript
const FORBIDDEN_FAILURE_COPY = [
  'You failed',
  'Penalty applied',
  'Punished',
  'Demotion',
  'Your fault',
  'Violation',      // Use "This didn't work out"
  'Strike',         // Use "Occurrence"
  'Warning',        // Use "Notice"
  'Banned',         // Use "Paused" or "Restricted"
];
```

---

## §4. GAP-3: Earning Predictability Engine (HIGH)

### §4.1 Problem Statement

Hustlers earn and progress, but they don't **predict**.

Best gig money apps answer: "If I open this app for 90 minutes, what happens?"

### §4.2 Solution: Session Forecast (AI, Read-Only)

AI predicts earning potential based on:
- Current location
- Historical performance
- Current demand
- Time of day

### §4.3 Session Forecast UI

```
┌─────────────────────────────────────────────────────────┐
│  🧠 SESSION FORECAST                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Based on your location & history:                      │
│                                                         │
│  EXPECTED EARNINGS                                      │
│  $35 – $55 in the next 90 minutes                      │
│                                                         │
│  BEST OPPORTUNITIES                                     │
│  • Delivery tasks (high demand nearby)                  │
│  • Moving help ($40+ tasks available)                   │
│                                                         │
│  CONDITIONS                                             │
│  🟢 Good — 12 active posters within 3 miles            │
│                                                         │
│  This is an estimate, not a guarantee.                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §4.4 Forecast Rules

| Rule | Description |
|------|-------------|
| Forecasts are **ranges**, not exact numbers | "$35–$55" not "$45" |
| No guarantees, no promises | Always include disclaimer |
| Accuracy improves over time | More history = better predictions |
| AI authority: **A1 (Advisory)** | Cannot make decisions |

### §4.5 Forecast Algorithm Inputs

```typescript
interface ForecastInputs {
  user_location: GeoPoint;
  time_of_day: number;          // 0-23
  day_of_week: number;          // 0-6
  user_historical_earnings: number[];
  user_completion_rate: number;
  user_avg_task_time: number;
  nearby_active_tasks: number;
  nearby_active_hustlers: number;
  category_demand: Record<string, number>;
}
```

### §4.6 Forecast Output

```typescript
interface SessionForecast {
  earnings_low: number;         // 25th percentile
  earnings_mid: number;         // 50th percentile (not shown)
  earnings_high: number;        // 75th percentile
  confidence: 'LOW' | 'MEDIUM' | 'HIGH';
  best_categories: string[];
  conditions: 'POOR' | 'FAIR' | 'GOOD' | 'EXCELLENT';
  nearby_demand: number;
  disclaimer: string;           // Always present
  generated_at: Date;
}
```

### §4.7 AI Constraints (Per AI_INFRASTRUCTURE)

```
FORECAST AI CAN:
- Predict earnings ranges
- Suggest best task categories
- Show demand conditions

FORECAST AI CANNOT:
- Guarantee any earnings
- Auto-accept tasks
- Change task visibility
- Override user decisions
```

---

## §5. GAP-4: Private Percentile Status (MEDIUM)

### §5.1 Problem Statement

Leaderboards destroy gig platforms through toxic competition.
But **status** still matters for motivation.

### §5.2 Solution: Private Percentile

Show users their relative standing **without** public ranks.

### §5.3 Private Percentile UI

```
┌─────────────────────────────────────────────────────────┐
│  YOUR STANDING (Private)                                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  RELIABILITY                                            │
│  Top 12% this week                                      │
│  ████████████░░░░░░░░                                   │
│                                                         │
│  RESPONSE TIME                                          │
│  Top 25% this week                                      │
│  ████████░░░░░░░░░░░░                                   │
│                                                         │
│  COMPLETION RATE                                        │
│  Top 8% all time                                        │
│  █████████████░░░░░░░                                   │
│                                                         │
│  Only you can see this.                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §5.4 Private Percentile Rules

| Rule | Description |
|------|-------------|
| **No usernames** | Never compare to named users |
| **No rankings** | Never show "You are #47" |
| **No competition** | Never "Beat X to unlock Y" |
| **Only self-relative** | Compare to your own history |
| **Private only** | Never visible to other users |

### §5.5 Percentile Metrics

| Metric | Calculation | Shown To |
|--------|-------------|----------|
| Reliability | Tasks completed / Tasks accepted | Hustler only |
| Response Time | Avg time to accept tasks | Hustler only |
| Completion Rate | Successful / Total tasks | Hustler only |
| Earnings Velocity | Earnings / Active hours | Hustler only |

### §5.6 Percentile Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PERC-1** | Percentiles are never public | API guard |
| **PERC-2** | No comparison to named users | UI review |
| **PERC-3** | Percentiles update weekly max | Backend job |
| **PERC-4** | Minimum 100 users for percentile | Statistical validity |

---

## §6. GAP-5: Anti-Burnout System (EXTEND)

### §6.1 Current State

Live Mode has fatigue rules:
- 3 hours continuous → Fatigue warning
- 4 hours continuous → Forced COOLDOWN

### §6.2 Extension: Global Activity Awareness

Extend fatigue awareness **beyond Live Mode**.

### §6.3 Global Fatigue Rules

| Trigger | Context | Result |
|---------|---------|--------|
| 4 hours total activity | Any mode | Gentle nudge |
| 6 hours total activity | Any mode | Stronger nudge |
| 8 hours total activity | Any mode | Mandatory break prompt |
| 7 consecutive days | Any mode | "Rest day" suggestion |

### §6.4 Fatigue Nudge UI

**Gentle (4 hours):**
```
You've been active for 4 hours today.
Consider taking a break when convenient.
[ Dismiss ]
```

**Stronger (6 hours):**
```
You've completed 6 hours of tasks today.
Taking breaks helps maintain quality.
[ Take a 15-min break ] [ Continue ]
```

**Mandatory (8 hours):**
```
┌─────────────────────────────────────────────────────────┐
│  Time for a break                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  You've been active for 8 hours today.                  │
│                                                         │
│  Great work! To maintain quality and protect your       │
│  wellbeing, please take at least a 30-minute break.     │
│                                                         │
│  TODAY'S SUMMARY                                        │
│  • 6 tasks completed                                    │
│  • $142 earned                                          │
│  • Top 15% reliability                                  │
│                                                         │
│  New tasks available in: 28:45                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §6.5 Fatigue Tracking Schema

```sql
ALTER TABLE users ADD COLUMN daily_active_minutes INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN last_activity_date DATE;
ALTER TABLE users ADD COLUMN consecutive_active_days INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN last_mandatory_break_at TIMESTAMPTZ;
```

---

## §7. GAP-6: Poster Quality Filtering (HIGH)

### §7.1 Problem Statement

Escrow protects hustlers from non-payment.
But not yet from **bad posters** who:
- Dispute unfairly
- Communicate poorly
- Create unclear tasks

### §7.2 Solution: Poster Reputation (Hustler-Only)

Surface poster history **only to hustlers**, not to posters themselves.

### §7.3 Poster Reputation UI (Task Card)

```
┌─────────────────────────────────────────────────────────┐
│  Deep cleaning needed                                   │
│  Sarah K. • VERIFIED                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  💰 $45.00 (you receive ~$38.25)                        │
│  📍 2.1 miles away                                      │
│  ✅ Escrow: FUNDED                                      │
│                                                         │
│  POSTER HISTORY                                         │
│  • 12 tasks posted                                      │
│  • 0 disputes                                           │
│  • Avg response: 2h                                     │
│  ⭐ Hustlers rate: Excellent                            │
│                                                         │
│  [ Accept Task ]                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §7.4 Poster Reputation Metrics

| Metric | Calculation | Visible To |
|--------|-------------|------------|
| Tasks Posted | COUNT(tasks) | Hustlers only |
| Dispute Rate | Disputes / Tasks | Hustlers only |
| Avg Response Time | Avg time to respond to proofs | Hustlers only |
| Hustler Rating | Avg rating from workers | Hustlers only |
| Repeat Hire Rate | Rehired same hustler % | Hustlers only |

### §7.5 Poster Reputation Rules

| Rule | Rationale |
|------|-----------|
| **Never show to posters** | Would change their behavior artificially |
| **Minimum 5 tasks** | Statistical validity |
| **Rolling 90-day window** | Recent behavior matters more |
| **No "bad poster" label** | Just facts, hustler decides |

### §7.6 Poster Rating System (Post-Task)

After task completion, hustler can rate poster:

```
How was working with Sarah?

[ 😊 Great ]  [ 😐 Okay ]  [ 😕 Difficult ]

Optional: What could be better?
[ ] Clearer task description
[ ] Faster communication
[ ] More reasonable expectations
```

### §7.7 Schema Additions

```sql
CREATE TABLE poster_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    poster_id UUID NOT NULL REFERENCES users(id),
    rated_by UUID NOT NULL REFERENCES users(id),  -- Hustler
    
    rating VARCHAR(20) NOT NULL CHECK (rating IN ('GREAT', 'OKAY', 'DIFFICULT')),
    feedback_flags TEXT[],
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    UNIQUE(task_id, rated_by)  -- One rating per task per hustler
);

CREATE INDEX idx_poster_ratings_poster ON poster_ratings(poster_id);

-- Poster reputation view (for hustlers only)
CREATE VIEW poster_reputation AS
SELECT 
    u.id as poster_id,
    COUNT(DISTINCT t.id) as tasks_posted,
    COUNT(DISTINCT d.id) as disputes,
    AVG(EXTRACT(EPOCH FROM (p.reviewed_at - p.submitted_at))/3600) as avg_response_hours,
    COUNT(CASE WHEN pr.rating = 'GREAT' THEN 1 END)::FLOAT / NULLIF(COUNT(pr.id), 0) as great_rate
FROM users u
LEFT JOIN tasks t ON t.poster_id = u.id AND t.created_at > NOW() - INTERVAL '90 days'
LEFT JOIN disputes d ON d.task_id = t.id
LEFT JOIN proofs p ON p.task_id = t.id
LEFT JOIN poster_ratings pr ON pr.poster_id = u.id
WHERE u.default_mode = 'poster' OR EXISTS (SELECT 1 FROM tasks WHERE poster_id = u.id)
GROUP BY u.id;
```

---

## §8. GAP-7: Exit With Dignity (MEDIUM)

### §8.1 Problem Statement

Most gig apps trap users psychologically:
- Streak anxiety
- FOMO notifications
- Punitive decay

This destroys trust and increases churn.

### §8.2 Solution: Graceful Pause State

Let users leave **cleanly** without losing progress.

### §8.3 Pause State UI

```
┌─────────────────────────────────────────────────────────┐
│  Taking a break?                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Your progress is safe.                                 │
│                                                         │
│  WHAT'S PROTECTED                                       │
│  ✅ XP total: 1,247 (no decay)                         │
│  ✅ Level: 5 (locked in)                               │
│  ✅ Trust tier: VERIFIED (preserved)                    │
│  ✅ Badges: 12 earned (permanent)                       │
│                                                         │
│  WHAT PAUSES                                            │
│  ⏸️  Current streak: 14 days                            │
│      Grace period: 14 days from now                     │
│                                                         │
│  Resume anytime to continue where you left off.         │
│                                                         │
│  [ Pause My Account ]  [ Stay Active ]                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §8.4 Pause State Rules

| Aspect | During Pause | After Resume |
|--------|--------------|--------------|
| XP | No decay | Intact |
| Level | Frozen | Intact |
| Trust Tier | Frozen | Intact |
| Badges | Permanent | Intact |
| Streak | Grace period (configurable) | Continues if resumed in time |
| Task Visibility | Hidden from task feed | Restored |
| Notifications | None | Restored |

### §8.5 Pause Duration Tiers

| Duration | Streak Grace | Trust Protection |
|----------|--------------|------------------|
| Up to 14 days | Full streak preserved | Full protection |
| 15-30 days | Streak resets to 1 | Trust tier preserved |
| 31-90 days | Streak resets to 1 | Trust tier preserved |
| 90+ days | Streak resets to 1 | Trust tier drops one level |

### §8.6 Schema Additions

```sql
ALTER TABLE users ADD COLUMN account_status VARCHAR(20) DEFAULT 'ACTIVE'
    CHECK (account_status IN ('ACTIVE', 'PAUSED', 'SUSPENDED'));
ALTER TABLE users ADD COLUMN paused_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN pause_streak_snapshot INTEGER;
ALTER TABLE users ADD COLUMN pause_trust_tier_snapshot INTEGER;
```

### §8.7 Pause Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PAUSE-1** | XP never decays during pause | Backend logic |
| **PAUSE-2** | Badges are permanent regardless | DB constraint |
| **PAUSE-3** | Pause is always available | UI always shows option |
| **PAUSE-4** | Resume is instant | No "reactivation" delay |
| **PAUSE-5** | No punitive notifications | Notification service |

---

## §9. UI Copy Contract

### §9.1 Tone Principles

| Principle | Description |
|-----------|-------------|
| **Certainty over hope** | "You will receive $40" not "You may earn up to $40" |
| **Facts over feelings** | "12 tasks completed" not "Great job!" |
| **Path over punishment** | "Complete 3 tasks to restore" not "Penalty applied" |
| **Time over urgency** | "Available until Friday" not "Hurry!" |

### §9.2 Forbidden Patterns

```javascript
const FORBIDDEN_COPY = [
  // Urgency
  'Hurry', 'Act now', 'Limited time', 'Don\'t miss',
  
  // Shame
  'You failed', 'Penalty', 'Punished', 'Strike', 'Warning',
  
  // False promises
  'Guaranteed', 'Always', 'Never fail', 'Easy money',
  
  // Gambling
  'Jackpot', 'Bonus round', 'Lucky', 'Spin', 'Win',
  
  // Manipulation
  'Everyone is doing it', 'You\'re missing out', 'Last chance'
];
```

---

## §10. Implementation Priority

### Phase 1: Foundation (Week 1-2)
- [ ] Money Timeline view
- [ ] Failure Recovery screens (3 core screens)
- [ ] Poster reputation schema

### Phase 2: Intelligence (Week 3-4)
- [ ] Session Forecast (AI integration)
- [ ] Private Percentile calculations
- [ ] Poster rating system

### Phase 3: Protection (Week 5-6)
- [ ] Global fatigue tracking
- [ ] Pause state implementation
- [ ] Notification constraints

### Phase 4: Polish (Week 7-8)
- [ ] Copy review against forbidden patterns
- [ ] Edge case UX
- [ ] Integration testing

---

## §11. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Financial Clarity** | 90% users understand money state | Survey |
| **Failure Recovery** | 70% resume after negative event | Retention |
| **Prediction Accuracy** | ±20% of forecast | Backend tracking |
| **Burnout Prevention** | <5% work 8+ hours regularly | Activity logs |
| **Voluntary Pause** | 40% return within 14 days | Pause tracking |
| **Poster Quality** | 15% fewer disputes | Dispute rate |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 0.1.0 | Jan 2025 | Initial human systems specification |

---

**END OF HUMAN_SYSTEMS_SPEC v0.1.0 (STAGING)**
