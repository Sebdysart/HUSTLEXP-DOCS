# JUDGE AGENT — Proactive Verification System

**STATUS: LOCKED — Institutional-Grade Specification**
**Version:** v1.0
**Authority:** AI_INFRASTRUCTURE.md §9, PRODUCT_SPEC.md INV-3
**Applies To:** Task completion proof, escrow release, dispute prevention
**Last Updated:** February 2026

---

## 0. Prime Directive

```
The Judge Agent does NOT trust photos.
The Judge Agent verifies CONTEXT.

Photos can be faked. Metadata cannot.
Static images can deceive. Video semantics cannot.
Single-party claims can lie. Multi-sig verification cannot.
```

**Governing Law (from AI_INFRASTRUCTURE.md §0):**
```
AI proposes.
Deterministic systems decide.
Databases enforce.
UI reveals.
```

The Judge Agent operates at **Layer 4 (AI Proposal)**. It NEVER releases escrow directly. It produces a `VerificationVerdict` that deterministic systems consume.

---

## 1. Architecture Overview

### 1.1 Position in Authority Stack

```
Layer 0: PostgreSQL constraints (INV-3: task_completed_requires_accepted_proof)
Layer 1: Backend state machines (proof state: PENDING → ACCEPTED/REJECTED)
Layer 2: Temporal enforcement (time windows, expiry)
Layer 3: Stripe escrow (funds held until Layer 1 transitions)
Layer 4: ★ JUDGE AGENT ★ (proposes verdict, NEVER decides)
Layer 5: UI state machines (screen transitions)
Layer 6: Client rendering (camera, LiDAR, video capture)
```

### 1.2 End-to-End Flow

```
Worker completes task
→ App triggers Proof Capture (Layer 6)
→ Client collects: photo/video + metadata envelope
→ Metadata envelope uploaded with media (Layer 4 input)
→ Judge Agent runs verification pipeline
→ Judge produces VerificationVerdict
→ Deterministic rules evaluate verdict
→ If PASS: proof.state → ACCEPTED, poster notified
→ If FAIL: proof.state → REJECTED, worker notified
→ If UNCERTAIN: proof.state → MANUAL_REVIEW, escalated
→ Poster multi-sig window opens (15 min default)
→ If no dispute: escrow.state → RELEASED
→ INV-1 chain completes: escrow → XP → trust
```

### 1.3 Judge Agent Boundary

```
JUDGE AGENT MAY:
- Analyze media (photos, video, 3D scans)
- Read metadata envelopes (GPS, timestamps, device info)
- Cross-reference task location with proof location
- Compute confidence scores
- Propose PASS / FAIL / UNCERTAIN verdict
- Request additional evidence from worker

JUDGE AGENT MAY NOT:
- Release escrow directly
- Modify proof state directly (only propose)
- Access payment systems
- Override poster disputes
- Skip metadata verification
- Accept gallery uploads as live proof
```

---

## 2. Verification Layers (Defense in Depth)

The Judge Agent runs **four verification layers** in sequence. Each layer produces a sub-verdict. All sub-verdicts feed the final `VerificationVerdict`.

```
┌─────────────────────────────────────────────┐
│ LAYER 1: Metadata & Spatial Verification    │
│ (Anti-Fraud — runs on ALL submissions)      │
├─────────────────────────────────────────────┤
│ LAYER 2: Visual/Video Semantic Analysis     │
│ (Content — runs on ALL submissions)         │
├─────────────────────────────────────────────┤
│ LAYER 3: Poster Multi-Sig                   │
│ (Human Loop — runs after AI layers pass)    │
├─────────────────────────────────────────────┤
│ LAYER 4: Behavioral Integrity Score         │
│ (Trust Modifier — adjusts rigor per worker) │
└─────────────────────────────────────────────┘
```

**Rule: Layers are sequential. If Layer 1 FAILS, Layers 2-4 do NOT run.**

---

## 3. Layer 1: Metadata & Spatial Verification (Anti-Fraud)

### 3.1 Time-Locked Live Capture

**Requirement:** Every proof photo/video MUST be captured live within the HustleXP app. Gallery uploads are BLOCKED at the client level.

**Client Enforcement (Layer 6):**
```typescript
interface CaptureConstraints {
  // Gallery access is DISABLED during proof capture
  allowGalleryUpload: false;          // HARD BLOCK — never true
  requireLiveCapture: true;           // Camera must be invoked in-app
  maxCaptureAge: 300;                 // Seconds — photo must be < 5 min old
  requireDeviceTimestamp: true;       // Device clock at capture
  requireServerTimestamp: true;       // Server receipt time
}
```

**Server Validation:**
```typescript
interface TimestampValidation {
  deviceTimestamp: string;            // ISO 8601 from device
  serverReceiptTimestamp: string;     // ISO 8601 from server
  maxClockDrift: 600;                 // 10 min tolerance for clock skew
  
  // FAIL conditions:
  // deviceTimestamp > serverReceiptTimestamp + maxClockDrift → FAIL
  // deviceTimestamp < task.started_at → FAIL (photo predates task)
  // deviceTimestamp > task.deadline + 3600 → FAIL (photo too late)
}
```

**Anti-Tamper:**
```
- Client signs capture with device attestation (iOS: DeviceCheck, Android: SafetyNet)
- EXIF data must be present and unstripped
- EXIF timestamp must match device timestamp (±30 seconds)
- If EXIF is stripped or missing → SUSPICIOUS flag (+0.3 fraud score)
```

### 3.2 GPS/EXIF Cross-Referencing

**Requirement:** The proof location must match the task location within an acceptable radius.

```typescript
interface LocationValidation {
  taskLocation: {
    lat: number;
    lng: number;
    radius: number;            // Meters — task-defined geofence
  };
  proofLocation: {
    lat: number;
    lng: number;
    accuracy: number;          // GPS accuracy in meters
    source: 'gps' | 'wifi' | 'cell';
  };
  
  // Thresholds
  defaultRadius: 200;          // 200m for standard tasks
  tightRadius: 50;             // 50m for location-critical tasks
  maxAcceptableAccuracy: 100;  // Reject if GPS accuracy > 100m
}
```

**Verdict Logic:**
```
distance = haversine(taskLocation, proofLocation)

IF proofLocation.accuracy > maxAcceptableAccuracy:
  → SUB_VERDICT: UNCERTAIN (GPS too imprecise)
  → Request: "Move to an area with better signal and retake"

IF distance <= task.radius:
  → SUB_VERDICT: PASS

IF distance > task.radius AND distance <= task.radius * 2:
  → SUB_VERDICT: UNCERTAIN
  → Flag: LOCATION_PROXIMITY_WARNING

IF distance > task.radius * 2:
  → SUB_VERDICT: FAIL
  → Flag: LOCATION_MISMATCH
  → Action: Payment FROZEN, escalate to manual review
```

**Spatial authority:** GPS validation coordinates with `SPATIAL_INTELLIGENCE_LOCKED.md` — task geocoding precision (§6.2), proximity zones (§8), and movement fraud signals (§9) that feed LOCATION_MISMATCH flags into RISK_TRUST_ENGINE.spatial_integrity scoring.

### 3.3 LiDAR Spatial Scanning (Trust-Gated)

**Availability:** Only requested for workers below Trust Tier 3 OR for task categories flagged as `spatial_verification_required`.

**When LiDAR is Requested:**
```typescript
interface LiDARRequirement {
  // Trigger conditions (ANY match = LiDAR requested)
  workerTrustTier: number;       // < 3 triggers LiDAR
  taskCategory: string;          // 'cleaning', 'organization', 'assembly' trigger
  taskValue: number;             // > $200 triggers LiDAR
  posterRequestedScan: boolean;  // Poster opted in during task creation
  
  // LiDAR capture spec
  scanDuration: 5;               // Minimum 5 seconds
  scanType: '3d_mesh';           // Full mesh, not point cloud
  minimumCoverage: 0.6;          // 60% of room must be captured
}
```

**What LiDAR Verifies:**
```
- Surface flatness (shelf leveling, floor cleaning)
- Object presence/absence (debris removed, furniture assembled)
- Spatial consistency (room matches task description)
- Anti-angle-fraud (prevents hiding mess behind camera angle)
```

**Fallback (No LiDAR Hardware):**
```
IF device lacks LiDAR:
  → Require 360-degree video sweep (minimum 8 seconds)
  → AI extracts spatial context from video frames
  → Confidence penalty: -0.1 (video is less precise than LiDAR)
```

### 3.4 Metadata Envelope Schema

Every proof submission includes this envelope alongside the media:

```typescript
interface MetadataEnvelope {
  // Identity
  proof_id: string;              // UUID
  task_id: string;               // Foreign key
  worker_id: string;             // Foreign key
  
  // Capture Context
  capture_type: 'photo' | 'video' | 'lidar_scan';
  device_timestamp: string;      // ISO 8601
  server_receipt_timestamp: string;
  
  // Location
  gps_lat: number;
  gps_lng: number;
  gps_accuracy: number;
  gps_source: 'gps' | 'wifi' | 'cell';
  
  // Device Attestation
  device_attestation_token: string;  // iOS DeviceCheck / Android SafetyNet
  device_model: string;
  os_version: string;
  app_version: string;
  
  // EXIF (extracted server-side, not trusted from client)
  exif_timestamp: string | null;
  exif_gps_lat: number | null;
  exif_gps_lng: number | null;
  exif_camera_make: string | null;
  
  // Integrity
  media_hash: string;            // SHA-256 of media file
  envelope_signature: string;    // HMAC of envelope fields
}
```

---

## 4. Layer 2: Visual & Video Semantic Analysis

### 4.1 Evidence Types (Escalating Rigor)

```
TIER 1 — Single Photo (Trust Tier 4+ workers, tasks < $50)
  → AI analyzes single "after" photo
  → Metadata verification required
  → Lowest confidence ceiling: 0.85

TIER 2 — Before/After Photos (Default for most tasks)
  → AI compares two photos for change detection
  → Both must pass metadata verification
  → Confidence ceiling: 0.92

TIER 3 — Video Walkthrough (Trust Tier 1-2, tasks > $100, spatial tasks)
  → 5-15 second walkthrough video required
  → Visual SLAM analysis for spatial continuity
  → Success marker detection
  → Confidence ceiling: 0.97

TIER 4 — Video + LiDAR (High-value, low-trust, or poster-requested)
  → Video walkthrough + 3D mesh scan
  → Full spatial verification
  → Confidence ceiling: 0.99
```

**Tier Selection Logic:**
```typescript
function selectEvidenceTier(task: Task, worker: Worker): EvidenceTier {
  // Start at default
  let tier = 2;
  
  // Trust upgrades
  if (worker.trustTier >= 4 && task.value < 50) tier = 1;
  
  // Risk downgrades
  if (worker.trustTier <= 2) tier = Math.max(tier, 3);
  if (task.value > 100) tier = Math.max(tier, 3);
  if (task.category.requiresSpatialVerification) tier = Math.max(tier, 3);
  if (task.value > 200 || task.poster.requestedScan) tier = 4;
  
  return tier;
}
```

### 4.2 Photo Analysis Pipeline

```
Input: Photo + MetadataEnvelope
  │
  ├─ Step 1: Content Moderation (safety scan)
  │   └─ CSAM/violence/PII detection → Block if flagged
  │
  ├─ Step 2: Scene Classification
  │   └─ "Is this a kitchen?" "Is this outdoors?" → Match to task.location_type
  │
  ├─ Step 3: Task-Specific Object Detection
  │   └─ Extract Success Markers from task description
  │   └─ "Debris removed" → Check for absence of debris
  │   └─ "Faucet installed" → Check for faucet presence
  │
  ├─ Step 4: Before/After Comparison (Tier 2+)
  │   └─ Structural similarity check (SSIM)
  │   └─ Change detection in task-relevant regions
  │   └─ Flag if photos are identical or near-identical
  │
  └─ Step 5: Confidence Scoring
      └─ Aggregate sub-scores → Final photo_confidence
```

### 4.3 Video Semantic Analysis Pipeline

```
Input: Video (5-15 sec) + MetadataEnvelope
  │
  ├─ Step 1: Content Moderation (frame sampling)
  │
  ├─ Step 2: Visual SLAM — Spatial Continuity
  │   └─ Verify camera is physically moving through space
  │   └─ Detect teleportation (jump cuts) → FAIL
  │   └─ Detect looping (same frames repeated) → FAIL
  │   └─ Extract 3D trajectory map
  │
  ├─ Step 3: Frame-by-Frame Scene Analysis
  │   └─ Extract key frames (1 per second minimum)
  │   └─ Run object detection on each frame
  │   └─ Build spatial inventory of visible objects
  │
  ├─ Step 4: Success Marker Detection
  │   └─ Task description → Expected markers (AI-extracted)
  │   └─ Example: "Clean kitchen" → {no_dishes_in_sink, clear_countertops, floor_clean}
  │   └─ Each marker: DETECTED / NOT_DETECTED / UNCERTAIN
  │
  ├─ Step 5: Temporal Consistency
  │   └─ Objects don't appear/disappear between frames
  │   └─ Lighting is consistent (no spliced clips)
  │   └─ Audio continuity check (if audio present)
  │
  └─ Step 6: Confidence Scoring
      └─ SLAM_score × marker_score × consistency_score → video_confidence
```

### 4.4 Success Marker Extraction

The Judge Agent extracts success markers from the task description at task creation time (not at verification time):

```typescript
interface SuccessMarkers {
  task_id: string;
  markers: Array<{
    id: string;
    description: string;       // "Debris removed from yard"
    detection_type: 'presence' | 'absence' | 'condition';
    object: string;            // "debris"
    expected_state: string;    // "absent"
    weight: number;            // 0-1, importance to overall task
    verifiable: boolean;       // Can AI reasonably detect this?
  }>;
  
  // Generated at task creation by AI_TASK_COMPLETION system
  generated_at: string;
  confidence: number;          // How confident AI is in marker extraction
}
```

**Pre-Extraction Rule:**
```
Markers are generated when task reaches LOCKED state (escrow funded).
Markers are IMMUTABLE after generation.
Worker sees markers BEFORE starting work.
This prevents "I didn't know what was expected" disputes.
```

---

## 5. Layer 3: Poster Multi-Sig Verification Loop

### 5.1 Flow

```
Judge Agent produces VerificationVerdict
  │
  ├─ IF verdict = FAIL:
  │   └─ Worker notified immediately
  │   └─ Worker may resubmit (max 3 attempts)
  │   └─ Poster NOT notified until max attempts exhausted
  │
  ├─ IF verdict = UNCERTAIN:
  │   └─ Escalate to manual review queue
  │   └─ Both parties notified: "Under review"
  │
  └─ IF verdict = PASS:
      └─ Poster notification triggered
      └─ Multi-sig window opens
```

### 5.2 Poster Notification

```
Push notification:
"[Worker Name] has completed [Task Title]. 
The AI has verified the work visually.
You have 15 minutes to review or dispute.
Funds release automatically after the window."
```

### 5.3 Multi-Sig Windows (Trust-Scaled)

```typescript
interface MultiSigWindow {
  // Window duration scales with task value and worker trust
  defaultWindow: 900;           // 15 minutes (standard)
  highValueWindow: 7200;        // 2 hours (tasks > $200)
  lowTrustWindow: 3600;         // 1 hour (worker trust tier 1-2)
  
  // Poster response options
  responses: {
    APPROVE: 'Release funds immediately',
    DISPUTE: 'Open dispute flow (DisputeEntryScreen SH4)',
    SILENT:  'No response → auto-release after window'
  };
}
```

### 5.4 Auto-Release Protocol

```
WHEN multi_sig_window expires AND poster_response = SILENT:
  → proof.state = ACCEPTED (deterministic rule, not AI)
  → Escrow release triggered
  → INV-1 chain: escrow RELEASED → XP awarded
  → Worker notified: "Payment released"
  → Poster notified: "Funds released — no dispute filed"
```

### 5.5 Poster Not Available

```
IF poster is offline (no app activity in 24h):
  → Extend window to 4 hours
  → Send SMS reminder at 50% window
  → Send email reminder at 75% window
  → If still no response → auto-release
  → Poster retains right to dispute within 48h post-release
    (dispute triggers escrow clawback if funds not yet withdrawn)
```

### 5.6 Dispute Escalation

```
IF poster disputes:
  → Task frozen (PRODUCT_SPEC: task freeze during active dispute)
  → Escrow held (no release)
  → DisputeEntryScreen (SH4) opens for poster
  → Judge Agent produces dispute summary (AI_INFRASTRUCTURE §11, A1 level)
  → Human resolution queue (admin)
  → Resolution: APPROVE_WORKER | APPROVE_POSTER | SPLIT
```

---

## 6. Layer 4: Behavioral Integrity Score (Trust-Scaled Rigor)

### 6.1 Trust Tier → Verification Rigor Matrix

```
┌──────────────┬───────────┬────────────┬──────────┬────────────────┐
│ Trust Tier   │ Evidence  │ GPS        │ Multi-Sig│ Confidence     │
│              │ Tier      │ Required   │ Window   │ Threshold      │
├──────────────┼───────────┼────────────┼──────────┼────────────────┤
│ Tier 1 (new) │ 3 or 4   │ MANDATORY  │ 60 min   │ 0.95           │
│ Tier 2       │ 2 or 3   │ MANDATORY  │ 30 min   │ 0.90           │
│ Tier 3       │ 2        │ MANDATORY  │ 15 min   │ 0.85           │
│ Tier 4       │ 1 or 2   │ Recommended│ 15 min   │ 0.80           │
│ Tier 5 (max) │ 1        │ Optional   │ 5 min    │ 0.75           │
└──────────────┴───────────┴────────────┴──────────┴────────────────┘
```

### 6.2 Instant Release (Elite Workers)

```typescript
interface InstantReleaseEligibility {
  // ALL conditions must be true
  workerTrustTier: 5;                    // Maximum tier
  completedTaskCount: '>= 100';         // Proven track record
  disputeRate: '< 0.02';               // Less than 2% dispute rate
  lastDisputeAge: '> 90 days';         // No recent disputes
  taskValue: '< 75';                   // Low-value tasks only
  
  // If ALL conditions met:
  // → Skip multi-sig window
  // → AI verdict = PASS triggers immediate escrow release
  // → Poster still has 48h dispute window (post-release)
}
```

### 6.3 Fraud Score Accumulation

```typescript
interface FraudSignals {
  // Each signal adds to cumulative fraud score
  signals: {
    EXIF_STRIPPED:              0.3,    // Metadata removed
    TIMESTAMP_MISMATCH:        0.4,    // Device vs EXIF mismatch
    LOCATION_PROXIMITY_WARNING: 0.3,   // Near but outside geofence
    LOCATION_MISMATCH:         0.8,    // Clearly wrong location
    IDENTICAL_PHOTOS:          0.9,    // Before/after are same image
    VIDEO_JUMP_CUT:            0.7,    // Spliced video detected
    VIDEO_LOOP:                0.9,    // Repeated frames
    DEVICE_ATTESTATION_FAIL:   0.6,    // Rooted/jailbroken device
    RAPID_SUBMISSION:          0.4,    // Submitted < 5 min after task start
    SCENE_MISMATCH:            0.5,    // Photo doesn't match task type
  };
  
  // Thresholds
  warningThreshold: 0.5;     // Flag for extra scrutiny
  freezeThreshold: 0.8;      // Payment frozen, escalate
  blockThreshold: 1.2;       // Account flagged for review
}
```

### 6.4 Trust Impact of Verification Outcomes

```
PASS (clean):
  → +XP per existing XP system
  → Trust score: +0.01 per clean verification
  → Consecutive clean streak tracked

PASS (with warnings):
  → XP awarded (reduced by 10%)
  → Trust score: no change
  → Warnings logged for pattern detection

FAIL (honest):
  → Resubmission allowed (max 3 attempts)
  → Trust score: -0.02 per fail
  → No XP until accepted

FAIL (fraud detected):
  → Payment frozen
  → Trust score: -0.15 per fraud flag
  → Account review triggered at 3 fraud flags
  → Permanent ban at 5 confirmed fraud incidents
```

---

## 7. Data Model

### 7.1 Proof Record (Enhanced)

```sql
CREATE TABLE proofs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  worker_id UUID NOT NULL REFERENCES users(id),
  
  -- State Machine
  state proof_state NOT NULL DEFAULT 'PENDING',
  -- PENDING → ANALYZING → PASS → ACCEPTED
  -- PENDING → ANALYZING → FAIL → (resubmit or REJECTED)
  -- PENDING → ANALYZING → UNCERTAIN → MANUAL_REVIEW
  
  -- Evidence
  evidence_tier INTEGER NOT NULL CHECK (evidence_tier BETWEEN 1 AND 4),
  media_type TEXT NOT NULL CHECK (media_type IN ('photo', 'video', 'lidar_scan')),
  media_url TEXT NOT NULL,
  media_hash TEXT NOT NULL,
  
  -- Metadata Envelope (JSONB for flexibility)
  metadata_envelope JSONB NOT NULL,
  
  -- Judge Verdict
  verdict_confidence DECIMAL(4,3),
  verdict_flags TEXT[],
  fraud_score DECIMAL(4,3) DEFAULT 0,
  success_markers_result JSONB,
  
  -- Multi-Sig
  poster_response TEXT CHECK (poster_response IN ('APPROVE', 'DISPUTE', 'SILENT')),
  poster_response_at TIMESTAMPTZ,
  multi_sig_window_expires_at TIMESTAMPTZ,
  auto_released BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  analyzed_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  
  -- Audit
  attempt_number INTEGER NOT NULL DEFAULT 1,
  previous_proof_id UUID REFERENCES proofs(id),
  
  CONSTRAINT max_attempts CHECK (attempt_number <= 3)
);

-- Indexes
CREATE INDEX idx_proofs_task ON proofs(task_id);
CREATE INDEX idx_proofs_worker ON proofs(worker_id);
CREATE INDEX idx_proofs_state ON proofs(state);
CREATE INDEX idx_proofs_pending_multisig ON proofs(multi_sig_window_expires_at) 
  WHERE state = 'PASS' AND poster_response IS NULL;
```

### 7.2 Verification Audit Log

```sql
CREATE TABLE verification_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proof_id UUID NOT NULL REFERENCES proofs(id),
  
  -- Layer Results
  layer_1_metadata JSONB,     -- Timestamp, GPS, attestation results
  layer_2_visual JSONB,       -- Photo/video analysis results
  layer_3_multisig JSONB,     -- Poster response details
  layer_4_trust JSONB,        -- Trust modifiers applied
  
  -- Aggregate
  final_verdict TEXT NOT NULL,
  final_confidence DECIMAL(4,3),
  fraud_signals TEXT[],
  processing_time_ms INTEGER,
  
  -- Model Tracking (for AI evaluation)
  model_version TEXT NOT NULL,
  model_provider TEXT NOT NULL,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 8. VerificationVerdict Schema

```typescript
interface VerificationVerdict {
  // Identity
  proof_id: string;
  task_id: string;
  worker_id: string;
  
  // Final Verdict
  verdict: 'PASS' | 'FAIL' | 'UNCERTAIN';
  confidence: number;           // 0-1
  
  // Layer Sub-Verdicts
  layers: {
    metadata: {
      verdict: 'PASS' | 'FAIL' | 'UNCERTAIN';
      timestamp_valid: boolean;
      location_valid: boolean;
      attestation_valid: boolean;
      flags: string[];
    };
    visual: {
      verdict: 'PASS' | 'FAIL' | 'UNCERTAIN';
      scene_match: boolean;
      markers_detected: number;
      markers_total: number;
      slam_valid: boolean | null;   // null if photo-only
      flags: string[];
    };
    trust_modifier: {
      worker_trust_tier: number;
      evidence_tier_required: number;
      confidence_threshold: number;
      instant_release_eligible: boolean;
      fraud_score: number;
    };
  };
  
  // Actions
  recommended_action: 'RELEASE' | 'FREEZE' | 'REVIEW' | 'RESUBMIT';
  resubmit_guidance: string | null;  // "Retake photo closer to task location"
  multi_sig_window_seconds: number;
  
  // Audit
  processing_time_ms: number;
  model_version: string;
  timestamp: string;
}
```

---

## 9. Screen Integration

### 9.1 Affected Screens

| Screen | ID | Role | Judge Integration |
|--------|----|------|-------------------|
| ProofSubmissionScreen | SH3 | Worker submits proof | Camera capture, evidence tier enforcement |
| ProofReviewScreen | P7 | Poster reviews proof | Multi-sig approve/dispute |
| TaskCompletionScreen | P8 | Poster confirms completion | Post-release summary |
| DisputeEntryScreen | SH4 | Either party disputes | Dispute with Judge evidence |

### 9.2 ProofSubmissionScreen (SH3) — Capture Requirements

```
Archetype: C (Task Lifecycle)
Allowed Molecules: TaskCard, StatusBadge, ProgressBar, ActionBar, LoadingState, ErrorState

CAPTURE FLOW:
1. Screen shows required evidence tier
2. "Gallery" button is HIDDEN (live capture only)
3. Camera opens in-app with metadata collection
4. GPS lock required before capture enabled
5. Worker captures media → metadata envelope auto-generated
6. Upload begins → LoadingState with progress
7. Judge Agent analyzes → StatusBadge shows result
8. If PASS → "Submitted for poster review"
9. If FAIL → ErrorState with resubmit_guidance
10. If resubmit → attempt_number incremented (max 3)
```

### 9.3 ProofReviewScreen (P7) — Multi-Sig

```
Archetype: C (Task Lifecycle)

REVIEW FLOW:
1. Push notification brings poster to P7
2. Screen shows: media, verdict summary, success markers
3. Timer showing remaining multi-sig window
4. Two buttons: "Approve" (release) / "Dispute" (SH4)
5. If timer expires → auto-release triggered
6. Poster CANNOT see raw confidence scores or fraud signals
```

---

## 10. Invariant Compliance

### 10.1 Alignment with Existing Invariants

| Invariant | How Judge Agent Complies |
|-----------|--------------------------|
| INV-1: XP requires RELEASED escrow | Judge verdict → proof ACCEPTED → task COMPLETED → escrow RELEASED → XP |
| INV-2: Escrow release requires COMPLETED task | Judge never releases escrow directly |
| INV-3: COMPLETED requires ACCEPTED proof | Judge produces verdict; deterministic rule transitions proof state |
| INV-4: Escrow amount immutable | Judge has zero access to escrow amounts |
| INV-5: One XP entry per escrow | Unaffected — Judge operates before XP layer |

### 10.2 New Invariants

```
INV-JUDGE-1: Gallery uploads are NEVER accepted as proof
Enforcement: Client-side camera-only + server rejects media without device attestation

INV-JUDGE-2: Proof metadata envelope is IMMUTABLE after submission
Enforcement: Envelope signed with HMAC at upload; any modification invalidates

INV-JUDGE-3: Judge Agent NEVER modifies proof.state directly
Enforcement: Judge writes to verification_audit; deterministic function reads verdict → updates state

INV-JUDGE-4: Multi-sig window CANNOT be shortened by AI
Enforcement: Window duration set by deterministic rules based on trust tier; AI has no input

INV-JUDGE-5: Maximum 3 proof submission attempts per task
Enforcement: Database constraint on proofs.attempt_number
```

---

## 11. Rate Limits & Cost Controls

```
| Operation                    | Limit              | Scope          |
|------------------------------|--------------------|----------------|
| Photo analysis               | 10 per task        | Task lifetime   |
| Video analysis               | 5 per task         | Task lifetime   |
| LiDAR scan analysis          | 3 per task         | Task lifetime   |
| Total AI calls per proof     | 5                  | Per submission  |
| Proof submissions per task   | 3                  | Per worker      |
| Multi-sig extension requests | 1                  | Per task        |
```

---

## 12. Phased Implementation

### Phase 1 — Bootstrap (v1.0)
```
✅ Live capture enforcement (no gallery)
✅ Timestamp validation
✅ GPS cross-referencing (200m radius)
✅ Single photo analysis (scene match + basic object detection)
✅ Poster multi-sig (15 min fixed window)
✅ Metadata envelope
✅ 3 attempt limit
```

### Phase 2 — Enhanced (v1.5)
```
◻ Before/after comparison
◻ Success marker extraction and detection
◻ Trust-scaled evidence tiers
◻ Trust-scaled multi-sig windows
◻ Fraud score accumulation
◻ Instant release for elite workers
```

### Phase 3 — Advanced (v2.0)
```
◻ Video walkthrough with Visual SLAM
◻ LiDAR spatial scanning
◻ 360-degree fallback for non-LiDAR devices
◻ Cross-signal pattern detection
◻ Behavioral anomaly detection
```

---

## 13. Kill Switches (from AI_INFRASTRUCTURE §12)

```
| Switch                  | Effect                                    |
|-------------------------|-------------------------------------------|
| JUDGE_DISABLED          | All proofs → MANUAL_REVIEW queue          |
| PHOTO_ANALYSIS_DISABLED | Skip visual analysis, metadata only       |
| VIDEO_ANALYSIS_DISABLED | Downgrade all video requirements to photo  |
| LIDAR_DISABLED          | Downgrade to video/photo fallback         |
| AUTO_RELEASE_DISABLED   | All multi-sig windows require poster input |
| INSTANT_RELEASE_DISABLED| All workers go through multi-sig           |
| GPS_DISABLED            | Skip location verification (emergency)    |
```

---

## 14. Chosen-State Integration

**The Judge Agent enforces the Chosen-State requirement:**

```
Worker submitting proof:
  ✅ "Your work is being verified" (feels like progress)
  ✅ Clear evidence tier shown upfront (no surprises)
  ✅ Guidance if resubmission needed (not punishment)
  ❌ "Your proof was rejected" (feels like rejection)
  ❌ Raw confidence scores visible (feels like a test)
  ❌ Fraud score visible to worker (feels accusatory)

Poster reviewing proof:
  ✅ "AI has verified — review or auto-approve" (feels easy)
  ✅ Clear timer showing window (feels controlled)
  ❌ "Verify the worker's proof" (feels like work)
  ❌ "Judge the quality" (feels like responsibility)
```

---

## 15. Integration Points

| System | Integration |
|--------|-------------|
| AI_INFRASTRUCTURE.md §9 | Extends proof verification with proactive layers |
| AI_TASK_COMPLETION_SPEC.md | Success markers generated at task LOCKED state |
| VERIFICATION_PIPELINE_LOCKED.md | Separate system — license/insurance, NOT task proof |
| PRODUCT_SPEC.md INV-3 | Judge verdict feeds into proof.state → task.state chain |
| TRIGGERS_AND_CONSTRAINTS.sql | Existing triggers enforce state transitions |
| SCREEN_ARCHETYPES.md | SH3, P7, P8, SH4 are Archetype C (Task Lifecycle) |
| ARCHETYPE_MOLECULE_MATRIX.md | Screens use only Archetype C allowed molecules |
| Stripe Escrow | Judge has ZERO access — deterministic rules handle release |

---

**This specification is LOCKED.**
**AI proposes. Deterministic systems decide. Databases enforce.**
**The Judge Agent sees everything but controls nothing.**
