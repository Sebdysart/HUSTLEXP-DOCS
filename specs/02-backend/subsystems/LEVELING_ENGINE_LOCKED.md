# LEVELING ENGINE — XP CALCULATION & LEVEL-UP LOGIC

**STATUS: LOCKED**
**Version:** v1.0
**Last Updated:** 2026-02-05
**Parent System:** GAMIFICATION_SYSTEM.md

---

## PURPOSE

The Leveling Engine is a backend subsystem that:
1. Calculates XP rewards for completed tasks
2. Applies multipliers (streaks, bonuses, equipment)
3. Checks for level-ups and unlocks equipment
4. Maintains XP transaction history for auditing

**Invariant:** XP can ONLY be awarded after escrow is released (see INV-1 in FINISHED_STATE.md).

---

## XP CALCULATION ALGORITHM

### Base XP Formula

```typescript
function calculateBaseXP(escrow_amount_cents: number): number {
  // 100 XP per $1 earned
  return Math.floor(escrow_amount_cents / 100);
}
```

**Examples:**
- $10.00 task = 1,000 XP
- $5.50 task = 550 XP
- $25.00 task = 2,500 XP

---

### Multiplier System

**Order of Operations:**
1. Start with base XP
2. Apply streak bonus (additive)
3. Apply first-task bonus (additive)
4. Apply speed bonus (multiplicative)
5. Apply quality bonus (multiplicative)

```typescript
interface XPMultipliers {
  streak_multiplier: number;      // 1.0 to 2.0
  first_task_bonus: boolean;      // +50% if true
  speed_bonus: boolean;           // +25% if true
  quality_bonus: boolean;         // +50% if true
}

function calculateTotalXP(
  base_xp: number,
  multipliers: XPMultipliers
): number {
  let total = base_xp;

  // Streak bonus (additive)
  total *= multipliers.streak_multiplier;

  // First task bonus (additive)
  if (multipliers.first_task_bonus) {
    total *= 1.5;
  }

  // Speed bonus (multiplicative)
  if (multipliers.speed_bonus) {
    total *= 1.25;
  }

  // Quality bonus (multiplicative)
  if (multipliers.quality_bonus) {
    total *= 1.5;
  }

  return Math.floor(total);
}
```

**Example Calculation:**
```
Task: $10.00 (1,000 base XP)
Streak: 7 days (1.7x)
First task: Yes (+50%)
Speed: Completed in 15min (expected 30min) (+25%)
Quality: 5-star rating (+50%)

total_xp = 1000 * 1.7 * 1.5 * 1.25 * 1.5
total_xp = 4,781 XP
```

---

### Streak Multiplier Calculation

```typescript
function getStreakMultiplier(streak_days: number): number {
  // +10% per consecutive day, max +100%
  const bonus = Math.min(streak_days * 0.1, 1.0);
  return 1.0 + bonus;
}
```

**Streak Table:**
| Days | Multiplier | Bonus |
|------|------------|-------|
| 0 | 1.0x | 0% |
| 1 | 1.1x | +10% |
| 2 | 1.2x | +20% |
| 3 | 1.3x | +30% |
| 7 | 1.7x | +70% |
| 10+ | 2.0x | +100% (capped) |

---

### First Task Bonus

```typescript
async function isFirstTaskToday(
  worker_id: number,
  current_date: Date
): Promise<boolean> {
  const tasks_today = await db.query(`
    SELECT COUNT(*) FROM tasks
    WHERE worker_id = $1
      AND status = 'completed'
      AND DATE(completed_at) = DATE($2)
  `, [worker_id, current_date]);

  return tasks_today[0].count === 0;
}
```

**Rule:** Bonus applies to FIRST completed task each day (midnight to midnight, local time).

---

### Speed Bonus

```typescript
function checkSpeedBonus(
  estimated_duration_minutes: number,
  actual_duration_minutes: number
): boolean {
  // Must complete in <50% of estimated time
  const threshold = estimated_duration_minutes * 0.5;
  return actual_duration_minutes < threshold;
}
```

**Anti-Fraud Rules:**
- Estimated duration must be ≥15 minutes (prevents gaming)
- Task distance must be ≥0.5 miles (prevents fake location)
- Speed bonus disabled if worker has >3 speed bonuses in one day (prevents exploitation)

---

### Quality Bonus

```typescript
function checkQualityBonus(
  rating: number,
  poster_level: number
): boolean {
  // Must be 5-star rating from Level 2+ poster
  return rating === 5.0 && poster_level >= 2;
}
```

**Anti-Fraud Rules:**
- Only verified posters (Level 2+) ratings count
- Repeated 5-star ratings from same poster don't stack (prevents collusion)
- Quality bonus capped at 3 per day

---

## LEVEL-UP SYSTEM

### Level Requirements Table

```typescript
const LEVEL_REQUIREMENTS = [
  { level: 0, xp: 0, title: 'Tutorial', equipment: null },
  { level: 1, xp: 1000, title: 'Novice', equipment: 'STARTER_PACK' },
  { level: 2, xp: 3000, title: 'Apprentice', equipment: 'MAP_VIEW' },
  { level: 3, xp: 6000, title: 'Journeyman', equipment: 'AUTO_ACCEPT' },
  { level: 4, xp: 10000, title: 'Skilled', equipment: 'PRICE_NEGOTIATION' },
  { level: 5, xp: 15000, title: 'Expert', equipment: 'TASK_BUNDLING' },
  { level: 6, xp: 21000, title: 'Master', equipment: 'FAST_TRAVEL' },
  { level: 7, xp: 28000, title: 'Elite', equipment: 'SHIELD' },
  { level: 8, xp: 36000, title: 'Veteran', equipment: 'PROOF_TEMPLATES' },
  { level: 9, xp: 45000, title: 'Champion', equipment: 'ESCROW_INSIGHT' },
  { level: 10, xp: 55000, title: 'Legend', equipment: 'TRUST_BADGE' },
  { level: 11, xp: 67000, title: 'Legend II', equipment: null },
  { level: 12, xp: 79000, title: 'Legend III', equipment: 'INSTANT_PAYOUT' },
  { level: 13, xp: 91000, title: 'Legend IV', equipment: null },
  { level: 14, xp: 103000, title: 'Legend V', equipment: null },
  { level: 15, xp: 115000, title: 'Mythic', equipment: 'GHOST_MODE' },
  // Continues +12k per level...
];
```

**Formula Implementation:**
```typescript
function getXPForLevel(level: number): number {
  if (level === 0) return 0;
  if (level === 1) return 1000;

  if (level <= 10) {
    // Levels 1-10: (level * 1000) + ((level - 1) * level * 500)
    return (level * 1000) + ((level - 1) * level * 500);
  } else {
    // Levels 11+: Previous level + 12,000
    const previousLevelXP = getXPForLevel(level - 1);
    return previousLevelXP + 12000;
  }
}
```

---

### Level-Up Check

```typescript
async function checkLevelUp(worker_id: number): Promise<LevelUpResult> {
  const worker = await db.workers.findOne({ worker_id });
  const { total_xp, current_level } = worker;

  const next_level = current_level + 1;
  const xp_required = getXPForLevel(next_level);

  if (total_xp >= xp_required) {
    // Level up!
    const equipment_unlocked = LEVEL_REQUIREMENTS[next_level].equipment;

    await db.workers.update(
      { worker_id },
      {
        current_level: next_level,
        xp_to_next_level: getXPForLevel(next_level + 1),
        unlocked_equipment: worker.unlocked_equipment | (1 << next_level)
      }
    );

    // Log equipment unlock
    if (equipment_unlocked) {
      await db.equipment_unlocks.insert({
        worker_id,
        equipment_id: next_level,
        unlocked_at: new Date()
      });
    }

    // Check for multiple level-ups (if XP gain was huge)
    return checkLevelUp(worker_id);
  }

  return {
    leveled_up: false,
    current_level,
    xp_to_next_level: xp_required - total_xp
  };
}
```

**Multiple Level-Ups:**
- Possible if worker completes high-value task with many multipliers
- Example: Level 2 worker completes $50 task with 2.0x streak + quality bonus = 15,000 XP (jumps to Level 5)
- Recursively checks level-ups until XP insufficient for next level

---

## XP AWARD FLOW

### 1. Trigger: Escrow Released

```typescript
// In escrow_transactions table trigger
CREATE TRIGGER escrow_released_award_xp
AFTER UPDATE ON escrow_transactions
FOR EACH ROW
WHEN (NEW.status = 'released' AND OLD.status != 'released')
EXECUTE FUNCTION award_xp_for_task();
```

### 2. Calculate XP

```typescript
async function award_xp_for_task(task_id: number): Promise<void> {
  const task = await db.tasks.findOne({ task_id });
  const escrow = await db.escrow_transactions.findOne({ task_id });

  // Base XP
  const base_xp = calculateBaseXP(escrow.amount_cents);

  // Multipliers
  const streak = await getWorkerStreak(task.worker_id);
  const first_task = await isFirstTaskToday(task.worker_id, new Date());
  const speed_bonus = checkSpeedBonus(
    task.estimated_duration,
    task.actual_duration
  );
  const quality_bonus = checkQualityBonus(
    task.rating,
    task.poster_level
  );

  const multipliers: XPMultipliers = {
    streak_multiplier: getStreakMultiplier(streak),
    first_task_bonus: first_task,
    speed_bonus,
    quality_bonus
  };

  // Total XP
  const total_xp = calculateTotalXP(base_xp, multipliers);

  // Award XP
  await awardXP(task.worker_id, task_id, total_xp, multipliers);
}
```

### 3. Update Worker Record

```typescript
async function awardXP(
  worker_id: number,
  task_id: number,
  xp_amount: number,
  multipliers: XPMultipliers
): Promise<void> {
  // Update total XP
  await db.workers.update(
    { worker_id },
    { total_xp: db.raw('total_xp + ??', [xp_amount]) }
  );

  // Log transaction
  await db.xp_transactions.insert({
    worker_id,
    task_id,
    xp_earned: xp_amount,
    xp_multiplier: multipliers.streak_multiplier,
    reason: buildReasonString(multipliers),
    created_at: new Date()
  });

  // Check for level-up
  const levelUpResult = await checkLevelUp(worker_id);

  if (levelUpResult.leveled_up) {
    // Send push notification
    await sendPushNotification(worker_id, {
      title: `LEVEL UP! You reached Level ${levelUpResult.new_level}`,
      body: `New equipment unlocked: ${levelUpResult.equipment}`,
      data: { type: 'level_up', level: levelUpResult.new_level }
    });
  }
}
```

---

## EQUIPMENT UNLOCK MECHANICS

### Equipment Bitfield

Equipment unlocks are stored as a bitfield in `workers.unlocked_equipment`:

```typescript
enum Equipment {
  STARTER_PACK = 1 << 0,     // Bit 0 (always unlocked)
  MAP_VIEW = 1 << 1,         // Bit 1 (Level 2)
  AUTO_ACCEPT = 1 << 2,      // Bit 2 (Level 3)
  PRICE_NEGOTIATION = 1 << 3,
  TASK_BUNDLING = 1 << 4,
  FAST_TRAVEL = 1 << 5,
  SHIELD = 1 << 6,
  PROOF_TEMPLATES = 1 << 7,
  ESCROW_INSIGHT = 1 << 8,
  TRUST_BADGE = 1 << 9,
  INSTANT_PAYOUT = 1 << 11,
  GHOST_MODE = 1 << 14,
  VIP_QUEUE = 1 << 17,
  PRESTIGE_EMBLEM = 1 << 19,
}

function hasEquipment(worker: Worker, equipment: Equipment): boolean {
  return (worker.unlocked_equipment & equipment) !== 0;
}
```

**Example:**
```typescript
// Worker at Level 5 has equipment bits 0-4 set
worker.unlocked_equipment = 0b11111 = 31

// Check if worker has FAST_TRAVEL (bit 5)
hasEquipment(worker, Equipment.FAST_TRAVEL) // false

// Level up to 6, unlock FAST_TRAVEL
worker.unlocked_equipment |= Equipment.FAST_TRAVEL
worker.unlocked_equipment = 0b111111 = 63
```

---

### Equipment Effects Implementation

**Auto-Accept (Level 3):**
```typescript
async function claimTask(worker_id: number, task_id: number) {
  const worker = await db.workers.findOne({ worker_id });

  if (hasEquipment(worker, Equipment.AUTO_ACCEPT)) {
    // Skip confirmation step
    await acceptTaskImmediately(worker_id, task_id);
  } else {
    // Show confirmation modal
    return { needs_confirmation: true };
  }
}
```

**Instant Payout (Level 12):**
```typescript
async function releaseEscrow(escrow_id: number) {
  const escrow = await db.escrow_transactions.findOne({ escrow_id });
  const worker = await db.workers.findOne({ worker_id: escrow.worker_id });

  if (hasEquipment(worker, Equipment.INSTANT_PAYOUT)) {
    // Release immediately (no 24h hold)
    await processEscrowRelease(escrow_id);
  } else {
    // Queue for 24h hold
    await scheduleEscrowRelease(escrow_id, Date.now() + 24 * 60 * 60 * 1000);
  }
}
```

**Shield (Level 7):**
```typescript
async function penalizeLateTask(worker_id: number, task_id: number) {
  const worker = await db.workers.findOne({ worker_id });

  if (hasEquipment(worker, Equipment.SHIELD)) {
    const shields_used_this_week = await countShieldUsage(worker_id);

    if (shields_used_this_week < 1) {
      // Forgive late task
      await logShieldUsage(worker_id, task_id);
      return { penalty_forgiven: true };
    }
  }

  // Apply normal late penalty
  await applyLatePenalty(worker_id, task_id);
}
```

---

## VALIDATION & ANTI-FRAUD

### XP Validation Rules

```typescript
// Rule 1: XP can only be awarded once per task
const existing = await db.xp_transactions.findOne({
  task_id,
  worker_id
});
if (existing) {
  throw new Error('XP already awarded for this task');
}

// Rule 2: XP amount must match escrow
const expected_xp = Math.floor(escrow.amount_cents / 100);
if (base_xp !== expected_xp) {
  throw new Error('XP amount does not match escrow');
}

// Rule 3: Escrow must be released
if (escrow.status !== 'released') {
  throw new Error('Cannot award XP until escrow released');
}
```

### Multiplier Fraud Detection

```typescript
// Speed bonus abuse: >3 speed bonuses per day
const speed_bonuses_today = await db.xp_transactions.count({
  worker_id,
  reason: { $like: '%speed%' },
  created_at: { $gte: startOfDay(new Date()) }
});

if (speed_bonuses_today >= 3) {
  multipliers.speed_bonus = false;
  await logFraudAttempt(worker_id, 'excessive_speed_bonuses');
}

// Quality bonus abuse: Same poster 5-star farming
const recent_quality_bonuses = await db.xp_transactions.findAll({
  worker_id,
  reason: { $like: '%quality%' },
  created_at: { $gte: Date.now() - 7 * 24 * 60 * 60 * 1000 }
});

const poster_counts = countBy(recent_quality_bonuses, 'poster_id');
if (Object.values(poster_counts).some(count => count > 3)) {
  multipliers.quality_bonus = false;
  await logFraudAttempt(worker_id, 'quality_bonus_farming');
}
```

---

## PERFORMANCE OPTIMIZATION

### Caching Strategy

```typescript
// Cache level requirements (rarely changes)
const LEVEL_CACHE = new Map<number, LevelRequirement>();

function getCachedLevelRequirement(level: number): LevelRequirement {
  if (!LEVEL_CACHE.has(level)) {
    LEVEL_CACHE.set(level, LEVEL_REQUIREMENTS[level]);
  }
  return LEVEL_CACHE.get(level)!;
}

// Cache worker XP stats (updated on XP award)
const WORKER_XP_CACHE = new Map<number, WorkerXPStats>();

async function getWorkerXPStats(worker_id: number): Promise<WorkerXPStats> {
  if (!WORKER_XP_CACHE.has(worker_id)) {
    const stats = await db.workers.findOne({ worker_id });
    WORKER_XP_CACHE.set(worker_id, stats);
  }
  return WORKER_XP_CACHE.get(worker_id)!;
}
```

### Database Indexing

```sql
-- Index for XP transaction lookups
CREATE INDEX idx_xp_transactions_worker_date
ON xp_transactions(worker_id, created_at DESC);

-- Index for level-up checks
CREATE INDEX idx_workers_xp
ON workers(total_xp, current_level);

-- Index for equipment unlocks
CREATE INDEX idx_equipment_unlocks_worker
ON equipment_unlocks(worker_id, equipment_id);
```

---

## RELATED DOCUMENTS

- **GAMIFICATION_SYSTEM.md** — Parent specification
- **SHADOW_REPUTATION_SYSTEM.md** — Fraud detection integration
- **FINISHED_STATE.md** — Database invariants (INV-1)
- **schema.sql** — Database tables and triggers

---

**Version:** 1.0
**Author:** Claude Sonnet 4.5
**Last Updated:** 2026-02-05
