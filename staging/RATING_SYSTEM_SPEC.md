# Bidirectional Rating System Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Mutual rating system for both workers and posters after task completion

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Ratings are mutual, mandatory, and immutable.**

Both worker and poster rate each other after task completion. Ratings cannot be changed. This builds trust, accountability, and quality on both sides.

**What This Unlocks:**
- Quality filtering (posters see worker ratings, workers see poster ratings)
- Trust building (ratings inform trust tier calculations)
- Accountability (both sides responsible for quality)
- Dispute prevention (ratings encourage good behavior)

---

## §1. Rating Flow

### 1.1 Rating Trigger

**Ratings are required after task COMPLETED:**

1. Task reaches COMPLETED state (proof approved, payment released)
2. Both parties receive notification: "Rate your experience"
3. Rating window: 7 days after completion
4. If not rated within 7 days: Auto-rating (5 stars, no comment)
5. Ratings are **blind** until both parties submit (or 7 days expire)

---

### 1.2 Rating Components

**Each rating includes:**

| Component | Type | Required | Purpose |
|-----------|------|----------|---------|
| **Star Rating** | 1-5 stars | ✅ Yes | Quantitative measure |
| **Comment** | Text (max 500 chars) | ❌ Optional | Qualitative feedback |
| **Tags** | Multi-select | ❌ Optional | Categorize feedback |

---

## §2. Star Rating System

### 2.1 Rating Scale

```
⭐⭐⭐⭐⭐ 5 stars = Excellent (exceeded expectations)
⭐⭐⭐⭐  4 stars = Good (met expectations)
⭐⭐⭐    3 stars = Satisfactory (acceptable)
⭐⭐      2 stars = Poor (below expectations)
⭐        1 star = Very Poor (serious issues)
```

### 2.2 Rating Meaning

| Stars | Meaning | When to Use |
|-------|---------|-------------|
| **5** | Excellent | Work exceeded expectations, would work with again |
| **4** | Good | Work met expectations, minor improvements possible |
| **3** | Satisfactory | Work acceptable, some issues but completed |
| **2** | Poor | Work below expectations, significant issues |
| **1** | Very Poor | Work unacceptable, major problems, would not work with again |

**Guidelines displayed to users:**
- "Be honest and fair. Ratings help build trust for everyone."
- "Consider: quality of work, communication, punctuality, professionalism."

---

## §3. Rating Tags (Optional)

### 3.1 Worker Rating Tags (Poster Rates Worker)

| Tag | Description |
|-----|-------------|
| **On Time** | Worker arrived on time or early |
| **Professional** | Worker was courteous and professional |
| **High Quality** | Work quality exceeded expectations |
| **Good Communication** | Worker communicated clearly and promptly |
| **Would Hire Again** | Would work with this worker again |
| **Clean Work** | Work area left clean |
| **Problem Solver** | Worker handled unexpected issues well |

**Negative Tags (if rating < 4):**
- **Late Arrival** | Worker was late
- **Poor Communication** | Worker didn't respond promptly
- **Quality Issues** | Work quality was below expectations
- **Unprofessional** | Worker was rude or unprofessional

---

### 3.2 Poster Rating Tags (Worker Rates Poster)

| Tag | Description |
|-----|-------------|
| **Clear Instructions** | Poster provided clear task instructions |
| **Fair Payment** | Payment was fair for work required |
| **Responsive** | Poster responded quickly to messages |
| **Friendly** | Poster was courteous and friendly |
| **Would Work Again** | Would accept tasks from this poster again |
| **Respectful** | Poster respected worker's time and effort |

**Negative Tags (if rating < 4):**
- **Unclear Instructions** | Task description was vague
- **Unresponsive** | Poster didn't respond to messages
- **Unfair Payment** | Payment too low for work required
- **Rude** | Poster was disrespectful

---

## §4. Rating Schema

### 4.1 Database Schema

```sql
CREATE TABLE task_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  task_id UUID NOT NULL REFERENCES tasks(id),
  rater_id UUID NOT NULL REFERENCES users(id),  -- Who gave the rating
  ratee_id UUID NOT NULL REFERENCES users(id),  -- Who received the rating
  
  -- Rating content
  stars INTEGER NOT NULL CHECK (stars >= 1 AND stars <= 5),
  comment TEXT,  -- Max 500 chars, optional
  tags TEXT[],   -- Array of tag strings
  
  -- Status
  is_public BOOLEAN DEFAULT true,  -- Visible to ratee (after both submitted)
  is_blind BOOLEAN DEFAULT true,   -- Hidden until both parties rate
  
  -- Auto-rating flag
  is_auto_rated BOOLEAN DEFAULT false,  -- True if auto-rated after 7 days
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- Constraints
  UNIQUE(task_id, rater_id, ratee_id),  -- One rating per pair per task
  CHECK (
    (comment IS NULL OR LENGTH(comment) <= 500)
  )
);

CREATE INDEX idx_ratings_ratee ON task_ratings(ratee_id, created_at DESC);
CREATE INDEX idx_ratings_task ON task_ratings(task_id);
CREATE INDEX idx_ratings_public ON task_ratings(ratee_id, is_public) WHERE is_public = true;

-- View for aggregated ratings
CREATE VIEW user_rating_summary AS
SELECT 
  ratee_id AS user_id,
  COUNT(*) AS total_ratings,
  AVG(stars)::DECIMAL(3,2) AS avg_rating,
  COUNT(*) FILTER (WHERE stars = 5) AS five_star_count,
  COUNT(*) FILTER (WHERE stars = 4) AS four_star_count,
  COUNT(*) FILTER (WHERE stars = 3) AS three_star_count,
  COUNT(*) FILTER (WHERE stars = 2) AS two_star_count,
  COUNT(*) FILTER (WHERE stars = 1) AS one_star_count,
  COUNT(*) FILTER (WHERE comment IS NOT NULL) AS commented_count,
  MAX(created_at) AS last_rating_at
FROM task_ratings
WHERE is_public = true
GROUP BY ratee_id;
```

---

## §5. Rating Display Rules

### 5.1 Profile Display

**Worker Profile (visible to posters):**
```
Sarah K. (VERIFIED)
⭐⭐⭐⭐⭐ 4.8 (127 ratings)

Recent feedback:
• "On time, professional, high quality work" - John D. (5 stars)
• "Great communication, would hire again" - Jane S. (5 stars)
• "Good work, minor cleanup needed" - Mike T. (4 stars)
```

**Poster Profile (visible to workers):**
```
John D. (VERIFIED)
⭐⭐⭐⭐ 4.5 (45 ratings)

Recent feedback:
• "Clear instructions, fair payment, responsive" - Sarah K. (5 stars)
• "Friendly poster, would work again" - Alex M. (4 stars)
• "Unclear task description, but paid fairly" - Lisa P. (3 stars)
```

---

### 5.2 Rating Visibility Rules

| Visibility | Who Can See | When |
|------------|-------------|------|
| **Private (Blind)** | Only system | Until both parties rate (or 7 days expire) |
| **Public** | Ratee, other users | After both parties rate (or 7 days expire) |
| **Profile Aggregates** | All users | Always visible (aggregated stats) |
| **Individual Ratings** | Ratee only | After both parties rate |
| **Rating Details** | Ratee + admins | Always (for dispute resolution) |

**Privacy Protection:**
- Rater identity is visible to ratee (accountability)
- Ratings cannot be edited or deleted
- Only ratee can see individual rating details

---

## §6. Rating Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **RATE-1** | Rating only allowed after task COMPLETED | Backend validation |
| **RATE-2** | Rating window: 7 days after completion | Backend validation |
| **RATE-3** | Both parties must rate (or auto-rated after 7 days) | Backend logic |
| **RATE-4** | Ratings are immutable (cannot edit/delete) | DB constraint + backend validation |
| **RATE-5** | One rating per pair per task | DB UNIQUE constraint |
| **RATE-6** | Stars must be 1-5 | DB CHECK constraint |
| **RATE-7** | Comment max 500 characters | DB CHECK constraint |
| **RATE-8** | Ratings are blind until both parties rate | Backend logic |

---

## §7. Auto-Rating System

### 7.1 Auto-Rating Rules

**After 7 days, if party hasn't rated:**

1. System auto-rates: **5 stars** (default)
2. Comment: "No rating submitted (auto-rated)"
3. Tags: None
4. `is_auto_rated = true`

**Rationale:**
- Prevents rating manipulation (waiting to see other party's rating)
- Ensures all tasks have ratings (for trust tier calculations)
- Defaults to positive (assumes good experience if no complaint)

**Notification:**
```
"Your rating period expired. Task auto-rated as 5 stars."
```

---

### 7.2 Auto-Rating Job

**Background job runs daily:**

```typescript
async function processAutoRatings() {
  const sql = getSql();
  
  // Find tasks completed 7+ days ago without ratings
  const incompleteRatings = await sql`
    SELECT 
      t.id AS task_id,
      t.poster_id,
      t.assigned_to AS worker_id,
      t.completed_at
    FROM tasks t
    WHERE t.status = 'completed'
      AND t.completed_at < NOW() - INTERVAL '7 days'
      AND NOT EXISTS (
        SELECT 1 FROM task_ratings r1
        WHERE r1.task_id = t.id AND r1.rater_id = t.poster_id
      )
      AND NOT EXISTS (
        SELECT 1 FROM task_ratings r2
        WHERE r2.task_id = t.id AND r2.rater_id = t.assigned_to
      )
  `;
  
  for (const task of incompleteRatings) {
    // Auto-rate poster → worker
    await createRating({
      taskId: task.task_id,
      raterId: task.poster_id,
      rateeId: task.worker_id,
      stars: 5,
      comment: "No rating submitted (auto-rated)",
      isAutoRated: true
    });
    
    // Auto-rate worker → poster
    await createRating({
      taskId: task.task_id,
      raterId: task.worker_id,
      rateeId: task.poster_id,
      stars: 5,
      comment: "No rating submitted (auto-rated)",
      isAutoRated: true
    });
  }
}
```

---

## §8. Rating Integration with Trust Tier

### 8.1 Trust Tier Calculation

**From PRODUCT_SPEC §4.1, Tier 4 (ELITE) requires:**
- 100+ completed tasks
- <1% dispute rate
- **4.8+ average rating** ← Rating integration

**Trust tier service uses rating_summary view:**
```typescript
const avgRating = await sql`
  SELECT avg_rating FROM user_rating_summary
  WHERE user_id = ${userId}
`;

if (avgRating >= 4.8 && completedTasks >= 100 && disputeRate < 0.01) {
  eligibleTier = TRUST_TIERS.ELITE;
}
```

---

## §9. API Endpoints

```typescript
// tRPC router: ratings
ratings.submitRating({
  input: {
    taskId: string;
    stars: 1 | 2 | 3 | 4 | 5;
    comment?: string;  // Max 500 chars
    tags?: string[];   // Array of tag strings
  },
  output: {
    ratingId: string;
    status: 'submitted' | 'pending_other_party';
    willBePublic: boolean;  // True if other party already rated
  }
});

ratings.getMyRatings({
  input: {
    limit?: number;  // Default: 50
    offset?: number;  // Default: 0
    taskId?: string;  // Filter by task
  },
  output: {
    ratings: Rating[];  // Ratings I gave
    received: Rating[];  // Ratings I received
  }
});

ratings.getUserRatings({
  input: {
    userId: string;  // Other user's ID
  },
  output: {
    summary: {
      totalRatings: number;
      avgRating: number;
      starDistribution: { [key: number]: number };  // {5: 100, 4: 20, ...}
    };
    recentRatings: Rating[];  // Last 10 public ratings
  }
});

ratings.getTaskRatings({
  input: {
    taskId: string;
  },
  output: {
    posterRating?: Rating;  // Poster's rating of worker (if public)
    workerRating?: Rating;  // Worker's rating of poster (if public)
    bothRated: boolean;  // True if both parties rated
  }
});
```

---

## §10. UI Requirements

### 10.1 Rating Modal (After Task Completion)

```
┌─────────────────────────────────────────────────────────┐
│  Rate Your Experience                                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Task: Deep cleaning                                    │
│  Worker: Sarah K.                                       │
│                                                         │
│  How was your experience?                               │
│  ⭐⭐⭐⭐⭐ (tap to select)                                │
│                                                         │
│  [Optional] Add a comment:                              │
│  ┌─────────────────────────────────────────────────────┐│
│  │ Great work! Sarah was on time and...               ││
│  │ (max 500 characters)                                ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
│  [Optional] Select tags:                                │
│  ☑ On Time  ☑ Professional  ☐ High Quality            │
│  ☐ Good Communication  ☑ Would Hire Again              │
│                                                         │
│  [ Submit Rating ]                                      │
│                                                         │
│  ℹ️ Your rating will be visible after both parties rate.│
└─────────────────────────────────────────────────────────┘
```

### 10.2 Rating Display on Profile

```
┌─────────────────────────────────────────────────────────┐
│  Sarah K. (VERIFIED)                                    │
│  ⭐⭐⭐⭐⭐ 4.8 (127 ratings)                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Recent Feedback:                                       │
│                                                         │
│  ⭐⭐⭐⭐⭐ "On time, professional, high quality work"     │
│     - John D. • 2 days ago                              │
│     Tags: On Time, Professional, Would Hire Again      │
│                                                         │
│  ⭐⭐⭐⭐⭐ "Great communication, would hire again"        │
│     - Jane S. • 5 days ago                              │
│     Tags: Good Communication, Would Hire Again         │
│                                                         │
│  ⭐⭐⭐⭐ "Good work, minor cleanup needed"                │
│     - Mike T. • 1 week ago                              │
│     Tags: High Quality                                  │
│                                                         │
│  [ View All Ratings ]                                   │
└─────────────────────────────────────────────────────────┘
```

---

## §11. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Rating completion rate** | >80% | Ratings submitted / Tasks completed |
| **Average rating** | >4.5 | Mean of all ratings |
| **Rating distribution** | Skewed high | 70%+ 5-star, <5% 1-2 star |
| **Comment rate** | >40% | Ratings with comments / Total ratings |
| **Auto-rating rate** | <20% | Auto-rated / Total ratings |
| **Rating submission time** | <2 days | Median time to submit rating |

---

## §12. Constitutional Alignment

### 12.1 Authority Model

- **Rating Submission**: Backend service (Layer 1)
- **Rating Display**: Backend service (Layer 1)
- **Auto-Rating**: Background job (Layer 1)
- **Trust Tier Integration**: TrustTierService (Layer 1)

### 12.2 AI Authority

**No AI involvement in ratings** (pure user feedback)

---

## §13. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial bidirectional rating specification |

---

**END OF RATING_SYSTEM_SPEC v1.0.0**
