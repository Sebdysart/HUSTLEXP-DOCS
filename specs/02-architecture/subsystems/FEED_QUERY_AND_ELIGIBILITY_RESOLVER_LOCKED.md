# Feed Query & Eligibility Resolver — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This is the moment where eligibility becomes reality. If the feed resolver is wrong, everything built above it is ornamental. If a task appears in a user's feed, the user is eligible to accept it. There are no exceptions, warnings, disabled buttons, or soft blocks. Rejection must happen **before rendering**, not after interaction. This is how marketplaces avoid entropy.

---

## Core Law (Non-Negotiable)

**If a task appears in a user's feed, the user is eligible to accept it.**
**There are no exceptions, warnings, disabled buttons, or soft blocks.**

If this law is violated, trust leaks, users experience rejection, and the system becomes untrustworthy.

---

## Authority Chain (Final)

**1. Tasks (Immutable Requirements)**
- Tasks declare requirements (trade, trust tier, insurance, background check)
- Requirements are immutable after posting (cannot be downgraded)
- Task requirements are the single source of truth for task eligibility

**2. Capability Profile (Latest Derived Snapshot)**
- Capability profile is derived from verification records
- Capability profile is the single source of truth for user eligibility
- Capability profile is recomputed on verification state changes

**3. Eligibility Resolver (Pure Logic)**
- Pure function (deterministic, side-effect free)
- Compares task requirements against capability profile
- Returns boolean (eligible or not)

**4. Feed Query (SQL / Query Builder)**
- SQL filters tasks by eligibility (joins tasks with capability profiles)
- Only eligible tasks are returned (no post-filtering)
- Pagination, sorting, and filtering applied at SQL level

**5. Client Render (Dumb)**
- Client receives pre-filtered tasks (all eligible)
- Client never decides eligibility
- Client never shows disabled buttons or upsells

**The client never decides eligibility.**

---

## 1. Inputs to the Feed Resolver

### Required Inputs

**From Client:**
```typescript
{
  user_id: string; // From auth token
  location?: {
    latitude: number; // Optional, for nearby feed
    longitude: number; // Optional, for nearby feed
  };
  feed_mode: 'normal' | 'urgent' | 'nearby'; // Default: 'normal'
  pagination_cursor?: string; // Optional, for cursor-based pagination
  limit?: number; // Default: 50, max: 100
}
```

**Validation Rules:**
1. `user_id` is required (must be authenticated)
2. `location` is optional (required only for `feed_mode = 'nearby'`)
3. `feed_mode` must be valid (`'normal' | 'urgent' | 'nearby'`)
4. `pagination_cursor` is optional (opaque string)
5. `limit` must be between 1 and 100 (default: 50)

### Required Server Fetches

**1. Capability Profile (Latest Snapshot)**
```typescript
async function getLatestCapabilityProfile(userId: string): Promise<CapabilityProfile> {
  const profile = await CapabilityProfileRepository.findByUserId(userId);
  
  if (!profile) {
    throw new Error('Capability profile not found. Complete onboarding first.');
  }
  
  return profile;
}
```

**2. Active Tasks (Within Geo/Time Bounds)**
```typescript
async function getActiveTasks(
  location?: Location,
  feedMode: FeedMode,
  paginationCursor?: string,
  limit: number = 50
): Promise<Task[]> {
  // Tasks are fetched via SQL query (see Section 4)
  // SQL query filters by eligibility + feed mode + pagination
}
```

**If Capability Profile Is Missing → Empty Feed:**
```typescript
if (!profile) {
  return {
    tasks: [],
    pagination: {
      has_more: false,
      next_cursor: null,
    },
  };
}
```

**Behavioral Rules:**
- Capability profile is required (cannot proceed without it)
- Active tasks are filtered by eligibility at SQL level (see Section 4)
- No tasks are fetched if capability profile is missing (empty feed returned)

---

## 2. Canonical Eligibility Predicate (Pure Function)

**Purpose:** Pure function that determines if a task is eligible for a user.

**This logic must exist once and be reused by:**
- Feed query (SQL filter)
- Task detail prefetch (eligibility check)
- Apply endpoint (defense-in-depth)

**Function Signature:**
```typescript
function isEligible(
  task: Task,
  capabilityProfile: CapabilityProfile
): boolean
```

**Eligibility Predicate (Authoritative):**
```typescript
function isEligible(
  task: Task,
  capabilityProfile: CapabilityProfile
): boolean {
  // Rule 1: Location state must match
  if (capabilityProfile.location_state !== task.location_state) {
    return false;
  }

  // Rule 2: Trade must be verified (if trade required)
  if (task.required_trade) {
    const hasVerifiedTrade = capabilityProfile.verified_trades.some(
      vt => vt.trade === task.required_trade
    );
    if (!hasVerifiedTrade) {
      return false;
    }
  }

  // Rule 3: Trust tier must be sufficient
  if (!hasSufficientTrustTier(capabilityProfile.trust_tier, task.required_trust_tier)) {
    return false;
  }

  // Rule 4: Insurance must be valid (if insurance required)
  if (task.insurance_required && !capabilityProfile.insurance_valid) {
    return false;
  }

  // Rule 5: Background check must be valid (if background check required)
  if (task.background_check_required && !capabilityProfile.background_check_valid) {
    return false;
  }

  // Rule 6: Task must be open (status = 'posted')
  if (task.status !== 'posted') {
    return false;
  }

  // Rule 7: Task must not be assigned
  if (task.assigned_to !== null) {
    return false;
  }

  // All checks passed
  return true;
}

function hasSufficientTrustTier(
  userTier: TrustTier,
  requiredTier: TrustTier
): boolean {
  // Trust tier hierarchy: 1 (ROOKIE) < 2 (VERIFIED) < 3 (TRUSTED) < 4 (ELITE)
  // Both are integers, direct comparison works
  return userTier >= requiredTier;
}
```

**Properties:**
- **Side-effect free:** No database queries, no mutations
- **Deterministic:** Same inputs → same output
- **Test-covered:** Unit tests for all branches
- **Pure function:** No external dependencies

**Test Coverage (Required):**
```typescript
describe('isEligible', () => {
  it('returns false if location state mismatch', () => {
    const task = { location_state: 'CA', ... };
    const profile = { location_state: 'WA', ... };
    expect(isEligible(task, profile)).toBe(false);
  });

  it('returns false if trade not verified', () => {
    const task = { required_trade: 'electrician', ... };
    const profile = { verified_trades: [], ... };
    expect(isEligible(task, profile)).toBe(false);
  });

  it('returns false if trust tier insufficient', () => {
    const task = { required_trust_tier: 3, ... };  // TRUSTED
    const profile = { trust_tier: 1, ... };  // ROOKIE
    expect(isEligible(task, profile)).toBe(false);
  });

  it('returns false if insurance required but invalid', () => {
    const task = { insurance_required: true, ... };
    const profile = { insurance_valid: false, ... };
    expect(isEligible(task, profile)).toBe(false);
  });

  it('returns false if background check required but invalid', () => {
    const task = { background_check_required: true, ... };
    const profile = { background_check_valid: false, ... };
    expect(isEligible(task, profile)).toBe(false);
  });

  it('returns true if all checks pass', () => {
    const task = { /* all requirements met */ };
    const profile = { /* all capabilities present */ };
    expect(isEligible(task, profile)).toBe(true);
  });
});
```

**Why This Must Exist Once:**
- Prevents code duplication (single source of truth)
- Ensures consistent eligibility logic across endpoints
- Makes testing easier (one function to test)
- Enables reuse (feed, task detail, apply endpoint)

---

## 3. Feed Query Strategy (Do Not Over-Optimize Early)

### Principle

**Filter in SQL first, refine in code only if unavoidable.**

Do not fetch ineligible tasks "just in case."

**Why:**
- Performance: SQL filtering is faster than application-level filtering
- Scalability: Reduces data transfer and memory usage
- Correctness: Ensures no ineligible tasks leak through
- Simplicity: Single source of truth (SQL query)

**Anti-Patterns (Forbidden):**
- ❌ Fetch all tasks, filter in application code
- ❌ Fetch tasks "just in case" and filter later
- ❌ Use LEFT JOINs and post-filter results

**Correct Pattern:**
- ✅ Filter in SQL (INNER JOINs only)
- ✅ Only fetch eligible tasks
- ✅ If it doesn't pass SQL, it doesn't exist

---

## 4. Base SQL Query (PostgreSQL)

**Purpose:** SQL query that filters tasks by eligibility at database level.

**Assumes:**
- `tasks` table (immutable requirements)
- `capability_profiles` table (latest snapshot only)
- `verified_trades` table (join table for verified trades)

**Base SQL Query:**
```sql
SELECT 
  t.task_id,
  t.title,
  t.description,
  t.location_state,
  t.location_city,
  t.location_address,
  t.urgency,
  t.required_trade,
  t.required_trust_tier,
  t.insurance_required,
  t.background_check_required,
  t.created_at,
  t.status
FROM tasks t
INNER JOIN capability_profiles cp
  ON cp.user_id = :user_id
LEFT JOIN verified_trades vt
  ON vt.profile_id = cp.profile_id
  AND vt.trade = t.required_trade
WHERE
  -- Rule 1: Location state must match
  t.location_state = cp.location_state

  -- Rule 2: Trade must be verified (if trade required)
  AND (
    t.required_trade IS NULL
    OR vt.trade IS NOT NULL
  )

  -- Rule 3: Trust tier must be sufficient (both are INTEGER, direct comparison)
  AND cp.trust_tier >= t.required_trust_tier

  -- Rule 4: Insurance must be valid (if insurance required)
  AND (
    t.insurance_required = FALSE
    OR cp.insurance_valid = TRUE
  )

  -- Rule 5: Background check must be valid (if background check required)
  AND (
    t.background_check_required = FALSE
    OR cp.background_check_valid = TRUE
  )

  -- Rule 6: Task must be open
  AND t.status = 'posted'

  -- Rule 7: Task must not be assigned
  AND t.assigned_to IS NULL

ORDER BY t.created_at DESC, t.task_id DESC
LIMIT :limit;
```

**Rules:**
1. **No LEFT JOINs (except verified_trades):**
   - INNER JOIN with capability_profiles (required)
   - LEFT JOIN with verified_trades (optional, for trade matching)

2. **No post-filtering hacks:**
   - All eligibility checks are in SQL WHERE clause
   - No application-level filtering after SQL query

3. **If it doesn't pass SQL, it doesn't exist:**
   - SQL query is the only filter
   - Application receives only eligible tasks

**Optimization Notes:**
- Indexes on `tasks.status`, `tasks.location_state`, `tasks.required_trade`
- Indexes on `capability_profiles.user_id`, `verified_trades.profile_id`
- Query planner should use indexes (EXPLAIN ANALYZE)

---

## 5. Pagination (Cursor-Based Only)

**Purpose:** Cursor-based pagination to handle dynamic feeds (task creation, expiry, eligibility changes).

**Why Cursor-Based (Not Offset-Based):**

**Problems with Offset Pagination:**
- Breaks when tasks are created between pages (duplicates/skips)
- Breaks when tasks expire between pages (gaps)
- Breaks when eligibility changes between pages (inconsistent results)

**Cursor-Based Solution:**
- Uses `created_at` + `task_id` as cursor (deterministic)
- Stable under task creation/expiry/eligibility changes
- No duplicates or gaps

**Cursor Fields:**
```typescript
interface PaginationCursor {
  created_at: string; // ISO 8601
  task_id: string; // UUID
}
```

**Cursor Encoding:**
```typescript
function encodeCursor(cursor: PaginationCursor): string {
  const data = `${cursor.created_at}:${cursor.task_id}`;
  return Buffer.from(data).toString('base64');
}

function decodeCursor(encoded: string): PaginationCursor {
  const data = Buffer.from(encoded, 'base64').toString('utf-8');
  const [created_at, task_id] = data.split(':');
  return { created_at, task_id };
}
```

**SQL Query with Cursor:**
```sql
-- ... (base query from Section 4) ...

AND (
  t.created_at < :cursor_created_at
  OR (
    t.created_at = :cursor_created_at
    AND t.task_id < :cursor_task_id
  )
)

ORDER BY t.created_at DESC, t.task_id DESC
LIMIT :limit;
```

**Response Format:**
```typescript
{
  tasks: Task[];
  pagination: {
    has_more: boolean;
    next_cursor?: string; // Encoded cursor, undefined if has_more = false
  };
}
```

**Cursor Must Be Opaque to Client:**
- Client cannot decode cursor (security)
- Client cannot manipulate cursor (correctness)
- Cursor is base64-encoded (not human-readable)

---

## 6. Feed Modes (Strictly Additive)

**Purpose:** Different feed modes for different use cases (normal, urgent, nearby).

**Feed Modes:**
- **Normal:** Standard feed (all eligible tasks)
- **Urgent:** Urgent/same-day tasks only
- **Nearby:** Geospatial filter (tasks within radius)

**Feed modes are strictly additive (do not bypass eligibility).**

### Normal Feed

**Query:** Base SQL query (Section 4)

**No additional constraints.**

---

### Urgent Feed

**Additional Constraints:**
```sql
-- ... (base query from Section 4) ...

AND t.urgency = 'immediate'
AND t.created_at > NOW() - INTERVAL '30 minutes'
```

**Behavioral Rules:**
- Urgent feed **never bypasses eligibility** (eligibility checks still apply)
- Urgent tasks are filtered by eligibility first, then by urgency
- Time window: Last 30 minutes (prevents stale urgent tasks)

---

### Nearby Feed

**Additional Constraints:**
```sql
-- ... (base query from Section 4) ...

AND ST_DWithin(
  t.location::geography,
  ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography,
  :radius_meters
)
```

**Behavioral Rules:**
- Geospatial constraint is applied **before** eligibility (SQL WHERE clause)
- Default radius: 10 miles (16 km)
- Maximum radius: 50 miles (80 km)
- Requires `location` input (latitude/longitude)

**PostGIS Extension Required:**
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

**Index for Performance:**
```sql
CREATE INDEX idx_tasks_location_gist ON tasks USING GIST (location);
```

---

## 7. Cache Strategy (Conservative, Correct)

**Purpose:** Cache feed results to reduce database load, while ensuring freshness.

**Cache Key:**
```
feed:{user_id}:{feed_mode}:{cursor_hash}
```

**Cache Key Generation:**
```typescript
function generateCacheKey(
  userId: string,
  feedMode: FeedMode,
  cursor?: string
): string {
  const cursorHash = cursor ? hashCursor(cursor) : 'initial';
  return `feed:${userId}:${feedMode}:${cursorHash}`;
}
```

**TTL (Time To Live):**
- **Normal feed:** 60 seconds
- **Urgent feed:** 15 seconds
- **Nearby feed:** 60 seconds

**Why Conservative TTL:**
- Freshness > cost (better to invalidate than show stale data)
- Eligibility can change rapidly (verification expiry, trust tier changes)
- Short TTL prevents stale eligibility states

**Cache Implementation (Redis):**
```typescript
async function getCachedFeed(
  cacheKey: string
): Promise<FeedResponse | null> {
  const cached = await redis.get(cacheKey);
  if (!cached) {
    return null;
  }
  return JSON.parse(cached) as FeedResponse;
}

async function setCachedFeed(
  cacheKey: string,
  feed: FeedResponse,
  ttl: number
): Promise<void> {
  await redis.setex(cacheKey, ttl, JSON.stringify(feed));
}
```

**Invalidation Triggers:**
```typescript
async function invalidateFeedCache(userId: string): Promise<void> {
  const patterns = [
    `feed:${userId}:normal:*`,
    `feed:${userId}:urgent:*`,
    `feed:${userId}:nearby:*`,
  ];

  for (const pattern of patterns) {
    const keys = await redis.keys(pattern);
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  }
}
```

**Invalidation Events:**
1. Capability profile recompute (verification state change)
2. Task created / closed (new tasks appear / tasks disappear)
3. Verification expiry (eligibility changes)

**Rule:**
> **If in doubt: invalidate. Freshness > cost.**

---

## 8. Defense-in-Depth (Non-Optional)

**Purpose:** Re-check eligibility on apply endpoint, even though feed is filtered.

**Why Defense-in-Depth:**
- Stale cache (cache may not reflect latest eligibility state)
- Race conditions (eligibility may change between feed load and apply)
- Malicious clients (clients may bypass feed and call apply directly)

**Apply Endpoint Re-Check:**
```typescript
async function applyToTask(
  userId: string,
  taskId: string
): Promise<ApplyResponse> {
  // 1. Load task and capability profile (latest, not cached)
  const task = await TaskRepository.findById(taskId);
  if (!task) {
    throw new Error('Task not found');
  }

  const profile = await getLatestCapabilityProfile(userId);

  // 2. Re-check eligibility (defense-in-depth)
  if (!isEligible(task, profile)) {
    throw new Error('You are not eligible for this task', { statusCode: 403 });
  }

  // 3. Check task is still open
  if (task.status !== 'posted') {
    throw new Error('Task is no longer available', { statusCode: 409 });
  }

  // 4. Check task is not already assigned
  if (task.assigned_to !== null) {
    throw new Error('Task is already assigned', { statusCode: 409 });
  }

  // 5. Assign task (atomic)
  await assignTask(taskId, userId);

  return {
    success: true,
    task_id: taskId,
    assigned_at: new Date().toISOString(),
  };
}
```

**This Protects Against:**
- Stale cache (re-fetches latest profile and task)
- Race conditions (checks task status before assignment)
- Malicious clients (re-checks eligibility before assignment)

**Behavioral Rules:**
- Apply endpoint always re-checks eligibility (no trust of feed cache)
- Apply endpoint loads latest data (not cached)
- Apply endpoint uses same `isEligible` function (consistency)

---

## 9. Forbidden Patterns (Never Allow)

### ❌ Fetch All Tasks Then Filter in JS

**Why Forbidden:**
- Performance: Wastes bandwidth and memory
- Scalability: Doesn't scale (fetching all tasks is expensive)
- Correctness: Risk of ineligible tasks leaking through

**Correct Pattern:**
- ✅ Filter in SQL (see Section 4)

---

### ❌ "Show But Disable" UI

**Why Forbidden:**
- UX: Confusing (why can't I apply?)
- Trust: Erodes trust ("why was I shown this if I can't do it?")
- Rejection: Users experience rejection (violates core law)

**Correct Pattern:**
- ✅ Don't show ineligible tasks (filter before render)

---

### ❌ "Apply Anyway" Flows

**Why Forbidden:**
- Eligibility: Bypasses eligibility enforcement
- Trust: Users can apply to tasks they're not qualified for
- Legal: Liability risk (unqualified workers)

**Correct Pattern:**
- ✅ Apply endpoint returns 403 if not eligible (see Section 8)

---

### ❌ Upsell Inside the Feed

**Why Forbidden:**
- UX: Disrupts feed experience
- Trust: Feels manipulative ("pay to unlock")
- Eligibility: Upsells don't belong in feed (belong in Settings)

**Correct Pattern:**
- ✅ Feed shows only eligible tasks (no upsells)
- ✅ Settings shows upgrade paths (see upgrade signal contract)

---

### ❌ Trust Logic in the Client

**Why Forbidden:**
- Security: Client can be manipulated
- Correctness: Client logic may diverge from server logic
- Trust: Users cannot trust client-side eligibility

**Correct Pattern:**
- ✅ All eligibility logic on server (see Section 2)
- ✅ Client receives pre-filtered tasks (see Section 1)

**Any of these reintroduce rejection UX and trust leakage.**

---

## 10. Test Matrix (You Must Write These)

**Purpose:** Comprehensive test coverage to ensure feed resolver correctness.

### Required Tests

**1. User with No Verified Trades → Sees Only Low-Risk Tasks**
```typescript
it('filters out trade-required tasks if user has no verified trades', async () => {
  const user = await createUser({ verified_trades: [] });
  const lowRiskTask = await createTask({ required_trade: null });
  const tradeTask = await createTask({ required_trade: 'electrician' });

  const feed = await getFeed(user.id, { feed_mode: 'normal' });

  expect(feed.tasks).toContainEqual(lowRiskTask);
  expect(feed.tasks).not.toContainEqual(tradeTask);
});
```

**2. License Expires → Task Disappears Within TTL**
```typescript
it('removes task from feed when license expires', async () => {
  const user = await createUser({ 
    verified_trades: [{ trade: 'electrician', expires_at: '2025-01-01' }] 
  });
  const task = await createTask({ required_trade: 'electrician' });

  // Feed should include task (license valid)
  const feedBefore = await getFeed(user.id);
  expect(feedBefore.tasks).toContainEqual(task);

  // Expire license
  await expireLicense(user.id, 'electrician');
  await recomputeCapabilityProfile(user.id);

  // Feed should exclude task (license expired, within TTL)
  await wait(65); // Wait for cache TTL (60s)
  const feedAfter = await getFeed(user.id);
  expect(feedAfter.tasks).not.toContainEqual(task);
});
```

**3. Trust Tier Downgrade → Feed Shrinks**
```typescript
it('removes high-tier tasks when trust tier downgrades', async () => {
  const user = await createUser({ trust_tier: 3 });  // TRUSTED
  const highTierTask = await createTask({ required_trust_tier: 3 });  // TRUSTED
  const lowTierTask = await createTask({ required_trust_tier: 1 });  // ROOKIE

  // Feed should include both tasks (tier 3 >= 3 and 1)
  const feedBefore = await getFeed(user.id);
  expect(feedBefore.tasks).toContainEqual(highTierTask);
  expect(feedBefore.tasks).toContainEqual(lowTierTask);

  // Downgrade trust tier
  await downgradeTrustTier(user.id, 1);  // ROOKIE
  await recomputeCapabilityProfile(user.id);
  await invalidateFeedCache(user.id);

  // Feed should exclude high-tier task (tier 1 < 3)
  const feedAfter = await getFeed(user.id);
  expect(feedAfter.tasks).not.toContainEqual(highTierTask);
  expect(feedAfter.tasks).toContainEqual(lowTierTask);
});
```

**4. Insurance Invalid → High-Risk Tasks Removed**
```typescript
it('removes insurance-required tasks when insurance invalid', async () => {
  const user = await createUser({ insurance_valid: true });
  const insuranceTask = await createTask({ insurance_required: true });
  const noInsuranceTask = await createTask({ insurance_required: false });

  // Feed should include both tasks (insurance valid)
  const feedBefore = await getFeed(user.id);
  expect(feedBefore.tasks).toContainEqual(insuranceTask);
  expect(feedBefore.tasks).toContainEqual(noInsuranceTask);

  // Invalidate insurance
  await invalidateInsurance(user.id);
  await recomputeCapabilityProfile(user.id);
  await invalidateFeedCache(user.id);

  // Feed should exclude insurance-required task
  const feedAfter = await getFeed(user.id);
  expect(feedAfter.tasks).not.toContainEqual(insuranceTask);
  expect(feedAfter.tasks).toContainEqual(noInsuranceTask);
});
```

**5. Background Check Missing → Critical Tasks Never Appear**
```typescript
it('excludes critical tasks if background check invalid', async () => {
  const user = await createUser({ background_check_valid: false });
  const criticalTask = await createTask({ background_check_required: true });
  const nonCriticalTask = await createTask({ background_check_required: false });

  const feed = await getFeed(user.id);

  expect(feed.tasks).not.toContainEqual(criticalTask);
  expect(feed.tasks).toContainEqual(nonCriticalTask);
});
```

**6. Task Edit Attempt → Rejected (Immutable Requirements)**
```typescript
it('rejects task edit if requirements would change', async () => {
  const task = await createTask({ required_trade: 'electrician' });

  await expect(
    updateTask(task.id, { required_trade: 'plumber' })
  ).rejects.toThrow('Task requirements cannot be changed');
});
```

**If these tests pass, your feed is correct.**

---

## 11. Operational Guarantees You Now Have

### Zero Unqualified Applications

**Guarantee:** Users can only apply to tasks they're eligible for.

**Evidence:**
- Feed query filters by eligibility (SQL WHERE clause)
- Apply endpoint re-checks eligibility (defense-in-depth)
- No "apply anyway" flows (forbidden pattern)

---

### Zero "Why Was I Rejected?" Tickets

**Guarantee:** Users never see tasks they can't do, so they never experience rejection.

**Evidence:**
- Feed shows only eligible tasks (filtered before render)
- No disabled buttons or upsells (forbidden pattern)
- Settings explains eligibility (upgrade paths visible)

---

### Clean Monetization Separation

**Guarantee:** Payments don't affect feed eligibility (eligibility is derived, not purchased).

**Evidence:**
- Feed query uses capability profile (not payment status)
- Payments unlock verification processing (not capability profile)
- Upgrade paths shown in Settings (not feed)

---

### Deterministic Behavior Under Load

**Guarantee:** Feed query produces consistent results under high load.

**Evidence:**
- Eligibility predicate is deterministic (pure function)
- SQL query is deterministic (same inputs → same output)
- Cache TTL ensures freshness (short TTL, frequent invalidation)

---

### Legal Defensibility

**Guarantee:** System can demonstrate that only qualified users saw tasks.

**Evidence:**
- Eligibility predicate is testable (pure function)
- SQL query is auditable (can be reviewed)
- Audit logs record all eligibility checks (if needed)

**This is how marketplaces avoid entropy.**

---

## This Feed Query & Eligibility Resolver is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this resolver exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
