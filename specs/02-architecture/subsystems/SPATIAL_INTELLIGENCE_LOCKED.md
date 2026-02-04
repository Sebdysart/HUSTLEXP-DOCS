# SPATIAL INTELLIGENCE SUBSYSTEM — LOCKED

**STATUS:** LOCKED — Implementation-ready, no further iteration
**Authority:** ARCHITECTURE.md §21
**Version:** 1.2.0
**Date:** Feb 2026

---

## §1. Purpose

Spatial Intelligence governs ALL map rendering, geocoding, routing, ETA computation, location sharing, and API cost management across HustleXP. This is the single source of truth for how the physical world maps to the digital task lifecycle.

**Constitutional principle:** The map is infrastructure, not surveillance. Every location API call must trace to an active task state or an explicit user action. Background spatial processing is prohibited (INV-PRIVACY-1).

---

## §2. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                SPATIAL INTELLIGENCE                   │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐│
│  │  GEOCODING    │  │  ROUTING     │  │  RENDERING  ││
│  │  ENGINE       │  │  ENGINE      │  │  ENGINE     ││
│  │              │  │              │  │             ││
│  │  Address →   │  │  A → B with  │  │  Static /   ││
│  │  Coordinates │  │  mode + ETA  │  │  Live tiles ││
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘│
│         │                 │                  │       │
│  ┌──────┴─────────────────┴──────────────────┴──────┐│
│  │            COST OPTIMIZATION LAYER                ││
│  │  Static tiles (feed) → $0 | Live nav (en-route) → $││
│  └──────────────────────────────────────────────────┘│
│                                                       │
│  ┌──────────────────────────────────────────────────┐│
│  │         PRIVACY ENFORCEMENT LAYER                 ││
│  │  INV-PRIVACY-1: Reactive only                     ││
│  │  INV-PRIVACY-2: Graduated poster visibility       ││
│  └──────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```


---

## §3. Technology Stack Lock

| Component | Provider | Justification |
|---|---|---|
| **Mobile Map SDK** | `react-native-maps` (Google Maps provider) | Cross-platform, battle-tested, supports both iOS/Android |
| **Geocoding API** | Google Maps Geocoding API | Address → coordinates. Required for task creation validation. |
| **Directions API** | Google Maps Directions API | Route polylines + ETA. Supports walking/driving/transit modes. |
| **Distance Matrix API** | Google Maps Distance Matrix API | Batch ETA calculations for feed proximity display. |
| **Static Maps API** | Google Maps Static Maps API | Zero-interaction map thumbnails for task cards in feed. |
| **Places API** | Google Maps Places Autocomplete | Address input with autocomplete during task creation. |

**Provider lock rationale:** Google Maps Platform chosen over Mapbox for:
- Superior geocoding accuracy in US suburban/residential areas (HustleXP's primary market)
- Native integration with `react-native-maps` (zero additional SDK)
- Walking directions quality (pedestrian routing critical for task workers)
- Single billing account covers all 5 APIs

**Cost model:** Pay-per-request. See §7 for optimization strategy.

---

## §4. Three Engines

### 4.1 Geocoding Engine

Converts addresses to coordinates and validates task locations.

```typescript
interface GeocodingResult {
  formatted_address: string;      // Normalized: "123 Main St, Seattle, WA 98101"
  coordinates: {
    latitude: number;             // 47.6062095
    longitude: number;            // -122.3320708
  };
  place_id: string;               // Google Place ID for deduplication
  location_type: 'ROOFTOP' | 'RANGE_INTERPOLATED' | 'GEOMETRIC_CENTER' | 'APPROXIMATE';
  confidence: 'HIGH' | 'MEDIUM' | 'LOW';
}
```

**Validation rules:**
- Task creation REQUIRES `location_type` = `ROOFTOP` or `RANGE_INTERPOLATED` (street-level accuracy)
- `GEOMETRIC_CENTER` or `APPROXIMATE` triggers AI clarification question (LOCATION_CLARITY)
- Geocoding runs server-side at task creation, NOT client-side (prevents spoofed coordinates)
- Result cached in `tasks.location_lat`, `tasks.location_lng`, `tasks.location_place_id`

**Schema addition:**
```sql
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS location_place_id VARCHAR(255);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS location_precision VARCHAR(30) 
  CHECK (location_precision IN ('ROOFTOP', 'RANGE_INTERPOLATED', 'GEOMETRIC_CENTER', 'APPROXIMATE'));
```

### 4.2 Routing Engine

Computes routes, ETAs, and polylines between worker and task location.

```typescript
interface RouteRequest {
  origin: { latitude: number; longitude: number };
  destination: { latitude: number; longitude: number };
  travelMode: 'WALKING' | 'DRIVING' | 'TRANSIT';
  departureTime?: Date;  // For traffic-aware ETAs
}

interface RouteResult {
  etaMinutes: number;
  distanceMeters: number;
  distanceMiles: number;
  polyline: string;                // Encoded polyline for map rendering
  travelMode: 'WALKING' | 'DRIVING' | 'TRANSIT';
  steps?: RouteStep[];             // Turn-by-turn (only for live navigation)
  trafficCondition?: 'LIGHT' | 'MODERATE' | 'HEAVY';
}
```

**Travel mode selection logic:**
```
IF task.category IN ('DELIVERY', 'GROCERY_HAUL', 'MOVING') → default DRIVING
ELSE IF distance < 1.5 miles → default WALKING
ELSE IF distance < 5 miles → default DRIVING
ELSE → default DRIVING

Worker can ALWAYS override the default travel mode.
```

**ETA refresh cadence:**
- EN_ROUTE state: Every 30 seconds (live)
- ACCEPTED state: Once at acceptance (static)
- Feed preview: Calculated from Distance Matrix at feed load (batch)

### 4.3 Rendering Engine

Three rendering tiers based on context:

| Tier | Context | Technology | Cost per Request | Interactivity |
|---|---|---|---|---|
| **STATIC** | Task card in feed | Static Maps API (image URL) | ~$0.002 | None (image only) |
| **INTERACTIVE** | Task detail / poster view | `react-native-maps` MapView | $0 (SDK, no API call) | Pan, zoom, tap |
| **LIVE NAVIGATION** | En-route (H7 screen) | `react-native-maps` + Directions API | ~$0.01/refresh | Real-time tracking |

---

## §5. Poster Location Visibility Protocol (INV-PRIVACY-2)

**Principle:** Worker location visibility graduates with proximity. Poster never sees exact coordinates until worker is physically at the task site.

### 5.1 Visibility State Machine

```
TASK ACCEPTED
  │
  │  Poster sees: ETA countdown ("~18 min away")
  │  Worker coords: NOT transmitted to poster
  │  Map shows: Task pin only (no worker marker)
  │
  ▼
EN_ROUTE (distance > 0.5 mi)
  │
  │  Poster sees: ETA + direction ("Heading your way, ~12 min")
  │  Worker coords: NOT transmitted to poster
  │  Map shows: Directional indicator (N/S/E/W arrow, not a pin)
  │
  ▼
EN_ROUTE (distance ≤ 0.5 mi)
  │
  │  Poster sees: Approximate zone (200m radius circle on map)
  │  Worker coords: Rounded to 200m grid (not exact)
  │  Map shows: Shaded circle approaching task pin
  │
  ▼
ARRIVED (distance ≤ 100m)
  │
  │  Poster sees: Precise worker pin on map
  │  Worker coords: Exact (verified by proximity check)
  │  Map shows: Worker pin + task pin
  │
  ▼
TASK IN PROGRESS
  │
  │  Poster sees: "Worker is on-site" (no live tracking)
  │  Worker coords: NOT transmitted (worker is at location)
  │  Map shows: Static task location only
```

### 5.2 Server-Side Enforcement

```typescript
function getWorkerLocationForPoster(
  workerCoords: { lat: number; lng: number },
  taskCoords: { lat: number; lng: number },
  taskState: TaskState
): PosterVisibleLocation {
  
  if (taskState === 'IN_PROGRESS' || taskState === 'COMPLETED') {
    return { type: 'ON_SITE', showWorkerPin: false };
  }
  
  const distanceMeters = haversine(workerCoords, taskCoords);
  
  if (distanceMeters > 800) {  // >0.5mi
    return { 
      type: 'DIRECTION_ONLY',
      direction: getCardinalDirection(workerCoords, taskCoords),
      etaMinutes: computeETA(workerCoords, taskCoords),
      showWorkerPin: false
    };
  }
  
  if (distanceMeters > 100) {  // 100m-800m
    return {
      type: 'APPROXIMATE_ZONE',
      center: roundToGrid(workerCoords, 200), // 200m grid snap
      radiusMeters: 200,
      etaMinutes: computeETA(workerCoords, taskCoords),
      showWorkerPin: false
    };
  }
  
  // ≤100m — arrived
  return {
    type: 'PRECISE',
    coordinates: workerCoords,
    showWorkerPin: true
  };
}
```

### 5.3 Privacy Invariant

**INV-PRIVACY-2: Poster Location Visibility Graduation**

Poster NEVER receives raw worker GPS coordinates until worker is within 100m of the task location and task state is ARRIVED or later. Prior to that threshold:
- >0.5mi: ETA + cardinal direction only
- ≤0.5mi: 200m-radius approximate zone only

**ENFORCEMENT:**
- Location graduation runs server-side (not client-side)
- Raw worker coords are NEVER sent to poster's device at >100m
- WebSocket updates transmit `PosterVisibleLocation` objects, not `{lat, lng}`
- P0 bug if raw coordinates leak to poster at any distance >100m

**IC COMPLIANCE:** This protects workers from surveillance by task requesters, reinforcing independent contractor status. Workers control their own route and timing — poster has no ability to monitor or direct movement.


---

## §6. Address Validation Authority

### 6.1 Task Creation Flow

```
Poster types address
  │
  ▼
Places Autocomplete (client-side)
  │  Suggests: "123 Main St, Seattle, WA 98101"
  │  Returns: place_id, formatted_address
  │
  ▼
Geocoding API (server-side validation)
  │  Converts: address → coordinates
  │  Validates: location_type = ROOFTOP or RANGE_INTERPOLATED
  │
  ├── HIGH confidence → Store in tasks table, proceed
  │
  └── LOW/MEDIUM confidence → Trigger LOCATION_CLARITY question
      │  "Can you confirm the exact address? We found multiple matches."
      │  AI Task Completion system handles disambiguation
      └── Poster confirms → Re-geocode → Store
```

### 6.2 Schema Integration

```sql
-- Tasks table location columns (existing + new)
-- EXISTING:
--   location VARCHAR(255),        -- Human-readable address
--   location_lat NUMERIC(10, 7),  -- Latitude
--   location_lng NUMERIC(10, 7),  -- Longitude

-- NEW (added by this spec):
--   location_place_id VARCHAR(255),      -- Google Place ID for dedup
--   location_precision VARCHAR(30),      -- Geocoding confidence level
```

### 6.3 Validation Rules

| Rule | Enforcement | Failure Mode |
|---|---|---|
| Address must geocode to street-level | Server-side geocoding | AI asks LOCATION_CLARITY question |
| Coordinates must be within continental US | Bounding box check: lat 24.5-49.0, lng -125.0 to -66.9 | Task creation blocked |
| PO Box addresses rejected for in-person tasks | Places API type check | "Please provide a street address" |
| Duplicate location detection | place_id comparison | Warning: "You have another task at this address" |

### 6.4 Arrival Instructions (Last-Meters Wayfinding)

Poster may provide free-text arrival instructions during task creation to guide workers through the final approach — "which door to enter," "which side of the park," "gate code is #1234," etc.

```typescript
interface ArrivalInstructions {
  text: string;            // Max 280 chars. Displayed on H7 when proximityZone = 'APPROACHING' or 'ARRIVAL'
  hasGateCode: boolean;    // If true, text is masked until worker is within ARRIVAL zone (100m)
}
```

**Display rules:**
- Arrival instructions appear in the H7 bottom sheet when worker enters APPROACHING zone (500m)
- If `hasGateCode = true`, the full text is masked ("Arrival instructions available when you arrive") until ARRIVAL zone (100m) — prevents premature sharing of security-sensitive access info
- Instructions are static text from task creation — NOT generated by AI
- Stored in `tasks.arrival_instructions` (VARCHAR 280) and `tasks.arrival_has_gate_code` (BOOLEAN DEFAULT false)

**Schema addition:**
```sql
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS arrival_instructions VARCHAR(280);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS arrival_has_gate_code BOOLEAN DEFAULT false;
```

---

## §7. API Cost Optimization Strategy

### 7.1 Cost Matrix

| API | Trigger | Cost/Request | Monthly Estimate (1K users) |
|---|---|---|---|
| Static Maps | Task card in feed (cached 24h) | $0.002 | ~$60 |
| Geocoding | Task creation (once per task) | $0.005 | ~$25 |
| Places Autocomplete | Address typing (per session) | $0.00283/session | ~$15 |
| Directions | EN_ROUTE refresh (30s interval) | $0.005-0.01 | ~$150 |
| Distance Matrix | Feed load (batch, cached 1h) | $0.005/element | ~$100 |

**Total estimated: ~$350/month at 1K active users**

### 7.2 Cost Reduction Rules

| Rule | Savings | Implementation |
|---|---|---|
| Cache static map tiles for 24 hours | ~60% on Static Maps | CDN + `Cache-Control: max-age=86400` |
| Cache Distance Matrix results for 1 hour | ~80% on Distance Matrix | Redis cache keyed by `{worker_grid}:{task_id}` |
| Only compute Directions when EN_ROUTE | ~90% reduction | No routing API calls in ACCEPTED or feed states |
| Batch Distance Matrix (up to 25 origins × 25 destinations per call) | ~95% on feed proximity | Single API call per feed load |
| Limit Places Autocomplete to 3 chars minimum | ~50% reduction | Client-side debounce + min length |
| Geocode once at task creation, never re-geocode | 100% on re-geocoding | Store result in `tasks.location_place_id` |

### 7.3 Budget Alerts

| Threshold | Action |
|---|---|
| >$500/month | Alert to ops team |
| >$1,000/month | Audit API usage patterns |
| >$2,000/month | Consider Mapbox fallback evaluation |
| >$5,000/month | Mandatory optimization sprint |

---

## §8. Proximity & Arrival System

### 8.1 Geofence Zones (Passive, NOT Auto-Clock-In)

```
┌──────────────────────────────────────────┐
│                                          │
│     APPROACHING ZONE (500m radius)       │
│     ┌──────────────────────────────┐     │
│     │                              │     │
│     │   ARRIVAL ZONE (100m radius) │     │
│     │   ┌──────────────────────┐   │     │
│     │   │                      │   │     │
│     │   │    📍 TASK SITE      │   │     │
│     │   │                      │   │     │
│     │   └──────────────────────┘   │     │
│     │   "I've Arrived" ENABLED     │     │
│     │                              │     │
│     └──────────────────────────────┘     │
│     Notification: "Almost there!"        │
│                                          │
└──────────────────────────────────────────┘
```

### 8.2 Zone Triggers

| Zone | Radius | Worker Experience | Poster Experience | Automatic? |
|---|---|---|---|---|
| **Approaching** | 500m | Notification: "Almost there! Task location ahead." | "Worker is nearby" | Yes (notification only) |
| **Arrival** | 100m | "I've Arrived" button enabled (was disabled) | Precise pin appears on map | Button enabled, NOT auto-triggered |
| **On-Site** | Worker taps "I've Arrived" | Task transitions to IN_PROGRESS | "Worker has arrived" notification | Manual tap REQUIRED |

### 8.3 Why NOT Auto-Clock-In (Geofenced Smart Start)

**REJECTED.** Auto-clock-in via geofence is dangerous for three reasons:

1. **IC Classification Risk:** Automatic timekeeping by the platform = employer behavior under IRS 20-factor test (Factor 12: "Set hours of work"). Workers must self-report arrival as independent businesses.

2. **False Triggers:** GPS accuracy in urban areas is ±15m. Workers passing nearby (e.g., walking past on sidewalk) would trigger false arrivals. 100m geofence in a city could trigger on an adjacent building.

3. **Worker Autonomy:** Workers may arrive at a property but need 5 minutes to prepare (park, gather tools, review task details). Auto-clock-in removes their control over when work begins.

**Decision:** Manual "I've Arrived" button within 100m is the correct v1 approach. The button is clearly ENABLED (visual state change) when in the arrival zone, but the worker decides when to tap it.

---

## §9. Movement Integrity Protocol (Anti-Fraud Only)

**CRITICAL BOUNDARY:** Movement analysis is EXCLUSIVELY for fraud detection. It is NEVER used for:
- Productivity monitoring ("worker is slow")
- Route enforcement ("worker took wrong route")
- Break detection ("worker stopped for 10 minutes")

These would constitute employer supervision, violating IC classification requirements.

### 9.1 Fraud Signals (What IS Monitored)

| Signal | Detection | Threshold | Action |
|---|---|---|---|
| **Stationary during active physical task** | GPS shows <5m movement for 30+ min during task categorized as physical labor | 30 min continuous | Shadow flag for human review |
| **Impossible speed** | Worker moves >120mph between GPS pings | Single occurrence | GPS spoofing alert to RISK_TRUST_ENGINE |
| **Location mismatch** | Worker GPS is >1km from task location during IN_PROGRESS | Continuous for 15+ min | Shadow flag + verification prompt |
| **Oscillating position** | GPS coordinates bounce between 2+ fixed points (emulator signature) | 5+ oscillations in 10 min | GPS_ANOMALY flag (RISK_TRUST_ENGINE §4.3) |

### 9.2 What is NOT Monitored

| Signal | Why NOT |
|---|---|
| Route efficiency | Worker chooses own route (IC autonomy) |
| Break duration | Worker sets own schedule (IC autonomy) |
| Walking speed | Not an employer performance metric |
| Task duration vs estimate | Workers are not timed (IC autonomy) |
| Location between tasks | INV-PRIVACY-1 prohibits non-task GPS |

### 9.3 Integration with RISK_TRUST_ENGINE

Movement fraud signals feed into `behavioral_scores.spatial_integrity` (0-100):

```typescript
interface MovementFraudSignal {
  task_id: string;
  signal_type: 'STATIONARY_ANOMALY' | 'IMPOSSIBLE_SPEED' | 'LOCATION_MISMATCH' | 'OSCILLATING_POSITION';
  detected_at: string;          // ISO timestamp
  evidence: {
    gps_points: Array<{ lat: number; lng: number; timestamp: string }>;
    task_location: { lat: number; lng: number };
    distance_from_task_m: number;
    duration_seconds: number;
  };
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
  action: 'LOG' | 'SHADOW_FLAG' | 'VERIFICATION_PROMPT' | 'SUSPEND_REVIEW';
}
```

**Escalation path:** Signal → RISK_TRUST_ENGINE behavioral_scores.spatial_integrity deduction → Shadow Level adjustment → If severe: human review queue. Worker is NEVER auto-penalized by movement analysis alone.

---

## §10. v2 Roadmap (Deferred Features)

### 10.1 Heat Maps / Hot Zones (v2)

Worker sees a map overlay showing demand density by area. "Hot Zones" indicate areas with high task concentration.

**Constraints when implemented:**
- Demand data aggregated at 1km² grid level (no individual task locations exposed)
- Updated every 15 minutes (not real-time — prevents gaming)
- No earnings projections ("you could earn $X here" requires regulatory review)
- Opt-in only (worker must enable "Demand View" in settings)
- Must comply with INV-PRIVACY-1 (no background location to compute "nearby" demand)

### 10.2 Quest Batching (v2)

AI suggests nearby tasks when worker completes one: "There's a Grocery Haul 0.3mi away starting in 45 min."

**Constraints when implemented:**
- Max 1 suggestion per task completion
- Max 3 suggestions per day per worker
- No push notifications (in-app banner only)
- Worker must explicitly tap to view suggested task
- Suggestion based on public task feed, not worker tracking
- Must comply with FEATURE_FREEZE gates

### 10.3 Map as Game Board (v2)

XP markers, Gold indicators, and badge progress overlaid on the map view. Workers see the physical world as a game board.

**Constraints when implemented:**
- Cosmetic overlay only (no gameplay mechanics tied to location)
- XP markers only appear at task locations worker has completed
- No "nearby XP" lures (would violate INV-PRIVACY-1 by requiring background location)

---

## §11. Cross-Reference Matrix

| This Spec Section | References | Referenced By |
|---|---|---|
| §3 Tech Stack | BACKEND_STACK_LOCK §maps, §extensions | — |
| §4 Routing Engine | H7 stitch prompt (travel mode) | UI_SPEC §5.5 |
| §4 PostGIS Queries | FEED_QUERY §6 (`location_geog`, `ST_DWithin`) | MATCHING_ALGORITHMS (distance_score) |
| §4 Schema | schema.sql v1.4.0 (`location_geog`, GIST index, trigger) | migration 006 |
| §5 Poster Visibility | PRODUCT_SPEC INV-PRIVACY-2 | P2 HustlerOnWay screen |
| §5 Privacy Enforcement | PRODUCT_SPEC INV-PRIVACY-1 | RISK_TRUST_ENGINE §4 |
| §6 Address Validation | AI Task Completion (LOCATION_CLARITY) | PRODUCT_SPEC §8 |
| §6.4 Arrival Instructions | Task creation form, H7 bottom sheet | schema.sql tasks table |
| §7 Cost Optimization | BACKEND_STACK_LOCK Tier 15 | Ops budget planning |
| §8 Proximity Zones | H7 stitch prompt (arrival) | SCREEN_REGISTRY (H7) |
| §9 Movement Integrity | RISK_TRUST_ENGINE §4.4 | JUDGE_AGENT (evidence) |
| §10 v2 Deferred | FINISHED_STATE.md v2 roadmap | FEATURE_FREEZE |
| §13 Permissions | O6 stitch prompt, app manifest | PRODUCT_SPEC INV-PRIVACY-1 |
| §14 Battery | H7 stitch prompt (update frequency) | Device performance targets |
| §15 Degradation | H7 fallback states, RISK_TRUST_ENGINE | Manual arrival scoring |

---

## §12. Verification Checklist

Before implementation, verify:

- [ ] Google Maps Platform API key provisioned with all 5 APIs enabled
- [ ] `react-native-maps` installed with Google Maps provider configured
- [ ] PostGIS extension enabled (`CREATE EXTENSION postgis`)
- [ ] `tasks` table has `location_geog GEOGRAPHY(POINT, 4326)` column with GIST index
- [ ] `sync_task_location_geog` trigger auto-populates geography from lat/lng
- [ ] `tasks` table has `location_place_id` and `location_precision` columns
- [ ] Poster WebSocket transmits `PosterVisibleLocation`, NEVER raw coordinates at >100m
- [ ] Movement fraud signals route to RISK_TRUST_ENGINE behavioral_scores
- [ ] Static map cache (24h) and Distance Matrix cache (1h) configured in Redis
- [ ] API budget alerts configured at $500/$1K/$2K/$5K thresholds
- [ ] Travel mode selector renders on H7 screen
- [ ] "Almost there!" notification fires at 500m zone entry
- [ ] "I've Arrived" button disabled outside 100m zone
- [ ] No background location permissions in app manifest

---

## §13. Location Permissions Protocol

### 13.1 Permission Hierarchy

HustleXP requests ONLY foreground location permission. Background location is NEVER requested (INV-PRIVACY-1).

| Platform | Permission | When Requested | Fallback if Denied |
|---|---|---|---|
| **iOS** | `NSLocationWhenInUseUsageDescription` | O6 onboarding screen (first launch) | Manual address entry. Feed shows all tasks (no proximity sort). |
| **iOS** | `NSLocationAlwaysUsageDescription` | **NEVER REQUESTED** | N/A — background location is prohibited |
| **Android** | `ACCESS_FINE_LOCATION` | O6 onboarding screen (first launch) | Manual address entry. Feed shows all tasks (no proximity sort). |
| **Android** | `ACCESS_BACKGROUND_LOCATION` | **NEVER REQUESTED** | N/A — background location is prohibited |

### 13.2 Permission Request Flow

```
App Launch → O6 Location Setup Screen
  │
  ├── OS Permission Dialog appears
  │     ├── "Allow While Using App" → ✅ Full spatial features enabled
  │     ├── "Allow Once" → ✅ Works for session, re-prompt next launch
  │     └── "Don't Allow" → Graceful degradation (§15)
  │
  ├── If previously denied → Show in-app explanation card:
  │     "Location helps you find nearby tasks and navigate to them.
  │      You can enable it in Settings → HustleXP → Location."
  │     [Open Settings] [Continue Without]
  │
  └── Worker can ALWAYS use app without location (manual address search)
```

### 13.3 EN_ROUTE Permission Escalation

When a worker taps "Start Navigation" (H7 screen), if location permission was previously denied:

```
"To navigate to this task, HustleXP needs your location.
 This is only used while you're traveling to the task."
 [Enable Location] [Use External Maps App]
```

If worker chooses "Use External Maps App" → deep-link to Apple Maps/Google Maps with task coordinates. H7 screen shows static route without live tracking. "I've Arrived" button enabled by manual tap (no proximity verification — lower confidence, logged in RISK_TRUST_ENGINE).

### 13.4 Privacy-First Language

All permission dialogs use privacy-first language:
- ✅ "Find tasks near you" (benefit to worker)
- ✅ "Navigate to your next task" (worker-initiated)
- ❌ Never: "Track your location" (surveillance language)
- ❌ Never: "Monitor your route" (employer language)

---

## §14. Battery & Performance Optimization

### 14.1 Location Update Frequency by State

| Task State | Update Frequency | Accuracy | Battery Impact |
|---|---|---|---|
| **No active task** | None (no GPS) | N/A | Zero |
| **ACCEPTED** (before EN_ROUTE) | None | N/A | Zero |
| **EN_ROUTE** (>500m from task) | Every 15 seconds | ~50m (balanced) | Low |
| **EN_ROUTE** (≤500m, APPROACHING) | Every 10 seconds | ~20m (high) | Medium |
| **ARRIVAL** (≤100m) | Every 5 seconds | ~10m (best) | Medium-High |
| **IN_PROGRESS** | None (worker is on-site) | N/A | Zero |

### 14.2 Optimization Rules

| Rule | Implementation | Savings |
|---|---|---|
| Stop GPS when not EN_ROUTE | No location subscriptions outside active navigation | ~100% between tasks |
| Reduce accuracy at distance | `kCLLocationAccuracyHundredMeters` when >500m, `kCLLocationAccuracyBest` when <100m | ~40% during navigation |
| Batch ETA recalculations | Directions API every 30s, not every GPS tick | ~80% on API calls |
| Kill location on IN_PROGRESS | Worker is on-site, no tracking needed | 100% after arrival |
| Use significant-change monitoring for zone detection | iOS: `startMonitoringSignificantLocationChanges()` for 500m/100m zone entry only | ~90% vs continuous |

### 14.3 Performance Targets

| Metric | Target | Measurement |
|---|---|---|
| Battery drain during 30min EN_ROUTE | <5% | Test on iPhone 12 min-spec device |
| Time to first location fix | <3 seconds | Cached location + fresh fix |
| Map tile loading | <500ms (cached), <2s (fresh) | Static tile CDN |
| Route polyline render | <200ms | Single Directions API response |

---

## §15. Degraded Location Fallback

### 15.1 Failure Modes

| Failure | Detection | User Experience | Data Impact |
|---|---|---|---|
| **GPS permission denied** | OS permission check returns `denied` | Feed shows all tasks (no proximity sort). Manual address search enabled. | No distance_score in matching. |
| **GPS unavailable (indoor/tunnel)** | Location update timeout >30s | Banner: "Location unavailable — last known: 2 min ago." ETA frozen at last value. | Last known coords used for proximity. |
| **GPS low accuracy (>200m)** | `horizontalAccuracy > 200` | Warning icon on ETA chip. "Approximate location." | Proximity zones use wider thresholds (+100m buffer). |
| **Google Maps API failure** | HTTP 4xx/5xx or timeout >5s | Static map fallback (cached tiles). Route polyline hidden. ETA shows "Unavailable." | Feed uses cached Distance Matrix. |
| **Network offline** | No connectivity | "You're offline" banner. Cached map tiles still render. No ETA updates. | "I've Arrived" still works (manual tap, no proximity verification). |

### 15.2 Graceful Degradation Priority

```
FULL FEATURES (GPS + Network + API)
  │  ↓ GPS denied
MANUAL MODE (No proximity sort, manual address, external navigation)
  │  ↓ Network offline
CACHED MODE (Cached map tiles, no ETA, manual arrival)
  │  ↓ Everything fails
TEXT-ONLY MODE (Address text, no map, full manual operation)
```

### 15.3 "I've Arrived" Without GPS

If GPS is unavailable when worker taps "I've Arrived":
- Button is ALWAYS tappable (no hard GPS gate — worker autonomy)
- Arrival logged with `verification_method: 'MANUAL'` (vs `'GPS_VERIFIED'`)
- RISK_TRUST_ENGINE scores manual arrivals slightly lower on spatial_integrity (80 vs 100)
- If worker has pattern of manual-only arrivals, Shadow Level review (not penalty)
- Poster still receives "Worker has arrived" notification regardless of verification method

---

**This subsystem is LOCKED (v1). Do not iterate further.**
**Commit hash binding:** 2a5a524
