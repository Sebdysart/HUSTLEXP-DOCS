# HustleXP — AI Infrastructure Specification v1.1

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Applies to:** All AI features (Onboarding, Pricing, Matching, Trust, Disputes, Proof, Support, Moderation)  
**Last Updated:** January 2025  
**Governance:** This spec governs all AI behavior. Violations are build failures.

---

## 0. Prime Directive

HustleXP uses AI to **propose** structured outputs and compute probabilistic signals. AI is **never** the final authority for irreversible state changes.

**Invariant:**

```
AI proposes.
Deterministic systems decide.
Databases enforce.
UI reveals.
```

If any feature violates this invariant, it is **invalid by definition**.

### 0.1 Integration with BUILD_GUIDE Authority Hierarchy

This spec's authority levels map to BUILD_GUIDE Layer 4:

| BUILD_GUIDE Layer | System | AI_INFRASTRUCTURE Mapping |
|-------------------|--------|---------------------------|
| 0 | PostgreSQL constraints | AI forbidden (A0) |
| 1 | Backend state machines | AI forbidden (A0) |
| 2 | Temporal enforcement | AI forbidden (A0) |
| 3 | Payments (Stripe) | AI forbidden (A0) |
| **4** | **AI proposal layer** | **A1-A3 (this spec)** |
| 5 | UI state machines | AI read-only (A1) |
| 6 | Client rendering | AI read-only (A1) |

**Rule:** AI operates ONLY at Layer 4. All higher layers are deterministic and immutable by AI.

---

## 1. Scope

This document defines:

1. AI authority levels and where AI is allowed/forbidden
2. Canonical AI execution flow and service boundaries
3. Required schemas and validation rules for AI I/O
4. Audit, replay, and dispute-grade traceability
5. Security, privacy, and abuse controls (including proof photos)
6. Operational requirements: evaluation, monitoring, and kill switches
7. Database schemas for AI tracking
8. tRPC endpoint contracts

This document does **not** define UI layout details. UI specs must reference this doc for AI behavior.

---

## 2. Definitions

### 2.1 "AI" (in this system)

Any probabilistic model output used to influence product behavior:

* LLM reasoning outputs
* Classifiers
* Embedding similarity
* Vision models (image evidence analysis)
* Multi-model orchestration

### 2.2 "Authority"

The ability to mutate or finalize canonical state:

* XP ledger mutations (governed by INV-1, INV-5)
* Trust tier changes
* Payment/escrow changes (governed by INV-2, INV-4)
* Dispute outcomes
* Bans/suspensions (final)

**AI has NO direct authority over these.**

### 2.3 "Proposal"

A structured, typed JSON object produced by AI which may inform deterministic rules.

### 2.4 "Deterministic Rules"

Backend logic that:

* Validates proposals against schemas
* Enforces constraints (INV-1 through INV-5)
* Makes final decisions
* Writes authoritative state within DB transactions

---

## 3. Authority Model

### 3.1 AI Authority Levels

| Level | Name | Description |
|-------|------|-------------|
| **A0** | Forbidden | AI may not participate. Any AI output is ignored. |
| **A1** | Read-Only | AI can summarize, extract, classify for display only. No state mutations. |
| **A2** | Proposal-Only | AI outputs proposals validated by deterministic rules. Cannot directly change state. Must be logged and replayable. |
| **A3** | Restricted Execution | AI may trigger *limited* reversible actions with: strict gating, explicit user consent, rate limits, audit trails, kill switch. No irreversible actions. |

**Hard Rule:** XP/trust/payment/dispute finalization are **NEVER** A3. They remain A0 (deterministic only).

### 3.2 Authority Allocation Table (v1.1)

| Subsystem | Level | AI Role | Invariant Refs |
|-----------|------:|---------|----------------|
| Onboarding role inference | A2 | Propose role confidence + signals | — |
| Task classification (category tags) | A2 | Propose tags + confidence | — |
| Task pricing suggestion | A2 | Propose price range + rationale | — |
| Matching / ranking | A2 | Propose ranked candidates + reasons | — |
| Fraud risk scoring | A2 | Propose risk score + flags | — |
| **Proof request (photo prompts)** | **A3** | Request evidence with user consent; cannot finalize | INV-3 |
| Proof analysis (image evaluation) | A2 | Propose pass/fail/needs-more + confidence | INV-3 |
| Dispute assistance | A1/A2 | Summarize evidence; propose recommendation | INV-2 |
| Content moderation triage | A2 | Propose moderation action | — |
| User support drafting | A1 | Draft replies; humans decide | — |
| **XP awarding** | **A0** | **FORBIDDEN** (deterministic only) | **INV-1, INV-5** |
| **Trust tier mutation** | **A0** | **FORBIDDEN** (deterministic only) | — |
| **Escrow release/capture** | **A0** | **FORBIDDEN** (deterministic only) | **INV-2, INV-4** |
| **Bans/suspensions** | **A0** | **FORBIDDEN** (deterministic + review) | — |

---

## 4. Canonical AI Execution Flow

All AI features MUST follow this pipeline:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. EVENT CAPTURE (Immutable)                                           │
│     User action or system trigger writes immutable event record         │
│     → ai_events table                                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  2. AI JOB CREATION                                                     │
│     Backend enqueues AI job referencing immutable inputs                │
│     → ai_jobs table (status: PENDING)                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  3. AI PROPOSAL GENERATION                                              │
│     AI returns strictly schema-valid JSON proposals                     │
│     → ai_proposals table                                                │
├─────────────────────────────────────────────────────────────────────────┤
│  4. VALIDATION                                                          │
│     Deterministic validators check schema + confidence + constraints    │
│     → ai_validations table                                              │
├─────────────────────────────────────────────────────────────────────────┤
│  5. DECISION                                                            │
│     Deterministic business rules decide accept/reject/ask-more          │
│     → ai_decisions table                                                │
├─────────────────────────────────────────────────────────────────────────┤
│  6. AUTHORITATIVE WRITE                                                 │
│     DB transaction writes authoritative state + references proposal IDs │
│     → Core tables (users, tasks, escrows, etc.)                         │
├─────────────────────────────────────────────────────────────────────────┤
│  7. UI REVEAL                                                           │
│     UI renders final state; may display AI rationale if allowed         │
└─────────────────────────────────────────────────────────────────────────┘
```

**PROHIBITED:** Direct client-to-model calls that affect canonical state.
Client may call AI only for local UX drafts (A1) that do not mutate truth.

---

## 5. AI Services Architecture

### 5.1 Required Services (Logical)

```
┌─────────────────────────────────────────────────────────────────┐
│                      AI ORCHESTRATOR                             │
│  - Single entry point for all AI jobs                           │
│  - Model selection, retries, timeouts                           │
│  - JSON schema validation                                       │
│  - Kill switch enforcement                                      │
└───────────────────────┬─────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ POLICY LAYER  │ │ EVIDENCE SVC  │ │  AUDIT SVC    │
│ - Validators  │ │ - Uploads     │ │ - Immutable   │
│ - Rule engine │ │ - Retention   │ │   logs        │
│ - Constraints │ │ - Access ctrl │ │ - Replay      │
└───────────────┘ └───────────────┘ └───────────────┘
```

### 5.2 Data Stores

| Store | Purpose | Tables |
|-------|---------|--------|
| **PostgreSQL** | Authoritative | users, tasks, escrows, disputes, xp_ledger, trust_ledger, ai_* tables |
| **Object Storage** | Evidence | photos/videos with strict ACL + expiring URLs |
| **Redis** | Operational | rate limiting, job queue, feature flags |

---

## 6. Database Schemas (AI Tracking)

### 6.1 AI Events Table

```sql
CREATE TABLE ai_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  subsystem VARCHAR(50) NOT NULL,  -- e.g., 'onboarding.role_inference'
  event_type VARCHAR(50) NOT NULL, -- e.g., 'calibration_submitted'
  
  -- Actors
  actor_user_id UUID REFERENCES users(id),
  subject_user_id UUID REFERENCES users(id),
  task_id UUID REFERENCES tasks(id),
  dispute_id UUID REFERENCES disputes(id),
  
  -- Immutable payload
  payload JSONB NOT NULL,
  payload_hash VARCHAR(64) NOT NULL,  -- SHA-256 for integrity
  
  -- Versioning
  schema_version VARCHAR(20) NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_events_subsystem ON ai_events(subsystem);
CREATE INDEX idx_ai_events_actor ON ai_events(actor_user_id);
CREATE INDEX idx_ai_events_created ON ai_events(created_at);
```

### 6.2 AI Jobs Table

```sql
CREATE TABLE ai_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Reference
  event_id UUID NOT NULL REFERENCES ai_events(id),
  subsystem VARCHAR(50) NOT NULL,
  
  -- Status
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
    'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'TIMED_OUT', 'KILLED'
  )),
  
  -- Model info
  model_provider VARCHAR(50),  -- e.g., 'anthropic', 'openai'
  model_id VARCHAR(100),       -- e.g., 'claude-3-sonnet'
  prompt_version VARCHAR(20),
  
  -- Timing
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  timeout_ms INTEGER DEFAULT 30000,
  
  -- Retry tracking
  attempt_count INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  last_error TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_jobs_status ON ai_jobs(status);
CREATE INDEX idx_ai_jobs_subsystem ON ai_jobs(subsystem);
```

### 6.3 AI Proposals Table

```sql
CREATE TABLE ai_proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Reference
  job_id UUID NOT NULL REFERENCES ai_jobs(id),
  
  -- Proposal content
  proposal_type VARCHAR(50) NOT NULL,  -- e.g., 'RoleInferenceProposal'
  proposal JSONB NOT NULL,
  proposal_hash VARCHAR(64) NOT NULL,
  
  -- Confidence
  confidence NUMERIC(5,4),
  certainty_tier VARCHAR(20),  -- STRONG, MODERATE, WEAK
  
  -- Anomaly flags
  anomaly_flags TEXT[],
  
  -- Versioning
  schema_version VARCHAR(20) NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_proposals_job ON ai_proposals(job_id);
CREATE INDEX idx_ai_proposals_type ON ai_proposals(proposal_type);
```

### 6.4 AI Decisions Table

```sql
CREATE TABLE ai_decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- References
  proposal_id UUID NOT NULL REFERENCES ai_proposals(id),
  
  -- Decision
  accepted BOOLEAN NOT NULL,
  reason_codes TEXT[] NOT NULL,  -- ['SCHEMA_OK', 'CONFIDENCE_OK', ...]
  
  -- What was written (if accepted)
  writes JSONB,  -- e.g., {"users.default_mode": "worker"}
  
  -- Authority
  final_author VARCHAR(50) NOT NULL,  -- 'system', 'admin:user_id', 'user:user_id'
  
  -- Timestamps
  decided_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_decisions_proposal ON ai_decisions(proposal_id);
CREATE INDEX idx_ai_decisions_accepted ON ai_decisions(accepted);
```

### 6.5 Evidence Table

```sql
CREATE TABLE evidence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  task_id UUID REFERENCES tasks(id),
  dispute_id UUID REFERENCES disputes(id),
  proof_id UUID REFERENCES proofs(id),
  
  -- Uploader
  uploader_user_id UUID NOT NULL REFERENCES users(id),
  
  -- Request context
  requested_by VARCHAR(20) NOT NULL,  -- 'system', 'poster', 'admin'
  request_reason_codes TEXT[] NOT NULL,
  ai_request_proposal_id UUID REFERENCES ai_proposals(id),
  
  -- File info
  storage_key VARCHAR(500) NOT NULL,  -- S3/GCS key
  content_type VARCHAR(100) NOT NULL,
  file_size_bytes BIGINT NOT NULL,
  checksum_sha256 VARCHAR(64) NOT NULL,
  
  -- Capture metadata
  capture_time TIMESTAMPTZ,
  device_metadata JSONB,
  
  -- Access control
  access_scope VARCHAR(20) NOT NULL DEFAULT 'restricted' CHECK (access_scope IN (
    'uploader_only', 'restricted', 'dispute_reviewers', 'admin_only'
  )),
  
  -- Retention
  retention_deadline TIMESTAMPTZ NOT NULL,
  legal_hold BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  
  -- Moderation
  moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN (
    'pending', 'approved', 'flagged', 'quarantined'
  )),
  moderation_flags TEXT[],
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_evidence_task ON evidence(task_id);
CREATE INDEX idx_evidence_dispute ON evidence(dispute_id);
CREATE INDEX idx_evidence_uploader ON evidence(uploader_user_id);
CREATE INDEX idx_evidence_retention ON evidence(retention_deadline) WHERE deleted_at IS NULL;
```

---

## 7. Mandatory Data Contracts

### 7.1 Input Record Schema

All AI jobs must reference a single immutable input record:

```typescript
interface AIInputRecord {
  ai_input_id: string;           // 'ain_...'
  subsystem: string;             // 'onboarding.role_inference'
  schema_version: string;        // 'v1.0.0'
  actor_user_id: string | null;  // Who triggered
  subject_user_id: string | null;// Who is affected
  task_id: string | null;
  dispute_id: string | null;
  created_at: string;            // ISO-8601
  payload: Record<string, unknown>;  // Structured inputs ONLY
}
```

**Rule:** AI sees ONLY what is necessary. No raw DB dumps.

### 7.2 Proposal Record Schemas

#### Role Inference Proposal

```typescript
interface RoleInferenceProposal {
  proposal_type: 'RoleInferenceProposal';
  onboarding_version: string;  // 'v1.1.0'
  role_scores: {
    worker: number;  // 0-1
    poster: number;  // 0-1
  };
  confidence: number;  // 0-1
  certainty_tier: 'STRONG' | 'MODERATE' | 'WEAK';
  signals: {
    risk_tolerance: number;
    urgency_bias: number;
    price_sensitivity: number;
    authority_expectation: number;
  };
  anomalies: string[];  // Inconsistency flags
  explanations: Array<{
    feature: string;
    direction: 'worker' | 'poster';
    weight: number;
  }>;
}
```

#### Evidence Request Proposal

```typescript
interface EvidenceRequestProposal {
  proposal_type: 'EvidenceRequestProposal';
  task_id: string;
  reason_codes: string[];  // ['CATEGORY_REQUIRES_PROOF', 'FRAUD_RISK_HIGH']
  requested_artifacts: Array<{
    type: 'photo' | 'video';
    instructions: string;  // Specific, not vague
    count: number;
  }>;
  privacy_minimization: string[];  // ['Avoid faces', 'No documents']
  deadline_minutes: number;
  confidence: number;
}
```

#### Evidence Verification Proposal

```typescript
interface EvidenceVerificationProposal {
  proposal_type: 'EvidenceVerificationProposal';
  evidence_id: string;
  result: 'PASS' | 'FAIL' | 'NEEDS_MORE' | 'ESCALATE';
  confidence: number;
  reasons: string[];
  followup_request?: {
    type: 'photo' | 'video';
    instructions: string;
    count: number;
  };
}
```

**Prohibited in proposals:**

* Freeform "do this" instructions
* Hidden tool calls
* Multi-step plans that imply authority
* Personally invasive inferences (health, politics, etc.)

### 7.3 Decision Record Schema

```typescript
interface AIDecisionRecord {
  decision_id: string;      // 'aid_...'
  proposal_id: string;      // 'aip_...'
  accepted: boolean;
  reason_codes: string[];   // ['SCHEMA_OK', 'CONFIDENCE_OK']
  writes: Record<string, unknown> | null;  // What was written
  final_author: string;     // 'system' | 'admin:usr_...' | 'user:usr_...'
  decided_at: string;       // ISO-8601
}
```

---

## 8. Confidence Thresholds and Ambiguity Handling

### 8.1 Certainty Tiers (Mandatory)

| Tier | Confidence | Behavior |
|------|------------|----------|
| **STRONG** | ≥ 0.75 | System sets default, offers adjustment |
| **MODERATE** | 0.60–0.74 | System sets default, copy softens, logs 'ambiguous' |
| **WEAK** | < 0.60 | Force explicit choice, log 'uncertain', reduce trust acceleration |

### 8.2 Trust Building Rate by Certainty

| Tier | Trust Building Rate | Dispute Review Priority |
|------|---------------------|------------------------|
| STRONG | 1.0 (normal) | normal |
| MODERATE | 0.9 (10% slower) | normal |
| WEAK | 0.75 (25% slower) | high |

### 8.3 Required Logging

Every AI decision MUST log:

* `certainty_tier`
* `confidence` (numeric)
* `anomaly_flags[]`
* `schema_version`
* `model_id`
* `prompt_version`

---

## 9. Evidence and Proof Requests

### 9.1 Purpose

Evidence requests exist to:

* Reduce fraud
* Validate task completion (INV-3 dependency)
* Support disputes with verifiable artifacts

### 9.2 Authority Model

* **AI may request evidence** (A3), but:
  * AI cannot finalize outcomes
  * Deterministic rules decide if proof is required
  * Deterministic rules decide pass/fail based on validated proposals

### 9.3 When Proof Requests Are Allowed

Evidence requests trigger ONLY when deterministic conditions are met:

| Condition | Reason Code |
|-----------|-------------|
| Task category requires proof | `CATEGORY_REQUIRES_PROOF` |
| Poster explicitly requested | `POSTER_REQUESTED_PROOF` |
| Fraud risk > 0.7 | `FRAUD_RISK_HIGH` |
| Dispute initiated | `DISPUTE_INITIATED` |
| Trust tier 1 + task > $100 | `LOW_TRUST_HIGH_VALUE` |

### 9.4 Consent and UX Requirements

User must see:

* What to capture (specific instructions)
* Why it's needed (reason code in plain language)
* How it will be used (verification/dispute)
* Retention window (30/90 days)
* Who can access (uploader, counterparty, admins)

User must be able to:

* Upload now
* Upload later (if deadline allows)
* Request manual review
* Provide alternate evidence (receipt, GPS, chat logs)

### 9.5 "Live" Proof Clarification

v1 does NOT require real-time video streaming.

"Live proof" means:

* Time-bounded capture request (e.g., "upload within 60 minutes")
* Metadata checks (timestamp freshness, GPS if enabled)
* Optional multi-angle sequence (2–3 photos)

Real-time streaming requires separate spec + privacy review.

### 9.6 Retention Policy

| Scenario | Retention |
|----------|-----------|
| Non-disputed task | Delete after **30 days** |
| Disputed task | Delete **90 days after closure** |
| Legal hold | Indefinite until released (admin-only) |

Retention enforced by scheduled deletion jobs. Deleted evidence sets `deleted_at` timestamp; storage blob purged async.

### 9.7 Safety and Content Moderation

All uploads must pass:

1. Malware scanning
2. Content moderation (CSAM/violence detection)
3. PII minimization check

Flagged content:

* Quarantined immediately
* Access restricted to admin
* Escalation path triggered
* User notified of issue (generic message)

---

## 10. Fraud, Abuse, and Gaming Controls

### 10.1 Anti-Spoofing Principles

* Client inputs are untrusted
* Role inference answers can be gamed
* Evidence can be staged

Defenses:

* Confidence thresholds with certainty tiers
* Inconsistency penalties (see ONBOARDING_SPEC §10)
* Cross-signal validation over time
* Rate limits
* Delayed trust acceleration for WEAK certainty

### 10.2 Inconsistency Detection

Deterministic validators reduce confidence if:

| Pattern | Penalty | Flag |
|---------|---------|------|
| Contradictory answers | -0.15 | `CONTRADICTORY_SIGNALS` |
| All-perfect profile | -0.25 | `SUSPICIOUSLY_PERFECT` |
| Behavior mismatch (later) | -0.20 | `BEHAVIOR_DRIFT` |

All penalties logged as reason codes.

---

## 11. Disputes and AI

### 11.1 Allowed AI Use

| Use | Level | Description |
|-----|-------|-------------|
| Summarize chat/evidence | A1 | Read-only extraction |
| Extract timeline | A1/A2 | Structured event list |
| Propose recommendation | A2 | Suggestion with confidence |

### 11.2 Forbidden AI Use

* AI may NOT finalize dispute outcomes
* AI may NOT release/refund escrow (INV-2, INV-4)
* AI may NOT apply penalties directly

### 11.3 Dispute-grade Traceability

Every dispute AI interaction must be replayable:

* Exact input snapshot (ai_events.id)
* Proposal IDs
* Validator outputs
* Final decision IDs

---

## 12. XP and Trust Enforcement

### 12.1 Absolute Rule (INV-1, INV-5)

XP and Trust changes are **deterministic and transactional**.

AI may:

* Propose risk scores influencing manual review
* Propose categorization influencing eligible rules

AI may NOT:

* Directly mutate XP totals
* Directly mutate trust tier

### 12.2 Transactional Integrity

State changes require:

* DB transaction with constraints
* Idempotency key (INV-5: unique escrow_id per XP award)
* Audit log entry

---

## 13. Rate Limits (Specific Values)

### 13.1 Per-User Limits

| Operation | Limit | Window |
|-----------|-------|--------|
| AI job submissions | 60 | per hour |
| Evidence requests received | 10 | per day |
| Evidence uploads | 20 | per day |
| Dispute AI queries | 20 | per dispute |

### 13.2 Per-Task Limits

| Operation | Limit | Window |
|-----------|-------|--------|
| Evidence requests | 5 | per task lifetime |
| AI proof analysis | 10 | per task lifetime |

### 13.3 System-Wide Limits

| Operation | Limit | Window |
|-----------|-------|--------|
| Total AI jobs | 10,000 | per hour |
| Evidence analysis jobs | 1,000 | per hour |

Exceeded limits return `429 Too Many Requests` with `RATE_LIMITED` reason code.

---

## 14. Kill Switches (Mandatory)

### 14.1 Available Switches

| Switch | Scope | Fallback |
|--------|-------|----------|
| `ai.global.enabled` | All AI | Full deterministic fallback |
| `ai.{subsystem}.enabled` | Per subsystem | Subsystem-specific fallback |
| `ai.vision.enabled` | Evidence analysis | Manual review queue |
| `ai.evidence_requests.enabled` | A3 requests | Category-based rules only |
| `ai.provider.{name}.enabled` | Model provider | Failover to next provider |

### 14.2 Fallback Behaviors

| Subsystem | Fallback When Killed |
|-----------|---------------------|
| Role inference | Force explicit user selection |
| Pricing suggestion | Show market baseline or require manual input |
| Matching | Sort by trust tier + availability only |
| Evidence analysis | Route to manual review |
| Evidence requests | Apply category rules only |
| Dispute assistance | Human-only review |

When killed:

* Log `KILL_SWITCH_ACTIVE` reason code
* System continues with deterministic fallback
* Alert ops team

---

## 15. tRPC Endpoint Contracts

### 15.1 Onboarding Endpoints

```typescript
// Submit calibration responses
ai.onboarding.submitCalibration.mutate({
  context: ContextCapture,
  responses: Record<string, string>,
}) => {
  job_id: string;
  status: 'processing';
}

// Get inference result
ai.onboarding.getInferenceResult.query({
  job_id: string,
}) => {
  status: 'completed' | 'processing' | 'failed';
  proposal?: RoleInferenceProposal;
  decision?: AIDecisionRecord;
}

// Confirm role selection
ai.onboarding.confirmRole.mutate({
  proposal_id: string,
  final_role: 'worker' | 'poster',
  was_overridden: boolean,
}) => {
  decision_id: string;
  success: boolean;
}

// Lock preferences
ai.onboarding.lockPreferences.mutate({
  decision_id: string,
  preferences: WorkerPreferences | PosterPreferences,
}) => {
  user_id: string;
  onboarding_complete: boolean;
}
```

### 15.2 Evidence Endpoints

```typescript
// Request evidence upload URL
ai.evidence.requestUploadUrl.mutate({
  task_id: string,
  content_type: string,
  file_size_bytes: number,
}) => {
  upload_url: string;  // Presigned URL
  evidence_id: string;
  expires_at: string;
}

// Confirm upload complete
ai.evidence.confirmUpload.mutate({
  evidence_id: string,
  checksum_sha256: string,
}) => {
  status: 'pending_moderation';
}

// Get evidence analysis
ai.evidence.getAnalysis.query({
  evidence_id: string,
}) => {
  status: 'analyzing' | 'completed' | 'failed';
  proposal?: EvidenceVerificationProposal;
  decision?: AIDecisionRecord;
}
```

---

## 16. Observability and Evaluation

### 16.1 Required Metrics (Per Subsystem)

* Proposal acceptance rate
* Confidence distribution (histogram)
* Latency (p50, p95, p99)
* Fallback rate
* Manual review rate
* User override rate
* Dispute rate by certainty tier
* Fraud incidents by certainty tier

### 16.2 Offline Evals (Before Enabling)

* Curated test set (min 100 cases)
* Adversarial test cases (min 20)
* Schema robustness tests
* Policy violation tests (hallucinated actions)

### 16.3 Drift Detection Triggers

| Metric | Threshold | Action |
|--------|-----------|--------|
| Acceptance rate drop | > 10% week-over-week | Alert |
| Override rate spike | > 2x baseline | Alert |
| Dispute rate spike | > 1.5x baseline | Auto-disable subsystem |
| Latency p99 | > 5s | Alert + consider disable |

---

## 17. Security and Privacy

### 17.1 Data Minimization

AI inputs must include:

* Only minimum required fields
* Redacted PII where possible
* No sensitive personal attributes inference

### 17.2 Access Control

* Evidence access requires explicit authorization
* Signed URLs time-limited (max 15 minutes)
* Audit logs append-only

### 17.3 User Transparency

Where AI influences outcomes:

* "Why am I seeing this?" available for rankings/pricing
* Evidence request shows reason codes in plain language
* No exposure of model internals or confidence scores to users

### 17.4 Prohibited Inferences

AI must NOT infer or store:

* Medical conditions
* Political affiliations
* Sexual orientation
* Religious beliefs
* Other sensitive traits

---

## 18. Compliance Checklist (Ship Gate)

A subsystem CANNOT ship unless:

- [ ] Authority level assigned (A0–A3) and documented
- [ ] Inputs are structured and minimal
- [ ] Output schema exists and validates server-side
- [ ] Deterministic validator exists with reason codes
- [ ] Decision writes are transactional and audited
- [ ] Fallback path exists and is deterministic
- [ ] Rate limits configured
- [ ] Kill switch exists and tested
- [ ] Metrics and logs implemented
- [ ] Evidence handling meets retention + access rules (if applicable)
- [ ] Offline eval passed
- [ ] Security review completed

---

## 19. Reason Codes (Standardized)

### 19.1 Schema & Validation

* `SCHEMA_OK` — Proposal matches expected schema
* `SCHEMA_FAIL` — Schema validation failed
* `SCHEMA_VERSION_MISMATCH` — Version incompatible

### 19.2 Confidence

* `CONFIDENCE_OK` — Above acceptance threshold
* `CONFIDENCE_LOW` — Below threshold, requires escalation
* `CONFIDENCE_WEAK` — Below 0.60, forces explicit choice

### 19.3 Anomalies

* `ANOMALY_DETECTED` — Generic anomaly flag
* `CONTRADICTORY_SIGNALS` — Response inconsistencies
* `SUSPICIOUSLY_PERFECT` — Gaming attempt suspected
* `BEHAVIOR_DRIFT` — Post-onboarding behavior mismatch

### 19.4 Evidence

* `EVIDENCE_REQUIRED_BY_CATEGORY` — Task type requires proof
* `EVIDENCE_REQUEST_APPROVED` — AI request validated
* `EVIDENCE_VERIFICATION_PASS` — Analysis confirms validity
* `EVIDENCE_VERIFICATION_NEEDS_MORE` — Insufficient evidence
* `EVIDENCE_VERIFICATION_ESCALATE` — Requires human review
* `EVIDENCE_MODERATION_FLAGGED` — Content policy violation

### 19.5 System

* `RATE_LIMITED` — Rate limit exceeded
* `KILL_SWITCH_ACTIVE` — Subsystem disabled
* `FALLBACK_EXPLICIT_SELECTION` — Deterministic fallback used
* `TIMEOUT_EXCEEDED` — AI job timed out
* `PROVIDER_UNAVAILABLE` — Model provider down

---

## 20. Cross-Reference Index

| Invariant | Relevant Sections |
|-----------|-------------------|
| INV-1 (XP requires RELEASED escrow) | §3.2, §12 |
| INV-2 (RELEASED requires COMPLETED) | §3.2, §11 |
| INV-3 (COMPLETED requires ACCEPTED proof) | §3.2, §9 |
| INV-4 (Escrow amount immutable) | §3.2, §11 |
| INV-5 (XP idempotent per escrow) | §3.2, §12 |

| Spec Document | Integration Points |
|---------------|-------------------|
| PRODUCT_SPEC.md | Invariants, state machines |
| BUILD_GUIDE.md | Authority hierarchy, DB schemas |
| ONBOARDING_SPEC.md | Role inference (§3.2, A2) |
| UI_SPEC.md | Transparency requirements (§17.3) |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0 | Jan 2025 | Initial draft |
| 1.1 | Jan 2025 | Added: DB schemas (§6), tRPC contracts (§15), specific rate limits (§13), cross-reference index (§20), integration with BUILD_GUIDE authority hierarchy |

---

**END OF AI INFRASTRUCTURE SPECIFICATION v1.1**
