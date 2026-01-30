# Poster-Side Task Creation Risk Classifier — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This is the last upstream control point. If task classification is correct, everything downstream (verification, feed, monetization, liability) behaves correctly by default. Posters never decide who is qualified. Posters only describe the task. The system classifies risk and enforces requirements. Any UI that lets posters "choose skill level" or "allow non-licensed workers" is illegal in this system.

---

## Core Law (Non-Negotiable)

**Posters never decide who is qualified.**
**Posters only describe the task.**
**The system classifies risk and enforces requirements.**

If this law is violated, trust leaks, liability increases, and unsafe matching occurs.

---

## Authority Hierarchy (Must Be Preserved)

**1. Task Input (Poster)**
- Descriptive only
- No enforcement authority
- No qualification decisions

**2. Risk Classification Engine (System)**
- Pure function
- Deterministic output
- No poster override

**3. Capability Profile Resolver (System)**
- Derived from verification records
- Single source of truth for eligibility
- No poster override

**4. Feed Filter (System)**
- Joins tasks with capability profiles
- Excludes ineligible tasks
- No poster override

**Posters are not an authority layer.**

---

## Task Creation Flow (Poster POV)

### STEP 1 — Task Description (Freeform)

**Purpose:** Collect descriptive information about the task.

**Fields:**
- **Title** (required, text input, max 100 characters)
  - Placeholder: "Describe your task"
  - Validation: Non-empty string, trimmed

- **Description** (required, textarea, max 1000 characters)
  - Placeholder: "Provide details about what needs to be done"
  - Validation: Non-empty string, trimmed

- **Location** (required, auto-filled if possible)
  - Address (text input or map picker)
  - City (auto-filled from address)
  - State (auto-filled from address, required)
  - ZIP (optional, from address)
  - Validation: Address must be valid, state must be valid US state code

- **Urgency** (required, radio buttons)
  - Options:
    - Standard (2-7 days)
    - Same-day (within 24 hours)
    - Immediate (within 2 hours)
  - Default: Standard
  - Validation: Must select one option

**Behavioral Rules:**
- Cannot proceed without title, description, location, and urgency
- Location auto-fills if poster has location set in profile
- Location can be manually adjusted (map picker)
- Urgency selection affects task prioritization (not risk classification)

**Backend Output:**
```typescript
{
  title: string;
  description: string;
  location: {
    address: string;
    city: string;
    state: string; // ISO 3166-2 state code
    zip?: string;
  };
  urgency: "standard" | "same_day" | "immediate";
}
```

**Backend Contract:**

**Endpoint:** `POST /api/tasks/describe` (Step 1)

**Request:**
```typescript
{
  title: string; // Required, non-empty, max 100 chars
  description: string; // Required, non-empty, max 1000 chars
  location: {
    address: string; // Required
    city: string; // Required
    state: string; // Required, ISO 3166-2 state code
    zip?: string; // Optional
  };
  urgency: "standard" | "same_day" | "immediate"; // Required
}
```

**Response:**
```typescript
{
  task_draft_id: string; // UUID, temporary until posting
  step_complete: true;
  next_step: "category_selection";
}
```

**Validation Rules:**
1. `title` must be non-empty string (trimmed, max 100 chars)
2. `description` must be non-empty string (trimmed, max 1000 chars)
3. `location.state` must be valid US state code (ISO 3166-2)
4. `urgency` must be valid option

**Why This Is Descriptive Only:**
- No enforcement happens at this step
- No qualification decisions are made
- Poster is only describing what they need done

---

### STEP 2 — Task Category Selection (Controlled Vocabulary)

**Purpose:** Select primary category that determines risk classification baseline.

**Fields:**
- **Category** (required, single selection, dropdown or cards)

**Category Options:**
```
Low-Risk Categories:
- Moving & hauling
- Yard work
- Cleaning
- Assembly
- Errands

Regulated Categories (License May Be Required):
- Electrical
- Plumbing
- HVAC
- Appliance install
- IT / networking
- In-home care
- General contractor
```

**UX Details:**
- Single selection required (cannot select multiple)
- Regulated categories marked with visual indicator: **"License may be required"** (amber badge)
- Cannot proceed without selection
- Helper text: "Select the category that best matches your task"

**Behavioral Rules:**
- Must select exactly one category (cannot skip)
- Category determines risk classification baseline
- Cannot change category after posting (requires cancellation + re-post)

**Backend Output:**
```typescript
{
  task_category: string; // e.g., "electrical", "moving", "plumbing"
}
```

**Backend Contract:**

**Endpoint:** `POST /api/tasks/select-category` (Step 2)

**Request:**
```typescript
{
  task_draft_id: string; // From Step 1
  task_category: string; // Required, must be in system category list
}
```

**Response:**
```typescript
{
  task_draft_id: string;
  task_category: string;
  risk_follow_ups: RiskFollowUp[]; // Dynamic questions based on category
  step_complete: true;
  next_step: "risk_follow_ups"; // If risk_follow_ups.length > 0
  next_step: "preview"; // If risk_follow_ups.length === 0
}
```

**RiskFollowUp:**
```typescript
{
  question_key: string; // e.g., "live_wiring", "overnight"
  question_text: string; // e.g., "Does this involve live wiring?"
  question_type: "yes_no" | "multiple_choice" | "value_range";
  options?: string[]; // If multiple_choice or value_range
  required: boolean;
}
```

**Validation Rules:**
1. `task_category` must exist in system category list
2. Cannot select invalid category

**Why This Matters:**
- Category determines risk classification baseline
- Category unlocks risk-relevant follow-up questions
- Category cannot be changed after posting (enforcement stability)

---

### STEP 3 — Risk-Relevant Follow-Ups (Dynamic, Minimal)

**Purpose:** Collect risk-signaling information that increases (never decreases) risk classification.

**Conditional Display:**
- Only shown if `risk_follow_ups.length > 0` (based on category from Step 2)
- Questions are dynamic (different per category)
- Minimal questions (only those that affect risk)

**Example Follow-Ups by Category:**

**Electrical:**
```
Q1: Does this involve live wiring? (yes/no)
Q2: Is this inside a residential structure? (yes/no)
Q3: Estimated task value? ($ range: <$100 | $100-$500 | $500+)
```

**In-Home Care:**
```
Q1: Is this overnight? (yes/no)
Q2: Is medical assistance involved? (yes/no)
```

**Appliance Install:**
```
Q1: Is this gas appliance? (yes/no)
Q2: Requires plumbing connection? (yes/no)
```

**Plumbing:**
```
Q1: Is this gas line work? (yes/no)
Q2: Requires permits? (yes/no)
```

**Moving & Hauling (Low-Risk, No Follow-Ups):**
```
No follow-up questions (risk is already low)
```

**Behavioral Rules:**
- All questions are optional (can skip if not applicable)
- Answers only increase risk, never reduce baseline
- Posters cannot lower risk by answering "no" dishonestly (system enforces minimums)
- If all questions skipped, baseline risk from category is used

**Backend Output:**
```typescript
{
  risk_inputs: {
    [question_key: string]: string | boolean | number; // Answer type depends on question_type
  };
}
```

**Example Output (Electrical):**
```typescript
{
  risk_inputs: {
    live_wiring: true,
    residential: true,
    value_band: "medium" // "$100-$500"
  };
}
```

**Backend Contract:**

**Endpoint:** `POST /api/tasks/risk-follow-ups` (Step 3)

**Request:**
```typescript
{
  task_draft_id: string; // From Step 2
  risk_inputs: {
    [question_key: string]: string | boolean | number;
  };
}
```

**Response:**
```typescript
{
  task_draft_id: string;
  risk_inputs: { [question_key: string]: any };
  classified_requirements: TaskRequirements; // System-classified, poster never sees this directly
  step_complete: true;
  next_step: "preview";
}
```

**Validation Rules:**
1. `risk_inputs` keys must match `risk_follow_ups[].question_key` from Step 2
2. Answer types must match `question_type` (yes_no → boolean, multiple_choice → string, value_range → string)

**Why Answers Only Increase Risk:**
- Baseline risk is set by category (minimum)
- Follow-up answers can only increase risk level
- System enforces minimum risk per category (posters cannot lower below baseline)

---

## Risk Classification Engine (System-Only)

**Purpose:** Pure function that classifies risk and derives requirements from task description.

**Input:**
```typescript
{
  task_category: string;
  risk_inputs: { [question_key: string]: any };
  location_state: string; // ISO 3166-2 state code
}
```

**Output (Authoritative):**
```typescript
{
  risk_level: RiskLevel;
  required_trade: string | null;
  required_trust_tier: TrustTier;
  insurance_required: boolean;
  background_check_required: boolean;
}
```

**Posters never see or edit this object.**

### Classification Algorithm (Pseudocode)

```typescript
function classifyTaskRisk(
  taskCategory: string,
  riskInputs: { [key: string]: any },
  locationState: string
): TaskRequirements {
  // 1. Get baseline risk from category
  const baselineRisk = getBaselineRiskForCategory(taskCategory);
  const baselineTrade = getTradeForCategory(taskCategory); // May be null for low-risk

  // 2. Apply risk escalations from follow-ups
  let riskLevel = baselineRisk;
  
  // Example: Electrical with live wiring → High risk
  if (taskCategory === 'electrical' && riskInputs.live_wiring === true) {
    riskLevel = 'high';
  }

  // Example: In-home care with overnight → Critical risk
  if (taskCategory === 'in_home_care' && riskInputs.overnight === true) {
    riskLevel = 'critical';
  }

  // Example: Appliance install with gas → High risk
  if (taskCategory === 'appliance_install' && riskInputs.gas_appliance === true) {
    riskLevel = 'high';
  }

  // 3. Derive requirements from risk level (immutable mapping)
  const requirements = getRequirementsForRiskLevel(riskLevel, baselineTrade, locationState);

  return requirements;
}

function getBaselineRiskForCategory(category: string): RiskLevel {
  const baselineMap: { [key: string]: RiskLevel } = {
    'moving_hauling': 'low',
    'yard_work': 'low',
    'cleaning': 'low',
    'assembly': 'low',
    'errands': 'low',
    'electrical': 'medium', // Escalates to high with live wiring
    'plumbing': 'medium', // Escalates to high with gas line
    'hvac': 'medium', // Escalates to high with gas
    'appliance_install': 'medium', // Escalates to high with gas
    'it_networking': 'low', // May require license in some states
    'in_home_care': 'medium', // Escalates to critical with overnight/medical
    'general_contractor': 'medium', // May escalate based on scope
  };

  return baselineMap[category] || 'low';
}

function getTradeForCategory(category: string): string | null {
  const tradeMap: { [key: string]: string | null } = {
    'moving_hauling': null,
    'yard_work': null,
    'cleaning': null,
    'assembly': null,
    'errands': null,
    'electrical': 'electrician',
    'plumbing': 'plumber',
    'hvac': 'hvac',
    'appliance_install': 'appliance_installer',
    'it_networking': 'it_networking',
    'in_home_care': 'in_home_care',
    'general_contractor': 'general_contractor',
  };

  return tradeMap[category] || null;
}

function getRequirementsForRiskLevel(
  riskLevel: RiskLevel,
  trade: string | null,
  locationState: string
): TaskRequirements {
  // Immutable mapping table (see Section 4)
  switch (riskLevel) {
    case 'low':
      return {
        risk_level: 'low',
        required_trade: trade, // May be null
        required_trust_tier: 1, // Tier 1 (ROOKIE)
        insurance_required: false,
        background_check_required: false,
        location_state: locationState,
      };

    case 'medium':
      return {
        risk_level: 'medium',
        required_trade: trade, // May be null
        required_trust_tier: 2, // Tier 2 (VERIFIED)
        insurance_required: trade !== null, // Required if regulated trade
        background_check_required: false,
        location_state: locationState,
      };

    case 'high':
      return {
        risk_level: 'high',
        required_trade: trade, // Required (cannot be null)
        required_trust_tier: 3, // Tier 3 (TRUSTED)
        insurance_required: true, // Always required
        background_check_required: false,
        location_state: locationState,
      };

    case 'critical':
      return {
        risk_level: 'critical',
        required_trade: trade, // Required (cannot be null)
        required_trust_tier: 4, // Tier 4 (ELITE)
        insurance_required: true, // Always required
        background_check_required: true, // Always required
        location_state: locationState,
      };

    default:
      throw new Error(`Invalid risk level: ${riskLevel}`);
  }
}
```

**Backend Contract:**

**Endpoint:** `POST /api/tasks/classify-risk` (Internal, system-only)

**Request:**
```typescript
{
  task_category: string;
  risk_inputs: { [question_key: string]: any };
  location_state: string;
}
```

**Response:**
```typescript
{
  risk_level: RiskLevel;
  required_trade: string | null;
  required_trust_tier: TrustTier;
  insurance_required: boolean;
  background_check_required: boolean;
  classification_confidence: number; // 0-1, for auditing
  classification_rules_applied: string[]; // For auditing
}
```

**Why This Is System-Only:**
- Posters cannot override risk classification
- Classification is deterministic (same inputs → same output)
- Requirements are derived from risk level (immutable mapping)
- Enforcement is centralized (no ambiguity)

---

## Risk Level Definitions (Locked)

**These definitions are immutable. Changes require architecture review.**

| Risk Level | Meaning | Examples |
|------------|---------|----------|
| **Low** | No injury / property risk | Yard work, errands, moving help, cleaning, assembly |
| **Medium** | Property risk | Appliance install (non-gas), IT/networking, general contractor (small scope) |
| **High** | Injury / fire / liability risk | Electrical (live wiring), plumbing (gas line), HVAC (gas), appliance install (gas) |
| **Critical** | Human safety risk | In-home care (overnight, medical), childcare, medical assistance |

**Risk Level Escalation Rules:**
- Risk level can only go **up**, never down
- Baseline risk is minimum (cannot be lowered)
- Follow-up answers can only increase risk
- System enforces minimum risk per category

**Examples:**
- Electrical (baseline: medium) + live wiring → High
- In-home care (baseline: medium) + overnight → Critical
- Appliance install (baseline: medium) + gas → High
- Yard work (baseline: low) + any follow-ups → Low (cannot escalate low-risk)

---

## Requirement Mapping Table (Immutable)

**This table is the spine of enforcement. It must live in code and docs. Changes require review.**

| Risk Level | Trade Required | Trust Tier | Insurance | Background Check |
|------------|----------------|------------|-----------|------------------|
| **Low** | None (optional) | A (Tier 0) | No | No |
| **Medium** | Sometimes (if regulated) | B (Tier 1-2) | Sometimes (if regulated) | No |
| **High** | Yes (always) | C (Tier ≥2) | Yes (always) | No |
| **Critical** | Yes (always) | D (Tier ≥3) | Yes (always) | Yes (always) |

**Mapping Rules:**
1. **Trade Required:**
   - Low: No trade required (anyone can do it)
   - Medium: Trade required only if category is regulated (e.g., electrical, plumbing)
   - High: Trade always required (cannot be null)
   - Critical: Trade always required (cannot be null)

2. **Trust Tier:**
   - Low: Tier 1 (ROOKIE, default)
   - Medium: Tier 2 (VERIFIED)
   - High: Tier 3 (TRUSTED)
   - Critical: Tier 4 (ELITE)

3. **Insurance:**
   - Low: Not required
   - Medium: Required if trade is regulated (e.g., electrical, plumbing)
   - High: Always required
   - Critical: Always required

4. **Background Check:**
   - Low: Not required
   - Medium: Not required
   - High: Not required
   - Critical: Always required

**Enforcement:**
- This table is hardcoded in the classification engine
- Cannot be overridden by posters
- Changes require architecture review and code + docs updates
- Audit log records all classifications using this table

---

## Task Object (Final, Stored)

**Purpose:** Store classified task with immutable requirements.

**Schema:**
```typescript
interface Task {
  // Identity
  task_id: string; // UUID, generated at posting
  posted_by: string; // Foreign key to users.id
  created_at: string; // ISO 8601
  updated_at: string; // ISO 8601 (only for non-requirement fields)

  // Task Description (From Poster)
  title: string;
  description: string;
  location: {
    address: string;
    city: string;
    state: string; // ISO 3166-2 state code
    zip?: string;
  };
  urgency: "standard" | "same_day" | "immediate";

  // Classification (System-Derived, Immutable)
  task_category: string;
  risk_level: RiskLevel;
  required_trade: string | null; // Null if no trade required
  required_trust_tier: TrustTier;
  insurance_required: boolean;
  background_check_required: boolean;

  // Status
  status: "draft" | "posted" | "assigned" | "in_progress" | "completed" | "cancelled";
  assigned_to?: string; // Foreign key to users.id (if assigned)

  // Metadata
  classification_confidence: number; // 0-1, for auditing
  classification_rules_applied: string[]; // For auditing
}
```

**Database Schema (PostgreSQL):**
```sql
CREATE TABLE tasks (
  -- Identity
  task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  posted_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Task Description
  title VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  location_address TEXT NOT NULL,
  location_city VARCHAR(255) NOT NULL,
  location_state VARCHAR(2) NOT NULL CHECK (length(location_state) = 2),
  location_zip VARCHAR(10),
  urgency VARCHAR(20) NOT NULL CHECK (urgency IN ('standard', 'same_day', 'immediate')),

  -- Classification (Immutable After Posting)
  task_category VARCHAR(255) NOT NULL,
  risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
  required_trade VARCHAR(255), -- NULL if no trade required
  required_trust_tier INTEGER NOT NULL CHECK (required_trust_tier IN (1, 2, 3, 4)),  -- 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE
  insurance_required BOOLEAN NOT NULL,
  background_check_required BOOLEAN NOT NULL,

  -- Status
  status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (
    status IN ('draft', 'posted', 'assigned', 'in_progress', 'completed', 'cancelled')
  ),
  assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Metadata
  classification_confidence NUMERIC(3, 2) NOT NULL DEFAULT 1.0 CHECK (
    classification_confidence >= 0 AND classification_confidence <= 1
  ),
  classification_rules_applied TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],

  -- Constraints
  CONSTRAINT tasks_location_state_valid CHECK (
    location_state ~ '^[A-Z]{2}$' -- Valid US state code
  )
);

-- Indexes
CREATE INDEX idx_tasks_posted_by ON tasks(posted_by);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_location_state ON tasks(location_state);
CREATE INDEX idx_tasks_risk_level ON tasks(risk_level);
CREATE INDEX idx_tasks_required_trade ON tasks(required_trade) WHERE required_trade IS NOT NULL;
CREATE INDEX idx_tasks_required_trust_tier ON tasks(required_trust_tier);

-- Immutability constraint (requirements cannot change after posting)
-- Enforced by application logic (no UPDATE statements allowed on requirement fields)
```

**Immutability Rule:**
> **Tasks cannot be downgraded after creation.**
>
> Edits require task cancellation + re-post.

**Why:**
- Requirements are derived from risk classification (immutable mapping)
- Feed filtering relies on stable requirements (cannot change after posting)
- Liability requires stable requirements (poster cannot lower requirements after posting)
- Trust requires consistency (same task → same requirements)

**Editable Fields (After Posting):**
- `title` (minor edits allowed)
- `description` (minor edits allowed)
- `location` (minor edits allowed, but state change requires re-classification)
- `status` (workflow transitions)

**Non-Editable Fields (After Posting):**
- `task_category` (requires cancellation + re-post)
- `risk_level` (immutable, derived from category)
- `required_trade` (immutable, derived from risk level)
- `required_trust_tier` (immutable, derived from risk level)
- `insurance_required` (immutable, derived from risk level)
- `background_check_required` (immutable, derived from risk level)

**Backend Contract:**

**Endpoint:** `POST /api/tasks` (Post task)

**Request:**
```typescript
{
  task_draft_id: string; // From previous steps
  // All task fields are already validated in draft steps
}
```

**Response:**
```typescript
{
  task_id: string;
  task: Task; // Full task object
  posting_confirmed: true;
}
```

**Validation (Before Posting):**
1. Task draft must be complete (all steps validated)
2. Requirements must be valid (from classification engine)
3. Location state must be valid US state code
4. Poster must be authorized (poster role or both role)

---

## Feed Enforcement (Automatic)

**Purpose:** Join tasks with capability profiles to show only eligible tasks.

**Algorithm:**
```typescript
async function getFeed(userId: string, params: FeedParams): Promise<Task[]> {
  // 1. Load capability profile (single source of truth)
  const profile = await getCapabilityProfile(userId);
  if (!profile) {
    throw new Error('Capability profile not found. Complete onboarding first.');
  }

  // 2. Build eligibility filter (derived from profile + task requirements)
  const eligibilityFilter = {
    // Trade matching
    ...(profile.verified_trades.length > 0
      ? { required_trade: { $in: profile.verified_trades.map(t => t.trade) } }
      : { required_trade: null }), // Low-risk tasks (no trade required)

    // Trust tier matching (user tier >= required tier)
    required_trust_tier: { $lte: profile.trust_tier },

    // Risk clearance matching
    risk_level: { $in: profile.risk_clearance },

    // Insurance matching
    ...(profile.insurance_valid === false
      ? { insurance_required: false } // Exclude tasks requiring insurance
      : {}),

    // Background check matching
    ...(profile.background_check_valid === false
      ? { background_check_required: false } // Exclude tasks requiring background check
      : {}),

    // Location matching
    location_state: profile.location_state,

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
  return tasks;
}
```

**What This Enforces:**
- Tasks only appear if user meets all requirements
- No disabled buttons (ineligible tasks don't appear)
- No upsells in feed (Settings is the place for eligibility)
- Clean feed (only eligible tasks visible)

---

## Poster UX (Trust Without Control)

**Purpose:** Show poster that only qualified professionals can accept, without exposing trust tiers or verification internals.

### What Poster Sees

**During Task Creation:**
- "Only qualified professionals can accept this task" (trust signal)
- Task description, category, urgency (normal fields)
- Risk follow-ups (if applicable)
- Preview of task (before posting)

**After Posting:**
- "Your task is live. Qualified professionals can now accept it."
- No trust tiers shown (internal system detail)
- No license rules shown (internal system detail)
- No verification internals shown (internal system detail)

**Optional Add-Ons (Poster Can Purchase):**
- **Verified Pro** (premium placement for verified professionals)
- **Priority Match** (fast-track matching for qualified professionals)
- **Urgent Execution** (guarantee same-day completion)

**What They Never See:**
- Trust tiers (internal system detail)
- License rules (internal system detail)
- Verification internals (internal system detail)
- Capability profile matching logic (internal system detail)

**Confidence Without Micromanagement:**
- Poster trusts system to match qualified professionals
- Poster doesn't need to understand trust tiers or verification
- Poster pays for certainty (verified professionals, priority matching)

---

## Abuse & Edge-Case Handling (Locked)

### Misclassification Attempts

**Scenario:** Poster selects "Assembly" but describes rewiring

**Detection:**
```typescript
async function detectMisclassification(
  taskCategory: string,
  description: string
): Promise<boolean> {
  // Keyword matching for risk-signaling terms
  const riskKeywords: { [category: string]: string[] } = {
    'assembly': ['wire', 'electrical', 'live', 'current', 'outlet', 'breaker'],
    'cleaning': ['chemical', 'hazardous', 'asbestos', 'lead'],
    'yard_work': ['tree', 'power line', 'electrical', 'utility'],
  };

  const keywords = riskKeywords[taskCategory] || [];
  const descriptionLower = description.toLowerCase();

  for (const keyword of keywords) {
    if (descriptionLower.includes(keyword)) {
      return true; // Misclassification detected
    }
  }

  return false;
}
```

**Response:**
1. System flags mismatch
2. Forces reclassification (category change required)
3. Blocks posting until category matches description
4. Shows warning: "Your description suggests this is [category]. Please select the correct category."

### Location Mismatch

**Scenario:** Task location state ≠ poster state

**Rule:**
> Classification uses **task location**, always.

**Enforcement:**
- Classification engine uses `location_state` from task (not poster profile)
- Feed matching uses task `location_state` (not poster profile)
- Poster can post tasks in any state (not restricted to their home state)

**Why:**
- Poster may need work done in another state (e.g., vacation property)
- Classification must match task location (jurisdiction correctness)
- Feed matching must match task location (proximity correctness)

---

## Invariants (Must Be Enforced)

### Invariant 1: Posters Cannot Override Risk Classification

**Rule:**
- Posters cannot select risk level (system classifies)
- Posters cannot lower risk (system enforces minimums)
- Posters cannot bypass requirements (system enforces)

**Enforcement:**
- No UI controls for risk level selection
- No UI controls for requirement selection
- Classification engine is system-only (no poster access)

### Invariant 2: Tasks Declare Requirements, Not Preferences

**Rule:**
- Task requirements are deterministic (same inputs → same requirements)
- Task requirements are immutable after posting
- Task requirements are enforceable (feed filtering uses them)

**Enforcement:**
- Requirements are derived from classification engine (no poster override)
- Requirements are stored with task (immutable after posting)
- Feed query enforces requirements (no bypass)

### Invariant 3: Risk Level Never Decreases After Creation

**Rule:**
- Risk level is immutable after posting
- Edits cannot lower risk (requires cancellation + re-post)
- Re-posting requires re-classification (no inheritance)

**Enforcement:**
- Database constraint (no UPDATE on `risk_level` after posting)
- Application logic (no downgrade mutations allowed)
- Re-post requires new classification (no inheritance)

### Invariant 4: Capability Profile Is the Only Gate

**Rule:**
- Feed filtering uses capability profile (single source of truth)
- Task requirements are checked against profile (not poster preference)
- No bypass or override (poster cannot grant access)

**Enforcement:**
- Feed query joins tasks with capability profiles (no bypass)
- Eligibility is derived from profile (not poster decision)
- No "allow non-qualified workers" option (illegal in system)

### Invariant 5: Feed Only Shows Eligible Tasks

**Rule:**
- Feed query filters by capability profile (joins tasks with profiles)
- Ineligible tasks do not appear (no disabled cards)
- Feed is clean (only eligible tasks visible)

**Enforcement:**
- Feed query enforces all requirements (trade, trust tier, insurance, background check)
- No disabled buttons (ineligible tasks excluded)
- No upsells in feed (Settings is the place for eligibility)

**Violating any of these collapses trust.**

---

## What This Enables (Immediately)

### Zero Unsafe Applications

**How:**
- Feed only shows eligible tasks (requirements enforced)
- Users cannot apply to tasks they don't qualify for (feed filtered)
- No "why was I rejected?" tickets (users never rejected, just not shown)

**Evidence:**
- Feed query enforces all requirements (Invariant 5)
- Capability profile is single source of truth (Invariant 4)
- Tasks declare requirements, not preferences (Invariant 2)

### Clean Monetization (Posters Pay for Certainty)

**How:**
- Posters can purchase verified pro matching (premium placement)
- Posters can purchase priority matching (fast-track qualified professionals)
- Posters can purchase urgent execution (same-day completion guarantee)

**Evidence:**
- Add-ons are optional (poster UX section)
- Add-ons don't affect requirements (requirements are immutable)
- Add-ons improve matching speed/quality (not qualification bypass)

### Clear Verification Upgrade Paths

**How:**
- Users see locked tasks count in Settings (upgrade signal contract)
- Verification unlocks more tasks (clear value proposition)
- Settings shows verification status (clear upgrade path)

**Evidence:**
- Upgrade signal contract (from capability profile spec)
- Settings → Work Eligibility screen (shows verification paths)
- Feed filtering shows value of verification (more tasks unlock)

### Legal Defensibility

**How:**
- Requirements are deterministic (same inputs → same requirements)
- Requirements are immutable (cannot change after posting)
- Requirements are enforceable (feed filtering uses them)

**Evidence:**
- Risk classification engine is pure function (no poster override)
- Requirement mapping table is immutable (locked architecture)
- Tasks declare requirements, not preferences (Invariant 2)

### Viral "This App Just Works" Effect

**How:**
- Users only see tasks they can do (clean feed)
- No rejection friction (users never rejected, just not shown)
- Posters trust system to match qualified professionals (trust without control)

**Evidence:**
- Feed only shows eligible tasks (Invariant 5)
- Poster UX is simple (trust without control)
- System enforces requirements (Invariant 1)

---

## This Risk Classifier is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this classifier exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
