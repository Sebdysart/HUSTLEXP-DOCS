-- Migration 005: Spatial Intelligence Columns
-- Authority: SPATIAL_INTELLIGENCE_LOCKED.md §6.2 (Address Validation)
-- Purpose: Add geocoding confidence and Google Place ID to tasks for spatial validation
-- Date: Feb 2026

-- ============================================================================
-- 1. TASKS TABLE — Spatial columns
-- ============================================================================

-- Google Place ID for address deduplication and re-geocoding prevention
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS location_place_id VARCHAR(255);

-- Geocoding confidence level from Google Maps Geocoding API
-- ROOFTOP = exact match, RANGE_INTERPOLATED = street-level, others = lower confidence
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS location_precision VARCHAR(30)
  CHECK (location_precision IN ('ROOFTOP', 'RANGE_INTERPOLATED', 'GEOMETRIC_CENTER', 'APPROXIMATE'));

-- Index for duplicate location detection (SPATIAL_INTELLIGENCE §6.3)
CREATE INDEX IF NOT EXISTS idx_tasks_place_id ON tasks(location_place_id) WHERE location_place_id IS NOT NULL;

-- ============================================================================
-- 2. TASKS TABLE — Arrival Instructions (SPATIAL_INTELLIGENCE §6.4)
-- ============================================================================

-- Poster-provided last-meters wayfinding notes ("enter through side gate", "gate code #1234")
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS arrival_instructions VARCHAR(280);

-- If true, mask arrival instructions until worker is within 100m (ARRIVAL zone)
-- Prevents premature sharing of security-sensitive access info (gate codes, building access)
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS arrival_has_gate_code BOOLEAN DEFAULT false;

-- ============================================================================
-- 2. USER_TASK_DRAFTS TABLE — Mirror spatial columns for draft persistence
-- ============================================================================

ALTER TABLE user_task_drafts ADD COLUMN IF NOT EXISTS location_place_id VARCHAR(255);
ALTER TABLE user_task_drafts ADD COLUMN IF NOT EXISTS location_precision VARCHAR(30)
  CHECK (location_precision IS NULL OR location_precision IN ('ROOFTOP', 'RANGE_INTERPOLATED', 'GEOMETRIC_CENTER', 'APPROXIMATE'));

-- ============================================================================
-- 3. VALIDATION NOTE
-- ============================================================================
-- Task creation REQUIRES location_precision = 'ROOFTOP' or 'RANGE_INTERPOLATED' (street-level accuracy).
-- 'GEOMETRIC_CENTER' or 'APPROXIMATE' triggers AI LOCATION_CLARITY clarification question.
-- Geocoding runs SERVER-SIDE at task creation (prevents spoofed coordinates from client).
-- See SPATIAL_INTELLIGENCE_LOCKED.md §4.1 and §6.1 for full validation flow.
