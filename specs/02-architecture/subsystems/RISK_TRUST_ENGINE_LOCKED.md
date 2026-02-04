# RISK & TRUST ENGINE — Active Risk Engineering System

**STATUS: LOCKED — Institutional-Grade Specification**
**Version:** v1.0
**Authority:** PRODUCT_SPEC.md INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8, AI_INFRASTRUCTURE.md §10
**Applies To:** Safety pool, worker classification, fraud detection, trust defense
**Last Updated:** February 2026
**Replaces:** Former staging/FRAUD_DETECTION_SPEC.md (stub — now archived)

---

## 0. Prime Directive

```
Risk is not a legal department. Risk is an automated system.
Trust is not a badge. Trust is a real-time computation.
Safety is not a policy. Safety is a financial instrument.

Every task, every second, every signal: monitored, scored, enforced.
```

**Governing Law (from AI_INFRASTRUCTURE.md §0):**
```
AI proposes.
Deterministic systems decide.
Databases enforce.
UI reveals.
```

The Risk & Trust Engine operates at **Layers 0-4**:
- Layer 0: PostgreSQL constraints (trust tier checks, escrow rules)
- Layer 1: Backend state machines (trust transitions, claim processing)
- Layer 2: Temporal enforcement (cooldowns, decay, windows)
- Layer 3: Stripe (escrow, safety pool, payouts)
- Layer 4: AI risk scoring (proposals only, NEVER final decisions)

---

## 1. Architecture Overview

### 1.1 Four Pillars

```
┌─────────────────────────────────────────────────────────────────┐
│ PILLAR 1: AI-Dynamic Safety Pool                                │
│ Self-insurance via parametric micro-premiums per task            │
├─────────────────────────────────────────────────────────────────┤
│ PILLAR 2: Worker Classification Fortress                        │
│ Bulletproof independent contractor status                       │
├─────────────────────────────────────────────────────────────────┤
│ PILLAR 3: Behavioral Integrity System ("Shadow Level")          │
│ Invisible fraud detection via behavioral biometrics             │
├─────────────────────────────────────────────────────────────────┤
│ PILLAR 4: Layered Trust Defense                                 │
│ Identity → Liveness → Spatial → Behavioral verification stack   │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Integration Map

```
RISK_TRUST_ENGINE
  ├── reads: POSTER_TASK_CREATION_RISK_CLASSIFIER (task risk level)
  ├── reads: CAPABILITY_PROFILE_SCHEMA (worker credentials)
  ├── reads: JUDGE_AGENT_SPEC (proof verdicts, fraud signals)
  ├── reads: RATING_SYSTEM_SPEC (mutual ratings)
  ├── reads: VERIFICATION_PIPELINE (license/insurance status)
  ├── writes: safety_pool_ledger (premium collection, claim payouts)
  ├── writes: trust_scores (real-time trust computation)
  ├── writes: fraud_signals (behavioral anomaly flags)
  └── writes: worker_classification_audit (contractor compliance log)
```

---

## 2. PILLAR 1: AI-Dynamic Safety Pool

### 2.1 Concept

Every task pays a parametric risk premium into a safety pool. The premium is NOT flat — it is computed per-task by AI based on risk signals. The pool self-insures against damage claims, enabling instant payouts without traditional insurance delays.

### 2.2 Premium Calculation Engine

```typescript
interface RiskPremiumInput {
  // Task Signals
  task_category: string;           // 'moving', 'plumbing', 'cleaning', etc.
  task_risk_level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';  // From risk classifier
  task_value: number;              // Escrow amount in dollars
  task_location_type: string;      // 'indoor', 'outdoor', 'residential', 'commercial'
  task_requires_tools: boolean;
  task_property_access: boolean;   // Worker enters someone's property
  
  // Worker Signals
  worker_trust_tier: 1 | 2 | 3 | 4 | 5;
  worker_completed_tasks: number;
  worker_dispute_rate: number;     // 0-1
  worker_claim_history: number;    // Past claims filed against
  worker_insurance_verified: boolean;
  
  // Location Signals
  location_state: string;          // Jurisdiction (regulations vary)
  location_crime_index: number;    // 0-1, area risk level
  location_property_value: string; // 'low' | 'medium' | 'high' | 'luxury'
}

interface RiskPremiumOutput {
  base_premium: number;            // Category baseline
  risk_multiplier: number;         // 0.5x - 3.0x based on signals
  trust_discount: number;          // 0-50% for high-trust workers
  final_premium: number;           // What the task actually pays
  premium_breakdown: {
    property_damage: number;       // % allocated to property claims
    injury_reserve: number;        // % allocated to injury claims
    dispute_reserve: number;       // % allocated to dispute resolution
    platform_overhead: number;     // % for pool administration
  };
}
```

### 2.3 Premium Schedule (Base Rates)

```
┌────────────────────────────┬────────────┬──────────────────────────────┐
│ Task Category              │ Base Rate  │ Risk Rationale               │
├────────────────────────────┼────────────┼──────────────────────────────┤
│ Delivery / Errand          │ $0.75      │ Minimal property contact     │
│ Cleaning (standard)        │ $1.50      │ Chemical/surface risk        │
│ Moving / Hauling           │ $2.50      │ Property damage, injury      │
│ Assembly / Installation    │ $2.00      │ Tool use, structural risk    │
│ Yard / Outdoor             │ $1.75      │ Equipment, weather           │
│ Plumbing (minor)           │ $4.00      │ Water damage potential       │
│ Electrical (minor)         │ $5.00      │ Fire/shock risk              │
│ In-home care               │ $3.50      │ Vulnerability, liability     │
│ Pet care                   │ $2.00      │ Animal injury, escape        │
│ General labor              │ $1.50      │ Baseline physical work       │
└────────────────────────────┴────────────┴──────────────────────────────┘
```

### 2.4 Risk Multipliers

```typescript
function computeMultiplier(input: RiskPremiumInput): number {
  let multiplier = 1.0;
  
  // Task value scaling (higher value = higher risk exposure)
  if (input.task_value > 100) multiplier += 0.2;
  if (input.task_value > 250) multiplier += 0.3;
  if (input.task_value > 500) multiplier += 0.5;
  
  // Worker trust discount
  const trustDiscounts = { 1: 0, 2: 0.05, 3: 0.10, 4: 0.20, 5: 0.30 };
  multiplier -= trustDiscounts[input.worker_trust_tier];
  
  // Claim history penalty
  multiplier += input.worker_claim_history * 0.15;
  
  // Property access premium
  if (input.task_property_access) multiplier += 0.25;
  
  // Location risk adjustment
  if (input.location_property_value === 'luxury') multiplier += 0.4;
  if (input.location_crime_index > 0.7) multiplier += 0.2;
  
  // Insurance discount
  if (input.worker_insurance_verified) multiplier -= 0.15;
  
  // Floor and ceiling
  return Math.max(0.5, Math.min(3.0, multiplier));
}
```

### 2.5 Safety Pool Architecture

```
TASK CREATED (escrow funded)
  → Premium calculated by AI (Layer 4 proposal)
  → Deterministic system validates premium within bounds (Layer 1)
  → Premium deducted from escrow amount
  → Premium deposited into Safety Pool (Stripe sub-account)
  → Pool balance tracked in safety_pool_ledger

POOL STRUCTURE:
┌──────────────────────────────────────────────────────────┐
│ Safety Pool (Stripe Connected Account)                    │
│                                                          │
│ ┌─────────────────┐  ┌──────────────┐  ┌─────────────┐ │
│ │ Property Damage  │  │ Injury       │  │ Dispute     │ │
│ │ Reserve (60%)    │  │ Reserve (25%)│  │ Reserve(15%)│ │
│ └─────────────────┘  └──────────────┘  └─────────────┘ │
│                                                          │
│ Minimum Balance: $10,000 (platform-funded seed)          │
│ Target Balance: 3x average monthly claims                │
│ Overflow: Excess moved to high-yield account quarterly   │
└──────────────────────────────────────────────────────────┘
```

### 2.6 Automated Claims Pipeline

```
CLAIM FILED (by poster or worker)
  │
  ├─ Step 1: Intake
  │   └─ Claim type: PROPERTY_DAMAGE | INJURY | THEFT | OTHER
  │   └─ Evidence required: photos, description, estimated value
  │   └─ Claim amount: user-declared (capped at task value × 3)
  │
  ├─ Step 2: Judge Agent Cross-Reference
  │   └─ Pull before/after proof from JUDGE_AGENT verification
  │   └─ Compare LiDAR scans if available (spatial diff)
  │   └─ Compare photo evidence (visual diff)
  │   └─ GPS/timestamp verification (claim happened at task site)
  │   └─ Output: claim_confidence (0-1)
  │
  ├─ Step 3: Automated Verdict (Layer 4 → Layer 1)
  │   │
  │   ├─ IF claim_confidence >= 0.90 AND claim_amount <= $200:
  │   │   └─ AUTO-APPROVE: Instant payout from pool
  │   │   └─ Worker trust impact: -0.05
  │   │   └─ Payout via Stripe to claimant within 24 hours
  │   │
  │   ├─ IF claim_confidence >= 0.75 AND claim_amount <= $500:
  │   │   └─ FAST-TRACK: Human review within 48 hours
  │   │   └─ Provisional hold on worker earnings
  │   │
  │   └─ IF claim_confidence < 0.75 OR claim_amount > $500:
  │       └─ FULL REVIEW: Human adjudication required
  │       └─ Both parties notified, evidence window opens
  │       └─ Resolution target: 5 business days
  │
  └─ Step 4: Payout
      └─ Approved claims paid from Safety Pool
      └─ If pool insufficient: platform backstop (guaranteed payout)
      └─ Payout logged in safety_pool_ledger
      └─ Worker trust score adjusted per outcome
```

### 2.7 Pool Health Monitoring

```typescript
interface PoolHealthMetrics {
  current_balance: number;
  monthly_inflow: number;          // Premiums collected
  monthly_outflow: number;         // Claims paid
  loss_ratio: number;              // outflow / inflow (target: < 0.6)
  claim_frequency: number;         // Claims per 1000 tasks
  average_claim_amount: number;
  reserve_months: number;          // balance / average monthly outflow
  
  // Alerts
  alerts: {
    LOW_BALANCE: boolean;          // balance < minimum ($10k)
    HIGH_LOSS_RATIO: boolean;      // loss_ratio > 0.8
    SPIKE_DETECTED: boolean;       // 3x normal claim frequency
    FRAUD_CLUSTER: boolean;        // Multiple claims from same area/users
  };
}
```

---

## 3. PILLAR 2: Worker Classification Fortress

### 3.1 Legal Foundation

HustleXP workers are **independent contractors**, not employees. This classification must be defensible under:
- Federal: IRS 20-factor test, ABC test
- State: California AB5, Massachusetts IC test, New York freelance laws
- Emerging: DOL 2024 economic reality test

**The system is architecturally designed so that misclassification is structurally impossible.**

### 3.2 Six Pillars of Contractor Status (Enforced in Code)

```
┌───────────────────────────────────────────────────────────────────────┐
│ PILLAR                │ REQUIREMENT              │ ENFORCEMENT        │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 1. Non-Exclusivity    │ Workers may use other    │ No penalties for   │
│                       │ platforms simultaneously  │ declining tasks,   │
│                       │ + Self-select from 130+   │ no exclusivity     │
│                       │ skills (SKILL_TAXONOMY)   │ clauses anywhere.  │
│                       │ as independent businesses │ Skill self-select  │
│                       │                          │ = IC evidence.     │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 2. Task Acceptance    │ Workers choose which     │ No auto-assignment │
│    Freedom            │ tasks to accept          │ No minimum accept  │
│                       │                          │ rate, no penalties  │
│                       │                          │ for declining      │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 3. Schedule Control   │ Workers set their own    │ No shift system,   │
│                       │ availability and hours   │ no mandatory hours │
│                       │                          │ no "online status" │
│                       │                          │ requirements       │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 4. Pricing Control    │ Workers influence their  │ AI suggests base   │
│    (Profit/Loss       │ earnings through rate    │ rate, worker sets  │
│     Opportunity)      │ multiplier               │ multiplier (0.8x - │
│                       │                          │ 2.0x), shown to    │
│                       │                          │ poster as final    │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 5. Tools & Equipment  │ Workers use own tools    │ No company-issued  │
│                       │ Platform offers optional │ equipment, tool    │
│                       │ rental marketplace       │ rental is optional │
│                       │                          │ and market-priced  │
├───────────────────────┼──────────────────────────┼────────────────────┤
│ 6. Method Control     │ Workers decide HOW to    │ Task defines WHAT  │
│                       │ complete the task        │ (outcome), not HOW │
│                       │                          │ (process). No step │
│                       │                          │ by step mandates   │
└───────────────────────┴──────────────────────────┴────────────────────┘
```

### 3.3 Rate Multiplier System

```typescript
interface RateMultiplier {
  // AI-suggested base rate
  ai_base_rate: number;            // From pricing AI (AI_INFRASTRUCTURE §21)
  
  // Worker control
  worker_multiplier: number;       // 0.8x to 2.0x (worker chooses)
  worker_final_rate: number;       // ai_base_rate × worker_multiplier
  
  // Display
  poster_sees: number;             // worker_final_rate (final price)
  worker_sees: {
    suggested_rate: number;        // ai_base_rate
    your_rate: number;             // worker_final_rate
    multiplier: number;            // worker_multiplier
    market_context: string;        // "85% of workers charge $18-22 for this"
  };
  
  // Constraints
  min_multiplier: 0.8;             // Floor: prevent race to bottom
  max_multiplier: 2.0;             // Ceiling: prevent pricing out
  
  // Legal significance:
  // "Opportunity for profit or loss" is THE key indicator
  // of independent contractor status under economic reality test
}
```

### 3.4 Anti-Misclassification Invariants

```
INV-CLASS-1: No Exclusivity Enforcement
The system MUST NOT penalize workers for using competing platforms.
No acceptance rate tracking. No "availability score." No loyalty bonuses
that create economic dependence.
Enforcement: No database column tracking decline rate or platform loyalty.

INV-CLASS-2: No Process Control
Task descriptions define OUTCOMES ("kitchen cleaned"), never PROCESS
("wipe counters, then mop floor, then take trash out").
Enforcement: AI task completion system validates outcome-based descriptions.
Task creation rejects step-by-step process instructions.

INV-CLASS-3: No Schedule Mandates
No minimum hours. No shift system. No penalties for inactivity.
Workers may go offline for any duration without consequence.
Enforcement: No "last active" penalties. No "inactive account" warnings.
Trust score NEVER decays from inactivity alone.

INV-CLASS-4: Pricing Freedom
Workers ALWAYS have a rate multiplier. AI suggestions are advisory.
The worker's chosen rate is shown to posters without modification.
Enforcement: rate_multiplier column on worker profile, required for task acceptance.

INV-CLASS-5: Tool Independence
Platform never issues tools. Optional tool rental is at market rates
through third-party integration, not platform-subsidized.
Enforcement: No "company equipment" database table. No tool tracking.

INV-CLASS-6: Termination Symmetry
Workers can stop mid-task (with escrow consequences).
Platform can only deactivate for safety/fraud (documented cause).
No "at-will termination" that mimics employment.
Enforcement: Deactivation requires fraud_signal or safety_incident record.
```

### 3.5 Classification Audit Trail

```sql
CREATE TABLE classification_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID NOT NULL REFERENCES users(id),
  
  -- Periodic compliance check
  audit_type TEXT NOT NULL CHECK (audit_type IN (
    'ONBOARDING', 'QUARTERLY', 'INCIDENT', 'REGULATORY'
  )),
  
  -- Six pillar verification
  non_exclusivity_pass BOOLEAN NOT NULL,
  task_freedom_pass BOOLEAN NOT NULL,
  schedule_control_pass BOOLEAN NOT NULL,
  pricing_control_pass BOOLEAN NOT NULL,
  tool_independence_pass BOOLEAN NOT NULL,
  method_control_pass BOOLEAN NOT NULL,
  
  -- Result
  all_pass BOOLEAN GENERATED ALWAYS AS (
    non_exclusivity_pass AND task_freedom_pass AND 
    schedule_control_pass AND pricing_control_pass AND 
    tool_independence_pass AND method_control_pass
  ) STORED,
  
  -- Evidence
  evidence JSONB NOT NULL,          -- Specific data points checked (see evidence schema below)
  auditor TEXT NOT NULL,            -- 'SYSTEM' or admin user ID
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_classification_audit_worker ON classification_audit(worker_id);
CREATE INDEX idx_classification_audit_failures 
  ON classification_audit(worker_id) WHERE all_pass = FALSE;
```

**Classification Audit Evidence Schema (JSONB):**

The `evidence` field MUST include self-selection data when `audit_type = 'ONBOARDING'`:

```json
{
  "pillar_1_non_exclusivity": {
    "claimed_skills_count": 15,
    "skills_across_categories": 4,
    "self_selected": true,
    "selection_source": "onboarding_skill_cloud",
    "selection_timestamp": "2025-01-15T10:30:00Z",
    "legal_significance": "Worker self-selected services from 130+ skill taxonomy as independent business — not assigned by platform"
  },
  "pillar_2_task_freedom": { "decline_penalty_exists": false },
  "pillar_3_schedule_control": { "shift_system_exists": false },
  "pillar_4_pricing_control": { "rate_multiplier_enabled": true, "range": "0.8x-2.0x" },
  "pillar_5_tool_independence": { "company_equipment_issued": false },
  "pillar_6_method_control": { "process_mandates_found": false }
}
```

---

## 4. PILLAR 3: Behavioral Integrity System ("Shadow Level")

### 4.1 Concept

A visible ban creates lawsuits. A visible trust score creates gaming.
The Shadow Level is an **invisible integrity layer** that adjusts what a worker sees and can access — without ever telling them their exact score.

### 4.2 Shadow Score Computation

```typescript
interface ShadowScore {
  worker_id: string;
  
  // Composite score (0-100, higher = more trusted)
  composite_score: number;
  
  // Sub-scores
  components: {
    verification_integrity: number;    // 0-100, credential honesty
    behavioral_consistency: number;    // 0-100, fingerprint stability
    spatial_integrity: number;         // 0-100, GPS/location honesty
    temporal_integrity: number;        // 0-100, timing patterns
    financial_integrity: number;       // 0-100, payment/claim patterns
    social_integrity: number;          // 0-100, rating/review patterns
  };
  
  // Current effect
  queue_tier: 'STANDARD' | 'RESTRICTED' | 'PROBATION';
  visible_task_filter: 'ALL' | 'MEDIUM_AND_BELOW' | 'LOW_ONLY';
  verification_rigor: 'STANDARD' | 'ENHANCED' | 'MAXIMUM';
  
  // CRITICAL: Worker NEVER sees this score
  // Worker sees: normal app experience (or slightly fewer high-value tasks)
}
```

### 4.3 Anti-Spoofing Protocol

#### 4.3.1 GPS Emulator Detection

```typescript
interface GPSIntegrityCheck {
  // Impossible travel detection
  impossibleTravel: {
    lastKnownLocation: { lat: number; lng: number; timestamp: string };
    currentLocation: { lat: number; lng: number; timestamp: string };
    distanceKm: number;
    timeElapsedMinutes: number;
    maxPossibleSpeedKmh: number;    // Based on road network
    
    // FAIL if: distanceKm / (timeElapsedMinutes / 60) > maxPossibleSpeedKmh × 1.5
    verdict: 'PLAUSIBLE' | 'SUSPICIOUS' | 'IMPOSSIBLE';
  };
  
  // Emulator indicators
  emulatorSignals: {
    mockLocationEnabled: boolean;     // Android: isMockLocation flag
    noGPSHardware: boolean;          // Device reports no GPS chip
    perfectCoordinates: boolean;      // Suspiciously round lat/lng
    staticAltitude: boolean;          // Real GPS has altitude variation
    noAccuracyVariation: boolean;     // Real GPS fluctuates ±5-20m
    vpnDetected: boolean;            // IP location vs GPS mismatch
  };
  
  // Scoring
  emulatorProbability: number;       // 0-1
  // > 0.7 → SILENT DE-LEVEL (restricted queue for 48h)
  // > 0.9 → IMMEDIATE FLAG (account review)
}
```

#### 4.3.2 App Tampering Detection

```typescript
interface AppIntegrityCheck {
  // Runtime checks
  jailbreakDetected: boolean;        // iOS: Cydia, substrate
  rootDetected: boolean;             // Android: su binary, Magisk
  debuggerAttached: boolean;         // Frida, LLDB detection
  hookingDetected: boolean;          // Method swizzling, Xposed
  repackagedApp: boolean;            // Bundle signature mismatch
  
  // Attestation
  deviceAttestationValid: boolean;   // iOS DeviceCheck / Android Play Integrity
  appAttestationValid: boolean;      // App Store / Play Store receipt
  
  // Response (graduated, NOT instant ban)
  if_tampering_detected: {
    level_1: 'Log signal, continue monitoring',
    level_2: 'Require selfie verification for next task',
    level_3: 'Restrict to low-value tasks for 72h',
    level_4: 'Flag for human review (potential ban)'
  };
}
```

#### 4.3.3 Behavioral Fingerprint (Account Sharing Detection)

```typescript
interface BehavioralFingerprint {
  worker_id: string;
  
  // Baseline (built over first 20 tasks)
  baseline: {
    avgTypingSpeed: number;          // Words per minute
    avgNavigationPattern: string;    // Screen transition sequences
    avgResponseTime: number;         // Seconds to respond to notifications
    avgSessionDuration: number;      // Minutes per app session
    preferredTaskCategories: string[];
    activeHours: number[];           // Typical hours of activity (0-23)
    deviceModel: string;
    screenResolution: string;
    touchPressure: number;           // Average touch force (if available)
  };
  
  // Current session
  current: {
    // Same fields as baseline
  };
  
  // Deviation detection
  deviationScore: number;            // 0-1 (0 = identical to baseline)
  
  // Thresholds
  // deviationScore > 0.4 → Log and monitor
  // deviationScore > 0.6 → Trigger Mandatory Selfie Challenge
  // deviationScore > 0.8 → Restrict to low-value tasks + selfie
  
  // Selfie Challenge
  selfieChallenge: {
    type: 'LIVENESS';
    prompts: [
      'Turn your head slowly to the left',
      'Blink twice',
      'Hold up [random number] fingers',
      'Smile, then return to neutral'
    ];
    // Random prompt selection prevents pre-recording
    // Must match ID photo on file (facial recognition)
    // Deepfake detection: texture analysis, blink pattern, 3D depth
    maxAttempts: 3;
    lockoutOnFail: '24 hours';
  };
}
```

### 4.4 De-Leveling Mechanics (Soft Penalties)

**Philosophy:** Bans create lawsuits and destroy revenue. De-leveling creates natural friction that bad actors self-select out of.

```
┌──────────────────┬─────────────────────────────────────────────────────────┐
│ Shadow Tier      │ Effect (INVISIBLE to worker)                            │
├──────────────────┼─────────────────────────────────────────────────────────┤
│ STANDARD         │ Full access to all eligible tasks                       │
│ (score 70-100)   │ Normal verification requirements                       │
│                  │ Standard multi-sig windows                              │
├──────────────────┼─────────────────────────────────────────────────────────┤
│ RESTRICTED       │ High-value tasks hidden (> $100)                        │
│ (score 40-69)    │ Enhanced verification (extra photo/video required)      │
│                  │ Longer multi-sig windows (30 min → 60 min)              │
│                  │ Duration: 48-hour rolling window                        │
│                  │ Recovery: 5 clean low-value task completions             │
├──────────────────┼─────────────────────────────────────────────────────────┤
│ PROBATION        │ Only LOW risk tasks visible                             │
│ (score 10-39)    │ Maximum verification (video + selfie required)          │
│                  │ Extended multi-sig windows (60 min)                     │
│                  │ Rate multiplier capped at 1.0x                          │
│                  │ Duration: 7-day rolling window                          │
│                  │ Recovery: 10 clean task completions                     │
├──────────────────┼─────────────────────────────────────────────────────────┤
│ FROZEN           │ No tasks visible ("No tasks available in your area")    │
│ (score 0-9)      │ Account flagged for human review                       │
│                  │ Worker sees empty feed (no error, no explanation)       │
│                  │ Recovery: Human review only                             │
└──────────────────┴─────────────────────────────────────────────────────────┘
```

**Critical UX Rule:**
```
The worker NEVER sees: "Your account has been restricted"
The worker ALWAYS sees: "No tasks available right now" or normal UI with fewer results

This is not deception. It is friction-based enforcement.
Explicit bans → lawsuits.
Invisible friction → bad actors leave voluntarily.
```

### 4.5 Signal Decay and Recovery

```typescript
interface SignalDecay {
  // Negative signals decay over time (people improve)
  decayRules: {
    GPS_ANOMALY:        { halfLife: '14 days', maxAge: '90 days' },
    FINGERPRINT_DRIFT:  { halfLife: '7 days',  maxAge: '30 days' },
    EMULATOR_DETECTED:  { halfLife: '30 days', maxAge: '180 days' },
    CLAIM_FILED:        { halfLife: '60 days', maxAge: '365 days' },
    FRAUD_CONFIRMED:    { halfLife: 'NEVER',   maxAge: 'PERMANENT' },
    TAMPERED_APP:       { halfLife: '30 days', maxAge: '180 days' },
  };
  
  // Positive signals build trust
  buildRules: {
    CLEAN_COMPLETION:   { weight: 1.0,  context: 'per task' },
    FIVE_STAR_RATING:   { weight: 0.5,  context: 'per rating received' },
    DISPUTE_WON:        { weight: 2.0,  context: 'worker was right' },
    LONG_TENURE:        { weight: 0.1,  context: 'per month active' },
    HIGH_VALUE_CLEAN:   { weight: 1.5,  context: 'task > $100, no issues' },
  };
}
```

---

## 5. PILLAR 4: Layered Trust Defense

### 5.1 Defense Stack

```
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 4: BEHAVIORAL (Ongoing)                                   │
│ Fingerprint monitoring, pattern analysis, anomaly detection     │
│ Technology: ML behavioral models, statistical analysis          │
│ When: Every session, every task, continuously                   │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 3: SPATIAL (Per-Task)                                     │
│ GPS verification, LiDAR scans, Visual SLAM                     │
│ Technology: Device sensors, Judge Agent integration             │
│ When: Task start, proof submission, random spot checks          │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 2: LIVENESS (Periodic + Triggered)                        │
│ Anti-deepfake selfie challenges, facial matching                │
│ Technology: 3D depth sensing, texture analysis, prompt-response │
│ When: Onboarding, behavioral deviation, random audit            │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 1: FOUNDATION (One-Time + Renewal)                        │
│ Government ID verification, device binding                      │
│ Technology: Stripe Identity / ID verification API               │
│ When: Onboarding, annual renewal, device change                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Foundation Layer — Identity Verification

```typescript
interface IdentityVerification {
  // Onboarding (mandatory)
  governmentId: {
    provider: 'stripe_identity';     // Stripe Identity API
    documentTypes: ['drivers_license', 'passport', 'state_id'];
    selfieRequired: true;
    livenessRequired: true;          // Not just a photo of a photo
    
    // Output
    verified: boolean;
    matchConfidence: number;         // Face match to ID photo
    documentExpiry: string;          // Track for renewal
  };
  
  // Device binding
  deviceBinding: {
    primaryDeviceId: string;         // Hashed device identifier
    maxDevices: 2;                   // Primary + one backup
    deviceChangeRequires: 'SELFIE_VERIFICATION';
    
    // If new device appears without selfie → account frozen
  };
  
  // Single-account enforcement
  deduplication: {
    method: 'FACE_EMBEDDING';        // Facial vector comparison
    threshold: 0.95;                 // Match threshold for duplicate detection
    // If face matches existing account → registration blocked
    // Human review for edge cases (twins, similar faces)
  };
}
```

### 5.3 Liveness Layer — Anti-Deepfake

```typescript
interface LivenessVerification {
  // When triggered
  triggers: [
    'ONBOARDING',                    // Always
    'BEHAVIORAL_DEVIATION',          // Fingerprint drift > 0.6
    'DEVICE_CHANGE',                 // New device detected
    'RANDOM_AUDIT',                  // 5% of task starts (random)
    'HIGH_VALUE_TASK',               // Tasks > $300
    'LONG_ABSENCE'                   // First task after 30+ days inactive
  ];
  
  // Challenge design (anti-replay)
  challenge: {
    // Random selection from prompt pool — prevents pre-recording
    promptPool: [
      { action: 'turn_head_left', duration: 2 },
      { action: 'turn_head_right', duration: 2 },
      { action: 'blink_twice', duration: 3 },
      { action: 'hold_fingers', count: 'random(1-5)', duration: 3 },
      { action: 'smile_neutral', duration: 3 },
      { action: 'nod_yes', duration: 2 },
      { action: 'look_up', duration: 2 },
    ];
    promptCount: 2;                  // Two random prompts per challenge
    timeLimit: 30;                   // Seconds to complete
    
    // Deepfake detection signals
    antiDeepfake: {
      textureAnalysis: true,         // Skin texture vs synthetic
      blinkPattern: true,            // Natural blink patterns
      microExpressions: true,        // Sub-second facial movements
      depthConsistency: true,        // 3D depth map (if TrueDepth camera)
      lightingReflection: true,      // Eye reflections match environment
      temporalCoherence: true,       // Face doesn't "flicker" between frames
    };
  };
  
  // Failure handling
  maxAttempts: 3;
  failureAction: 'ACCOUNT_LOCKED_24H';
  // After 3 failures: human review required to unlock
}
```

### 5.4 Spatial Layer — Physical Presence

```
Integrated with JUDGE_AGENT_SPEC_LOCKED.md

This layer verifies the worker is PHYSICALLY at the task location:
- GPS lock before task start
- GPS continuous during task (background, every 5 min)
- GPS at proof submission
- LiDAR/video if trust-gated (see Judge Agent §3.3)

Spatial integrity feeds into Shadow Score → spatial_integrity component

**Canonical movement fraud authority:** `SPATIAL_INTELLIGENCE_LOCKED.md §9 (Movement Integrity Protocol)` defines the 4 fraud signals (STATIONARY_ANOMALY, IMPOSSIBLE_SPEED, LOCATION_MISMATCH, OSCILLATING_POSITION), their thresholds, and the explicit IC compliance boundary — movement analysis is EXCLUSIVELY for fraud detection, NEVER for productivity monitoring, route enforcement, or break detection.
```

### 5.5 Behavioral Layer — Continuous Monitoring

```
Integrated with Shadow Level (Pillar 3, §4.3)

This layer runs continuously:
- Typing patterns
- Navigation patterns
- Session timing
- Device consistency
- GPS trajectory patterns
- Task selection patterns
- Communication patterns

All signals feed Shadow Score → behavioral_consistency component
```

---

## 6. Data Model

### 6.1 Safety Pool Ledger

```sql
CREATE TABLE safety_pool_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Transaction
  transaction_type TEXT NOT NULL CHECK (transaction_type IN (
    'PREMIUM_COLLECTED',
    'CLAIM_PAYOUT',
    'PLATFORM_SEED',
    'OVERFLOW_WITHDRAWAL',
    'ADJUSTMENT'
  )),
  
  amount DECIMAL(10,2) NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('CREDIT', 'DEBIT')),
  running_balance DECIMAL(10,2) NOT NULL,
  
  -- References
  task_id UUID REFERENCES tasks(id),
  claim_id UUID,
  worker_id UUID REFERENCES users(id),
  
  -- Premium details (for PREMIUM_COLLECTED)
  premium_breakdown JSONB,
  
  -- Stripe
  stripe_transfer_id TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pool_ledger_task ON safety_pool_ledger(task_id);
CREATE INDEX idx_pool_ledger_type ON safety_pool_ledger(transaction_type);
```

### 6.2 Claims Table

```sql
CREATE TABLE claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  claimant_id UUID NOT NULL REFERENCES users(id),
  respondent_id UUID NOT NULL REFERENCES users(id),
  
  -- Claim details
  claim_type TEXT NOT NULL CHECK (claim_type IN (
    'PROPERTY_DAMAGE', 'INJURY', 'THEFT', 'SERVICE_QUALITY', 'OTHER'
  )),
  description TEXT NOT NULL,
  claimed_amount DECIMAL(10,2) NOT NULL,
  
  -- Judge Agent assessment
  judge_confidence DECIMAL(4,3),
  judge_evidence JSONB,
  
  -- Resolution
  state TEXT NOT NULL DEFAULT 'FILED' CHECK (state IN (
    'FILED', 'UNDER_REVIEW', 'APPROVED', 'DENIED', 'PARTIAL', 'APPEALED'
  )),
  approved_amount DECIMAL(10,2),
  resolution_reason TEXT,
  resolved_by TEXT,                    -- 'AUTO' or admin user ID
  
  -- Timestamps
  filed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ
);
```

### 6.3 Shadow Scores Table

```sql
CREATE TABLE shadow_scores (
  worker_id UUID PRIMARY KEY REFERENCES users(id),
  
  -- Composite
  composite_score INTEGER NOT NULL DEFAULT 80 CHECK (composite_score BETWEEN 0 AND 100),
  
  -- Components
  verification_integrity INTEGER NOT NULL DEFAULT 80,
  behavioral_consistency INTEGER NOT NULL DEFAULT 80,
  spatial_integrity INTEGER NOT NULL DEFAULT 80,
  temporal_integrity INTEGER NOT NULL DEFAULT 80,
  financial_integrity INTEGER NOT NULL DEFAULT 80,
  social_integrity INTEGER NOT NULL DEFAULT 80,
  
  -- Derived state
  queue_tier TEXT NOT NULL DEFAULT 'STANDARD' CHECK (queue_tier IN (
    'STANDARD', 'RESTRICTED', 'PROBATION', 'FROZEN'
  )),
  
  -- Metadata
  last_computed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  signal_count INTEGER NOT NULL DEFAULT 0,
  
  -- CRITICAL: This table is NEVER exposed to the worker
  -- No API endpoint returns shadow_score to the worker's device
);

-- Ensure shadow score is never stale
CREATE INDEX idx_shadow_recompute ON shadow_scores(last_computed_at)
  WHERE last_computed_at < NOW() - INTERVAL '24 hours';
```

### 6.4 Fraud Signals Table

```sql
CREATE TABLE fraud_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID NOT NULL REFERENCES users(id),
  
  signal_type TEXT NOT NULL CHECK (signal_type IN (
    'GPS_EMULATOR', 'IMPOSSIBLE_TRAVEL', 'APP_TAMPERED',
    'FINGERPRINT_DRIFT', 'DEVICE_ATTESTATION_FAIL',
    'SELFIE_MISMATCH', 'DUPLICATE_ACCOUNT',
    'SUSPICIOUS_CLAIM_PATTERN', 'RATING_MANIPULATION',
    'RAPID_ACCOUNT_CREATION', 'FAKE_PROOF'
  )),
  
  severity TEXT NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  confidence DECIMAL(4,3) NOT NULL,
  evidence JSONB NOT NULL,
  
  -- Decay
  decayed BOOLEAN NOT NULL DEFAULT FALSE,
  decay_at TIMESTAMPTZ,
  
  -- Response
  action_taken TEXT,
  reviewed_by TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fraud_signals_worker ON fraud_signals(worker_id);
CREATE INDEX idx_fraud_signals_active ON fraud_signals(worker_id)
  WHERE decayed = FALSE;
```

---

## 7. Invariant Registry

```
INV-RISK-1: Premium Cannot Exceed 15% of Task Value
Enforcement: Database CHECK constraint on premium calculation
Rationale: Premiums must be reasonable; excessive fees destroy marketplace economics

INV-RISK-2: Safety Pool Cannot Go Negative
Enforcement: Platform backstop guarantee; if pool < $0, platform funds difference
Rationale: Claimants must always be paid, regardless of pool state

INV-RISK-3: Shadow Score Never Exposed to Worker
Enforcement: No API endpoint returns shadow_score for authenticated worker
Zero frontend references to shadow_score. No UI component displays it.
Rationale: Visibility enables gaming; invisibility enables honest enforcement

INV-RISK-4: No Exclusivity Enforcement (Classification Protection)
Enforcement: No database column tracking decline rate or platform loyalty
No penalties triggered by task refusal
Rationale: Core independent contractor requirement

INV-RISK-5: De-Leveling Before Banning (Graduated Response)
Enforcement: Account deactivation requires queue_tier = 'FROZEN' for 7+ days
AND human review approval. No instant bans except confirmed fraud.
Rationale: Graduated response reduces legal exposure

INV-RISK-6: Claims Must Reference Judge Agent Evidence
Enforcement: claims.judge_evidence NOT NULL for AUTO-APPROVE
Foreign key to verification_audit table
Rationale: Automated payouts require AI evidence trail

INV-RISK-7: Rate Multiplier Always Available
Enforcement: Worker profile requires rate_multiplier (default 1.0)
Task acceptance blocked if multiplier not set
Rationale: Core "opportunity for profit/loss" contractor indicator

INV-RISK-8: Liveness Challenge Cannot Be Predicted
Enforcement: Prompt selection is cryptographically random
No sequential patterns, no user-influenced selection
Rationale: Predictable challenges can be pre-recorded or deepfaked

INV-RISK-9: Fraud Signal Decay is Automatic
Enforcement: Scheduled job runs daily, applies decay rules
Signals cannot be manually un-decayed except by system admin
Rationale: People improve; permanent records without decay create legal risk

INV-RISK-10: Premium Breakdown Logged Per Task
Enforcement: safety_pool_ledger.premium_breakdown NOT NULL for PREMIUM_COLLECTED
Rationale: Financial auditability requires per-task premium documentation
```

---

## 8. Screen Integration

| Screen | Integration Point |
|--------|-------------------|
| TaskCreation (P2) | Premium displayed to poster as "Safety Fee" |
| TaskFeed (H2) | Shadow-filtered results (restricted workers see fewer) |
| TaskDetail | Rate multiplier display for worker pricing |
| ProofSubmission (SH3) | Evidence tier from shadow-adjusted Judge requirements |
| Settings (S1-S6) | Rate multiplier configuration |
| Onboarding (O3-O6) | Identity verification, device binding, initial liveness |

---

## 9. Phased Implementation

### Phase 1 — Foundation (v1.0)
```
✅ Identity verification (Stripe Identity) at onboarding
✅ Device binding (single device)
✅ Fixed safety fee per task category (not yet AI-dynamic)
✅ Basic GPS verification (Judge Agent Layer 1)
✅ Worker rate multiplier (0.8x - 2.0x)
✅ Classification audit trail
✅ Claims table (manual review only)
✅ Shadow score table (computed but not yet influencing feed)
```

### Phase 2 — Active (v1.5)
```
◻ AI-dynamic premium calculation
◻ Safety pool with automated claims (< $200)
◻ Shadow score influencing feed visibility
◻ GPS emulator detection
◻ App tampering detection
◻ Basic behavioral fingerprinting (device + timing)
◻ Liveness challenges (behavioral deviation trigger)
◻ De-leveling mechanics (RESTRICTED tier)
```

### Phase 3 — Advanced (v2.0)
```
◻ Full behavioral biometrics (typing, navigation, touch)
◻ Deepfake detection in liveness challenges
◻ LiDAR integration for spatial claims verification
◻ Automated claims up to $500
◻ Pool health monitoring and premium auto-adjustment
◻ Cross-signal pattern detection (fraud clusters)
◻ PROBATION and FROZEN tiers active
◻ Impossible travel detection
```

---

## 9a. Compound Pattern Detection

Individual signals (cancellation, dispute, low rating) are weak. Compound patterns across rolling windows are where real abuse hides. This section defines the cross-signal rules that trigger escalation.

### 9a.1 Rolling Window Metrics

Every user has three rolling windows computed continuously:

| Window | Period | Updated |
|---|---|---|
| `metrics_7d` | Last 7 calendar days | Hourly |
| `metrics_30d` | Last 30 calendar days | Every 6 hours |
| `metrics_90d` | Last 90 calendar days | Daily |

**Metrics tracked per window:**
- `cancellation_count` — tasks cancelled by this user
- `late_cancel_count` — cancellations within 2h of deadline
- `no_show_count` — auto-cancelled due to no arrival
- `dispute_count` — disputes opened (as either party)
- `dispute_loss_count` — disputes lost
- `avg_rating_received` — mean rating from counterparties
- `rating_decline_velocity` — (avg_rating_30d - avg_rating_7d)
- `rejection_count` — proof rejections issued (posters) or received (workers)
- `task_completion_count` — successfully completed tasks
- `completion_rate` — completed / (completed + cancelled + no_show + expired)

### 9a.2 Compound Trigger Rules

| Rule ID | Condition | Action | Rationale |
|---|---|---|---|
| CPR-1 | `late_cancel_count_7d >= 3` | 24h acceptance cooldown + warning | Unreliable worker |
| CPR-2 | `no_show_count_30d >= 2` | 48h cooldown + shadow flag `NO_SHOW_PATTERN` | Ghost worker |
| CPR-3 | `dispute_loss_count_30d >= 2 AND completion_rate_30d < 0.7` | Trust tier review (possible demotion) | Pattern of poor work |
| CPR-4 | `rating_decline_velocity < -0.5` (i.e., ratings dropping fast) | Human review flag | Quality declining |
| CPR-5 | `rejection_count_7d >= 5` (poster) | Warning + reduced task posting rate (5/day cap) | Potentially exploitative poster |
| CPR-6 | `cancellation_count_7d >= 3 AND dispute_count_7d >= 1` | Shadow score -15 | Combined unreliability |
| CPR-7 | `completion_rate_90d < 0.5 AND task_completion_count_90d > 5` | Trust tier demotion | Persistent underperformance |
| CPR-8 | `avg_rating_received_30d < 3.0 AND task_completion_count_30d >= 3` | Probation warning | Consistently poor quality |

### 9a.3 Escalation Matrix

Compound triggers stack. Multiple active triggers escalate severity:

| Active Triggers | Severity | Action |
|---|---|---|
| 1 | Low | Automated warning + metric tracking |
| 2 | Medium | Cooldown applied + human review queued |
| 3+ | High | Account restricted, admin review required within 24h |
| Any trigger + existing `RESTRICTED` shadow level | Critical | Immediate suspension pending review |

### 9a.4 Fraud Cluster Detection (Phase 2)

Cross-user compound patterns that indicate coordinated fraud:

| Pattern | Detection | Action |
|---|---|---|
| Same poster + same worker on 5+ tasks in 7 days | SQL: pair frequency query | Flag both accounts |
| Poster creates task → specific worker always accepts within 30s | Acceptance latency anomaly | Flag as possible collusion |
| 3+ accounts share device fingerprint | Join `device_fingerprints` | Flag all accounts for Sybil review |
| Worker completes tasks only for new accounts (<7 days old) | Join users by created_at | Flag for onboarding fraud |

**Implementation:** Background job runs compound pattern queries every hour. Results written to `compound_pattern_alerts` table. Operations dashboard surfaces alerts by severity.

---

## 10. Kill Switches

```
| Switch                      | Effect                                         |
|-----------------------------|-------------------------------------------------|
| SAFETY_POOL_DISABLED        | Fixed fee collected, manual claims only         |
| SHADOW_SCORE_DISABLED       | All workers see full feed, standard verification|
| GPS_VERIFICATION_DISABLED   | Skip location checks (emergency only)           |
| LIVENESS_DISABLED           | Skip selfie challenges (privacy emergency)      |
| BEHAVIORAL_DISABLED         | Stop fingerprint collection                     |
| AUTO_CLAIMS_DISABLED        | All claims require human review                 |
| RATE_MULTIPLIER_DISABLED    | All workers use AI base rate (LEGAL RISK)       |
| DE_LEVELING_DISABLED        | No shadow tier effects on feed                  |
```

**WARNING:** Disabling RATE_MULTIPLIER removes "opportunity for profit/loss" — this weakens contractor classification defense. Legal review required before use.

---

## 11. Integration Points

| System | Integration |
|--------|-------------|
| JUDGE_AGENT_SPEC_LOCKED.md | Fraud signals feed shadow score; claims reference Judge evidence |
| POSTER_TASK_CREATION_RISK_CLASSIFIER | Risk level determines base premium |
| CAPABILITY_PROFILE_SCHEMA | Trust tier modifies premium and verification rigor |
| VERIFICATION_PIPELINE_LOCKED | License/insurance status feeds risk calculation |
| RATING_SYSTEM_SPEC | Ratings feed social_integrity shadow component |
| AI_INFRASTRUCTURE.md §10 | Anti-gaming controls, inconsistency detection |
| AI_INFRASTRUCTURE.md §21 | Session Forecast provides base rate for multiplier |
| PRODUCT_SPEC INV-ELIGIBILITY-1 | Trust tier → risk clearance mapping |
| TRIGGERS_AND_CONSTRAINTS.sql | Existing escrow/XP enforcement chain |
| Stripe Identity | Foundation layer ID verification |
| Stripe Connect | Safety pool sub-account, claim payouts |

---

## 12. Chosen-State Integration

```
Worker experience:
  ✅ "Safety fee: $1.50" (transparent, feels professional)
  ✅ "Set your rate" with multiplier (feels empowering)
  ✅ Restricted feed shows as "No tasks nearby" (feels normal)
  ✅ Liveness challenge feels like "security check" (feels protective)
  ❌ "Your trust score is 47" (feels punishing)
  ❌ "You've been restricted" (feels adversarial)
  ❌ "Your account is under review" (feels threatening)
  ❌ "Safety premium: high risk detected" (feels accusatory)

Poster experience:
  ✅ "Safety fee included" (feels protected)
  ✅ "Claim filed — resolution in 24-48 hours" (feels fast)
  ✅ Worker's rate clearly shown (feels fair)
  ❌ "Worker shadow score: 62" (breaks trust theater)
  ❌ "This worker has fraud flags" (creates bias)
```

---

**This specification is LOCKED.**
**Risk is automated. Trust is computed. Safety is funded.**
**The system sees everything. The worker sees normalcy.**
