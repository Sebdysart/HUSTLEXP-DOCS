# Capability Onboarding & Feed Filtering Architecture — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This architecture prevents trust leaks, eliminates rejection friction, and ensures legal compliance. It enforces "users do not apply to gigs — gigs appear only if the user is eligible" as the fundamental rule. This is how serious marketplaces prevent unsafe matching, regulatory ambiguity, and trust erosion.

---

## Core Rule (Non-Negotiable)

**Users do not apply to gigs.**
**Gigs appear only if the user is eligible.**

Everything else is implementation detail.

---

## System Architecture (Authoritative Order)

**Onboarding → Capability Profile → Eligibility Resolver → Feed Filter**

If this order is violated, trust leaks.

---

## 1. Personalized Onboarding (Capability Declaration Phase)

### Purpose

This is **not preference onboarding**. This is **capability onboarding**.

The goal is to establish **claims** that unlock **verification paths**, not immediate gig access.

### During Onboarding, User Declares:

#### Role Selection (Required, First Step)
- `role`: `'hustler'` | `'poster'` | `'both'`
- Single choice, cannot be skipped
- Determines which flows are available

#### Capability Claims (Required for Hustlers)
- `claimed_trades`: `string[]` — Trades the user claims to be qualified for
  - Examples: `["electrician", "plumber", "carpenter"]`
  - Must select at least one
  - Cannot proceed without selection
- `willingness_flags`: `WillingnessFlags` — Risk and work type flags
  - `in_home_work: boolean` — Willing to work inside residences
  - `high_risk_tasks: boolean` — Willing to accept high-risk tasks
  - `urgent_jobs: boolean` — Willing to accept urgent/instant tasks
- `location_state: string` — State where user operates (required)
- `location_city?: string` — City (optional, used for proximity matching)

#### Verification Preferences (Optional)
- `insurance_preference?: 'required' | 'optional' | 'none'` — Insurance requirement preference

### Behavioral Rules Enforced by UI

- ❌ Cannot skip capability claims (required for hustlers)
- ❌ Cannot proceed without location state (required)
- ❌ Cannot enable willingness flags without understanding consequences (clear explanations shown)
- ❌ Cannot see tasks until verification paths are unlocked

### Backend Contract

**Endpoint:** `POST /api/onboarding/capability-claims`

**Request:**
```typescript
{
  role: 'hustler' | 'poster' | 'both';
  claimed_trades?: string[]; // Required if role includes 'hustler'
  willingness_flags?: {
    in_home_work: boolean;
    high_risk_tasks: boolean;
    urgent_jobs: boolean;
  };
  location_state: string;
  location_city?: string;
  insurance_preference?: 'required' | 'optional' | 'none';
}
```

**Response:**
```typescript
{
  user_id: string;
  capability_profile_id: string;
  verification_paths_unlocked: VerificationPath[];
  onboarding_complete: boolean;
}
```

**VerificationPath:**
```typescript
{
  trade: string;
  status: 'pending' | 'in_progress' | 'required';
  requirements: string[];
  estimated_duration?: string;
}
```

### What This Prevents

- Users claiming capabilities they don't have (claim → verification gate)
- Users seeing tasks they can't legally do (feed filtered before display)
- Trust leaks from "why was I rejected?" support tickets (never rejected, just not shown)
- Regulatory ambiguity (capability profile enforces legal requirements)

---

## 2. Capability Profile (Server-Side Object)

### Purpose

This is the **single source of truth** for user eligibility.

It is **derived**, not editable by the client.

It is **recomputed** on verification events and **invalidated** on expiry.

### Schema (Authoritative)

```typescript
interface CapabilityProfile {
  // Identity
  user_id: string;
  profile_id: string;
  updated_at: string; // ISO 8601
  expires_at?: { // Optional expiry map
    [key: string]: string; // e.g., "electrician_license": "2026-05-01"
  };

  // Verified Capabilities (Derived from Verifications)
  verified_trades: VerifiedTrade[];

  // Trust & Risk
  trust_tier: TrustTier; // A | B | C | D
  trust_tier_updated_at: string;
  risk_clearance: RiskLevel[]; // ["low", "medium"] | ["low", "medium", "high"]

  // Insurance & Credentials
  insurance_valid: boolean;
  insurance_expires_at?: string;
  background_check_valid: boolean;
  background_check_expires_at?: string;

  // Location & Willingness (From Onboarding Claims)
  location_state: string;
  location_city?: string;
  willingness_flags: {
    in_home_work: boolean;
    high_risk_tasks: boolean;
    urgent_jobs: boolean;
  };

  // Verification Status
  verification_status: {
    [trade: string]: 'not_started' | 'pending' | 'in_progress' | 'verified' | 'expired' | 'rejected';
  };
}

interface VerifiedTrade {
  trade: string;
  verified_at: string;
  expires_at?: string;
  verification_method: 'license_scan' | 'certification' | 'portfolio' | 'test' | 'manual_review';
  verification_id: string; // References verification record
}
```

### Invariants (Enforced by Database)

1. **No unverified trades appear in `verified_trades`**
   - If `verification_status[trade] !== 'verified'`, trade is excluded from `verified_trades`

2. **Expired credentials invalidate capabilities**
   - If `expires_at[trade] < now()`, trade is removed from `verified_trades`
   - `verification_status[trade]` is set to `'expired'`

3. **Trust tier determines risk clearance**
   - `trust_tier === 1` (ROOKIE) → `risk_clearance: ['low']`
   - `trust_tier === 2` (VERIFIED) → `risk_clearance: ['low', 'medium']`
   - `trust_tier === 3` (TRUSTED) → `risk_clearance: ['low', 'medium']`
   - `trust_tier === 4` (ELITE) → `risk_clearance: ['low', 'medium', 'high']`

4. **Insurance requirement gates in-home tasks**
   - If `insurance_required === true` and `insurance_valid === false`, in-home tasks are excluded

### Recomputation Triggers

The capability profile is **recomputed** when:
- Verification status changes (approved/rejected/expired)
- Trust tier changes (promotion/demotion)
- Insurance status changes (added/expired)
- Background check status changes (added/expired)
- Credential expiry is detected (scheduled check)

### Recomputation Contract

**Trigger:** Verification event, trust tier change, credential expiry

**Process:**
1. Load current capability profile
2. Re-evaluate `verified_trades` from verification records
3. Re-evaluate `risk_clearance` from trust tier
4. Re-evaluate `insurance_valid` from insurance records
5. Update `expires_at` map from credential expiries
6. Persist updated profile
7. Invalidate user feed cache (if exists)

**Atomicity:** Profile update is atomic (transaction-scoped)

**Consistency:** Profile is consistent with verification records (foreign key constraints)

---

## 3. Verification Gates (Settings UI States)

### Purpose

Settings reflect **truth**, not desire.

Users see their capability status, not preference toggles.

### Settings → Work Eligibility UI States

#### Trade Verification Status

For each trade in `claimed_trades`:

**Not Started:**
```
State: 'not_started'
Display:
  - Trade name: "Electrician"
  - Badge: "Not Verified" (gray, muted)
  - Action: "Start Verification" button (enabled)
  - Hint: "Verify to unlock electrician tasks"
```

**In Progress:**
```
State: 'in_progress'
Display:
  - Trade name: "Electrician"
  - Badge: "Verification In Progress" (amber, pulsing)
  - Action: "View Status" button (enabled)
  - Hint: "Estimated completion: 2-3 business days"
  - Progress indicator: (if applicable)
```

**Verified:**
```
State: 'verified'
Display:
  - Trade name: "Electrician"
  - Badge: "Verified" (green, checkmark icon)
  - Expiry: "Expires: May 1, 2026" (if applicable)
  - Action: "Renew" button (shown if expiry < 30 days)
  - Hint: None (status is clear)
```

**Expired:**
```
State: 'expired'
Display:
  - Trade name: "Electrician"
  - Badge: "Expired" (red, warning icon)
  - Expiry: "Expired: May 1, 2026"
  - Action: "Renew Verification" button (enabled, prominent)
  - Hint: "This trade is no longer available. Renew to restore access."
```

**Rejected:**
```
State: 'rejected'
Display:
  - Trade name: "Electrician"
  - Badge: "Verification Rejected" (red, error icon)
  - Action: "Appeal" button (if appeals allowed) or "Start New Verification" button
  - Hint: "Reason: [specific reason from verification record]"
  - Support link: "Contact Support" (de-emphasized)
```

#### Willingness Flags (Read-Write, But Gated)

**Enabled State (if eligibility met):**
```
Flag: in_home_work
Display:
  - Label: "In-Home Work"
  - Toggle: Enabled (user can toggle)
  - Hint: "Accept tasks inside customer residences"
  - Warning: "Requires valid insurance" (if insurance required)
```

**Disabled State (if eligibility not met):**
```
Flag: in_home_work
Display:
  - Label: "In-Home Work"
  - Toggle: Disabled (user cannot toggle)
  - Hint: "Requires valid insurance"
  - Action: "Add Insurance" button (if no insurance) or "Renew Insurance" button (if expired)
  - Explanation: "Insurance is required for in-home tasks"
```

#### Trust Tier (Read-Only)

**Current Tier Display:**
```
Label: "Trust Tier"
Value: "Verified (Tier B)"
Badge: Current tier color/icon
Link: "View Trust Tier Ladder" (navigates to ladder screen)
Hint: "Tier determines available risk levels"
```

#### Insurance Status

**Valid:**
```
Label: "Insurance"
Status: "Valid" (green)
Expiry: "Expires: Dec 31, 2026" (if applicable)
Action: "View Details" button
```

**Invalid/Expired:**
```
Label: "Insurance"
Status: "Not Valid" or "Expired" (red)
Expiry: "Expired: May 1, 2026"
Action: "Add Insurance" or "Renew Insurance" button (prominent)
Warning: "In-home tasks require valid insurance"
```

### Behavioral Rules Enforced by UI

- ❌ Cannot enable willingness flags without meeting eligibility (toggle disabled, action button shown)
- ❌ Cannot toggle trade verification status (read-only, action buttons for renewal/appeal)
- ❌ Cannot edit trust tier (read-only, link to ladder screen)
- ❌ No "request exception" or "enable anyway" buttons (settings reflect truth)
- ❌ No hidden states (all eligibility requirements are visible)

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response:**
```typescript
{
  capability_profile: CapabilityProfile; // Current profile
  trades: TradeVerificationStatus[];
  willingness_flags: {
    in_home_work: { enabled: boolean; can_toggle: boolean; requirement?: string };
    high_risk_tasks: { enabled: boolean; can_toggle: boolean; requirement?: string };
    urgent_jobs: { enabled: boolean; can_toggle: boolean; requirement?: string };
  };
  trust_tier: {
    current: TrustTier;
    next?: TrustTier;
    progress?: { current: number; target: number };
  };
  insurance: {
    valid: boolean;
    expires_at?: string;
    requirement: 'required' | 'optional' | 'none';
  };
}
```

---

## 4. Task Definition (Requirements Declared)

### Purpose

Every task has **explicit requirements** that map directly to capability profile fields.

No task is "generic" once it crosses risk.

### Schema (Authoritative)

```typescript
interface TaskRequirements {
  // Required Trade
  required_trade: string; // Must match `verified_trades[].trade`

  // Trust & Risk
  required_trust_tier: TrustTier; // Minimum trust tier required
  risk_level: RiskLevel; // 'low' | 'medium' | 'high'

  // Insurance & Credentials
  insurance_required: boolean; // If true, requires `insurance_valid === true`
  background_check_required: boolean; // If true, requires `background_check_valid === true`

  // Location (Matching)
  location_state: string; // Must match user's `location_state`
  location_city?: string; // Optional, used for proximity matching
  location_proximity_required?: number; // Miles from user location

  // Willingness Flags (Must Match)
  requires_in_home: boolean; // If true, requires `willingness_flags.in_home_work === true`
  requires_high_risk_clearance: boolean; // If true, requires `risk_clearance.includes(risk_level)`

  // Urgency (If applicable)
  instant_mode: boolean; // If true, requires `willingness_flags.urgent_jobs === true`
}
```

### Task Definition Contract

**Endpoint:** `POST /api/tasks` (Poster creates task)

**Validation Rules:**
1. `required_trade` must exist in system trade list
2. `required_trust_tier` must be valid (`A | B | C | D`)
3. `risk_level` must be valid (`low | medium | high`)
4. If `insurance_required === true`, task must have `requires_in_home === true` or `risk_level === 'high'`
5. If `requires_high_risk_clearance === true`, `risk_level` must be `'medium'` or `'high'`
6. If `instant_mode === true`, `requires_high_risk_clearance === false` (instant tasks are low-medium risk only)

**Task Record (Stored):**
```typescript
interface Task {
  task_id: string;
  requirements: TaskRequirements; // Immutable once posted
  created_at: string;
  posted_by: string;
  // ... other task fields
}
```

### What This Enforces

- Tasks have explicit eligibility gates (no ambiguity)
- Risk levels are enforced (no unsafe matching)
- Legal requirements are encoded (regulatory compliance)
- Matching is deterministic (same requirements → same eligible users)

---

## 5. Feed Construction (Eligibility-Resolved Query)

### Purpose

The feed is **not a list of all tasks**.

It is a **join between tasks and eligibility**.

If the join fails, the task does not appear.

### Feed Query Contract (Authoritative)

**Endpoint:** `GET /api/tasks/feed`

**Query Parameters:**
```typescript
{
  user_id: string; // From auth token
  location_state?: string; // Optional override
  location_city?: string; // Optional override
  limit?: number; // Default: 50
  offset?: number; // Default: 0
}
```

**Backend Logic (Pseudocode):**
```typescript
async function getFeed(userId: string, params: FeedParams): Promise<Task[]> {
  // 1. Load capability profile (single source of truth)
  const profile = await getCapabilityProfile(userId);
  if (!profile) {
    throw new Error('Capability profile not found. Complete onboarding first.');
  }

  // 2. Build eligibility filter (derived from profile)
  const eligibilityFilter = {
    // Trade matching
    required_trade: { $in: profile.verified_trades.map(t => t.trade) },

    // Trust tier matching
    required_trust_tier: { $lte: profile.trust_tier }, // User tier >= required tier

    // Risk clearance matching
    risk_level: { $in: profile.risk_clearance },

    // Insurance matching
    ...(profile.insurance_valid === false
      ? { insurance_required: false } // Exclude tasks requiring insurance
      : {}),

    // Background check matching
    ...(profile.background_check_valid === false
      ? { background_check_required: false }
      : {}),

    // Location matching
    location_state: profile.location_state,
    ...(profile.location_city
      ? { location_city: profile.location_city }
      : {}),

    // Willingness flags matching
    ...(profile.willingness_flags.in_home_work === false
      ? { requires_in_home: false }
      : {}),

    ...(profile.willingness_flags.high_risk_tasks === false
      ? { requires_high_risk_clearance: false }
      : {}),

    ...(profile.willingness_flags.urgent_jobs === false
      ? { instant_mode: false }
      : {}),

    // Task status
    status: 'posted', // Only show posted tasks
    assigned_to: null, // Only show unassigned tasks
  };

  // 3. Query tasks with eligibility filter
  const tasks = await TaskRepository.find(eligibilityFilter, {
    limit: params.limit || 50,
    offset: params.offset || 0,
    orderBy: 'created_at DESC', // Newest first
  });

  // 4. Return tasks (no eligibility information exposed)
  return tasks.map(task => ({
    ...task,
    // Do not expose eligibility reason or requirements mismatch
    // User only sees tasks they can accept
  }));
}
```

### Response Contract

**Success Response:**
```typescript
{
  tasks: Task[];
  total: number; // Total eligible tasks (for pagination)
  has_more: boolean;
}
```

**Empty Feed Response:**
```typescript
{
  tasks: [];
  total: 0;
  has_more: false;
}
```

### Behavioral Rules Enforced by Backend

- ❌ No disabled task cards (tasks not shown if ineligible)
- ❌ No upsell prompts in feed (settings is the place for eligibility)
- ❌ No eligibility mismatch explanations in feed (clean feed, settings explains status)
- ❌ No "you were rejected" messaging (users never rejected, just not shown)
- ❌ No task requirements visible in feed (feed is clean, task detail shows requirements)

### What This Prevents

- Users seeing tasks they can't legally do (feed filtered before display)
- "Why was I rejected?" support tickets (never rejected, just not shown)
- Trust erosion from failed attempts (no failed attempts, only successful matches)
- Screenshots of unsafe gigs (unsafe gigs don't appear for ineligible users)
- Regulatory ambiguity (capability profile enforces legal requirements)

---

## 6. Expiry & Revocation (Silent but Ruthless)

### Purpose

When credentials expire, capabilities invalidate immediately.

No warnings in the feed. Only clear alerts in Settings.

This is how serious systems behave.

### Expiry Detection

**Scheduled Check (Cron):**
```typescript
// Run every hour
async function checkCredentialExpiry() {
  const now = new Date();

  // Find profiles with expired credentials
  const expiredProfiles = await CapabilityProfileRepository.find({
    $or: [
      { 'expires_at.electrician_license': { $lt: now } },
      { 'expires_at.plumber_license': { $lt: now } },
      { 'insurance_expires_at': { $lt: now } },
      { 'background_check_expires_at': { $lt: now } },
    ],
  });

  // Recompute profiles (removes expired trades, invalidates insurance)
  for (const profile of expiredProfiles) {
    await recomputeCapabilityProfile(profile.user_id);
  }

  // Invalidate feed cache for affected users
  await invalidateFeedCache(expiredProfiles.map(p => p.user_id));
}
```

### User Experience on Expiry

**Feed:**
- Tasks disappear immediately (no warning, no disabled cards)
- Feed shows empty state or "no tasks available" (if applicable)

**Settings:**
- Expired trade shows "Expired" badge (red, prominent)
- Expired insurance shows "Expired" status (red, prominent)
- Clear renewal actions shown (no ambiguity)

**Notification (Optional):**
- Push notification: "Your electrician license has expired. Renew to restore access."
- Links to Settings → Work Eligibility → [Trade] → Renew button

### Recomputation on Expiry

**Process:**
1. Detect expiry (scheduled check or manual verification)
2. Update `verification_status[trade] = 'expired'`
3. Remove trade from `verified_trades` (if expired)
4. Set `insurance_valid = false` (if insurance expired)
5. Recompute `risk_clearance` (if trust tier affected)
6. Update `expires_at` map (remove expired entries)
7. Persist updated profile
8. Invalidate feed cache

**Atomicity:** Profile update is atomic (transaction-scoped)

---

## 7. Failure Modes Avoided

### User Cannot Apply to Jobs They Can't Legally Do

**How:** Feed filtered by capability profile. Ineligible tasks never appear.

**Evidence:** Task requirements are checked against profile before feed query. If match fails, task is excluded.

### No "Why Was I Rejected?" Support Tickets

**How:** Users never rejected. Tasks simply don't appear.

**Evidence:** Feed query joins tasks with capability profile. No rejection event exists.

### No Trust Erosion from Posters

**How:** Only eligible users can accept tasks. Poster confidence is high.

**Evidence:** Feed construction ensures only users meeting requirements see tasks. Acceptance implies eligibility.

### No Screenshots of Unsafe Gigs

**How:** Unsafe gigs don't appear for ineligible users.

**Evidence:** Risk level and trust tier matching prevent unsafe matching.

### No Regulatory Ambiguity

**How:** Capability profile enforces legal requirements. Task requirements are explicit.

**Evidence:** Insurance, background checks, and licenses are verified and enforced before task display.

---

## 8. Implementation Checklist (Authoritative)

### Phase 1: Schema & Data Model

- [ ] Define `CapabilityProfile` schema (fields + invariants)
- [ ] Define `TaskRequirements` schema (fields + validation rules)
- [ ] Create database tables/migrations
- [ ] Add foreign key constraints (profile → verifications)
- [ ] Add check constraints (trust tier → risk clearance mapping)
- [ ] Add index on `verified_trades` (for feed query performance)

### Phase 2: Onboarding Flow

- [ ] Create onboarding UI screens (role selection, capability claims)
- [ ] Implement onboarding API endpoint (`POST /api/onboarding/capability-claims`)
- [ ] Create initial capability profile on onboarding completion
- [ ] Unlock verification paths based on claims
- [ ] Add onboarding completion check (gates feed access)

### Phase 3: Verification Integration

- [ ] Integrate verification system with capability profile
- [ ] Update profile when verification status changes
- [ ] Add expiry detection (scheduled check)
- [ ] Add profile recomputation on verification events
- [ ] Add profile recomputation on trust tier changes

### Phase 4: Settings UI

- [ ] Create Settings → Work Eligibility screen
- [ ] Display trade verification statuses
- [ ] Display willingness flags (gated by eligibility)
- [ ] Display trust tier (read-only, link to ladder)
- [ ] Display insurance status
- [ ] Add renewal/appeal actions (if applicable)

### Phase 5: Feed Query

- [ ] Implement feed query with eligibility filter
- [ ] Load capability profile for user
- [ ] Build eligibility filter from profile
- [ ] Query tasks with filter
- [ ] Return tasks (no eligibility information exposed)
- [ ] Add feed cache invalidation on profile updates

### Phase 6: Task Creation (Poster Side)

- [ ] Add task requirements to task creation form
- [ ] Validate requirements against system constraints
- [ ] Store requirements with task (immutable after posting)
- [ ] Add risk classification (automatic, not user choice)
- [ ] Add insurance/background check requirements (based on risk)

---

## 9. Invariants (Enforced by Database & Code)

### Database Constraints

1. **Capability Profile → User (1:1)**
   - `capability_profiles.user_id` → `users.id` (foreign key, unique)

2. **Verified Trades → Verification Records**
   - `capability_profiles.verified_trades[].verification_id` → `verifications.id` (foreign key, if applicable)

3. **Trust Tier → Risk Clearance (Immutable Mapping)**
   - `trust_tier = 1` (ROOKIE) → `risk_clearance` must contain only `['low']`
   - `trust_tier = 2` (VERIFIED) → `risk_clearance` must contain `['low', 'medium']`
   - `trust_tier = 3` (TRUSTED) → `risk_clearance` must contain `['low', 'medium']`
   - `trust_tier = 4` (ELITE) → `risk_clearance` must contain `['low', 'medium', 'high']`

4. **Task Requirements → Capability Profile Matching**
   - Feed query enforces matching (no database constraint, but query filter)

### Code Invariants

1. **No Unverified Trades in Profile**
   - If `verification_status[trade] !== 'verified'`, trade is excluded from `verified_trades` (recomputation enforces)

2. **Expired Credentials Invalidate Capabilities**
   - If `expires_at[trade] < now()`, trade is removed from `verified_trades` (recomputation enforces)

3. **Feed Only Shows Eligible Tasks**
   - Feed query filters by capability profile (query logic enforces)

4. **Settings Reflect Truth**
   - Settings UI reads from capability profile (no client-side toggles for verified status)

---

## 10. API Contract Summary (Quick Reference)

### Onboarding

**POST /api/onboarding/capability-claims**
- Creates capability profile
- Unlocks verification paths
- Returns profile ID

### Settings

**GET /api/settings/work-eligibility**
- Returns capability profile
- Returns trade verification statuses
- Returns willingness flags (with eligibility gates)
- Returns trust tier
- Returns insurance status

**PUT /api/settings/willingness-flags**
- Updates willingness flags (gated by eligibility)
- Returns updated profile

### Feed

**GET /api/tasks/feed**
- Returns eligible tasks (filtered by capability profile)
- Does not expose eligibility information
- Returns empty array if no eligible tasks

### Task Creation (Poster)

**POST /api/tasks**
- Validates task requirements
- Stores requirements with task (immutable after posting)
- Returns task ID

---

## 11. What This Completes

With this architecture locked:

- **Entire eligibility system** is deterministic (capability profile → feed filter)
- **Onboarding flow** establishes claims (not preferences)
- **Verification gates** are visible in Settings (not hidden)
- **Feed construction** prevents unsafe matching (eligibility-resolved query)
- **Expiry & revocation** are silent but ruthless (no warnings in feed, clear in Settings)
- **Trust leaks are prevented** (users never rejected, tasks never shown if ineligible)
- **Regulatory compliance** is enforced (capability profile encodes legal requirements)

---

## 12. This Architecture is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this architecture exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
