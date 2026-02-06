# LIVE MODE — ASAP TASK DISPATCHING SYSTEM

**STATUS: LOCKED**
**Version:** v1.0
**Last Updated:** 2026-02-05
**Parent System:** GAMIFICATION_SYSTEM.md

---

## PURPOSE

Live Mode is a **real-time task dispatching system** for time-sensitive gigs that need to be completed within 1-2 hours (e.g., coffee runs, package pickups, event assistance, emergency errands).

**Core Mechanic:**
- Hustlers toggle "Live Mode ON" to receive ASAP task notifications
- ASAP tasks pay 1.5x base rate + 50% XP bonus
- First to accept within 60 seconds gets the task
- Limited to 3 ASAP tasks per day (prevents burnout)

**Why Live Mode?**
- Creates urgency and FOMO (gamification)
- Rewards highly responsive workers
- Solves real-time poster needs (not everything can wait)
- Prevents task feed spam (only Live Mode users see ASAP tasks)

---

## SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────┐
│                    LIVE MODE FLOW                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Poster creates ASAP task                              │
│        ↓                                                │
│  [Geofence Filter] ──→ Find Hustlers within 1 mile     │
│        ↓                                                │
│  [Live Mode Check] ──→ Only notify Live Mode ON users  │
│        ↓                                                │
│  [Eligibility Filter] ─→ Level 5+, 4.5★+, <3 ASAP today│
│        ↓                                                │
│  [Push Notification] ──→ 60-second acceptance window   │
│        ↓                                                │
│  First to accept gets task + bonuses                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ELIGIBILITY REQUIREMENTS

### Hustler Requirements

```typescript
interface LiveModeEligibility {
  minimum_level: 5;
  minimum_rating: 4.5;
  maximum_asap_tasks_per_day: 3;
  integrity_score_minimum: 70;  // No probation/banned workers
}

async function isEligibleForLiveMode(worker_id: number): Promise<boolean> {
  const worker = await db.workers.findOne({ worker_id });

  // Check level
  if (worker.current_level < 5) {
    return false;
  }

  // Check rating
  if (worker.average_rating < 4.5) {
    return false;
  }

  // Check shadow reputation
  if (worker.integrity_score < 70) {
    return false;
  }

  // Check daily ASAP limit
  const asap_tasks_today = await countASAPTasksToday(worker_id);
  if (asap_tasks_today >= 3) {
    return false;
  }

  return true;
}
```

### Poster Requirements

**ASAP Task Creation:**
- No minimum level (anyone can create ASAP tasks)
- Must pay 1.5x base rate (enforced by system)
- Task deadline must be ≤2 hours from now
- Must provide clear urgency reason (dropdown)

```typescript
enum ASAPUrgencyReason {
  COFFEE_RUN = 'coffee_run',         // "Need coffee for meeting in 1hr"
  PACKAGE_PICKUP = 'package_pickup',  // "Package arriving in 30min"
  EVENT_SETUP = 'event_setup',        // "Event starts in 2hr"
  EMERGENCY_ERRAND = 'emergency',     // "Urgent need"
  LAST_MINUTE_HELP = 'last_minute'    // "Plans changed"
}
```

---

## LIVE MODE TOGGLE

### Frontend UI

**HustlerHomeScreen (H1):**
```tsx
<View style={styles.liveModeBanner}>
  <Icon name="broadcast" color="#EF4444" />
  <Text>Live Mode</Text>
  <Switch
    value={liveModeEnabled}
    onValueChange={handleToggleLiveMode}
    disabled={!isEligibleForLiveMode}
  />
</View>

{/* Show eligibility requirements if disabled */}
{!isEligibleForLiveMode && (
  <Text style={styles.eligibilityHint}>
    Reach Level 5 and 4.5★ to unlock Live Mode
  </Text>
)}
```

**Live Mode ON Visual:**
- Red pulsing dot 🔴 next to "Live Mode ON"
- Notification badge showing ASAP tasks available nearby
- Banner at top: "You're live! Accepting ASAP tasks within 1 mile"

**Live Mode OFF Visual:**
- Gray switch
- No ASAP tasks shown in feed
- Hint: "Turn on Live Mode to receive urgent tasks with bonuses"

---

### Backend Toggle Logic

```typescript
async function toggleLiveMode(
  worker_id: number,
  enabled: boolean
): Promise<LiveModeToggleResult> {
  const worker = await db.workers.findOne({ worker_id });

  // Check eligibility
  if (enabled && !await isEligibleForLiveMode(worker_id)) {
    return {
      success: false,
      reason: 'ineligible',
      requirements: {
        level: worker.current_level >= 5,
        rating: worker.average_rating >= 4.5,
        asap_limit: await countASAPTasksToday(worker_id) < 3,
        integrity: worker.integrity_score >= 70
      }
    };
  }

  // Update worker record
  await db.workers.update(
    { worker_id },
    { live_mode_enabled: enabled }
  );

  // If turning ON, check for nearby ASAP tasks
  if (enabled) {
    const nearby_asap_tasks = await findNearbyASAPTasks(worker_id);
    return {
      success: true,
      live_mode_enabled: true,
      asap_tasks_available: nearby_asap_tasks.length,
      asap_tasks_remaining_today: 3 - await countASAPTasksToday(worker_id)
    };
  }

  return {
    success: true,
    live_mode_enabled: false
  };
}
```

---

## ASAP TASK CREATION

### Poster Flow

**TaskCreationScreen (P2):**
```tsx
<Switch
  label="ASAP Task (needs done within 2 hours)"
  value={isASAPTask}
  onValueChange={setIsASAPTask}
/>

{isASAPTask && (
  <>
    <Picker
      label="Urgency Reason"
      value={urgencyReason}
      onValueChange={setUrgencyReason}
      items={[
        { label: 'Coffee run', value: 'coffee_run' },
        { label: 'Package pickup', value: 'package_pickup' },
        { label: 'Event setup help', value: 'event_setup' },
        { label: 'Emergency errand', value: 'emergency' },
        { label: 'Last-minute help', value: 'last_minute' }
      ]}
    />

    <Text style={styles.asapNotice}>
      ⚡ ASAP tasks pay 1.5x base rate and get priority notifications
    </Text>

    <Text style={styles.priceAdjustment}>
      Base rate: ${baseRate.toFixed(2)} → ASAP rate: ${(baseRate * 1.5).toFixed(2)}
    </Text>
  </>
)}
```

### Backend Creation Logic

```typescript
async function createASAPTask(
  poster_id: number,
  task_data: TaskData
): Promise<ASAPTaskResult> {
  // Validate deadline
  const deadline = new Date(task_data.deadline);
  const now = new Date();
  const hours_until_deadline = (deadline.getTime() - now.getTime()) / (1000 * 60 * 60);

  if (hours_until_deadline > 2) {
    throw new Error('ASAP tasks must have deadline ≤2 hours from now');
  }

  // Enforce 1.5x base rate
  const min_payment = task_data.base_rate * 1.5;
  if (task_data.payment_amount < min_payment) {
    throw new Error(`ASAP tasks require 1.5x payment (minimum $${min_payment.toFixed(2)})`);
  }

  // Create task
  const task = await db.tasks.insert({
    ...task_data,
    is_asap: true,
    urgency_reason: task_data.urgency_reason,
    acceptance_deadline: new Date(now.getTime() + 60 * 1000), // 60 seconds
    created_at: now
  });

  // Find nearby Live Mode Hustlers
  const nearby_hustlers = await findNearbyLiveModeHustlers(
    task.location,
    1.0 // 1 mile radius
  );

  // Send push notifications
  await sendASAPNotifications(task, nearby_hustlers);

  return {
    task_id: task.task_id,
    nearby_hustlers: nearby_hustlers.length,
    acceptance_deadline: task.acceptance_deadline,
    payment_multiplier: 1.5,
    xp_multiplier: 1.5
  };
}
```

---

## GEOFENCE MATCHING

### Find Nearby Live Mode Hustlers

```typescript
async function findNearbyLiveModeHustlers(
  task_location: GeoPoint,
  radius_miles: number
): Promise<Worker[]> {
  // Using PostGIS ST_DWithin for geospatial query
  return db.raw(`
    SELECT w.*
    FROM workers w
    WHERE w.live_mode_enabled = true
      AND w.current_level >= 5
      AND w.average_rating >= 4.5
      AND w.integrity_score >= 70
      AND (
        SELECT COUNT(*)
        FROM tasks t
        WHERE t.worker_id = w.worker_id
          AND t.is_asap = true
          AND DATE(t.claimed_at) = CURRENT_DATE
      ) < 3
      AND ST_DWithin(
        w.last_known_location::geography,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
        $3
      )
    ORDER BY ST_Distance(
      w.last_known_location::geography,
      ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
    )
    LIMIT 50
  `, [task_location.longitude, task_location.latitude, radius_miles * 1609.34]);
}
```

**Privacy Note:**
- Worker location updated only when app is active
- Location NOT tracked when Live Mode OFF
- Location used only for matching, not stored long-term

---

## PUSH NOTIFICATION DISPATCH

### Notification Content

```typescript
interface ASAPNotification {
  title: string;
  body: string;
  data: {
    type: 'asap_task';
    task_id: number;
    payment: number;
    xp_bonus: number;
    distance: number;
    urgency_reason: string;
    acceptance_deadline: Date;
  };
}

async function sendASAPNotifications(
  task: Task,
  hustlers: Worker[]
): Promise<void> {
  for (const hustler of hustlers) {
    const distance_miles = calculateDistance(
      hustler.last_known_location,
      task.location
    );

    await sendPushNotification(hustler.worker_id, {
      title: '⚡ ASAP Task Available',
      body: `$${task.payment.toFixed(2)} - ${task.title} - ${distance_miles.toFixed(1)} mi away`,
      data: {
        type: 'asap_task',
        task_id: task.task_id,
        payment: task.payment,
        xp_bonus: Math.floor(task.payment * 100 * 1.5), // 1.5x XP
        distance: distance_miles,
        urgency_reason: task.urgency_reason,
        acceptance_deadline: task.acceptance_deadline
      },
      sound: 'asap_alert.wav', // Custom urgent sound
      priority: 'high',
      time_sensitive: true
    });
  }
}
```

### Notification Sound

- Custom sound: `asap_alert.wav` (urgent chime)
- iOS: Time-sensitive notification (bypasses Do Not Disturb if allowed)
- Android: High-priority notification (heads-up display)

---

## ACCEPTANCE RACE

### 60-Second Window

**Frontend UI:**
```tsx
<Modal visible={asapTaskModalVisible}>
  <View style={styles.asapModal}>
    <Text style={styles.asapBadge}>⚡ ASAP TASK</Text>
    <Text style={styles.taskTitle}>{task.title}</Text>
    <Text style={styles.payment}>${task.payment.toFixed(2)}</Text>
    <Text style={styles.bonus}>+{task.xp_bonus} XP Bonus</Text>

    {/* Countdown timer */}
    <CountdownTimer
      seconds={remainingSeconds}
      onComplete={() => setAsapTaskModalVisible(false)}
      color="#EF4444"
    />

    <Button
      label="Accept Task"
      onPress={handleAcceptASAPTask}
      loading={accepting}
      variant="primary"
    />

    <Button
      label="Pass"
      onPress={() => setAsapTaskModalVisible(false)}
      variant="text"
    />
  </View>
</Modal>
```

### Backend Acceptance Logic

```typescript
async function acceptASAPTask(
  worker_id: number,
  task_id: number
): Promise<ASAPAcceptanceResult> {
  const task = await db.tasks.findOne({ task_id });

  // Check if still available
  if (task.status !== 'posted') {
    return {
      success: false,
      reason: 'already_claimed',
      message: 'Another Hustler already accepted this task'
    };
  }

  // Check acceptance deadline
  if (new Date() > task.acceptance_deadline) {
    return {
      success: false,
      reason: 'expired',
      message: 'Acceptance window expired'
    };
  }

  // Check daily ASAP limit
  const asap_tasks_today = await countASAPTasksToday(worker_id);
  if (asap_tasks_today >= 3) {
    return {
      success: false,
      reason: 'daily_limit_reached',
      message: 'You\'ve already completed 3 ASAP tasks today'
    };
  }

  // Atomic claim (prevents race condition)
  const claimed = await db.tasks.update(
    {
      task_id,
      status: 'posted'  // Only update if still posted
    },
    {
      status: 'claimed',
      worker_id,
      claimed_at: new Date()
    }
  );

  if (!claimed) {
    return {
      success: false,
      reason: 'race_condition',
      message: 'Another Hustler accepted this task simultaneously'
    };
  }

  // Increment ASAP counter
  await db.workers.update(
    { worker_id },
    { asap_tasks_today: asap_tasks_today + 1 }
  );

  return {
    success: true,
    task,
    payment_multiplier: 1.5,
    xp_multiplier: 1.5,
    asap_tasks_remaining_today: 2 - asap_tasks_today
  };
}
```

---

## TASK COMPLETION & BONUSES

### XP Bonus Calculation

```typescript
async function awardASAPBonuses(task_id: number): Promise<void> {
  const task = await db.tasks.findOne({ task_id });

  // Base XP
  const base_xp = Math.floor(task.payment * 100);

  // ASAP bonus: +50% XP
  const asap_bonus_xp = Math.floor(base_xp * 0.5);

  // Award XP (stacks with other bonuses)
  await awardXP(task.worker_id, task_id, base_xp + asap_bonus_xp, {
    reason: 'asap_task',
    base_xp,
    asap_bonus_xp
  });

  // Award payment (already 1.5x from poster)
  // No additional payment bonus needed
}
```

### Completion Deadline Enforcement

```typescript
// Scheduled job: Check ASAP task deadlines
async function checkASAPDeadlines(): Promise<void> {
  const overdue_tasks = await db.tasks.findAll({
    is_asap: true,
    status: 'claimed',
    deadline: { $lt: new Date() }
  });

  for (const task of overdue_tasks) {
    // Penalize worker (late task)
    await penalizeLateTask(task.worker_id, task.task_id);

    // Refund poster
    await refundEscrow(task.task_id, 'asap_deadline_missed');

    // Notify poster
    await sendPushNotification(task.poster_id, {
      title: 'ASAP Task Not Completed',
      body: `${task.title} was not completed on time. Refund issued.`
    });
  }
}
```

---

## ANTI-ABUSE MEASURES

### Daily Limit (3 ASAP Tasks)

**Reason:** Prevents burnout and hoarding of high-value tasks.

```typescript
async function countASAPTasksToday(worker_id: number): Promise<number> {
  const today_start = new Date();
  today_start.setHours(0, 0, 0, 0);

  return db.tasks.count({
    worker_id,
    is_asap: true,
    claimed_at: { $gte: today_start }
  });
}
```

### Acceptance Timeout (60 seconds)

**Reason:** Prevents Hustlers from hoarding notifications while deciding.

```typescript
// Scheduled job: Cancel expired ASAP tasks
async function cancelExpiredASAPTasks(): Promise<void> {
  const expired = await db.tasks.findAll({
    is_asap: true,
    status: 'posted',
    acceptance_deadline: { $lt: new Date() }
  });

  for (const task of expired) {
    await db.tasks.update(
      { task_id: task.task_id },
      { status: 'expired' }
    );

    // Notify poster
    await sendPushNotification(task.poster_id, {
      title: 'ASAP Task Expired',
      body: 'No Hustlers accepted within 60 seconds. Try posting again.'
    });
  }
}
```

### Geographic Verification

```typescript
async function verifyASAPProof(task_id: number, proof_location: GeoPoint): Promise<void> {
  const task = await db.tasks.findOne({ task_id });

  // Proof location must be within 0.25 miles of task location
  const distance_miles = calculateDistance(task.location, proof_location);

  if (distance_miles > 0.25) {
    await flagShadowEvent(task.worker_id, 'asap_location_mismatch', {
      task_location: task.location,
      proof_location,
      distance_miles
    });

    throw new Error('Proof location too far from task location');
  }
}
```

---

## ANALYTICS & MONITORING

### Admin Dashboard Metrics

```typescript
async function getASAPMetrics(): Promise<ASAPMetrics> {
  const today_start = new Date();
  today_start.setHours(0, 0, 0, 0);

  return {
    // Task metrics
    asap_tasks_created_today: await db.tasks.count({
      is_asap: true,
      created_at: { $gte: today_start }
    }),
    asap_tasks_accepted_today: await db.tasks.count({
      is_asap: true,
      status: { $in: ['claimed', 'in_progress', 'completed'] },
      claimed_at: { $gte: today_start }
    }),
    asap_tasks_expired_today: await db.tasks.count({
      is_asap: true,
      status: 'expired',
      created_at: { $gte: today_start }
    }),

    // Hustler metrics
    live_mode_hustlers_active: await db.workers.count({
      live_mode_enabled: true
    }),
    avg_acceptance_time_seconds: await db.raw(`
      SELECT AVG(EXTRACT(EPOCH FROM (claimed_at - created_at)))
      FROM tasks
      WHERE is_asap = true
        AND status != 'posted'
        AND created_at >= $1
    `, [today_start]).then(r => r[0].avg),

    // Completion metrics
    asap_completion_rate: await calculateCompletionRate('asap'),
    avg_time_to_complete_minutes: await db.raw(`
      SELECT AVG(EXTRACT(EPOCH FROM (completed_at - claimed_at)) / 60)
      FROM tasks
      WHERE is_asap = true
        AND status = 'completed'
        AND completed_at >= $1
    `, [today_start]).then(r => r[0].avg)
  };
}
```

---

## DATABASE SCHEMA ADDITIONS

**New Columns in `tasks` table:**
```sql
is_asap BOOLEAN DEFAULT FALSE,
urgency_reason VARCHAR(50),  -- coffee_run, package_pickup, etc.
acceptance_deadline TIMESTAMPTZ,  -- 60 seconds from creation
asap_payment_multiplier DECIMAL(3,2) DEFAULT 1.50,
asap_xp_multiplier DECIMAL(3,2) DEFAULT 1.50
```

**New Columns in `workers` table:**
```sql
live_mode_enabled BOOLEAN DEFAULT FALSE,
asap_tasks_today INTEGER DEFAULT 0,
last_asap_task_timestamp TIMESTAMPTZ,
last_known_location GEOGRAPHY(POINT, 4326)  -- For geofencing
```

**Indexes:**
```sql
-- Fast geospatial queries
CREATE INDEX idx_workers_live_location
ON workers USING GIST(last_known_location)
WHERE live_mode_enabled = true;

-- Fast ASAP task lookups
CREATE INDEX idx_tasks_asap
ON tasks(is_asap, status, acceptance_deadline)
WHERE is_asap = true;
```

---

## RELATED DOCUMENTS

- **GAMIFICATION_SYSTEM.md** — Parent specification
- **LEVELING_ENGINE_LOCKED.md** — XP bonus calculation
- **SHADOW_REPUTATION_SYSTEM.md** — Eligibility filtering
- **schema.sql** — Database tables

---

**Version:** 1.0
**Author:** Claude Sonnet 4.5
**Last Updated:** 2026-02-05
