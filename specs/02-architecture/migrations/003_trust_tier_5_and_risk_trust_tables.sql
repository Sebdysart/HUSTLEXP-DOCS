-- ============================================================================
-- HustleXP Migration: 003_trust_tier_5_and_risk_trust_tables.sql
-- ============================================================================
-- PURPOSE: 
--   1. Extend trust_tier from 4 → 5 (MASTER) per PRODUCT_SPEC §8.2
--   2. Add Risk & Trust Engine tables (RISK_TRUST_ENGINE_LOCKED.md)
--   3. Add Judge Agent verification_audit table (JUDGE_AGENT_SPEC_LOCKED.md)
-- AUTHORITY: PRODUCT_SPEC INV-ELIGIBILITY-1, RISK_TRUST_ENGINE_LOCKED.md, JUDGE_AGENT_SPEC_LOCKED.md
-- ============================================================================

INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES ('1.3.0', 'system', 'TRUST_TIER_5_RISK_TRUST', 
  'Add MASTER tier, safety pool, claims, shadow scores, fraud signals, classification audit, verification audit')
ON CONFLICT (version) DO NOTHING;

-- ============================================================================
-- SECTION 1: TRUST TIER EXTENSION (4 → 5)
-- ============================================================================

-- 1.1 Users table: extend trust_tier constraint
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_trust_tier_check;
ALTER TABLE users ADD CONSTRAINT users_trust_tier_check 
  CHECK (trust_tier >= 1 AND trust_tier <= 5);

-- 1.2 Capability profiles: extend trust_tier and risk_clearance
ALTER TABLE capability_profiles DROP CONSTRAINT IF EXISTS capability_profiles_trust_tier_check;
ALTER TABLE capability_profiles ADD CONSTRAINT capability_profiles_trust_tier_check
  CHECK (trust_tier IN (1, 2, 3, 4, 5));

-- Comment: 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE, 5=MASTER

ALTER TABLE capability_profiles DROP CONSTRAINT IF EXISTS capability_profiles_risk_clearance_check;
ALTER TABLE capability_profiles ADD CONSTRAINT capability_profiles_risk_clearance_check CHECK (
  (trust_tier = 1 AND risk_clearance = ARRAY['low']::TEXT[]) OR
  (trust_tier = 2 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
  (trust_tier = 3 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
  (trust_tier = 4 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance) AND 'high' = ANY(risk_clearance)) OR
  (trust_tier = 5 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance) AND 'high' = ANY(risk_clearance) AND 'critical' = ANY(risk_clearance))
);

-- 1.3 Tasks: extend required_trust_tier
-- (If column exists from prior migration)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='required_trust_tier') THEN
    ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_required_trust_tier_check;
    ALTER TABLE tasks ADD CONSTRAINT tasks_required_trust_tier_check
      CHECK (required_trust_tier >= 0 AND required_trust_tier <= 5);
  END IF;
END $$;


-- ============================================================================
-- SECTION 2: SAFETY POOL TABLES (RISK_TRUST_ENGINE_LOCKED.md §PILLAR-1)
-- ============================================================================

-- 2.1 Safety Pool Ledger — tracks all pool financial activity
CREATE TABLE IF NOT EXISTS safety_pool_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_type VARCHAR(30) NOT NULL 
    CHECK (transaction_type IN ('PREMIUM', 'CLAIM_PAYOUT', 'SEED', 'OVERFLOW', 'ADJUSTMENT', 'BACKSTOP')),
  amount INTEGER NOT NULL,  -- in USD cents
  direction VARCHAR(10) NOT NULL CHECK (direction IN ('IN', 'OUT')),
  running_balance INTEGER NOT NULL,
  task_id UUID REFERENCES tasks(id),
  claim_id UUID,  -- FK added after claims table
  worker_id UUID REFERENCES users(id),
  premium_breakdown JSONB,  -- { category_base, risk_multiplier, trust_discount, final_premium }
  stripe_transfer_id VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INV-RISK-2: Safety pool cannot go negative (platform backstop)
ALTER TABLE safety_pool_ledger ADD CONSTRAINT safety_pool_no_negative
  CHECK (running_balance >= 0);

-- INV-RISK-10: Premium breakdown logged per task
-- (Enforced: premium_breakdown is NOT NULL for PREMIUM transactions via application layer)

CREATE INDEX idx_safety_pool_task ON safety_pool_ledger(task_id);
CREATE INDEX idx_safety_pool_created ON safety_pool_ledger(created_at DESC);
CREATE INDEX idx_safety_pool_type ON safety_pool_ledger(transaction_type);

-- 2.2 Claims — injury, property damage, service quality disputes
CREATE TABLE IF NOT EXISTS claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  claimant_id UUID NOT NULL REFERENCES users(id),
  respondent_id UUID REFERENCES users(id),
  
  claim_type VARCHAR(30) NOT NULL
    CHECK (claim_type IN ('PROPERTY_DAMAGE', 'INJURY', 'THEFT', 'SERVICE_QUALITY', 'OTHER')),
  description TEXT NOT NULL,
  claimed_amount INTEGER NOT NULL CHECK (claimed_amount > 0),  -- USD cents
  
  -- Judge Agent cross-reference (INV-RISK-6)
  judge_confidence DECIMAL(4,3),
  judge_evidence JSONB,  -- NOT NULL for auto-approved claims
  
  -- State machine
  state VARCHAR(20) NOT NULL DEFAULT 'FILED'
    CHECK (state IN ('FILED', 'UNDER_REVIEW', 'APPROVED', 'DENIED', 'PARTIAL', 'APPEALED')),
  
  approved_amount INTEGER CHECK (approved_amount >= 0),  -- USD cents
  resolution_reason TEXT,
  reviewed_by UUID REFERENCES users(id),
  
  -- Timestamps
  filed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add FK from safety_pool_ledger to claims
ALTER TABLE safety_pool_ledger ADD CONSTRAINT fk_safety_pool_claim
  FOREIGN KEY (claim_id) REFERENCES claims(id);

CREATE INDEX idx_claims_task ON claims(task_id);
CREATE INDEX idx_claims_state ON claims(state);
CREATE INDEX idx_claims_claimant ON claims(claimant_id);


-- ============================================================================
-- SECTION 3: BEHAVIORAL INTEGRITY TABLES (RISK_TRUST_ENGINE_LOCKED.md §PILLAR-3)
-- ============================================================================

-- 3.1 Shadow Scores — invisible behavioral integrity score
-- INV-RISK-3: Shadow score NEVER exposed to worker (no API endpoint)
CREATE TABLE IF NOT EXISTS shadow_scores (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  composite_score DECIMAL(5,2) NOT NULL DEFAULT 100.00
    CHECK (composite_score >= 0 AND composite_score <= 100),
  
  -- 6 component scores (0-100 each)
  verification_integrity DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  behavioral_consistency DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  spatial_integrity DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  temporal_integrity DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  financial_integrity DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  social_integrity DECIMAL(5,2) NOT NULL DEFAULT 100.00,
  
  -- Queue tier (derived from composite_score)
  queue_tier VARCHAR(20) NOT NULL DEFAULT 'STANDARD'
    CHECK (queue_tier IN ('STANDARD', 'RESTRICTED', 'PROBATION', 'FROZEN')),
  
  last_computed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  signal_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3.2 Fraud Signals — individual risk events with decay
CREATE TABLE IF NOT EXISTS fraud_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  signal_type VARCHAR(40) NOT NULL
    CHECK (signal_type IN (
      'GPS_EMULATOR', 'IMPOSSIBLE_TRAVEL', 'APP_TAMPERED',
      'FINGERPRINT_DRIFT', 'DEVICE_ATTESTATION_FAIL', 'SELFIE_MISMATCH',
      'DUPLICATE_ACCOUNT', 'SUSPICIOUS_CLAIM', 'RATING_MANIPULATION',
      'RAPID_CREATION', 'FAKE_PROOF'
    )),
  
  severity VARCHAR(10) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  confidence DECIMAL(4,3) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  evidence JSONB NOT NULL,
  
  -- Decay (INV-RISK-9: automatic, no manual un-decay)
  decayed BOOLEAN NOT NULL DEFAULT FALSE,
  decay_at TIMESTAMPTZ NOT NULL,
  
  action_taken VARCHAR(50),
  reviewed_by UUID REFERENCES users(id),
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fraud_signals_user ON fraud_signals(user_id);
CREATE INDEX idx_fraud_signals_type ON fraud_signals(signal_type);
CREATE INDEX idx_fraud_signals_decay ON fraud_signals(decayed, decay_at);


-- ============================================================================
-- SECTION 4: AUDIT TABLES (RISK_TRUST_ENGINE_LOCKED.md §PILLAR-2, JUDGE_AGENT_SPEC_LOCKED.md)
-- ============================================================================

-- 4.1 Classification Audit — contractor compliance records
CREATE TABLE IF NOT EXISTS classification_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  audit_type VARCHAR(20) NOT NULL
    CHECK (audit_type IN ('ONBOARDING', 'QUARTERLY', 'INCIDENT', 'REGULATORY')),
  
  -- 6-pillar pass/fail (INV-CLASS-1 through INV-CLASS-6)
  non_exclusivity_pass BOOLEAN NOT NULL,
  task_freedom_pass BOOLEAN NOT NULL,
  schedule_control_pass BOOLEAN NOT NULL,
  pricing_control_pass BOOLEAN NOT NULL,
  tool_independence_pass BOOLEAN NOT NULL,
  method_control_pass BOOLEAN NOT NULL,
  
  -- Computed: all 6 must pass
  all_pass BOOLEAN GENERATED ALWAYS AS (
    non_exclusivity_pass AND task_freedom_pass AND schedule_control_pass AND
    pricing_control_pass AND tool_independence_pass AND method_control_pass
  ) STORED,
  
  evidence JSONB NOT NULL,
  auditor VARCHAR(100),
  notes TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_classification_audit_user ON classification_audit(user_id);
CREATE INDEX idx_classification_audit_type ON classification_audit(audit_type);

-- 4.2 Verification Audit — Judge Agent verification decisions
-- Source: JUDGE_AGENT_SPEC_LOCKED.md §8
CREATE TABLE IF NOT EXISTS verification_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proof_id UUID NOT NULL REFERENCES proofs(id),
  task_id UUID NOT NULL REFERENCES tasks(id),
  worker_id UUID NOT NULL REFERENCES users(id),
  
  -- Verification layers executed
  metadata_check JSONB,      -- EXIF, GPS, timestamp results
  visual_analysis JSONB,     -- AI semantic analysis results
  spatial_verification JSONB,-- LiDAR/GPS correlation results
  behavioral_check JSONB,    -- Shadow score signals at time of proof
  
  -- Verdict
  overall_confidence DECIMAL(4,3) NOT NULL,
  verdict VARCHAR(20) NOT NULL CHECK (verdict IN ('PASS', 'FAIL', 'UNCERTAIN')),
  fraud_flags TEXT[],
  
  -- Performance
  processing_time_ms INTEGER,
  model_version VARCHAR(50),
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_verification_audit_proof ON verification_audit(proof_id);
CREATE INDEX idx_verification_audit_worker ON verification_audit(worker_id);
CREATE INDEX idx_verification_audit_verdict ON verification_audit(verdict);

-- ============================================================================
-- SECTION 5: SCHEMA.SQL INLINE FIXES
-- ============================================================================
-- These fixes update existing constraints in schema.sql that reference trust_tier <= 4
-- They should be applied AFTER the base schema.sql is loaded.
-- 
-- NOTE: The canonical schema.sql should also be updated directly.
-- Affected lines in schema.sql:
--   Line ~66:   users.trust_tier CHECK <= 4  → <= 5
--   Line ~2102: capability_profiles.trust_tier IN (1,2,3,4) → (1,2,3,4,5)
--   Line ~2124: risk_clearance constraint → add tier 5 clause
--   Line ~2266: required_trust_tier <= 4 → <= 5
-- ============================================================================
