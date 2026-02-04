-- ============================================================================
-- Migration 006: PostGIS Geospatial Infrastructure
-- ============================================================================
-- Authority: SPATIAL_INTELLIGENCE_LOCKED.md §3-§4
-- Resolves: P0 geospatial infrastructure inconsistency (V3 Audit §2)
--   - FEED_QUERY §6 uses PostGIS ST_DWithin but no extension was declared
--   - MATCHING_ALGORITHMS used incompatible earth_distance approach
--   - schema.sql had VARCHAR location but no geography column
--   - No spatial index existed for O(log n) radius queries
-- Decision: Standardize ALL geospatial queries on PostGIS
-- Provider: Neon supports PostGIS natively (BACKEND_STACK_LOCK §extensions)
-- ============================================================================

-- Step 1: Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Step 2: Add geography column to tasks table
-- Auto-populated from existing lat/lng via trigger (backward compatible)
ALTER TABLE tasks
ADD COLUMN IF NOT EXISTS location_geog GEOGRAPHY(POINT, 4326);

-- Step 3: Create GIST spatial index for O(log n) radius queries
-- Referenced by: FEED_QUERY §6, MATCHING_ALGORITHMS, SPATIAL_INTELLIGENCE §4
CREATE INDEX IF NOT EXISTS idx_tasks_location_geog
ON tasks USING GIST (location_geog);

-- Step 4: Auto-populate trigger (keeps location_geog in sync with lat/lng)
CREATE OR REPLACE FUNCTION sync_task_location_geog()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.location_lat IS NOT NULL AND NEW.location_lng IS NOT NULL THEN
        NEW.location_geog := ST_SetSRID(ST_MakePoint(NEW.location_lng, NEW.location_lat), 4326)::geography;
    ELSE
        NEW.location_geog := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_sync_geog
BEFORE INSERT OR UPDATE OF location_lat, location_lng ON tasks
FOR EACH ROW EXECUTE FUNCTION sync_task_location_geog();

-- Step 5: Backfill existing rows
UPDATE tasks
SET location_geog = ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326)::geography
WHERE location_lat IS NOT NULL
  AND location_lng IS NOT NULL
  AND location_geog IS NULL;

-- Step 6: Record migration
INSERT INTO schema_versions (version, applied_by, checksum, notes)
VALUES (
    '1.4.0',
    'migration_006',
    'POSTGIS_INFRASTRUCTURE_V1',
    'PostGIS extension, tasks.location_geog GEOGRAPHY(POINT,4326), GIST spatial index, auto-populate trigger, backfill existing rows.'
)
ON CONFLICT (version) DO NOTHING;
