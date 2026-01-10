-- ============================================================================
-- Migration 002: Critical Gaps Feature Tables
-- ============================================================================
-- STATUS: CONSTITUTIONAL — DO NOT MODIFY WITHOUT VERSION BUMP
-- AUTHORITY: Layer 0 (Highest) — See ARCHITECTURE.md §1
-- VERSION: 1.1.0
-- DATE: 2025-01-XX
-- 
-- This migration adds tables for all 9 critical gaps:
-- - Task Discovery & Matching (GAP A)
-- - Messaging System (GAP B)
-- - Notification System (GAP D)
-- - Rating System (GAP E)
-- - Analytics Infrastructure (GAP J)
-- - Fraud Detection (GAP K)
-- - Content Moderation (GAP L)
-- - GDPR Compliance (GAP M)
-- ============================================================================

-- Update schema version
INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES ('1.1.0', 'system', 'CRITICAL_GAPS', 'Added tables for critical gaps: messaging, notifications, ratings, analytics, fraud, moderation, GDPR');

-- ============================================================================
-- SECTION 1: TASK DISCOVERY & MATCHING (GAP A)
-- ============================================================================

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

CREATE INDEX idx_matching_scores_hustler ON task_matching_scores(hustler_id, relevance_score DESC);
CREATE INDEX idx_matching_scores_task ON task_matching_scores(task_id, matching_score DESC);
CREATE INDEX idx_matching_scores_expires ON task_matching_scores(expires_at) WHERE expires_at < NOW();

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

CREATE INDEX idx_saved_searches_user ON saved_searches(user_id, created_at DESC);

-- ============================================================================
-- SECTION 2: MESSAGING SYSTEM (GAP B)
-- ============================================================================

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

CREATE INDEX idx_task_messages_task ON task_messages(task_id, created_at DESC);
CREATE INDEX idx_task_messages_unread ON task_messages(receiver_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_task_messages_moderation ON task_messages(moderation_status) WHERE moderation_status = 'pending';

-- ============================================================================
-- SECTION 3: NOTIFICATION SYSTEM (GAP D)
-- ============================================================================

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

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_user_recent ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_pending ON notifications(sent_at) WHERE sent_at IS NULL;
CREATE INDEX idx_notifications_task ON notifications(task_id) WHERE task_id IS NOT NULL;
CREATE INDEX idx_notifications_expires ON notifications(expires_at) WHERE expires_at IS NOT NULL;

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

-- ============================================================================
-- SECTION 4: RATING SYSTEM (GAP E)
-- ============================================================================

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

CREATE INDEX idx_ratings_ratee ON task_ratings(ratee_id, created_at DESC);
CREATE INDEX idx_ratings_task ON task_ratings(task_id);
CREATE INDEX idx_ratings_public ON task_ratings(ratee_id, is_public) WHERE is_public = true;

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

-- ============================================================================
-- SECTION 5: ANALYTICS INFRASTRUCTURE (GAP J)
-- ============================================================================

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

CREATE INDEX idx_analytics_event_type ON analytics_events(event_type, event_timestamp DESC);
CREATE INDEX idx_analytics_user ON analytics_events(user_id, event_timestamp DESC);
CREATE INDEX idx_analytics_task ON analytics_events(task_id, event_timestamp DESC);
CREATE INDEX idx_analytics_session ON analytics_events(session_id, event_timestamp DESC);
CREATE INDEX idx_analytics_timestamp ON analytics_events(event_timestamp DESC);
CREATE INDEX idx_analytics_category ON analytics_events(event_category, event_timestamp DESC);

-- ============================================================================
-- SECTION 6: FRAUD DETECTION (GAP K)
-- ============================================================================

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

CREATE INDEX idx_fraud_risk_entity ON fraud_risk_scores(entity_type, entity_id, calculated_at DESC);
CREATE INDEX idx_fraud_risk_score ON fraud_risk_scores(risk_score DESC) WHERE status = 'active';
CREATE INDEX idx_fraud_risk_review ON fraud_risk_scores(status) WHERE status IN ('active', 'reviewed');

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

CREATE INDEX idx_fraud_patterns_type ON fraud_patterns(pattern_type, detected_at DESC);
CREATE INDEX idx_fraud_patterns_status ON fraud_patterns(status) WHERE status = 'detected';

-- ============================================================================
-- SECTION 7: CONTENT MODERATION (GAP L)
-- ============================================================================

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

CREATE INDEX idx_moderation_queue_status ON content_moderation_queue(status, severity, flagged_at);
CREATE INDEX idx_moderation_queue_sla ON content_moderation_queue(sla_deadline) WHERE status = 'pending';
CREATE INDEX idx_moderation_queue_user ON content_moderation_queue(user_id, flagged_at DESC);

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

CREATE INDEX idx_content_reports_status ON content_reports(status, reported_at DESC);
CREATE INDEX idx_content_reports_content ON content_reports(content_type, content_id);
CREATE INDEX idx_content_reports_reporter ON content_reports(reporter_user_id, reported_at DESC);

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

CREATE INDEX idx_content_appeals_status ON content_appeals(status, submitted_at DESC);
CREATE INDEX idx_content_appeals_user ON content_appeals(user_id, submitted_at DESC);

-- ============================================================================
-- SECTION 8: GDPR COMPLIANCE (GAP M)
-- ============================================================================

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

CREATE INDEX idx_gdpr_requests_user ON gdpr_data_requests(user_id, requested_at DESC);
CREATE INDEX idx_gdpr_requests_status ON gdpr_data_requests(status, deadline) WHERE status IN ('pending', 'processing');

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

CREATE INDEX idx_user_consents_user ON user_consents(user_id, consent_type);
CREATE INDEX idx_user_consents_granted ON user_consents(granted, consent_type) WHERE granted = true;

-- ============================================================================
-- SECTION 9: TRIGGERS FOR NEW TABLES
-- ============================================================================

-- Auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_messages_updated_at
  BEFORE UPDATE ON task_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER task_ratings_updated_at
  BEFORE UPDATE ON task_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER user_consents_updated_at
  BEFORE UPDATE ON user_consents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- END OF MIGRATION 002
-- ============================================================================
