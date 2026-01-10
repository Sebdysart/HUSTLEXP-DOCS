# Analytics & Metrics Infrastructure Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Event tracking, conversion funnels, and data-driven decision making

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **You cannot improve what you do not measure.**

Every user action is tracked. Every conversion is measured. Every decision is data-driven.

**What This Unlocks:**
- Identify bottlenecks (where users drop off)
- Optimize conversion (signup → first task → repeat)
- Measure feature impact (A/B testing)
- Track retention (cohort analysis)
- Drive product decisions (data, not intuition)

---

## §1. Event Tracking System

### 1.1 Event Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **User Actions** | User interactions | `task_viewed`, `task_accepted`, `proof_submitted` |
| **System Events** | Backend events | `escrow_funded`, `payment_released`, `dispute_opened` |
| **Error Events** | Failures | `payment_failed`, `validation_error`, `invariant_violation` |
| **Performance** | Latency, errors | `api_latency`, `db_query_time`, `cache_hit_rate` |

---

### 1.2 Event Schema

```typescript
interface AnalyticsEvent {
  // Identity
  event_id: string;  // UUID
  event_type: string;  // e.g., "task_viewed"
  event_category: 'user_action' | 'system_event' | 'error' | 'performance';
  
  // User context
  user_id: string | null;  // NULL for anonymous
  session_id: string;
  device_id: string;  // Persistent device identifier
  
  // Context
  task_id?: string;
  task_category?: string;
  trust_tier?: number;
  
  // Properties (flexible JSON)
  properties: Record<string, any>;
  
  // Metadata
  ip_address?: string;  // Anonymized
  user_agent?: string;  // Anonymized
  platform: 'ios' | 'android' | 'web';
  app_version: string;
  
  // Timestamps
  timestamp: Date;
  ingested_at: Date;
}
```

---

### 1.3 Core Events to Track

#### User Onboarding Funnel

| Event | When | Properties |
|-------|------|------------|
| `signup_started` | User opens signup screen | `{ method: 'email' \| 'google' }` |
| `signup_completed` | User creates account | `{ user_id, trust_tier: 1 }` |
| `onboarding_started` | User starts onboarding | `{ user_id }` |
| `onboarding_completed` | User completes onboarding | `{ user_id, role: 'poster' \| 'worker' }` |
| `first_task_viewed` | User views first task | `{ user_id, task_id, task_category }` |
| `first_task_posted` | Poster posts first task | `{ user_id, task_id, task_price }` |
| `first_task_accepted` | Worker accepts first task | `{ user_id, task_id, task_price }` |
| `first_task_completed` | First task completed | `{ user_id, task_id, earnings }` |

#### Task Lifecycle Events

| Event | When | Properties |
|-------|------|------------|
| `task_created` | Poster creates task | `{ task_id, category, price, deadline }` |
| `task_viewed` | Worker views task | `{ task_id, user_id, source: 'feed' \| 'search' }` |
| `task_accepted` | Worker accepts task | `{ task_id, user_id, time_to_accept }` |
| `task_started` | Worker marks task as started | `{ task_id, user_id }` |
| `proof_submitted` | Worker submits proof | `{ task_id, user_id, proof_count }` |
| `proof_approved` | Poster approves proof | `{ task_id, user_id, time_to_approve }` |
| `proof_rejected` | Poster rejects proof | `{ task_id, user_id, rejection_reason }` |
| `task_completed` | Task reaches COMPLETED | `{ task_id, poster_id, worker_id, earnings }` |
| `task_cancelled` | Task cancelled | `{ task_id, cancelled_by, reason }` |
| `task_expired` | Task deadline passed | `{ task_id, accepted: boolean }` |

#### Messaging Events

| Event | When | Properties |
|-------|------|------------|
| `message_sent` | User sends message | `{ task_id, sender_id, message_type, length }` |
| `message_read` | User reads message | `{ task_id, reader_id, message_id }` |

#### Trust & Reputation Events

| Event | When | Properties |
|-------|------|------------|
| `trust_tier_upgraded` | User promoted | `{ user_id, old_tier, new_tier }` |
| `trust_tier_downgraded` | User demoted | `{ user_id, old_tier, new_tier, reason }` |
| `badge_earned` | User earns badge | `{ user_id, badge_id, badge_name }` |
| `rating_submitted` | User submits rating | `{ task_id, rater_id, ratee_id, stars }` |

#### Payment Events

| Event | When | Properties |
|-------|------|------------|
| `escrow_funded` | Escrow payment confirmed | `{ task_id, amount, payment_method }` |
| `payment_released` | Payment released to worker | `{ task_id, amount, worker_id }` |
| `refund_issued` | Refund processed | `{ task_id, amount, reason }` |

---

## §2. Conversion Funnels

### 2.1 Signup Funnel

```
1. Landing Page View
   ↓ (conversion rate: TBD)
2. Signup Started
   ↓ (conversion rate: TBD)
3. Signup Completed
   ↓ (conversion rate: TBD)
4. Onboarding Started
   ↓ (conversion rate: TBD)
5. Onboarding Completed
   ↓ (conversion rate: TBD)
6. First Action (post task OR view task)
```

**Metrics:**
- Drop-off rate at each step
- Time to complete each step
- Overall conversion rate (landing → first action)

---

### 2.2 Task Posting Funnel (Poster)

```
1. Create Task (DRAFT)
   ↓ (conversion rate: TBD)
2. AI Task Completion (INCOMPLETE → COMPLETE)
   ↓ (conversion rate: TBD)
3. Escrow Funded (LOCKED)
   ↓ (conversion rate: TBD)
4. Task Accepted
   ↓ (conversion rate: TBD)
5. Task Completed
```

**Metrics:**
- Task completion rate (DRAFT → LOCKED)
- Time to complete task creation
- Escrow funding rate
- Task acceptance rate
- Task completion rate

---

### 2.3 Task Acceptance Funnel (Worker)

```
1. Task Viewed
   ↓ (conversion rate: TBD)
2. Task Details Viewed
   ↓ (conversion rate: TBD)
3. Task Accepted
   ↓ (conversion rate: TBD)
4. Task Started
   ↓ (conversion rate: TBD)
5. Proof Submitted
   ↓ (conversion rate: TBD)
6. Proof Approved (Task Completed)
```

**Metrics:**
- View → Accept rate
- Accept → Complete rate
- Average time to accept
- Average time to complete

---

## §3. Cohort Analysis

### 3.1 Retention Cohorts

**Cohort Definition:** Users who signed up in the same week/month

**Retention Metrics:**
- Day 1 retention (users active 1 day after signup)
- Day 7 retention (users active 7 days after signup)
- Day 30 retention (users active 30 days after signup)

**Cohort Table:**
```
Cohort     | Users | Day 1 | Day 7 | Day 30
-----------|-------|-------|-------|--------
Week 1     | 100   | 60%   | 30%   | 15%
Week 2     | 150   | 65%   | 35%   | 18%
Week 3     | 200   | 70%   | 40%   | 20%
```

---

### 3.2 Revenue Cohorts

**Revenue Per User (RPU) by Cohort:**
- First task earnings (workers)
- First task spend (posters)
- Lifetime value (LTV)
- Average revenue per user (ARPU)

---

## §4. A/B Testing Framework

### 4.1 Test Structure

```typescript
interface ABTest {
  test_id: string;
  test_name: string;
  variants: {
    control: VariantConfig;
    treatment: VariantConfig;
  };
  traffic_split: number;  // 0-1, e.g., 0.5 = 50/50
  start_date: Date;
  end_date: Date;
  metrics: string[];  // Events to track
  status: 'draft' | 'running' | 'completed' | 'cancelled';
}
```

---

### 4.2 Example Tests

| Test | Hypothesis | Metric |
|------|------------|--------|
| **AI Question Count** | Fewer questions = higher completion | Task creation completion rate |
| **Notification Frequency** | More notifications = higher engagement | Task acceptance rate |
| **Trust Tier Visibility** | Show trust tier = higher acceptance | Task acceptance rate |
| **Price Range Filter** | Price filter = better matches | Task acceptance rate |

---

### 4.3 Test Assignment

**User Assignment:**
- Consistent assignment (user always sees same variant)
- Random assignment based on user_id hash
- Traffic split: 50/50 by default

**Tracking:**
- Track variant assignment per user
- Track all events for each variant
- Calculate statistical significance (p-value < 0.05)

---

## §5. Analytics Schema

### 5.1 Database Schema

```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identity
  event_type VARCHAR(100) NOT NULL,
  event_category VARCHAR(50) NOT NULL,
  
  -- User context
  user_id UUID REFERENCES users(id),
  session_id UUID NOT NULL,
  device_id UUID NOT NULL,
  
  -- Context
  task_id UUID REFERENCES tasks(id),
  task_category VARCHAR(50),
  trust_tier INTEGER,
  
  -- Properties (flexible JSON)
  properties JSONB NOT NULL DEFAULT '{}',
  
  -- Metadata
  platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  app_version VARCHAR(50),
  
  -- A/B Test assignment
  ab_test_id VARCHAR(100),
  ab_variant VARCHAR(20),
  
  -- Timestamps
  event_timestamp TIMESTAMPTZ NOT NULL,
  ingested_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_analytics_event_type ON analytics_events(event_type, event_timestamp DESC);
CREATE INDEX idx_analytics_user ON analytics_events(user_id, event_timestamp DESC);
CREATE INDEX idx_analytics_task ON analytics_events(task_id, event_timestamp DESC);
CREATE INDEX idx_analytics_session ON analytics_events(session_id, event_timestamp DESC);
CREATE INDEX idx_analytics_timestamp ON analytics_events(event_timestamp DESC);

-- Partition by month for performance
-- (PostgreSQL 10+)
-- CREATE TABLE analytics_events_2025_01 PARTITION OF analytics_events
--   FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

---

## §6. Real-Time Dashboards

### 6.1 Key Metrics Dashboard

**Real-Time Metrics:**
- Active users (last 1 hour)
- Tasks created (today)
- Tasks accepted (today)
- Tasks completed (today)
- Revenue (today)
- Dispute rate (last 24h)

---

### 6.2 Funnel Dashboard

**Conversion Funnels:**
- Signup funnel (last 7 days)
- Task posting funnel (last 7 days)
- Task acceptance funnel (last 7 days)

**Visualization:**
- Step-by-step conversion rates
- Drop-off points highlighted
- Time to complete each step

---

### 6.3 Cohort Dashboard

**Retention Cohorts:**
- Cohort table (weekly/monthly)
- Retention curves
- Revenue cohorts

---

## §7. Analytics Service

### 7.1 API Endpoints

```typescript
// tRPC router: analytics
analytics.track({
  input: {
    eventType: string;
    eventCategory: 'user_action' | 'system_event' | 'error' | 'performance';
    properties?: Record<string, any>;
    taskId?: string;
    abTestId?: string;
  },
  output: {
    eventId: string;
    status: 'tracked';
  }
});

analytics.getFunnel({
  input: {
    funnelId: 'signup' | 'task_posting' | 'task_acceptance';
    startDate: Date;
    endDate: Date;
  },
  output: {
    steps: FunnelStep[];
    conversionRates: number[];
    dropOffRates: number[];
  }
});

analytics.getCohort({
  input: {
    cohortType: 'retention' | 'revenue';
    startDate: Date;
    endDate: Date;
    period: 'week' | 'month';
  },
  output: {
    cohorts: CohortData[];
  }
});

analytics.getABTestResults({
  input: {
    testId: string;
  },
  output: {
    controlMetrics: MetricValue[];
    treatmentMetrics: MetricValue[];
    significance: number;  // p-value
    winner: 'control' | 'treatment' | 'inconclusive';
  }
});
```

---

## §8. Privacy & Compliance

### 8.1 Data Anonymization

**Anonymized Fields:**
- IP address (hash, last octet removed)
- User agent (generalized, not raw)
- Personal data (no PII in properties)

**Retention:**
- Raw events: 90 days
- Aggregated metrics: 2 years
- Deleted on user account deletion (GDPR)

---

### 8.2 GDPR Compliance

**User Rights:**
- Right to access (export all events)
- Right to delete (delete all events)
- Right to opt-out (disable tracking)

**Implementation:**
- `analytics.exportUserData(userId)` → CSV/JSON export
- `analytics.deleteUserData(userId)` → Delete all events
- `analytics.optOut(userId)` → Stop tracking

---

## §9. Metrics to Track

### 9.1 Business Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **DAU (Daily Active Users)** | TBD | Unique users active per day |
| **MAU (Monthly Active Users)** | TBD | Unique users active per month |
| **Task Creation Rate** | TBD | Tasks created per day |
| **Task Acceptance Rate** | >15% | Tasks accepted / Tasks viewed |
| **Task Completion Rate** | >90% | Tasks completed / Tasks accepted |
| **Dispute Rate** | <2% | Disputes / Tasks completed |
| **Revenue** | TBD | Total revenue per day/month |

---

### 9.2 Product Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Signup Conversion** | >30% | Signups / Landing page views |
| **Onboarding Completion** | >80% | Completed / Started |
| **First Task Rate** | >50% | First task within 7 days / Signups |
| **Retention (Day 7)** | >30% | Users active on day 7 / Signups |
| **Retention (Day 30)** | >15% | Users active on day 30 / Signups |
| **LTV (Lifetime Value)** | TBD | Average revenue per user |

---

## §10. Constitutional Alignment

### 10.1 Authority Model

- **Event Tracking**: Backend service (Layer 1)
- **Funnel Analysis**: Analytics service (Layer 1)
- **Cohort Analysis**: Analytics service (Layer 1)
- **A/B Testing**: Backend service (Layer 1)

### 10.2 AI Authority

**No AI involvement in analytics** (pure data collection and analysis)

---

## §11. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial analytics specification |

---

**END OF ANALYTICS_SPEC v1.0.0**
