# Spatial Intelligence Engine v1.0

> **⚠️ SUPERSEDED — DO NOT IMPLEMENT**
> This file was superseded by `specs/02-architecture/subsystems/SPATIAL_INTELLIGENCE_LOCKED.md` (510 lines, Google Maps provider).
> This version used Mapbox and referenced outdated §14.6/§15. The authoritative spec now lives at §21.
> Archived: Feb 2026

**STATUS: ~~LOCKED — CONSTITUTIONAL AUTHORITY~~ → SUPERSEDED**
**Parent:** ~~ARCHITECTURE.md §14.6 (Maps Gate) + new §15 (Spatial Authority)~~ → See §21
**Governs:** All location, mapping, routing, geofencing, and GPS privacy operations

---

## §1. Prime Directive

```
Location data is audit evidence, not surveillance.
GPS serves the system, not the poster. Workers are not packages.
```

---

## §2. Map API Architecture

### 2.1 Provider Strategy

| Tier | Provider | Use Case | Cost Model |
|------|----------|----------|------------|
| Static | Mapbox Static Images API | Task feed cards, task detail preview | ~$0.50/1K req |
| Interactive | Mapbox Maps SDK (React Native) | EN_ROUTE navigation, worker map | ~$5.00/1K sessions |
| Geocoding | Mapbox Geocoding API | Address → coords, reverse lookup | ~$0.75/1K req |
| Directions | Mapbox Directions API | ETA calculation, route polyline | ~$5.00/1K req |
| Geofencing | Custom (PostGIS + device GPS) | Arrival detection, property boundary | Self-hosted ($0) |

### 2.2 Cost Control Rules (Non-Negotiable)

| Rule | Enforcement |
|------|-------------|
| Static maps for ALL feed/browse views | Frontend guard — no interactive map loads until task ACCEPTED |
| Interactive map ONLY during active task (ACCEPTED → terminal) | State machine gate — map SDK init blocked outside active states |
| Directions API called ONCE on acceptance, cached for session | Backend — no re-routing unless worker deviates >500m |
| Geocoding cached per address (TTL: 30 days) | Backend cache — addresses don't move |
| Zero map API calls in onboarding, settings, profile, XP screens | Frontend guard — map components lazy-loaded |

### 2.3 Monthly Cost Projection (1,000 active tasks/day)

| API | Calls/day | Monthly Cost |
|-----|-----------|-------------|
| Static Images | ~10,000 (feed browsing) | ~$150 |
| Directions | ~1,000 (1 per task) | ~$150 |
| Geocoding | ~200 (new addresses only) | ~$5 |
| Interactive sessions | ~2,000 (worker + poster per task) | ~$300 |
| **Total** | | **~$605/month** |

**Comparison:** Uber spends $1B+/yr on mapping. HustleXP rents the same power for <$10K/yr at scale.

---

## §3. Location Privacy Invariants

### INV-LOCATION-1: No Real-Time GPS Exposure

```
Worker GPS coordinates are NEVER exposed to posters in real-time.
Posters receive DERIVED signals only: ETA, proximity tier, arrival confirmation.
Raw GPS logs are stored for dispute audit ONLY.
```

**Enforcement:** Backend API — poster endpoints return ETA/proximity, never coordinates.

### INV-LOCATION-2: Collection Window

```
GPS collection is active ONLY during task states: ACCEPTED → terminal state.
GPS collection stops IMMEDIATELY on COMPLETED, CANCELLED, or EXPIRED.
No GPS between tasks. No background tracking. No home address capture.
```

**Enforcement:** State machine gate — GPS SDK disabled outside active task states.

### INV-LOCATION-3: Auto-Purge

```
GPS audit logs auto-purge after 90 days.
Exception: Active dispute — GPS retained until dispute resolved + 30 days.
```

**Enforcement:** Scheduled PostgreSQL job — `DELETE FROM gps_audit_log WHERE created_at < NOW() - INTERVAL '90 days' AND task_id NOT IN (SELECT task_id FROM disputes WHERE status = 'OPEN')`.

### INV-LOCATION-4: Feed Privacy

```
Task feed cards show NEIGHBORHOOD only (e.g., "Capitol Hill, Seattle").
Exact address revealed ONLY after task state = ACCEPTED.
Worker's departure location is NEVER stored or transmitted.
```

**Enforcement:** Frontend guard — geocode truncated to neighborhood in feed. Backend API — full address requires ACCEPTED state check.

---

## §4. Progressive Disclosure Model (Poster View)

This replaces the previous "Hustler live location" spec in §14.6.

| Task State | GPS Collected? | What Poster Sees | What Is Stored |
|------------|---------------|------------------|----------------|
| OPEN | No | Task location (static map thumbnail) | Nothing |
| ACCEPTED (pre-departure) | No | "Preparing to depart" | acceptance_timestamp |
| EN_ROUTE (>1 mile away) | Yes (30s intervals) | ETA countdown only ("Arriving in ~12 min") | GPS log (encrypted) |
| EN_ROUTE (≤1 mile) | Yes (15s intervals) | "Nearby" + ETA | GPS log (encrypted) |
| EN_ROUTE (≤0.1 mile) | Yes (10s intervals) | "Arriving now" | GPS log (encrypted) |
| ARRIVED (geofence triggered) | Snapshot only | "Worker has arrived ✅" | arrival_verification record |
| WORKING | No (unless liveness) | "Task in progress" | Nothing |
| COMPLETED | No | Completion screen | Final GPS snapshot |

### Why Not Live Location?

| Approach | Risk | HustleXP Decision |
|----------|------|--------------------|
| Exact live GPS pin (Uber style) | Surveillance, stalking risk, power imbalance | **REJECTED** |
| No tracking until arrival | Poster anxiety, high cancellation rate | **REJECTED** |
| Full opacity (no info at all) | Poster has no certainty, calls/texts worker | **REJECTED** |
| **Progressive disclosure (ETA → Nearby → Arrived)** | Poster gets certainty, worker keeps autonomy | **ADOPTED** |

### Worker GPS Rights

- Worker sees own location on map at all times during EN_ROUTE
- Worker sees navigation directions to task location
- Worker CANNOT be tracked after task completion
- Worker CANNOT be tracked between tasks
- Worker home/departure point NEVER transmitted to poster or stored
- GPS collection stops IMMEDIATELY on terminal state

---

## §5. Geofence Arrival Protocol

### 5.1 How It Works

```
1. Task ACCEPTED → backend geocodes task address → creates geofence circle
2. Geofence radius = 50m (adjustable per task type)
3. Worker device reports GPS at 30s intervals during EN_ROUTE
4. 2 consecutive pings inside geofence → ARRIVAL_VERIFIED event fired
5. UI auto-advances checklist: "Arrive at Location ✅ GPS Verified: [timestamp]"
6. No manual "I'm here" button needed (Smart Start)
```

### 5.2 Parameters

| Parameter | Default | Override |
|-----------|---------|---------|
| Radius | 50m | Large properties (farms, warehouses): 150m |
| Verification threshold | 2 consecutive pings inside fence | Prevents drive-by false positives |
| Late timeout | 60 min after ETA | Worker never enters → LATE flag |
| Fallback | Manual "I've arrived" button | GPS disabled / indoor / poor signal |

### 5.3 Anti-Spoof Protections

| Attack | Defense |
|--------|---------|
| GPS spoofing app | Device attestation (Play Integrity / App Attest) |
| VPN/proxy location | GPS-only (not IP-based), device sensor cross-check |
| Friend at location | Photo proof timestamp must match GPS timestamp (±5 min) |
| Drive-by ping | 2 consecutive pings required (min 30s inside geofence) |

---

## §6. ETA Engine

### 6.1 Transport Mode Selection

| Task Category | Default Mode | Rationale |
|---------------|-------------|-----------|
| Moving / Hauling | Driving | Worker likely has vehicle |
| Cleaning / Assembly | Walking or Transit | Local neighborhood tasks |
| Delivery / Grocery | Driving | Cargo requires vehicle |
| Yard Work / Manual | Driving | Equipment transport |
| Pet / Child Care | Walking | Proximity-based matching |

**Override:** Worker selects transport mode on acceptance. Defaults above.

### 6.2 ETA Display Rules

| Condition | Display | Example |
|-----------|---------|---------|
| ETA > 30 min | Round to 5 min | "Arriving in ~35 min" |
| ETA 10-30 min | Round to nearest min | "Arriving in ~12 min" |
| ETA 5-10 min | Exact minute | "Arriving in 7 min" |
| ETA < 5 min | Proximity label | "Almost there" |
| ETA < 1 min | Arrival label | "Arriving now" |
| Worker stationary >5 min EN_ROUTE | Add qualifier | "Arriving in ~15 min (may be delayed)" |

### 6.3 Pedestrian ETA Enhancements

Standard APIs optimize for cars. HustleXP adds:

- **Entrance precision:** Task address includes unit/door/gate notes displayed to worker
- **Walking-speed calibration:** 4.5 km/h (not API default 5.0) for loaded workers
- **Floor + elevator:** Poster specifies at task creation
- **Pin-drop for ambiguous locations:** Parks, campuses, large properties

---

## §7. Map UI Components

| Component | Screen | Map Type | Cost Tier |
|-----------|--------|----------|-----------|
| `StaticMapCard` | Task feed (H3), task detail (H4) | Static image | Low |
| `NavigationMapView` | Worker EN_ROUTE (H7) | Interactive + directions | High |
| `PosterETAView` | Poster On Way (P2) | **NO MAP — text ETA only** | Zero |
| `ArrivalBadge` | Worker checklist step (H5) | Geofence status | Zero |
| `TaskLocationPin` | Task creation (P1) | Interactive (place pin) | Medium |

### Feed Card Map Layout

```
┌─────────────────────────┐
│ [Static Map 128×128px]  │  ← Mapbox Static Image (low-cost)
│ 📍 Capitol Hill, Seattle│  ← Neighborhood only (INV-LOCATION-4)
│ ~0.8 mi away            │  ← From worker's general area
│ Move Furniture — $45    │
└─────────────────────────┘
```

---

## §8. Judge Agent GPS Signals

### 8.1 Movement Analysis (Advisory ONLY)

GPS movement patterns are ONE input signal. GPS alone is NEVER sufficient for penalty.

| Signal | Meaning | Judge Action |
|--------|---------|-------------|
| Stationary at task for expected duration | Normal | No action |
| Leaves geofence during WORKING | Possible abandonment | Flag + ask worker |
| Stationary >500m from task for >15 min | Suspicious | Flag + require photo proof |
| GPS disabled during active task | Cannot verify | Require manual proof, note in audit |

### 8.2 Hard Rules (Non-Negotiable)

- GPS movement is ADVISORY, not EVIDENCE
- Judge Agent CANNOT penalize based on GPS alone
- Worker explanation + photo proof overrides GPS suspicion
- "Sitting on curb" is NOT fraud — workers take breaks
- GPS data auto-purges per INV-LOCATION-3

---

## §9. v2 Deferred Features

### 9.1 Live Heat Maps (DEFERRED — FEATURE_FREEZE)

**Why deferred:** Requires demand aggregation AI, sufficient volume for stats, careful UX to avoid "surge pricing" perception.
**v2 constraints:** Demand density only (no earnings projections), 15-min refresh (not real-time), optional toggle, no push notifications from heat data.

### 9.2 Quest Batching (DEFERRED — FEATURE_FREEZE)

**Why deferred:** AI suggesting adjacent tasks = Adjacent Skill Prompt (already deferred in REACTIVE_SKILL_INTELLIGENCE_ANALYSIS).
**v2 constraints:** Max 1 suggestion/task, opt-in "route mode" only, no earnings projections, must preserve IC classification.

---

## §10. Forbidden Behaviors

| Forbidden | Why | Alternative |
|-----------|-----|-------------|
| Background GPS between tasks | INV-LOCATION-2 | GPS only ACCEPTED → terminal |
| Exact worker GPS to poster | INV-LOCATION-1, safety risk | Progressive disclosure (§4) |
| Penalize on GPS movement alone | False positives, breaks | Advisory + proof required (§8.2) |
| Push notifications from location data | "Creepy" factor, battery drain | Worker checks feed voluntarily |
| GPS retention >90 days | Privacy compliance | Auto-purge INV-LOCATION-3 |
| GPS "productivity scoring" | Anti-worker, IC violation | GPS = logistics tool, not performance metric |
| Earnings/XP shown on map | Conflicts with DC-1 dopamine cadence | Map shows tasks and locations only |
| Real-time route sharing | Stalking risk | ETA text only |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Feb 2026 | Initial spatial intelligence specification |

---

**END OF SPATIAL INTELLIGENCE ENGINE v1.0**
