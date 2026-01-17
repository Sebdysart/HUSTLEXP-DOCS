# Settings: Verification & Eligibility — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This is the interpretability layer. If this is wrong, users feel confused even when the system is correct. If this is right, support volume collapses and upgrades feel obvious—not coercive. Settings explain reality. Settings do not change reality. No toggles that grant access. No "request exception." No temporary overrides. This completes the end-to-end eligibility system.

---

## Core Law (Non-Negotiable)

**Settings explain reality.**
**Settings do not change reality.**

If this law is violated, trust leaks, users feel confused, and support volume increases.

---

## Authority Boundary

**Read Source:** Capability Profile (Latest Snapshot)
- Settings reads from capability profile (derived, immutable)
- Settings reads from verification source tables (for metadata)
- Settings never reads from feed or task eligibility (feed is downstream)

**Write Targets:** Verification Pipelines Only
- Settings triggers verification submission (license, insurance, background check)
- Settings triggers renewal (expired credentials)
- Settings never writes to capability profile directly

**Never Write:** Capability Profile Directly
- Settings cannot mutate capability profile (derived, not editable)
- Settings cannot trigger recompute directly (recompute happens automatically)
- Settings cannot cache eligibility independently (capability profile is single source of truth)

**Settings is a control surface for initiating verification, not for eligibility.**

---

## Information Architecture (Single Entry Point)

**Settings → Work Eligibility**

This page is the **only place** users learn why they can/cannot see certain gigs.

**No Duplicate Indicators In:**
- Feed (feed shows only eligible tasks, no explanations)
- Task cards (task cards show task details, not eligibility)
- Apply flows (apply endpoint returns 403 if not eligible, no explanations)

**Why Single Entry Point:**
- Reduces cognitive load (one place to understand eligibility)
- Prevents confusion (consistent messaging)
- Enables deep linking (Settings → Work Eligibility → [Trade/Insurance])

**Navigation Path:**
```
Settings
  → Work Eligibility (main entry point)
    → Verify [Trade] (deep link to verification pipeline)
    → Add Insurance (deep link to insurance verification)
    → Start Background Check (deep link to background check)
```

---

## Page Structure (Fixed Order)

**The order is fixed. Do not reorder. Cognitive load matters.**

1. **Eligibility Summary (Read-Only)**
2. **Verified Trades**
3. **Insurance**
4. **Background Checks (Conditional)**
5. **Upgrade Opportunities (Computed)**
6. **System Notices (Expiry Only)**

---

## 1. Eligibility Summary (Top, Read-Only)

### Purpose

Provide high-level overview of eligibility without overwhelming detail.

### Displays (Derived Only)

**1. Current Trust Tier**
```typescript
{
  label: "Trust Tier",
  value: "Tier B (Verified)",
  badge: "B", // Color-coded badge
  description: "You can accept low and medium-risk gigs",
  read_only: true, // No edit action
}
```

**2. Active Risk Clearance**
```typescript
{
  label: "Risk Clearance",
  values: ["Low", "Medium"], // Derived from trust_tier
  description: "Based on your trust tier",
  read_only: true, // No edit action
}
```

**3. Work Location**
```typescript
{
  label: "Work Location",
  value: "Washington (WA)",
  description: "Licenses and insurance are state-scoped",
  read_only: true, // Cannot change here (must go to onboarding)
}
```

### Eligibility Breakdown

**What You're Eligible For:**
```typescript
const eligibleFor = computeEligibleCategories(profile);
// Returns: ["Low-risk gigs", "Medium-risk appliance installs"]
```

**What You're Not Eligible For:**
```typescript
const notEligibleFor = computeIneligibleCategories(profile);
// Returns: ["Electrical (license required)", "In-home care (background check required)"]
```

### Example Copy

**Display:**
```
You're eligible for:
• Low-risk gigs
• Medium-risk appliance installs

Not eligible for:
• Electrical (license required)
• In-home care (background check required)
```

**Rules:**
- No buttons here (read-only summary)
- No upsells (not persuasion, orientation)
- No estimates (only actual eligibility)

**This is orientation, not persuasion.**

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response:**
```typescript
{
  eligibility_summary: {
    trust_tier: {
      current: TrustTier; // 'A' | 'B' | 'C' | 'D'
      display: string; // "Tier B (Verified)"
      description: string; // "You can accept low and medium-risk gigs"
    };
    risk_clearance: RiskLevel[]; // ["low", "medium"]
    location: {
      state: string; // "WA"
      display: string; // "Washington (WA)"
    };
    eligible_for: string[]; // ["Low-risk gigs", "Medium-risk appliance installs"]
    not_eligible_for: string[]; // ["Electrical (license required)", ...]
  };
  // ... other sections (see below)
}
```

---

## 2. Verified Trades Section

### Purpose

Display verification status for all claimed or verified trades.

### Render Logic

**For each trade the user claimed or has ever verified:**

#### State A — Not Verified

**Display:**
```typescript
{
  trade: "electrician",
  status: "not_verified",
  badge: "❌ Not verified", // Red badge
  action: {
    label: "Verify license",
    type: "button", // Primary button
    destination: "/verifications/licenses/submit?trade=electrician"
  },
  subtext: "Required to see licensed gigs",
}
```

**UI:**
```
[Electrician] ❌ Not verified
[Verify license] ← Primary button
Required to see licensed gigs
```

**Behavioral Rules:**
- Button triggers verification submission (deep link to verification pipeline)
- No toggle to "enable" trade (verification is required)
- Subtext explains requirement clearly

---

#### State B — Pending

**Display:**
```typescript
{
  trade: "electrician",
  status: "pending",
  badge: "⏳ Verification in progress", // Amber badge
  action: null, // No action button
  subtext: "This usually takes under 2 hours",
  progress?: {
    current_step: string; // "Registry lookup"
    estimated_completion: string; // "2 hours"
  },
}
```

**UI:**
```
[Electrician] ⏳ Verification in progress
This usually takes under 2 hours
```

**Behavioral Rules:**
- No action button (verification in progress)
- Subtext sets expectations (time estimate)
- Progress indicator optional (if available from verification system)

---

#### State C — Verified

**Display:**
```typescript
{
  trade: "electrician",
  status: "verified",
  badge: "✅ Verified", // Green badge
  details: {
    state: "WA",
    license_number: "EL12345", // Partially masked: "EL****5"
    verified_at: "2025-01-15",
    expires_at?: "2026-05-01", // Optional
  },
  action: null, // No action (read-only)
}
```

**UI:**
```
[Electrician] ✅ Verified
State: WA | License: EL****5
Verified: Jan 15, 2025
Expires: May 1, 2026
```

**Behavioral Rules:**
- No action button (verification is complete)
- Details are read-only (cannot edit)
- Expiry date shown if applicable

---

#### State D — Expired

**Display:**
```typescript
{
  trade: "electrician",
  status: "expired",
  badge: "⚠️ Expired", // Red badge with warning icon
  details: {
    state: "WA",
    license_number: "EL12345",
    verified_at: "2025-01-15",
    expires_at: "2026-01-01", // Expired
  },
  action: {
    label: "Renew verification",
    type: "button", // Primary button
    destination: "/verifications/licenses/renew?trade=electrician"
  },
  subtext: "Expired credentials remove access immediately",
}
```

**UI:**
```
[Electrician] ⚠️ Expired
State: WA | License: EL****5
Expired: Jan 1, 2026
[Renew verification] ← Primary button
Expired credentials remove access immediately
```

**Behavioral Rules:**
- Button triggers renewal (deep link to verification pipeline)
- Subtext explains immediate impact (no grace period)
- No toggle to "re-enable" (renewal required)

---

### Hard Rule

> **There is no toggle to "enable" a trade.**

Verification status is truth. It cannot be toggled.

**Forbidden:**
- ❌ Enable/disable switches
- ❌ "Temporarily enable" checkboxes
- ❌ "Request exception" buttons

**Correct:**
- ✅ "Verify license" button (triggers verification)
- ✅ "Renew verification" button (triggers renewal)
- ✅ Read-only status badges (no edit actions)

---

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response (Verified Trades Section):**
```typescript
{
  verified_trades: Array<{
    trade: string;
    status: 'not_verified' | 'pending' | 'verified' | 'expired';
    badge: string; // Display badge text
    details?: {
      state?: string;
      license_number?: string; // Partially masked
      verified_at?: string;
      expires_at?: string;
    };
    action?: {
      label: string;
      type: 'button';
      destination: string; // Deep link to verification pipeline
    };
    subtext?: string;
    progress?: {
      current_step: string;
      estimated_completion: string;
    };
  }>;
}
```

---

## 3. Insurance Section (Conditional)

### Purpose

Display insurance status, only shown if user can use it.

### Conditional Display

**Shown only if:**
1. User has at least one verified trade
   - AND
2. That trade maps to risk levels requiring insurance (high or critical)

**If conditions not met:**
- Section is hidden (not shown)
- No "Add insurance" prompt (cannot use insurance without verified trade)

### States

#### ❌ Not on File

**Display:**
```typescript
{
  status: "not_on_file",
  badge: "❌ Not on file", // Red badge
  action: {
    label: "Add insurance",
    type: "button", // Primary button
    destination: "/verifications/insurance/submit"
  },
  subtext: "Required for in-home and high-risk gigs",
}
```

**UI:**
```
[Insurance] ❌ Not on file
[Add insurance] ← Primary button
Required for in-home and high-risk gigs
```

---

#### ⏳ Pending Review

**Display:**
```typescript
{
  status: "pending",
  badge: "⏳ Pending review", // Amber badge
  action: null, // No action
  subtext: "Review usually takes under 24 hours",
}
```

**UI:**
```
[Insurance] ⏳ Pending review
Review usually takes under 24 hours
```

---

#### ✅ Active

**Display:**
```typescript
{
  status: "verified",
  badge: "✅ Active", // Green badge
  details: {
    insurer_name?: string; // "State Farm"
    coverage_amount?: number; // 500000
    verified_at: string; // "2025-01-15"
    expires_at?: string; // "2026-01-01"
  },
  action: null, // No action (read-only)
}
```

**UI:**
```
[Insurance] ✅ Active
State Farm | $500,000 coverage
Verified: Jan 15, 2025
Expires: Jan 1, 2026
```

---

#### ⚠️ Expired

**Display:**
```typescript
{
  status: "expired",
  badge: "⚠️ Expired", // Red badge with warning icon
  details: {
    insurer_name?: string;
    expires_at: string; // Expired date
  },
  action: {
    label: "Renew insurance",
    type: "button", // Primary button
    destination: "/verifications/insurance/renew"
  },
  subtext: "Expired insurance removes access to in-home gigs immediately",
}
```

**UI:**
```
[Insurance] ⚠️ Expired
Expired: Jan 1, 2026
[Renew insurance] ← Primary button
Expired insurance removes access to in-home gigs immediately
```

---

### Rule

> **Insurance UI never appears for users who cannot use it.**

No confusion, no false hope.

**Enforcement:**
- Pre-check before rendering section (requires verified trade)
- Section hidden if conditions not met
- No "Add insurance" prompt if user has no verified trades

---

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response (Insurance Section):**
```typescript
{
  insurance: {
    visible: boolean; // True only if user has verified trade requiring insurance
    status?: 'not_on_file' | 'pending' | 'verified' | 'expired';
    badge?: string;
    details?: {
      insurer_name?: string;
      coverage_amount?: number;
      verified_at?: string;
      expires_at?: string;
    };
    action?: {
      label: string;
      type: 'button';
      destination: string;
    };
    subtext?: string;
  };
}
```

---

## 4. Background Checks (Critical Tasks Only)

### Purpose

Display background check status, only shown if user opted into critical tasks.

### Conditional Display

**Shown only if:**
1. User opted into critical tasks (`willingness_flags.high_risk_tasks === true`)
   - AND
2. Task categories require background checks (in-home care, vulnerable populations)

**If conditions not met:**
- Section is hidden (not shown)
- No "Start background check" prompt (cannot use without opt-in)

### States

#### ❌ Not Completed

**Display:**
```typescript
{
  status: "not_completed",
  badge: "❌ Not completed", // Red badge
  action: {
    label: "Start background check",
    type: "button", // Primary button
    destination: "/verifications/background-checks/initiate"
  },
  subtext: "Required for critical tasks (in-home care, vulnerable populations)",
}
```

**UI:**
```
[Background Check] ❌ Not completed
[Start background check] ← Primary button
Required for critical tasks (in-home care, vulnerable populations)
```

---

#### ⏳ Pending

**Display:**
```typescript
{
  status: "pending",
  badge: "⏳ Pending", // Amber badge
  action: null, // No action
  subtext: "Background checks typically take 2-3 business days",
  progress?: {
    provider: string; // "Checkr"
    current_step: string; // "Identity verification"
  },
}
```

**UI:**
```
[Background Check] ⏳ Pending
Checkr | Identity verification
Background checks typically take 2-3 business days
```

---

#### ✅ Verified

**Display:**
```typescript
{
  status: "verified",
  badge: "✅ Verified", // Green badge
  details: {
    provider: string; // "Checkr"
    verified_at: string; // "2025-01-15"
    expires_at?: string; // "2027-01-15" (typically 2 years)
  },
  action: null, // No action (read-only)
}
```

**UI:**
```
[Background Check] ✅ Verified
Checkr | Verified: Jan 15, 2025
Expires: Jan 15, 2027
```

---

#### ⚠️ Expired

**Display:**
```typescript
{
  status: "expired",
  badge: "⚠️ Expired", // Red badge with warning icon
  details: {
    provider: string;
    expires_at: string; // Expired date
  },
  action: {
    label: "Renew",
    type: "button", // Primary button
    destination: "/verifications/background-checks/renew"
  },
  subtext: "Expired background checks remove access to critical tasks immediately",
}
```

**UI:**
```
[Background Check] ⚠️ Expired
Expired: Jan 15, 2027
[Renew] ← Primary button
Expired background checks remove access to critical tasks immediately
```

---

### Important Rules

**Background checks:**
- Do not unlock non-critical gigs (only critical tasks)
- Are never bundled with other verifications (separate flow)
- Require opt-in (willingness flag must be enabled)

**Enforcement:**
- Section hidden if user has not opted into critical tasks
- No "Start background check" prompt without opt-in
- Background check verification only affects `background_check_valid` flag

---

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response (Background Checks Section):**
```typescript
{
  background_check: {
    visible: boolean; // True only if user opted into critical tasks
    status?: 'not_completed' | 'pending' | 'verified' | 'expired';
    badge?: string;
    details?: {
      provider?: string;
      verified_at?: string;
      expires_at?: string;
    };
    action?: {
      label: string;
      type: 'button';
      destination: string;
    };
    subtext?: string;
    progress?: {
      provider: string;
      current_step: string;
    };
  };
}
```

---

## 5. Upgrade Opportunities (Computed, Not Marketing)

### Purpose

Show upgrade paths that unlock real, currently available tasks.

**This is where motivation lives—but it must be truthful.**

### Render Rule (Strict)

**Show an upgrade card only if:**
1. There exist currently open tasks (status = 'posted', assigned_to = null)
   - AND
2. That would become eligible if exactly one verification were completed
   - AND
3. Task count is computed, not estimated (real-time query)

**If conditions not met:**
- Section is hidden (not shown)
- No upgrade cards (no false promises)

### Algorithm

```typescript
async function computeUpgradeOpportunities(
  userId: string
): Promise<UpgradeOpportunity[]> {
  const profile = await getLatestCapabilityProfile(userId);
  const opportunities: UpgradeOpportunity[] = [];

  // For each claimed but unverified trade
  const unverifiedTrades = await getUnverifiedTrades(userId);
  for (const trade of unverifiedTrades) {
    // Count tasks that would become eligible if trade was verified
    const lockedTaskCount = await countLockedTasksForTrade(userId, trade);
    
    if (lockedTaskCount > 0) {
      opportunities.push({
        type: 'verify_trade',
        trade,
        locked_task_count: lockedTaskCount,
        average_payout: await computeAveragePayoutForTrade(trade),
      });
    }
  }

  // For insurance (if user has verified trade but no insurance)
  if (profile.verified_trades.length > 0 && !profile.insurance_valid) {
    const lockedTaskCount = await countLockedTasksRequiringInsurance(userId);
    
    if (lockedTaskCount > 0) {
      opportunities.push({
        type: 'add_insurance',
        locked_task_count: lockedTaskCount,
        average_payout: await computeAveragePayoutForInsuranceRequiredTasks(),
      });
    }
  }

  return opportunities;
}
```

### Example Card

**Display:**
```typescript
{
  type: "verify_trade",
  trade: "electrician",
  locked_task_count: 7, // Computed, not estimated
  average_payout: 180, // Computed from actual tasks
  action: {
    label: "Verify Electrician License",
    destination: "/verifications/licenses/submit?trade=electrician"
  },
}
```

**UI:**
```
[Upgrade Card]
Verify Electrician License
Unlocks 7 active gigs near you
Average payout: $180
[Verify license] ← Primary button
```

**Computed Fields:**
- `locked_task_count`: Real-time query (count of tasks that would become eligible)
- `average_payout`: Computed from actual task payouts (not estimates)
- `trade`: From claimed trades (not hypothetical)

---

### Forbidden

**❌ Hypothetical counts:**
- "Up to 20 gigs" (vague, not actionable)
- "Potential earnings" (hypothetical, not real)

**❌ "Up to" language:**
- "Up to $500" (range, not specific)
- "Up to 10 gigs" (maximum, not actual)

**❌ Global averages:**
- "Average electrician pay: $200" (global, not local)
- "Typical payout: $150" (typical, not actual)

**❌ Marketing copy:**
- "Unlock unlimited earning potential" (marketing, not factual)
- "Join the top earners" (aspirational, not actionable)

**This is a query result, not a pitch.**

---

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility/upgrade-opportunities`

**Response:**
```typescript
{
  upgrade_opportunities: Array<{
    type: 'verify_trade' | 'add_insurance' | 'complete_background_check';
    trade?: string; // If type = 'verify_trade'
    locked_task_count: number; // Computed, not estimated
    average_payout: number; // Computed from actual tasks
    action: {
      label: string;
      destination: string; // Deep link to verification pipeline
    };
  }>;
}
```

**Update Frequency:**
- Real-time (recomputed on each request)
- Cached for 5 minutes (prevents repeated queries)
- Invalidated when tasks created/closed (feed invalidation)

---

## 6. System Notices (Expiry Only)

### Purpose

Display expiry and failure notices, only shown when relevant.

### Allowed Notices

**1. Credential Expired**
```typescript
{
  type: "credential_expired",
  credential_type: "license" | "insurance" | "background_check",
  trade?: string, // If credential_type = 'license'
  expires_at: string,
  severity: "warning", // Amber badge
}
```

**2. Verification Failed**
```typescript
{
  type: "verification_failed",
  credential_type: "license" | "insurance" | "background_check",
  trade?: string,
  failure_reason: string,
  severity: "error", // Red badge
}
```

**3. Reverification Required**
```typescript
{
  type: "reverification_required",
  credential_type: "license" | "insurance" | "background_check",
  trade?: string,
  reason: string, // "Expires in 30 days"
  severity: "info", // Blue badge
}
```

### Placement

**1. Badge on "Work Eligibility" Navigation**
- Red dot badge (if expiries/failures exist)
- Count of active notices (optional)

**2. Inline Alert at Top of Page**
- Only shown if notices exist
- Collapsible (can dismiss if non-critical)
- Clear action buttons (Renew, Resubmit, etc.)

**UI:**
```
[Work Eligibility] 🔴 (badge if notices exist)

[Inline Alert at Top]
⚠️ Your electrician license expired on Jan 1, 2026
[Renew verification] ← Action button
```

---

### Forbidden

**❌ Push notifications for eligibility loss:**
- "Your feed has been updated" (too vague)
- "You lost access to tasks" (alarming, not calm)

**❌ Feed warnings:**
- "Some tasks are no longer available" (confusing, not clear)
- "Your eligibility changed" (vague, not specific)

**❌ Modals:**
- "Your license expired" (interrupting, not procedural)
- "Update required" (blocking, not informative)

**Loss of access should be calm and procedural, not alarming.**

---

### Backend Contract

**Endpoint:** `GET /api/settings/work-eligibility`

**Response (System Notices Section):**
```typescript
{
  system_notices: Array<{
    type: 'credential_expired' | 'verification_failed' | 'reverification_required';
    credential_type: 'license' | 'insurance' | 'background_check';
    trade?: string;
    expires_at?: string;
    failure_reason?: string;
    reason?: string;
    severity: 'info' | 'warning' | 'error';
    action?: {
      label: string;
      destination: string;
    };
  }>;
}
```

---

## Navigation Rules

**All "Verify / Renew" actions deep-link into the verification pipeline.**

**Flow:**
```
Settings → Work Eligibility
  → [Verify license] button
    → Verification Pipeline (Step A: Submission)
      → Verification processing
        → Return to Settings (on completion or failure)
```

**Return Behavior:**
- On completion: Return to Settings → Work Eligibility (show updated status)
- On failure: Return to Settings → Work Eligibility (show failure reason)
- Never auto-navigate to Feed (Settings is control room, not dopamine loop)

**Deep Link Format:**
```
/verifications/licenses/submit?trade=electrician
/verifications/insurance/submit
/verifications/background-checks/initiate
/verifications/licenses/renew?trade=electrician&verification_id=xxx
```

---

## Data Binding (Non-Negotiable)

**Settings reads only:**
- `capability_profile` (latest snapshot, not cached)
- Verification source tables (for metadata: status, expiry, etc.)

**Settings never:**
- Mutates eligibility (eligibility is derived, not editable)
- Calls recompute directly (recompute happens automatically)
- Caches eligibility independently (capability profile is single source of truth)

**Backend Contract:**

**Endpoint:** `GET /api/settings/work-eligibility`

**Request:**
```typescript
{
  // No parameters (userId from auth token)
}
```

**Response:**
```typescript
{
  eligibility_summary: EligibilitySummary;
  verified_trades: VerifiedTrade[];
  insurance: InsuranceStatus;
  background_check: BackgroundCheckStatus;
  upgrade_opportunities: UpgradeOpportunity[];
  system_notices: SystemNotice[];
}
```

**Cache Strategy:**
- No caching (always fetch latest capability profile)
- Short TTL on upgrade opportunities (5 minutes, invalidated on task changes)
- Real-time system notices (no caching)

---

## Forbidden UI Patterns (Hard No)

### ❌ Enable/Disable Switches

**Why Forbidden:**
- Verification status is truth (cannot be toggled)
- Eligibility is derived (not user-controlled)

**Correct Pattern:**
- ✅ "Verify license" button (triggers verification)
- ✅ Read-only status badges (no edit actions)

---

### ❌ "Try Anyway"

**Why Forbidden:**
- Bypasses eligibility enforcement
- Users can apply to tasks they're not qualified for

**Correct Pattern:**
- ✅ Apply endpoint returns 403 if not eligible (defense-in-depth)

---

### ❌ "Request Exception"

**Why Forbidden:**
- Creates support burden
- Suggests eligibility is negotiable (it's not)

**Correct Pattern:**
- ✅ "Verify license" button (clear upgrade path)
- ✅ "Renew verification" button (clear renewal path)

---

### ❌ "Contact Support to Unlock"

**Why Forbidden:**
- Suggests support can bypass eligibility (they can't)
- Creates false hope (support cannot grant access)

**Correct Pattern:**
- ✅ "Verify license" button (self-service upgrade path)
- ✅ Upgrade opportunities (computed, actionable)

---

### ❌ Upsells Framed as Access Shortcuts

**Why Forbidden:**
- Suggests payment can bypass eligibility (it can't)
- Erodes trust (pay-to-play feeling)

**Correct Pattern:**
- ✅ "Verify license" button (clear verification path)
- ✅ Upgrade opportunities (truthful, not coercive)

**If any of these appear, you have broken trust.**

---

## Required Tests (UI + Logic)

### 1. Expired License → Trade Disappears from Summary

```typescript
it('removes expired trade from eligibility summary', async () => {
  const user = await createUser({
    verified_trades: [{ trade: 'electrician', expires_at: '2025-01-01' }]
  });

  // Expire license
  await expireLicense(user.id, 'electrician');
  await recomputeCapabilityProfile(user.id);

  // Settings should not show electrician in "eligible for"
  const settings = await getSettings(user.id);
  expect(settings.eligibility_summary.eligible_for).not.toContain('Electrical');
});
```

---

### 2. Verification Completes → Feed Updates Within TTL

```typescript
it('updates feed when verification completes', async () => {
  const user = await createUser({ verified_trades: [] });
  const task = await createTask({ required_trade: 'electrician' });

  // Feed should exclude task (no verified trade)
  const feedBefore = await getFeed(user.id);
  expect(feedBefore.tasks).not.toContainEqual(task);

  // Complete verification
  await completeVerification(user.id, 'electrician');
  await recomputeCapabilityProfile(user.id);
  await invalidateFeedCache(user.id);

  // Feed should include task (verified trade, within TTL)
  await wait(65); // Wait for cache TTL (60s)
  const feedAfter = await getFeed(user.id);
  expect(feedAfter.tasks).toContainEqual(task);
});
```

---

### 3. Insurance Expires → High-Risk Trades Disappear

```typescript
it('removes high-risk trades when insurance expires', async () => {
  const user = await createUser({
    verified_trades: [{ trade: 'electrician' }],
    insurance_valid: true,
  });

  // Expire insurance
  await expireInsurance(user.id);
  await recomputeCapabilityProfile(user.id);

  // Settings should not show high-risk trades in "eligible for"
  const settings = await getSettings(user.id);
  expect(settings.eligibility_summary.eligible_for).not.toContain('In-home electrical');
});
```

---

### 4. No Eligible Upgrades → Upgrade Section Hidden

```typescript
it('hides upgrade section if no eligible upgrades', async () => {
  const user = await createUser({ verified_trades: [] });
  
  // No tasks available for unverified trades
  const settings = await getSettings(user.id);
  
  expect(settings.upgrade_opportunities).toHaveLength(0);
  // UI should hide upgrade section if empty
});
```

---

### 5. User with No Trades → Sees Clean, Minimal UI

```typescript
it('shows minimal UI for users with no trades', async () => {
  const user = await createUser({ verified_trades: [] });

  const settings = await getSettings(user.id);

  // Should show only eligibility summary and "Add trade" prompts
  expect(settings.verified_trades).toHaveLength(0);
  expect(settings.insurance.visible).toBe(false);
  expect(settings.background_check.visible).toBe(false);
  expect(settings.upgrade_opportunities).toHaveLength(0);
});
```

**If these tests pass, your Settings UI is correct.**

---

## What You've Now Achieved

### Users Understand Their Feed Without Rejection

**How:**
- Settings explains eligibility clearly (what you can/cannot do)
- Feed shows only eligible tasks (no disabled buttons)
- No "why was I rejected?" tickets (users never rejected, just not shown)

**Evidence:**
- Settings is single entry point (one place to understand eligibility)
- Eligibility summary shows clear breakdown (eligible vs not eligible)
- Upgrade opportunities show actionable paths (verify trade to unlock tasks)

---

### Upgrades Feel Earned, Not Sold

**How:**
- Upgrade opportunities are computed (not estimated)
- Upgrade cards show real task counts (not hypothetical)
- Upgrade actions trigger verification (not payment)

**Evidence:**
- Upgrade opportunities computed from real tasks (locked_task_count)
- Average payout computed from actual tasks (not global averages)
- Actions link to verification pipeline (not payment flow)

---

### Support Tickets Drop

**How:**
- Settings explains eligibility (no confusion)
- Clear upgrade paths (no support needed)
- No false promises (computed, not estimated)

**Evidence:**
- Eligibility summary is clear (eligible vs not eligible)
- Upgrade opportunities are truthful (computed task counts)
- No "request exception" buttons (self-service only)

---

### Trust Remains Centralized

**How:**
- Settings reads from capability profile (single source of truth)
- Settings never mutates eligibility (eligibility is derived)
- Settings triggers verification (not access changes)

**Evidence:**
- Data binding reads only from capability profile (not cached)
- No toggles or switches (verification status is truth)
- Actions link to verification pipeline (not direct profile mutations)

---

### Monetization Stays Clean

**How:**
- Payments unlock verification processing (not capability profile)
- Upgrade opportunities trigger verification (not payment)
- No pay-to-play feeling (eligibility is earned, not purchased)

**Evidence:**
- Upgrade actions link to verification pipeline (not payment)
- Settings never shows "pay to unlock" (verification is self-service)
- Payments are gated by eligibility pre-check (not access bypass)

**This completes the end-to-end eligibility system:**
**Onboarding → Verification → Capability → Feed → Explanation.**

---

## This Settings UI is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this UI exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
