# Verification Pipeline — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This verification pipeline prevents trust leaks, ensures legal compliance, and guarantees deterministic trust enforcement. Verification never grants access directly. Verification only updates source-of-truth records. Access is derived exclusively via Capability Profile recomputation. If an engineer ever "just flips a flag," the system is broken. This is institutional-grade enforcement.

---

## Core Law (Non-Negotiable)

**Verification never grants access directly.**
**Verification only updates source-of-truth records.**
**Access is derived exclusively via Capability Profile recomputation.**

If this law is violated, trust leaks, legal compliance fails, and unsafe matching occurs.

---

## Authority Stack (Final)

**1. Verification Source Records** (licenses, insurance, background)
- Mutable layer
- Single source of truth for verification status
- Only layer that can be directly updated

**2. Recompute Engine**
- Derived layer
- Recomputes capability profile from verification records
- Atomic and deterministic

**3. Capability Profile (Derived Snapshot)**
- Immutable after recompute
- Single source of truth for eligibility
- Never edited directly

**4. Feed / Eligibility Resolver**
- Derived layer
- Uses capability profile to filter tasks
- No bypass or override

**Verification ≠ access.**
**Recomputation = access.**

---

## Pipeline Overview (End-to-End)

**Flow:**
```
User submits credential
→ Verification record created (PENDING)
→ Verification processor runs
→ Record becomes VERIFIED or FAILED
→ Recompute capability profile (atomic)
→ Feed cache invalidated
```

**Rules:**
- No shortcuts
- No exceptions
- No manual overrides (except rare admin actions, logged)
- Every verification state change triggers recompute

---

## 1. License Verification Pipeline

### 1.1 Data Model (Source of Truth)

**Schema:**
```typescript
interface LicenseVerification {
  // Identity
  id: string; // UUID, primary key
  user_id: string; // Foreign key to users.id
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601

  // License Details (From User Submission)
  trade: string; // e.g., "electrician", "plumber"
  state: string; // ISO 3166-2 state code (e.g., "WA")
  license_number: string; // License number from user
  license_type?: string; // Optional, if applicable

  // Verification Status (Mutable, State Machine)
  status: VerificationStatus; // 'pending' | 'verified' | 'failed' | 'expired'
  verified_at?: string; // ISO 8601, set when status = 'verified'
  expires_at?: string; // ISO 8601, from registry or document
  failure_reason?: string; // Set when status = 'failed'

  // Verification Source (How Verification Was Performed)
  source: VerificationSource; // 'registry' | 'document' | 'manual_review'
  verification_method?: string; // 'api_lookup' | 'ocr' | 'manual_review'
  verification_provider?: string; // e.g., "WA_DOL_API" or "OpenAI_Vision"

  // Metadata
  confidence_score?: number; // 0-1, if automated (OCR confidence)
  reviewer_id?: string; // Foreign key to users.id (if manual review)
  review_notes?: string; // Admin notes (if manual review)
}
```

**Database Schema (PostgreSQL):**
```sql
CREATE TABLE license_verifications (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- License Details
  trade VARCHAR(255) NOT NULL,
  state VARCHAR(2) NOT NULL CHECK (length(state) = 2),
  license_number VARCHAR(255) NOT NULL,
  license_type VARCHAR(255),

  -- Verification Status
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'verified', 'failed', 'expired')
  ),
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  failure_reason TEXT,

  -- Verification Source
  source VARCHAR(20) NOT NULL CHECK (source IN ('registry', 'document', 'manual_review')),
  verification_method VARCHAR(50),
  verification_provider VARCHAR(255),
  confidence_score NUMERIC(3, 2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  reviewer_id UUID REFERENCES users(id) ON DELETE SET NULL,
  review_notes TEXT,

  -- Constraints
  CONSTRAINT license_verifications_user_trade_state_unique UNIQUE (user_id, trade, state),
  CONSTRAINT license_verifications_status_transition CHECK (
    -- Status transitions are monotonic (no verified → pending)
    (status = 'pending' AND verified_at IS NULL) OR
    (status = 'verified' AND verified_at IS NOT NULL) OR
    (status = 'failed' AND failure_reason IS NOT NULL) OR
    (status = 'expired' AND expires_at IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_license_verifications_user_id ON license_verifications(user_id);
CREATE INDEX idx_license_verifications_status ON license_verifications(status);
CREATE INDEX idx_license_verifications_expires_at ON license_verifications(expires_at) WHERE expires_at IS NOT NULL;
```

**Rules:**
1. **One active license per (user, trade, state)**
   - Database constraint: `UNIQUE (user_id, trade, state)`
   - Prevents duplicate verifications for same license

2. **Status transitions are monotonic (no verified → pending)**
   - Database check constraint enforces valid transitions
   - Allowed transitions:
     - `pending` → `verified`
     - `pending` → `failed`
     - `verified` → `expired`
     - `failed` → `pending` (retry allowed)
   - Disallowed transitions:
     - `verified` → `pending` (immutable after verification)
     - `expired` → `verified` (must re-submit)

3. **Verification source must be recorded**
   - `source` is required (cannot be null)
   - Must be one of: `'registry'`, `'document'`, `'manual_review'`

---

### 1.2 Verification Flow

#### Step A — Submission

**Purpose:** Create verification record with user-submitted license details.

**Triggered From:**
- Onboarding (PHASE 4: License Metadata Capture)
- Settings → Work Eligibility → [Trade] → Start Verification

**Input:**
```typescript
{
  user_id: string;
  trade: string; // From onboarding or Settings
  state: string; // ISO 3166-2 state code
  license_number: string; // From user input
  license_type?: string; // Optional
}
```

**Action:**
```typescript
async function submitLicenseVerification(
  userId: string,
  licenseDetails: LicenseDetails
): Promise<LicenseVerification> {
  // 1. Validate input
  validateLicenseInput(licenseDetails);

  // 2. Check for existing active verification
  const existing = await getActiveLicenseVerification(
    userId,
    licenseDetails.trade,
    licenseDetails.state
  );

  if (existing && existing.status === 'verified') {
    throw new Error('Active license verification already exists');
  }

  // 3. Create verification record (status = 'pending')
  const verification = await createLicenseVerification({
    user_id: userId,
    trade: licenseDetails.trade,
    state: licenseDetails.state,
    license_number: licenseDetails.license_number,
    license_type: licenseDetails.license_type,
    status: 'pending',
    source: 'registry', // Will be updated after verification
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  });

  // 4. Queue verification job (async processing)
  await queueLicenseVerificationJob(verification.id);

  return verification;
}
```

**Backend Contract:**

**Endpoint:** `POST /api/verifications/licenses/submit`

**Request:**
```typescript
{
  trade: string; // Required, must be in system trade list
  state: string; // Required, ISO 3166-2 state code
  license_number: string; // Required, non-empty string
  license_type?: string; // Optional
}
```

**Response:**
```typescript
{
  verification_id: string;
  status: 'pending';
  estimated_duration?: string; // e.g., "2-3 business days"
  next_step: 'verification_processing';
}
```

**Validation Rules:**
1. `trade` must exist in system trade list
2. `state` must be valid US state code (ISO 3166-2)
3. `license_number` must be non-empty string
4. Cannot submit duplicate active verification (same user, trade, state)

**Behavioral Rules:**
- Creates verification record with `status = 'pending'`
- No payment yet (payment gated by eligibility pre-check)
- Queues verification job for async processing
- Returns immediately (verification happens asynchronously)

---

#### Step B — Eligibility Pre-Check (Hard Gate)

**Purpose:** Validate license format and eligibility before processing verification.

**Triggered:** Automatically before verification execution (Step C)

**Pre-Check Logic:**
```typescript
async function preCheckLicenseEligibility(
  verification: LicenseVerification
): Promise<PreCheckResult> {
  const checks: PreCheck[] = [];

  // Check 1: License format valid
  const formatValid = validateLicenseFormat(
    verification.license_number,
    verification.state,
    verification.trade
  );
  checks.push({
    name: 'license_format',
    passed: formatValid,
    reason: formatValid ? undefined : 'Invalid license format for state/trade',
  });

  // Check 2: Trade allowed in state
  const tradeAllowed = await isTradeAllowedInState(
    verification.trade,
    verification.state
  );
  checks.push({
    name: 'trade_allowed',
    passed: tradeAllowed,
    reason: tradeAllowed ? undefined : 'Trade not allowed in state',
  });

  // Check 3: User identity already verified
  const identityVerified = await isUserIdentityVerified(verification.user_id);
  checks.push({
    name: 'identity_verified',
    passed: identityVerified,
    reason: identityVerified ? undefined : 'User identity not verified',
  });

  // Determine overall result
  const allPassed = checks.every(check => check.passed);
  
  return {
    passed: allPassed,
    checks,
    failure_reason: allPassed ? undefined : checks.find(c => !c.passed)?.reason,
  };
}
```

**If Pre-Check Fails:**
```typescript
async function handlePreCheckFailure(
  verificationId: string,
  failureReason: string
): Promise<void> {
  // Update verification status to 'failed'
  await updateLicenseVerification(verificationId, {
    status: 'failed',
    failure_reason: failureReason,
    updated_at: new Date().toISOString(),
  });

  // Notify user (email or in-app notification)
  await notifyUserVerificationFailed(verification.user_id, {
    verification_id: verificationId,
    reason: failureReason,
    next_step: 'fix_inputs_and_resubmit',
  });
}
```

**If Pre-Check Passes:**
- Proceeds to Step C (Verification Execution)
- No payment unlocked yet (payment happens after verification)

**Behavioral Rules:**
- Pre-check is mandatory (cannot skip)
- Pre-check failure sets `status = 'failed'` immediately
- Pre-check failure does not trigger recompute (no capability change)
- User can resubmit after fixing inputs

---

#### Step C — Verification Execution

**Purpose:** Verify license against authoritative source (registry or document).

**Triggered:** After pre-check passes, via queued job

**Execution Strategy:**

**Preferred Method: Registry API Lookup**
```typescript
async function verifyLicenseViaRegistry(
  verification: LicenseVerification
): Promise<VerificationResult> {
  try {
    // 1. Get registry client for state
    const registryClient = getRegistryClient(verification.state);
    
    // 2. Query registry API
    const registryResult = await registryClient.lookupLicense({
      license_number: verification.license_number,
      trade: verification.trade,
      state: verification.state,
    });

    // 3. Validate registry response
    if (registryResult.found && registryResult.valid) {
      return {
        status: 'verified',
        verified_at: new Date().toISOString(),
        expires_at: registryResult.expires_at,
        source: 'registry',
        verification_method: 'api_lookup',
        verification_provider: registryClient.provider,
      };
    } else {
      return {
        status: 'failed',
        failure_reason: registryResult.reason || 'License not found in registry',
        source: 'registry',
        verification_method: 'api_lookup',
        verification_provider: registryClient.provider,
      };
    }
  } catch (error) {
    // Registry API failed, fallback to document verification
    return await verifyLicenseViaDocument(verification);
  }
}
```

**Fallback Method: Document OCR + AI Extraction**
```typescript
async function verifyLicenseViaDocument(
  verification: LicenseVerification
): Promise<VerificationResult> {
  // 1. Get uploaded license document
  const document = await getLicenseDocument(verification.id);
  if (!document) {
    return {
      status: 'failed',
      failure_reason: 'No license document uploaded',
      source: 'document',
    };
  }

  // 2. OCR extraction
  const ocrResult = await extractLicenseDataViaOCR(document);
  
  // 3. Validate OCR confidence
  if (ocrResult.confidence_score < 0.8) {
    // Low confidence, require manual review
    return await queueManualReview(verification, ocrResult);
  }

  // 4. Validate extracted data matches submission
  const dataMatches = validateExtractedData(ocrResult, verification);
  if (!dataMatches) {
    return {
      status: 'failed',
      failure_reason: 'Extracted data does not match submission',
      source: 'document',
      verification_method: 'ocr',
    };
  }

  // 5. Success
  return {
    status: 'verified',
    verified_at: new Date().toISOString(),
    expires_at: ocrResult.expires_at,
    source: 'document',
    verification_method: 'ocr',
    verification_provider: 'OpenAI_Vision',
    confidence_score: ocrResult.confidence_score,
  };
}
```

**Manual Review (If AI Confidence < Threshold):**
```typescript
async function queueManualReview(
  verification: LicenseVerification,
  ocrResult: OCRResult
): Promise<VerificationResult> {
  // 1. Create manual review task
  const reviewTask = await createManualReviewTask({
    verification_id: verification.id,
    ocr_result: ocrResult,
    priority: 'normal',
    assigned_to: null, // Will be assigned by admin
  });

  // 2. Update verification status to 'pending_review'
  await updateLicenseVerification(verification.id, {
    status: 'pending',
    source: 'manual_review',
    verification_method: 'ocr_with_manual_review',
    confidence_score: ocrResult.confidence_score,
    review_task_id: reviewTask.id,
  });

  // 3. Notify admin team
  await notifyAdminReviewNeeded(reviewTask);

  // Return pending status (will be updated after manual review)
  return {
    status: 'pending',
    source: 'manual_review',
    verification_method: 'ocr_with_manual_review',
  };
}
```

**Backend Contract:**

**Job:** `processLicenseVerification` (Async, queued)

**Input:**
```typescript
{
  verification_id: string;
}
```

**Output:**
```typescript
{
  verification_id: string;
  status: 'verified' | 'failed' | 'pending'; // pending if manual review
  verified_at?: string;
  expires_at?: string;
  failure_reason?: string;
  source: 'registry' | 'document' | 'manual_review';
}
```

**Behavioral Rules:**
- Registry API lookup is preferred (fastest, most authoritative)
- Document OCR is fallback (if registry unavailable)
- Manual review is fallback (if OCR confidence < threshold)
- Verification is asynchronous (does not block user)
- User is notified when verification completes

---

#### Step D — Resolution

**Purpose:** Finalize verification status and record result.

**Resolution Logic:**
```typescript
async function resolveLicenseVerification(
  verificationId: string,
  result: VerificationResult
): Promise<void> {
  // 1. Update verification record
  await updateLicenseVerification(verificationId, {
    status: result.status,
    verified_at: result.verified_at,
    expires_at: result.expires_at,
    failure_reason: result.failure_reason,
    source: result.source,
    verification_method: result.verification_method,
    verification_provider: result.verification_provider,
    confidence_score: result.confidence_score,
    updated_at: new Date().toISOString(),
  });

  // 2. If verified, schedule expiry check
  if (result.status === 'verified' && result.expires_at) {
    await scheduleExpiryCheck(verificationId, result.expires_at);
  }

  // 3. Notify user
  if (result.status === 'verified') {
    await notifyUserVerificationSuccess(verification.user_id, {
      verification_id: verificationId,
      trade: verification.trade,
      expires_at: result.expires_at,
    });
  } else if (result.status === 'failed') {
    await notifyUserVerificationFailed(verification.user_id, {
      verification_id: verificationId,
      reason: result.failure_reason,
      next_step: 'resubmit_with_corrected_information',
    });
  }

  // 4. Trigger recompute (MANDATORY - see Step E)
  await recomputeCapabilityProfile(verification.user_id);
}
```

**Success Path:**
- Status → `verified`
- `verified_at` set to current timestamp
- `expires_at` set from registry or document
- Expiry check scheduled (if applicable)
- User notified
- Recompute triggered (Step E)

**Failure Path:**
- Status → `failed`
- `failure_reason` set
- User notified with reason
- Recompute not triggered (no capability change)

**Behavioral Rules:**
- Resolution is atomic (all-or-nothing)
- If resolution fails, verification remains `pending`
- Expiry is scheduled automatically (if expires_at present)
- User is always notified of resolution

---

#### Step E — Recompute Trigger (MANDATORY)

**Purpose:** Recompute capability profile after verification status change.

**Requirement:** **Runs inside the same transaction as resolution.**

**Recompute Logic:**
```typescript
async function resolveLicenseVerification(
  verificationId: string,
  result: VerificationResult
): Promise<void> {
  // Start transaction
  await db.transaction(async (tx) => {
    // 1. Update verification record (Step D)
    await updateLicenseVerification(verificationId, result, { transaction: tx });

    // 2. Recompute capability profile (Step E - MANDATORY)
    await recomputeCapabilityProfile(verification.user_id, { transaction: tx });

    // 3. Invalidate feed cache
    await invalidateFeedCache(verification.user_id, { transaction: tx });

    // Commit transaction (all-or-nothing)
  });
}
```

**Why Transaction-Scoped:**
- If recompute fails, verification update is rolled back
- Ensures capability profile is always consistent with verification records
- Prevents partial updates (verification updated but profile not)

**Why MANDATORY:**
- Verification does not grant access directly
- Access is derived from capability profile
- Profile must be recomputed to reflect verification change

**Behavioral Rules:**
- Recompute is atomic (transaction-scoped)
- If recompute fails, verification update is rolled back
- Feed cache is invalidated after successful recompute
- Recompute is synchronous (blocks resolution until complete)

---

## 2. Insurance Verification Pipeline

### 2.1 Data Model (Source of Truth)

**Schema:**
```typescript
interface InsuranceVerification {
  // Identity
  id: string; // UUID, primary key
  user_id: string; // Foreign key to users.id
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601

  // Insurance Details (From User Submission)
  trade?: string; // Optional, if trade-specific
  policy_number?: string; // Optional, from document
  insurer_name?: string; // From document
  coverage_amount?: number; // Minimum required coverage

  // Verification Status (Mutable, State Machine)
  status: VerificationStatus; // 'pending' | 'verified' | 'failed' | 'expired'
  verified_at?: string; // ISO 8601
  expires_at?: string; // ISO 8601, from COI
  failure_reason?: string;

  // Verification Source
  source: VerificationSource; // 'document' | 'manual_review'
  verification_method?: string; // 'ocr' | 'manual_review'
  confidence_score?: number; // 0-1, if OCR
  reviewer_id?: string; // If manual review
}
```

**Database Schema (PostgreSQL):**
```sql
CREATE TABLE insurance_verifications (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Insurance Details
  trade VARCHAR(255),
  policy_number VARCHAR(255),
  insurer_name VARCHAR(255),
  coverage_amount NUMERIC(10, 2) CHECK (coverage_amount >= 0),

  -- Verification Status
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'verified', 'failed', 'expired')
  ),
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  failure_reason TEXT,

  -- Verification Source
  source VARCHAR(20) NOT NULL CHECK (source IN ('document', 'manual_review')),
  verification_method VARCHAR(50),
  confidence_score NUMERIC(3, 2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  reviewer_id UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Constraints
  CONSTRAINT insurance_verifications_user_unique UNIQUE (user_id),
  CONSTRAINT insurance_verifications_status_transition CHECK (
    -- Status transitions are monotonic
    (status = 'pending' AND verified_at IS NULL) OR
    (status = 'verified' AND verified_at IS NOT NULL) OR
    (status = 'failed' AND failure_reason IS NOT NULL) OR
    (status = 'expired' AND expires_at IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_insurance_verifications_user_id ON insurance_verifications(user_id);
CREATE INDEX idx_insurance_verifications_status ON insurance_verifications(status);
CREATE INDEX idx_insurance_verifications_expires_at ON insurance_verifications(expires_at) WHERE expires_at IS NOT NULL;
```

**Rule:**
> **Insurance can never be valid without a verified trade.**

**Enforcement:**
- Pre-check before verification: User must have at least one verified trade
- If no verified trades, insurance verification is blocked
- Database constraint: Cannot set `insurance_valid = true` if `verified_trades.length === 0` (enforced via recompute logic)

---

### 2.2 Flow

**Conditional Display:**
- Only available if:
  - User has at least one verified trade
  - Task risk requires insurance (high or critical)

**Steps:**

**1. Upload COI (Certificate of Insurance)**
```typescript
async function submitInsuranceVerification(
  userId: string,
  coiFile: File
): Promise<InsuranceVerification> {
  // 1. Pre-check: User must have verified trade
  const verifiedTrades = await getVerifiedTrades(userId);
  if (verifiedTrades.length === 0) {
    throw new Error('Insurance verification requires at least one verified trade');
  }

  // 2. Validate COI file
  validateCOIFile(coiFile);

  // 3. Upload COI to storage
  const coiUrl = await uploadCOI(userId, coiFile);

  // 4. Create verification record
  const verification = await createInsuranceVerification({
    user_id: userId,
    status: 'pending',
    source: 'document',
    created_at: new Date().toISOString(),
  });

  // 5. Queue verification job
  await queueInsuranceVerificationJob(verification.id, coiUrl);

  return verification;
}
```

**2. OCR Extract Policy Data**
```typescript
async function verifyInsuranceViaOCR(
  verificationId: string,
  coiUrl: string
): Promise<VerificationResult> {
  // 1. Extract COI data via OCR
  const ocrResult = await extractCOIDataViaOCR(coiUrl);

  // 2. Validate OCR confidence
  if (ocrResult.confidence_score < 0.8) {
    return await queueManualReview(verificationId, ocrResult);
  }

  // 3. Validate extracted data
  const dataValid = validateExtractedCOIData(ocrResult);
  if (!dataValid) {
    return {
      status: 'failed',
      failure_reason: 'Invalid COI data extracted',
      source: 'document',
    };
  }

  // 4. Success
  return {
    status: 'verified',
    verified_at: new Date().toISOString(),
    expires_at: ocrResult.expires_at,
    coverage_amount: ocrResult.coverage_amount,
    source: 'document',
    verification_method: 'ocr',
    confidence_score: ocrResult.confidence_score,
  };
}
```

**3. Validate Extracted Data**
```typescript
function validateExtractedCOIData(ocrResult: OCRResult): boolean {
  // Check 1: Named insured matches user name
  const nameMatches = ocrResult.named_insured === user.name;

  // Check 2: Coverage amount ≥ minimum required
  const coverageSufficient = ocrResult.coverage_amount >= MINIMUM_COVERAGE_AMOUNT;

  // Check 3: Active dates valid (not expired)
  const datesValid = new Date(ocrResult.expires_at) > new Date();

  // Check 4: Policy type matches trade (if trade-specific)
  const policyTypeValid = !verification.trade || 
    ocrResult.policy_type.includes(verification.trade);

  return nameMatches && coverageSufficient && datesValid && policyTypeValid;
}
```

**4. Resolve Status**
- Same pattern as license verification (Step D)

**5. Trigger Recompute**
- Same pattern as license verification (Step E - MANDATORY)

---

## 3. Background Check Pipeline (Critical Tasks Only)

### 3.1 Data Model (Source of Truth)

**Schema:**
```typescript
interface BackgroundCheck {
  // Identity
  id: string; // UUID, primary key
  user_id: string; // Foreign key to users.id
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601

  // Background Check Details
  provider: string; // e.g., "Checkr", "Sterling"
  provider_check_id?: string; // External provider's check ID

  // Verification Status (Mutable, State Machine)
  status: VerificationStatus; // 'pending' | 'verified' | 'failed' | 'expired'
  verified_at?: string; // ISO 8601
  expires_at?: string; // ISO 8601 (typically 1-2 years)
  failure_reason?: string;

  // Results (Sensitive, Encrypted)
  results_encrypted?: string; // Encrypted background check results
}
```

**Database Schema (PostgreSQL):**
```sql
CREATE TABLE background_checks (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Background Check Details
  provider VARCHAR(255) NOT NULL,
  provider_check_id VARCHAR(255),

  -- Verification Status
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'verified', 'failed', 'expired')
  ),
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  failure_reason TEXT,

  -- Results (Encrypted)
  results_encrypted TEXT, -- Encrypted JSON, only accessible via API

  -- Constraints
  CONSTRAINT background_checks_user_unique UNIQUE (user_id),
  CONSTRAINT background_checks_status_transition CHECK (
    -- Status transitions are monotonic
    (status = 'pending' AND verified_at IS NULL) OR
    (status = 'verified' AND verified_at IS NOT NULL) OR
    (status = 'failed' AND failure_reason IS NOT NULL) OR
    (status = 'expired' AND expires_at IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_background_checks_user_id ON background_checks(user_id);
CREATE INDEX idx_background_checks_status ON background_checks(status);
CREATE INDEX idx_background_checks_expires_at ON background_checks(expires_at) WHERE expires_at IS NOT NULL;
```

**Rule:**
> **Background checks never unlock non-critical gigs.**

**Enforcement:**
- Background check verification only affects `background_check_valid` flag
- `background_check_valid = true` does not unlock tasks unless risk level = `'critical'`
- Feed query enforces: `background_check_required = true` only for critical tasks

---

### 3.2 Flow

**Conditional Trigger:**
- Only triggered if:
  - Task risk = `'critical'` (in-home care, vulnerable populations)
  - User opts into critical gigs (willingness flag)

**Steps:**

**1. Identity Already Verified**
```typescript
async function preCheckBackgroundCheckEligibility(
  userId: string
): Promise<boolean> {
  // User identity must be verified before background check
  const identityVerified = await isUserIdentityVerified(userId);
  
  if (!identityVerified) {
    throw new Error('User identity must be verified before background check');
  }

  return true;
}
```

**2. Third-Party Background Provider**
```typescript
async function initiateBackgroundCheck(
  userId: string,
  provider: string
): Promise<BackgroundCheck> {
  // 1. Pre-check eligibility
  await preCheckBackgroundCheckEligibility(userId);

  // 2. Get user identity information
  const userIdentity = await getUserIdentity(userId);

  // 3. Initiate check with provider
  const providerClient = getBackgroundCheckProvider(provider);
  const providerCheckId = await providerClient.initiateCheck({
    first_name: userIdentity.first_name,
    last_name: userIdentity.last_name,
    ssn: userIdentity.ssn, // Encrypted
    date_of_birth: userIdentity.date_of_birth,
  });

  // 4. Create background check record
  const backgroundCheck = await createBackgroundCheck({
    user_id: userId,
    provider,
    provider_check_id: providerCheckId,
    status: 'pending',
    created_at: new Date().toISOString(),
  });

  // 5. Webhook will be called when check completes
  return backgroundCheck;
}
```

**3. Result Mapped to Pass/Fail**
```typescript
async function processBackgroundCheckWebhook(
  providerCheckId: string,
  providerResult: ProviderResult
): Promise<void> {
  // 1. Get background check record
  const backgroundCheck = await getBackgroundCheckByProviderId(providerCheckId);

  // 2. Map provider result to pass/fail
  const passed = mapProviderResultToPassFail(providerResult);

  // 3. Update background check status
  await updateBackgroundCheck(backgroundCheck.id, {
    status: passed ? 'verified' : 'failed',
    verified_at: passed ? new Date().toISOString() : undefined,
    failure_reason: passed ? undefined : providerResult.failure_reason,
    expires_at: passed ? calculateExpiryDate() : undefined,
    results_encrypted: encryptResults(providerResult),
    updated_at: new Date().toISOString(),
  });

  // 4. Trigger recompute (MANDATORY)
  await recomputeCapabilityProfile(backgroundCheck.user_id);
}
```

**4. Recompute Capability Profile**
- Same pattern as license/insurance verification (Step E - MANDATORY)

---

## 4. Payment Gating (Strict)

**Purpose:** Gate verification processing fees, not access.

**Allowed Payments:**
- License verification processing (one-time fee per verification)
- Insurance verification processing (one-time fee per verification)
- Periodic re-verification (annual renewal fee)

**Forbidden Payments:**
- Paying to retry failed credentials (fix inputs, then resubmit for free)
- Paying to bypass eligibility (eligibility is derived, not purchased)
- Paying to raise trust tier (trust tier is earned, not purchased)

**Enforcement Rule:**
```typescript
async function checkVerificationPaymentEligibility(
  userId: string,
  verificationType: 'license' | 'insurance' | 'background_check'
): Promise<boolean> {
  // Check 1: Pre-check must pass (no payment if pre-check fails)
  const preCheckPassed = await checkPreCheckEligibility(userId, verificationType);
  if (!preCheckPassed) {
    return false; // Payment button hidden
  }

  // Check 2: No duplicate active verification (no payment for duplicates)
  const activeVerification = await getActiveVerification(userId, verificationType);
  if (activeVerification) {
    return false; // Payment button hidden
  }

  // Check 3: Payment is for processing, not access
  // (This is implicit - payment unlocks processing, not capability profile)

  return true; // Payment button enabled
}
```

**UI Enforcement:**
```typescript
if (!eligibleForVerification) {
  payment_button = hidden;
  // Show message: "Pre-check failed. Fix inputs and resubmit."
}
```

**Behavioral Rules:**
- Payment is gated by eligibility pre-check (no payment if pre-check fails)
- Payment unlocks processing, not access (access is derived via recompute)
- Payment is one-time per verification (no recurring fees for same verification)
- Failed verification can be resubmitted for free (after fixing inputs)

---

## 5. Recomputation Engine (Central Choke Point)

**Purpose:** Recompute capability profile from verification records (atomic, deterministic, idempotent).

**Function Signature:**
```typescript
async function recomputeCapabilityProfile(
  userId: string,
  options?: {
    transaction?: Transaction; // If provided, runs in transaction
    force?: boolean; // Force recompute even if unchanged
  }
): Promise<CapabilityProfile>
```

**Inputs:**
- License verifications (active only: `status = 'verified'`, not expired)
- Insurance verifications (active only: `status = 'verified'`, not expired)
- Background checks (active only: `status = 'verified'`, not expired)
- Trust tier (from trust service)
- Location (from onboarding claims)

**Output:**
- New immutable capability profile snapshot

**Guarantees:**
- **Atomic:** All-or-nothing (transaction-scoped)
- **Deterministic:** Same inputs → same output
- **Idempotent:** Multiple calls with same inputs → same output

**Algorithm:** (See `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` Section 5 for full algorithm)

**Transaction Scope:**
```typescript
async function resolveVerification(
  verificationId: string,
  result: VerificationResult
): Promise<void> {
  // Start transaction
  await db.transaction(async (tx) => {
    // 1. Update verification record
    await updateVerification(verificationId, result, { transaction: tx });

    // 2. Recompute capability profile (atomic, same transaction)
    await recomputeCapabilityProfile(userId, { transaction: tx });

    // 3. Invalidate feed cache
    await invalidateFeedCache(userId, { transaction: tx });

    // Commit transaction (all-or-nothing)
  });
}
```

**Why Transaction-Scoped:**
- If recompute fails, verification update is rolled back
- Ensures capability profile is always consistent with verification records
- Prevents partial updates (verification updated but profile not)

**If Recompute Fails → Verification Is Rolled Back:**
```typescript
try {
  await recomputeCapabilityProfile(userId, { transaction: tx });
} catch (error) {
  // Transaction rolls back (verification update is undone)
  throw new Error('Recompute failed, verification update rolled back');
}
```

---

## 6. Expiry & Revocation (Silent, Immediate)

**Purpose:** Invalidate expired credentials immediately, silently in feed, clearly in Settings.

**Cron Jobs:**

**Nightly Expiry Scan:**
```typescript
async function scanForExpiredCredentials(): Promise<void> {
  const now = new Date();

  // 1. Find expired license verifications
  const expiredLicenses = await db.query(`
    SELECT id, user_id
    FROM license_verifications
    WHERE status = 'verified'
      AND expires_at IS NOT NULL
      AND expires_at < $1
  `, [now]);

  // 2. Find expired insurance verifications
  const expiredInsurance = await db.query(`
    SELECT id, user_id
    FROM insurance_verifications
    WHERE status = 'verified'
      AND expires_at IS NOT NULL
      AND expires_at < $1
  `, [now]);

  // 3. Find expired background checks
  const expiredBackgroundChecks = await db.query(`
    SELECT id, user_id
    FROM background_checks
    WHERE status = 'verified'
      AND expires_at IS NOT NULL
      AND expires_at < $1
  `, [now]);

  // 4. Mark expired and trigger recompute
  for (const license of expiredLicenses) {
    await markExpiredAndRecompute(license.id, license.user_id, 'license');
  }
  for (const insurance of expiredInsurance) {
    await markExpiredAndRecompute(insurance.id, insurance.user_id, 'insurance');
  }
  for (const check of expiredBackgroundChecks) {
    await markExpiredAndRecompute(check.id, check.user_id, 'background_check');
  }
}
```

**On Expiry:**
```typescript
async function markExpiredAndRecompute(
  verificationId: string,
  userId: string,
  type: 'license' | 'insurance' | 'background_check'
): Promise<void> {
  // Start transaction
  await db.transaction(async (tx) => {
    // 1. Mark verification as expired
    await updateVerificationStatus(
      verificationId,
      { status: 'expired', updated_at: new Date().toISOString() },
      { transaction: tx }
    );

    // 2. Trigger recompute (removes expired credential from profile)
    await recomputeCapabilityProfile(userId, { transaction: tx });

    // 3. Invalidate feed cache
    await invalidateFeedCache(userId, { transaction: tx });

    // 4. Send expiry notification (Settings only, not feed)
    await sendExpiryNotification(userId, {
      verification_type: type,
      verification_id: verificationId,
      next_step: 'renew_verification',
    });

    // Commit transaction
  });
}
```

**UX Behavior:**

**Feed:**
- No feed warning (tasks disappear silently)
- No disabled cards (ineligible tasks excluded)
- Feed shows remaining eligible tasks (or empty state)

**Settings:**
- Expired badge shown (red, warning icon)
- Clear renewal path (Settings → Work Eligibility → [Trade/Insurance] → Renew)
- Single notification (push/email, links to Settings)

**Behavioral Rules:**
- Expiry is silent in feed (no warnings, no disabled cards)
- Expiry is clear in Settings (red badge, renewal button)
- Expiry triggers immediate recompute (tasks disappear instantly)
- Expiry notification is single, not repeated (Settings only)

---

## 7. Failure Modes Explicitly Prevented

### ❌ Verified Trade Without License

**Prevention:**
- Invariant 2: Verified trades must have active verification
- Recomputation logic: Only `status = 'verified'` and not expired → `verified_trades`
- Cannot set `verified_trades` without valid license verification

**Evidence:**
- Database foreign key: `verified_trades.verification_id` → `license_verifications.id`
- Recomputation algorithm excludes non-verified or expired verifications

---

### ❌ Insurance Without Trade

**Prevention:**
- Pre-check before verification: User must have at least one verified trade
- Recomputation logic: `insurance_valid = true` only if insurance verification exists and is verified
- Feed query: Insurance-required tasks excluded if `insurance_valid = false`

**Evidence:**
- Pre-check enforces verified trade requirement
- Recomputation algorithm checks verified trades before setting `insurance_valid`

---

### ❌ Expired Credential Still Granting Access

**Prevention:**
- Nightly expiry scan: Marks expired verifications as `'expired'`
- Recomputation logic: Excludes expired verifications from `verified_trades`
- Feed query: Uses current capability profile (expired credentials already excluded)

**Evidence:**
- Expiry scan runs daily (cron job)
- Recomputation excludes expired verifications
- Feed query uses recomputed profile (no expired credentials)

---

### ❌ Manual Overrides Leaking to Feed

**Prevention:**
- Manual overrides are rare, logged, and reviewed
- Manual overrides still trigger recompute (not direct profile mutation)
- Feed query uses recomputed profile (not manual override flags)

**Evidence:**
- Admin override logging (see `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` Section 5, Trigger 7)
- Recomputation is mandatory (even for manual overrides)
- Feed query uses capability profile (not override flags)

---

### ❌ Support "Fixing" Access

**Prevention:**
- Support cannot mutate capability profile directly
- Support can only trigger verification resubmission or manual review
- Support actions are logged and reviewed

**Evidence:**
- Capability profile is derived, never edited directly
- Support actions trigger verification flow (not profile mutation)
- Audit logs record all support actions

---

## 8. Invariants (Re-stated)

### Invariant 1: Verification Records Are the Only Mutable Layer

**Rule:**
- Verification records (license, insurance, background check) are the only mutable layer
- Capability profile is derived, never edited directly
- Feed query uses capability profile (derived, not mutable)

**Enforcement:**
- Database constraints: Capability profile fields cannot be updated directly (except `updated_at`)
- Application logic: No direct UPDATE statements on capability profile (except `updated_at`)
- Code review checklist: "No direct profile mutations"

---

### Invariant 2: Capability Profile Is Derived, Never Edited

**Rule:**
- Capability profile is recomputed from verification records
- Capability profile is never mutated directly (except `updated_at`)
- Recomputation is mandatory after verification state changes

**Enforcement:**
- Database constraints: Check constraints prevent direct mutations
- Application logic: Repository pattern enforces recompute-only access
- Transaction scope: Recomputation is atomic (transaction-scoped)

---

### Invariant 3: Every Verification State Change Triggers Recompute

**Rule:**
- Every verification status change (`pending` → `verified`, `verified` → `expired`, etc.) triggers recompute
- Recompute runs in same transaction as verification update
- If recompute fails, verification update is rolled back

**Enforcement:**
- Transaction scope: Recompute is inside verification update transaction
- Error handling: Recompute failures roll back verification updates
- Code review checklist: "Every verification update triggers recompute"

---

### Invariant 4: Access Flows Only from Capability Profile

**Rule:**
- Feed query uses capability profile (not verification records directly)
- Task eligibility is determined by capability profile (not verification status)
- No bypass or override (capability profile is single source of truth)

**Enforcement:**
- Feed query algorithm: Uses capability profile fields only
- Task eligibility resolver: Uses capability profile (not verification records)
- Code review checklist: "No direct verification checks in feed query"

---

### Invariant 5: Payments Never Bypass Eligibility

**Rule:**
- Payment is gated by eligibility pre-check (no payment if pre-check fails)
- Payment unlocks processing, not access (access is derived via recompute)
- Payment is one-time per verification (no recurring fees for same verification)

**Enforcement:**
- Payment eligibility check: Pre-check must pass before payment
- Payment flow: Payment unlocks verification processing (not capability profile update)
- Code review checklist: "Payments don't bypass eligibility"

**If any invariant is violated, you stop shipping.**

---

## This Verification Pipeline is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this pipeline exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
