# HustleXP Matching Algorithms v1.0.0

**STATUS: IMPLEMENTATION SPECIFICATION**
**Authority:** PRODUCT_SPEC.md §9, API_CONTRACT.md task.getFeed
**Cursor-Ready:** YES - All formulas implementable without additional clarification

---

## Table of Contents

1. [Overview](#overview)
2. [Matching Score Formula](#matching-score-formula)
3. [Component Calculations](#component-calculations)
4. [Eligibility Check](#eligibility-check)
5. [Feed Ranking Algorithm](#feed-ranking-algorithm)
6. [Live Mode Matching](#live-mode-matching)
7. [Implementation Reference](#implementation-reference)

---

## Overview

The matching system computes a relevance score (0.0 to 1.0) for each task-hustler pair. This score determines feed ordering and helps hustlers find suitable tasks quickly.

### Key Principles

1. **Deterministic**: Same inputs always produce same output
2. **Explainable**: Score components visible to users
3. **Fast**: O(1) per task-hustler pair
4. **Tunable**: Weights stored in config, not hardcoded

---

## Matching Score Formula

### Master Formula

```
matchingScore = Σ(component_i × weight_i) × eligibilityMultiplier

where:
  - component_i ∈ [0.0, 1.0]
  - Σ(weight_i) = 1.0
  - eligibilityMultiplier ∈ {0.0, 1.0}
```

### Component Weights (v1.0)

| Component | Weight | Rationale |
|-----------|--------|-----------|
| distance_score | 0.25 | Physical proximity is primary convenience factor |
| price_attractiveness | 0.20 | Earnings potential drives engagement |
| category_match | 0.20 | Skill alignment improves completion quality |
| poster_rating | 0.15 | Good posters mean better experiences |
| urgency_fit | 0.10 | Deadline alignment with hustler availability |
| trust_compatibility | 0.10 | Trust tier alignment reduces friction |

### TypeScript Implementation

```typescript
interface MatchingWeights {
  distance: number;
  price: number;
  category: number;
  posterRating: number;
  urgency: number;
  trust: number;
}

const DEFAULT_WEIGHTS: MatchingWeights = {
  distance: 0.25,
  price: 0.20,
  category: 0.20,
  posterRating: 0.15,
  urgency: 0.10,
  trust: 0.10,
};

function calculateMatchingScore(
  components: MatchingComponents,
  weights: MatchingWeights = DEFAULT_WEIGHTS,
  isEligible: boolean
): number {
  if (!isEligible) return 0.0;

  return (
    components.distanceScore * weights.distance +
    components.priceAttractiveness * weights.price +
    components.categoryMatch * weights.category +
    components.posterRating * weights.posterRating +
    components.urgencyFit * weights.urgency +
    components.trustCompatibility * weights.trust
  );
}
```

---

## Component Calculations

### 1. Distance Score

**Formula:**
```
distance_score = max(0, 1 - (distance_miles / max_radius_miles))
```

**Implementation:**
```typescript
function calculateDistanceScore(
  taskLat: number,
  taskLng: number,
  hustlerLat: number,
  hustlerLng: number,
  maxRadiusMiles: number = 25
): number {
  const distanceMiles = haversineDistance(taskLat, taskLng, hustlerLat, hustlerLng);

  if (distanceMiles > maxRadiusMiles) return 0.0;

  return Math.max(0, 1 - (distanceMiles / maxRadiusMiles));
}

// Haversine formula for distance in miles
function haversineDistance(
  lat1: number, lng1: number,
  lat2: number, lng2: number
): number {
  const R = 3959; // Earth's radius in miles
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);

  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
            Math.sin(dLng / 2) ** 2;

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}
```

**Score Distribution:**
- 0 miles: 1.0
- 5 miles: 0.8
- 12.5 miles: 0.5
- 25 miles: 0.0

---

### 2. Price Attractiveness

**Formula:**
```
price_attractiveness = normalize(task_price, market_floor, market_ceiling)

where:
  market_floor = category_median × 0.5
  market_ceiling = category_median × 2.0
  normalize(x, min, max) = clamp((x - min) / (max - min), 0, 1)
```

**Implementation:**
```typescript
interface CategoryPriceStats {
  median: number;  // in cents
  p25: number;     // 25th percentile
  p75: number;     // 75th percentile
}

// Pre-computed category stats (updated daily via cron)
const CATEGORY_PRICE_STATS: Record<string, CategoryPriceStats> = {
  'cleaning': { median: 5000, p25: 3000, p75: 8000 },
  'moving': { median: 12000, p25: 7500, p75: 20000 },
  'delivery': { median: 2500, p25: 1500, p75: 4000 },
  'handyman': { median: 7500, p25: 4000, p75: 15000 },
  'errands': { median: 2000, p25: 1000, p75: 3500 },
  'tech_help': { median: 6000, p25: 3500, p75: 10000 },
  'yard_work': { median: 6500, p25: 4000, p75: 12000 },
  'pet_care': { median: 3500, p25: 2000, p75: 6000 },
  'other': { median: 5000, p25: 2500, p75: 10000 },
};

function calculatePriceAttractiveness(
  taskPriceCents: number,
  category: string
): number {
  const stats = CATEGORY_PRICE_STATS[category] || CATEGORY_PRICE_STATS['other'];

  const floor = stats.median * 0.5;
  const ceiling = stats.median * 2.0;

  const normalized = (taskPriceCents - floor) / (ceiling - floor);

  return Math.max(0, Math.min(1, normalized));
}
```

**Score Distribution (for median $50 category):**
- $25 or less: 0.0
- $50: 0.5
- $75: 0.75
- $100+: 1.0

---

### 3. Category Match

**Formula:**
```
category_match =
  1.0 if hustler has verified trade matching task category
  0.8 if hustler has claimed (unverified) trade matching category
  0.6 if category in hustler's recently completed categories (last 30 days)
  0.4 if category in same category group as hustler's trades
  0.2 if hustler has generic tasks completed
  0.0 if no match
```

**Implementation:**
```typescript
interface HustlerProfile {
  verifiedTrades: string[];
  claimedTrades: string[];
  recentCategories: string[];  // Last 30 days
  totalTasksCompleted: number;
}

const CATEGORY_GROUPS: Record<string, string[]> = {
  'home_services': ['cleaning', 'handyman', 'yard_work', 'organization'],
  'transportation': ['moving', 'delivery', 'errands'],
  'professional': ['tech_help', 'admin', 'tutoring'],
  'care': ['pet_care', 'elder_care', 'child_care'],
};

function getCategoryGroup(category: string): string | null {
  for (const [group, categories] of Object.entries(CATEGORY_GROUPS)) {
    if (categories.includes(category)) return group;
  }
  return null;
}

function calculateCategoryMatch(
  taskCategory: string,
  hustler: HustlerProfile
): number {
  // Exact verified trade match
  if (hustler.verifiedTrades.includes(taskCategory)) {
    return 1.0;
  }

  // Claimed trade match
  if (hustler.claimedTrades.includes(taskCategory)) {
    return 0.8;
  }

  // Recently completed same category
  if (hustler.recentCategories.includes(taskCategory)) {
    return 0.6;
  }

  // Same category group
  const taskGroup = getCategoryGroup(taskCategory);
  if (taskGroup) {
    const hustlerGroups = [
      ...hustler.verifiedTrades,
      ...hustler.claimedTrades
    ].map(getCategoryGroup).filter(Boolean);

    if (hustlerGroups.includes(taskGroup)) {
      return 0.4;
    }
  }

  // Generic experience
  if (hustler.totalTasksCompleted > 0) {
    return 0.2;
  }

  return 0.0;
}
```

---

### 4. Poster Rating

**Formula:**
```
poster_rating = (avg_stars - 1) / 4

where:
  avg_stars ∈ [1.0, 5.0]
  result ∈ [0.0, 1.0]

If poster has < 5 ratings, use weighted blend:
  poster_rating = (actual_avg × rating_count + 4.0 × (5 - rating_count)) / 5
```

**Implementation:**
```typescript
interface PosterStats {
  avgRating: number | null;  // null if no ratings
  ratingCount: number;
  disputeRate: number;       // Disputes / Total tasks
}

function calculatePosterRatingScore(poster: PosterStats): number {
  // New poster with no ratings gets neutral score
  if (poster.avgRating === null || poster.ratingCount === 0) {
    return 0.75;  // Assume 4-star equivalent
  }

  let effectiveRating: number;

  if (poster.ratingCount < 5) {
    // Bayesian smoothing toward 4.0
    const smoothingWeight = 5 - poster.ratingCount;
    effectiveRating = (
      poster.avgRating * poster.ratingCount +
      4.0 * smoothingWeight
    ) / 5;
  } else {
    effectiveRating = poster.avgRating;
  }

  // Apply dispute penalty
  const disputePenalty = Math.min(poster.disputeRate * 2, 0.3);

  const baseScore = (effectiveRating - 1) / 4;

  return Math.max(0, baseScore - disputePenalty);
}
```

**Score Distribution:**
- 5.0 stars: 1.0
- 4.0 stars: 0.75
- 3.0 stars: 0.50
- 2.0 stars: 0.25
- 1.0 star: 0.0

---

### 5. Urgency Fit

**Formula:**
```
urgency_fit = 1 - |urgency_bias_mismatch|

where:
  task_urgency = 1 - (hours_until_deadline / 168)  // 168 = 1 week
  task_urgency = clamp(task_urgency, 0, 1)

  urgency_bias_mismatch = task_urgency - hustler_urgency_bias
  hustler_urgency_bias ∈ [0.0, 1.0] from onboarding profile
```

**Implementation:**
```typescript
function calculateUrgencyFit(
  taskDeadline: Date,
  hustlerUrgencyBias: number,  // 0.0 = prefers relaxed, 1.0 = prefers urgent
  now: Date = new Date()
): number {
  const hoursUntilDeadline = (taskDeadline.getTime() - now.getTime()) / (1000 * 60 * 60);

  // Tasks due in more than a week are not urgent
  const maxHours = 168;  // 1 week

  const taskUrgency = Math.max(0, Math.min(1, 1 - (hoursUntilDeadline / maxHours)));

  const mismatch = Math.abs(taskUrgency - hustlerUrgencyBias);

  return 1 - mismatch;
}
```

**Score Examples:**
- Urgent task (2h deadline) + high urgency hustler (0.9): 0.87
- Urgent task (2h deadline) + low urgency hustler (0.2): 0.32
- Relaxed task (5d deadline) + low urgency hustler (0.2): 0.91

---

### 6. Trust Compatibility

**Formula:**
```
trust_compatibility =
  1.0 if hustler_tier >= required_tier
  0.5 if hustler_tier == required_tier - 1
  0.0 if hustler_tier < required_tier - 1 (also not eligible)
```

**Implementation:**
```typescript
function calculateTrustCompatibility(
  hustlerTier: number,    // 1-4
  requiredTier: number    // 1-4, from task
): number {
  if (hustlerTier >= requiredTier) {
    return 1.0;
  }

  if (hustlerTier === requiredTier - 1) {
    return 0.5;  // Close but not quite
  }

  return 0.0;  // Also fails eligibility
}
```

---

## Eligibility Check

Eligibility is a binary gate. A hustler is either eligible (multiplier = 1.0) or not (multiplier = 0.0).

### Eligibility Checks

```typescript
interface EligibilityResult {
  eligible: boolean;
  blockers: string[];
}

interface EligibilityContext {
  hustler: {
    trustTier: number;
    verifiedTrades: string[];
    insuranceValid: boolean;
    backgroundCheckValid: boolean;
    locationState: string;
    riskClearance: ('low' | 'medium' | 'high')[];
  };
  task: {
    requiredTrustTier: number;
    requiredTrade: string | null;
    insuranceRequired: boolean;
    backgroundCheckRequired: boolean;
    locationState: string;
    riskLevel: 'low' | 'medium' | 'high' | 'critical';
  };
}

function checkEligibility(ctx: EligibilityContext): EligibilityResult {
  const blockers: string[] = [];

  // 1. Trust Tier Check
  if (ctx.hustler.trustTier < ctx.task.requiredTrustTier) {
    blockers.push(`requires_trust_tier_${ctx.task.requiredTrustTier}`);
  }

  // 2. Trade Verification Check
  if (ctx.task.requiredTrade && !ctx.hustler.verifiedTrades.includes(ctx.task.requiredTrade)) {
    blockers.push(`requires_verified_trade_${ctx.task.requiredTrade}`);
  }

  // 3. Insurance Check
  if (ctx.task.insuranceRequired && !ctx.hustler.insuranceValid) {
    blockers.push('requires_insurance');
  }

  // 4. Background Check
  if (ctx.task.backgroundCheckRequired && !ctx.hustler.backgroundCheckValid) {
    blockers.push('requires_background_check');
  }

  // 5. Location State Check
  if (ctx.task.locationState !== ctx.hustler.locationState) {
    blockers.push(`requires_state_${ctx.task.locationState}`);
  }

  // 6. Risk Clearance Check
  if (!ctx.hustler.riskClearance.includes(ctx.task.riskLevel as any)) {
    blockers.push(`requires_risk_clearance_${ctx.task.riskLevel}`);
  }

  return {
    eligible: blockers.length === 0,
    blockers,
  };
}
```

---

## Feed Ranking Algorithm

### Primary Sort

Tasks are sorted by matching score descending, with tie-breakers.

```typescript
interface FeedTask {
  id: string;
  matchingScore: number;
  distanceMiles: number;
  priceCents: number;
  createdAt: Date;
}

function sortFeed(tasks: FeedTask[]): FeedTask[] {
  return tasks.sort((a, b) => {
    // Primary: Matching score descending
    if (Math.abs(a.matchingScore - b.matchingScore) > 0.01) {
      return b.matchingScore - a.matchingScore;
    }

    // Tie-breaker 1: Distance ascending
    if (Math.abs(a.distanceMiles - b.distanceMiles) > 0.5) {
      return a.distanceMiles - b.distanceMiles;
    }

    // Tie-breaker 2: Price descending
    if (a.priceCents !== b.priceCents) {
      return b.priceCents - a.priceCents;
    }

    // Tie-breaker 3: Newest first
    return b.createdAt.getTime() - a.createdAt.getTime();
  });
}
```

### Pagination

Use cursor-based pagination for stable ordering.

```typescript
interface FeedCursor {
  lastScore: number;
  lastId: string;
}

function encodeCursor(task: FeedTask): string {
  return Buffer.from(JSON.stringify({
    s: task.matchingScore,
    i: task.id,
  })).toString('base64');
}

function decodeCursor(cursor: string): FeedCursor {
  const data = JSON.parse(Buffer.from(cursor, 'base64').toString());
  return { lastScore: data.s, lastId: data.i };
}
```

---

## Live Mode Matching

Live mode uses the same matching formula but with adjusted weights for urgency.

### Live Mode Weights

```typescript
const LIVE_MODE_WEIGHTS: MatchingWeights = {
  distance: 0.35,     // Higher: proximity critical for quick response
  price: 0.15,        // Lower: urgency > price
  category: 0.20,     // Same
  posterRating: 0.10, // Lower: less time for deliberation
  urgency: 0.05,      // Lower: all live tasks are urgent by definition
  trust: 0.15,        // Higher: trust matters for fast commitment
};
```

### Broadcast Radius Expansion

```typescript
interface BroadcastConfig {
  initialRadiusMiles: number;
  expansionIntervalSeconds: number;
  expansionMiles: number;
  maxRadiusMiles: number;
}

const DEFAULT_BROADCAST_CONFIG: BroadcastConfig = {
  initialRadiusMiles: 2,
  expansionIntervalSeconds: 30,
  expansionMiles: 1,
  maxRadiusMiles: 10,
};

function getCurrentBroadcastRadius(
  startedAt: Date,
  config: BroadcastConfig = DEFAULT_BROADCAST_CONFIG
): number {
  const elapsedSeconds = (Date.now() - startedAt.getTime()) / 1000;
  const expansions = Math.floor(elapsedSeconds / config.expansionIntervalSeconds);

  return Math.min(
    config.initialRadiusMiles + (expansions * config.expansionMiles),
    config.maxRadiusMiles
  );
}
```

---

## Implementation Reference

### Database Query (PostgreSQL)

```sql
-- Get eligible tasks with matching scores for a hustler
WITH hustler_profile AS (
  SELECT
    cp.user_id,
    cp.trust_tier,
    cp.risk_clearance,
    cp.insurance_valid,
    cp.background_check_valid,
    cp.location_state,
    COALESCE(u.urgency_bias, 0.5) as urgency_bias,
    array_agg(DISTINCT vt.trade) as verified_trades
  FROM capability_profiles cp
  JOIN users u ON u.id = cp.user_id
  LEFT JOIN verified_trades vt ON vt.profile_id = cp.profile_id
  WHERE cp.user_id = $1
  GROUP BY cp.user_id, cp.trust_tier, cp.risk_clearance,
           cp.insurance_valid, cp.background_check_valid,
           cp.location_state, u.urgency_bias
),
eligible_tasks AS (
  SELECT t.*
  FROM tasks t, hustler_profile hp
  WHERE t.state = 'OPEN'
    AND t.mode = 'STANDARD'
    AND hp.trust_tier >= COALESCE(t.required_trust_tier, 1)
    AND (t.required_trade IS NULL OR t.required_trade = ANY(hp.verified_trades))
    AND (NOT t.insurance_required OR hp.insurance_valid)
    AND (NOT t.background_check_required OR hp.background_check_valid)
    AND t.location_state = hp.location_state
    AND t.risk_level = ANY(hp.risk_clearance)
)
SELECT
  et.id,
  et.title,
  et.price,
  et.category,
  -- Distance score component
  GREATEST(0, 1 - (
    earth_distance(
      ll_to_earth(et.location_lat, et.location_lng),
      ll_to_earth($2, $3)
    ) / 1609.34 / $4  -- Convert meters to miles, divide by max radius
  )) as distance_score
FROM eligible_tasks et
ORDER BY distance_score DESC
LIMIT $5;
```

### Caching Strategy

```typescript
interface MatchingScoreCache {
  // Cache key: `matching:${taskId}:${hustlerId}`
  // TTL: 5 minutes
  // Invalidate on: task update, hustler profile update, price stats update
}

const CACHE_CONFIG = {
  ttlSeconds: 300,
  maxEntries: 100000,
  invalidationEvents: [
    'task.updated',
    'task.created',
    'capability_profile.updated',
    'price_stats.refreshed',
  ],
};
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial matching algorithms specification |

---

**END OF MATCHING ALGORITHMS SPECIFICATION**
