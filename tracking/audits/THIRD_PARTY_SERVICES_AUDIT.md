# THIRD-PARTY SERVICES & API AUDIT

**Date:** 2026-02-04
**Source:** Full repo spec extraction (BACKEND_STACK_LOCK, ARCHITECTURE, PRODUCT_SPEC, all subsystem specs)
**Purpose:** Definitive list of every external service, API key, and account HustleXP v1 requires

---

## SUMMARY

| Priority | Category | Count |
|----------|----------|-------|
| 🔴 LAUNCH BLOCKER | Cannot ship without | 11 |
| 🟡 PRE-REVENUE | Need before first dollar | 5 |
| 🟢 GROWTH | Can defer post-launch | 6 |
| **TOTAL** | | **22** |

---

## 🔴 LAUNCH BLOCKERS (Must have before App Store submission)

### 1. STRIPE

**What you need:** Stripe account + Stripe Connect platform activation
**Products used:**
- **Stripe Connect** (Direct Charges model) — worker payouts via connected accounts
- **Stripe Payment Intents** — escrow funding from posters
- **Stripe Transfers** — releasing escrow to workers
- **Stripe Refunds** — cancellation/dispute refunds
- **Stripe Identity** — government ID verification at onboarding
- **Stripe Radar** — fraud screening per transaction ($0.05/screened)
- **Stripe Webhooks** — payment_intent.succeeded, transfer.created, charge.dispute.created, etc.
- **Stripe Tax Reporting API** — 1099-NEC generation for workers earning >$600/year

**Env vars:**
- `STRIPE_SECRET_KEY` (sk_test_... / sk_live_...)
- `STRIPE_WEBHOOK_SECRET` (whsec_...)
- `STRIPE_CONNECT_CLIENT_ID` (ca_...)

**Cost:** 2.9% + $0.30 per transaction. No monthly fee.
**Signup:** https://dashboard.stripe.com/register
**Notes:** Need to apply for Connect platform approval. Takes 1-5 business days. Must provide business details, description of marketplace model, and expected volume.

---

### 2. FIREBASE (Auth only)

**What you need:** Firebase project with Authentication enabled
**Products used:**
- **Firebase Authentication** — email/password, Google Sign-In, Apple Sign-In, phone verification (SMS OTP)
- **Firebase Admin SDK** — server-side token verification (UID → users.id mapping)

**NOT using:** Firestore, Firebase Storage, Realtime Database, Cloud Functions, Hosting

**Env vars:**
- `FIREBASE_ADMIN_KEY` (JSON service account key)

**Cost:** Free (Spark plan covers auth for millions of users)
**Signup:** https://console.firebase.google.com
**Notes:** Create separate projects for dev/staging/production.

---

### 3. NEON (PostgreSQL)

**What you need:** Neon account with Pro plan
**Products used:**
- **PostgreSQL 15+** — primary database (all tables, constraints, triggers, state machines)
- **PostGIS extension** — geospatial queries (task proximity, radius search)
- **Serverless branching** — test DB branches
- **Connection pooling** — managed pooler

**Env vars:**
- `DATABASE_URL` (postgres://...)

**Cost:** $19-69/month (Pro plan with branching)
**Signup:** https://neon.tech
**Notes:** PostGIS supported natively, no add-on. Create separate projects per environment.

---

### 4. UPSTASH (Redis)

**What you need:** Upstash Redis instance
**Products used:**
- **Redis** — caching (feed results, capability profiles, task details)
- **Redis** — BullMQ job queue backing store
- **Redis** — rate limiting (sliding window counters)
- **Redis** — session data

**Env vars:**
- `REDIS_URL` (rediss://...)

**Cost:** $10-30/month (pay-per-request)
**Signup:** https://upstash.com
**Notes:** Serverless Redis. Max connections: 10. Separate instances per environment.

---

### 5. RAILWAY (Hosting)

**What you need:** Railway account with project
**Products used:**
- **API server** — auto-scaling instances
- **Worker process** — separate service for BullMQ background jobs
- **Health checks** — GET /health every 10s
- **Secrets management** — encrypted env vars in production
- **Logs** — stdout → Railway log viewer

**Env vars:** All secrets stored via Railway dashboard

**Cost:** $5-50/month (usage-based)
**Signup:** https://railway.app
**Notes:** Git-based deployment. Docker optional.

---

### 6. CLOUDFLARE R2 (File Storage)

**What you need:** Cloudflare account + R2 bucket
**Products used:**
- **R2 bucket:** `hustlexp-storage` (proof photos, verification docs, user avatars)
- **Presigned URLs** — client-direct upload (no backend proxying)
- **R2 CDN** — built-in CDN with custom domain support
- **Lifecycle policies** — auto-delete old proof photos

**Env vars:**
- `R2_ACCOUNT_ID`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET_NAME`

**Cost:** Free egress, $0.015/GB storage (~$1-5/month at launch)
**Signup:** https://dash.cloudflare.com
**Notes:** S3-compatible API. Uses AWS SDK v3 with custom endpoint. Zero egress fees (major cost advantage over S3).

---

### 7. GOOGLE MAPS PLATFORM

**What you need:** Google Cloud project with Maps APIs enabled + billing
**APIs to enable:**
- **Geocoding API** — address → coordinates (server-side, task creation)
- **Directions API** — route polylines + ETA (EN_ROUTE state, 30s refresh)
- **Distance Matrix API** — batch proximity for feed (cached 1h in Redis)
- **Static Maps API** — task card map thumbnails (cached 24h via CDN)
- **Places Autocomplete** — address input suggestions (client-side)

**Mobile SDK:** MapKit (native iOS) for map display; Google APIs for server-side geocoding/directions

**Env vars:**
- `GOOGLE_MAPS_API_KEY` (server-side, restricted)
- Client-side key (restricted to app bundle ID)

**Cost:** $200-500/month at launch. $200 free credit/month. Scales aggressively — cache everything.
**Signup:** https://console.cloud.google.com → APIs & Services → Maps Platform
**Notes:** Set budget alerts at $500/$1K/$2K/$5K. At 10K users Maps alone could be $2-5K/month.

---

### 8. GOOGLE CLOUD VISION (Content Moderation)

**What you need:** Google Cloud project with Cloud Vision API enabled
**Products used:**
- **SafeSearch Detection** — scan ALL uploaded images before storage (proof photos, avatars, verification docs, message photos)
- Blocks + reports illegal content, flags NSFW for review

**Fallback:** AWS Rekognition Content Moderation (if Vision unavailable)

**Cost:** $1.50/1K images (~$75/month at 50K images)
**Signup:** Same Google Cloud project as Maps
**Notes:** Can share billing with Google Maps. AWS Rekognition fallback costs $1.00/1K images.

---

### 9. APPLE DEVELOPER (Frontend Build & Distribution)

**What you need:** Apple Developer Program membership
**Products used:**
- **Xcode** — iOS builds (SwiftUI)
- **TestFlight** — beta distribution
- **App Store Connect** — App Store submission
- **APNs** — push notification delivery (via Firebase Cloud Messaging)

**Env vars:**
- Apple Developer account credentials (for Xcode signing)

**Cost:** $99/year (Apple Developer Program)
**Signup:** https://developer.apple.com
**Notes:** Native SwiftUI app — no Expo/React Native. Push notifications via Firebase Cloud Messaging which routes to APNs.

---

### 10. SENTRY (Error Tracking)

**What you need:** Sentry account with Team plan
**Products used:**
- **Error tracking** — uncaught exceptions, invariant failures, recompute failures
- **Source maps** — production debugging
- **User context** — userId breadcrumbs

**Env vars:**
- `SENTRY_DSN`

**Cost:** $26/month (Team plan)
**Signup:** https://sentry.io

---

### 11. SENDGRID (Email)

**What you need:** SendGrid account with API key
**Products used:**
- **Transactional email** — verification emails, password reset, dispute notifications, verification status updates, data export delivery, support ticket confirmations

**Env vars:**
- `SENDGRID_API_KEY`

**Cost:** Free tier (100 emails/day) → $19.95/month (Essentials, 50K/month)
**Signup:** https://sendgrid.com

---

## 🟡 PRE-REVENUE (Need before earning money)

### 12. TWILIO (SMS)

**What you need:** Twilio account + phone number
**Products used:**
- **SMS OTP** — phone verification during onboarding
- **Twilio Lookup API** — carrier type check (block VoIP numbers for Sybil prevention)
- **Urgent task notifications** — opt-in SMS for time-critical tasks

**Env vars:**
- `TWILIO_AUTH_TOKEN`
- `TWILIO_ACCOUNT_SID`
- `TWILIO_PHONE_NUMBER`

**Cost:** $0.0079/SMS sent + $1/month per phone number
**Signup:** https://twilio.com
**Notes:** Firebase Auth handles phone OTP natively, but Twilio Lookup is needed separately for VoIP detection.

---

### 13. CHECKR (Background Checks)

**What you need:** Checkr partner account
**Products used:**
- **Background checks** — for workers accessing high-trust / critical-risk tasks (in-home care, etc.)
- One-time per worker. Status visible to posters for applicable categories.

**Cost:** $25-85 per check (varies by package)
**Signup:** https://checkr.com/partners
**Notes:** Can defer to post-launch if no critical-risk task categories at launch. But spec lists it as part of trust tier requirements.

---

### 14. ANTHROPIC / AI PROVIDER

**What you need:** Anthropic API key (or OpenAI as alternative)
**Products used (AI proposal layer — never final authority):**
- **Task classification** — category, risk level, complexity scoring
- **Pricing suggestions** — fair price proposals
- **Proof analysis** — photo evidence verification
- **Content moderation** — text classification assistance
- **Fraud detection** — behavioral pattern analysis
- **Support triage** — ticket routing

**Env vars:**
- `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`

**Cost:** Variable. Claude Sonnet ~$3/$15 per 1M input/output tokens.
**Signup:** https://console.anthropic.com
**Notes:** All AI features have deterministic fallbacks. Kill switches per subsystem. AI proposes, database decides.

---

### 15. POSTHOG (Analytics)

**What you need:** PostHog account (cloud or self-hosted)
**Products used:**
- **Event tracking** — user behavior, funnel analysis, retention cohorts
- **Session replay** — debugging UX issues
- **Feature flags** — gradual rollouts
- **iOS SDK** (Swift) + **Node SDK** (server events)

**Fallback:** Mixpanel (if PostHog insufficient)

**Cost:** Free tier (1M events/month) → paid plans after
**Signup:** https://posthog.com
**Notes:** GDPR-compliant. IP anonymization enabled. No PII in analytics events.

---

### 16. LOGTAIL / PAPERTRAIL (Log Aggregation)

**What you need:** Log aggregation service account
**Products used:**
- **Production log drain** — Railway stdout → aggregation service
- **Structured JSON logs** via Pino
- **Log search + alerting**

**Cost:** Logtail free tier (1GB/month) → $25/month (5GB). Papertrail: $7/month.
**Signup:** https://logtail.com or https://papertrailapp.com

---

## 🟢 GROWTH (Can defer post-launch)

### 17. PROMETHEUS + GRAFANA (Metrics & Dashboards)

**Products used:**
- Metrics collection (latency percentiles, recompute duration, API error rates)
- Dashboards and alerting

**Cost:** Grafana Cloud free tier. Self-hosted: free.
**Signup:** https://grafana.com

---

### 18. PAGERDUTY (On-Call Alerting)

**Products used:**
- Alert routing from Prometheus/Grafana
- On-call rotation management

**Cost:** $21/user/month
**Signup:** https://pagerduty.com
**Notes:** Can use Grafana alerting + SMS/email initially instead.

---

### 19. AWS REKOGNITION (Fallback Image Moderation)

**Products used:**
- Content moderation fallback if Google Cloud Vision is down

**Cost:** $1.00/1K images (only used as fallback)
**Signup:** Same AWS account as S3

---

### 20. GITHUB ACTIONS (CI/CD)

**Products used:**
- CI pipeline: lint, test, type-check, build, Docker image
- CD: auto-deploy to staging, manual promote to production
- Branch protection enforcement

**Cost:** Free for public repos. 2,000 min/month free for private.
**Signup:** https://github.com (already have this)

---

### 21. k6 (Load Testing)

**Products used:**
- Feed query load tests (100 RPS)
- Capability recompute (50 RPS)
- Task creation (20 RPS)
- Prometheus integration

**Cost:** Free (open source CLI). k6 Cloud for dashboards: $99/month.
**Signup:** https://k6.io

---

### 22. DOCKER

**Products used:**
- Dockerfile-based deployment to Railway
- Local development (Docker Compose for local Postgres)

**Cost:** Free (Docker Desktop personal use)
**Signup:** https://docker.com

---

## ENV VARS MASTER CHECKLIST

Copy this to `.env.local` template:

```bash
# === LAUNCH BLOCKERS ===
DATABASE_URL=                    # Neon PostgreSQL connection string
REDIS_URL=                       # Upstash Redis connection string
FIREBASE_ADMIN_KEY=              # Firebase Admin SDK JSON (base64 encoded)
STRIPE_SECRET_KEY=               # sk_test_... or sk_live_...
STRIPE_WEBHOOK_SECRET=           # whsec_...
STRIPE_CONNECT_CLIENT_ID=       # ca_...
R2_ACCOUNT_ID=                   # Cloudflare R2
R2_ACCESS_KEY_ID=                # Cloudflare R2
R2_SECRET_ACCESS_KEY=            # Cloudflare R2
R2_BUCKET_NAME=                  # Cloudflare R2
GOOGLE_MAPS_API_KEY=             # Server-side (restricted)
GOOGLE_CLOUD_VISION_KEY=         # Same GCP project or service account
# Apple Developer credentials managed via Xcode signing
SENTRY_DSN=                      # Error tracking
SENDGRID_API_KEY=                # Transactional email

# === PRE-REVENUE ===
TWILIO_ACCOUNT_SID=              # SMS
TWILIO_AUTH_TOKEN=               # SMS
TWILIO_PHONE_NUMBER=             # SMS sender number
CHECKR_API_KEY=                  # Background checks
ANTHROPIC_API_KEY=               # AI services (or OPENAI_API_KEY)
POSTHOG_API_KEY=                 # Analytics
LOGTAIL_TOKEN=                   # Log aggregation

# === GROWTH ===
PAGERDUTY_INTEGRATION_KEY=       # On-call alerting (optional)
```

---

## ACCOUNTS TO CREATE (ordered by priority)

| # | Service | URL | Why First |
|---|---------|-----|-----------|
| 1 | Stripe | dashboard.stripe.com/register | Connect approval takes days |
| 2 | Google Cloud | console.cloud.google.com | Maps + Vision, billing setup |
| 3 | Firebase | console.firebase.google.com | Auth project setup |
| 4 | Neon | neon.tech | Database provisioning |
| 5 | Cloudflare | dash.cloudflare.com | R2 storage setup |
| 6 | Upstash | upstash.com | Redis instance |
| 7 | Railway | railway.app | Hosting setup |
| 8 | Apple Developer | developer.apple.com | iOS build + distribution |
| 9 | SendGrid | sendgrid.com | Email delivery |
| 10 | Sentry | sentry.io | Error tracking |
| 11 | Twilio | twilio.com | SMS + phone verification |
| 12 | Anthropic | console.anthropic.com | AI API access |
| 13 | PostHog | posthog.com | Analytics |
| 14 | Checkr | checkr.com/partners | Background checks (partner app) |
| 15 | Logtail | logtail.com | Log aggregation |

---

## MONTHLY COST ESTIMATE (at launch, ~100 users)

| Service | Est. Cost |
|---------|-----------|
| Stripe | $0 (% per txn only) |
| Firebase Auth | $0 (free tier) |
| Neon (Pro) | $19-69 |
| Upstash Redis | $10-30 |
| Railway | $5-50 |
| Cloudflare R2 | $1-5 |
| Google Maps | $0-200 ($200 free credit) |
| Google Cloud Vision | $5-15 |
| Apple Developer | $99/year |
| Sentry | $26 |
| SendGrid | $0-20 |
| Twilio | $5-15 |
| Anthropic AI | $20-100 |
| PostHog | $0 (free tier) |
| Logtail | $0-25 |
| **TOTAL** | **~$140-770/month** |

At 1K users: ~$500-1,500/month (Maps is the biggest scaler)
At 10K users: ~$2,000-6,000/month

---

## SPEC CONFLICTS / NOTES

1. **Storage:** Backend uses Cloudflare R2 (S3-compatible API, zero egress fees). Env vars: `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET_NAME`.
2. **Firebase Storage references:** Some stitch prompts reference "Firebase Storage URL" for avatars/task images. These should be R2 URLs.
3. **Supabase references:** Some older spec code samples use `await supabase.from(...)`. These are pseudocode — actual implementation uses `pg` (node-postgres) direct SQL per stack lock.
4. **PostHog vs Mixpanel:** ANALYTICS_LOCKED locks PostHog as primary, Mixpanel as fallback. UNIT_ECONOMICS lists both. **Use PostHog first.**
5. **Push Notifications:** Firebase Cloud Messaging handles push delivery to iOS via APNs. No Expo Push needed (native SwiftUI app).
6. **Twilio vs Firebase Phone Auth:** Firebase Auth handles phone OTP natively. Twilio Lookup is needed separately for VoIP number blocking (Sybil prevention). Both are needed.

---

**END OF THIRD_PARTY_SERVICES_AUDIT.md**
