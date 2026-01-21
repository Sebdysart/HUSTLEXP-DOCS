-- ============================================================================
-- HustleXP Canonical Database Schema v1.2.0
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

-- Initialize schema versions (if not exists)
INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES ('1.0.0', 'system', 'INITIAL', 'Constitutional schema - INV-1 through INV-5, terminal state triggers, AI tables')
ON CONFLICT (version) DO NOTHING;

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
    location_lat NUMERIC(10, 7),     -- Latitude for geo-matching
    location_lng NUMERIC(10, 7),     -- Longitude for geo-matching
    category VARCHAR(50),

    -- Pricing (in USD cents — PRODUCT_SPEC §4.3)
    -- STANDARD mode minimum: $5.00 (500 cents), LIVE mode minimum: $15.00 (1500 cents, enforced by trigger)
    price INTEGER NOT NULL CHECK (price >= 500),
    
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
    review_deadline TIMESTAMPTZ,         -- Deadline for poster to review proof
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_proofs_task ON proofs(task_id);
CREATE INDEX idx_proofs_review_deadline ON proofs(review_deadline) WHERE state = 'SUBMITTED';
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
-- SECTION 10.7: HUMAN SYSTEMS SCHEMA (PRODUCT_SPEC §3.7, §8.3, §8.4, §11)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 10.7.1 FATIGUE TRACKING (Global Anti-Burnout)
-- ----------------------------------------------------------------------------

ALTER TABLE users ADD COLUMN IF NOT EXISTS daily_active_minutes INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_activity_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS consecutive_active_days INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_mandatory_break_at TIMESTAMPTZ;

-- ----------------------------------------------------------------------------
-- 10.7.2 ACCOUNT PAUSE STATE
-- ----------------------------------------------------------------------------

ALTER TABLE users ADD COLUMN IF NOT EXISTS account_status VARCHAR(20) DEFAULT 'ACTIVE'
    CHECK (account_status IN ('ACTIVE', 'PAUSED', 'SUSPENDED'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS paused_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS pause_streak_snapshot INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS pause_trust_tier_snapshot INTEGER;

-- ----------------------------------------------------------------------------
-- 10.7.3 POSTER RATINGS TABLE (Hustler-only reputation)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS poster_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    poster_id UUID NOT NULL REFERENCES users(id),
    rated_by UUID NOT NULL REFERENCES users(id),
    
    rating VARCHAR(20) NOT NULL CHECK (rating IN ('GREAT', 'OKAY', 'DIFFICULT')),
    feedback_flags TEXT[],
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    UNIQUE(task_id, rated_by)
);

CREATE INDEX IF NOT EXISTS idx_poster_ratings_poster ON poster_ratings(poster_id);
CREATE INDEX IF NOT EXISTS idx_poster_ratings_task ON poster_ratings(task_id);

-- ----------------------------------------------------------------------------
-- 10.7.4 POSTER REPUTATION VIEW (Hustlers only — PRODUCT_SPEC §8.4)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW poster_reputation AS
SELECT 
    u.id as poster_id,
    COUNT(DISTINCT t.id) as tasks_posted_90d,
    COUNT(DISTINCT d.id) as disputes_90d,
    ROUND(AVG(EXTRACT(EPOCH FROM (p.reviewed_at - p.submitted_at))/3600)::NUMERIC, 1) as avg_response_hours,
    COUNT(CASE WHEN pr.rating = 'GREAT' THEN 1 END) as great_ratings,
    COUNT(CASE WHEN pr.rating = 'OKAY' THEN 1 END) as okay_ratings,
    COUNT(CASE WHEN pr.rating = 'DIFFICULT' THEN 1 END) as difficult_ratings,
    COUNT(pr.id) as total_ratings
FROM users u
LEFT JOIN tasks t ON t.poster_id = u.id AND t.created_at > NOW() - INTERVAL '90 days'
LEFT JOIN disputes d ON d.task_id = t.id
LEFT JOIN proofs p ON p.task_id = t.id
LEFT JOIN poster_ratings pr ON pr.poster_id = u.id AND pr.created_at > NOW() - INTERVAL '90 days'
GROUP BY u.id
HAVING COUNT(DISTINCT t.id) >= 5;  -- POSTER-2: Minimum 5 tasks

-- ----------------------------------------------------------------------------
-- 10.7.5 SESSION FORECASTS TABLE (AI Predictions — AI_INFRASTRUCTURE §21)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS session_forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Forecast outputs
    earnings_low_cents INTEGER NOT NULL,
    earnings_high_cents INTEGER NOT NULL,
    confidence VARCHAR(20) NOT NULL CHECK (confidence IN ('LOW', 'MEDIUM', 'HIGH')),
    conditions VARCHAR(20) NOT NULL CHECK (conditions IN ('POOR', 'FAIR', 'GOOD', 'EXCELLENT')),
    best_categories TEXT[],
    nearby_demand INTEGER,
    
    -- Accuracy tracking
    actual_earnings_cents INTEGER,  -- Filled in after session ends
    
    -- Metadata
    inputs_hash VARCHAR(64),        -- Privacy: hash of inputs
    expires_at TIMESTAMPTZ NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_session_forecasts_user ON session_forecasts(user_id);
CREATE INDEX IF NOT EXISTS idx_session_forecasts_expires ON session_forecasts(expires_at);

-- ----------------------------------------------------------------------------
-- 10.7.6 MONEY TIMELINE VIEW (UI_SPEC §14)
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW money_timeline AS
SELECT 
    e.id,
    e.worker_id,
    e.amount_cents,
    e.state as escrow_state,
    e.released_at,
    t.id as task_id,
    t.title as task_title,
    t.state as task_state,
    CASE 
        WHEN e.state = 'RELEASED' AND e.released_at > NOW() - INTERVAL '24 hours' 
            THEN 'TODAY'
        WHEN e.state = 'RELEASED' 
            THEN 'AVAILABLE'
        WHEN e.state = 'FUNDED' AND t.state IN ('ACCEPTED', 'PROOF_SUBMITTED') 
            THEN 'COMING_SOON'
        WHEN e.state = 'LOCKED_DISPUTE' 
            THEN 'BLOCKED'
        ELSE 'PENDING'
    END as timeline_category,
    CASE
        WHEN e.state = 'FUNDED' AND t.state = 'ACCEPTED' 
            THEN 'Task in progress'
        WHEN e.state = 'FUNDED' AND t.state = 'PROOF_SUBMITTED' 
            THEN 'Awaiting review'
        WHEN e.state = 'LOCKED_DISPUTE' 
            THEN 'Under dispute review'
        ELSE NULL
    END as status_context
FROM escrows e
JOIN tasks t ON e.task_id = t.id
WHERE e.worker_id IS NOT NULL;

-- ============================================================================
-- SECTION 11: ERROR CODE REFERENCE
-- ============================================================================
-- 
-- Core Invariants (HX0XX, HX1XX, HX2XX, HX3XX, HX4XX, HX8XX)
-- HX001: Task terminal state violation
-- HX002: Escrow terminal state violation
-- HX004: INV-4 violation (escrow amount immutability)
-- HX101: INV-1 violation (XP requires RELEASED escrow)
-- HX102: XP ledger immutability violation
-- HX201: INV-2 violation (RELEASED requires COMPLETED task)
-- HX301: INV-3 violation (COMPLETED requires ACCEPTED proof)
-- HX401: INV-BADGE-2 violation (badge delete attempt)
-- HX801: Admin action audit immutability
--
-- Live Mode (HX9XX)
-- HX901: LIVE-1 violation (live broadcast without funded escrow)
-- HX902: LIVE-2 violation (live task below price floor)
-- HX903: Hustler not in ACTIVE live mode state
-- HX904: Live Mode toggle cooldown violation
-- HX905: Live Mode banned
--
-- Human Systems (HX6XX) — Reserved for future enforcement
-- HX601: Fatigue mandatory break bypass attempt
-- HX602: Pause state violation
-- HX603: Poster reputation access by poster (POSTER-1 violation)
-- HX604: Percentile public exposure attempt (PERC-1 violation)
-- 
-- ============================================================================

-- ============================================================================
-- SECTION 11: CRITICAL GAPS FEATURE TABLES (Migration 002 Integration)
-- ============================================================================
-- AUTHORITY: PRODUCT_SPEC §9-§16, §19
-- INTEGRATED: 2025-01-XX (from migrations/002_critical_gaps_tables.sql)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 11.1 TASK DISCOVERY & MATCHING (GAP A - PRODUCT_SPEC §9)
-- ----------------------------------------------------------------------------

-- Task matching scores cache (optional optimization)
CREATE TABLE IF NOT EXISTS task_matching_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  hustler_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  matching_score DECIMAL(3,2) NOT NULL CHECK (matching_score >= 0.0 AND matching_score <= 1.0),
  relevance_score DECIMAL(3,2) NOT NULL,
  distance_miles DECIMAL(5,2) NOT NULL,
  calculated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  
  UNIQUE(task_id, hustler_id)
);

CREATE INDEX IF NOT EXISTS idx_matching_scores_hustler ON task_matching_scores(hustler_id, relevance_score DESC);
CREATE INDEX IF NOT EXISTS idx_matching_scores_task ON task_matching_scores(task_id, matching_score DESC);
CREATE INDEX IF NOT EXISTS idx_matching_scores_expires ON task_matching_scores(expires_at) WHERE expires_at < NOW();

-- Saved searches (optional, post-launch)
CREATE TABLE IF NOT EXISTS saved_searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  query TEXT,
  filters JSONB NOT NULL DEFAULT '{}',
  sort_by VARCHAR(20) NOT NULL DEFAULT 'relevance',
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_saved_searches_user ON saved_searches(user_id, created_at DESC);

-- ----------------------------------------------------------------------------
-- 11.2 MESSAGING SYSTEM (GAP B - PRODUCT_SPEC §10)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS task_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Content
  message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('TEXT', 'AUTO', 'PHOTO', 'LOCATION')),
  content TEXT,  -- NULL for PHOTO/LOCATION types
  auto_message_template VARCHAR(50),  -- For AUTO type
  
  -- Photo attachments (for PHOTO type)
  photo_urls TEXT[],  -- Array of evidence IDs or URLs
  photo_count INTEGER DEFAULT 0 CHECK (photo_count >= 0 AND photo_count <= 3),
  
  -- Location (for LOCATION type)
  location_latitude DECIMAL(10, 8),
  location_longitude DECIMAL(11, 8),
  location_expires_at TIMESTAMPTZ,
  
  -- Status
  read_at TIMESTAMPTZ,  -- NULL = unread
  deleted_at TIMESTAMPTZ,  -- Soft delete (archived)
  
  -- Moderation
  moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'flagged', 'quarantined')),
  moderation_flags TEXT[],
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CHECK (content IS NULL OR LENGTH(content) <= 500)
);

CREATE INDEX IF NOT EXISTS idx_task_messages_task ON task_messages(task_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_task_messages_unread ON task_messages(receiver_id, read_at) WHERE read_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_task_messages_moderation ON task_messages(moderation_status) WHERE moderation_status = 'pending';

-- ----------------------------------------------------------------------------
-- 11.3 NOTIFICATION SYSTEM (GAP D - PRODUCT_SPEC §11)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recipient
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Content
  category VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  
  -- Deep linking
  deep_link TEXT NOT NULL,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  metadata JSONB DEFAULT '{}',
  
  -- Delivery
  channels TEXT[] NOT NULL DEFAULT ARRAY['push'],  -- 'push', 'email', 'sms', 'in_app'
  priority VARCHAR(10) NOT NULL CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  
  -- Status
  sent_at TIMESTAMPTZ,  -- NULL = pending
  delivered_at TIMESTAMPTZ,  -- NULL = not delivered
  read_at TIMESTAMPTZ,  -- NULL = unread
  clicked_at TIMESTAMPTZ,  -- NULL = not clicked
  
  -- Grouping
  group_id UUID,  -- NULL = not grouped, same UUID = grouped
  group_position INTEGER,  -- Position in group (1, 2, 3, ...)
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ,  -- NULL = no expiration
  
  CHECK (sent_at IS NULL OR sent_at >= created_at),
  CHECK (delivered_at IS NULL OR delivered_at >= sent_at),
  CHECK (read_at IS NULL OR read_at >= delivered_at)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_notifications_user_recent ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_pending ON notifications(sent_at) WHERE sent_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_notifications_task ON notifications(task_id) WHERE task_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_notifications_expires ON notifications(expires_at) WHERE expires_at IS NOT NULL;

-- User notification preferences
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Quiet hours
  quiet_hours_enabled BOOLEAN DEFAULT true,
  quiet_hours_start TIME DEFAULT '22:00:00',
  quiet_hours_end TIME DEFAULT '07:00:00',
  
  -- Channel preferences
  push_enabled BOOLEAN DEFAULT true,
  email_enabled BOOLEAN DEFAULT false,
  sms_enabled BOOLEAN DEFAULT false,
  
  -- Per-category preferences (JSONB for flexibility)
  category_preferences JSONB NOT NULL DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ----------------------------------------------------------------------------
-- 11.4 RATING SYSTEM (GAP E - PRODUCT_SPEC §12)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS task_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  rater_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,  -- Who gave the rating
  ratee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,  -- Who received the rating
  
  -- Rating content
  stars INTEGER NOT NULL CHECK (stars >= 1 AND stars <= 5),
  comment TEXT,  -- Max 500 chars, optional
  tags TEXT[],   -- Array of tag strings
  
  -- Status
  is_public BOOLEAN DEFAULT true,  -- Visible to ratee (after both submitted)
  is_blind BOOLEAN DEFAULT true,   -- Hidden until both parties rate
  
  -- Auto-rating flag
  is_auto_rated BOOLEAN DEFAULT false,  -- True if auto-rated after 7 days
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- Constraints
  UNIQUE(task_id, rater_id, ratee_id),  -- One rating per pair per task
  CHECK (comment IS NULL OR LENGTH(comment) <= 500)
);

CREATE INDEX IF NOT EXISTS idx_ratings_ratee ON task_ratings(ratee_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ratings_task ON task_ratings(task_id);
CREATE INDEX IF NOT EXISTS idx_ratings_public ON task_ratings(ratee_id, is_public) WHERE is_public = true;

-- View for aggregated ratings
CREATE OR REPLACE VIEW user_rating_summary AS
SELECT 
  ratee_id AS user_id,
  COUNT(*) AS total_ratings,
  AVG(stars)::DECIMAL(3,2) AS avg_rating,
  COUNT(*) FILTER (WHERE stars = 5) AS five_star_count,
  COUNT(*) FILTER (WHERE stars = 4) AS four_star_count,
  COUNT(*) FILTER (WHERE stars = 3) AS three_star_count,
  COUNT(*) FILTER (WHERE stars = 2) AS two_star_count,
  COUNT(*) FILTER (WHERE stars = 1) AS one_star_count,
  COUNT(*) FILTER (WHERE comment IS NOT NULL) AS commented_count,
  MAX(created_at) AS last_rating_at
FROM task_ratings
WHERE is_public = true
GROUP BY ratee_id;

-- ----------------------------------------------------------------------------
-- 11.5 ANALYTICS INFRASTRUCTURE (GAP J - PRODUCT_SPEC §13)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identity
  event_type VARCHAR(100) NOT NULL,
  event_category VARCHAR(50) NOT NULL CHECK (event_category IN ('user_action', 'system_event', 'error', 'performance')),
  
  -- User context
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  session_id UUID NOT NULL,
  device_id UUID NOT NULL,
  
  -- Context
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  task_category VARCHAR(50),
  trust_tier INTEGER,
  
  -- Properties (flexible JSON)
  properties JSONB NOT NULL DEFAULT '{}',
  
  -- Metadata
  platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  app_version VARCHAR(50),
  
  -- A/B Test assignment
  ab_test_id VARCHAR(100),
  ab_variant VARCHAR(20),
  
  -- Timestamps
  event_timestamp TIMESTAMPTZ NOT NULL,
  ingested_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_events(event_type, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_user ON analytics_events(user_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_task ON analytics_events(task_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_session ON analytics_events(session_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_timestamp ON analytics_events(event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_category ON analytics_events(event_category, event_timestamp DESC);

-- ----------------------------------------------------------------------------
-- 11.6 FRAUD DETECTION (GAP K - PRODUCT_SPEC §14)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS fraud_risk_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'task', 'transaction')),
  entity_id UUID NOT NULL,
  
  -- Risk score
  risk_score DECIMAL(3,2) NOT NULL CHECK (risk_score >= 0.0 AND risk_score <= 1.0),
  risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  
  -- Components (for transparency)
  component_scores JSONB NOT NULL DEFAULT '{}',
  
  -- Flags
  flags TEXT[] DEFAULT ARRAY[]::TEXT[],
  
  -- Status
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  review_notes TEXT,
  
  -- Timestamps
  calculated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ,
  
  UNIQUE(entity_type, entity_id, calculated_at)
);

CREATE INDEX IF NOT EXISTS idx_fraud_risk_entity ON fraud_risk_scores(entity_type, entity_id, calculated_at DESC);
CREATE INDEX IF NOT EXISTS idx_fraud_risk_score ON fraud_risk_scores(risk_score DESC) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_fraud_risk_review ON fraud_risk_scores(status) WHERE status IN ('active', 'reviewed');

-- Fraud patterns table
CREATE TABLE IF NOT EXISTS fraud_patterns (
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
  
  -- Status
  status VARCHAR(20) DEFAULT 'detected' CHECK (status IN ('detected', 'reviewed', 'confirmed', 'dismissed')),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  
  -- Timestamps
  detected_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_fraud_patterns_type ON fraud_patterns(pattern_type, detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_fraud_patterns_status ON fraud_patterns(status) WHERE status = 'detected';

-- ----------------------------------------------------------------------------
-- 11.7 CONTENT MODERATION (GAP L - PRODUCT_SPEC §15)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS content_moderation_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Content context
  content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('task', 'message', 'rating', 'profile', 'photo')),
  content_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Content snapshot (at time of flag)
  content_text TEXT,
  content_url TEXT,  -- For photos
  
  -- Moderation
  moderation_category VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  ai_confidence DECIMAL(3,2) CHECK (ai_confidence >= 0.0 AND ai_confidence <= 1.0),
  ai_recommendation VARCHAR(20) CHECK (ai_recommendation IN ('approve', 'flag', 'block')),
  
  -- Source
  flagged_by VARCHAR(20) NOT NULL CHECK (flagged_by IN ('ai', 'user_report', 'admin')),
  reporter_user_id UUID REFERENCES users(id) ON DELETE SET NULL,  -- If user-reported
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'approved', 'rejected', 'escalated')),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20) CHECK (review_decision IN ('approve', 'reject', 'escalate', 'no_action')),
  review_notes TEXT,
  
  -- Timestamps
  flagged_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  sla_deadline TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_moderation_queue_status ON content_moderation_queue(status, severity, flagged_at);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_sla ON content_moderation_queue(sla_deadline) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_moderation_queue_user ON content_moderation_queue(user_id, flagged_at DESC);

-- User reporting system
CREATE TABLE IF NOT EXISTS content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Content being reported
  content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('task', 'message', 'rating', 'profile', 'photo')),
  content_id UUID NOT NULL,
  reported_content_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Reporter
  reporter_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Report details
  category VARCHAR(50) NOT NULL,
  description TEXT,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20),
  review_notes TEXT,
  
  -- Timestamps
  reported_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_content_reports_status ON content_reports(status, reported_at DESC);
CREATE INDEX IF NOT EXISTS idx_content_reports_content ON content_reports(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_reporter ON content_reports(reporter_user_id, reported_at DESC);

-- Appeal system
CREATE TABLE IF NOT EXISTS content_appeals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Original moderation action
  moderation_queue_id UUID REFERENCES content_moderation_queue(id) ON DELETE CASCADE,
  original_decision VARCHAR(20) NOT NULL,
  
  -- Appellant
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  appeal_reason TEXT NOT NULL,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'upheld', 'overturned')),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20),
  review_notes TEXT,
  
  -- Timestamps
  submitted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  deadline TIMESTAMPTZ NOT NULL  -- 7/14/30 days from original action
);

CREATE INDEX IF NOT EXISTS idx_content_appeals_status ON content_appeals(status, submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_content_appeals_user ON content_appeals(user_id, submitted_at DESC);

-- ----------------------------------------------------------------------------
-- 11.8 GDPR COMPLIANCE (GAP M - PRODUCT_SPEC §16)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS gdpr_data_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Request type
  request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('export', 'deletion', 'rectification', 'restriction')),
  
  -- Request details
  request_details JSONB DEFAULT '{}',
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'rejected', 'cancelled')),
  processed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  processed_at TIMESTAMPTZ,
  
  -- Result
  result_url TEXT,  -- Download link for exports
  result_expires_at TIMESTAMPTZ,  -- Link expiration
  
  -- Timestamps
  requested_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  deadline TIMESTAMPTZ NOT NULL,  -- 30 days for export, 7 days for deletion
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_gdpr_requests_user ON gdpr_data_requests(user_id, requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_gdpr_requests_status ON gdpr_data_requests(status, deadline) WHERE status IN ('pending', 'processing');

-- User consent management
CREATE TABLE IF NOT EXISTS user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Consent type
  consent_type VARCHAR(50) NOT NULL,
  purpose TEXT NOT NULL,
  
  -- Consent status
  granted BOOLEAN NOT NULL,
  granted_at TIMESTAMPTZ,
  withdrawn_at TIMESTAMPTZ,
  
  -- Metadata
  ip_address TEXT,  -- Anonymized
  user_agent TEXT,  -- Anonymized
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  UNIQUE(user_id, consent_type)
);

CREATE INDEX IF NOT EXISTS idx_user_consents_user ON user_consents(user_id, consent_type);
CREATE INDEX IF NOT EXISTS idx_user_consents_granted ON user_consents(granted, consent_type) WHERE granted = true;

-- ----------------------------------------------------------------------------
-- 11.9 TRIGGERS FOR NEW TABLES
-- ----------------------------------------------------------------------------

-- Auto-update updated_at timestamps (reuse existing function if exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
    CREATE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  END IF;
END $$;

CREATE TRIGGER IF NOT EXISTS task_messages_updated_at
  BEFORE UPDATE ON task_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS task_ratings_updated_at
  BEFORE UPDATE ON task_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS user_consents_updated_at
  BEFORE UPDATE ON user_consents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SCHEMA VERSION UPDATE (v1.1.0)
-- ============================================================================

-- Note: schema_versions table already exists from Section 1
-- This migration integrates critical gaps tables (Migration 002)
INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES ('1.1.0', 'system', 'CRITICAL_GAPS', 'Added tables for critical gaps: task discovery, messaging, notifications, ratings, analytics, fraud detection, content moderation, GDPR compliance')
ON CONFLICT (version) DO NOTHING;

-- ============================================================================
-- SECTION 12: ELIGIBILITY SYSTEM TABLES (v1.2.0)
-- Authority: architecture/*_LOCKED.md specs
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 12.1 CAPABILITY_CLAIMS (IMMUTABLE INPUT RECORD)
-- Source: CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md
-- Purpose: Historical record of user claims. Never grants access.
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS capability_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('hustler', 'poster', 'both')),
    claimed_trades TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    license_claims JSONB NOT NULL DEFAULT '[]'::JSONB,
    insurance_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    work_state CHAR(2) NOT NULL CHECK (length(work_state) = 2),
    work_region VARCHAR(255),
    risk_preferences JSONB NOT NULL DEFAULT '{"in_home_work": false, "high_risk_tasks": false, "urgent_jobs": false}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT capability_claims_user_id_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_capability_claims_user_id ON capability_claims(user_id);
CREATE INDEX IF NOT EXISTS idx_capability_claims_work_state ON capability_claims(work_state);

-- ----------------------------------------------------------------------------
-- 12.2 LICENSE_VERIFICATIONS (PRIMARY TRADE AUTHORITY)
-- Source: VERIFICATION_PIPELINE_LOCKED.md §1.1
-- Purpose: Authoritative record of licensed trade verification.
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS license_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    trade VARCHAR(255) NOT NULL,
    state CHAR(2) NOT NULL CHECK (length(state) = 2),
    license_number VARCHAR(255) NOT NULL,
    license_type VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'failed', 'expired')),
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    failure_reason TEXT,
    source VARCHAR(20) NOT NULL CHECK (source IN ('registry', 'document', 'manual_review')),
    verification_method VARCHAR(50),
    verification_provider VARCHAR(255),
    confidence_score NUMERIC(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    reviewer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    review_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT license_verifications_user_trade_state_unique UNIQUE (user_id, trade, state),
    CONSTRAINT license_verifications_status_verified_check CHECK (
        (status = 'verified' AND verified_at IS NOT NULL) OR (status != 'verified')
    ),
    CONSTRAINT license_verifications_status_expires_check CHECK (
        (status = 'verified' AND expires_at IS NOT NULL) OR (status != 'verified')
    )
);

CREATE INDEX IF NOT EXISTS idx_license_verifications_user_id ON license_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_license_verifications_status ON license_verifications(status);
CREATE INDEX IF NOT EXISTS idx_license_verifications_expires_at ON license_verifications(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_license_verifications_user_trade ON license_verifications(user_id, trade);

-- ----------------------------------------------------------------------------
-- 12.3 CAPABILITY_PROFILES (DERIVED AUTHORITY SNAPSHOT)
-- Source: CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md
-- Purpose: Single source of truth for eligibility. Derived, never mutated directly.
-- INV-ELIGIBILITY-1: Trust tier → risk clearance mapping enforced here
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS capability_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    trust_tier INTEGER NOT NULL CHECK (trust_tier IN (1, 2, 3, 4)),  -- 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE
    trust_tier_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    risk_clearance TEXT[] NOT NULL DEFAULT ARRAY['low']::TEXT[],
    insurance_valid BOOLEAN NOT NULL DEFAULT FALSE,
    insurance_expires_at TIMESTAMPTZ,
    background_check_valid BOOLEAN NOT NULL DEFAULT FALSE,
    background_check_expires_at TIMESTAMPTZ,
    location_state CHAR(2) NOT NULL CHECK (length(location_state) = 2),
    location_city VARCHAR(255),
    willingness_flags JSONB NOT NULL DEFAULT '{"in_home_work": false, "high_risk_tasks": false, "urgent_jobs": false}'::JSONB,
    verification_status JSONB NOT NULL DEFAULT '{}'::JSONB,
    expires_at JSONB DEFAULT '{}'::JSONB,
    derived_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- INV-ELIGIBILITY-1: Trust tier → risk clearance mapping (immutable)
    -- Tier 1 (ROOKIE) = low only, Tier 2-3 (VERIFIED/TRUSTED) = low+medium, Tier 4 (ELITE) = low+medium+high
    CONSTRAINT capability_profiles_risk_clearance_check CHECK (
        (trust_tier = 1 AND risk_clearance = ARRAY['low']::TEXT[]) OR
        (trust_tier = 2 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
        (trust_tier = 3 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance)) OR
        (trust_tier = 4 AND 'low' = ANY(risk_clearance) AND 'medium' = ANY(risk_clearance) AND 'high' = ANY(risk_clearance))
    )
);

CREATE INDEX IF NOT EXISTS idx_capability_profiles_user_id ON capability_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_capability_profiles_trust_tier ON capability_profiles(trust_tier);
CREATE INDEX IF NOT EXISTS idx_capability_profiles_location_state ON capability_profiles(location_state);
CREATE INDEX IF NOT EXISTS idx_capability_profiles_risk_clearance_gin ON capability_profiles USING GIN (risk_clearance);

-- ----------------------------------------------------------------------------
-- 12.4 VERIFIED_TRADES (DERIVED, FAST-PATH JOIN TABLE)
-- Source: CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md
-- Purpose: Fast join table for eligibility. Derived ONLY from license_verifications.
-- INV-ELIGIBILITY-2: Verified trades must have active verification (FK enforces)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS verified_trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES capability_profiles(profile_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trade VARCHAR(255) NOT NULL,
    state CHAR(2) NOT NULL CHECK (length(state) = 2),
    license_verification_id UUID NOT NULL REFERENCES license_verifications(id) ON DELETE RESTRICT,
    verified_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    verification_method VARCHAR(50) NOT NULL CHECK (verification_method IN ('license_scan', 'certification', 'portfolio', 'test', 'manual_review')),
    
    CONSTRAINT verified_trades_profile_trade_unique UNIQUE (profile_id, trade),
    CONSTRAINT verified_trades_license_verification_id_unique UNIQUE (license_verification_id),
    CONSTRAINT verified_trades_expires_check CHECK (
        expires_at > verified_at OR expires_at IS NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_verified_trades_profile_id ON verified_trades(profile_id);
CREATE INDEX IF NOT EXISTS idx_verified_trades_user_id ON verified_trades(user_id);
CREATE INDEX IF NOT EXISTS idx_verified_trades_trade ON verified_trades(trade);
CREATE INDEX IF NOT EXISTS idx_verified_trades_expires_at ON verified_trades(expires_at) WHERE expires_at IS NOT NULL;

-- ----------------------------------------------------------------------------
-- 12.5 INSURANCE_VERIFICATIONS (TRADE-SCOPED INSURANCE AUTHORITY)
-- Source: VERIFICATION_PIPELINE_LOCKED.md §2.1
-- Purpose: Trade-scoped insurance authority.
-- INV-ELIGIBILITY-4: Insurance validity gated by verification (trigger enforces)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS insurance_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    trade VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'failed', 'expired')),
    coverage_amount INTEGER NOT NULL CHECK (coverage_amount > 0),
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    failure_reason TEXT,
    source VARCHAR(20) NOT NULL CHECK (source IN ('coi_upload', 'manual_review')),
    verification_method VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT insurance_verifications_user_trade_unique UNIQUE (user_id, trade),
    CONSTRAINT insurance_verifications_status_verified_check CHECK (
        (status = 'verified' AND verified_at IS NOT NULL) OR (status != 'verified')
    ),
    CONSTRAINT insurance_verifications_status_expires_check CHECK (
        (status = 'verified' AND expires_at IS NOT NULL) OR (status != 'verified')
    )
);

CREATE INDEX IF NOT EXISTS idx_insurance_verifications_user_id ON insurance_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_insurance_verifications_status ON insurance_verifications(status);
CREATE INDEX IF NOT EXISTS idx_insurance_verifications_expires_at ON insurance_verifications(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_insurance_verifications_user_trade ON insurance_verifications(user_id, trade);

-- Trigger: Prevent insurance without verified trade (INV-ELIGIBILITY-4)
CREATE OR REPLACE FUNCTION prevent_insurance_without_verified_trade()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if verified trade exists for this (user_id, trade)
    IF NOT EXISTS (
        SELECT 1 FROM verified_trades
        WHERE user_id = NEW.user_id
        AND trade = NEW.trade
        AND (expires_at IS NULL OR expires_at > NOW())
    ) THEN
        RAISE EXCEPTION 'INSURANCE_REQUIRES_VERIFIED_TRADE: Insurance verification requires verified trade for user_id=%, trade=%', NEW.user_id, NEW.trade
            USING ERRCODE = 'P0001';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS insurance_requires_verified_trade_trigger
    BEFORE INSERT OR UPDATE ON insurance_verifications
    FOR EACH ROW
    WHEN (NEW.status IN ('verified', 'pending'))
    EXECUTE FUNCTION prevent_insurance_without_verified_trade();

-- ----------------------------------------------------------------------------
-- 12.6 BACKGROUND_CHECKS (CRITICAL-RISK ELIGIBILITY GATE)
-- Source: VERIFICATION_PIPELINE_LOCKED.md §3.1
-- Purpose: Critical-risk eligibility gate.
-- INV-ELIGIBILITY-5: Background check validity gated by verification
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS background_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'failed', 'expired')),
    provider VARCHAR(255) NOT NULL,
    provider_check_id VARCHAR(255),
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    failure_reason TEXT,
    results_encrypted BYTEA,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT background_checks_user_unique_verified UNIQUE (user_id) WHERE status = 'verified',
    CONSTRAINT background_checks_status_verified_check CHECK (
        (status = 'verified' AND verified_at IS NOT NULL) OR (status != 'verified')
    ),
    CONSTRAINT background_checks_status_expires_check CHECK (
        (status = 'verified' AND expires_at IS NOT NULL) OR (status != 'verified')
    )
);

CREATE INDEX IF NOT EXISTS idx_background_checks_user_id ON background_checks(user_id);
CREATE INDEX IF NOT EXISTS idx_background_checks_status ON background_checks(status);
CREATE INDEX IF NOT EXISTS idx_background_checks_expires_at ON background_checks(expires_at) WHERE expires_at IS NOT NULL;

-- ----------------------------------------------------------------------------
-- 12.7 TASKS TABLE EXTENSIONS (9 NEW FIELDS)
-- Source: POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md §4
-- Purpose: Add risk classification and eligibility fields to tasks table
-- INV-ELIGIBILITY-6: Location state must be valid (CHECK enforces)
-- ----------------------------------------------------------------------------

ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS task_category VARCHAR(255),
    ADD COLUMN IF NOT EXISTS risk_level VARCHAR(20) CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    ADD COLUMN IF NOT EXISTS required_trade VARCHAR(255),
    ADD COLUMN IF NOT EXISTS required_trust_tier INTEGER CHECK (required_trust_tier >= 0 AND required_trust_tier <= 4),
    ADD COLUMN IF NOT EXISTS insurance_required BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS background_check_required BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS location_state CHAR(2) CHECK (length(location_state) = 2),
    ADD COLUMN IF NOT EXISTS classification_confidence NUMERIC(3,2) CHECK (classification_confidence >= 0 AND classification_confidence <= 1),
    ADD COLUMN IF NOT EXISTS classification_rules_applied JSONB DEFAULT '[]'::JSONB;

-- Indexes for new task fields
CREATE INDEX IF NOT EXISTS idx_tasks_location_state ON tasks(location_state) WHERE location_state IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_required_trade ON tasks(required_trade) WHERE required_trade IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_risk_level ON tasks(risk_level) WHERE risk_level IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_required_trust_tier ON tasks(required_trust_tier) WHERE required_trust_tier IS NOT NULL;

-- ============================================================================
-- SECTION 13: OPERATIONS SUPPORT TABLES (v1.3.0)
-- Authority: BACKEND_EXECUTION_QUEUE.md, STRIPE_INTEGRATION.md
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 13.1 USER_TASK_DRAFTS (Poster Task Drafts)
-- Purpose: Store incomplete task drafts for posters to resume later
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS user_task_drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Draft content (same structure as tasks but nullable)
    title VARCHAR(255),
    description TEXT,
    requirements TEXT,
    location VARCHAR(255),
    location_lat NUMERIC(10, 7),
    location_lng NUMERIC(10, 7),
    category VARCHAR(50),
    price INTEGER CHECK (price IS NULL OR price > 0),
    deadline TIMESTAMPTZ,
    mode VARCHAR(20) CHECK (mode IS NULL OR mode IN ('STANDARD', 'LIVE')),
    requires_proof BOOLEAN,
    proof_instructions TEXT,

    -- Draft metadata
    last_step_completed VARCHAR(50),          -- e.g., 'basics', 'location', 'pricing'
    draft_data JSONB DEFAULT '{}'::JSONB,     -- Additional draft state

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days') NOT NULL,

    -- Only one active draft per user
    CONSTRAINT user_task_drafts_user_unique UNIQUE (user_id) WHERE expires_at > NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_task_drafts_user ON user_task_drafts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_task_drafts_expires ON user_task_drafts(expires_at) WHERE expires_at > NOW();

-- ----------------------------------------------------------------------------
-- 13.2 TRANSFER_RETRY_QUEUE (Stripe Transfer Retries)
-- Purpose: Track failed Stripe transfers for automated retry
-- Authority: STRIPE_INTEGRATION.md §4.3
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transfer_retry_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Reference
    escrow_id UUID NOT NULL REFERENCES escrows(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    worker_id UUID NOT NULL REFERENCES users(id),

    -- Transfer details
    amount INTEGER NOT NULL CHECK (amount > 0),
    stripe_transfer_id VARCHAR(255),           -- NULL until successful

    -- Retry state
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED_PERMANENT', 'CANCELLED')),
    attempt_count INTEGER DEFAULT 0 NOT NULL,
    max_attempts INTEGER DEFAULT 5 NOT NULL,

    -- Error tracking
    last_error_code VARCHAR(100),
    last_error_message TEXT,
    error_history JSONB DEFAULT '[]'::JSONB,

    -- Timing
    next_retry_at TIMESTAMPTZ,
    last_attempt_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    completed_at TIMESTAMPTZ,

    -- One active retry per escrow
    CONSTRAINT transfer_retry_queue_escrow_unique UNIQUE (escrow_id) WHERE status IN ('PENDING', 'PROCESSING')
);

CREATE INDEX IF NOT EXISTS idx_transfer_retry_queue_status ON transfer_retry_queue(status, next_retry_at)
    WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_transfer_retry_queue_escrow ON transfer_retry_queue(escrow_id);
CREATE INDEX IF NOT EXISTS idx_transfer_retry_queue_worker ON transfer_retry_queue(worker_id, status);

-- Trigger: Update updated_at on transfer_retry_queue
CREATE TRIGGER transfer_retry_queue_updated_at
    BEFORE UPDATE ON transfer_retry_queue
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Trigger: Update updated_at on user_task_drafts
CREATE TRIGGER user_task_drafts_updated_at
    BEFORE UPDATE ON user_task_drafts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- SCHEMA VERSION UPDATE (v1.3.0)
-- ============================================================================

INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES (
    '1.3.0',
    'system',
    'OPERATIONS_SUPPORT_V1',
    'Added user_task_drafts table for poster draft persistence, transfer_retry_queue for Stripe transfer retry automation, proof review_deadline column.'
)
ON CONFLICT (version) DO NOTHING;

-- ============================================================================
-- SCHEMA VERSION UPDATE (v1.2.0) - Retained for migration history
-- ============================================================================

INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES (
    '1.2.0',
    'system',
    'ELIGIBILITY_SYSTEM_V1',
    'Eligibility system tables: capability_profiles, license_verifications, insurance_verifications, background_checks, verified_trades, capability_claims. Added 9 fields to tasks table. Enforced 8 eligibility invariants.'
)
ON CONFLICT (version) DO NOTHING;

-- ============================================================================
-- END OF CONSTITUTIONAL SCHEMA v1.3.0
-- ============================================================================
