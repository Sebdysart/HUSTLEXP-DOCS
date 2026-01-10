# Task Discovery & Matching Algorithm Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Define how hustlers discover and match with tasks (the core interaction)

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Task discovery is not a feed. It is a personalized matching engine.**

Hustlers don't browse. They **match** with tasks that fit their profile, skills, location, and preferences.

**What This Unlocks:**
- Highest task acceptance rates
- Fastest fulfillment
- Best earning potential for hustlers
- Highest satisfaction for posters

---

## §1. Matching Score Formula

### 1.1 Core Matching Score

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

### 1.2 Component Calculations

#### Trust Multiplier (0.0 to 1.0)

```typescript
trust_multiplier = (
  (trust_tier_value / 4.0) × 0.60 +  // ROOKIE=1, VERIFIED=2, TRUSTED=3, ELITE=4
  (completion_rate / 100) × 0.30 +   // 0-100% completion rate
  (approval_rate / 100) × 0.10        // 0-100% proof approval rate
)
```

**Why This Matters:**
- Higher trust = better matches
- Rewards reliable hustlers
- Posters get quality workers

---

#### Distance Score (0.0 to 1.0)

```typescript
distance_miles = calculateDistance(hustler_location, task_location);

if (distance_miles <= 1.0) {
  distance_score = 1.0;  // Excellent
} else if (distance_miles <= 3.0) {
  distance_score = 1.0 - ((distance_miles - 1.0) / 2.0) × 0.3;  // 1.0 to 0.7
} else if (distance_miles <= 5.0) {
  distance_score = 0.7 - ((distance_miles - 3.0) / 2.0) × 0.4;  // 0.7 to 0.3
} else if (distance_miles <= 10.0) {
  distance_score = 0.3 - ((distance_miles - 5.0) / 5.0) × 0.2;  // 0.3 to 0.1
} else {
  distance_score = 0.0;  // Too far
}
```

**Why This Matters:**
- Proximity = faster completion
- Reduces travel time
- Better for both sides

---

#### Category Match (0.0 to 1.0)

```typescript
category_match = (
  (preferred_categories.includes(task.category) ? 1.0 : 0.6) × 0.70 +
  (category_experience_count[task.category] / 10.0) × 0.30  // Cap at 10+ tasks
)
```

**Why This Matters:**
- Skills match = better quality
- Experience = faster completion
- Reduces disputes

---

#### Price Attractiveness (0.0 to 1.0)

```typescript
price_attractiveness = (
  (task.price >= hustler.preferred_min_price ? 1.0 : 0.5) × 0.60 +
  (task.price >= market_average_for_category ? 1.0 : 0.7) × 0.40
)
```

**Why This Matters:**
- Fair pricing = happier workers
- Above market = competitive advantage
- Reduces price disputes

---

#### Time Match (0.0 to 1.0)

```typescript
time_until_deadline = task.deadline - NOW();
hustler_available_window = calculateAvailability(hustler);

if (time_until_deadline >= hustler_available_window) {
  time_match = 1.0;  // Perfect timing
} else if (time_until_deadline >= hustler_available_window × 0.5) {
  time_match = 0.7;  // Tight but doable
} else {
  time_match = 0.3;  // Very tight
}
```

**Why This Matters:**
- Realistic deadlines = completion success
- Time pressure = stress = disputes

---

### 1.3 Matching Score Thresholds

| Score Range | Visibility | Label |
|-------------|------------|-------|
| **0.80 - 1.0** | Top of feed | "Perfect Match" |
| **0.60 - 0.79** | High in feed | "Great Match" |
| **0.40 - 0.59** | Normal feed | "Good Match" |
| **0.20 - 0.39** | Lower in feed | "Possible Match" |
| **< 0.20** | Hidden (unless search) | "Poor Match" |

**Rule:** Tasks below 0.20 matching score are hidden from feed unless explicitly searched.

---

## §2. Feed Ranking Algorithm

### 2.1 Ranking Formula

Tasks are ranked by **relevance score**, not just matching score:

```
relevance_score = (
  matching_score × 0.70 +
  recency_boost × 0.15 +
  urgency_boost × 0.10 +
  poster_quality_boost × 0.05
)
```

### 2.2 Boost Calculations

#### Recency Boost

```typescript
hours_since_posted = (NOW() - task.created_at) / 3600;

if (hours_since_posted <= 1) {
  recency_boost = 1.0;  // Very fresh
} else if (hours_since_posted <= 6) {
  recency_boost = 1.0 - ((hours_since_posted - 1) / 5.0) × 0.3;  // 1.0 to 0.7
} else if (hours_since_posted <= 24) {
  recency_boost = 0.7 - ((hours_since_posted - 6) / 18.0) × 0.4;  // 0.7 to 0.3
} else {
  recency_boost = 0.3;  // Stale
}
```

---

#### Urgency Boost

```typescript
hours_until_deadline = (task.deadline - NOW()) / 3600;

if (hours_until_deadline <= 2) {
  urgency_boost = 1.0;  // Very urgent
} else if (hours_until_deadline <= 6) {
  urgency_boost = 1.0 - ((hours_until_deadline - 2) / 4.0) × 0.3;  // 1.0 to 0.7
} else if (hours_until_deadline <= 24) {
  urgency_boost = 0.7 - ((hours_until_deadline - 6) / 18.0) × 0.3;  // 0.7 to 0.4
} else {
  urgency_boost = 0.4;  // Not urgent
}
```

---

#### Poster Quality Boost

```typescript
// From poster_reputation view (PRODUCT_SPEC §8.4)
poster_quality_boost = (
  (poster.tasks_posted >= 5 ? 1.0 : 0.5) × 0.40 +
  (1.0 - poster.dispute_rate) × 0.40 +  // Lower dispute rate = higher boost
  (poster.avg_response_hours <= 2.0 ? 1.0 : 0.7) × 0.20
)
```

**Why This Matters:**
- Good posters get visibility
- Bad posters get deprioritized
- Encourages quality

---

### 2.3 Feed Display Rules

**Standard Feed:**
- Show top 20 tasks by relevance_score
- Update every 30 seconds (refresh on pull)
- Infinite scroll (load next 20)

**Live Mode Feed:**
- Show only LIVE tasks
- Rank by: distance (primary), price (secondary), trust (tertiary)
- Update every 5 seconds
- No infinite scroll (time-bounded broadcasts)

---

## §3. Filter Specifications

### 3.1 Allowed Filters

| Filter | Type | Options | Default |
|--------|------|---------|---------|
| **Category** | Multi-select | All task categories | All |
| **Price Range** | Min/Max | $5 - $500+ | No limit |
| **Distance** | Max miles | 1, 3, 5, 10, 20, 50 | 10 miles |
| **Time Window** | Hours until deadline | 1h, 3h, 6h, 12h, 24h, 48h+ | All |
| **Trust Tier** | Multi-select | ROOKIE, VERIFIED, TRUSTED, ELITE | All |
| **Mode** | Single-select | STANDARD, LIVE, All | All |
| **Escrow Status** | Multi-select | PENDING, FUNDED | FUNDED only |

### 3.2 Filter Application

```typescript
function applyFilters(tasks: Task[], filters: Filters): Task[] {
  return tasks
    .filter(task => filters.categories.length === 0 || filters.categories.includes(task.category))
    .filter(task => task.price >= filters.price_min && task.price <= filters.price_max)
    .filter(task => calculateDistance(hustler_location, task.location) <= filters.distance_max)
    .filter(task => (task.deadline - NOW()) / 3600 <= filters.time_window)
    .filter(task => filters.trust_tiers.length === 0 || filters.trust_tiers.includes(poster.trust_tier))
    .filter(task => filters.mode === 'ALL' || task.mode === filters.mode)
    .filter(task => filters.escrow_status.includes(escrow.state));
}
```

### 3.3 Filter Persistence

**Rules:**
- Filters persist in localStorage (per device)
- Filters reset on app restart (defaults)
- No server-side filter storage (privacy)

---

## §4. Sort Options

### 4.1 Allowed Sort Options

| Sort Option | Description | Formula |
|-------------|-------------|---------|
| **Relevance** (Default) | By relevance_score | `relevance_score DESC` |
| **Distance** | Nearest first | `distance_miles ASC` |
| **Price High** | Highest price first | `price DESC` |
| **Price Low** | Lowest price first | `price ASC` |
| **Deadline Soon** | Earliest deadline first | `deadline ASC` |
| **Deadline Later** | Latest deadline first | `deadline DESC` |
| **Poster Trust** | Highest trust tier first | `poster.trust_tier DESC` |
| **Recently Posted** | Newest first | `created_at DESC` |

### 4.2 Sort Application

**Rule:** Sort is applied **after** filtering and matching score calculation.

```typescript
function sortTasks(tasks: Task[], sortBy: SortOption): Task[] {
  switch (sortBy) {
    case 'RELEVANCE':
      return tasks.sort((a, b) => b.relevance_score - a.relevance_score);
    case 'DISTANCE':
      return tasks.sort((a, b) => a.distance_miles - b.distance_miles);
    case 'PRICE_HIGH':
      return tasks.sort((a, b) => b.price - a.price);
    case 'PRICE_LOW':
      return tasks.sort((a, b) => a.price - b.price);
    case 'DEADLINE_SOON':
      return tasks.sort((a, b) => a.deadline.getTime() - b.deadline.getTime());
    case 'DEADLINE_LATER':
      return tasks.sort((a, b) => b.deadline.getTime() - a.deadline.getTime());
    case 'POSTER_TRUST':
      return tasks.sort((a, b) => b.poster.trust_tier - a.poster.trust_tier);
    case 'RECENTLY_POSTED':
      return tasks.sort((a, b) => b.created_at.getTime() - a.created_at.getTime());
    default:
      return tasks;  // Relevance (default)
  }
}
```

---

## §5. Search Functionality

### 5.1 Search Algorithm

**Full-Text Search** on:
- Task title
- Task description
- Task location
- Task category

**Search Formula:**
```
search_score = (
  title_match_weight × 0.50 +
  description_match_weight × 0.30 +
  location_match_weight × 0.15 +
  category_match_weight × 0.05
)
```

### 5.2 Match Weights

```typescript
function calculateSearchScore(task: Task, query: string): number {
  const queryLower = query.toLowerCase();
  const titleMatch = task.title.toLowerCase().includes(queryLower) ? 1.0 : 0.0;
  const descMatch = task.description.toLowerCase().includes(queryLower) ? 0.8 : 0.0;
  const locationMatch = task.location.toLowerCase().includes(queryLower) ? 0.6 : 0.0;
  const categoryMatch = task.category.toLowerCase().includes(queryLower) ? 0.4 : 0.0;
  
  return (titleMatch × 0.50) + (descMatch × 0.30) + (locationMatch × 0.15) + (categoryMatch × 0.05);
}
```

### 5.3 Search + Filter Integration

**Rule:** Search results are **filtered and sorted** just like feed tasks.

```typescript
function searchTasks(query: string, filters: Filters, sortBy: SortOption): Task[] {
  // 1. Calculate search scores
  const tasksWithSearchScores = allTasks.map(task => ({
    ...task,
    search_score: calculateSearchScore(task, query)
  }));
  
  // 2. Filter by search score (minimum 0.1)
  const searchResults = tasksWithSearchScores.filter(task => task.search_score >= 0.1);
  
  // 3. Apply filters
  const filtered = applyFilters(searchResults, filters);
  
  // 4. Combine search_score with matching_score
  const combined = filtered.map(task => ({
    ...task,
    relevance_score: (task.search_score × 0.40) + (task.matching_score × 0.60)
  }));
  
  // 5. Sort
  return sortTasks(combined, sortBy);
}
```

### 5.4 Saved Searches (Optional)

**Post-Launch Feature:**
- Save search query + filters
- Name saved searches ("High-paying cleaning", "Nearby moving")
- Quick access from feed

---

## §6. "Why This Task?" Explanations

### 6.1 AI-Powered Explanations

For each task in feed, show **why it matches**:

```
Why you're seeing this:
• Perfect distance match (0.8 miles)
• You've completed 12 moving tasks
• Above market rate ($45 vs $35 avg)
• Poster is VERIFIED with 0% dispute rate
```

**Authority Level:** A1 (Read-Only, Advisory)  
**Source:** AI_INFRASTRUCTURE.md §3.2

### 6.2 Explanation Generation

```typescript
interface TaskExplanation {
  reasons: string[];  // Top 3 reasons
  confidence: number;  // 0.0 to 1.0
  generated_at: Date;
}

function generateExplanation(task: Task, hustler: User, matchingScore: number): TaskExplanation {
  const reasons: string[] = [];
  
  // Distance reason
  if (task.distance_miles <= 1.0) {
    reasons.push(`Perfect distance match (${task.distance_miles.toFixed(1)} miles)`);
  } else if (task.distance_miles <= 3.0) {
    reasons.push(`Great distance (${task.distance_miles.toFixed(1)} miles)`);
  }
  
  // Category reason
  if (hustler.category_experience[task.category] >= 5) {
    reasons.push(`You've completed ${hustler.category_experience[task.category]} ${task.category} tasks`);
  }
  
  // Price reason
  const marketAvg = getMarketAverageForCategory(task.category);
  if (task.price >= marketAvg × 1.2) {
    reasons.push(`Above market rate ($${task.price/100} vs $${marketAvg/100} avg)`);
  }
  
  // Poster quality reason
  if (task.poster.trust_tier >= 2 && task.poster.dispute_rate === 0) {
    reasons.push(`Poster is ${task.poster.trust_tier_name} with 0% dispute rate`);
  }
  
  return {
    reasons: reasons.slice(0, 3),  // Top 3 only
    confidence: matchingScore,
    generated_at: new Date()
  };
}
```

### 6.3 Display Rules

**When to Show:**
- Always shown in task feed (small text below task)
- Expandable for full explanation
- Hidden if confidence < 0.40 (poor match)

**UI Location:**
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
│  ℹ️ Why you're seeing this:                             │
│  • Great distance (2.1 miles)                           │
│  • You've completed 8 cleaning tasks                    │
│  • Above market rate                                    │
│                                                         │
│  [ Accept Task ]                                        │
└─────────────────────────────────────────────────────────┘
```

---

## §7. Matching Algorithm Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MATCH-1** | Matching score is always 0.0 to 1.0 | Backend validation |
| **MATCH-2** | Tasks below 0.20 score are hidden from feed | Backend filter |
| **MATCH-3** | Relevance score combines matching + boosts | Backend calculation |
| **MATCH-4** | Filters never bypass trust tier requirements | Backend validation |
| **MATCH-5** | Search + filter + sort are composable | Backend logic |
| **MATCH-6** | Explanations are advisory only (A1) | AI authority model |

---

## §8. Performance Requirements

### 8.1 Latency Targets

| Operation | Target | Maximum |
|-----------|--------|---------|
| Feed generation | < 200ms | 500ms |
| Filter application | < 100ms | 200ms |
| Search results | < 300ms | 500ms |
| Explanation generation | < 150ms | 300ms |

### 8.2 Caching Strategy

**Cache Matching Scores:**
- Recalculate every 5 minutes (user location changes)
- Cache per user-task pair (Redis key: `match:{userId}:{taskId}`)
- Invalidate on: task update, user location change, user trust tier change

**Cache Feed Results:**
- Cache top 20 tasks per user (Redis key: `feed:{userId}`)
- TTL: 30 seconds
- Invalidate on: new task posted, filter change, sort change

---

## §9. Schema Additions

```sql
-- Add matching score cache table (optional optimization)
CREATE TABLE task_matching_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  hustler_id UUID NOT NULL REFERENCES users(id),
  matching_score DECIMAL(3,2) NOT NULL CHECK (matching_score >= 0.0 AND matching_score <= 1.0),
  relevance_score DECIMAL(3,2) NOT NULL,
  distance_miles DECIMAL(5,2) NOT NULL,
  calculated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  
  UNIQUE(task_id, hustler_id)
);

CREATE INDEX idx_matching_scores_hustler ON task_matching_scores(hustler_id, relevance_score DESC);
CREATE INDEX idx_matching_scores_task ON task_matching_scores(task_id, matching_score DESC);

-- Add saved searches (optional, post-launch)
CREATE TABLE saved_searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(100) NOT NULL,
  query TEXT,
  filters JSONB NOT NULL,
  sort_by VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_saved_searches_user ON saved_searches(user_id);
```

---

## §10. API Endpoints

```typescript
// tRPC router: taskDiscovery
taskDiscovery.getFeed({
  input: {
    filters?: Filters;
    sortBy?: SortOption;
    limit?: number;  // Default: 20
    offset?: number;  // Default: 0
  },
  output: {
    tasks: Task[];
    total_count: number;
    has_more: boolean;
    explanations: Record<string, TaskExplanation>;  // taskId → explanation
  }
});

taskDiscovery.search({
  input: {
    query: string;
    filters?: Filters;
    sortBy?: SortOption;
    limit?: number;
    offset?: number;
  },
  output: {
    tasks: Task[];
    total_count: number;
    has_more: boolean;
    search_score: Record<string, number>;  // taskId → search_score
  }
});

taskDiscovery.getExplanation({
  input: {
    taskId: string;
  },
  output: {
    explanation: TaskExplanation;
  }
});
```

---

## §11. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Feed acceptance rate** | >15% | Tasks accepted / Tasks viewed |
| **Search conversion rate** | >20% | Tasks accepted from search / Search queries |
| **Average matching score** | >0.60 | Mean matching score of accepted tasks |
| **Filter usage rate** | >40% | Users who apply filters / Total users |
| **Explanation engagement** | >30% | Users who expand explanation / Total views |
| **Feed generation latency** | <200ms p95 | Backend metrics |
| **Cache hit rate** | >80% | Redis cache hits / Total requests |

---

## §12. Constitutional Alignment

### 12.1 Authority Model

- **Matching Score Calculation**: Backend service (Layer 1)
- **Feed Ranking**: Backend service (Layer 1)
- **Filter/Sort Application**: Backend service (Layer 1)
- **Search Algorithm**: Backend service (Layer 1)
- **Explanation Generation**: AI (A1 - Advisory, Read-Only)

### 12.2 AI Authority

**Explanations are A1 (Advisory):**
- AI reads task and user data
- AI generates explanation text
- AI does NOT influence matching score
- AI does NOT change task visibility

---

## §13. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial task discovery specification |

---

**END OF TASK_DISCOVERY_SPEC v1.0.0**
