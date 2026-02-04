-- ============================================================================
-- Migration 007: 42-Gap Audit Hardening
-- Date: Feb 4, 2026
-- Resolves: ALL 42 gaps from COMPREHENSIVE_APP_BUSINESS_AUDIT.md + DEEP_BUSINESS_LOGIC_AUDIT.md
-- Schema: v1.5.0 → v1.6.0
-- ============================================================================

-- 1. User Safety Columns (GAP-3 Cancellation, GAP-B5 Stale Timeout, GAP-4 Sybil)
ALTER TABLE users ADD COLUMN IF NOT EXISTS cancellation_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS no_show_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_cancellation_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT false;

-- 2. Task Safety Columns (GAP-B3 Rejection Loop, GAP-B5 Stale Timeout, GAP-B4 Max Price)
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS rejection_count INTEGER DEFAULT 0;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS acceptance_deadline TIMESTAMPTZ;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS max_rejections INTEGER DEFAULT 3;

-- Enforce max price (GAP-B4): $500 STANDARD, $1000 LIVE
-- Note: Application-layer enforcement. DB constraint as safety net.
ALTER TABLE tasks ADD CONSTRAINT IF NOT EXISTS tasks_max_price
    CHECK (amount <= 100000); -- $1,000 max in cents (LIVE max; STANDARD enforced at app layer at $500)

-- 3. User Blocks (GAP-B8)
CREATE TABLE IF NOT EXISTS user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id),
    CHECK (blocker_id != blocked_id)
);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked ON user_blocks(blocked_id);

-- 4. Sybil Prevention (GAP-4)
CREATE TABLE IF NOT EXISTS device_fingerprints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fingerprint TEXT NOT NULL,
    os_version TEXT,
    device_model TEXT,
    screen_resolution TEXT,
    timezone TEXT,
    language TEXT,
    first_seen_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_device_fp_user ON device_fingerprints(user_id);
CREATE INDEX IF NOT EXISTS idx_device_fp_fingerprint ON device_fingerprints(fingerprint);

CREATE TABLE IF NOT EXISTS banned_phones (
    phone_number TEXT PRIMARY KEY,
    banned_at TIMESTAMPTZ DEFAULT NOW(),
    reason TEXT,
    original_user_id UUID REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS banned_devices (
    fingerprint TEXT PRIMARY KEY,
    banned_at TIMESTAMPTZ DEFAULT NOW(),
    reason TEXT,
    original_user_id UUID REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS banned_stripe_accounts (
    stripe_account_id TEXT PRIMARY KEY,
    banned_at TIMESTAMPTZ DEFAULT NOW(),
    reason TEXT,
    original_user_id UUID REFERENCES users(id)
);

-- 5. Scheduled Transfers — 48h delay (GAP-B6 Chargeback)
CREATE TABLE IF NOT EXISTS scheduled_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escrow_id UUID NOT NULL REFERENCES escrows(id),
    worker_id UUID NOT NULL REFERENCES users(id),
    amount_cents INTEGER NOT NULL,
    scheduled_for TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED_CHARGEBACK')),
    stripe_transfer_id TEXT,
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_scheduled_transfers_status ON scheduled_transfers(status, scheduled_for);

-- 6. Support Tickets (GAP-2)
CREATE TABLE IF NOT EXISTS support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    category TEXT NOT NULL
        CHECK (category IN ('PAYMENT', 'TASK', 'ACCOUNT', 'DISPUTE', 'SAFETY', 'OTHER')),
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    task_id UUID REFERENCES tasks(id),
    status TEXT NOT NULL DEFAULT 'OPEN'
        CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    assigned_to UUID REFERENCES users(id),
    attachments TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_support_tickets_user ON support_tickets(user_id, status);

-- 7. Background Job Log (GAP-B11)
CREATE TABLE IF NOT EXISTS background_job_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_name TEXT NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'RUNNING'
        CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED', 'RETRYING')),
    error_message TEXT,
    rows_affected INTEGER DEFAULT 0,
    duration_ms INTEGER
);
CREATE INDEX IF NOT EXISTS idx_job_log_name ON background_job_log(job_name, started_at DESC);

-- 8. Dispute SLA Expansion (GAP-B9)
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS sla_phase TEXT DEFAULT 'AI_TRIAGE'
    CHECK (sla_phase IN ('AI_TRIAGE', 'HUMAN_REVIEW', 'ADMIN_DECISION', 'FOUNDER_ESCALATION', 'AUTO_RESOLVED'));
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS sla_deadline TIMESTAMPTZ;
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS appeal_filed BOOLEAN DEFAULT false;
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS appeal_deadline TIMESTAMPTZ;
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS resolution_split_poster_pct INTEGER;
ALTER TABLE disputes ADD COLUMN IF NOT EXISTS resolution_split_worker_pct INTEGER;

-- 9. Tax Documents (GAP-1)
CREATE TABLE IF NOT EXISTS tax_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    tax_year INTEGER NOT NULL,
    document_type TEXT NOT NULL DEFAULT '1099-NEC',
    total_earnings_cents INTEGER NOT NULL,
    stripe_tax_form_id TEXT,
    available_at TIMESTAMPTZ,
    download_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, tax_year, document_type)
);

-- 10. Chargeback Tracking (GAP-B6)
ALTER TABLE escrows ADD COLUMN IF NOT EXISTS chargeback_dispute_id TEXT;
ALTER TABLE escrows ADD COLUMN IF NOT EXISTS chargeback_at TIMESTAMPTZ;

-- 11. Compound Pattern Detection (GAP-11)
CREATE TABLE IF NOT EXISTS compound_pattern_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    rule_id TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    window_period TEXT NOT NULL,
    trigger_metrics JSONB NOT NULL,
    action_taken TEXT NOT NULL,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id),
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cpa_user ON compound_pattern_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_cpa_severity ON compound_pattern_alerts(severity, resolved_at);

CREATE TABLE IF NOT EXISTS user_rolling_metrics (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    metrics_7d JSONB NOT NULL DEFAULT '{}',
    metrics_30d JSONB NOT NULL DEFAULT '{}',
    metrics_90d JSONB NOT NULL DEFAULT '{}',
    last_computed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Schema Version
INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES (
    '1.6.0', 'system', '42_GAP_HARDENING_V1',
    '42-gap audit: user_blocks, device_fingerprints, banned_phones/devices/stripe, scheduled_transfers, support_tickets, background_job_log, tax_documents, compound_pattern_alerts, user_rolling_metrics. Safety columns on users + tasks. Dispute SLA. Chargeback tracking.'
) ON CONFLICT (version) DO NOTHING;

-- END Migration 007
