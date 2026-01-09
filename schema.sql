-- ============================================================================
-- HustleXP Canonical Database Schema v1.0.0
-- ============================================================================
-- STATUS: CONSTITUTIONAL — DO NOT MODIFY WITHOUT VERSION BUMP
-- AUTHORITY: Layer 0 (Highest) — See ARCHITECTURE.md §1
-- GOVERNANCE: Changes require founder approval + 24h review
-- 
-- This schema enforces invariants at the database level.
-- Application code CANNOT bypass these constraints.
-- ============================================================================

-- Version tracking (immutable record of schema state)
CREATE TABLE IF NOT EXISTS schema_versions (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    applied_by VARCHAR(100) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    notes TEXT
);

INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES ('1.0.0', 'system', 'INITIAL', 'Constitutional schema - INV-1 through INV-5, terminal state triggers, AI tables');

-- ============================================================================
-- SECTION 1: CORE DOMAIN TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1.1 USERS TABLE
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §5, ONBOARDING_SPEC §7
-- ----------------------------------------------------------------------------

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identity
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    
    -- Role (from onboarding)
    default_mode VARCHAR(20) NOT NULL DEFAULT 'worker' 
        CHECK (default_mode IN ('worker', 'poster')),
    
    -- Onboarding (ONBOARDING_SPEC §7, §11)
    onboarding_version VARCHAR(20),
    onboarding_completed_at TIMESTAMPTZ,
    role_confidence_worker NUMERIC(5,4),
    role_confidence_poster NUMERIC(5,4),
    role_certainty_tier VARCHAR(20) CHECK (role_certainty_tier IN ('STRONG', 'MODERATE', 'WEAK')),
    role_was_overridden BOOLEAN DEFAULT FALSE,
    inconsistency_flags TEXT[],
    
    -- Profile signals
    risk_tolerance NUMERIC(4,3),
    urgency_bias NUMERIC(4,3),
    authority_expectation NUMERIC(4,3),
    price_sensitivity NUMERIC(4,3),
    
    -- Trust (PRODUCT_SPEC §6, 4-tier system)
    trust_tier INTEGER DEFAULT 1 NOT NULL 
        CHECK (trust_tier >= 1 AND trust_tier <= 4),
    
    -- XP (PRODUCT_SPEC §5)
    xp_total INTEGER DEFAULT 0 NOT NULL 
        CHECK (xp_total >= 0),
    current_level INTEGER DEFAULT 1 NOT NULL 
        CHECK (current_level >= 1 AND current_level <= 10),
    
    -- Streak (PRODUCT_SPEC §5.4, §5.5)
    current_streak INTEGER DEFAULT 0 NOT NULL 
        CHECK (current_streak >= 0),
    last_task_completed_at TIMESTAMPTZ,
    streak_grace_expires_at TIMESTAMPTZ,
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    student_id_verified BOOLEAN DEFAULT FALSE,
    
    -- Stripe
    stripe_customer_id VARCHAR(255),
    stripe_connect_id VARCHAR(255),
    
    -- UI preferences (ONBOARDING_SPEC §6)
    xp_visibility_rules VARCHAR(20) DEFAULT 'ledger',
    trust_ui_density VARCHAR(20) DEFAULT 'normal',
    copy_tone_variant VARCHAR(20) DEFAULT 'neutral',
    
    -- Gamification unlock tracking (ONBOARDING_SPEC §13.4, UI_SPEC §12.4)
    xp_first_celebration_shown_at TIMESTAMPTZ,  -- NULL until first XP animation plays
    
    -- Live Mode (PRODUCT_SPEC §3.5)
    live_mode_state VARCHAR(20) DEFAULT 'OFF'
        CHECK (live_mode_state IN ('OFF', 'ACTIVE', 'COOLDOWN', 'PAUSED')),
    live_mode_session_started_at TIMESTAMPTZ,
    live_mode_banned_until TIMESTAMPTZ,
    live_mode_total_tasks INTEGER DEFAULT 0,
    live_mode_completion_rate NUMERIC(5,4),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_stripe_customer ON users(stripe_customer_id);
CREATE INDEX idx_users_trust_tier ON users(trust_tier);
CREATE INDEX idx_users_default_mode ON users(default_mode);

-- ----------------------------------------------------------------------------
-- 1.2 TASKS TABLE
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §3
-- Terminal States: COMPLETED, CANCELLED, EXPIRED (immutable once reached)
-- ----------------------------------------------------------------------------

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Participants
    poster_id UUID NOT NULL REFERENCES users(id),
    worker_id UUID REFERENCES users(id),
    
    -- Content
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    location VARCHAR(255),
    category VARCHAR(50),
    
    -- Pricing (in USD cents — PRODUCT_SPEC §4.3)
    price INTEGER NOT NULL CHECK (price > 0),
    
    -- Scope hash for immutability
    scope_hash VARCHAR(64),
    
    -- State (PRODUCT_SPEC §3.1)
    state VARCHAR(20) NOT NULL DEFAULT 'OPEN' 
        CHECK (state IN (
            'OPEN',           -- Visible, accepting applications
            'ACCEPTED',       -- Worker assigned, work in progress
            'PROOF_SUBMITTED',-- Awaiting poster review
            'DISPUTED',       -- Under admin review
            'COMPLETED',      -- TERMINAL: Successfully finished
            'CANCELLED',      -- TERMINAL: Terminated by poster/admin
            'EXPIRED'         -- TERMINAL: Time limit exceeded
        )),
    
    -- Live Mode (PRODUCT_SPEC §3.5)
    mode VARCHAR(20) NOT NULL DEFAULT 'STANDARD'
        CHECK (mode IN ('STANDARD', 'LIVE')),
    live_broadcast_started_at TIMESTAMPTZ,
    live_broadcast_expired_at TIMESTAMPTZ,
    live_broadcast_radius_miles NUMERIC(4,1),
    
    -- Time bounds
    deadline TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    proof_submitted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    expired_at TIMESTAMPTZ,
    
    -- Proof requirement
    requires_proof BOOLEAN DEFAULT TRUE,
    proof_instructions TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_tasks_poster ON tasks(poster_id);
CREATE INDEX idx_tasks_worker ON tasks(worker_id);
CREATE INDEX idx_tasks_state ON tasks(state);
CREATE INDEX idx_tasks_created ON tasks(created_at DESC);

-- ----------------------------------------------------------------------------
-- 1.2.1 TASK TERMINAL STATE TRIGGER (AUDIT-4)
-- ----------------------------------------------------------------------------
-- Invariant: Once task reaches terminal state, it is FROZEN
-- No outbound transitions, no field modifications (except audit fields)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_task_terminal_mutation()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if OLD state is terminal
    IF OLD.state IN ('COMPLETED', 'CANCELLED', 'EXPIRED') THEN
        -- Only allow updates to audit-related fields
        IF NEW.state != OLD.state OR
           NEW.price != OLD.price OR
           NEW.poster_id != OLD.poster_id OR
           NEW.worker_id IS DISTINCT FROM OLD.worker_id OR
           NEW.title != OLD.title OR
           NEW.description != OLD.description THEN
            RAISE EXCEPTION 'TERMINAL_STATE_VIOLATION: Cannot modify task % in terminal state %', OLD.id, OLD.state
                USING ERRCODE = 'HX001';
        END IF;
    END IF;
    
    -- Prevent transition FROM terminal states
    IF OLD.state IN ('COMPLETED', 'CANCELLED', 'EXPIRED') AND NEW.state != OLD.state THEN
        RAISE EXCEPTION 'TERMINAL_STATE_VIOLATION: Cannot transition task % from terminal state %', OLD.id, OLD.state
            USING ERRCODE = 'HX001';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_terminal_guard
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION prevent_task_terminal_mutation();

-- ----------------------------------------------------------------------------
-- 1.3 ESCROWS TABLE
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §4
-- Terminal States: RELEASED, REFUNDED, REFUND_PARTIAL (immutable once reached)
-- INV-4: amount is immutable after creation
-- ----------------------------------------------------------------------------

CREATE TABLE escrows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    task_id UUID NOT NULL REFERENCES tasks(id) UNIQUE,
    
    -- Amount (INV-4: immutable after creation)
    -- Stored in USD cents — no floating point
    amount INTEGER NOT NULL CHECK (amount > 0),
    
    -- State (PRODUCT_SPEC §4.1)
    state VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (state IN (
            'PENDING',        -- Awaiting payment
            'FUNDED',         -- Money held in escrow
            'LOCKED_DISPUTE', -- Frozen during dispute
            'RELEASED',       -- TERMINAL: Paid to worker
            'REFUNDED',       -- TERMINAL: Returned to poster
            'REFUND_PARTIAL'  -- TERMINAL: Split resolution
        )),
    
    -- Partial refund tracking (for REFUND_PARTIAL state)
    refund_amount INTEGER CHECK (refund_amount >= 0),
    release_amount INTEGER CHECK (release_amount >= 0),
    
    -- Stripe references
    stripe_payment_intent_id VARCHAR(255),
    stripe_transfer_id VARCHAR(255),
    stripe_refund_id VARCHAR(255),
    
    -- Timestamps
    funded_at TIMESTAMPTZ,
    released_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Constraint: partial amounts must sum to total
    CONSTRAINT escrow_partial_sum_check 
        CHECK (
            state != 'REFUND_PARTIAL' OR 
            (refund_amount IS NOT NULL AND release_amount IS NOT NULL AND 
             refund_amount + release_amount = amount)
        )
);

CREATE INDEX idx_escrows_task ON escrows(task_id);
CREATE INDEX idx_escrows_state ON escrows(state);
CREATE INDEX idx_escrows_stripe_pi ON escrows(stripe_payment_intent_id);

-- ----------------------------------------------------------------------------
-- 1.3.1 ESCROW TERMINAL STATE TRIGGER (AUDIT-4)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_escrow_terminal_mutation()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.state IN ('RELEASED', 'REFUNDED', 'REFUND_PARTIAL') THEN
        IF NEW.state != OLD.state OR
           NEW.amount != OLD.amount OR
           NEW.task_id != OLD.task_id THEN
            RAISE EXCEPTION 'TERMINAL_STATE_VIOLATION: Cannot modify escrow % in terminal state %', OLD.id, OLD.state
                USING ERRCODE = 'HX002';
        END IF;
    END IF;
    
    IF OLD.state IN ('RELEASED', 'REFUNDED', 'REFUND_PARTIAL') AND NEW.state != OLD.state THEN
        RAISE EXCEPTION 'TERMINAL_STATE_VIOLATION: Cannot transition escrow % from terminal state %', OLD.id, OLD.state
            USING ERRCODE = 'HX002';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER escrow_terminal_guard
    BEFORE UPDATE ON escrows
    FOR EACH ROW
    EXECUTE FUNCTION prevent_escrow_terminal_mutation();

-- ----------------------------------------------------------------------------
-- 1.3.2 ESCROW AMOUNT IMMUTABILITY TRIGGER (INV-4)
-- ----------------------------------------------------------------------------
-- INV-4: Escrow amount = task price (immutable after funding)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_escrow_amount_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Amount cannot change after escrow is funded
    IF OLD.state != 'PENDING' AND NEW.amount != OLD.amount THEN
        RAISE EXCEPTION 'INV-4_VIOLATION: Cannot change escrow amount after funding. Escrow: %, Old: %, New: %', 
            OLD.id, OLD.amount, NEW.amount
            USING ERRCODE = 'HX004';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER escrow_amount_immutable
    BEFORE UPDATE ON escrows
    FOR EACH ROW
    EXECUTE FUNCTION prevent_escrow_amount_change();

-- ----------------------------------------------------------------------------
-- 1.4 PROOFS TABLE
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §3.2, INV-3
-- INV-3: COMPLETED task requires ACCEPTED proof
-- ----------------------------------------------------------------------------

CREATE TABLE proofs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    task_id UUID NOT NULL REFERENCES tasks(id),
    submitter_id UUID NOT NULL REFERENCES users(id),
    
    -- State
    state VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (state IN (
            'PENDING',   -- Not yet submitted
            'SUBMITTED', -- Awaiting review
            'ACCEPTED',  -- Approved by poster
            'REJECTED',  -- Rejected by poster
            'EXPIRED'    -- Review window passed
        )),
    
    -- Content
    description TEXT,
    
    -- Review
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Timestamps
    submitted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_proofs_task ON proofs(task_id);
CREATE INDEX idx_proofs_submitter ON proofs(submitter_id);
CREATE INDEX idx_proofs_state ON proofs(state);

-- ----------------------------------------------------------------------------
-- 1.4.1 PROOF PHOTOS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE proof_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proof_id UUID NOT NULL REFERENCES proofs(id) ON DELETE CASCADE,
    
    -- Storage
    storage_key VARCHAR(500) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    checksum_sha256 VARCHAR(64) NOT NULL,
    
    -- Metadata
    capture_time TIMESTAMPTZ,
    sequence_number INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_proof_photos_proof ON proof_photos(proof_id);

-- ============================================================================
-- SECTION 2: XP SYSTEM (PRODUCT_SPEC §5)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 XP LEDGER TABLE
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §5, INV-1, INV-5
-- INV-1: XP requires RELEASED escrow
-- INV-5: XP issuance is idempotent per escrow_id (UNIQUE constraint)
-- ----------------------------------------------------------------------------

CREATE TABLE xp_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- References
    user_id UUID NOT NULL REFERENCES users(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    escrow_id UUID NOT NULL REFERENCES escrows(id),
    
    -- XP awarded
    base_xp INTEGER NOT NULL CHECK (base_xp > 0),
    streak_multiplier NUMERIC(3,2) DEFAULT 1.00 NOT NULL,
    decay_factor NUMERIC(6,4) DEFAULT 1.0000 NOT NULL,
    effective_xp INTEGER NOT NULL CHECK (effective_xp > 0),
    
    -- Context
    reason VARCHAR(50) NOT NULL DEFAULT 'task_completion',
    
    -- User state at time of award (for audit)
    user_xp_before INTEGER NOT NULL,
    user_xp_after INTEGER NOT NULL,
    user_level_before INTEGER NOT NULL,
    user_level_after INTEGER NOT NULL,
    user_streak_at_award INTEGER NOT NULL,
    
    -- Timestamps
    awarded_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- INV-5: One XP award per escrow (idempotency)
    CONSTRAINT xp_ledger_escrow_unique UNIQUE (escrow_id)
);

CREATE INDEX idx_xp_ledger_user ON xp_ledger(user_id);
CREATE INDEX idx_xp_ledger_task ON xp_ledger(task_id);
CREATE INDEX idx_xp_ledger_awarded ON xp_ledger(awarded_at DESC);

-- ----------------------------------------------------------------------------
-- 2.1.1 XP LEDGER INSERT TRIGGER (INV-1)
-- ----------------------------------------------------------------------------
-- INV-1: XP requires RELEASED escrow
-- Enforces that XP can only be awarded when escrow is in RELEASED state
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION enforce_xp_requires_released_escrow()
RETURNS TRIGGER AS $$
DECLARE
    escrow_state VARCHAR(20);
BEGIN
    -- Get current escrow state
    SELECT state INTO escrow_state
    FROM escrows
    WHERE id = NEW.escrow_id;
    
    IF escrow_state IS NULL THEN
        RAISE EXCEPTION 'INV-1_VIOLATION: Cannot award XP - escrow % not found', NEW.escrow_id
            USING ERRCODE = 'HX101';
    END IF;
    
    IF escrow_state != 'RELEASED' THEN
        RAISE EXCEPTION 'INV-1_VIOLATION: Cannot award XP - escrow % is in state % (must be RELEASED)', 
            NEW.escrow_id, escrow_state
            USING ERRCODE = 'HX101';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER xp_requires_released_escrow
    BEFORE INSERT ON xp_ledger
    FOR EACH ROW
    EXECUTE FUNCTION enforce_xp_requires_released_escrow();

-- ----------------------------------------------------------------------------
-- 2.1.2 XP LEDGER DELETE PREVENTION (Append-only)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_xp_ledger_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'XP_LEDGER_IMMUTABLE: Cannot delete XP ledger entries. Entry: %', OLD.id
        USING ERRCODE = 'HX102';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER xp_ledger_no_delete
    BEFORE DELETE ON xp_ledger
    FOR EACH ROW
    EXECUTE FUNCTION prevent_xp_ledger_delete();

-- ============================================================================
-- SECTION 3: TRUST SYSTEM (PRODUCT_SPEC §6, ARCHITECTURE §2.2)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 3.1 TRUST LEDGER TABLE
-- ----------------------------------------------------------------------------
-- Authority: ARCHITECTURE §2.2 (INV-TRUST-3: Trust changes require audit log)
-- ----------------------------------------------------------------------------

CREATE TABLE trust_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Change
    old_tier INTEGER NOT NULL CHECK (old_tier >= 1 AND old_tier <= 4),
    new_tier INTEGER NOT NULL CHECK (new_tier >= 1 AND new_tier <= 4),
    
    -- Reason
    reason VARCHAR(100) NOT NULL,
    reason_details JSONB,
    
    -- Related entities
    task_id UUID REFERENCES tasks(id),
    dispute_id UUID,
    
    -- Actor
    changed_by VARCHAR(100) NOT NULL, -- 'system', 'admin:usr_xxx'
    
    -- Timestamps
    changed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_trust_ledger_user ON trust_ledger(user_id);
CREATE INDEX idx_trust_ledger_changed ON trust_ledger(changed_at DESC);

-- ----------------------------------------------------------------------------
-- 3.1.1 TRUST CHANGE AUDIT TRIGGER
-- ----------------------------------------------------------------------------
-- Automatically log trust tier changes to trust_ledger
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION audit_trust_tier_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.trust_tier != NEW.trust_tier THEN
        INSERT INTO trust_ledger (user_id, old_tier, new_tier, reason, changed_by)
        VALUES (NEW.id, OLD.trust_tier, NEW.trust_tier, 'direct_update', 'system');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trust_tier_audit
    AFTER UPDATE OF trust_tier ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_trust_tier_change();

-- ============================================================================
-- SECTION 4: BADGE SYSTEM (ARCHITECTURE §2.3)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4.1 BADGES TABLE (Append-only ledger)
-- ----------------------------------------------------------------------------
-- Authority: ARCHITECTURE §2.3
-- INV-BADGE-2: Badges cannot be revoked (append-only ledger)
-- INV-BADGE-3: Badge unlock animations play exactly once (server-side tracking)
-- ----------------------------------------------------------------------------

CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Badge info
    badge_type VARCHAR(50) NOT NULL,
    badge_tier INTEGER NOT NULL CHECK (badge_tier >= 1 AND badge_tier <= 4),
    
    -- INV-BADGE-3: Animation tracking (server-side, not client)
    animation_shown_at TIMESTAMPTZ,
    
    -- Context
    awarded_for VARCHAR(100),
    task_id UUID REFERENCES tasks(id),
    
    -- Timestamps
    awarded_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Unique badge per user
    CONSTRAINT badges_user_type_unique UNIQUE (user_id, badge_type)
);

CREATE INDEX idx_badges_user ON badges(user_id);
CREATE INDEX idx_badges_type ON badges(badge_type);

-- ----------------------------------------------------------------------------
-- 4.1.1 BADGE DELETE PREVENTION (INV-BADGE-2)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_badge_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'INV-BADGE-2_VIOLATION: Cannot delete badges. Badges are append-only. Badge: %', OLD.id
        USING ERRCODE = 'HX401';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER badge_no_delete
    BEFORE DELETE ON badges
    FOR EACH ROW
    EXECUTE FUNCTION prevent_badge_delete();

-- ============================================================================
-- SECTION 5: DISPUTE SYSTEM
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 5.1 DISPUTES TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    task_id UUID NOT NULL REFERENCES tasks(id),
    escrow_id UUID NOT NULL REFERENCES escrows(id),
    
    -- Participants
    initiated_by UUID NOT NULL REFERENCES users(id),
    poster_id UUID NOT NULL REFERENCES users(id),
    worker_id UUID NOT NULL REFERENCES users(id),
    
    -- State
    state VARCHAR(20) NOT NULL DEFAULT 'OPEN'
        CHECK (state IN (
            'OPEN',           -- Under review
            'EVIDENCE_REQUESTED', -- Waiting for more info
            'RESOLVED',       -- TERMINAL: Decision made
            'ESCALATED'       -- Sent to higher authority
        )),
    
    -- Reason
    reason VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    
    -- Resolution
    resolution VARCHAR(50),
    resolution_notes TEXT,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMPTZ,
    
    -- Outcome
    outcome_escrow_action VARCHAR(20)
        CHECK (outcome_escrow_action IN ('RELEASE', 'REFUND', 'SPLIT')),
    outcome_worker_penalty BOOLEAN DEFAULT FALSE,
    outcome_poster_penalty BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_disputes_task ON disputes(task_id);
CREATE INDEX idx_disputes_state ON disputes(state);
CREATE INDEX idx_disputes_initiated ON disputes(initiated_by);

-- ============================================================================
-- SECTION 6: STRIPE INTEGRATION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 6.1 PROCESSED STRIPE EVENTS (Idempotency)
-- ----------------------------------------------------------------------------
-- Authority: ARCHITECTURE §2.4 (INV-STRIPE-1)
-- ----------------------------------------------------------------------------

CREATE TABLE processed_stripe_events (
    event_id VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    processed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    result VARCHAR(50) NOT NULL,
    error_message TEXT
);

CREATE INDEX idx_stripe_events_processed ON processed_stripe_events(processed_at DESC);

-- ============================================================================
-- SECTION 7: AI INFRASTRUCTURE (AI_INFRASTRUCTURE.md §6)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 7.1 AI EVENTS TABLE (Immutable inputs)
-- ----------------------------------------------------------------------------

CREATE TABLE ai_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Context
    subsystem VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    
    -- Actors
    actor_user_id UUID REFERENCES users(id),
    subject_user_id UUID REFERENCES users(id),
    task_id UUID REFERENCES tasks(id),
    dispute_id UUID REFERENCES disputes(id),
    
    -- Immutable payload
    payload JSONB NOT NULL,
    payload_hash VARCHAR(64) NOT NULL,
    
    -- Versioning
    schema_version VARCHAR(20) NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_events_subsystem ON ai_events(subsystem);
CREATE INDEX idx_ai_events_actor ON ai_events(actor_user_id);
CREATE INDEX idx_ai_events_created ON ai_events(created_at DESC);

-- ----------------------------------------------------------------------------
-- 7.2 AI JOBS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE ai_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    event_id UUID NOT NULL REFERENCES ai_events(id),
    subsystem VARCHAR(50) NOT NULL,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN (
            'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'TIMED_OUT', 'KILLED'
        )),
    
    -- Model info
    model_provider VARCHAR(50),
    model_id VARCHAR(100),
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
CREATE INDEX idx_ai_jobs_event ON ai_jobs(event_id);

-- ----------------------------------------------------------------------------
-- 7.3 AI PROPOSALS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE ai_proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    job_id UUID NOT NULL REFERENCES ai_jobs(id),
    
    -- Proposal content
    proposal_type VARCHAR(50) NOT NULL,
    proposal JSONB NOT NULL,
    proposal_hash VARCHAR(64) NOT NULL,
    
    -- Confidence
    confidence NUMERIC(5,4),
    certainty_tier VARCHAR(20),
    
    -- Anomaly flags
    anomaly_flags TEXT[],
    
    -- Versioning
    schema_version VARCHAR(20) NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_proposals_job ON ai_proposals(job_id);
CREATE INDEX idx_ai_proposals_type ON ai_proposals(proposal_type);

-- ----------------------------------------------------------------------------
-- 7.4 AI DECISIONS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE ai_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- References
    proposal_id UUID NOT NULL REFERENCES ai_proposals(id),
    
    -- Decision
    accepted BOOLEAN NOT NULL,
    reason_codes TEXT[] NOT NULL,
    
    -- What was written (if accepted)
    writes JSONB,
    
    -- Authority
    final_author VARCHAR(100) NOT NULL,
    
    -- Timestamps
    decided_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ai_decisions_proposal ON ai_decisions(proposal_id);
CREATE INDEX idx_ai_decisions_accepted ON ai_decisions(accepted);

-- ----------------------------------------------------------------------------
-- 7.5 EVIDENCE TABLE (AI_INFRASTRUCTURE.md §8)
-- ----------------------------------------------------------------------------

CREATE TABLE evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Context
    task_id UUID REFERENCES tasks(id),
    dispute_id UUID REFERENCES disputes(id),
    proof_id UUID REFERENCES proofs(id),
    
    -- Uploader
    uploader_user_id UUID NOT NULL REFERENCES users(id),
    
    -- Request context
    requested_by VARCHAR(20) NOT NULL
        CHECK (requested_by IN ('system', 'poster', 'admin')),
    request_reason_codes TEXT[] NOT NULL,
    ai_request_proposal_id UUID REFERENCES ai_proposals(id),
    
    -- File info
    storage_key VARCHAR(500) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    checksum_sha256 VARCHAR(64) NOT NULL,
    
    -- Capture metadata
    capture_time TIMESTAMPTZ,
    device_metadata JSONB,
    
    -- Access control
    access_scope VARCHAR(20) NOT NULL DEFAULT 'restricted'
        CHECK (access_scope IN (
            'uploader_only', 'restricted', 'dispute_reviewers', 'admin_only'
        )),
    
    -- Retention (AI_INFRASTRUCTURE.md §8.10)
    retention_deadline TIMESTAMPTZ NOT NULL,
    legal_hold BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    
    -- Moderation
    moderation_status VARCHAR(20) DEFAULT 'pending'
        CHECK (moderation_status IN (
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
CREATE INDEX idx_evidence_moderation ON evidence(moderation_status) WHERE moderation_status != 'approved';

-- ============================================================================
-- SECTION 8: ADMIN & AUDIT
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 8.1 ADMIN ROLES TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE admin_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    
    role VARCHAR(50) NOT NULL
        CHECK (role IN ('support', 'moderator', 'admin', 'founder')),
    
    -- Permissions
    can_resolve_disputes BOOLEAN DEFAULT FALSE,
    can_override_escrow BOOLEAN DEFAULT FALSE,
    can_modify_trust BOOLEAN DEFAULT FALSE,
    can_ban_users BOOLEAN DEFAULT FALSE,
    can_access_financials BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    granted_by UUID REFERENCES users(id)
);

CREATE INDEX idx_admin_roles_user ON admin_roles(user_id);

-- ----------------------------------------------------------------------------
-- 8.2 ADMIN ACTIONS TABLE (Audit log)
-- ----------------------------------------------------------------------------

CREATE TABLE admin_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Actor
    admin_user_id UUID NOT NULL REFERENCES users(id),
    admin_role VARCHAR(50) NOT NULL,
    
    -- Action
    action_type VARCHAR(100) NOT NULL,
    action_details JSONB NOT NULL,
    
    -- Target
    target_user_id UUID REFERENCES users(id),
    target_task_id UUID REFERENCES tasks(id),
    target_escrow_id UUID REFERENCES escrows(id),
    target_dispute_id UUID REFERENCES disputes(id),
    
    -- Result
    result VARCHAR(50) NOT NULL,
    result_details JSONB,
    
    -- Timestamps
    performed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_admin_actions_admin ON admin_actions(admin_user_id);
CREATE INDEX idx_admin_actions_type ON admin_actions(action_type);
CREATE INDEX idx_admin_actions_performed ON admin_actions(performed_at DESC);

-- ----------------------------------------------------------------------------
-- 8.2.1 ADMIN ACTION AUDIT TRIGGER
-- ----------------------------------------------------------------------------
-- Prevent deletion of admin actions (append-only audit log)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_admin_action_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'AUDIT_IMMUTABLE: Cannot delete admin action records. Action: %', OLD.id
        USING ERRCODE = 'HX801';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER admin_actions_no_delete
    BEFORE DELETE ON admin_actions
    FOR EACH ROW
    EXECUTE FUNCTION prevent_admin_action_delete();

-- ============================================================================
-- SECTION 9: CROSS-SYSTEM INVARIANT ENFORCEMENT
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 9.1 INV-2: RELEASED escrow requires COMPLETED task
-- ----------------------------------------------------------------------------
-- Enforced via trigger on escrow state change
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION enforce_released_requires_completed()
RETURNS TRIGGER AS $$
DECLARE
    task_state VARCHAR(20);
BEGIN
    -- Only check when transitioning TO RELEASED
    IF NEW.state = 'RELEASED' AND OLD.state != 'RELEASED' THEN
        SELECT state INTO task_state
        FROM tasks
        WHERE id = NEW.task_id;
        
        IF task_state IS NULL THEN
            RAISE EXCEPTION 'INV-2_VIOLATION: Cannot release escrow % - task not found', NEW.id
                USING ERRCODE = 'HX201';
        END IF;
        
        IF task_state != 'COMPLETED' THEN
            RAISE EXCEPTION 'INV-2_VIOLATION: Cannot release escrow % - task % is in state % (must be COMPLETED)', 
                NEW.id, NEW.task_id, task_state
                USING ERRCODE = 'HX201';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER escrow_released_requires_completed_task
    BEFORE UPDATE ON escrows
    FOR EACH ROW
    EXECUTE FUNCTION enforce_released_requires_completed();

-- ----------------------------------------------------------------------------
-- 9.2 INV-3: COMPLETED task requires ACCEPTED proof
-- ----------------------------------------------------------------------------
-- Enforced via trigger on task state change
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION enforce_completed_requires_accepted_proof()
RETURNS TRIGGER AS $$
DECLARE
    proof_count INTEGER;
    accepted_proof_count INTEGER;
BEGIN
    -- Only check when transitioning TO COMPLETED
    IF NEW.state = 'COMPLETED' AND OLD.state != 'COMPLETED' THEN
        -- Check if task requires proof
        IF NEW.requires_proof = TRUE THEN
            SELECT COUNT(*), COUNT(*) FILTER (WHERE state = 'ACCEPTED')
            INTO proof_count, accepted_proof_count
            FROM proofs
            WHERE task_id = NEW.id;
            
            IF proof_count = 0 THEN
                RAISE EXCEPTION 'INV-3_VIOLATION: Cannot complete task % - no proof submitted', NEW.id
                    USING ERRCODE = 'HX301';
            END IF;
            
            IF accepted_proof_count = 0 THEN
                RAISE EXCEPTION 'INV-3_VIOLATION: Cannot complete task % - no accepted proof (found % proofs, 0 accepted)', 
                    NEW.id, proof_count
                    USING ERRCODE = 'HX301';
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_completed_requires_accepted_proof
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION enforce_completed_requires_accepted_proof();

-- ============================================================================
-- SECTION 10: UTILITY FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 10.1 Update timestamp trigger
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER escrows_updated_at BEFORE UPDATE ON escrows FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER proofs_updated_at BEFORE UPDATE ON proofs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER disputes_updated_at BEFORE UPDATE ON disputes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER ai_jobs_updated_at BEFORE UPDATE ON ai_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER evidence_updated_at BEFORE UPDATE ON evidence FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ----------------------------------------------------------------------------
-- 10.2 XP Level Calculation Function
-- ----------------------------------------------------------------------------
-- Authority: PRODUCT_SPEC §5.1
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_level(xp_total INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE
        WHEN xp_total >= 18500 THEN 10  -- Mythic
        WHEN xp_total >= 10500 THEN 9   -- Legend
        WHEN xp_total >= 7000 THEN 8    -- Elite
        WHEN xp_total >= 4500 THEN 7    -- Master
        WHEN xp_total >= 2700 THEN 6    -- Veteran
        WHEN xp_total >= 1500 THEN 5    -- Expert
        WHEN xp_total >= 700 THEN 4     -- Pro
        WHEN xp_total >= 300 THEN 3     -- Hustler
        WHEN xp_total >= 100 THEN 2     -- Apprentice
        ELSE 1                          -- Rookie
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- 10.3 XP Decay Factor Calculation (PRODUCT_SPEC §5.2)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_xp_decay(total_xp INTEGER)
RETURNS NUMERIC(6,4) AS $$
BEGIN
    -- effectiveXP = baseXP × (1 / (1 + log₁₀(1 + totalXP / 1000)))
    RETURN ROUND(1.0 / (1.0 + LOG(1.0 + total_xp / 1000.0)), 4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- 10.4 Streak Multiplier Calculation (PRODUCT_SPEC §5.4)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_streak_multiplier(streak_days INTEGER)
RETURNS NUMERIC(3,2) AS $$
BEGIN
    RETURN CASE
        WHEN streak_days >= 30 THEN 1.50  -- Cap
        WHEN streak_days >= 14 THEN 1.30
        WHEN streak_days >= 7 THEN 1.20
        WHEN streak_days >= 3 THEN 1.10
        ELSE 1.00
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- SECTION 10.5: LIVE MODE TABLES (PRODUCT_SPEC §3.5, §3.6)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 10.5.1 LIVE SESSIONS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE live_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    end_reason VARCHAR(20) CHECK (end_reason IN ('MANUAL', 'COOLDOWN', 'FATIGUE', 'FORCED')),
    
    tasks_accepted INTEGER DEFAULT 0,
    tasks_declined INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    earnings_cents INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_live_sessions_user ON live_sessions(user_id);
CREATE INDEX idx_live_sessions_started ON live_sessions(started_at);

-- ----------------------------------------------------------------------------
-- 10.5.2 LIVE BROADCASTS TABLE
-- ----------------------------------------------------------------------------

CREATE TABLE live_broadcasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expired_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    accepted_by UUID REFERENCES users(id),
    
    initial_radius_miles NUMERIC(4,1) NOT NULL,
    final_radius_miles NUMERIC(4,1),
    hustlers_notified INTEGER DEFAULT 0,
    hustlers_viewed INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_live_broadcasts_task ON live_broadcasts(task_id);
CREATE INDEX idx_live_broadcasts_active ON live_broadcasts(started_at) 
    WHERE expired_at IS NULL AND accepted_at IS NULL;

-- ============================================================================
-- SECTION 10.6: LIVE MODE TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LIVE-1: Live tasks require FUNDED escrow before broadcast
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION live_task_requires_funded_escrow()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.mode = 'LIVE' AND NEW.live_broadcast_started_at IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM escrows 
            WHERE task_id = NEW.id AND state = 'FUNDED'
        ) THEN
            RAISE EXCEPTION 'LIVE-1_VIOLATION: Cannot broadcast live task without funded escrow. Task: %', NEW.id
                USING ERRCODE = 'HX901';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER live_task_escrow_check
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    WHEN (NEW.live_broadcast_started_at IS DISTINCT FROM OLD.live_broadcast_started_at)
    EXECUTE FUNCTION live_task_requires_funded_escrow();

-- ----------------------------------------------------------------------------
-- LIVE-2: Live tasks require elevated price floor ($15.00 = 1500 cents)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION live_task_price_floor()
RETURNS TRIGGER AS $$
DECLARE
    live_minimum_cents INTEGER := 1500; -- $15.00
BEGIN
    IF NEW.mode = 'LIVE' AND NEW.price < live_minimum_cents THEN
        RAISE EXCEPTION 'LIVE-2_VIOLATION: Live tasks require minimum price of $15.00. Task: %, Price: %', 
            NEW.id, NEW.price
            USING ERRCODE = 'HX902';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER live_task_price_check
    BEFORE INSERT OR UPDATE ON tasks
    FOR EACH ROW
    WHEN (NEW.mode = 'LIVE')
    EXECUTE FUNCTION live_task_price_floor();

-- ============================================================================
-- SECTION 11: ERROR CODE REFERENCE
-- ============================================================================
-- 
-- HX001: Task terminal state violation
-- HX002: Escrow terminal state violation
-- HX004: INV-4 violation (escrow amount immutability)
-- HX101: INV-1 violation (XP requires RELEASED escrow)
-- HX102: XP ledger immutability violation
-- HX201: INV-2 violation (RELEASED requires COMPLETED task)
-- HX301: INV-3 violation (COMPLETED requires ACCEPTED proof)
-- HX401: INV-BADGE-2 violation (badge delete attempt)
-- HX801: Admin action audit immutability
-- HX901: LIVE-1 violation (live broadcast without funded escrow)
-- HX902: LIVE-2 violation (live task below price floor)
-- HX903: Hustler not in ACTIVE live mode state
-- HX904: Live Mode toggle cooldown violation
-- HX905: Live Mode banned
-- 
-- ============================================================================

-- ============================================================================
-- END OF CONSTITUTIONAL SCHEMA v1.1.0
-- ============================================================================
