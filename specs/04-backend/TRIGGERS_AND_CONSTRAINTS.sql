-- ============================================================================
-- HustleXP Database Triggers and Constraints
-- ============================================================================
-- STATUS: CONSTITUTIONAL AUTHORITY
-- Owner: Backend Team
-- Last Updated: January 2025
-- Version: v1.0.0
--
-- This file contains all database-level enforcement of PRODUCT_SPEC invariants.
-- These triggers form Layer 0 (PostgreSQL) of the enforcement hierarchy.
-- Application code CANNOT bypass these constraints.
-- ============================================================================

-- ============================================================================
-- SECTION 1: CUSTOM ERROR DOMAIN
-- ============================================================================

-- Create custom exception for HustleXP errors
CREATE OR REPLACE FUNCTION raise_hx_error(code TEXT, message TEXT)
RETURNS void AS $$
BEGIN
  RAISE EXCEPTION '%: %', code, message
    USING ERRCODE = 'P0001',
          HINT = code;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SECTION 2: CORE INVARIANT TRIGGERS (INV-1 through INV-5)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- INV-1: XP Requires Released Escrow
-- SPEC: PRODUCT_SPEC.md §2 INV-1
-- Error Code: HX101
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION xp_requires_released_escrow()
RETURNS TRIGGER AS $$
DECLARE
  escrow_state TEXT;
BEGIN
  -- Get the escrow state
  SELECT state INTO escrow_state
  FROM escrows
  WHERE id = NEW.escrow_id;

  -- Escrow must exist and be RELEASED
  IF escrow_state IS NULL THEN
    PERFORM raise_hx_error('HX101', 'XP cannot be awarded: escrow not found');
  END IF;

  IF escrow_state != 'RELEASED' THEN
    PERFORM raise_hx_error('HX101',
      'XP cannot be awarded: escrow state is ' || escrow_state || ', must be RELEASED');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_xp_requires_released_escrow
  BEFORE INSERT ON xp_ledger
  FOR EACH ROW
  EXECUTE FUNCTION xp_requires_released_escrow();

-- ----------------------------------------------------------------------------
-- INV-2: Released Escrow Requires Completed Task
-- SPEC: PRODUCT_SPEC.md §2 INV-2
-- Error Code: HX201
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_released_requires_completed_task()
RETURNS TRIGGER AS $$
DECLARE
  task_state TEXT;
BEGIN
  -- Only check when transitioning TO RELEASED
  IF NEW.state = 'RELEASED' AND (OLD.state IS NULL OR OLD.state != 'RELEASED') THEN
    -- Get the task state
    SELECT state INTO task_state
    FROM tasks
    WHERE escrow_id = NEW.id;

    IF task_state IS NULL THEN
      PERFORM raise_hx_error('HX201', 'Escrow cannot be released: no linked task found');
    END IF;

    IF task_state != 'COMPLETED' THEN
      PERFORM raise_hx_error('HX201',
        'Escrow cannot be released: task state is ' || task_state || ', must be COMPLETED');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_escrow_released_requires_completed_task
  BEFORE UPDATE ON escrows
  FOR EACH ROW
  EXECUTE FUNCTION escrow_released_requires_completed_task();

-- ----------------------------------------------------------------------------
-- INV-3: Completed Task Requires Accepted Proof
-- SPEC: PRODUCT_SPEC.md §2 INV-3
-- Error Code: HX301
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION task_completed_requires_accepted_proof()
RETURNS TRIGGER AS $$
DECLARE
  accepted_proof_count INTEGER;
BEGIN
  -- Only check when transitioning TO COMPLETED
  IF NEW.state = 'COMPLETED' AND (OLD.state IS NULL OR OLD.state != 'COMPLETED') THEN
    -- Only enforce for tasks that require proof
    IF NEW.requires_proof = TRUE THEN
      SELECT COUNT(*) INTO accepted_proof_count
      FROM proofs
      WHERE task_id = NEW.id AND state = 'ACCEPTED';

      IF accepted_proof_count = 0 THEN
        PERFORM raise_hx_error('HX301',
          'Task cannot be completed: no accepted proof exists');
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_completed_requires_accepted_proof
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION task_completed_requires_accepted_proof();

-- ----------------------------------------------------------------------------
-- INV-4: Escrow Amount Immutable
-- SPEC: PRODUCT_SPEC.md §2 INV-4
-- Error Code: HX004
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_amount_immutable()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.amount IS NOT NULL AND NEW.amount != OLD.amount THEN
    PERFORM raise_hx_error('HX004',
      'Escrow amount cannot be modified after creation');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_escrow_amount_immutable
  BEFORE UPDATE ON escrows
  FOR EACH ROW
  EXECUTE FUNCTION escrow_amount_immutable();

-- ----------------------------------------------------------------------------
-- INV-5: XP Idempotent Per Escrow
-- SPEC: PRODUCT_SPEC.md §2 INV-5
-- Error Code: 23505 (PostgreSQL unique violation)
-- ----------------------------------------------------------------------------
-- Enforced via UNIQUE constraint on xp_ledger.escrow_id
ALTER TABLE xp_ledger ADD CONSTRAINT xp_ledger_escrow_unique UNIQUE (escrow_id);

-- ============================================================================
-- SECTION 3: TERMINAL STATE GUARDS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Task Terminal State Guard
-- SPEC: PRODUCT_SPEC.md §3.4
-- Error Code: HX001
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION task_terminal_guard()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.state IN ('COMPLETED', 'CANCELLED', 'EXPIRED') THEN
    -- Allow only updated_at changes
    IF NEW.state != OLD.state OR
       NEW.title != OLD.title OR
       NEW.description != OLD.description OR
       NEW.price != OLD.price OR
       NEW.poster_id != OLD.poster_id OR
       NEW.worker_id IS DISTINCT FROM OLD.worker_id THEN
      PERFORM raise_hx_error('HX001',
        'Task in terminal state (' || OLD.state || ') cannot be modified');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_terminal_guard
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION task_terminal_guard();

-- ----------------------------------------------------------------------------
-- Escrow Terminal State Guard
-- SPEC: PRODUCT_SPEC.md §4.4
-- Error Code: HX002
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_terminal_guard()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.state IN ('RELEASED', 'REFUNDED', 'REFUND_PARTIAL') THEN
    -- Only allow updated_at changes
    IF NEW.state != OLD.state OR
       NEW.amount != OLD.amount THEN
      PERFORM raise_hx_error('HX002',
        'Escrow in terminal state (' || OLD.state || ') cannot be modified');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_escrow_terminal_guard
  BEFORE UPDATE ON escrows
  FOR EACH ROW
  EXECUTE FUNCTION escrow_terminal_guard();

-- ============================================================================
-- SECTION 4: APPEND-ONLY LEDGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- XP Ledger No Delete
-- SPEC: PRODUCT_SPEC.md §5.3
-- Error Code: HX102
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION xp_ledger_no_delete()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM raise_hx_error('HX102', 'XP ledger entries cannot be deleted');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_xp_ledger_no_delete
  BEFORE DELETE ON xp_ledger
  FOR EACH ROW
  EXECUTE FUNCTION xp_ledger_no_delete();

-- ----------------------------------------------------------------------------
-- Badge Ledger No Delete
-- SPEC: PRODUCT_SPEC.md (badges are permanent)
-- Error Code: HX401
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION badge_ledger_no_delete()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM raise_hx_error('HX401', 'Badge entries cannot be deleted');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_badge_ledger_no_delete
  BEFORE DELETE ON user_badges
  FOR EACH ROW
  EXECUTE FUNCTION badge_ledger_no_delete();

-- ----------------------------------------------------------------------------
-- Trust Ledger No Delete
-- Error Code: HX801
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trust_ledger_no_delete()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM raise_hx_error('HX801', 'Trust ledger entries cannot be deleted');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trust_ledger_no_delete
  BEFORE DELETE ON trust_ledger
  FOR EACH ROW
  EXECUTE FUNCTION trust_ledger_no_delete();

-- ============================================================================
-- SECTION 5: LIVE MODE CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LIVE-1: Live Broadcast Requires Funded Escrow
-- SPEC: PRODUCT_SPEC.md §3.5
-- Error Code: HX901
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION live_broadcast_requires_funded_escrow()
RETURNS TRIGGER AS $$
DECLARE
  escrow_state TEXT;
BEGIN
  -- Only check for LIVE mode tasks when broadcast starts
  IF NEW.mode = 'LIVE' AND NEW.live_broadcast_started_at IS NOT NULL
     AND (OLD.live_broadcast_started_at IS NULL) THEN

    SELECT state INTO escrow_state
    FROM escrows
    WHERE id = NEW.escrow_id;

    IF escrow_state IS NULL OR escrow_state != 'FUNDED' THEN
      PERFORM raise_hx_error('HX901',
        'Live broadcast cannot start: escrow must be FUNDED');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_live_broadcast_requires_funded_escrow
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION live_broadcast_requires_funded_escrow();

-- ----------------------------------------------------------------------------
-- LIVE-2: Live Task Minimum Price ($15.00 = 1500 cents)
-- SPEC: PRODUCT_SPEC.md §3.5
-- Error Code: HX902
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION live_task_minimum_price()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.mode = 'LIVE' AND NEW.price < 1500 THEN
    PERFORM raise_hx_error('HX902',
      'Live tasks require minimum price of $15.00 (1500 cents)');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_live_task_minimum_price
  BEFORE INSERT OR UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION live_task_minimum_price();

-- ============================================================================
-- SECTION 6: STANDARD TASK CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Standard Task Minimum Price ($5.00 = 500 cents)
-- SPEC: PRODUCT_SPEC.md §18.1
-- ----------------------------------------------------------------------------
ALTER TABLE tasks ADD CONSTRAINT task_minimum_price CHECK (price >= 500);

-- ----------------------------------------------------------------------------
-- Escrow Amount Matches Task Price
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_amount_matches_task()
RETURNS TRIGGER AS $$
DECLARE
  task_price INTEGER;
BEGIN
  SELECT price INTO task_price
  FROM tasks
  WHERE escrow_id = NEW.id;

  IF task_price IS NOT NULL AND NEW.amount != task_price THEN
    PERFORM raise_hx_error('HX003',
      'Escrow amount must match task price');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SECTION 7: PARTIAL REFUND CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Escrow Partial Sum Check
-- SPEC: PRODUCT_SPEC.md §4.5
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_partial_sum_check()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.state = 'REFUND_PARTIAL' THEN
    -- Both amounts must be non-null
    IF NEW.refund_amount IS NULL OR NEW.release_amount IS NULL THEN
      PERFORM raise_hx_error('HX005',
        'Partial refund requires both refund_amount and release_amount');
    END IF;

    -- Sum must equal original amount
    IF NEW.refund_amount + NEW.release_amount != NEW.amount THEN
      PERFORM raise_hx_error('HX006',
        'Partial refund amounts must sum to original escrow amount');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_escrow_partial_sum_check
  BEFORE UPDATE ON escrows
  FOR EACH ROW
  EXECUTE FUNCTION escrow_partial_sum_check();

-- ============================================================================
-- SECTION 8: AI TASK COMPLETION CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- COMPLETE-4: Escrow Cannot Fund Unless Task State = COMPLETE
-- SPEC: PRODUCT_SPEC.md §8.9
-- Error Code: HX702
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION escrow_funding_requires_complete_task()
RETURNS TRIGGER AS $$
DECLARE
  task_ai_state TEXT;
BEGIN
  -- Only check when transitioning TO FUNDED
  IF NEW.state = 'FUNDED' AND (OLD.state IS NULL OR OLD.state != 'FUNDED') THEN
    SELECT ai_completion_state INTO task_ai_state
    FROM tasks
    WHERE escrow_id = NEW.id;

    -- If task has AI completion tracking, enforce COMPLETE state
    IF task_ai_state IS NOT NULL AND task_ai_state != 'COMPLETE' THEN
      PERFORM raise_hx_error('HX702',
        'Escrow cannot be funded: task AI state is ' || task_ai_state || ', must be COMPLETE');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_escrow_funding_requires_complete_task
  BEFORE UPDATE ON escrows
  FOR EACH ROW
  EXECUTE FUNCTION escrow_funding_requires_complete_task();

-- ============================================================================
-- SECTION 9: MESSAGING CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MSG-1: Messages Only During Active Task States
-- SPEC: PRODUCT_SPEC.md §10.5
-- Error Code: HX801
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION message_requires_active_task()
RETURNS TRIGGER AS $$
DECLARE
  task_state TEXT;
BEGIN
  SELECT state INTO task_state
  FROM tasks
  WHERE id = NEW.task_id;

  IF task_state NOT IN ('ACCEPTED', 'PROOF_SUBMITTED', 'DISPUTED') THEN
    PERFORM raise_hx_error('HX801',
      'Messages can only be sent during ACCEPTED, PROOF_SUBMITTED, or DISPUTED states');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_message_requires_active_task
  BEFORE INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION message_requires_active_task();

-- ----------------------------------------------------------------------------
-- MSG-2: Message Sender Must Be Task Participant
-- SPEC: PRODUCT_SPEC.md §10.5
-- Error Code: HX802
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION message_sender_is_participant()
RETURNS TRIGGER AS $$
DECLARE
  task_poster_id UUID;
  task_worker_id UUID;
BEGIN
  SELECT poster_id, worker_id INTO task_poster_id, task_worker_id
  FROM tasks
  WHERE id = NEW.task_id;

  IF NEW.sender_id != task_poster_id AND NEW.sender_id != task_worker_id THEN
    PERFORM raise_hx_error('HX802',
      'Message sender must be task poster or worker');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_message_sender_is_participant
  BEFORE INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION message_sender_is_participant();

-- ----------------------------------------------------------------------------
-- MSG-4: Message Content Length Limit (500 chars)
-- SPEC: PRODUCT_SPEC.md §10.5
-- Error Code: HX804
-- ----------------------------------------------------------------------------
ALTER TABLE messages ADD CONSTRAINT message_content_length CHECK (
  content IS NULL OR LENGTH(content) <= 500
);

-- ============================================================================
-- SECTION 10: RATING CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- RATE-1: Rating Only After Task COMPLETED
-- SPEC: PRODUCT_SPEC.md §12.5
-- Error Code: HX807
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rating_requires_completed_task()
RETURNS TRIGGER AS $$
DECLARE
  task_state TEXT;
BEGIN
  SELECT state INTO task_state
  FROM tasks
  WHERE id = NEW.task_id;

  IF task_state != 'COMPLETED' THEN
    PERFORM raise_hx_error('HX807',
      'Ratings can only be submitted after task is COMPLETED');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_rating_requires_completed_task
  BEFORE INSERT ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION rating_requires_completed_task();

-- ----------------------------------------------------------------------------
-- RATE-4: Ratings Are Immutable
-- SPEC: PRODUCT_SPEC.md §12.5
-- Error Code: HX809
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rating_immutable()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM raise_hx_error('HX809', 'Ratings cannot be modified after submission');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_rating_immutable
  BEFORE UPDATE ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION rating_immutable();

CREATE TRIGGER trg_rating_no_delete
  BEFORE DELETE ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION rating_immutable();

-- ----------------------------------------------------------------------------
-- RATE-5: One Rating Per Pair Per Task
-- SPEC: PRODUCT_SPEC.md §12.5
-- ----------------------------------------------------------------------------
ALTER TABLE ratings ADD CONSTRAINT rating_unique_per_pair
  UNIQUE (task_id, rater_id, ratee_id);

-- ----------------------------------------------------------------------------
-- RATE-6: Stars Must Be 1-5
-- SPEC: PRODUCT_SPEC.md §12.5
-- Error Code: HX810
-- ----------------------------------------------------------------------------
ALTER TABLE ratings ADD CONSTRAINT rating_stars_range CHECK (
  stars >= 1 AND stars <= 5
);

-- ============================================================================
-- SECTION 11: GDPR CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- GDPR-3: Consent Records Append-Only
-- SPEC: PRODUCT_SPEC.md §16.7
-- Error Code: HX973
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION consent_record_immutable()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM raise_hx_error('HX973', 'Consent records cannot be modified');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consent_record_immutable
  BEFORE UPDATE OR DELETE ON consent_records
  FOR EACH ROW
  EXECUTE FUNCTION consent_record_immutable();

-- ============================================================================
-- SECTION 12: ELIGIBILITY CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- INV-ELIGIBILITY-6: Location State Must Be Valid US State Code
-- SPEC: PRODUCT_SPEC.md §2 INV-ELIGIBILITY-6
-- ----------------------------------------------------------------------------
ALTER TABLE users ADD CONSTRAINT user_location_state_format CHECK (
  location_state IS NULL OR LENGTH(location_state) = 2
);

-- Valid US state codes (application layer validates against full list)

-- ============================================================================
-- SECTION 13: UTILITY FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Calculate Level from XP
-- SPEC: PRODUCT_SPEC.md §5.4
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_level(total_xp INTEGER)
RETURNS INTEGER AS $$
BEGIN
  -- Level calculation: floor(sqrt(total_xp / 25)) + 1 capped at 10
  RETURN LEAST(FLOOR(SQRT(total_xp / 25.0)) + 1, 10);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- Calculate Streak Multiplier
-- SPEC: PRODUCT_SPEC.md §5.2
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_streak_multiplier(streak_days INTEGER)
RETURNS NUMERIC AS $$
BEGIN
  -- 1.0 + (streak_days × 0.05) capped at 2.0
  RETURN LEAST(1.0 + (streak_days * 0.05), 2.0);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- Calculate Trust Multiplier
-- SPEC: PRODUCT_SPEC.md §5.2
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_trust_multiplier(trust_tier INTEGER)
RETURNS NUMERIC AS $$
BEGIN
  CASE trust_tier
    WHEN 1 THEN RETURN 1.0;  -- ROOKIE
    WHEN 2 THEN RETURN 1.5;  -- VERIFIED
    WHEN 3 THEN RETURN 1.5;  -- TRUSTED
    WHEN 4 THEN RETURN 2.0;  -- ELITE
    ELSE RETURN 1.0;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- Calculate Effective XP
-- SPEC: PRODUCT_SPEC.md §5.2
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_effective_xp(
  base_xp INTEGER,
  streak_days INTEGER,
  trust_tier INTEGER
)
RETURNS INTEGER AS $$
BEGIN
  RETURN FLOOR(
    base_xp *
    calculate_streak_multiplier(streak_days) *
    calculate_trust_multiplier(trust_tier)
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- SECTION 14: STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Award XP (with all validations)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION award_xp(
  p_user_id UUID,
  p_task_id UUID,
  p_escrow_id UUID
)
RETURNS TABLE (
  xp_entry_id UUID,
  base_xp INTEGER,
  effective_xp INTEGER,
  new_level INTEGER
) AS $$
DECLARE
  v_escrow_amount INTEGER;
  v_user_streak INTEGER;
  v_user_trust_tier INTEGER;
  v_user_xp_before INTEGER;
  v_base_xp INTEGER;
  v_effective_xp INTEGER;
  v_new_xp_total INTEGER;
  v_level_before INTEGER;
  v_level_after INTEGER;
  v_entry_id UUID;
BEGIN
  -- Get escrow amount
  SELECT amount INTO v_escrow_amount
  FROM escrows WHERE id = p_escrow_id AND state = 'RELEASED';

  IF v_escrow_amount IS NULL THEN
    PERFORM raise_hx_error('HX101', 'Cannot award XP: escrow not found or not released');
  END IF;

  -- Get user current state
  SELECT xp_total, current_streak, trust_tier
  INTO v_user_xp_before, v_user_streak, v_user_trust_tier
  FROM users WHERE id = p_user_id;

  -- Calculate XP
  v_base_xp := v_escrow_amount / 100;  -- cents to XP
  v_effective_xp := calculate_effective_xp(v_base_xp, v_user_streak, v_user_trust_tier);
  v_new_xp_total := v_user_xp_before + v_effective_xp;
  v_level_before := calculate_level(v_user_xp_before);
  v_level_after := calculate_level(v_new_xp_total);

  -- Insert ledger entry
  INSERT INTO xp_ledger (
    user_id, task_id, escrow_id,
    base_xp, effective_xp,
    user_xp_before, user_xp_after,
    user_level_before, user_level_after,
    user_streak_at_award
  ) VALUES (
    p_user_id, p_task_id, p_escrow_id,
    v_base_xp, v_effective_xp,
    v_user_xp_before, v_new_xp_total,
    v_level_before, v_level_after,
    v_user_streak
  ) RETURNING id INTO v_entry_id;

  -- Update user totals
  UPDATE users SET
    xp_total = v_new_xp_total,
    current_level = v_level_after,
    last_task_completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_user_id;

  RETURN QUERY SELECT v_entry_id, v_base_xp, v_effective_xp, v_level_after;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Expire Task
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION expire_task(p_task_id UUID)
RETURNS void AS $$
DECLARE
  v_escrow_id UUID;
BEGIN
  -- Update task state
  UPDATE tasks SET
    state = 'EXPIRED',
    expired_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id
  RETURNING escrow_id INTO v_escrow_id;

  -- Refund escrow if funded
  IF v_escrow_id IS NOT NULL THEN
    UPDATE escrows SET
      state = 'REFUNDED',
      updated_at = NOW()
    WHERE id = v_escrow_id AND state = 'FUNDED';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Auto-Approve Proof (48-hour timeout)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION auto_approve_proof(p_proof_id UUID)
RETURNS void AS $$
DECLARE
  v_task_id UUID;
BEGIN
  -- Update proof state
  UPDATE proofs SET
    state = 'ACCEPTED',
    auto_approved = TRUE,
    reviewed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_proof_id
  RETURNING task_id INTO v_task_id;

  -- Complete the task (will trigger escrow release)
  UPDATE tasks SET
    state = 'COMPLETED',
    completed_at = NOW(),
    updated_at = NOW()
  WHERE id = v_task_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- END OF TRIGGERS_AND_CONSTRAINTS.sql
-- ============================================================================
