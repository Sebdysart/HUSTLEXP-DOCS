# TASK DISCOVERY SPECIFICATION

**Authority:** PRODUCT_SPEC §9 (Matching) | HUSTLER_UI_SPEC (Feed) | API_CONTRACT (task.getFeed)
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED
**Resolves:** GAP-22 (task discovery stub)

---

## §1. Discovery Channels

| Channel | Description | Entry Point |
|---|---|---|
| **Main Feed** | Personalized task feed based on eligibility + matching | Home screen |
| **Search** | Keyword + filter search | Search bar on feed |
| **Category Browse** | Browse by task category | Category tabs/chips |
| **Map View** | Geographic task discovery | Map tab on feed |
| **Saved Searches** | Stored filter combinations with notifications | Saved searches screen |
| **Deep Links** | Direct task links shared externally | Push notification / URL |
| **Recommendations** | AI-suggested tasks based on history | Feed "Recommended" section |

---

## §2. Feed Algorithm

### 2.1 Feed Query Pipeline

```
All OPEN tasks
  → Filter: eligibility (ARCHITECTURE §9 FEED_QUERY)
  → Filter: user_blocks (blocked users excluded)
  → Filter: geographic radius (user location ± radius_km)
  → Filter: category (if filter applied)
  → Sort: relevance score (§2.2)
  → Paginate: 20 per page, cursor-based
```

### 2.2 Relevance Score

Each task receives a composite score:

| Factor | Weight | Calculation |
|---|---|---|
| Distance | 0.30 | Inverse of distance (closer = higher) |
| Price per estimated hour | 0.25 | Normalized task price / estimated duration |
| Skill match | 0.20 | % of task requirements matching worker capabilities |
| Recency | 0.15 | Decay function from task.created_at |
| Poster rating | 0.10 | Poster's average rating (0-5 normalized) |

Ties broken by `created_at` descending (newer first).

### 2.3 Feed Sections

| Section | Content | Position |
|---|---|---|
| **Urgent** | Tasks with deadline < 4 hours, within 5km | Top (if any exist) |
| **Recommended** | Top 5 by relevance score | Below urgent |
| **Nearby** | All eligible tasks sorted by distance | Main list |
| **Live Mode** | Active LIVE broadcasts | Floating card (if any) |

---

## §3. Search & Filters

### 3.1 Search

- **Keyword search:** Full-text search on task title + description
- **Technology:** PostgreSQL `tsvector` / `tsquery` with `pg_trgm` for fuzzy matching
- **Minimum query length:** 2 characters
- **Results:** Same eligibility filtering as feed, ranked by text relevance × feed score

### 3.2 Filters

| Filter | Type | Options |
|---|---|---|
| Distance | Slider | 1km, 5km, 10km, 25km, 50km, Any |
| Price range | Range slider | $5 – $500 (STANDARD), $15 – $1000 (LIVE) |
| Category | Multi-select | All categories from SKILL_TAXONOMY |
| Task mode | Toggle | STANDARD / LIVE / Both |
| Posted within | Select | 1h, 4h, 12h, 24h, 7d, Any |
| Verified poster only | Toggle | Only show tasks from VERIFIED+ posters |

### 3.3 Filter Persistence

- Last-used filters persist per session (in-memory)
- Filters do NOT persist across app restarts (clean slate)
- Exception: saved searches persist indefinitely

---

## §4. Saved Searches

### 4.1 Schema

`saved_searches` table (already in schema.sql):
- user_id, name, filters (JSONB), notify (boolean), created_at

### 4.2 Behavior

- Maximum 10 saved searches per user
- If `notify = true`: background job runs saved search every 30 minutes
- If new tasks match since last check → push notification: "3 new tasks match your saved search '[name]'"
- Notification links to pre-filtered feed

---

## §5. Map View

- Map centered on user's current location
- Tasks shown as pins with price labels
- Pin tap → task card preview (poster name, title, price, distance)
- Card tap → full task detail screen
- Map respects same eligibility filters as feed
- Cluster pins when zoomed out (>20 pins visible)
- Uses Google Maps SDK (SPATIAL_INTELLIGENCE cost tier)

---

## §6. Empty States

| Condition | Message | Action |
|---|---|---|
| No tasks in area | "No tasks nearby. Try expanding your search radius." | Expand radius button |
| No tasks matching filters | "No tasks match your filters. Try adjusting." | Clear filters button |
| All tasks require higher trust tier | "Complete more tasks to unlock these opportunities." | Show trust tier progress |
| No tasks at all (new market) | "Be the first! Tasks will appear here as posters create them." | Invite a friend CTA |

---

## §7. Invariants

| ID | Rule | Enforcement |
|---|---|---|
| **DISC-1** | Feed never shows tasks user is ineligible for | FEED_QUERY eligibility gate |
| **DISC-2** | Feed never shows tasks from blocked users | user_blocks join filter |
| **DISC-3** | Saved search notifications throttled to 1/hour max per search | Background job dedup |
| **DISC-4** | Search results respect all safety filters (moderation, ban) | Same pipeline as feed |

---

## Amendment History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | Feb 2026 | HustleXP Core | Promoted from stub. Feed algorithm, search, filters, saved searches, map view, empty states. Resolves GAP-22. |
