# Fraud Detection & Risk Scoring Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Automated fraud detection, risk scoring, and pattern recognition

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Fraud detection prevents platform abuse before it causes damage.**

Every user, task, and transaction is risk-scored. Suspicious patterns trigger automated flags. High-risk activities require manual review before proceeding.

**What This Unlocks:**
- Prevents fake tasks (self-matching, payment fraud)
- Detects account abuse (multiple accounts, identity fraud)
- Protects platform integrity (trust, reputation)
- Reduces financial losses (chargebacks, refunds)
- Maintains legal compliance (AML, KYC)

---

## §1. Risk Scoring System

### 1.1 Risk Score Range

**Risk Score:** 0.0 (no risk) to 1.0 (maximum risk)

| Score Range | Label | Action |
|-------------|-------|--------|
| **0.0 - 0.3** | LOW | Auto-approve, monitor |
| **0.3 - 0.6** | MEDIUM | Review queue, additional verification |
| **0.6 - 0.8** | HIGH | Manual review required, flag account |
| **0.8 - 1.0** | CRITICAL | Auto-reject, suspend account, alert admins |

---

### 1.2 Risk Score Components

**User Risk Score:**
```
user_risk_score = (
  account_risk × 0.40 +
  behavioral_risk × 0.30 +
  payment_risk × 0.20 +
  identity_risk × 0.10
)
```

**Task Risk Score:**
```
task_risk_score = (
  poster_risk × 0.50 +
  task_pattern_risk × 0.30 +
  payment_risk × 0.20
)
```

**Transaction Risk Score:**
```
transaction_risk_score = (
  user_risk × 0.40 +
  task_risk × 0.30 +
  payment_method_risk × 0.20 +
  velocity_risk × 0.10
)
```

---

## §2. Fraud Patterns

### 2.1 Account-Level Patterns

| Pattern | Description | Risk Weight |
|---------|-------------|-------------|
| **Multiple Accounts** | Same device/IP, different accounts | 0.8 |
| **Rapid Account Creation** | Multiple signups in short time | 0.6 |
| **Suspicious Identity** | Missing verification, fake email | 0.5 |
| **Device Sharing** | Same device used by many accounts | 0.7 |
| **VPN/Proxy Usage** | High-risk IP, geolocation mismatch | 0.4 |

---

### 2.2 Task-Level Patterns

| Pattern | Description | Risk Weight |
|---------|-------------|-------------|
| **Self-Matching** | Poster accepts own task (same device/IP) | 1.0 |
| **Circular Matching** | User A posts, User B accepts, User B posts, User A accepts | 0.9 |
| **Fake Task Patterns** | Tasks posted and immediately cancelled | 0.7 |
| **Price Manipulation** | Unusually high/low prices | 0.5 |
| **Rapid Task Creation** | Many tasks posted in short time | 0.6 |
| **Duplicate Tasks** | Same task posted multiple times | 0.4 |

---

### 2.3 Payment-Level Patterns

| Pattern | Description | Risk Weight |
|---------|-------------|-------------|
| **Chargeback History** | Previous chargebacks on account | 0.9 |
| **Failed Payment Methods** | Multiple failed payment attempts | 0.7 |
| **Rapid Escrow Funding** | Many escrows funded quickly | 0.6 |
| **High-Value Transactions** | Unusually large payments | 0.5 |
| **Payment Method Mismatch** | Card country ≠ user location | 0.6 |
| **Stripe Radar Flags** | Stripe Radar risk score > 0.7 | 0.8 |

---

### 2.4 Behavioral Patterns

| Pattern | Description | Risk Weight |
|---------|-------------|-------------|
| **Velocity Abuse** | Too many actions in short time | 0.6 |
| **Dispute Abuse** | High dispute rate (>10%) | 0.8 |
| **Proof Rejection Abuse** | Frequent proof rejections | 0.7 |
| **Rating Manipulation** | Fake ratings (all 5-star, same IP) | 0.9 |
| **Message Spam** | Excessive messaging, harassment | 0.5 |

---

## §3. Risk Scoring Algorithm

### 3.1 User Risk Calculation

```typescript
interface UserRiskFactors {
  accountAge: number;  // Days since signup
  verificationStatus: 'verified' | 'unverified';
  deviceCount: number;  // Unique devices
  ipAddressCount: number;  // Unique IPs
  chargebackCount: number;
  disputeRate: number;
  taskCompletionRate: number;
  avgRating: number | null;
  stripeRadarScore: number | null;
}

function calculateUserRisk(userId: string, factors: UserRiskFactors): number {
  let risk = 0.0;
  
  // Account age (newer = higher risk)
  if (factors.accountAge < 1) risk += 0.2;
  else if (factors.accountAge < 7) risk += 0.1;
  else if (factors.accountAge < 30) risk += 0.05;
  
  // Verification status
  if (factors.verificationStatus === 'unverified') risk += 0.15;
  
  // Multiple devices/IPs (potential multi-account)
  if (factors.deviceCount > 3) risk += 0.2;
  if (factors.ipAddressCount > 5) risk += 0.15;
  
  // Chargeback history
  if (factors.chargebackCount > 0) risk += 0.3;
  if (factors.chargebackCount > 2) risk += 0.4;  // Cumulative
  
  // Dispute rate
  if (factors.disputeRate > 0.10) risk += 0.25;
  if (factors.disputeRate > 0.20) risk += 0.35;
  
  // Task completion rate (low = suspicious)
  if (factors.taskCompletionRate < 0.50) risk += 0.2;
  if (factors.taskCompletionRate < 0.30) risk += 0.3;
  
  // Stripe Radar score
  if (factors.stripeRadarScore && factors.stripeRadarScore > 0.7) {
    risk += 0.3;
  }
  
  return Math.min(risk, 1.0);  // Cap at 1.0
}
```

---

### 3.2 Task Risk Calculation

```typescript
interface TaskRiskFactors {
  posterRisk: number;
  price: number;
  category: string;
  deadline: Date;
  duplicateCount: number;  // Similar tasks by same poster
  selfMatchProbability: number;  // Same device/IP as potential worker
  rapidCreationFlag: boolean;  // Created shortly after previous task
}

function calculateTaskRisk(taskId: string, factors: TaskRiskFactors): number {
  let risk = factors.posterRisk * 0.5;  // Base risk from poster
  
  // Price manipulation
  const categoryAvg = getCategoryAveragePrice(factors.category);
  if (factors.price > categoryAvg * 3) risk += 0.2;  // Unusually high
  if (factors.price < categoryAvg * 0.3) risk += 0.15;  // Unusually low
  
  // Duplicate tasks
  if (factors.duplicateCount > 2) risk += 0.2;
  
  // Self-match probability
  if (factors.selfMatchProbability > 0.7) risk += 0.4;
  if (factors.selfMatchProbability > 0.9) risk += 0.6;  // Very likely self-match
  
  // Rapid creation
  if (factors.rapidCreationFlag) risk += 0.15;
  
  return Math.min(risk, 1.0);
}
```

---

## §4. Automated Flagging System

### 4.1 Flag Rules

**Auto-Flag Conditions:**
- User risk score ≥ 0.6
- Task risk score ≥ 0.6
- Transaction risk score ≥ 0.6
- Self-match detected (risk score = 1.0)
- Stripe Radar score ≥ 0.8
- Chargeback detected
- Multiple failed payment attempts (>3)

---

### 4.2 Flag Actions

| Risk Level | Action | Who Can Override |
|------------|--------|------------------|
| **LOW (0.0-0.3)** | Monitor, auto-approve | N/A |
| **MEDIUM (0.3-0.6)** | Review queue, additional verification | Admin |
| **HIGH (0.6-0.8)** | Manual review required, flag account | Admin |
| **CRITICAL (0.8-1.0)** | Auto-reject, suspend account, alert admins | Admin + Senior Admin |

---

### 4.3 Review Queue

**Review Queue Items:**
- Flagged users (risk score ≥ 0.6)
- Flagged tasks (risk score ≥ 0.6)
- Flagged transactions (risk score ≥ 0.6)
- Chargeback notifications
- Stripe Radar alerts

**Review Process:**
1. Admin reviews flag details
2. Admin checks patterns (device, IP, behavior)
3. Admin decides: approve, reject, suspend
4. Decision logged in audit trail

---

## §5. Fraud Detection Schema

### 5.1 Database Schema

```sql
CREATE TABLE fraud_risk_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'task', 'transaction')),
  entity_id UUID NOT NULL,
  
  -- Risk score
  risk_score DECIMAL(3,2) NOT NULL CHECK (risk_score >= 0.0 AND risk_score <= 1.0),
  risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  
  -- Components (for transparency)
  component_scores JSONB NOT NULL DEFAULT '{}',
  /* Example:
  {
    "account_risk": 0.2,
    "behavioral_risk": 0.3,
    "payment_risk": 0.1,
    "identity_risk": 0.0
  }
  */
  
  -- Flags
  flags TEXT[] DEFAULT ARRAY[]::TEXT[],
  /* Example: ['multiple_accounts', 'self_match', 'chargeback_history'] */
  
  -- Status
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  review_notes TEXT,
  
  -- Timestamps
  calculated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ,
  
  UNIQUE(entity_type, entity_id, calculated_at)
);

CREATE INDEX idx_fraud_risk_entity ON fraud_risk_scores(entity_type, entity_id, calculated_at DESC);
CREATE INDEX idx_fraud_risk_score ON fraud_risk_scores(risk_score DESC) WHERE status = 'active';
CREATE INDEX idx_fraud_risk_review ON fraud_risk_scores(status) WHERE status IN ('active', 'reviewed');

-- Fraud patterns table (for pattern detection)
CREATE TABLE fraud_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Pattern
  pattern_type VARCHAR(50) NOT NULL,
  pattern_description TEXT NOT NULL,
  
  -- Entities involved
  user_ids UUID[] NOT NULL,
  task_ids UUID[],
  transaction_ids UUID[],
  
  -- Evidence
  evidence JSONB NOT NULL DEFAULT '{}',
  /* Example:
  {
    "same_device": true,
    "same_ip": true,
    "circular_matching": true,
    "timeline": [...]
  }
  */
  
  -- Status
  status VARCHAR(20) DEFAULT 'detected' CHECK (status IN ('detected', 'reviewed', 'confirmed', 'dismissed')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  
  -- Timestamps
  detected_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_fraud_patterns_type ON fraud_patterns(pattern_type, detected_at DESC);
CREATE INDEX idx_fraud_patterns_status ON fraud_patterns(status) WHERE status = 'detected';
```

---

## §6. Stripe Radar Integration

### 6.1 Stripe Radar Risk Score

**Integration:**
- Use Stripe Radar for payment risk assessment
- Risk score: 0-100 (Stripe's scale)
- Map to HustleXP risk score: `stripe_score / 100.0`

**Actions Based on Stripe Score:**
- Score ≥ 80: Auto-reject payment, flag account
- Score ≥ 60: Manual review required
- Score < 60: Auto-approve, monitor

---

### 6.2 Stripe Radar Events

**Track:**
- `payment_intent.succeeded` (low risk)
- `payment_intent.payment_failed` (medium risk)
- `charge.dispute.created` (high risk)
- `radar.early_fraud_warning.created` (critical risk)

---

## §7. Fraud Detection Service

### 7.1 API Endpoints

```typescript
// tRPC router: fraud (admin only)
fraud.getRiskScore({
  input: {
    entityType: 'user' | 'task' | 'transaction';
    entityId: string;
  },
  output: {
    riskScore: number;
    riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
    componentScores: Record<string, number>;
    flags: string[];
    calculatedAt: Date;
  }
});

fraud.getReviewQueue({
  input: {
    riskLevel?: 'MEDIUM' | 'HIGH' | 'CRITICAL';
    limit?: number;
    offset?: number;
  },
  output: {
    items: ReviewQueueItem[];
    totalCount: number;
  }
});

fraud.reviewFlag({
  input: {
    riskScoreId: string;
    decision: 'approve' | 'reject' | 'suspend';
    notes?: string;
  },
  output: {
    status: 'reviewed';
    riskScoreId: string;
  }
});

fraud.detectPatterns({
  input: {
    userId?: string;
    taskId?: string;
    patternType?: string;
  },
  output: {
    patterns: FraudPattern[];
  }
});
```

---

## §8. Fraud Detection Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FRAUD-1** | Risk scores are calculated for all users/tasks/transactions | Background job |
| **FRAUD-2** | High-risk (≥0.6) entities require manual review | Backend validation |
| **FRAUD-3** | Critical-risk (≥0.8) entities are auto-rejected | Backend validation |
| **FRAUD-4** | Self-match (risk = 1.0) is always blocked | Backend validation |
| **FRAUD-5** | Review decisions are logged in audit trail | Backend logging |
| **FRAUD-6** | Risk scores are recalculated on pattern detection | Background job |

---

## §9. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Fraud detection rate** | >95% | Fraud detected / Total fraud attempts |
| **False positive rate** | <5% | False flags / Total flags |
| **Review queue time** | <24h | Time from flag to review |
| **Self-match prevention** | 100% | Self-matches blocked / Total self-match attempts |
| **Chargeback rate** | <1% | Chargebacks / Total transactions |
| **Account suspension rate** | <0.5% | Suspended accounts / Total accounts |

---

## §10. Constitutional Alignment

### 10.1 Authority Model

- **Risk Scoring**: Background job (Layer 1)
- **Pattern Detection**: Background job (Layer 1)
- **Flagging**: Automated (Layer 1)
- **Review**: Admin (Layer 6 - Human)

### 10.2 AI Authority

**No AI involvement in fraud detection** (pure rule-based pattern matching)

---

## §11. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial fraud detection specification |

---

**END OF FRAUD_DETECTION_SPEC v1.0.0**
