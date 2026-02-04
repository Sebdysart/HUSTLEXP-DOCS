# SPATIAL INTELLIGENCE — Gap Analysis & Integration Plan

**STATUS:** ✅ IMPLEMENTED — v1 enhancements synced, v2 deferred
**Date:** Feb 2026
**Trigger:** External spec proposing Uber-level mapping integration
**Commit:** [PENDING]

---

## §1. PROPOSAL EVALUATION MATRIX

| Proposal Element | Status | Verdict | Rationale |
|---|---|---|---|
| Live Heat Maps / Hot Zones | Does NOT exist | **v2 DEFERRED** | FEATURE_FREEZE blocks demand visualization. Feed list handles discovery for v1. |
| Pedestrian-Level ETA / Travel Mode | PARTIAL (H7 has ETA, no mode) | **v1 ENHANCE** | Add travel mode selection (walk/drive/transit). Critical for task app. |
| Geofenced Smart Start (auto clock-in) | Does NOT exist | **REJECTED** | Auto-timekeeping = employer behavior → IC misclassification risk. Keep manual "I've Arrived" button. |
| Quest Batching (nearby task recs) | Does NOT exist | **v2 DEFERRED** | FEATURE_FREEZE blocks AI task recommendations. |
| GPS Movement Verification | PARTIAL (spoofing only) | **v1 ENHANCE** | Add movement pattern fraud signals. NOT productivity monitoring (IC compliance). |
| Cost-Tiered Map API | Does NOT exist | **v1 ADD** | Static tiles for feed, live navigation for en-route. Operational cost management. |
| Poster Live Location Visibility | UNDEFINED | **v1 ADD** | Privacy-first protocol: ETA only → approximate zone → precise at arrival. |
| Map as Game Board (XP on map) | Does NOT exist | **v2 DEFERRED** | Gamification overlay on maps is v2 polish, not v1 core. |

---

## §2. GAP INVENTORY (8 Gaps Found)

### CRITICAL (No coverage anywhere):
1. **No Maps/Spatial Authority in ARCHITECTURE.md** — Location logic scattered across 6+ files with no single source of truth
2. **No Map API Provider Lock** — BACKEND_STACK_LOCK is silent on maps. UI_SPEC says `mapsApi.getRoute()` with no provider
3. **No Poster Location Visibility Protocol** — When/how poster sees worker location is undefined
4. **No Travel Mode Spec** — H7 shows ETA with no walking/driving/transit mode
5. **No API Cost Tier Strategy** — No differentiation between static and live map usage
6. **No Geocoding/Address Validation Authority** — Tasks have lat/lng but no validation spec

### ENHANCEMENT (Partial coverage, needs strengthening):
7. **Movement Integrity** — RISK_TRUST_ENGINE has GPS spoofing but no movement pattern fraud detection
8. **Proximity Arrival Zone** — H7 has 100m arrival but no approaching-zone notification

---

## §3. ADOPT / DEFER / REJECT DECISIONS

### ADOPTED (v1):
- Travel mode selection → SPATIAL_INTELLIGENCE subsystem
- Poster visibility protocol → INV-PRIVACY-2 invariant
- Map API provider lock → BACKEND_STACK_LOCK §maps
- Cost-tiered API usage → SPATIAL_INTELLIGENCE subsystem
- Geocoding authority → SPATIAL_INTELLIGENCE subsystem
- Movement fraud signals → RISK_TRUST_ENGINE enhancement
- Proximity arrival notification → H7 enhancement

### DEFERRED (v2):
- Heat Maps / Hot Zones → Feed overlay showing demand density
- Quest Batching → "Nearby task starts in 45 min" suggestions
- Map as Game Board → XP/Gold markers on live map
- Constraints: Must comply with INV-PRIVACY-1, FEATURE_FREEZE

### REJECTED:
- Geofenced Smart Start → Auto clock-in is employer timekeeping behavior. IC misclassification risk.
- 2x Demand Earnings Projections → Regulatory risk without compliance review.

---

## §4. POSTER VISIBILITY DECISION (User Question)

**Question:** Should poster see exact live location from acceptance, or privacy-protected until within 1 mile?

**ANSWER: Privacy-first graduated visibility.**

| Task State | Poster Sees | Worker Consent | Rationale |
|---|---|---|---|
| ACCEPTED | ETA countdown only ("~18 min away") | Implicit (accepted task) | Worker is preparing, may not be moving yet |
| EN_ROUTE (>0.5mi) | ETA + direction ("Heading your way, ~12 min") | Implicit (opted into EN_ROUTE) | General direction without precise coords |
| EN_ROUTE (≤0.5mi) | Approximate zone (200m radius circle) | Implicit (approaching) | Poster can prepare for arrival |
| ARRIVED (≤100m) | Precise pin on map | Automatic (verified proximity) | Worker is at the property |

**Enforcement:** This is codified as INV-PRIVACY-2 in PRODUCT_SPEC. Violation = P0 bug.

---

## §5. SYNCED FILES MANIFEST

| # | File | Change |
|---|---|---|
| 1 | specs/02-architecture/subsystems/SPATIAL_INTELLIGENCE_LOCKED.md | **NEW** — Full subsystem spec |
| 2 | specs/02-architecture/ARCHITECTURE.md | §21 Spatial Intelligence Authority |
| 3 | BACKEND_STACK_LOCK.md | Map API provider lock (react-native-maps + Google Maps Platform) |
| 4 | specs/01-product/PRODUCT_SPEC.md | INV-PRIVACY-2 (poster visibility protocol) |
| 5 | specs/02-architecture/subsystems/RISK_TRUST_ENGINE_LOCKED.md | §4.4 Movement Integrity Protocol |
| 6 | specs/03-frontend/stitch-prompts/H7-en-route-map-screen.md | Travel mode selection + proximity notifications |
| 7 | FINISHED_STATE.md | §D enhanced with 8 new items |
| 8 | staging/SPATIAL_INTELLIGENCE_ANALYSIS.md | This analysis file |
