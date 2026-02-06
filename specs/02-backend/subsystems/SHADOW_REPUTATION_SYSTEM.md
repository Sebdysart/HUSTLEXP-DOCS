# SHADOW REPUTATION SYSTEM — FRAUD DETECTION & TRUST CALIBRATION

**STATUS: LOCKED**
**Version:** v1.0
**Last Updated:** 2026-02-05
**Parent System:** GAMIFICATION_SYSTEM.md

---

## PURPOSE

The Shadow Reputation System is a **hidden scoring mechanism** that detects fraud, abuse, and low-quality behavior without exposing internal metrics to users.

**Key Principles:**
1. **Invisible:** Users never see their shadow score
2. **Gradual:** Restrictions escalate progressively (probation → shadow ban)
3. **Recoverable:** Good behavior can restore standing
4. **Auditable:** All events logged for review

**Why "Shadow"?**
- Public ratings/reviews are gameable (sock puppets, retaliation)
- Visible restrictions cause user backlash ("I'm being unfairly targeted!")
- Hidden scoring allows system to self-correct without confrontation

---

## INTEGRITY SCORE FORMULA

### Core Metrics

```typescript
interface ShadowMetrics {
  // Primary Factors (70% weight)
  completion_rate: number;          // 0-100% (tasks completed / tasks claimed)
  proof_acceptance_rate: number;    // 0-100% (proofs accepted / proofs submitted)
  rating_average: number;           // 0-5.0 (average poster rating)

  // Secondary Factors (30% weight)
  geographic_consistency: number;   // 0-100% (location pattern believability)
  behavioral_consistency: number;   // 0-100% (time-of-day, task-type patterns)
}
```

### Weighted Formula

```typescript
function calculateIntegrityScore(metrics: ShadowMetrics): number {
  const score = (
    metrics.completion_rate * 0.3 +
    metrics.proof_acceptance_rate * 0.3 +
    (metrics.rating_average / 5.0) * 100 * 0.2 +
    metrics.geographic_consistency * 0.1 +
    metrics.behavioral_consistency * 0.1
  );

  return Math.max(0, Math.min(100, score));
}
```

**Example Calculations:**

**Good Worker:**
```
completion_rate: 95%
proof_acceptance_rate: 98%
rating_average: 4.8 (96%)
geographic_consistency: 90%
behavioral_consistency: 85%

score = (95 * 0.3) + (98 * 0.3) + (96 * 0.2) + (90 * 0.1) + (85 * 0.1)
score = 28.5 + 29.4 + 19.2 + 9.0 + 8.5
score = 94.6 ✅ TRUSTED
```

**Suspicious Worker:**
```
completion_rate: 60%
proof_acceptance_rate: 70%
rating_average: 3.2 (64%)
geographic_consistency: 40%
behavioral_consistency: 50%

score = (60 * 0.3) + (70 * 0.3) + (64 * 0.2) + (40 * 0.1) + (50 * 0.1)
score = 18.0 + 21.0 + 12.8 + 4.0 + 5.0
score = 60.8 ⚠️ MONITORED
```

---

## INTEGRITY SCORE TIERS

### Score Ranges & Restrictions

| Score | Status | Restrictions | Recovery Path |
|-------|--------|--------------|---------------|
| 90-100 | **TRUSTED** | None | Maintain good behavior |
| 70-89 | **NORMAL** | None | Standard access |
| 50-69 | **MONITORED** | Manual review on disputes | Complete 10 tasks with 4.5★+ |
| 30-49 | **PROBATION** | Limited to tasks <$20 | Complete 20 small tasks with 5★ |
| 0-29 | **SHADOW BANNED** | Only see low-value tasks (<$10) | 50 tasks with perfect record |

### Status Effects Implementation

```typescript
async function getTaskFeed(worker_id: number): Promise<Task[]> {
  const worker = await db.workers.findOne({ worker_id });
  const { integrity_score, shadow_ban_status } = worker;

  let max_task_value = Infinity;

  if (shadow_ban_status === 'probation') {
    max_task_value = 20.00;
  } else if (shadow_ban_status === 'banned') {
    max_task_value = 10.00;
  }

  return db.tasks.findAll({
    status: 'posted',
    payment_amount: { $lte: max_task_value },
    // Worker sees "normal" feed but filtered by max_task_value
  });
}

async function submitProof(worker_id: number, task_id: number) {
  const worker = await db.workers.findOne({ worker_id });

  if (worker.shadow_ban_status === 'monitored' ||
      worker.shadow_ban_status === 'probation') {
    // Send to manual review queue
    return { status: 'pending_review', estimated_review_time: '2-4 hours' };
  }

  // Normal proof submission flow
  return { status: 'submitted' };
}
```

---

## FRAUD DETECTION TRIGGERS

### 1. Completion Rate Drop

**Detection:**
```typescript
async function checkCompletionRate(worker_id: number): Promise<void> {
  const last_30_tasks = await db.tasks.findAll({
    worker_id,
    status: { $in: ['completed', 'unclaimed'] },
    claimed_at: { $gte: Date.now() - 30 * 24 * 60 * 60 * 1000 }
  });

  const completed = last_30_tasks.filter(t => t.status === 'completed').length;
  const claimed = last_30_tasks.length;
  const completion_rate = (completed / claimed) * 100;

  if (completion_rate < 60 && claimed >= 10) {
    await flagShadowEvent(worker_id, 'low_completion_rate', {
      completion_rate,
      tasks_claimed: claimed,
      tasks_completed: completed
    });
  }
}
```

**Trigger:**
```sql
CREATE TRIGGER task_unclaimed_check
AFTER UPDATE ON tasks
FOR EACH ROW
WHEN (NEW.status = 'unclaimed' AND OLD.status = 'claimed')
EXECUTE FUNCTION check_completion_rate();
```

---

### 2. Proof Rejection Pattern

**Detection:**
```typescript
async function checkProofQuality(worker_id: number): Promise<void> {
  const recent_proofs = await db.task_proof.findAll({
    worker_id,
    created_at: { $gte: Date.now() - 14 * 24 * 60 * 60 * 1000 }
  });

  const rejected = recent_proofs.filter(p => p.status === 'rejected').length;
  const total = recent_proofs.length;
  const rejection_rate = (rejected / total) * 100;

  // 3+ consecutive rejections = immediate flag
  const consecutive_rejections = countConsecutiveRejections(recent_proofs);

  if (rejection_rate > 30 || consecutive_rejections >= 3) {
    await flagShadowEvent(worker_id, 'high_proof_rejection_rate', {
      rejection_rate,
      consecutive_rejections,
      total_proofs: total
    });
  }
}
```

**Trigger:**
```sql
CREATE TRIGGER proof_rejected_check
AFTER UPDATE ON task_proof
FOR EACH ROW
WHEN (NEW.status = 'rejected' AND OLD.status != 'rejected')
EXECUTE FUNCTION check_proof_quality();
```

---

### 3. Geographic Impossibility

**Detection:**
```typescript
async function checkLocationPlausibility(
  worker_id: number,
  task_id: number,
  proof_location: GeoPoint
): Promise<void> {
  const previous_task = await db.tasks.findOne({
    worker_id,
    completed_at: { $lte: Date.now() }
  }, {
    order: [['completed_at', 'DESC']],
    limit: 1
  });

  if (previous_task) {
    const distance_km = calculateDistance(
      previous_task.completion_location,
      proof_location
    );
    const time_diff_minutes = (Date.now() - previous_task.completed_at) / 60000;
    const speed_kmh = (distance_km / time_diff_minutes) * 60;

    // Flag if speed >80 km/h (impossible for walking/biking tasks)
    if (speed_kmh > 80 && distance_km > 5) {
      await flagShadowEvent(worker_id, 'geographic_impossibility', {
        distance_km,
        time_diff_minutes,
        speed_kmh,
        previous_task_id: previous_task.task_id,
        current_task_id: task_id
      });
    }
  }
}
```

**Trigger:**
```sql
CREATE TRIGGER location_check
AFTER INSERT ON task_proof
FOR EACH ROW
EXECUTE FUNCTION check_location_plausibility();
```

---

### 4. Rating Anomaly Detection

**Detection:**
```typescript
async function checkRatingAnomaly(worker_id: number): Promise<void> {
  const recent_ratings = await db.tasks.findAll({
    worker_id,
    rating: { $ne: null },
    completed_at: { $gte: Date.now() - 30 * 24 * 60 * 60 * 1000 }
  });

  // Check for rating farming (same poster repeatedly giving 5 stars)
  const poster_rating_counts = groupBy(recent_ratings, 'poster_id');

  for (const [poster_id, ratings] of Object.entries(poster_rating_counts)) {
    const five_star_count = ratings.filter(r => r.rating === 5).length;

    if (five_star_count >= 5 && ratings.length === five_star_count) {
      // Same poster gave 5+ consecutive 5-star ratings
      await flagShadowEvent(worker_id, 'rating_farming', {
        poster_id,
        consecutive_five_stars: five_star_count
      });
    }
  }

  // Check for sudden rating drop (potential retaliation)
  const avg_last_10 = average(recent_ratings.slice(0, 10).map(r => r.rating));
  const avg_previous_20 = average(recent_ratings.slice(10, 30).map(r => r.rating));

  if (avg_previous_20 - avg_last_10 > 1.5) {
    await flagShadowEvent(worker_id, 'sudden_rating_drop', {
      previous_avg: avg_previous_20,
      recent_avg: avg_last_10,
      drop: avg_previous_20 - avg_last_10
    });
  }
}
```

---

### 5. Behavioral Consistency

**Detection:**
```typescript
async function checkBehavioralConsistency(worker_id: number): Promise<void> {
  const task_history = await db.tasks.findAll({
    worker_id,
    status: 'completed',
    completed_at: { $gte: Date.now() - 60 * 24 * 60 * 60 * 1000 }
  });

  // Check time-of-day pattern
  const hours = task_history.map(t => new Date(t.completed_at).getHours());
  const hour_distribution = countBy(hours);

  // If all tasks completed in exact same 2-hour window = bot behavior
  const unique_hours = Object.keys(hour_distribution).length;
  if (unique_hours <= 2 && task_history.length > 20) {
    await flagShadowEvent(worker_id, 'rigid_time_pattern', {
      unique_hours,
      total_tasks: task_history.length,
      primary_hours: Object.keys(hour_distribution)
    });
  }

  // Check task type diversity
  const task_types = task_history.map(t => t.category);
  const unique_types = new Set(task_types).size;

  // Only ever doing one task type = potential collusion
  if (unique_types === 1 && task_history.length > 15) {
    await flagShadowEvent(worker_id, 'no_task_diversity', {
      task_type: task_types[0],
      task_count: task_history.length
    });
  }
}
```

---

## SHADOW BAN ESCALATION

### Progressive Restriction Flow

```typescript
async function updateShadowStatus(worker_id: number): Promise<void> {
  const worker = await db.workers.findOne({ worker_id });
  const integrity_score = await recalculateIntegrityScore(worker_id);

  let new_status: ShadowStatus;

  if (integrity_score >= 90) {
    new_status = 'trusted';
  } else if (integrity_score >= 70) {
    new_status = 'normal';
  } else if (integrity_score >= 50) {
    new_status = 'monitored';
  } else if (integrity_score >= 30) {
    new_status = 'probation';
  } else {
    new_status = 'banned';
  }

  // Only escalate if status worsened
  const status_hierarchy = ['trusted', 'normal', 'monitored', 'probation', 'banned'];
  const current_index = status_hierarchy.indexOf(worker.shadow_ban_status);
  const new_index = status_hierarchy.indexOf(new_status);

  if (new_index > current_index) {
    await db.workers.update(
      { worker_id },
      {
        shadow_ban_status: new_status,
        integrity_score,
        last_shadow_update: new Date()
      }
    );

    await logShadowEvent(worker_id, 'status_escalation', {
      old_status: worker.shadow_ban_status,
      new_status,
      integrity_score
    });
  } else if (new_index < current_index) {
    // De-escalate (recovery)
    await db.workers.update(
      { worker_id },
      {
        shadow_ban_status: new_status,
        integrity_score
      }
    );

    await logShadowEvent(worker_id, 'status_recovery', {
      old_status: worker.shadow_ban_status,
      new_status,
      integrity_score
    });
  }
}
```

### Escalation Events

```typescript
async function flagShadowEvent(
  worker_id: number,
  event_type: string,
  details: object
): Promise<void> {
  const worker = await db.workers.findOne({ worker_id });
  const old_score = worker.integrity_score;

  // Recalculate integrity score
  const new_score = await recalculateIntegrityScore(worker_id);

  // Log event
  await db.shadow_reputation_log.insert({
    worker_id,
    event_type,
    integrity_score_before: old_score,
    integrity_score_after: new_score,
    trigger_reason: JSON.stringify(details),
    created_at: new Date()
  });

  // Update status if needed
  await updateShadowStatus(worker_id);

  // Alert admin if score drops >20 points
  if (old_score - new_score > 20) {
    await alertAdmin({
      type: 'integrity_score_drop',
      worker_id,
      old_score,
      new_score,
      event_type,
      details
    });
  }
}
```

---

## RECOVERY MECHANISMS

### Automatic Recovery

```typescript
async function checkRecoveryEligibility(worker_id: number): Promise<void> {
  const worker = await db.workers.findOne({ worker_id });

  if (worker.shadow_ban_status === 'probation') {
    // Recovery: 20 consecutive small tasks with 5★
    const recent_tasks = await db.tasks.findAll({
      worker_id,
      status: 'completed',
      payment_amount: { $lte: 20.00 },
      rating: { $gte: 5.0 },
      completed_at: { $gte: Date.now() - 30 * 24 * 60 * 60 * 1000 }
    }, {
      order: [['completed_at', 'DESC']],
      limit: 20
    });

    if (recent_tasks.length === 20) {
      await updateShadowStatus(worker_id); // Will recalculate and likely promote to MONITORED
    }
  }

  if (worker.shadow_ban_status === 'banned') {
    // Recovery: 50 consecutive tasks with perfect record
    const recent_tasks = await db.tasks.findAll({
      worker_id,
      status: 'completed',
      rating: { $gte: 5.0 },
      completed_at: { $gte: Date.now() - 60 * 24 * 60 * 60 * 1000 }
    }, {
      order: [['completed_at', 'DESC']],
      limit: 50
    });

    if (recent_tasks.length === 50 &&
        recent_tasks.every(t => t.status === 'completed' && t.rating === 5)) {
      await updateShadowStatus(worker_id); // Will recalculate and promote
    }
  }
}
```

### Manual Review Queue

```typescript
async function getManualReviewQueue(): Promise<Task[]> {
  return db.tasks.findAll({
    proof_status: 'pending_review',
    worker_shadow_status: { $in: ['monitored', 'probation'] }
  }, {
    order: [['created_at', 'ASC']]
  });
}

async function adminReviewProof(
  admin_id: number,
  task_id: number,
  decision: 'approve' | 'reject',
  notes: string
): Promise<void> {
  await db.task_proof.update(
    { task_id },
    {
      status: decision === 'approve' ? 'accepted' : 'rejected',
      reviewed_by: admin_id,
      review_notes: notes,
      reviewed_at: new Date()
    }
  );

  // Impact integrity score
  const task = await db.tasks.findOne({ task_id });
  if (decision === 'approve') {
    // Boost integrity score slightly
    await adjustIntegrityScore(task.worker_id, +2);
  } else {
    // Further penalize
    await adjustIntegrityScore(task.worker_id, -5);
  }
}
```

---

## ADMIN DASHBOARD QUERIES

### Get Workers by Shadow Status

```typescript
async function getWorkersByShadowStatus(
  status: ShadowStatus
): Promise<Worker[]> {
  return db.workers.findAll({
    shadow_ban_status: status
  }, {
    order: [['integrity_score', 'ASC']]
  });
}
```

### Integrity Score Distribution

```typescript
async function getIntegrityScoreDistribution(): Promise<object> {
  const workers = await db.workers.findAll();

  return {
    trusted: workers.filter(w => w.integrity_score >= 90).length,
    normal: workers.filter(w => w.integrity_score >= 70 && w.integrity_score < 90).length,
    monitored: workers.filter(w => w.integrity_score >= 50 && w.integrity_score < 70).length,
    probation: workers.filter(w => w.integrity_score >= 30 && w.integrity_score < 50).length,
    banned: workers.filter(w => w.integrity_score < 30).length
  };
}
```

### Shadow Event History

```typescript
async function getShadowEventHistory(
  worker_id: number,
  limit: number = 50
): Promise<ShadowEvent[]> {
  return db.shadow_reputation_log.findAll({
    worker_id
  }, {
    order: [['created_at', 'DESC']],
    limit
  });
}
```

---

## MACHINE LEARNING ENHANCEMENTS (FUTURE)

### Fraud Pattern Detection

```typescript
interface FraudPattern {
  pattern_id: string;
  description: string;
  indicators: string[];
  confidence: number;
}

// Weekly ML model retraining on fraud patterns
async function retrainFraudModel(): Promise<void> {
  const banned_workers = await db.workers.findAll({
    shadow_ban_status: 'banned'
  });

  const features = await extractFraudFeatures(banned_workers);
  const model = await trainLogisticRegression(features);

  await saveModel('fraud_detection_v2', model);
}

// Apply ML model to new workers
async function predictFraudRisk(worker_id: number): Promise<number> {
  const features = await extractWorkerFeatures(worker_id);
  const model = await loadModel('fraud_detection_v2');

  return model.predict(features); // 0-1 fraud probability
}
```

---

## PRIVACY & COMPLIANCE

### User Data Access

**User can request:**
- ✅ Public rating history (visible ratings from posters)
- ✅ Task completion statistics
- ✅ XP/level progression

**User CANNOT request:**
- ❌ Shadow integrity score
- ❌ Shadow ban status
- ❌ Fraud detection events
- ❌ Internal fraud flags

**Reason:** Shadow reputation is a **security measure**, not personal data subject to disclosure. Similar to spam filtering, credit card fraud detection.

### GDPR Compliance

```typescript
// On account deletion request
async function deleteWorkerData(worker_id: number): Promise<void> {
  // Anonymize shadow reputation log (keep for fraud research)
  await db.shadow_reputation_log.update(
    { worker_id },
    { worker_id: null, anonymized: true }
  );

  // Delete worker record (cascade to other tables)
  await db.workers.delete({ worker_id });
}
```

---

## RELATED DOCUMENTS

- **GAMIFICATION_SYSTEM.md** — Parent specification
- **LEVELING_ENGINE_LOCKED.md** — XP award integration
- **FINISHED_STATE.md** — Database invariants
- **schema.sql** — Shadow reputation tables

---

**Version:** 1.0
**Author:** Claude Sonnet 4.5
**Last Updated:** 2026-02-05
