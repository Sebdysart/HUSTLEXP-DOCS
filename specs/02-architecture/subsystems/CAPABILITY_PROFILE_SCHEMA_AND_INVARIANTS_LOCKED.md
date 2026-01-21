# Capability Profile Schema & Invariants — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** The Capability Profile is the single source of truth for user eligibility. It is never mutated directly. It is always re-derived from verification records, trust tier changes, and credential expiries. This document defines the exact schema, invariants, recompute triggers, and illegal states. All backend implementations must follow this exactly.

---

## Core Rule (Non-Negotiable)

**Capability Profile is never mutated directly. It is always re-derived.**

If this rule is violated, trust leaks and eligibility becomes inconsistent.

---

## Schema Definition (Authoritative)

### CapabilityProfile Interface

```typescript
interface CapabilityProfile {
  // Identity (Immutable After Creation)
  user_id: string; // Foreign key to users.id (1:1 relationship)
  profile_id: string; // UUID, generated at profile creation
  created_at: string; // ISO 8601, set once at creation
  updated_at: string; // ISO 8601, updated on every recompute

  // Verified Capabilities (Derived from Verification Records)
  verified_trades: VerifiedTrade[]; // Empty array if no verifications

  // Trust & Risk (Derived from Trust Service)
  trust_tier: TrustTier; // 1 | 2 | 3 | 4 (ROOKIE/VERIFIED/TRUSTED/ELITE)
  trust_tier_updated_at: string; // ISO 8601, updated when trust tier changes
  risk_clearance: RiskLevel[]; // Derived from trust_tier (immutable mapping)

  // Insurance & Credentials (Derived from Verification Records)
  insurance_valid: boolean; // Derived from insurance_verifications table
  insurance_expires_at?: string; // ISO 8601, if insurance has expiry
  background_check_valid: boolean; // Derived from background_check_verifications table
  background_check_expires_at?: string; // ISO 8601, if background check has expiry

  // Location & Willingness (From Onboarding Claims, Immutable)
  location_state: string; // ISO 3166-2 state code (e.g., "WA")
  location_city?: string; // City name or ZIP code (optional)
  willingness_flags: WillingnessFlags; // From onboarding, can be updated in Settings

  // Verification Status (Derived from Verification Records)
  verification_status: { [trade: string]: VerificationStatus }; // Map of trade → status

  // Expiry Tracking (Derived from Verification Records)
  expires_at?: { [key: string]: string }; // Map of credential_type → expiration_date (ISO 8601)
}

interface VerifiedTrade {
  trade: string; // Trade identifier (e.g., "electrician", "plumber")
  verified_at: string; // ISO 8601, when verification was approved
  expires_at?: string; // ISO 8601, if trade has expiry (e.g., license expiration)
  verification_method: VerificationMethod; // 'license_scan' | 'certification' | 'portfolio' | 'test' | 'manual_review'
  verification_id: string; // Foreign key to verifications.id
}

type TrustTier = 1 | 2 | 3 | 4;  // 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE
type RiskLevel = 'low' | 'medium' | 'high';
type VerificationStatus = 'not_started' | 'pending' | 'in_progress' | 'verified' | 'expired' | 'rejected';
type VerificationMethod = 'license_scan' | 'certification' | 'portfolio' | 'test' | 'manual_review';

interface WillingnessFlags {
  in_home_work: boolean; // If true, can accept in-home tasks (requires insurance if applicable)
  high_risk_tasks: boolean; // If true, can accept high-risk tasks (requires appropriate trust tier)
  urgent_jobs: boolean; // If true, can accept instant/same-day tasks
}
```

### Database Schema (PostgreSQL)

```sql
-- Capability Profiles Table
CREATE TABLE capability_profiles (
  -- Identity
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Trust & Risk (1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE)
  trust_tier INTEGER NOT NULL CHECK (trust_tier IN (1, 2, 3, 4)),
  trust_tier_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  risk_clearance TEXT[] NOT NULL DEFAULT ARRAY['low']::TEXT[] CHECK (
    (trust_tier = 1 AND risk_clearance = ARRAY['low']::TEXT[]) OR
    (trust_tier = 2 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
    (trust_tier = 3 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
    (trust_tier = 4 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance) AND 'high' = ANY(risk_clearance))
  ),

  -- Insurance & Credentials
  insurance_valid BOOLEAN NOT NULL DEFAULT FALSE,
  insurance_expires_at TIMESTAMPTZ,
  background_check_valid BOOLEAN NOT NULL DEFAULT FALSE,
  background_check_expires_at TIMESTAMPTZ,

  -- Location & Willingness (Immutable from Onboarding)
  location_state VARCHAR(2) NOT NULL CHECK (length(location_state) = 2),
  location_city VARCHAR(255),
  willingness_flags JSONB NOT NULL DEFAULT '{"in_home_work": false, "high_risk_tasks": false, "urgent_jobs": false}'::JSONB,

  -- Metadata
  verification_status JSONB NOT NULL DEFAULT '{}'::JSONB,
  expires_at JSONB DEFAULT '{}'::JSONB,

  -- Constraints
  CONSTRAINT capability_profiles_user_id_unique UNIQUE (user_id)
);

-- Verified Trades Table (Join Table)
CREATE TABLE verified_trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES capability_profiles(profile_id) ON DELETE CASCADE,
  trade VARCHAR(255) NOT NULL,
  verified_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ,
  verification_method VARCHAR(50) NOT NULL CHECK (
    verification_method IN ('license_scan', 'certification', 'portfolio', 'test', 'manual_review')
  ),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,

  -- Constraints
  CONSTRAINT verified_trades_profile_trade_unique UNIQUE (profile_id, trade),
  CONSTRAINT verified_trades_verification_id_unique UNIQUE (verification_id)
);

-- Indexes
CREATE INDEX idx_capability_profiles_user_id ON capability_profiles(user_id);
CREATE INDEX idx_capability_profiles_trust_tier ON capability_profiles(trust_tier);
CREATE INDEX idx_capability_profiles_location_state ON capability_profiles(location_state);
CREATE INDEX idx_verified_trades_profile_id ON verified_trades(profile_id);
CREATE INDEX idx_verified_trades_trade ON verified_trades(trade);
CREATE INDEX idx_verified_trades_expires_at ON verified_trades(expires_at) WHERE expires_at IS NOT NULL;
```

---

## Invariants (Enforced by Database & Code)

### Invariant 1: Trust Tier → Risk Clearance Mapping (Immutable)

**Rule:**
```
trust_tier = 1 (ROOKIE)   → risk_clearance = ['low']
trust_tier = 2 (VERIFIED) → risk_clearance = ['low', 'medium']
trust_tier = 3 (TRUSTED)  → risk_clearance = ['low', 'medium']
trust_tier = 4 (ELITE)    → risk_clearance = ['low', 'medium', 'high']
```

**Enforcement:**
- Database check constraint (see schema above)
- Application-level validation before recompute
- Cannot be violated without database constraint error

**Why:**
- Trust tier is the authority for risk clearance
- Risk clearance is derived from trust tier, not stored separately
- Prevents inconsistent eligibility states

### Invariant 2: Verified Trades Must Have Active Verification

**Rule:**
- If `verified_trades` contains trade `X`, then `verification_status[X] === 'verified'`
- If `verification_status[X] !== 'verified'`, then trade `X` is excluded from `verified_trades`

**Enforcement:**
- Recomputation logic enforces this (see Section 4)
- Foreign key constraint on `verified_trades.verification_id`
- Cannot insert `verified_trade` without valid `verification_id`

**Why:**
- Verified trades are derived from verification records
- No verified trade can exist without active verification
- Prevents phantom capabilities

### Invariant 3: Expired Credentials Invalidate Capabilities

**Rule:**
- If `expires_at[trade] < now()`, then trade is removed from `verified_trades`
- If `insurance_expires_at < now()`, then `insurance_valid = false`
- If `background_check_expires_at < now()`, then `background_check_valid = false`

**Enforcement:**
- Expiry detection cron job (see Section 5)
- Recomputation on expiry detection
- Cannot have expired credentials in `verified_trades`

**Why:**
- Expired credentials are not valid for task eligibility
- System must prevent matching on expired credentials
- Legal compliance requires expiry enforcement

### Invariant 4: Insurance Validity Gated by Verification

**Rule:**
- `insurance_valid = true` only if insurance verification record exists and is approved
- `insurance_valid = false` if insurance verification record is missing, rejected, or expired

**Enforcement:**
- Recomputation logic checks insurance verification records
- Cannot set `insurance_valid = true` without valid insurance verification

**Why:**
- Insurance validity is derived from verification records
- Cannot claim insurance without verification
- Legal compliance requires proof of insurance

### Invariant 5: Background Check Validity Gated by Verification

**Rule:**
- `background_check_valid = true` only if background check verification record exists and is approved
- `background_check_valid = false` if background check verification record is missing, rejected, or expired

**Enforcement:**
- Recomputation logic checks background check verification records
- Cannot set `background_check_valid = true` without valid background check verification

**Why:**
- Background check validity is derived from verification records
- Cannot claim background check without verification
- Legal compliance requires proof of background check

### Invariant 6: Location State Must Be Valid US State Code

**Rule:**
- `location_state` must be 2-character ISO 3166-2 US state code
- Valid values: `'AL'`, `'AK'`, `'AZ'`, ..., `'WY'` (50 states + DC)

**Enforcement:**
- Database check constraint (length = 2)
- Application-level validation (must be in valid state list)
- Cannot create profile with invalid state code

**Why:**
- Licenses and insurance are state-scoped
- Task matching requires valid state codes
- Legal compliance requires jurisdiction correctness

### Invariant 7: Willingness Flags Cannot Override Eligibility

**Rule:**
- `willingness_flags.in_home_work = true` does not grant access if `insurance_valid = false` and insurance is required
- `willingness_flags.high_risk_tasks = true` does not grant access if `trust_tier` is too low

**Enforcement:**
- Feed query logic (see Section 6 of architecture spec)
- Settings UI disables flags if eligibility not met
- Cannot bypass eligibility with willingness flags

**Why:**
- Willingness flags are preferences, not permissions
- Eligibility is determined by capability profile, not willingness
- Prevents unsafe task matching

### Invariant 8: Capability Profile Is Never Mutated Directly

**Rule:**
- Capability profile fields are never updated via `UPDATE` statements (except `updated_at`)
- Capability profile is always re-derived via `recomputeCapabilityProfile()` function
- Direct mutations are prevented by application logic (not database triggers)

**Enforcement:**
- Application-level validation (no direct UPDATE statements allowed)
- Repository pattern enforces recompute-only access
- Code review checklist includes "no direct profile mutations"

**Why:**
- Profile must be consistent with verification records
- Direct mutations cause drift (profile out of sync with source data)
- Recomputation ensures consistency

---

## Recomputation Triggers (Authoritative List)

**Capability Profile is never mutated directly. It is always re-derived from source data.**

### Trigger 1: License Verification Status Change

**Event:** License verification approved, rejected, or expired

**Source Data:**
- `verifications` table (status changed)
- `verification_records` table (license details)

**Recomputation Logic:**
```typescript
async function recomputeOnLicenseVerificationChange(
  userId: string,
  verificationId: string,
  newStatus: VerificationStatus
): Promise<void> {
  const profile = await getCapabilityProfile(userId);
  const verification = await getVerification(verificationId);

  // Re-evaluate verified_trades
  if (newStatus === 'verified') {
    // Add trade to verified_trades if not already present
    await addVerifiedTrade(profile.profile_id, {
      trade: verification.trade,
      verified_at: verification.approved_at,
      expires_at: verification.expires_at,
      verification_method: verification.method,
      verification_id: verificationId,
    });
  } else if (newStatus === 'rejected' || newStatus === 'expired') {
    // Remove trade from verified_trades
    await removeVerifiedTrade(profile.profile_id, verification.trade);
  }

  // Update verification_status
  profile.verification_status[verification.trade] = newStatus;

  // Recompute profile
  await recomputeCapabilityProfile(userId);
}
```

**When It Fires:**
- Verification approved (manual review or automated check)
- Verification rejected (manual review or automated check)
- Verification expired (expiry date passed)

### Trigger 2: Insurance Verification Status Change

**Event:** Insurance verification approved, rejected, or expired

**Source Data:**
- `insurance_verifications` table (status changed)
- `insurance_records` table (insurance details)

**Recomputation Logic:**
```typescript
async function recomputeOnInsuranceVerificationChange(
  userId: string,
  verificationId: string,
  newStatus: VerificationStatus
): Promise<void> {
  const profile = await getCapabilityProfile(userId);
  const verification = await getInsuranceVerification(verificationId);

  // Update insurance_valid
  profile.insurance_valid = newStatus === 'verified';

  // Update insurance_expires_at
  if (newStatus === 'verified' && verification.expires_at) {
    profile.insurance_expires_at = verification.expires_at;
  } else {
    profile.insurance_expires_at = undefined;
  }

  // Recompute profile
  await recomputeCapabilityProfile(userId);
}
```

**When It Fires:**
- Insurance verification approved (COI uploaded and validated)
- Insurance verification rejected (COI invalid or expired)
- Insurance verification expired (expiry date passed)

### Trigger 3: Background Check Verification Status Change

**Event:** Background check verification approved, rejected, or expired

**Source Data:**
- `background_check_verifications` table (status changed)
- `background_check_records` table (background check details)

**Recomputation Logic:**
```typescript
async function recomputeOnBackgroundCheckVerificationChange(
  userId: string,
  verificationId: string,
  newStatus: VerificationStatus
): Promise<void> {
  const profile = await getCapabilityProfile(userId);
  const verification = await getBackgroundCheckVerification(verificationId);

  // Update background_check_valid
  profile.background_check_valid = newStatus === 'verified';

  // Update background_check_expires_at
  if (newStatus === 'verified' && verification.expires_at) {
    profile.background_check_expires_at = verification.expires_at;
  } else {
    profile.background_check_expires_at = undefined;
  }

  // Recompute profile
  await recomputeCapabilityProfile(userId);
}
```

**When It Fires:**
- Background check verification approved (check completed and passed)
- Background check verification rejected (check failed or incomplete)
- Background check verification expired (expiry date passed)

### Trigger 4: Trust Tier Promotion/Demotion

**Event:** Trust tier changed (A → B, B → C, C → D, or demotion)

**Source Data:**
- `trust_scores` table (trust score updated)
- `trust_tier_changes` table (tier change log)

**Recomputation Logic:**
```typescript
async function recomputeOnTrustTierChange(
  userId: string,
  newTrustTier: TrustTier
): Promise<void> {
  const profile = await getCapabilityProfile(userId);
  const oldTrustTier = profile.trust_tier;

  // Update trust_tier
  profile.trust_tier = newTrustTier;
  profile.trust_tier_updated_at = new Date().toISOString();

  // Recompute risk_clearance (immutable mapping)
  profile.risk_clearance = getRiskClearanceForTrustTier(newTrustTier);

  // Recompute profile
  await recomputeCapabilityProfile(userId);

  // Log tier change
  await logTrustTierChange(userId, oldTrustTier, newTrustTier);
}
```

**Risk Clearance Mapping:**
```typescript
function getRiskClearanceForTrustTier(tier: TrustTier): RiskLevel[] {
  switch (tier) {
    case 1: return ['low'];           // ROOKIE
    case 2: return ['low', 'medium']; // VERIFIED
    case 3: return ['low', 'medium']; // TRUSTED
    case 4: return ['low', 'medium', 'high']; // ELITE
    default: throw new Error(`Invalid trust tier: ${tier}`);
  }
}
```

**When It Fires:**
- Trust tier promotion (trust score threshold crossed upward)
- Trust tier demotion (trust score threshold crossed downward)
- Dispute resolution (tier may be demoted)
- Trust score recalculation (tier may change)

### Trigger 5: Credential Expiry Detection

**Event:** Scheduled cron job detects expired credentials

**Source Data:**
- `verified_trades` table (expires_at < now())
- `insurance_verifications` table (expires_at < now())
- `background_check_verifications` table (expires_at < now())

**Recomputation Logic:**
```typescript
async function recomputeOnCredentialExpiry(userId: string): Promise<void> {
  const profile = await getCapabilityProfile(userId);
  const now = new Date();

  // Check verified_trades for expiry
  for (const trade of profile.verified_trades) {
    if (trade.expires_at && new Date(trade.expires_at) < now) {
      // Remove expired trade
      await removeVerifiedTrade(profile.profile_id, trade.trade);
      profile.verification_status[trade.trade] = 'expired';
    }
  }

  // Check insurance expiry
  if (profile.insurance_expires_at && new Date(profile.insurance_expires_at) < now) {
    profile.insurance_valid = false;
    profile.insurance_expires_at = undefined;
  }

  // Check background check expiry
  if (profile.background_check_expires_at && new Date(profile.background_check_expires_at) < now) {
    profile.background_check_valid = false;
    profile.background_check_expires_at = undefined;
  }

  // Recompute profile
  await recomputeCapabilityProfile(userId);

  // Send expiry notification (see Section 6)
  await sendExpiryNotification(userId, expiredCredentials);
}
```

**When It Fires:**
- Hourly cron job checks all profiles for expired credentials
- Expiry date passed (expires_at < now())

### Trigger 6: Dispute Resolution

**Event:** Dispute resolved (hustler found at fault)

**Source Data:**
- `disputes` table (dispute resolved, outcome logged)
- `trust_scores` table (trust score adjusted)

**Recomputation Logic:**
```typescript
async function recomputeOnDisputeResolution(
  userId: string,
  disputeOutcome: DisputeOutcome
): Promise<void> {
  const profile = await getCapabilityProfile(userId);

  // Trust tier may be demoted (handled by Trigger 4)
  // Capability profile may be affected if dispute involves credential fraud

  // If dispute involves credential fraud, revoke verification
  if (disputeOutcome.includesCredentialFraud) {
    const affectedTrade = disputeOutcome.fraudulentTrade;
    await removeVerifiedTrade(profile.profile_id, affectedTrade);
    profile.verification_status[affectedTrade] = 'rejected';
  }

  // Recompute profile
  await recomputeCapabilityProfile(userId);
}
```

**When It Fires:**
- Dispute resolved (poster wins, hustler found at fault)
- Credential fraud detected (verification revoked)

### Trigger 7: Manual Admin Override (Rare, Logged)

**Event:** Admin manually adjusts capability profile (rare, for corrections only)

**Source Data:**
- Admin action (logged in `admin_actions` table)
- Manual override reason (logged in `admin_actions` table)

**Recomputation Logic:**
```typescript
async function recomputeOnManualAdminOverride(
  userId: string,
  overrideReason: string,
  adminUserId: string
): Promise<void> {
  const profile = await getCapabilityProfile(userId);

  // Admin override does not mutate profile directly
  // Instead, it triggers recomputation with override flags

  // Log admin action
  await logAdminAction({
    admin_user_id: adminUserId,
    target_user_id: userId,
    action_type: 'capability_profile_override',
    reason: overrideReason,
    timestamp: new Date(),
  });

  // Recompute profile (with override flags if needed)
  await recomputeCapabilityProfile(userId, { allowAdminOverrides: true });

  // Alert security team
  await alertSecurityTeam({
    action: 'capability_profile_override',
    admin_user_id: adminUserId,
    target_user_id: userId,
    reason: overrideReason,
  });
}
```

**When It Fires:**
- Manual correction (data corruption fix)
- Appeals process (admin review and override)
- Legal requirement (compliance override)

**Audit Requirements:**
- All admin overrides must be logged
- Security team must be notified
- Override reason must be documented

---

## Recomputation Algorithm (Authoritative)

### Function: `recomputeCapabilityProfile()`

**Purpose:** Re-derive capability profile from source data (verification records, trust tier, expiries).

**Input:**
```typescript
{
  userId: string;
  options?: {
    allowAdminOverrides?: boolean; // Only for manual admin overrides
  };
}
```

**Output:**
```typescript
CapabilityProfile // Updated profile
```

**Algorithm (Pseudocode):**
```typescript
async function recomputeCapabilityProfile(
  userId: string,
  options?: RecomputeOptions
): Promise<CapabilityProfile> {
  // 1. Load current profile
  const profile = await getCapabilityProfile(userId);
  if (!profile) {
    throw new Error('Capability profile not found');
  }

  // 2. Load source data
  const verifications = await getVerifications(userId);
  const trustTier = await getTrustTier(userId);
  const insuranceVerification = await getInsuranceVerification(userId);
  const backgroundCheckVerification = await getBackgroundCheckVerification(userId);

  // 3. Re-evaluate verified_trades
  profile.verified_trades = [];
  for (const verification of verifications) {
    if (verification.status === 'verified' && !isExpired(verification)) {
      profile.verified_trades.push({
        trade: verification.trade,
        verified_at: verification.approved_at,
        expires_at: verification.expires_at,
        verification_method: verification.method,
        verification_id: verification.id,
      });
      profile.verification_status[verification.trade] = 'verified';
    } else {
      profile.verification_status[verification.trade] = verification.status;
    }
  }

  // 4. Re-evaluate trust_tier and risk_clearance
  profile.trust_tier = trustTier;
  profile.trust_tier_updated_at = new Date().toISOString();
  profile.risk_clearance = getRiskClearanceForTrustTier(trustTier);

  // 5. Re-evaluate insurance_valid
  if (insuranceVerification && insuranceVerification.status === 'verified' && !isExpired(insuranceVerification)) {
    profile.insurance_valid = true;
    profile.insurance_expires_at = insuranceVerification.expires_at;
  } else {
    profile.insurance_valid = false;
    profile.insurance_expires_at = undefined;
  }

  // 6. Re-evaluate background_check_valid
  if (backgroundCheckVerification && backgroundCheckVerification.status === 'verified' && !isExpired(backgroundCheckVerification)) {
    profile.background_check_valid = true;
    profile.background_check_expires_at = backgroundCheckVerification.expires_at;
  } else {
    profile.background_check_valid = false;
    profile.background_check_expires_at = undefined;
  }

  // 7. Update expires_at map
  profile.expires_at = {};
  for (const trade of profile.verified_trades) {
    if (trade.expires_at) {
      profile.expires_at[`${trade.trade}_license`] = trade.expires_at;
    }
  }
  if (profile.insurance_expires_at) {
    profile.expires_at['insurance'] = profile.insurance_expires_at;
  }
  if (profile.background_check_expires_at) {
    profile.expires_at['background_check'] = profile.background_check_expires_at;
  }

  // 8. Update updated_at timestamp
  profile.updated_at = new Date().toISOString();

  // 9. Validate invariants
  validateCapabilityProfileInvariants(profile);

  // 10. Persist updated profile (transaction-scoped)
  await saveCapabilityProfile(profile);

  // 11. Invalidate feed cache (if exists)
  await invalidateFeedCache(userId);

  return profile;
}
```

**Transaction Scope:**
- Recomputation is atomic (all-or-nothing)
- If validation fails, transaction is rolled back
- Feed cache invalidation happens after successful commit

**Validation:**
```typescript
function validateCapabilityProfileInvariants(profile: CapabilityProfile): void {
  // Invariant 1: Trust tier → risk clearance mapping
  const expectedRiskClearance = getRiskClearanceForTrustTier(profile.trust_tier);
  if (JSON.stringify(profile.risk_clearance.sort()) !== JSON.stringify(expectedRiskClearance.sort())) {
    throw new Error(`Risk clearance mismatch for trust tier ${profile.trust_tier}`);
  }

  // Invariant 2: Verified trades must have active verification
  for (const trade of profile.verified_trades) {
    if (profile.verification_status[trade.trade] !== 'verified') {
      throw new Error(`Verified trade ${trade.trade} has non-verified status`);
    }
  }

  // Invariant 3: Expired credentials must be excluded
  const now = new Date();
  for (const trade of profile.verified_trades) {
    if (trade.expires_at && new Date(trade.expires_at) < now) {
      throw new Error(`Verified trade ${trade.trade} is expired`);
    }
  }
  if (profile.insurance_expires_at && new Date(profile.insurance_expires_at) < now) {
    if (profile.insurance_valid) {
      throw new Error('Insurance is expired but marked as valid');
    }
  }
  if (profile.background_check_expires_at && new Date(profile.background_check_expires_at) < now) {
    if (profile.background_check_valid) {
      throw new Error('Background check is expired but marked as valid');
    }
  }

  // Invariant 6: Location state must be valid
  if (!isValidUSStateCode(profile.location_state)) {
    throw new Error(`Invalid location state: ${profile.location_state}`);
  }

  // Invariant 8: Capability profile is never mutated directly
  // (This is enforced by application logic, not validation)
}
```

---

## Illegal States (Prevented by Invariants)

### Illegal State 1: Verified Trade Without Active Verification

**State:**
```typescript
{
  verified_trades: [{ trade: 'electrician', ... }],
  verification_status: { electrician: 'pending' }
}
```

**Prevention:**
- Invariant 2 enforces `verification_status[trade] === 'verified'` for all `verified_trades`
- Recomputation algorithm excludes non-verified trades from `verified_trades`
- Cannot insert `verified_trade` without valid `verification_id`

### Illegal State 2: Expired Credential in Verified Trades

**State:**
```typescript
{
  verified_trades: [{ trade: 'electrician', expires_at: '2025-01-01' }], // Expired
  // Current date: 2025-01-17
}
```

**Prevention:**
- Invariant 3 enforces expiry check (expired trades removed)
- Recomputation algorithm excludes expired trades
- Expiry detection cron job triggers recomputation

### Illegal State 3: Trust Tier Mismatch with Risk Clearance

**State:**
```typescript
{
  trust_tier: 1,  // ROOKIE
  risk_clearance: ['low', 'medium'] // Should be ['low']
}
```

**Prevention:**
- Invariant 1 enforces trust tier → risk clearance mapping
- Database check constraint prevents mismatches
- Recomputation algorithm derives risk clearance from trust tier

### Illegal State 4: Insurance Valid Without Verification

**State:**
```typescript
{
  insurance_valid: true,
  // No insurance verification record
}
```

**Prevention:**
- Invariant 4 enforces insurance validity gated by verification
- Recomputation algorithm sets `insurance_valid = false` if no verification
- Cannot set `insurance_valid = true` without valid verification

### Illegal State 5: Invalid Location State

**State:**
```typescript
{
  location_state: 'XX' // Invalid state code
}
```

**Prevention:**
- Invariant 6 enforces valid US state codes
- Database check constraint (length = 2)
- Application-level validation (must be in valid state list)

---

## Upgrade Signal Contract (Product-Critical)

### Purpose

Show users how many gigs they could unlock by verifying a trade.

**Rule:**
> "Verify Electrician License to unlock 14 gigs near you"

This must be **computed, not estimated**.

### Deterministic Rule

**Only show upgrade paths that unlock real, currently available tasks.**

**Never show hypothetical value.**

### Algorithm

```typescript
async function getUpgradePaths(userId: string): Promise<UpgradePath[]> {
  const profile = await getCapabilityProfile(userId);
  const claimedTrades = await getClaimedTrades(userId); // From capability_claims

  const upgradePaths: UpgradePath[] = [];

  for (const trade of claimedTrades) {
    // Skip if trade is already verified
    if (profile.verified_trades.some(vt => vt.trade === trade)) {
      continue;
    }

    // Count tasks that would be unlocked by verifying this trade
    const lockedTaskCount = await countLockedTasksForTrade(userId, trade);

    // Only show if there are real, currently available tasks
    if (lockedTaskCount > 0) {
      upgradePaths.push({
        trade,
        locked_task_count: lockedTaskCount,
        unlock_message: `Verify ${trade} License to unlock ${lockedTaskCount} gigs near you`,
      });
    }
  }

  return upgradePaths;
}

async function countLockedTasksForTrade(userId: string, trade: string): Promise<number> {
  const profile = await getCapabilityProfile(userId);

  // Build filter for tasks that would be eligible if trade was verified
  const hypotheticalFilter = {
    required_trade: trade,
    required_trust_tier: { $lte: profile.trust_tier },
    risk_level: { $in: profile.risk_clearance },
    location_state: profile.location_state,
    status: 'posted',
    assigned_to: null,
    // ... other filters match current profile
  };

  // Count tasks matching hypothetical filter
  const count = await TaskRepository.count(hypotheticalFilter);

  return count;
}
```

### Update Frequency

- **Real-time:** Upgrade paths recomputed on feed request (if cached, invalidated on profile update)
- **Caching:** Upgrade paths cached for 5 minutes (prevents repeated queries)
- **Invalidation:** Upgrade paths invalidated when:
  - Capability profile updates (recomputation)
  - New tasks posted (feed updated)
  - Tasks assigned/removed (feed updated)

### Display Rules

**Settings → Work Eligibility Screen:**
- Show upgrade path only if `locked_task_count > 0`
- Display: "Verify [Trade] License to unlock [N] gigs near you"
- Action button: "Start Verification"

**Onboarding Summary Screen (PHASE 7):**
- Show upgrade paths unlocked by verification
- Display: Same format as Settings
- Action button: "Start Verification"

**Feed Empty State:**
- If feed is empty, show upgrade paths as suggestions
- Display: "Unlock more gigs by verifying [Trade]"

### Forbidden Displays

- ❌ "Verify to unlock up to [N] gigs" (hypothetical, not real)
- ❌ "Verify to unlock potential gigs" (vague, not actionable)
- ❌ Estimated counts (must be computed from real tasks)

---

## Expiry UX (Silent but Ruthless)

### Purpose

When credentials expire, capabilities invalidate immediately.

No warnings in the feed. Only clear alerts in Settings.

This is how serious systems behave.

### Single Allowed Notification

**Location:** Settings → Work Eligibility → [Trade/Insurance/Background Check] → Alert Badge

**Timing:**
- **Before Expiry:** No notification (feed unchanged)
- **On Expiry:** Badge appears immediately (recomputation triggers)
- **After Expiry:** Badge persists until renewal

**Alert Badge:**
```
[Trade Name]
Status: "Expired" (red badge, warning icon)
Expiry: "Expired: May 1, 2026"
Action: "Renew Verification" button (prominent, green)
```

**Notification Message (Push/Email, Optional):**
```
Subject: "Your [Trade] license has expired"

Body:
"Your [Trade] license expired on [Date]. Renew to restore access to [Trade] tasks.

Renew now: [Link to Settings → Work Eligibility]"
```

**Language (Non-Negotiable Tone):**
- **Factual:** "Expired on [Date]" (not "oops, your license expired")
- **Actionable:** "Renew to restore access" (not "please renew when convenient")
- **No appeals:** No "temporary grace period" language
- **No confusion:** Clear what expired and what action is required

### Single Allowed Recovery Path

**Path:** Settings → Work Eligibility → [Trade/Insurance/Background Check] → "Renew Verification" → Verification Flow

**Steps:**
1. User navigates to Settings → Work Eligibility
2. User sees expired badge on trade/insurance/background check
3. User clicks "Renew Verification" button
4. User is taken to verification flow (upload new credential, verify)
5. On verification approval, profile recomputes (expiry cleared)

**No Appeals:**
- No "request exception" option
- No "temporary grace period" toggle
- No "contact support to restore access" path (except for technical errors)

**Grace Period:**
- **None.** Expired credentials immediately invalidate capabilities.
- Feed updates instantly (tasks disappear immediately).
- Settings shows clear renewal path (no ambiguity).

### Feed Behavior on Expiry

**Before Expiry:**
- Feed shows eligible tasks (normal behavior)
- No warnings or disabled cards

**On Expiry:**
- Feed recomputes immediately (expired tasks removed)
- Feed shows remaining eligible tasks (or empty state)
- No "your license expired" messaging in feed

**After Expiry:**
- Feed continues to show only eligible tasks
- Settings is the only place expiry is visible
- No feed-based expiry reminders

### What This Prevents

- ❌ Users seeing expired credential warnings in feed (feed is clean)
- ❌ Confusion about which tasks are affected (Settings shows clear status)
- ❌ Support tickets asking "why can't I see tasks?" (Settings explains)
- ❌ Appeals process for expired credentials (renewal is the only path)

---

## This Schema & Invariants Document is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this schema and invariants exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
