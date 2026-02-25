# BACKEND STACK LOCK v1.0.0

**Status:** LOCKED FOR V1 — No Alternatives Permitted
**Date:** 2025-01-20
**Authority:** Constitutional backend specification for HustleXP

---

## 🔒 LOCK STATEMENT

**This stack is LOCKED for HustleXP v1.**

No migrations to Supabase, Convex, Firebase, Prisma ORM, GraphQL, REST, or alternative backends are permitted until v1 ships.

This document defines the ONLY backend stack authorized for implementation.

---

## 🧠 WHY THIS STACK

HustleXP is a **rules-heavy, trust-gated, eligibility-driven execution system**, not a CRUD app.

Requirements:
- Deterministic authority (Postgres enforces invariants)
- Explicit state machines (code, not conventions)
- SQL-level enforcement (triggers, constraints, FK)
- Auditable recomputation (capability profiles)
- Zero magic (no ORMs hiding logic)

**This stack supports that goal. Others do not.**

---

## 📦 TIER 0: DATABASE (AUTHORITY LAYER)

### ✅ PostgreSQL 15+ on Neon

**Why Neon:**
- Pure PostgreSQL (no opinionated framework)
- Serverless branching for testing
- Schema-first development
- Excellent with Claude Code
- No auth, no RLS, no hidden logic

**Database Client:**
- `pg` (node-postgres) — direct SQL access
- NO Prisma, NO TypeORM, NO Sequelize
- Reason: ORMs hide authority, create N+1 queries, obscure invariants

**Migration Tool:**
- `node-pg-migrate` — SQL-first migrations
- Reason: Migrations are SQL files, not framework abstractions

**Connection Pooling:**
- `pg.Pool` with max 20 connections
- Connection timeout: 30s
- Idle timeout: 10s

**What lives in Postgres:**
- Tasks, escrows, proofs, disputes
- XP ledger, trust ledger, badges
- Capability profiles, verified trades
- Verification records (license, insurance, background)
- Eligibility joins (SQL JOIN, not post-filtering)
- State machine constraints (CHECK, FK, triggers)
- All invariants (INV-1 through INV-5, INV-ELIGIBILITY-1 through 8)

**Required Extensions:**

| Extension | Purpose | Authority |
|-----------|---------|-----------|
| **PostGIS** | All geospatial queries — proximity filtering, radius search, geo-bounded broadcasts | SPATIAL_INTELLIGENCE_LOCKED.md §3-§4, FEED_QUERY §6, MATCHING_ALGORITHMS |

- Neon supports PostGIS natively (no add-on required)
- Enables `GEOGRAPHY(POINT, 4326)` column type + GIST spatial index
- O(log n) radius queries vs O(n) full table scan with `earth_distance`
- All geospatial queries standardized on PostGIS (schema.sql v1.4.0, migration 006)

**Forbidden:**
- ❌ Supabase (auth + RLS causes hidden authority)
- ❌ Convex (JS-first, no real SQL authority)
- ❌ Firebase Firestore (no SQL, no invariants)
- ❌ MongoDB (no schema enforcement)

---

## ⚙️ TIER 1: BACKEND RUNTIME

### ✅ Node.js 20 LTS + TypeScript 5+

**Why:**
- Mature ecosystem
- First-class Postgres tooling
- Excellent job queue + worker support
- Claude Code works best here
- No edge runtimes (need stateful workers)

**TypeScript Config:**
- `strict: true`
- `noUncheckedIndexedAccess: true`
- `exactOptionalPropertyTypes: true`
- Target: ES2022
- Module: CommonJS (for workers)

**Package Manager:**
- `npm` (lock file: package-lock.json)
- Reason: Universal, no extra tooling

**Forbidden:**
- ❌ Deno (immature ecosystem)
- ❌ Bun (unproven for production)
- ❌ Edge runtimes (Cloudflare Workers, Vercel Edge) — no stateful workers

---

## 🔌 TIER 2: API LAYER

### ✅ tRPC v10+

**Why:**
- End-to-end type safety
- No OpenAPI drift
- Contracts live in code
- Clear read vs write separation (query vs mutation)

**Structure:**
- Routers: feed, task, verification, eligibility, onboarding
- Context: `{ userId: string | null }`
- Middleware: auth, logging, error handling
- Procedures: query (read-only), mutation (write)

**Error Handling:**
- All errors mapped to HX error codes (HX001, HX101, HX201, etc.)
- No raw Postgres errors leaked to client
- Error shape: `{ code: string, message: string, field?: string }`

**Forbidden:**
- ❌ REST (manual route definitions, no type safety)
- ❌ GraphQL (over-fetching, N+1, resolver complexity)
- ❌ gRPC (overkill for web + mobile)

---

## 🔄 TIER 3: BACKGROUND PROCESSING

### ✅ BullMQ + Redis

**Why:**
- Industry-standard job queue
- Redis-backed persistence
- Retries, delays, priorities
- Separate workers from handlers

**Job Types:**
- `capability.recompute` — triggered by verification state changes
- `verification.resolve` — process pending verifications
- `verification.expire` — daily cron for expired credentials
- `feed.invalidate` — invalidate cache on capability changes
- `analytics.aggregate` — batch analytics processing

**Worker Separation:**
- Handlers emit jobs (lightweight, return fast)
- Workers mutate authority tables (heavy, transactional)
- Workers run in separate process: `npm run worker`

**Redis Config:**
- Host: Upstash Redis (serverless)
- Max connections: 10
- Retry strategy: Exponential backoff
- Job retention: 7 days

**Forbidden:**
- ❌ In-memory queues (Bull without Redis) — no persistence
- ❌ Database-backed queues (pg-boss) — slow, pollutes DB
- ❌ AWS SQS (vendor lock-in, overkill)

---

## 🔐 TIER 4: AUTHENTICATION

### ✅ Firebase Auth (Identity Only)

**Why:**
- Only provides identity (UID)
- UID maps to internal `users.id`
- Auth ≠ permissions ≠ eligibility ≠ trust
- Handles phone verification, email verification

**Token Verification:**
- Firebase Admin SDK verifies tokens
- Token → UID → `users.id`
- No role claims in tokens (roles in DB)

**What Firebase Does:**
- Phone verification (SMS OTP)
- Email verification
- Password reset
- Token issuance

**What Firebase Does NOT Do:**
- ❌ Authorization (no Firestore rules)
- ❌ Eligibility checks (capability profiles)
- ❌ Trust tier enforcement (trust ledger)
- ❌ Task access control (feed query)

**Forbidden:**
- ❌ Supabase Auth (couples with RLS)
- ❌ Clerk (opinionated, unnecessary features)
- ❌ Auth0 (overkill, expensive)
- ❌ Custom JWT (reinventing the wheel)

---

## 📁 TIER 5: FILE STORAGE

### ✅ Cloudflare R2 (S3-compatible API)

**Why:**
- S3-compatible API (drop-in replacement)
- Zero egress fees (significant cost savings)
- Presigned URLs (client-direct upload)
- No backend proxying (bandwidth savings)
- Lifecycle policies (auto-delete old proofs)

**Buckets:**
- `hustlexp-proof-photos` — task proof photos
- `hustlexp-verification-docs` — license, insurance docs
- `hustlexp-user-avatars` — profile photos

**Upload Flow:**
1. Client requests presigned URL from backend
2. Backend generates presigned POST URL (10min TTL)
3. Client uploads directly to R2
4. Client confirms upload to backend
5. Backend validates file exists, stores R2 key in DB

**Security:**
- Presigned URLs expire after 10 minutes
- All objects private (no public read)
- Backend serves via Cloudflare CDN

**Forbidden:**
- ❌ Cloudinary (expensive, unnecessary features)
- ❌ Supabase Storage (couples with auth)
- ❌ Vercel Blob (vendor lock-in)
- ❌ Direct backend upload (wastes bandwidth)

---

## 💾 TIER 6: CACHING

### ✅ Redis (Upstash Serverless)

**Why:**
- Fast (sub-millisecond reads)
- Shared across all backend instances
- TTL support (auto-expiration)

**Cache Keys:**
- `feed:{userId}:{mode}` — feed results (TTL: 60s normal, 15s urgent)
- `capability:{userId}` — capability profile (TTL: 300s)
- `task:{taskId}` — task details (TTL: 60s)
- `user:{userId}:session` — session data (TTL: 3600s)

**Cache Invalidation:**
- Capability recompute → invalidate `feed:{userId}:*`, `capability:{userId}`
- Task state change → invalidate `task:{taskId}`, `feed:*`
- Manual invalidation: `FLUSHDB` (admin only)

**Forbidden:**
- ❌ In-memory caching (no shared state across instances)
- ❌ Database caching (too slow)
- ❌ Memcached (Redis is better)

---

## 📧 TIER 7: COMMUNICATIONS

### ✅ Email: SendGrid

**Why:**
- Simple API
- Transactional email reliability
- Webhook support (delivery tracking)

**Email Types:**
- Verification emails (email confirmation)
- Password reset
- Verification status updates
- Dispute notifications

### ✅ SMS: Twilio

**Why:**
- Industry standard for SMS
- Phone verification (OTP)
- Reliable delivery

**SMS Types:**
- Phone verification OTP
- Urgent task notifications (opt-in only)

**Forbidden:**
- ❌ AWS SES (good but more complex than SendGrid)
- ❌ Mailgun (less reliable than SendGrid)
- ❌ Postmark (unnecessary for our volume)

---

## 💳 TIER 8: PAYMENTS

### ✅ Stripe

**Why:**
- Industry standard for escrow-based marketplaces
- Excellent Connect API for payouts
- Webhook reliability
- PCI compliance handled

**Integration:**
- Stripe Connect (split payments: platform fee + worker payout)
- Payment Intents API (not Checkout Sessions)
- Webhook verification (signature checking)

**Escrow Flow:**
1. Poster funds escrow → Stripe Payment Intent
2. Funds held in Stripe (not released)
3. Task completed → Backend releases to worker via Connect Transfer
4. Stripe handles payouts to worker bank account

**Forbidden:**
- ❌ PayPal (bad API, unreliable webhooks)
- ❌ Square (not designed for marketplaces)
- ❌ Braintree (owned by PayPal, legacy)

---

## 🛡️ TIER 9: MONITORING & OBSERVABILITY

### ✅ Error Tracking: Sentry

**Why:**
- Best-in-class error tracking
- Source maps support
- User context (userId in breadcrumbs)

**What to Track:**
- All uncaught exceptions
- Failed invariant assertions
- Failed recompute operations
- Failed verification resolutions

### ✅ Logging: Pino (structured JSON logs)

**Why:**
- Fast (async logging)
- Structured (JSON output)
- Context-aware (userId, taskId, requestId)

**Log Levels:**
- `error` — failures (invariants, DB errors)
- `warn` — degraded performance (slow queries)
- `info` — key events (recompute, verification)
- `debug` — detailed traces (dev only)

**Log Destination:**
- Development: stdout (pretty-printed)
- Production: stdout → Railway logs → Logtail/Papertrail

### ✅ Metrics: Prometheus + Grafana

**Why:**
- Industry standard for metrics
- Histogram support (latency percentiles)
- Alerting (PagerDuty integration)

**Metrics:**
- `feed_query_duration_ms` (p50, p95, p99)
- `recompute_duration_ms` (p50, p95, p99)
- `recompute_failures_total` (counter)
- `verification_processing_duration_ms` (histogram)
- `api_requests_total` (counter, by endpoint)
- `api_errors_total` (counter, by error code)

**Forbidden:**
- ❌ Console.log (unstructured, no context)
- ❌ Winston (slower than Pino)
- ❌ Custom logging (reinventing the wheel)

---

## 🧪 TIER 10: TESTING

### ✅ Unit Tests: Vitest

**Why:**
- Vite-native, fast execution
- ESM-first with great TypeScript support
- Jest-compatible API (easy migration)
- Built-in code coverage (v8/istanbul)

**Test Types:**
- Unit tests: Services, utilities
- Integration tests: API endpoints (with test DB)
- Invariant tests: Kill tests (must fail on violations)
- E2E tests: Full user journeys

**Test Database:**
- Separate test DB (reset between tests)
- Use transactions (rollback after each test)
- Fixtures: Minimal data setup

**Coverage Target:**
- Services: 90%+
- Invariants: 100%
- API endpoints: 80%+

### ✅ Load Testing: k6

**Why:**
- Realistic load simulation
- Prometheus integration
- CI/CD friendly

**Load Tests:**
- Feed query: 100 RPS sustained
- Capability recompute: 50 RPS sustained
- Task creation: 20 RPS sustained

**Forbidden:**
- ❌ Manual testing (not reproducible)
- ❌ Jest (slower, CJS-first; migrated to Vitest)
- ❌ Mocha (Vitest is better)
- ❌ AVA (immature)

---

## 🚀 TIER 11: DEPLOYMENT

### ✅ Platform: Railway

**Why:**
- Simple deployment (Dockerfile or Nixpacks)
- Automatic scaling
- Low latency to Neon Postgres
- No vendor lock-in (Docker-based)
- Excellent DX (GitHub integration, preview environments)

**Architecture:**
- API server: auto-scaling instances
- Worker process: separate Railway service
- Redis: Upstash (managed)
- Postgres: Neon (managed)

**Health Checks:**
- Endpoint: `GET /health`
- Checks: DB connection, Redis connection
- Frequency: Every 10s

**Graceful Shutdown:**
- SIGTERM handler (drain connections)
- Max 30s shutdown grace period

**Alternative:** Fly.io (similar to Railway, equally acceptable)

**Forbidden:**
- ❌ Vercel (no stateful workers, edge runtime limitations)
- ❌ AWS EC2 (overkill, manual management)
- ❌ Heroku (expensive, legacy)
- ❌ Google Cloud Run (vendor lock-in)

---

## 🔧 TIER 12: DEVELOPMENT WORKFLOW

### ✅ Code Quality

**Linting:**
- ESLint with TypeScript support
- Rules: `@typescript-eslint/recommended`
- Custom rules: `no-client-eligibility` (frontend)

**Formatting:**
- Prettier (automatic on save)
- Config: 2-space indent, single quotes, trailing commas

**Git Hooks:**
- Husky + lint-staged
- Pre-commit: Lint + format staged files
- Pre-push: Run tests

### ✅ Local Development

**Environment:**
- `.env.local` (gitignored)
- Required vars: `DATABASE_URL`, `REDIS_URL`, `FIREBASE_ADMIN_KEY`

**Dev Server:**
- `npm run dev` — starts server with hot reload
- `tsx watch src/index.ts` — TypeScript execution + watch mode

**Database:**
- Local Postgres via Docker Compose
- OR: Neon branch (dev branch)

### ✅ CI/CD

**Pipeline (GitHub Actions):**
1. Install dependencies
2. Run lint + format check
3. Run type check (`tsc --noEmit`)
4. Run tests (unit + integration)
5. Run build (`tsc`)
6. Build Docker image
7. Deploy to staging (auto)
8. Deploy to production (manual approval)

**Branch Protection:**
- Require CI pass before merge
- Require 1 approval
- No force push to main

---

## 🔐 TIER 13: SECRETS MANAGEMENT

### ✅ Environment Variables

**Where:**
- Development: `.env.local` (gitignored)
- Production: Railway environment variables (encrypted)

**Required Secrets:**
- `DATABASE_URL` — Neon connection string
- `REDIS_URL` — Upstash connection string
- `FIREBASE_ADMIN_KEY` — Firebase Admin SDK JSON
- `STRIPE_SECRET_KEY` — Stripe API key
- `STRIPE_WEBHOOK_SECRET` — Stripe webhook signing secret
- `R2_ACCESS_KEY_ID` — Cloudflare R2 access
- `R2_SECRET_ACCESS_KEY` — Cloudflare R2 secret
- `R2_ENDPOINT` — Cloudflare R2 endpoint URL
- `SENDGRID_API_KEY` — Email sending
- `TWILIO_AUTH_TOKEN` — SMS sending
- `SENTRY_DSN` — Error tracking

**Forbidden:**
- ❌ Hardcoded secrets in code
- ❌ Secrets in version control
- ❌ Secrets in Docker images

---

## 📊 TIER 14: BACKUP & DISASTER RECOVERY

### ✅ Database Backups

**Strategy:**
- Neon automatic daily backups (7-day retention)
- Manual backup before migrations: `pg_dump`

**Recovery:**
- Point-in-time recovery (PITR) via Neon
- RTO: 1 hour
- RPO: 1 hour

### ✅ Code Backups

**Strategy:**
- GitHub (primary)
- Daily backup to S3 (via GitHub Actions)

---

## 🗺️ TIER 15: MAPS & SPATIAL INTELLIGENCE

**Authority:** ARCHITECTURE.md §21, SPATIAL_INTELLIGENCE_LOCKED.md

### Provider: Google Maps Platform

| API | Purpose | Trigger |
|-----|---------|---------|
| **Geocoding API** | Address → coordinates (task creation) | Task POST, server-side only |
| **Directions API** | Route polylines + ETA (en-route nav) | EN_ROUTE state, 30s refresh |
| **Distance Matrix API** | Batch proximity for feed | Feed load, cached 1h in Redis |
| **Static Maps API** | Task card map thumbnails | Feed render, cached 24h via CDN |
| **Places Autocomplete** | Address input suggestions | Task creation form, client-side |

### Mobile SDK: `react-native-maps` (Google Maps provider)

- iOS: Uses Google Maps SDK (not Apple Maps) for cross-platform consistency
- Android: Native Google Maps integration
- Map interactions: Pan, zoom, markers, polylines, circles
- No Mapbox, no Apple Maps, no HERE Maps

### Cost Controls

- Static map tiles cached 24h (CDN)
- Distance Matrix cached 1h (Redis)
- Directions API calls ONLY during EN_ROUTE state
- Places Autocomplete debounced (3 char minimum, 300ms delay)
- Budget alerts: $500 / $1K / $2K / $5K monthly thresholds
- Estimated: ~$350/month at 1K active users

### Privacy Constraints

- Geocoding runs SERVER-SIDE only (prevents spoofed coordinates from client)
- No background location permissions in app manifest
- Worker GPS transmitted to server ONLY during active task states
- Poster receives `PosterVisibleLocation` objects, NEVER raw `{lat, lng}` at >100m

### Forbidden

- ❌ Mapbox (inconsistent US residential geocoding)
- ❌ Apple Maps API (iOS-only, no Android support)
- ❌ OpenStreetMap tiles (insufficient address accuracy for task matching)
- ❌ Background location tracking (INV-PRIVACY-1 violation)
- ❌ Client-side geocoding (spoofing vector)

---

## 🚫 FORBIDDEN PATTERNS

### ❌ DO NOT USE

1. **ORMs** (Prisma, TypeORM, Sequelize)
   - Reason: Hide SQL, create N+1 queries, obscure invariants

2. **Supabase** (database + auth + storage)
   - Reason: RLS hides logic, auth bleeds into authority

3. **Convex** (backend-as-a-service)
   - Reason: No SQL authority, state machines become conventions

4. **GraphQL** (API layer)
   - Reason: Over-fetching, N+1, resolver complexity

5. **REST** (API layer)
   - Reason: No type safety, manual route definitions

6. **Serverless-only backends** (Vercel Edge, Cloudflare Workers)
   - Reason: Hard to run workers, hard to enforce state transitions

7. **NoSQL databases** (MongoDB, Firestore)
   - Reason: No schema enforcement, no invariants

8. **Edge runtimes** (Cloudflare Workers, Vercel Edge Functions)
   - Reason: No stateful workers, limited Node.js APIs

---

## 🔒 FINAL LOCK

**This stack is LOCKED for HustleXP v1.**

No changes permitted until v1 ships and is stable in production.

If you disagree with this stack, you disagree with the system design.

**Signed:** HustleXP Technical Authority
**Date:** 2025-01-20
**Version:** 1.0.0

---

**END OF BACKEND_STACK_LOCK.md**
