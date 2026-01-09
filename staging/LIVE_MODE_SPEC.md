# HustleXP LIVE MODE Specification v0.1.0

**STATUS: STAGING — PENDING INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Integration Target:** PRODUCT_SPEC §3.5, UI_SPEC §13, ARCHITECTURE §10

---

## §0. Executive Summary

LIVE MODE is a **real-time task fulfillment system** that enables immediate task matching when both parties explicitly opt in. It is not a "rush" feature—it is a **mode switch** that activates a higher-intensity, higher-trust marketplace layer.

**Core Principle:**
> Live Mode turns HustleXP into a real-time marketplace — but only when both sides explicitly opt in.

**What LIVE MODE is NOT:**
- ❌ "ASAP" / "Rush" / "Urgent" / "Instant" (race-to-bottom language)
- ❌ Always-on worker surveillance
- ❌ Dark pattern notifications
- ❌ Gig panic exploitation

**What LIVE MODE IS:**
- ✅ Explicit poster intent declaration
- ✅ Explicit hustler availability opt-in
- ✅ Real-time state signaling (not advertising)
- ✅ Higher price floors, higher responsibility
- ✅ Session-based, fatigue-aware game mechanic

---

## §1. Constitutional Constraints

### §1.1 LIVE MODE Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **LIVE-1** | Live tasks require FUNDED escrow | DB trigger |
| **LIVE-2** | Live tasks require elevated price floor | DB constraint |
| **LIVE-3** | Hustlers must explicitly opt into Live Mode | UI + DB state |
| **LIVE-4** | Live broadcasts are geo-bounded | Backend service |
| **LIVE-5** | Live broadcasts are time-bounded (TTL) | Backend service |
| **LIVE-6** | Live Mode is session-based, not permanent | State machine |
| **LIVE-7** | No auto-accept, no AI task assignment | Constitutional |

### §1.2 Authority Model

| Layer | Authority | Live Mode Scope |
|-------|-----------|-----------------|
| Layer 0 (Database) | Highest | LIVE-1, LIVE-2 enforcement |
| Layer 1 (Backend) | High | LIVE-4, LIVE-5, broadcast routing |
| Layer 2 (API) | Medium | Mode switching, availability state |
| Layer 3 (Frontend) | Low | UI mode shifts, notifications |
| AI | Advisory Only | Recommendations, never decisions |

---

## §2. Mode Definitions

### §2.1 Task Modes (Poster Intent)

Every task has exactly one mode, declared at creation.

```typescript
type TaskMode = 'STANDARD' | 'LIVE';
```

| Mode | Description | Default |
|------|-------------|---------|
| **STANDARD** | Normal task feed, no time pressure | ✅ Yes |
| **LIVE** | Real-time fulfillment, elevated visibility | No |

**Mode is immutable after task creation.** A poster cannot switch a STANDARD task to LIVE after workers have seen it.

### §2.2 Hustler Availability States

Hustlers control their Live Mode availability via explicit toggle.

```typescript
type HustlerLiveState = 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
```

| State | Meaning | Receives Live Broadcasts |
|-------|---------|--------------------------|
| **OFF** | Not opted in | ❌ |
| **ACTIVE** | Explicitly available | ✅ |
| **COOLDOWN** | Temporary rest after completions | ❌ |
| **PAUSED** | System-triggered (fatigue, decline rate) | ❌ |

**Default state: OFF.** No hustler is ever auto-enrolled in Live Mode.

---

## §3. Poster Flow

### §3.1 Task Creation Mode Selection

At task creation, after describing the task and setting price:

```
┌─────────────────────────────────────────────────────────┐
│  FULFILLMENT MODE                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ STANDARD                                             │
│    Task appears in normal feed                          │
│    Workers browse at their pace                         │
│                                                         │
│  ○ LIVE                                                 │
│    Real-time matching with nearby hustlers              │
│    Minimum price: $15.00                                │
│    Requires funded escrow before broadcast              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- STANDARD is pre-selected
- LIVE requires confirmation of elevated minimum
- Mode selection happens BEFORE payment
- Mode displayed on task card permanently

### §3.2 Live Task Creation Flow

```
1. Poster creates task (title, description, location)
2. Poster sets price (enforced ≥ $15 for LIVE)
3. Poster selects LIVE MODE
4. System displays: "Live tasks broadcast immediately after payment"
5. Poster confirms and pays (escrow.state → FUNDED)
6. Broadcast begins (task.live_broadcast_started_at = NOW())
7. Poster sees: "Broadcasting to nearby hustlers..."
```

### §3.3 Poster Live Task Card

When a hustler accepts:

```
┌─────────────────────────────────────────────────────────┐
│  🟢 HUSTLER ON THE WAY                                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Marcus                                                 │
│  ⭐ VERIFIED • 47 tasks completed                       │
│                                                         │
│  ETA: ~12 minutes                                       │
│  Distance: 1.2 miles                                    │
│                                                         │
│  [ Message ]                                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- No animation spam
- No confetti
- Just certainty: name, trust tier, ETA
- This is the screenshot moment

### §3.4 No Hustler Available Flow

If no hustler accepts within TTL (default: 10 minutes):

```
┌─────────────────────────────────────────────────────────┐
│  No nearby hustlers available right now                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Your escrow remains secured.                           │
│                                                         │
│  Options:                                               │
│  [ Switch to Standard ] — Task joins normal feed        │
│  [ Increase Price ]     — Rebroadcast at higher rate    │
│  [ Cancel & Refund ]    — Full refund to card           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- No fake "searching..." animations
- No false hope
- Escrow remains FUNDED until poster decides
- Clear options with honest outcomes

---

## §4. Hustler Flow

### §4.1 Live Mode Opt-In

The Live Mode toggle is a **top-level control**, not buried in settings.

**Location:** Home screen or persistent header when hustler role active.

```
┌─────────────────────────────────────────────────────────┐
│  LIVE MODE                                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [ ○ OFF ]                                              │
│                                                         │
│  Turn on to receive real-time task broadcasts           │
│  based on your location.                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

When toggled ON:

```
┌─────────────────────────────────────────────────────────┐
│  LIVE MODE                                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [ ● ACTIVE ]                                           │
│                                                         │
│  🟢 Actively available                                  │
│  You'll receive live task broadcasts nearby             │
│                                                         │
│  Session started: 2:34 PM                               │
│  Tasks this session: 0                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### §4.2 Live Task Notification

When a live task broadcasts, hustlers in range receive a **state signal**, not an ad.

**Notification Format:**

```
LIVE TASK nearby
$35 • 1.2 miles • Escrow funded
[View Task]
```

**Rules:**
- Shows price (what hustler receives after fees)
- Shows distance
- Confirms escrow is funded (trust signal)
- No urgency language ("Act now!", "Limited time!")
- No sound effects beyond system default

### §4.3 Live Task Card (Hustler View)

```
┌─────────────────────────────────────────────────────────┐
│  🔴 LIVE                                                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Help move furniture                                    │
│  Sarah K. • VERIFIED                                    │
│                                                         │
│  💰 $35.00 (you receive ~$29.75)                        │
│  📍 1.2 miles away                                      │
│  ⏱️  Posted 45 seconds ago                              │
│  ✅ Escrow: FUNDED                                      │
│                                                         │
│  [ Accept Task ]                                        │
│                                                         │
│  Other hustlers viewing: 3                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- Clear price breakdown
- Distance visible
- Escrow state visible (always FUNDED for live)
- Social proof: how many others are viewing (optional, configurable)
- No countdown timers (creates panic)

### §4.4 Hustler HUD (Active Live Mode)

When Live Mode is ACTIVE, the main interface shifts:

```
┌─────────────────────────────────────────────────────────┐
│  LIVE MODE ACTIVE                                       │
│  ──────────────────────────────────────────────────     │
│  Tasks prioritized by proximity & payout                │
│  Session: 47 minutes • Tasks: 2 • Earned: $52          │
└─────────────────────────────────────────────────────────┘
```

This creates a **skill layer**:
- Fast decision-making (not panic tapping)
- Geographic awareness
- Availability mastery

### §4.5 Session Management

Live Mode is **session-based**, not permanent.

```typescript
interface LiveSession {
  started_at: Date;
  tasks_accepted: number;
  tasks_declined: number;
  tasks_completed: number;
  earnings: number;
  state: 'ACTIVE' | 'COOLDOWN' | 'PAUSED' | 'ENDED';
}
```

**Session Rules:**

| Trigger | Result |
|---------|--------|
| 2 tasks accepted in session | Automatic COOLDOWN (15 min) |
| 5 declines without acceptance | PAUSED (reduced broadcasts) |
| 3 hours continuous | Fatigue warning |
| 4 hours continuous | Forced COOLDOWN (30 min) |
| Manual toggle OFF | Session ENDED |

**Cooldown Screen:**

```
┌─────────────────────────────────────────────────────────┐
│  COOLDOWN                                               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Great work! Taking a short break.                      │
│                                                         │
│  Tasks completed: 2                                     │
│  Earned this session: $52                               │
│                                                         │
│  Live Mode resumes in: 12:34                            │
│                                                         │
│  [ End Session Early ]                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## §5. Pricing Rules

### §5.1 Elevated Price Floor

Live Mode tasks have a **system-enforced minimum** higher than standard.

| Mode | Minimum Price | Rationale |
|------|---------------|-----------|
| STANDARD | $5.00 | Base marketplace floor |
| LIVE | $15.00 | Prevents spam, values hustler time |

**Dynamic pricing (future):**
- Geo-adjusted minimums
- Demand-based floors
- Time-of-day adjustments

### §5.2 Price Display Rules

```
Poster creates: $35 task (LIVE)
Platform fee: 15% = $5.25
Hustler receives: $29.75

Poster pays: $35 + fee = $40.25
Hustler sees: "$35 (you receive ~$29.75)"
```

All prices displayed in the currency amount the viewer cares about:
- Posters see total cost
- Hustlers see their take-home

---

## §6. Broadcast System

### §6.1 Geo-Bounding

Live tasks broadcast to hustlers within a **configurable radius**.

```typescript
interface LiveBroadcastConfig {
  initial_radius_miles: number;    // Default: 3
  max_radius_miles: number;        // Default: 10
  expansion_interval_seconds: number; // Default: 60
  expansion_step_miles: number;    // Default: 2
}
```

**Expansion Logic:**
1. Broadcast to hustlers within 3 miles
2. If no acceptance after 60s, expand to 5 miles
3. Continue until max radius or TTL expires

### §6.2 Time-Bounding (TTL)

Live broadcasts have a **time-to-live**.

```typescript
interface LiveTaskTTL {
  broadcast_ttl_minutes: number;   // Default: 10
  acceptance_window_seconds: number; // Default: 120 (per hustler)
}
```

**Rules:**
- After TTL, task stops broadcasting
- Poster is notified of expiration
- Task remains FUNDED, poster chooses next action

### §6.3 Tier-Bounding (Optional)

Posters can optionally request hustlers of minimum trust tier.

```
[ ] Any hustler
[x] VERIFIED or higher
[ ] TRUSTED only
```

**Rules:**
- Higher tier = smaller pool = longer wait
- System warns poster of reduced availability
- Cannot require tier higher than VERIFIED for first-time posters

---

## §7. XP and Trust Implications

### §7.1 XP Awards

Live tasks award XP using the standard formula with a **Live Mode multiplier**.

```
live_xp = effective_xp × 1.25
```

**Rationale:** Live tasks require availability commitment and fast response.

### §7.2 Trust Impact

Live Mode has **elevated responsibility**.

| Action | Trust Impact (Standard) | Trust Impact (Live) |
|--------|------------------------|---------------------|
| Complete task | +1 | +1.5 |
| Abandon after accept | -2 | -4 |
| Decline (no penalty) | 0 | 0 |
| Complete under 30 min | +0.5 | +1 |

**Abandonment in Live Mode is severely penalized** because the poster had real-time expectations.

### §7.3 Live Mode Performance Score

Hustlers build a **Live Mode reputation** separate from general stats.

```typescript
interface LiveModeStats {
  total_live_tasks: number;
  live_completion_rate: number;    // Must stay > 90%
  average_response_time_seconds: number;
  average_eta_accuracy: number;    // Actual vs predicted
  live_earnings_total: number;
}
```

**Consequences:**
- `live_completion_rate < 80%` → PAUSED from Live Mode (7 days)
- `live_completion_rate < 70%` → BANNED from Live Mode (30 days)

---

## §8. AI Constraints

### §8.1 AI Authority Level

AI in Live Mode is **strictly advisory** (A1 per AI_INFRASTRUCTURE).

```
AI CAN:
- Recommend when to enable Live Mode
- Predict earnings potential
- Summarize session performance
- Suggest optimal availability windows

AI CANNOT:
- Force Live Mode on/off
- Auto-accept tasks
- Override pricing
- Change broadcast ordering
- Make accept/decline decisions
```

### §8.2 AI Recommendation Examples

**To Hustler:**

```
"Based on your location and history, Live Mode could yield ~$45 in the next hour."

"High demand in your area right now. Consider enabling Live Mode."

"You've been active for 3 hours. Consider a break."
```

**To Poster:**

```
"3 VERIFIED hustlers are in Live Mode nearby. Average response: 45 seconds."

"Demand is high. Consider increasing price to $40 for faster matching."
```

### §8.3 AI Logging Requirements

Per AI_INFRASTRUCTURE §8.3, all AI recommendations must be logged:

```typescript
interface AILiveModeRecommendation {
  user_id: string;
  recommendation_type: 'ENABLE_LIVE' | 'DISABLE_LIVE' | 'PRICE_SUGGESTION' | 'BREAK_SUGGESTION';
  confidence: number;
  context: {
    user_location: GeoPoint;
    nearby_demand: number;
    user_fatigue_score: number;
    historical_earnings: number;
  };
  user_action: 'ACCEPTED' | 'DISMISSED' | 'IGNORED';
  timestamp: Date;
}
```

---

## §9. Edge Cases and Abuse Prevention

### §9.1 Hustler Accepts Then Abandons

**Scenario:** Hustler accepts live task, then goes dark.

**Defenses:**
1. ETA tracking (hustler must share location while en route)
2. Check-in requirement at 50% of ETA
3. Poster can report "no show" after ETA + 15 min
4. Trust penalty: -4 (2x standard abandonment)
5. Live Mode ban: 7 days after 2 abandonments

### §9.2 Hustler Accepts to Block Others

**Scenario:** Hustler accepts then immediately cancels to grief competitors.

**Defenses:**
1. Cancel within 60 seconds = no penalty (changed mind)
2. Cancel after 60 seconds = counted as abandonment
3. Pattern detection: 3 quick cancels = PAUSED
4. Repeated pattern = Live Mode ban

### §9.3 Poster Creates Fake Live Tasks

**Scenario:** Poster creates live tasks to see who's available, then cancels.

**Defenses:**
1. Escrow is funded before broadcast (real money committed)
2. Cancel after broadcast = fee retained (platform keeps 5%)
3. Pattern detection: 3 cancels in 24h = Live Mode restricted
4. Repeated pattern = account review

### §9.4 Hustler Toggle Spam

**Scenario:** Hustler rapidly toggles Live Mode to game broadcasts.

**Defenses:**
1. Toggle cooldown: 5 minutes between OFF → ON
2. Session must be active for 10+ minutes to count
3. Pattern detection flags rapid togglers

### §9.5 Location Spoofing

**Scenario:** Hustler fakes location to receive more broadcasts.

**Defenses:**
1. GPS + cell tower triangulation
2. Movement pattern analysis
3. ETA reasonableness check
4. Poster proximity verification at task start
5. Spoofing detection = permanent Live Mode ban

---

## §10. Database Schema Additions

### §10.1 Tasks Table Additions

```sql
-- Add to tasks table
ALTER TABLE tasks ADD COLUMN mode VARCHAR(20) DEFAULT 'STANDARD'
    CHECK (mode IN ('STANDARD', 'LIVE'));
ALTER TABLE tasks ADD COLUMN live_broadcast_started_at TIMESTAMPTZ;
ALTER TABLE tasks ADD COLUMN live_broadcast_expired_at TIMESTAMPTZ;
ALTER TABLE tasks ADD COLUMN live_broadcast_radius_miles NUMERIC(4,1);
```

### §10.2 Users Table Additions

```sql
-- Add to users table
ALTER TABLE users ADD COLUMN live_mode_state VARCHAR(20) DEFAULT 'OFF'
    CHECK (live_mode_state IN ('OFF', 'ACTIVE', 'COOLDOWN', 'PAUSED'));
ALTER TABLE users ADD COLUMN live_mode_session_started_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN live_mode_banned_until TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN live_mode_total_tasks INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN live_mode_completion_rate NUMERIC(5,4);
```

### §10.3 Live Sessions Table

```sql
CREATE TABLE live_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    end_reason VARCHAR(20) CHECK (end_reason IN ('MANUAL', 'COOLDOWN', 'FATIGUE', 'FORCED')),
    
    tasks_accepted INTEGER DEFAULT 0,
    tasks_declined INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    earnings_cents INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_live_sessions_user ON live_sessions(user_id);
CREATE INDEX idx_live_sessions_started ON live_sessions(started_at);
```

### §10.4 Live Broadcasts Table

```sql
CREATE TABLE live_broadcasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expired_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    accepted_by UUID REFERENCES users(id),
    
    initial_radius_miles NUMERIC(4,1) NOT NULL,
    final_radius_miles NUMERIC(4,1),
    hustlers_notified INTEGER DEFAULT 0,
    hustlers_viewed INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_live_broadcasts_task ON live_broadcasts(task_id);
CREATE INDEX idx_live_broadcasts_active ON live_broadcasts(started_at) 
    WHERE expired_at IS NULL AND accepted_at IS NULL;
```

### §10.5 Invariant Triggers

```sql
-- LIVE-1: Live tasks require FUNDED escrow
CREATE OR REPLACE FUNCTION live_task_requires_funded_escrow()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.mode = 'LIVE' AND NEW.live_broadcast_started_at IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM escrows 
            WHERE task_id = NEW.id AND state = 'FUNDED'
        ) THEN
            RAISE EXCEPTION 'LIVE-1_VIOLATION: Cannot broadcast live task without funded escrow. Task: %', NEW.id
                USING ERRCODE = 'HX901';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER live_task_escrow_check
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    WHEN (NEW.live_broadcast_started_at IS DISTINCT FROM OLD.live_broadcast_started_at)
    EXECUTE FUNCTION live_task_requires_funded_escrow();

-- LIVE-2: Live tasks require elevated price floor
CREATE OR REPLACE FUNCTION live_task_price_floor()
RETURNS TRIGGER AS $$
DECLARE
    live_minimum_cents INTEGER := 1500; -- $15.00
BEGIN
    IF NEW.mode = 'LIVE' AND NEW.price < live_minimum_cents THEN
        RAISE EXCEPTION 'LIVE-2_VIOLATION: Live tasks require minimum price of $15.00. Task: %, Price: %', 
            NEW.id, NEW.price
            USING ERRCODE = 'HX902';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER live_task_price_check
    BEFORE INSERT OR UPDATE ON tasks
    FOR EACH ROW
    WHEN (NEW.mode = 'LIVE')
    EXECUTE FUNCTION live_task_price_floor();
```

---

## §11. Error Codes

| Code | Meaning | Trigger |
|------|---------|---------|
| `HX901` | Live broadcast without funded escrow | LIVE-1 violation |
| `HX902` | Live task below price floor | LIVE-2 violation |
| `HX903` | Hustler not in ACTIVE state | Accept attempt while OFF/COOLDOWN/PAUSED |
| `HX904` | Live Mode toggle cooldown | Toggle attempt within 5 minutes |
| `HX905` | Live Mode banned | Attempt to enable while banned |

---

## §12. UI_SPEC Additions

### §12.1 Mode Indicator Colors

```
LIVE_INDICATOR:    #EF4444 (Red-500) — Urgency, real-time
STANDARD_INDICATOR: #6B7280 (Gray-500) — Neutral, default
```

### §12.2 Live Task Card Rules

- Red "🔴 LIVE" badge in top-left
- No countdown timers (creates panic)
- No urgency copy ("Act now!", "Limited!")
- Escrow state always visible
- Distance always visible

### §12.3 Live Mode Toggle Rules

- Toggle must be prominent (not buried)
- State change requires confirmation
- Cooldown state clearly communicated
- Session stats visible when active

### §12.4 Notification Rules

- Notifications are state signals, not ads
- Format: "LIVE TASK nearby — $X — X miles — Escrow funded"
- No sound effects beyond system default
- No vibration patterns beyond system default
- Respect Do Not Disturb

---

## §13. Viral Mechanics

### §13.1 Poster Screenshot Moment

The moment a hustler accepts:

```
🟢 Hustler On The Way
Marcus • VERIFIED
ETA: ~12 minutes
```

**This is shareable because:**
- Clear, immediate result
- Human connection (name, verification)
- Certainty (ETA, not "searching...")

### §13.2 Hustler Share Moment

After a successful Live Mode session:

```
Session Complete
──────────────────
2 tasks • $52 earned • 1.5 hours
Live Mode performance: ⭐ Excellent
```

**This is shareable because:**
- Concrete earnings
- Time efficiency visible
- Skill validation (performance rating)

### §13.3 What Gets Shared

**Posters share:**
> "I posted a task and someone was on the way in 30 seconds."

**Hustlers share:**
> "Turned on Live Mode and made $60 in an hour."

---

## §14. Integration Points

### §14.1 PRODUCT_SPEC Integration

Add to §3 (Task Lifecycle):
- §3.5 Task Modes (STANDARD, LIVE)
- §3.6 Live Task Lifecycle

### §14.2 UI_SPEC Integration

Add:
- §13 Mode-Based UI Shifts
- Live Mode color semantics
- Live notification rules

### §14.3 ARCHITECTURE Integration

Add:
- §10 Live Mode Authority
- Broadcast service jurisdiction

### §14.4 ONBOARDING_SPEC Integration

Add:
- Live Mode introduction (post first task completion)
- Never shown during initial onboarding

### §14.5 AI_INFRASTRUCTURE Integration

Add:
- Live Mode recommendation rules
- Session optimization suggestions

---

## §15. Implementation Checklist

### Phase 0: Schema
- [ ] Add task.mode column
- [ ] Add user.live_mode_state column
- [ ] Create live_sessions table
- [ ] Create live_broadcasts table
- [ ] Add LIVE-1, LIVE-2 triggers
- [ ] Add HX901-HX905 error codes

### Phase 1: Backend
- [ ] LiveBroadcastService
- [ ] GeoMatchingService
- [ ] LiveSessionService
- [ ] LiveModeToggleEndpoint
- [ ] LiveTaskCreateEndpoint

### Phase 2: Frontend
- [ ] LiveModeToggle component
- [ ] LiveTaskCard component
- [ ] LiveHustlerHUD component
- [ ] LiveSessionSummary component
- [ ] LiveNotificationHandler

### Phase 3: Integration
- [ ] Push notification integration
- [ ] Location services integration
- [ ] Real-time WebSocket for broadcasts

### Phase 4: Testing
- [ ] LIVE-1 kill test
- [ ] LIVE-2 kill test
- [ ] Session management tests
- [ ] Abuse scenario tests

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 0.1.0 | Jan 2025 | Initial staging specification |

---

**END OF LIVE_MODE_SPEC v0.1.0 (STAGING)**
