-- ============================================================================
-- MIGRATION 004: Skill Taxonomy Integration
-- Source: SKILL_TAXONOMY.md, REACTIVE_SKILL_INTELLIGENCE_ANALYSIS.md
-- Purpose: Add granular skill support to capability system
-- ============================================================================

-- (1) Add claimed_skills column to capability_claims
ALTER TABLE capability_claims ADD COLUMN IF NOT EXISTS
  claimed_skills TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

-- (2) Add selection_source tracking
ALTER TABLE capability_claims ADD COLUMN IF NOT EXISTS
  selection_source VARCHAR(20) NOT NULL DEFAULT 'onboarding'
  CHECK (selection_source IN ('onboarding', 'settings', 'post_task_prompt'));

-- (3) Create skill_catalog table (canonical skill enumeration)
CREATE TABLE IF NOT EXISTS skill_catalog (
    skill_id VARCHAR(100) PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(100) NOT NULL,
    base_risk VARCHAR(10) NOT NULL CHECK (base_risk IN ('low', 'medium', 'high', 'critical')),
    regulated BOOLEAN NOT NULL DEFAULT FALSE,
    requires_insurance BOOLEAN NOT NULL DEFAULT FALSE,
    requires_background BOOLEAN NOT NULL DEFAULT FALSE,
    min_trust_tier INTEGER NOT NULL DEFAULT 1 CHECK (min_trust_tier BETWEEN 1 AND 5),
    verification_gate VARCHAR(255),
    adjacent_skills TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- (4) Indexes
CREATE INDEX IF NOT EXISTS idx_capability_claims_skills
  ON capability_claims USING GIN (claimed_skills);
CREATE INDEX IF NOT EXISTS idx_skill_catalog_category
  ON skill_catalog(category);
CREATE INDEX IF NOT EXISTS idx_skill_catalog_risk
  ON skill_catalog(base_risk);
CREATE INDEX IF NOT EXISTS idx_skill_catalog_tier
  ON skill_catalog(min_trust_tier);

-- (5) Skill claim history (append-only log for IC classification evidence)
CREATE TABLE IF NOT EXISTS skill_claim_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill_id VARCHAR(100) NOT NULL,
    action VARCHAR(10) NOT NULL CHECK (action IN ('claim', 'unclaim')),
    source VARCHAR(20) NOT NULL CHECK (source IN ('onboarding', 'settings', 'post_task_prompt')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_skill_claim_log_user
  ON skill_claim_log(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_claim_log_skill
  ON skill_claim_log(skill_id);

-- ============================================================================
-- END MIGRATION 004
-- ============================================================================
