# GAMIFICATION SYSTEM — HUSTLEXP RPG MECHANICS

**STATUS: LOCKED**
**Version:** v1.0
**Last Updated:** 2026-02-05

---

## PURPOSE

HustleXP transforms gig work into an RPG-style progression system where completing tasks earns XP, levels unlock equipment/abilities, and reputation builds trust currency. This makes routine work feel like meaningful character development.

**Core Principle:** Workers don't "start at zero" — they're immediately engaged in leveling up, unlocking perks, and building reputation that translates to higher earnings and better tasks.

---

## SYSTEM OVERVIEW

```
┌─────────────────────────────────────────────────────────┐
│                  GAMIFICATION ENGINE                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Task Completion                                        │
│        ↓                                                │
│  [XP Award] ──→ [Leveling Engine] ──→ [Equipment Unlock]│
│        ↓                ↓                      ↓        │
│  [Streak Bonus]   [XP Multiplier]      [Trust Tier]    │
│        ↓                ↓                      ↓        │
│  [Shadow Rep]     [Ability Unlock]     [Better Tasks]  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## CORE COMPONENTS

### 1. Experience Points (XP)

**Earning XP:**
- **Base XP:** 100 XP per $1 earned (e.g., $10 task = 1,000 XP)
- **Streak Bonus:** +10% XP per consecutive day worked (max +100%)
- **First Task Bonus:** +50% XP for first task of the day
- **Speed Bonus:** +25% XP for tasks completed in <50% of estimated time
- **Quality Bonus:** +50% XP for 5-star rated tasks

**XP Multipliers:**
| Condition | Multiplier | Example |
|-----------|------------|---------|
| Base (no streak) | 1.0x | $10 task = 1,000 XP |
| 3-day streak | 1.3x | $10 task = 1,300 XP |
| 7-day streak | 1.7x | $10 task = 1,700 XP |
| 10-day streak | 2.0x | $10 task = 2,000 XP |
| First task of day | 1.5x | Stacks with streak |
| Speed completion | 1.25x | Stacks with all |

**XP Display:**
- Current level and progress bar on all screens
- XP earned animation after task completion (+1,250 XP ⚡)
- Next level preview (e.g., "Level 8 → Equipment: Fast Travel")

---

### 2. Leveling System

**Level Progression:**
```
Level 0: Tutorial (0 XP)
Level 1: Novice (1,000 XP)
Level 2: Apprentice (3,000 XP)
Level 3: Journeyman (6,000 XP)
Level 4: Skilled (10,000 XP)
Level 5: Expert (15,000 XP)
Level 6: Master (21,000 XP)
Level 7: Elite (28,000 XP)
Level 8: Veteran (36,000 XP)
Level 9: Champion (45,000 XP)
Level 10: Legend (55,000 XP)
Level 11-20: +12,000 XP per level
Level 20+: Prestige tiers (cosmetic)
```

**Formula:**
- Levels 1-10: `XP_required = (level * 1000) + ((level - 1) * level * 500)`
- Levels 11+: `XP_required = previous_level_XP + 12000`

**Level-Up Events:**
- Modal overlay: "LEVEL UP! You reached Level 5"
- Show newly unlocked equipment/abilities
- Confetti animation + haptic feedback
- Push notification if app is backgrounded

---

### 3. Equipment & Abilities

**Equipment Unlocks by Level:**

| Level | Equipment | Effect | Description |
|-------|-----------|--------|-------------|
| 1 | Starter Pack | None | Basic profile badge |
| 2 | Map View | Visual | See task locations on map |
| 3 | Auto-Accept | Speed | Skip confirmation for trusted posters |
| 4 | Price Negotiation | Economic | Counter-offer on task prices |
| 5 | Task Bundling | Economic | Accept multiple tasks at once |
| 6 | Fast Travel | Speed | Priority routing for <10min tasks |
| 7 | Shield | Protection | Forgive 1 late task per week |
| 8 | Proof Templates | Speed | Save common proof types |
| 9 | Escrow Insight | Economic | See poster's payment history |
| 10 | Trust Badge | Social | "Verified Elite" marker |
| 12 | Instant Payout | Economic | Get paid immediately (no 24h hold) |
| 15 | Ghost Mode | Privacy | Hide online status |
| 18 | VIP Queue | Priority | Jump to front of task lists |
| 20 | Prestige Emblem | Cosmetic | Exclusive gold badge |

**Ability Mechanics:**
- Abilities are ALWAYS ON once unlocked (no activation needed)
- Equipment is shown on profile as badges/icons
- Locked equipment shows as grayed-out with level requirement
- Equipment provides REAL utility, not just cosmetic

---

### 4. Streak System

**Streak Rules:**
- Streak increments by 1 for each consecutive day with ≥1 completed task
- Streak resets to 0 if no tasks completed by midnight (local time)
- **Freeze Tokens:** Earn 1 freeze per week (max 3 stored), use to preserve streak on rest days
- Streak bonus applies to ALL XP earned that day

**Streak Milestones:**
| Streak | Bonus | Reward |
|--------|-------|--------|
| 3 days | +30% XP | Bronze Flame Badge |
| 7 days | +70% XP | Silver Flame Badge + 1 Freeze Token |
| 14 days | +100% XP | Gold Flame Badge + 2 Freeze Tokens |
| 30 days | +100% XP | Diamond Flame Badge + 3 Freeze Tokens |

**Streak UI:**
- Flame icon 🔥 with number next to XP bar
- "Don't lose your streak!" reminder at 8pm if no tasks completed
- Streak calendar view showing completion history

---

### 5. Shadow Reputation System

**Purpose:** Fraud detection and trust calibration without exposing internal metrics.

**Tracked Metrics (Hidden from User):**
- Task acceptance rate (claims vs completions)
- Average task completion time vs estimate
- Proof quality score (rejections, disputes)
- Rating consistency (posters who rate user)
- Geographic consistency (task locations)
- Device fingerprint consistency
- Behavioral patterns (time of day, task types)

**Integrity Score Formula:**
```
integrity_score = (
  completion_rate * 0.3 +
  proof_acceptance_rate * 0.3 +
  rating_average * 0.2 +
  geographic_consistency * 0.1 +
  behavioral_consistency * 0.1
)
```

**Score ranges:**
- 90-100: Trusted (no restrictions)
- 70-89: Normal (standard access)
- 50-69: Monitored (manual review on disputes)
- 30-49: Probation (limited to small tasks <$20)
- 0-29: Shadow banned (invisible to most posters)

**Shadow Ban Mechanics:**
- User sees normal feed but only low-value tasks (<$10)
- User's claims/proofs go to manual review queue
- No notification of shadow ban status
- Can recover by completing small tasks with high quality

**Bulletproofing:**
- All shadow metrics logged to `shadow_reputation_log` table
- Triggers fire on suspicious patterns (e.g., 3 consecutive rejections)
- Admin dashboard shows integrity score distribution
- Weekly ML model retraining on fraud patterns

---

### 6. Trust Tiers

**Visible Trust System (Different from Shadow Rep):**

| Tier | Requirements | Benefits |
|------|--------------|----------|
| Unverified | New account | Limited to $20 tasks |
| Bronze | Level 2 + 5 completed tasks | Access to $50 tasks |
| Silver | Level 5 + 25 completed tasks + 4.5★ | Access to $100 tasks |
| Gold | Level 10 + 100 completed tasks + 4.8★ | Access to $500 tasks |
| Platinum | Level 15 + 500 completed tasks + 4.9★ | Unlimited task access |

**Trust Tier Display:**
- Badge color next to avatar (Bronze/Silver/Gold/Platinum)
- Trust tier shows on profile and in task claims
- Posters can filter Hustlers by minimum trust tier

---

### 7. Live Mode (ASAP Tasks)

**Purpose:** Real-time task dispatching for time-sensitive gigs (coffee runs, package pickups, event help).

**Live Mode Rules:**
- Only available to Level 5+ Hustlers with 4.5★+ rating
- Hustler toggles "Live Mode ON" to receive ASAP tasks
- ASAP tasks require acceptance within 60 seconds
- ASAP tasks pay 1.5x base rate + 50% XP bonus
- Maximum 3 ASAP tasks per day (prevents burnout)

**ASAP Task Flow:**
```
Poster creates ASAP task (needs done in <2 hours)
  ↓
System matches to Live Mode Hustlers within 1 mile
  ↓
Push notification: "ASAP Task: $25 - Coffee run - Accept in 60s"
  ↓
First to accept gets task + bonus XP
  ↓
Countdown timer starts (2 hours to complete)
```

**Live Mode UI:**
- Toggle switch on HustlerHomeScreen: "Live Mode 🔴 ON"
- Shows ETA to nearby ASAP tasks
- Countdown timer when ASAP task active
- "ASAP" badge on task cards (red, pulsing)

---

## DATABASE SCHEMA ADDITIONS

**New Columns in `workers` table:**
```sql
-- XP and Leveling
total_xp INTEGER DEFAULT 0,
current_level INTEGER DEFAULT 0,
xp_to_next_level INTEGER DEFAULT 1000,

-- Streaks
current_streak INTEGER DEFAULT 0,
longest_streak INTEGER DEFAULT 0,
last_task_completed_date DATE,
streak_freeze_tokens INTEGER DEFAULT 0,

-- Equipment (bitfield for unlocked equipment)
unlocked_equipment BIGINT DEFAULT 1,  -- bit 0 = starter pack

-- Shadow Reputation
integrity_score DECIMAL(5,2) DEFAULT 100.00,
shadow_ban_status VARCHAR(20) DEFAULT 'normal',  -- normal, monitored, probation, banned
manual_review_required BOOLEAN DEFAULT FALSE,

-- Live Mode
live_mode_enabled BOOLEAN DEFAULT FALSE,
asap_tasks_today INTEGER DEFAULT 0,
last_asap_task_timestamp TIMESTAMPTZ,
```

**New Table: `xp_transactions`**
```sql
CREATE TABLE xp_transactions (
  xp_transaction_id SERIAL PRIMARY KEY,
  worker_id INTEGER REFERENCES workers(worker_id),
  task_id INTEGER REFERENCES tasks(task_id),
  xp_earned INTEGER NOT NULL,
  xp_multiplier DECIMAL(3,2) DEFAULT 1.0,
  reason VARCHAR(50),  -- base, streak, first_task, speed, quality
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**New Table: `equipment_unlocks`**
```sql
CREATE TABLE equipment_unlocks (
  unlock_id SERIAL PRIMARY KEY,
  worker_id INTEGER REFERENCES workers(worker_id),
  equipment_id INTEGER NOT NULL,  -- references equipment enum
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);
```

**New Table: `streak_history`**
```sql
CREATE TABLE streak_history (
  streak_id SERIAL PRIMARY KEY,
  worker_id INTEGER REFERENCES workers(worker_id),
  streak_date DATE NOT NULL,
  tasks_completed INTEGER DEFAULT 0,
  freeze_used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**New Table: `shadow_reputation_log`**
```sql
CREATE TABLE shadow_reputation_log (
  log_id SERIAL PRIMARY KEY,
  worker_id INTEGER REFERENCES workers(worker_id),
  event_type VARCHAR(50),  -- acceptance_rate_drop, proof_rejected, rating_anomaly
  integrity_score_before DECIMAL(5,2),
  integrity_score_after DECIMAL(5,2),
  trigger_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**New Table: `level_requirements`** (lookup table)
```sql
CREATE TABLE level_requirements (
  level INTEGER PRIMARY KEY,
  xp_required INTEGER NOT NULL,
  equipment_unlocked INTEGER,  -- NULL if no equipment at this level
  title VARCHAR(50)  -- "Novice", "Expert", "Legend"
);
```

---

## API ENDPOINTS

**New tRPC Routes:**

```typescript
// XP and Leveling
gamification.getWorkerStats(worker_id)
  → { total_xp, current_level, streak, equipment, trust_tier }

gamification.awardXP(worker_id, task_id, xp_amount, reason)
  → { new_total_xp, level_up, unlocked_equipment }

gamification.checkLevelUp(worker_id)
  → { leveled_up: boolean, new_level, unlocked_equipment[] }

// Streaks
gamification.getStreakStatus(worker_id)
  → { current_streak, freeze_tokens, streak_bonus }

gamification.useStreakFreeze(worker_id)
  → { success: boolean, freeze_tokens_remaining }

// Equipment
gamification.getUnlockedEquipment(worker_id)
  → { unlocked: Equipment[], locked: Equipment[] }

// Shadow Reputation (admin only)
admin.getIntegrityScore(worker_id)
  → { integrity_score, shadow_ban_status, recent_events[] }

admin.manualReview(worker_id, action: 'approve' | 'ban')
  → { success: boolean }

// Live Mode
gamification.toggleLiveMode(worker_id, enabled: boolean)
  → { live_mode_enabled, asap_tasks_remaining_today }

tasks.createASAPTask(poster_id, task_data)
  → { task_id, nearby_hustlers[], expires_at }
```

---

## FRONTEND INTEGRATION

**Components Affected:**

1. **HustlerHomeScreen** (H1)
   - Add XP bar above task feed
   - Show level, XP progress, streak 🔥
   - "Live Mode" toggle switch

2. **ProfileScreen** (E1)
   - Add equipment showcase grid
   - Show trust tier badge
   - Display streak calendar
   - Level progression timeline

3. **TaskCompletionScreen** (H6)
   - XP earned animation after proof accepted
   - Show multipliers applied (streak, speed, quality)
   - Level-up modal if threshold crossed

4. **SettingsScreen**
   - Toggle for Live Mode notifications
   - Streak freeze token management
   - Equipment preferences (e.g., Auto-Accept settings)

**New Molecules Needed:**
- `XPProgressBar` (shows current level + XP to next)
- `EquipmentCard` (displays equipment with lock/unlock state)
- `StreakFlame` (animated flame icon with count)
- `LevelUpModal` (celebrates level-up with confetti)

---

## VALIDATION RULES

**XP Award Validation:**
```typescript
// Rule: XP can only be awarded for released escrow
if (escrow.status !== 'released') {
  throw new Error('Cannot award XP until escrow released');
}

// Rule: XP award must match escrow amount
const expected_xp = escrow.amount_cents * 0.1; // $1 = 100 XP
if (xp_amount !== expected_xp) {
  throw new Error('XP amount does not match escrow');
}

// Rule: One XP transaction per escrow
if (xp_transactions.some(tx => tx.escrow_id === escrow.escrow_id)) {
  throw new Error('XP already awarded for this escrow');
}
```

**Level-Up Validation:**
```typescript
// Rule: Level cannot skip (must increment by 1)
if (new_level !== current_level + 1) {
  throw new Error('Level must increment sequentially');
}

// Rule: Must have sufficient XP for new level
if (total_xp < level_requirements[new_level].xp_required) {
  throw new Error('Insufficient XP for level-up');
}
```

**Streak Validation:**
```typescript
// Rule: Streak increments only once per day
if (last_streak_date === today) {
  throw new Error('Streak already incremented today');
}

// Rule: Streak resets if >24h gap and no freeze used
if (hours_since_last_task > 24 && freeze_tokens_remaining === 0) {
  current_streak = 0;
}
```

---

## ANTI-FRAUD MEASURES

### 1. XP Gaming Prevention
- XP only awarded for tasks with real payment (no $0.01 spam)
- Speed bonus only applies if task distance ≥ 0.5 miles (prevents fake location claims)
- Quality bonus only counts for ratings from verified posters (Level 2+)

### 2. Shadow Rep Triggers
```sql
-- Trigger 1: Proof rejection rate >30%
CREATE TRIGGER proof_quality_check
AFTER UPDATE ON task_proof
FOR EACH ROW
WHEN (NEW.status = 'rejected')
EXECUTE FUNCTION check_proof_rejection_rate();

-- Trigger 2: Task claim abandonment >50%
CREATE TRIGGER claim_abandonment_check
AFTER UPDATE ON tasks
FOR EACH ROW
WHEN (NEW.status = 'unclaimed' AND OLD.status = 'claimed')
EXECUTE FUNCTION check_claim_abandonment_rate();

-- Trigger 3: Geographic impossibility
CREATE TRIGGER location_consistency_check
AFTER INSERT ON task_proof
FOR EACH ROW
EXECUTE FUNCTION check_location_plausibility();
```

### 3. Equipment Unlock Protection
- Equipment unlocks stored in database (not client-side)
- Equipment effects validated server-side (e.g., Auto-Accept checks worker level)
- Unlocked equipment bitfield prevents manipulation

### 4. Live Mode Abuse Prevention
- ASAP task limit: 3 per day (prevents burnout farming)
- ASAP acceptance timeout: 60 seconds (prevents hoarding)
- ASAP bonus only applies if completed within time limit
- Live Mode disabled if integrity score <70

---

## BUSINESS IMPACT

**Increased Retention:**
- Leveling system gives long-term progression goal
- Daily streak bonus incentivizes regular engagement
- Equipment unlocks provide tangible milestones

**Improved Task Quality:**
- Shadow rep system filters low-quality Hustlers
- Quality bonus encourages good work over speed
- Trust tiers ensure high-value tasks go to reliable workers

**Higher Earnings:**
- XP multipliers reward consistent workers
- Equipment like "Instant Payout" reduces friction
- VIP Queue (Level 18) gives access to premium tasks

**Fraud Reduction:**
- Shadow banning removes bad actors without confrontation
- Integrity score prevents coordinated attacks
- Device fingerprinting catches multi-account abuse

---

## RELATED DOCUMENTS

- **LEVELING_ENGINE_LOCKED.md** — XP calculation and level-up logic
- **SHADOW_REPUTATION_SYSTEM.md** — Fraud detection mechanics
- **LIVE_MODE_SPEC.md** — ASAP task dispatching system
- **TRUST_TIER_RULES.md** — Trust tier progression requirements
- **schema.sql** — Database tables and triggers

---

**Version:** 1.0
**Author:** Claude Sonnet 4.5
**Approved By:** Sebastian Dysart
**Last Updated:** 2026-02-05
