# SPATIAL INTELLIGENCE — V3 Audit & Geospatial Infrastructure Fix

**STATUS:** ✅ IMPLEMENTED — All 12 gaps resolved, PostGIS infrastructure standardized
**Date:** Feb 2026
**Trigger:** External spec proposing Uber-level mapping (heat maps, geofenced clock-in, quest batching, movement verification, cost-tiered APIs). Third round — previous V1 analysis + V2 audit both complete.

---

## §1. PROPOSAL vs. EXISTING SPEC MATRIX

| # | Proposal Element | Existing Coverage | Verdict |
|---|---|---|---|
| 1 | Live "Heat Maps" / Hot Zones | SPATIAL_INTELLIGENCE §10.1, FINISHED_STATE v2 roadmap | ✅ ALREADY DEFERRED with constraints |
| 2 | Precise Walking ETA | SPATIAL_INTELLIGENCE §4.2 (WALKING/DRIVING/TRANSIT) | ✅ ALREADY IMPLEMENTED |
| 3 | Geofenced Smart Start (auto clock-in) | SPATIAL_INTELLIGENCE §8.3 REJECTED | ✅ ALREADY REJECTED (IC classification risk) |
| 4 | Quest Batching (nearby tasks) | SPATIAL_INTELLIGENCE §10.2, FINISHED_STATE v2 roadmap | ✅ ALREADY DEFERRED with constraints |
| 5 | GPS Movement Verification | SPATIAL_INTELLIGENCE §9 Movement Integrity Protocol | ✅ ALREADY IMPLEMENTED (fraud-only, IC-compliant) |
| 6 | Cost-Tiered Maps (static vs live) | SPATIAL_INTELLIGENCE §4.3 + §7 ($350/mo at 1K users) | ✅ ALREADY IMPLEMENTED |
| 7 | Map as Game Board (XP/Gold overlay) | SPATIAL_INTELLIGENCE §10.3, FINISHED_STATE v2 roadmap | ✅ ALREADY DEFERRED |
| 8 | Coordinate proximity (not zip code) | FEED_QUERY §6 (PostGIS), MATCHING_ALGORITHMS (earth_distance) | ✅ ALREADY IMPLEMENTED — but infrastructure gap found |
| 9 | Poster live location question | SPATIAL_INTELLIGENCE §5 INV-PRIVACY-2 | ✅ ALREADY ANSWERED (graduated visibility) |
| 10 | Cost efficiency ("pennies per request") | SPATIAL_INTELLIGENCE §7 (~$0.002-$0.01/request) | ✅ ALREADY DOCUMENTED |

**Result:** 0 of 10 proposal elements needed new subsystem work. 100% were already covered, consciously deferred, or explicitly rejected with rationale.

**However:** This audit discovered a **P0 geospatial infrastructure inconsistency** across 4 locked files that predates this proposal.

---

## §2. CRITICAL DISCOVERY: Geospatial Query Inconsistency (P0)

### The Problem

Two locked files use **incompatible geospatial approaches** to compute proximity, and the database schema supports **neither** of them:

| File | Approach | Function Used | Requires |
|---|---|---|---|
| FEED_QUERY §6 "Nearby Feed" | PostGIS | `ST_DWithin(t.location::geography, ...)` | PostGIS extension + `geography` column |
| MATCHING_ALGORITHMS | earthdistance | `earth_distance(ll_to_earth(lat, lng), ...)` | `cube` + `earthdistance` extensions |

**Schema reality:**
```
tasks.location     = VARCHAR(255)  ← human-readable address string
tasks.location_lat = NUMERIC(10,7) ← latitude
tasks.location_lng = NUMERIC(10,7) ← longitude
```

**Why this is P0:**
- `t.location::geography` casts a VARCHAR to geography — **runtime SQL error**
- No PostGIS extension declared in schema.sql or any migration
- No earthdistance/cube extensions declared anywhere
- No GIST spatial index exists (referenced in FEED_QUERY but absent from schema)
- LIVE-4 "geo-bounded broadcasts" has no defined implementation

---

## §3. ALL GAPS FOUND (12 Total)

### P0 — CRITICAL: Geospatial Infrastructure

| # | File | Gap |
|---|---|---|
| 1 | schema.sql | No PostGIS extension declared |
| 2 | schema.sql | No `geography` column on tasks table — FEED_QUERY casts VARCHAR which would fail |
| 3 | schema.sql | No GIST spatial index (referenced in FEED_QUERY §6 but absent) |
| 4 | FEED_QUERY vs MATCHING_ALGORITHMS | Two incompatible geospatial approaches — must unify on PostGIS |

### P1 — Cross-Reference Alignment

| # | File | Gap |
|---|---|---|
| 5 | MATCHING_ALGORITHMS | Zero SPATIAL_INTELLIGENCE references — contains geospatial logic without citing authority |
| 6 | FEED_QUERY §6 | References PostGIS but doesn't cite SPATIAL_INTELLIGENCE as geospatial authority |
| 7 | BACKEND_STACK_LOCK | No Postgres Extensions section — PostGIS undeclared as infrastructure dependency |
| 8 | SPATIAL_INTELLIGENCE §11 | Cross-reference matrix missing FEED_QUERY and MATCHING_ALGORITHMS |

### P2 — Pending Items

| # | File | Gap |
|---|---|---|
| 9 | SPATIAL_INTELLIGENCE_LOCKED.md | Commit hash still `[PENDING — set after commit]` — never set |
| 10 | ARCHITECTURE.md §21 | No "coordinate-based proximity, NOT zip code" competitive differentiator language |

### P2 — PRODUCT_SPEC Broadcast Gap

| # | File | Gap |
|---|---|---|
| 11 | PRODUCT_SPEC §8.9 | LIVE-4 "geo-bounded" broadcasts doesn't specify PostGIS implementation |
| 12 | PRODUCT_SPEC §8.9 | Broadcast radius expansion has no geospatial authority reference |

---

## §4. RESOLUTION: Standardize on PostGIS

**Decision:** Unify all geospatial queries on **PostGIS** (not earthdistance).

**Rationale:**
1. FEED_QUERY (the eligibility resolver) already uses PostGIS syntax — it's the more authoritative spec
2. PostGIS GIST indexes are O(log n) for radius queries vs O(n) full table scan with earthdistance
3. Neon (Postgres provider in BACKEND_STACK_LOCK) supports PostGIS natively
4. Industry standard — every production geospatial system uses PostGIS
5. Supports future v2 features (heat maps, quest batching) that need spatial aggregation

**Implementation:**
- Add `location_geog GEOGRAPHY(POINT, 4326)` column to tasks table
- Auto-populate via trigger from existing lat/lng columns (backward compatible)
- GIST index on the geography column
- Update FEED_QUERY to use `t.location_geog` instead of `t.location::geography`
- Update MATCHING_ALGORITHMS to use PostGIS instead of earthdistance

---

## §5. ADOPT / DEFER / REJECT

### ADOPTED (This Round):
1. PostGIS extension + geography column + GIST index in schema.sql + migration
2. FEED_QUERY column reference fix (`t.location_geog` not `t.location::geography`)
3. MATCHING_ALGORITHMS PostGIS migration + SPATIAL_INTELLIGENCE authority reference
4. BACKEND_STACK_LOCK Postgres Extensions section
5. SPATIAL_INTELLIGENCE cross-reference matrix update
6. ARCHITECTURE.md competitive differentiator language
7. Commit hash binding
8. PRODUCT_SPEC broadcast PostGIS authority reference

### REJECTED (Same as V1/V2):
- Geofenced auto-clock-in → IC misclassification risk (unchanged)
- 2x demand earnings projections → Regulatory risk (unchanged)
- Background heat map computation → INV-PRIVACY-1 violation (unchanged)
- Mapbox → Google Maps Platform lock (unchanged)

---

## §6. SYNCED FILES MANIFEST

| # | File | Change |
|---|---|---|
| 1 | specs/02-architecture/schema.sql | PostGIS extension + `location_geog` column + GIST index + auto-populate trigger |
| 2 | specs/02-architecture/migrations/006_postgis_infrastructure.sql | PostGIS migration |
| 3 | specs/02-architecture/subsystems/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md | Fix column ref, add SPATIAL authority |
| 4 | specs/04-backend/MATCHING_ALGORITHMS.md | PostGIS migration, add SPATIAL authority |
| 5 | BACKEND_STACK_LOCK.md | Postgres Extensions section with PostGIS |
| 6 | specs/02-architecture/subsystems/SPATIAL_INTELLIGENCE_LOCKED.md | Cross-ref update + commit hash |
| 7 | specs/02-architecture/ARCHITECTURE.md | §21 competitive differentiator + PostGIS dependency |
| 8 | specs/01-product/PRODUCT_SPEC.md | Broadcast flow PostGIS authority reference |
| 9 | staging/SPATIAL_INTELLIGENCE_V3_AUDIT.md | This file |
