# Logistics AI Agent Specification

**Status:** 🔒 LOCKED
**Version:** 1.0
**Authority Level:** A2 (Proposal-Only)
**Layer:** 3 (AI Decision Layer)

---

## 1. Purpose & Scope

The **Logistics AI Agent** validates proof submissions for spatial consistency, temporal integrity, and physical feasibility. It operates at **Authority Level A2**, meaning it can flag suspicious patterns and recommend actions, but cannot directly approve/reject proofs.

### Core Responsibilities

1. **GPS Validation**: Verify proof photo location matches task location
2. **Impossible Travel Detection**: Flag physically impossible movement patterns
3. **Time-Lock Verification**: Ensure photos are live-captured, not pre-uploaded
4. **Spatial Consistency**: Validate LiDAR depth maps match visual photos
5. **Risk Scoring**: Generate 0-1 risk scores for fraud likelihood

### Authority Constraints

- **CANNOT** directly set `proof.status = 'ACCEPTED' | 'REJECTED'`
- **MUST** log all validations to `ai_agent_decisions` table
- **MUST** provide reasoning for risk flags
- **MUST** defer to Judge AI Agent or deterministic validators for final decisions
- All proposals reviewed before action taken

---

## 2. Input Schema

```typescript
interface LogisticsInput {
  proof_id: string;
  task_id: string;
  user_id: string;

  // GPS data from proof submission
  gps_coordinates: {
    latitude: number;   // Decimal degrees
    longitude: number;
  };
  gps_accuracy_meters: number;
  gps_timestamp: string; // ISO 8601

  // Task location (expected location)
  task_location: {
    latitude: number;
    longitude: number;
  };

  // User's last known location (fraud detection)
  last_known_location?: {
    latitude: number;
    longitude: number;
    timestamp: string;
  };

  // Time-lock hash (proof of live capture)
  time_lock_hash: string;
  submission_timestamp: string;

  // Optional LiDAR data
  lidar_depth_map_url?: string;
  photo_url: string;
}
```

### Example Input

```json
{
  "proof_id": "550e8400-e29b-41d4-a716-446655440000",
  "task_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "gps_coordinates": {
    "latitude": 30.2672,
    "longitude": -97.7431
  },
  "gps_accuracy_meters": 12,
  "gps_timestamp": "2026-02-06T14:30:00Z",
  "task_location": {
    "latitude": 30.2650,
    "longitude": -97.7410
  },
  "last_known_location": {
    "latitude": 30.1500,
    "longitude": -97.8000,
    "timestamp": "2026-02-06T14:15:00Z"
  },
  "time_lock_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "submission_timestamp": "2026-02-06T14:30:05Z"
}
```

---

## 3. Output Schema (Proposal)

```typescript
interface LogisticsProposal {
  risk_score: number;            // 0.0-1.0 (0=safe, 1=fraud)
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  recommendation: 'approve' | 'manual_review' | 'reject';

  fraud_flags: string[];         // ['impossible_travel', 'gps_spoofing', etc.]
  reasoning: string;             // Human-readable explanation

  validation_checks: {
    gps_proximity: {
      passed: boolean;
      distance_meters: number;
      threshold_meters: number;
    };
    impossible_travel: {
      passed: boolean;
      speed_kmh?: number;
      max_allowed_kmh: number;
    };
    time_lock: {
      passed: boolean;
      time_delta_seconds?: number;
    };
    gps_accuracy: {
      passed: boolean;
      accuracy_meters: number;
      threshold_meters: number;
    };
  };

  confidence_score: number;      // 0.0-1.0
}
```

### Example Output

```json
{
  "risk_score": 0.15,
  "risk_level": "LOW",
  "recommendation": "approve",
  "fraud_flags": [],
  "reasoning": "Proof location within 250 meters of task. GPS accuracy: 12m (excellent). No impossible travel detected. Time-lock valid. All checks passed.",

  "validation_checks": {
    "gps_proximity": {
      "passed": true,
      "distance_meters": 248,
      "threshold_meters": 500
    },
    "impossible_travel": {
      "passed": true,
      "speed_kmh": 45,
      "max_allowed_kmh": 100
    },
    "time_lock": {
      "passed": true,
      "time_delta_seconds": 5
    },
    "gps_accuracy": {
      "passed": true,
      "accuracy_meters": 12,
      "threshold_meters": 50
    }
  },

  "confidence_score": 0.92
}
```

---

## 4. Validation Rules (Deterministic)

### Rule 1: GPS Proximity Check

```typescript
function validateGPSProximity(
  proof_coords: { lat: number, lon: number },
  task_coords: { lat: number, lon: number },
  accuracy_meters: number
): { passed: boolean, distance_meters: number } {
  const distance_meters = haversineDistance(proof_coords, task_coords);

  // Risk tiers
  if (distance_meters <= 100) {
    return { passed: true, distance_meters, risk_level: 'LOW' };
  } else if (distance_meters <= 500) {
    return { passed: true, distance_meters, risk_level: 'MEDIUM' };
  } else {
    return { passed: false, distance_meters, risk_level: 'HIGH' };
  }
}

// Haversine distance formula
function haversineDistance(
  coord1: { lat: number, lon: number },
  coord2: { lat: number, lon: number }
): number {
  const R = 6371e3; // Earth radius in meters
  const φ1 = coord1.lat * Math.PI / 180;
  const φ2 = coord2.lat * Math.PI / 180;
  const Δφ = (coord2.lat - coord1.lat) * Math.PI / 180;
  const Δλ = (coord2.lon - coord1.lon) * Math.PI / 180;

  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  return R * c; // Distance in meters
}
```

### Rule 2: Impossible Travel Detection

```typescript
function detectImpossibleTravel(
  last_location: { lat: number, lon: number, timestamp: string },
  current_location: { lat: number, lon: number, timestamp: string }
): { passed: boolean, speed_kmh: number } {
  const distance_meters = haversineDistance(last_location, current_location);
  const time_delta_seconds =
    (new Date(current_location.timestamp).getTime() -
     new Date(last_location.timestamp).getTime()) / 1000;

  const speed_mps = distance_meters / time_delta_seconds;
  const speed_kmh = speed_mps * 3.6;

  // Max ground speed: 100 km/h (realistic for car/bus, not plane)
  const MAX_SPEED_KMH = 100;

  return {
    passed: speed_kmh <= MAX_SPEED_KMH,
    speed_kmh,
    flagged: speed_kmh > MAX_SPEED_KMH
  };
}
```

### Rule 3: Time-Lock Validation

```typescript
function validateTimeLock(
  time_lock_hash: string,
  submission_timestamp: string,
  gps_timestamp: string
): { passed: boolean, time_delta_seconds: number } {
  // Time-lock hash format: SHA-256(photo_bytes + gps_timestamp)
  // Validates photo was taken at claimed time, not pre-uploaded

  const time_delta = Math.abs(
    (new Date(submission_timestamp).getTime() -
     new Date(gps_timestamp).getTime()) / 1000
  );

  // Photos must be submitted within 5 minutes of capture
  const MAX_TIME_DELTA_SECONDS = 300;

  return {
    passed: time_delta <= MAX_TIME_DELTA_SECONDS,
    time_delta_seconds: time_delta
  };
}
```

### Rule 4: GPS Accuracy Check

```typescript
function validateGPSAccuracy(accuracy_meters: number): boolean {
  // Excellent: <20m
  // Good: 20-50m
  // Fair: 50-100m
  // Poor: >100m (flag for manual review)

  const ACCURACY_THRESHOLD_METERS = 50;
  return accuracy_meters <= ACCURACY_THRESHOLD_METERS;
}
```

### Rule 5: Risk Scoring Algorithm

```typescript
function calculateRiskScore(validation_checks: ValidationChecks): number {
  let risk_score = 0.0;

  // GPS proximity (40% weight)
  if (validation_checks.gps_proximity.distance_meters > 500) {
    risk_score += 0.40;
  } else if (validation_checks.gps_proximity.distance_meters > 100) {
    risk_score += 0.15;
  }

  // Impossible travel (30% weight)
  if (!validation_checks.impossible_travel.passed) {
    risk_score += 0.30;
  }

  // Time-lock (20% weight)
  if (!validation_checks.time_lock.passed) {
    risk_score += 0.20;
  }

  // GPS accuracy (10% weight)
  if (!validation_checks.gps_accuracy.passed) {
    risk_score += 0.10;
  }

  return Math.min(risk_score, 1.0);
}
```

---

## 5. Implementation Flow

```
┌─────────────────────┐
│ Hustler submits     │
│ proof with GPS      │
└──────────┬──────────┘
           │
           v
┌────────────────────────┐
│ ProofService.submit()  │
└──────────┬─────────────┘
           │
           v
┌──────────────────────────────┐
│ LogisticsAIService.          │
│ validateGPSProof(input)      │
└──────────┬───────────────────┘
           │
           v
┌──────────────────────────────┐
│ Run deterministic checks:    │
│ 1. GPS proximity             │
│ 2. Impossible travel         │
│ 3. Time-lock                 │
│ 4. GPS accuracy              │
└──────────┬───────────────────┘
           │
           v
┌──────────────────────────────┐
│ Calculate risk score         │
│ Generate recommendation      │
└──────────┬───────────────────┘
           │
           v
┌──────────────────────────────┐
│ Log to ai_agent_decisions    │
│ (authority_level='A2')       │
└──────────┬───────────────────┘
           │
     ┌─────┴─────┐
     │           │
  LOW/MED     HIGH/CRITICAL
     │           │
     v           v
┌──────────┐  ┌─────────────────┐
│ Pass to  │  │ Flag for manual │
│ Judge AI │  │ review + notify │
└──────────┘  └─────────────────┘
```

---

## 6. Fraud Detection Patterns

### Pattern 1: GPS Spoofing
**Indicators:**
- GPS accuracy suddenly perfect (<5m) when user history shows poor accuracy
- Location jumps between submissions with no travel time
- GPS coordinates at exact task location (suspiciously precise)

**Response:**
```json
{
  "fraud_flags": ["gps_spoofing_suspected"],
  "risk_score": 0.85,
  "recommendation": "manual_review",
  "reasoning": "GPS accuracy suspiciously perfect. User typically has 30-50m accuracy; this submission shows 3m. Possible location spoofing app."
}
```

### Pattern 2: Impossible Travel
**Indicators:**
- User submitted proof 50km away 10 minutes ago
- Required travel speed exceeds 100 km/h ground speed

**Response:**
```json
{
  "fraud_flags": ["impossible_travel"],
  "risk_score": 0.95,
  "recommendation": "reject",
  "reasoning": "User traveled 50km in 10 minutes (300 km/h). Physically impossible via ground transport. Likely multiple devices or location spoofing."
}
```

### Pattern 3: Time Manipulation
**Indicators:**
- Time-lock hash doesn't match claimed timestamp
- Photo EXIF data shows creation time 2 days ago

**Response:**
```json
{
  "fraud_flags": ["time_manipulation", "pre_uploaded_photo"],
  "risk_score": 0.90,
  "recommendation": "reject",
  "reasoning": "Time-lock validation failed. Photo appears to be pre-uploaded, not live-captured. EXIF timestamp: 2 days ago."
}
```

### Pattern 4: Systematic Fraud
**Indicators:**
- User has 3+ fraud flags in last 7 days
- Multiple proofs submitted from same GPS coordinate (office-based fraud)

**Response:**
```json
{
  "fraud_flags": ["systematic_fraud_pattern"],
  "risk_score": 1.0,
  "recommendation": "reject",
  "reasoning": "User flagged for systematic fraud. 5 proofs in last 7 days all from same office location (30.2672, -97.7431) for tasks across city. Account suspension recommended."
}
```

---

## 7. Database Schema Integration

### fraud_detection_events Table

```sql
CREATE TABLE fraud_detection_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),

  event_type TEXT NOT NULL CHECK (event_type IN (
    'impossible_travel',
    'gps_spoofing',
    'time_manipulation',
    'systematic_fraud'
  )),

  severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),

  task_id UUID REFERENCES tasks(id),
  proof_id UUID REFERENCES proof_submissions(id),

  evidence JSONB NOT NULL,

  -- Location data
  location_a POINT,
  location_b POINT,
  time_a TIMESTAMPTZ,
  time_b TIMESTAMPTZ,
  distance_km DECIMAL(10,2),
  time_delta_seconds INTEGER,

  action_taken TEXT, -- 'flagged', 'suspended', 'banned', 'cleared'
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Logged Event Example

```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "event_type": "impossible_travel",
  "severity": "high",
  "task_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "proof_id": "550e8400-e29b-41d4-a716-446655440000",
  "evidence": {
    "speed_kmh": 320,
    "distance_meters": 53000,
    "time_delta_seconds": 600,
    "explanation": "User traveled 53km in 10 minutes"
  },
  "location_a": "(30.1500, -97.8000)",
  "location_b": "(30.2672, -97.7431)",
  "time_a": "2026-02-06T14:15:00Z",
  "time_b": "2026-02-06T14:25:00Z",
  "distance_km": 53.0,
  "time_delta_seconds": 600,
  "action_taken": "flagged",
  "created_at": "2026-02-06T14:25:10Z"
}
```

---

## 8. Integration with Judge AI Agent

The Logistics Agent passes its proposal to the Judge AI Agent for final synthesis:

```typescript
// In JudgeAIService.evaluateProofSubmission()
async evaluateProofSubmission(proof_id: string) {
  // Get Logistics proposal
  const logistics_proposal = await LogisticsAIService.validateGPSProof(proof_id);

  // Get visual analysis (from Judge's own checks)
  const visual_analysis = await this.analyzeProofPhoto(proof_id);

  // Synthesize
  if (logistics_proposal.risk_level === 'CRITICAL') {
    return {
      recommendation: 'reject',
      reasoning: `Logistics flagged critical fraud: ${logistics_proposal.reasoning}`
    };
  }

  if (logistics_proposal.risk_level === 'HIGH' && visual_analysis.confidence < 0.70) {
    return {
      recommendation: 'manual_review',
      reasoning: 'Both Logistics (HIGH risk) and visual analysis (low confidence) require human review.'
    };
  }

  // Low/medium risk + good visual → approve
  return {
    recommendation: 'approve',
    reasoning: 'Logistics checks passed, visual analysis confident.'
  };
}
```

---

## 9. Performance Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **False Positive Rate** | <5% | Legitimate proofs flagged as fraud |
| **False Negative Rate** | <2% | Fraudulent proofs not detected |
| **Response Time** | <2 seconds | P95 latency for `validateGPSProof()` |
| **GPS Accuracy** | >90% within 50m | Proof GPS within 50m of task |
| **Impossible Travel Detection** | 100% | All speed >100 km/h flagged |

### Monitoring Query

```sql
-- Logistics AI fraud detection metrics
SELECT
  event_type,
  severity,
  COUNT(*) as event_count,
  AVG(distance_km) as avg_distance_km,
  AVG(time_delta_seconds) as avg_time_delta_seconds
FROM fraud_detection_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY event_type, severity
ORDER BY event_count DESC;
```

---

## 10. Edge Cases & Fallbacks

### Edge Case 1: Poor GPS Accuracy
**Scenario:** User submits proof with 150m GPS accuracy (rural area, weak signal)

**Response:**
```json
{
  "risk_score": 0.30,
  "risk_level": "MEDIUM",
  "recommendation": "manual_review",
  "reasoning": "GPS accuracy poor (150m). Cannot verify exact location. Recommend visual landmark verification by Judge AI.",
  "fraud_flags": ["poor_gps_accuracy"]
}
```

### Edge Case 2: No Last Known Location
**Scenario:** First proof submission from new user (no travel history)

**Response:**
```json
{
  "risk_score": 0.10,
  "risk_level": "LOW",
  "recommendation": "approve",
  "reasoning": "First submission from user. No travel history to validate. GPS proximity check passed (80m from task). Time-lock valid.",
  "validation_checks": {
    "impossible_travel": {
      "passed": true,
      "note": "Skipped (no prior location)"
    }
  }
}
```

### Edge Case 3: GPS Disabled
**Scenario:** User submits proof without GPS coordinates

**Response:**
```json
{
  "risk_score": 0.50,
  "risk_level": "MEDIUM",
  "recommendation": "manual_review",
  "reasoning": "No GPS data provided. Cannot validate location. Require photo with GPS enabled or manual review.",
  "fraud_flags": ["missing_gps_data"]
}
```

---

## 11. Admin Tools

### Manual Review Interface

Admins can review flagged proofs:

```typescript
router.procedure('reviewLogisticsFlag')
  .input(z.object({
    fraud_event_id: z.string(),
    action: z.enum(['clear', 'suspend', 'ban']),
    reason: z.string()
  }))
  .mutation(async ({ input, ctx }) => {
    if (!ctx.user.is_admin) throw new TRPCError({ code: 'FORBIDDEN' });

    await db.query(`
      UPDATE fraud_detection_events
      SET action_taken = $1,
          reviewed_by = $2,
          reviewed_at = NOW()
      WHERE id = $3
    `, [input.action, ctx.user.id, input.fraud_event_id]);

    if (input.action === 'ban') {
      // Ban user account
      await UserService.banUser(fraud_event.user_id, input.reason);
    }
  });
```

---

## 12. Testing Requirements

### Unit Tests

```typescript
describe('LogisticsAIService', () => {
  it('should pass GPS proximity check within 100m', () => {
    const result = validateGPSProximity(
      { lat: 30.2672, lon: -97.7431 },
      { lat: 30.2665, lon: -97.7425 },
      12
    );
    expect(result.passed).toBe(true);
    expect(result.distance_meters).toBeLessThan(100);
  });

  it('should detect impossible travel at 300 km/h', () => {
    const result = detectImpossibleTravel(
      { lat: 30.1500, lon: -97.8000, timestamp: '2026-02-06T14:15:00Z' },
      { lat: 30.2672, lon: -97.7431, timestamp: '2026-02-06T14:25:00Z' }
    );
    expect(result.passed).toBe(false);
    expect(result.speed_kmh).toBeGreaterThan(100);
  });

  it('should reject proofs with time-lock delta >5 minutes', () => {
    const result = validateTimeLock(
      'hash123',
      '2026-02-06T14:30:00Z', // submission
      '2026-02-06T14:20:00Z'  // GPS timestamp (10 min ago)
    );
    expect(result.passed).toBe(false);
    expect(result.time_delta_seconds).toBe(600);
  });
});
```

### Integration Tests

```typescript
describe('Logistics Integration', () => {
  it('should flag impossible travel and create fraud_detection_event', async () => {
    // Submit proof 50km away 5 minutes after last proof
    const result = await LogisticsAIService.validateGPSProof({
      proof_id: 'test-proof-1',
      last_known_location: { lat: 30.1500, lon: -97.8000, timestamp: '14:15:00' },
      gps_coordinates: { lat: 30.2672, lon: -97.7431 },
      gps_timestamp: '14:20:00'
    });

    expect(result.fraud_flags).toContain('impossible_travel');

    const event = await db.query(
      'SELECT * FROM fraud_detection_events WHERE proof_id = $1',
      ['test-proof-1']
    );
    expect(event.rows[0].event_type).toBe('impossible_travel');
    expect(event.rows[0].severity).toBe('high');
  });
});
```

---

## 13. Deployment Checklist

- [ ] `fraud_detection_events` table created (migration 004)
- [ ] `proof_submissions` table enhanced with GPS fields (migration 001)
- [ ] LogisticsAIService.ts implemented and tested
- [ ] Haversine distance calculation verified (unit tests)
- [ ] Impossible travel threshold calibrated (100 km/h ground)
- [ ] Time-lock validation tested with edge cases
- [ ] Integration with Judge AI tested
- [ ] Admin review interface deployed
- [ ] Fraud monitoring dashboard configured
- [ ] False positive rate tracked (<5% target)

---

## 14. Constitutional Enforcement Summary

| Rule | Enforced By | Bypass Possible? |
|------|-------------|------------------|
| GPS within 500m | Deterministic validator | ❌ No (hardcoded) |
| Speed <100 km/h | Deterministic validator | ❌ No (hardcoded) |
| Time-lock <5 min | Deterministic validator | ❌ No (hardcoded) |
| Authority level A2 | Database CHECK constraint | ❌ No (DB-enforced) |
| Fraud logging | Application code + DB insert | ⚠️ Yes (code bug only) |

**Key Insight:** Logistics Agent cannot directly reject proofs. Even with CRITICAL risk flags, the proof must be reviewed by Judge AI or admin before final decision.

---

**END OF SPECIFICATION**

_This specification is LOCKED and forms part of the constitutional layer of HustleXP. Changes require architectural review._
