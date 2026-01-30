# Capability-Driven Onboarding (Hustler Side) — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This onboarding flow prevents trust leaks, eliminates rejection friction, and ensures legal compliance. It enforces "onboarding collects claims, not permissions" as the fundamental principle. Users never see gigs they don't qualify for. This is how serious marketplaces scale safely.

---

## Core Principles (Non-Negotiable)

1. **Onboarding collects claims, not permissions**
   - Answers populate backend fields
   - No question grants access directly
   - Verification is always a second step

2. **No question grants access directly**
   - Onboarding does not unlock tasks
   - Capability profile (derived) drives feed
   - Verification gates are separate

3. **Every answer maps to a backend field**
   - No fluff questions
   - Every response updates capability claims
   - Backend schema is single source of truth

4. **Verification is always a second step**
   - Claims unlock verification paths
   - Verification unlocks tasks (indirectly)
   - No shortcuts or "apply anyway" buttons

5. **Users never see gigs they don't qualify for**
   - Feed is filtered before display
   - No disabled cards or upsell prompts
   - Eligibility is invisible (clean feed)

**If a question does not change feed eligibility or unlock a verification path, delete it.**

---

## Onboarding Flow (Authoritative Sequence)

**PHASE 0 → PHASE 1 → PHASE 2 → PHASE 3 → PHASE 4 → PHASE 5 → PHASE 6 → PHASE 7**

Each phase must complete before next phase is accessible.

---

## PHASE 0 — Role Declaration (Branching Gate)

### Purpose

Determine user intent and unlock appropriate onboarding flow.

### Screen: Role Selection

**Question:**
> "How do you want to use HustleXP?"

**Options:**
- [ ] I want to earn money completing gigs
- [ ] I want to post gigs
- [ ] Both

**Behavioral Rules:**
- Single selection required (cannot proceed without selection)
- Cannot skip or go back (first step)
- Selection determines which flows are available

**Backend Output:**
```typescript
{
  role: "hustler" | "poster" | "both"
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/role-selection`

**Request:**
```typescript
{
  role: "hustler" | "poster" | "both"
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  role: "hustler" | "poster" | "both";
  next_phase: "location" | "hustler_complete" | "poster_flow";
  phase_complete: boolean;
}
```

**Flow Branching:**
- If `role === "hustler"` or `role === "both"` → Continue to PHASE 1 (Location)
- If `role === "poster"` only → Skip to poster-specific flow (out of scope for this spec)

---

## PHASE 1 — Location & Jurisdiction (Legal Scope)

### Purpose

Establish legal jurisdiction for licenses, insurance, and task legality.

### Screen: Location Selection

**Question:**
> "Where will you be working?"

**Fields:**
- **State** (required, dropdown)
  - All 50 US states + DC
  - Cannot proceed without selection
- **City / ZIP** (optional but recommended, text input)
  - Used for proximity matching
  - Improves task relevance

**UX Details:**
- State dropdown is prominent (above city/ZIP)
- City/ZIP field has placeholder: "City or ZIP code (optional)"
- Helper text below: "Licenses and insurance are state-scoped"

**Behavioral Rules:**
- State is required (cannot proceed without selection)
- City/ZIP is optional (can skip)
- Location cannot be changed after onboarding (must go to Settings)
- Selection updates `work_state` and `work_region` immediately

**Backend Output:**
```typescript
{
  work_state: "WA", // ISO 3166-2 state code
  work_region: "Seattle" | "98101" | undefined // City name or ZIP
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/location`

**Request:**
```typescript
{
  work_state: string; // Required, must be valid US state code
  work_region?: string; // Optional, city name or ZIP code
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  work_state: string;
  work_region?: string;
  next_phase: "capability_declaration";
  phase_complete: boolean;
}
```

**Validation Rules:**
1. `work_state` must be valid US state code (ISO 3166-2)
2. `work_region` must be non-empty string if provided
3. If `work_region` is ZIP, must match state (validation check)

**Why This Matters:**
- Licenses are state-scoped (WA electrician license ≠ CA electrician license)
- Insurance is state-scoped (coverage territory)
- Task legality is state-scoped (workplace safety laws)
- No location = no trade verification paths

---

## PHASE 2 — Capability Declaration (Claims Only)

### Purpose

Collect trade claims that unlock verification paths, not gig access.

### Screen: Trade Selection

**Question:**
> "What types of work are you qualified to do?"
> "(Select all that apply)"

**Trade Categories:**

**Low-Risk (No License Typically Required):**
- Moving help
- Yard work
- Cleaning
- Assembly
- Errands

**Trade / Regulated:**
- Electrician (License required)
- Plumber (License required)
- HVAC (License required)
- General contractor (License required)
- Appliance install (License required)
- IT / networking (License may be required)
- In-home care (License may be required)

**UX Details:**
- Checkbox selection (multiple allowed)
- Regulated trades marked with visual indicator: **"License required"** (amber badge)
- Visual distinction between low-risk and regulated trades (section separator or grouping)
- Helper text: "Select all trades you're qualified for. Verification is the next step."
- Cannot proceed without at least one selection (validation)

**Behavioral Rules:**
- Must select at least one trade (cannot proceed empty)
- Can select multiple trades (checkboxes)
- Selection does not unlock gigs (only verification paths)
- Regulated trades unlock PHASE 3 (Credential Claim)
- Low-risk trades skip to PHASE 5 (Insurance Claim)

**Backend Output:**
```typescript
{
  claimed_trades: string[] // e.g., ["electrician", "moving"]
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/capability-declaration`

**Request:**
```typescript
{
  claimed_trades: string[]; // Required, must contain at least one trade
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  claimed_trades: string[];
  regulated_trades: string[]; // Filtered from claimed_trades
  low_risk_trades: string[]; // Filtered from claimed_trades
  next_phase: "credential_claim" | "insurance_claim"; // Depends on regulated_trades.length
  phase_complete: boolean;
}
```

**Validation Rules:**
1. `claimed_trades` must contain at least one trade
2. All trades in `claimed_trades` must exist in system trade list
3. If `regulated_trades.length > 0` → Next phase is `"credential_claim"`
4. If `regulated_trades.length === 0` → Next phase is `"insurance_claim"`

**Trade Classification:**
```typescript
const REGULATED_TRADES = [
  "electrician",
  "plumber",
  "hvac",
  "general_contractor",
  "appliance_install",
];

const LICENSE_MAY_BE_REQUIRED = [
  "it_networking",
  "in_home_care",
];
```

**Why This Matters:**
- Claims unlock verification paths (not gig access)
- Regulated trades require PHASE 3 (Credential Claim)
- Low-risk trades skip to PHASE 5 (Insurance Claim)
- This does NOT unlock gigs (capability profile drives feed)

---

## PHASE 3 — Credential Claim (Eligibility Pre-Check)

### Purpose

Assess whether user has licenses for regulated trades, unlock credential capture if applicable.

### Conditional Display

**Only shown if `regulated_trades.length > 0` (from PHASE 2)**

### Screen: Credential Status

**Question:**
> "Do you currently hold a valid license for any of these trades?"

**Options:**
- [ ] Yes
- [ ] No
- [ ] I'm not sure

**Trades List:**
- Display all regulated trades selected in PHASE 2
- Format: "Electrician (License required)" with amber badge
- Grouped for readability

### Branching Logic

**If "No" Selected:**
- Trade verification remains locked
- User can continue onboarding (no blocking)
- Clear copy shown:

  > "You won't see licensed gigs until verification is complete. You'll still see eligible low-risk work."

- Next phase: `"insurance_claim"` (skip PHASE 4)

**If "I'm not sure" Selected:**
- Treated same as "No" (no verification path unlocked)
- Clear copy shown:

  > "You can verify your license later in Settings. You'll still see eligible low-risk work."

- Next phase: `"insurance_claim"` (skip PHASE 4)

**If "Yes" Selected:**
- Proceed to PHASE 4 (License Metadata Capture)
- Next phase: `"license_metadata"`

**Behavioral Rules:**
- Cannot proceed without selection (required)
- "No" or "I'm not sure" does not block onboarding (can continue)
- "Yes" unlocks PHASE 4 (credential capture)
- Selection updates `has_license` flag (not grant access)

**Backend Output:**
```typescript
{
  has_license: boolean; // true if "Yes", false if "No" or "I'm not sure"
  license_intent: "yes" | "no" | "unsure";
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/credential-status`

**Request:**
```typescript
{
  license_intent: "yes" | "no" | "unsure";
  regulated_trades: string[]; // From PHASE 2
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  has_license: boolean;
  license_intent: "yes" | "no" | "unsure";
  next_phase: "license_metadata" | "insurance_claim";
  phase_complete: boolean;
}
```

**Why This Matters:**
- Pre-checks eligibility without blocking onboarding
- "No" does not prevent continuing (low-risk work still available)
- "Yes" unlocks license capture (PHASE 4)
- Verification paths are unlocked based on intent, not verification status

---

## PHASE 4 — License Metadata Capture (No Payment Yet)

### Purpose

Collect license metadata for verification processing, not grant access.

### Conditional Display

**Only shown if `has_license === true` (from PHASE 3)**

### Screen: License Details

**Question:**
> "Enter your license details"

**Form Fields:**

For each regulated trade selected in PHASE 2:

**License Details:**
- **Trade type** (auto-filled, read-only)
  - Value from PHASE 2 selection
  - Display: "Electrician" with amber "License required" badge
- **License number** (required, text input)
  - Placeholder: "Enter license number"
  - Validation: Must be non-empty string
- **Issuing state** (required, dropdown)
  - Pre-filled with `work_state` from PHASE 1
  - User can change (may have license from different state)
  - Validation: Must match `work_state` or adjacent state (for reciprocity)
- **Expiration date** (optional, date picker)
  - Only shown if license registry cannot be checked automatically
  - Helper text: "If your license has an expiration date"

**UX Details:**
- Multi-trade licenses shown as separate forms (one per trade)
- "Add another license" button if multiple regulated trades selected
- "Skip for now" option (allows continuing without license details)
- Helper text: "Verification is processed after onboarding. You can add licenses later in Settings."

**Behavioral Rules:**
- Can add multiple licenses (one per regulated trade)
- Can skip individual licenses ("Skip for now" button)
- License number and issuing state are required if license added
- Expiration date is optional (if registry-checked, auto-filled)
- Adding license does not grant access (verification is separate)

**Backend Output:**
```typescript
{
  license_claims: LicenseClaim[];
}

interface LicenseClaim {
  trade: string; // e.g., "electrician"
  state: string; // e.g., "WA"
  license_number: string; // e.g., "EL12345"
  expiration_date?: string; // ISO 8601, optional
  verification_status: "pending"; // Always "pending" at onboarding
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/license-metadata`

**Request:**
```typescript
{
  license_claims: Array<{
    trade: string; // Must be in regulated_trades from PHASE 2
    state: string; // ISO 3166-2 state code
    license_number: string; // Non-empty string
    expiration_date?: string; // ISO 8601, optional
  }>;
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  license_claims: LicenseClaim[];
  verification_paths_unlocked: VerificationPath[];
  next_phase: "insurance_claim";
  phase_complete: boolean;
}
```

**VerificationPath:**
```typescript
{
  trade: string;
  status: "pending";
  requirements: string[]; // e.g., ["Submit license scan", "Verify state registry"]
  estimated_duration?: string; // e.g., "2-3 business days"
}
```

**Validation Rules:**
1. `license_claims` can be empty (user can skip)
2. If `license_claims` provided, `trade`, `state`, and `license_number` are required
3. `trade` must be in `regulated_trades` from PHASE 2
4. `state` must be valid US state code (ISO 3166-2)
5. `license_number` must be non-empty string

**Critical Notes:**
- ❌ No trust granted at this stage
- ❌ No feed changes at this stage
- ❌ No payment yet (verification is free or separate)
- ❌ No gig access (verification unlocks tasks)
- ✅ Verification paths unlocked (can start verification after onboarding)

**Why This Matters:**
- License metadata enables verification processing
- Claims unlock verification paths (not gig access)
- Verification is separate step (post-onboarding)
- Users can complete onboarding without licenses (low-risk work still available)

---

## PHASE 5 — Insurance Claim (Conditional)

### Purpose

Collect insurance claims for risk-class gating, not grant access.

### Conditional Display

**Only shown if:**
- `regulated_trades.length > 0` OR
- `risk_preferences.in_home === true` (from PHASE 6, if answered first)
- OR both

### Screen: Insurance Status

**Question:**
> "Do you currently carry active professional insurance?"

**Options:**
- [ ] Yes
- [ ] No

**If "Yes" Selected:**
- Show "Upload Certificate of Insurance (COI)" button (optional now, required later)
- Helper text: "Upload now or add later in Settings"
- File upload interface (accepts PDF, JPG, PNG)
- Upload is optional at onboarding (can skip)

**If "No" Selected:**
- Clear copy shown:

  > "Insurance is required for certain higher-risk gigs. You'll still see eligible lower-risk work."

- No blocking (user can continue onboarding)

**Behavioral Rules:**
- Must select "Yes" or "No" (cannot skip, but "No" does not block)
- COI upload is optional at onboarding (can add later in Settings)
- "No" does not prevent continuing (low-risk work still available)
- Selection updates `insurance_claimed` flag (not grant access)

**Backend Output:**
```typescript
{
  insurance_claimed: boolean; // true if "Yes", false if "No"
  coi_uploaded: boolean; // true if file uploaded, false otherwise
  coi_url?: string; // S3 URL if uploaded, undefined otherwise
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/insurance-status`

**Request:**
```typescript
{
  insurance_claimed: boolean;
  coi_file?: File; // Optional, if uploaded
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  insurance_claimed: boolean;
  coi_uploaded: boolean;
  coi_url?: string;
  verification_paths_unlocked: VerificationPath[]; // If insurance_claimed === true
  next_phase: "risk_willingness";
  phase_complete: boolean;
}
```

**Validation Rules:**
1. `insurance_claimed` is required (must be `true` or `false`)
2. If `coi_file` provided, must be valid file (PDF, JPG, PNG, < 10MB)
3. If `coi_file` provided, `insurance_claimed` must be `true`

**Why This Matters:**
- Insurance claims unlock verification paths (not gig access)
- Insurance verification gates higher-risk tasks (not low-risk tasks)
- "No" does not block onboarding (low-risk work still available)
- Verification is separate step (post-onboarding)

---

## PHASE 6 — Risk Willingness (Not Access)

### Purpose

Collect willingness flags that tailor verification prompts and upsells, not grant access.

### Screen: Risk Willingness

**Question:**
> "Are you willing to do the following?"
> "(These preferences tailor your verification options)"

**Options (Checkboxes):**

- [ ] **In-home work**
  - Helper text: "Work inside customer residences (requires insurance)"
  - Warning icon if `insurance_claimed === false` (from PHASE 5)

- [ ] **Urgent / same-day gigs**
  - Helper text: "Accept instant tasks with tight deadlines"
  - No additional requirements

- [ ] **High-value installs ($$$)**
  - Helper text: "Installation tasks with higher pay (requires higher trust tier)"
  - Info icon explaining trust tier requirements

**UX Details:**
- Checkboxes (multiple can be selected)
- Helper text for each option (explains requirements)
- Warning icons if requirements not met (e.g., insurance for in-home work)
- Can skip all options (none are required)

**Behavioral Rules:**
- All options are optional (can skip)
- Can select multiple options (checkboxes)
- Selection does not unlock gigs (only tailors prompts)
- Warnings shown if requirements not met (informational, not blocking)
- Selection updates `risk_preferences` (not grant access)

**Backend Output:**
```typescript
{
  risk_preferences: {
    in_home: boolean; // true if checked, false otherwise
    urgent: boolean; // true if checked, false otherwise
    high_value: boolean; // true if checked, false otherwise
  };
}
```

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/risk-willingness`

**Request:**
```typescript
{
  risk_preferences: {
    in_home?: boolean; // Optional, default false
    urgent?: boolean; // Optional, default false
    high_value?: boolean; // Optional, default false
  };
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  risk_preferences: RiskPreferences;
  next_phase: "summary";
  phase_complete: boolean;
}
```

**Why This Matters:**
- Willingness flags tailor verification prompts (not unlock gigs)
- Settings screen shows relevant verification options based on preferences
- Feed filtering uses willingness flags (in addition to capability profile)
- Preferences do not grant access (capability profile drives feed)

---

## PHASE 7 — Summary & Next Actions (Critical UX Moment)

### Purpose

Confirm onboarding completion, show verification paths, and guide next steps.

### Screen: Onboarding Summary

**Header:**
> "You're set up to earn on HustleXP"

**Summary Sections:**

**1. Location (Read-Only)**
- Display: `work_state`, `work_region` (from PHASE 1)
- Status: "Set" (green checkmark)
- Action: None (cannot change here, must go to Settings)

**2. Trades (Read-Only with Actions)**
- Display: All `claimed_trades` from PHASE 2
- Low-risk trades: "Active" badge (green)
- Regulated trades: Status depends on PHASE 3/4:
  - If `has_license === true` and `license_claims.length > 0`: "Verification pending" badge (amber)
  - If `has_license === false`: "Not verified" badge (gray) with action button

**3. Insurance (Read-Only with Actions)**
- Display: `insurance_claimed` status from PHASE 5
- If `insurance_claimed === true` and `coi_uploaded === false`: "Upload COI" action button
- If `insurance_claimed === false`: "Add insurance" action button (optional)
- Status: "Not required for low-risk work" (if `insurance_claimed === false`)

**4. Risk Preferences (Read-Only)**
- Display: Selected `risk_preferences` from PHASE 6
- Status: "Preferences saved" (green checkmark)
- Action: None (can change in Settings)

**Next Actions Section:**

**Primary Action (If Verification Paths Unlocked):**
- Button: "Start Verification" (prominent, green)
- Action: Navigate to Settings → Work Eligibility → [Trade] → Start Verification
- Visible only if `verification_paths_unlocked.length > 0`

**Secondary Action (Always Visible):**
- Button: "Explore Feed" (secondary, gray)
- Action: Navigate to task feed (shows only eligible tasks)
- Visible always (feed is filtered by capability profile)

**Locked Sections (If Applicable):**
- Display: "Verify [Trade] License to unlock [X] gigs near you"
- Example: "Verify Electrician License to unlock 14 gigs near you"
- Action: "Start Verification" button (if applicable)

**What You Must NOT Show:**
- ❌ Rejected tasks (feed is filtered, no rejected tasks visible)
- ❌ Disabled apply buttons (feed only shows eligible tasks)
- ❌ Confusing errors (onboarding is clear, errors are preempted)
- ❌ "Why was I rejected?" messaging (users never rejected, just not shown)

**Backend Contract:**

**Endpoint:** `POST /api/onboarding/complete`

**Request:**
```typescript
{
  onboarding_id: string; // From previous phases
}
```

**Response:**
```typescript
{
  onboarding_id: string;
  onboarding_complete: true;
  capability_claims: CapabilityClaims;
  capability_profile: CapabilityProfile; // Initial profile (empty verified_trades)
  verification_paths_unlocked: VerificationPath[];
  feed_url: string; // e.g., "/tasks/feed"
}
```

**CapabilityClaims (Stored):**
```typescript
{
  user_id: string;
  role: "hustler" | "poster" | "both";
  claimed_trades: string[];
  license_claims: LicenseClaim[];
  insurance_claimed: boolean;
  work_state: string;
  work_region?: string;
  risk_preferences: RiskPreferences;
  created_at: string; // ISO 8601
}
```

**CapabilityProfile (Initial, Empty Verified Trades):**
```typescript
{
  user_id: string;
  profile_id: string;
  verified_trades: []; // Empty at onboarding completion
  trust_tier: 1; // Default tier (ROOKIE)
  risk_clearance: ["low"]; // Default for Tier 1
  insurance_valid: false; // Will be true after insurance verification
  background_check_valid: false; // Will be true after background check
  willingness_flags: RiskPreferences; // From onboarding
  location_state: string; // From onboarding
  location_city?: string; // From onboarding
  verification_status: {}; // Empty at onboarding completion
  created_at: string; // ISO 8601
}
```

**What Happens After Onboarding Completion:**

1. **Capability claims are stored** (immutable record of onboarding answers)
2. **Initial capability profile is created** (empty verified_trades, default trust tier)
3. **Verification paths are unlocked** (user can start verification in Settings)
4. **Feed is accessible** (filtered by capability profile, shows only eligible tasks)
5. **Settings → Work Eligibility screen is accessible** (shows verification statuses)

---

## Backend Objects Created at Onboarding Completion

### Capability Claims (Immutable Record)

**Purpose:** Audit trail of onboarding answers, never modified after creation.

**Schema:**
```typescript
interface CapabilityClaims {
  user_id: string;
  role: "hustler" | "poster" | "both";
  claimed_trades: string[];
  license_claims: LicenseClaim[];
  insurance_claimed: boolean;
  work_state: string;
  work_region?: string;
  risk_preferences: RiskPreferences;
  created_at: string; // ISO 8601
  updated_at?: never; // Immutable after creation
}
```

**Storage:** `capability_claims` table (immutable, append-only)

**Why Immutable:**
- Audit trail of onboarding answers
- Cannot be modified (must go to Settings to change)
- References for verification processing

### Capability Profile (Derived, Recomputed)

**Purpose:** Single source of truth for eligibility, drives feed filtering.

**Schema:**
```typescript
interface CapabilityProfile {
  user_id: string;
  profile_id: string;
  verified_trades: VerifiedTrade[]; // Empty at onboarding completion
  trust_tier: TrustTier; // 1 (ROOKIE) at onboarding completion
  risk_clearance: RiskLevel[]; // ["low"] at onboarding completion
  insurance_valid: boolean; // false at onboarding completion
  background_check_valid: boolean; // false at onboarding completion
  willingness_flags: RiskPreferences; // From onboarding
  location_state: string; // From onboarding
  location_city?: string; // From onboarding
  verification_status: { [trade: string]: VerificationStatus };
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601 (recomputed on verification events)
}
```

**Initial State (At Onboarding Completion):**
```typescript
{
  verified_trades: [], // Empty (no verifications yet)
  trust_tier: 1, // ROOKIE (default)
  risk_clearance: ["low"], // Only low-risk tasks available
  insurance_valid: false, // Not verified yet
  background_check_valid: false, // Not verified yet
  willingness_flags: { ... }, // From onboarding
  location_state: "WA", // From onboarding
  location_city: "Seattle", // From onboarding (if provided)
  verification_status: {}, // Empty (no verifications yet)
}
```

**Storage:** `capability_profiles` table (derived, recomputed on verification events)

**Why Derived:**
- Single source of truth for eligibility
- Recomputed on verification events (consistent with verification records)
- Drives feed filtering (feed query uses profile)

**Only the capability_profile drives the feed.**
**Capability claims do not drive the feed (only enable verification paths).**

---

## Why This Works (Honest Assessment)

### Users Feel Guided, Not Blocked

**How:**
- Onboarding is clear about what's required (no hidden gates)
- "No" answers do not block onboarding (low-risk work still available)
- Verification paths are unlocked (can start verification after onboarding)

**Evidence:**
- PHASE 3 ("No" does not block)
- PHASE 5 ("No" does not block)
- PHASE 7 (summary shows verification paths, not blocked tasks)

### Verification Feels Like an Upgrade, Not Punishment

**How:**
- Verification is optional (low-risk work available without verification)
- Verification unlocks more tasks (not required for existing tasks)
- Settings screen shows verification as enhancement (not requirement)

**Evidence:**
- PHASE 3 ("You won't see licensed gigs until verification")
- PHASE 7 (summary shows "unlock [X] gigs" messaging)
- Settings → Work Eligibility (verification shown as upgrade)

### Posters Never See Unqualified Applicants

**How:**
- Feed is filtered by capability profile (only eligible users see tasks)
- Task acceptance implies eligibility (feed construction ensures matching)
- No "why was I rejected?" tickets (users never rejected, just not shown)

**Evidence:**
- Feed query filters by capability profile (Section 5 of architecture spec)
- Onboarding does not grant access (capability profile drives feed)
- Task requirements are explicit (posters can see requirements before posting)

### Legal Responsibility Stays Centralized

**How:**
- Capability profile enforces legal requirements (insurance, licenses, background checks)
- Task requirements are explicit (regulatory compliance is encoded)
- Verification records are immutable (audit trail is preserved)

**Evidence:**
- Capability profile schema (Section 2 of architecture spec)
- Task requirements schema (Section 4 of architecture spec)
- Verification paths unlock (Section 4 of this spec)

### Monetization Fits Naturally Later

**How:**
- Verification can be gated by payment (post-onboarding)
- Trust tier progression can be gated by payment (post-onboarding)
- Premium features can be gated by payment (post-onboarding)

**Evidence:**
- Onboarding does not collect payment (PHASE 4: "No payment yet")
- Verification is separate step (post-onboarding)
- Capability profile is derived (not purchased)

---

## Failure Modes Avoided

### Users Applying to Jobs They Can't Legally Do

**How:** Feed is filtered by capability profile. Ineligible tasks never appear.

**Evidence:** Feed query filters by `verified_trades`, `trust_tier`, `risk_clearance`, `insurance_valid`.

### "Why Was I Rejected?" Support Tickets

**How:** Users never rejected. Tasks simply don't appear.

**Evidence:** Feed construction excludes ineligible tasks (no rejection event exists).

### Trust Erosion from Posters

**How:** Only eligible users can accept tasks. Poster confidence is high.

**Evidence:** Feed construction ensures only users meeting requirements see tasks.

### Screenshots of Unsafe Gigs

**How:** Unsafe gigs don't appear for ineligible users.

**Evidence:** Risk level and trust tier matching prevent unsafe matching.

### Regulatory Ambiguity

**How:** Capability profile enforces legal requirements. Task requirements are explicit.

**Evidence:** Insurance, background checks, and licenses are verified and enforced.

---

## Implementation Checklist (Authoritative)

### Phase 1: Data Model & Schema

- [ ] Define `CapabilityClaims` schema (fields + immutability)
- [ ] Define `CapabilityProfile` schema (fields + derivation rules)
- [ ] Define `LicenseClaim` schema (fields + validation)
- [ ] Create database tables/migrations
- [ ] Add foreign key constraints (claims → users, profiles → users)
- [ ] Add check constraints (trust tier → risk clearance mapping)

### Phase 2: Onboarding API Endpoints

- [ ] `POST /api/onboarding/role-selection`
- [ ] `POST /api/onboarding/location`
- [ ] `POST /api/onboarding/capability-declaration`
- [ ] `POST /api/onboarding/credential-status`
- [ ] `POST /api/onboarding/license-metadata`
- [ ] `POST /api/onboarding/insurance-status`
- [ ] `POST /api/onboarding/risk-willingness`
- [ ] `POST /api/onboarding/complete`

### Phase 3: Onboarding UI Screens

- [ ] PHASE 0: Role Selection screen
- [ ] PHASE 1: Location Selection screen
- [ ] PHASE 2: Trade Selection screen (with regulated trade indicators)
- [ ] PHASE 3: Credential Status screen (conditional)
- [ ] PHASE 4: License Metadata screen (conditional)
- [ ] PHASE 5: Insurance Status screen (conditional)
- [ ] PHASE 6: Risk Willingness screen
- [ ] PHASE 7: Summary & Next Actions screen

### Phase 4: Onboarding Flow Logic

- [ ] Phase branching logic (conditional screens)
- [ ] Phase completion validation (required fields)
- [ ] Phase navigation (forward/backward)
- [ ] Onboarding state persistence (session management)
- [ ] Onboarding completion handler (create claims + profile)

### Phase 5: Capability Profile Initialization

- [ ] Create initial capability profile on onboarding completion
- [ ] Set default trust tier ("A" - Unverified)
- [ ] Set default risk clearance (["low"])
- [ ] Initialize verification_status (empty)
- [ ] Initialize willingness_flags (from onboarding)
- [ ] Initialize location (from onboarding)

### Phase 6: Verification Path Integration

- [ ] Unlock verification paths based on onboarding answers
- [ ] Display verification paths in Settings → Work Eligibility
- [ ] Link verification paths to verification system
- [ ] Update capability profile on verification completion

---

## This Onboarding Flow is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this flow exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
