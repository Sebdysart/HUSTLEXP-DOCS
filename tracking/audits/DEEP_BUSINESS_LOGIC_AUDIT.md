# HUSTLEXP DEEP BUSINESS LOGIC AUDIT — Gaps the First Audit Missed

**Date:** Feb 4, 2026
**Scope:** Business logic, marketplace mechanics, operational safety, platform risk
**Method:** Cross-file trace of user flows, edge case analysis, attack surface mapping
**Prior audit:** `COMPREHENSIVE_APP_BUSINESS_AUDIT.md` found 24 gaps (7 P0, 10 P1, 7 P2)
**This audit:** NET NEW gaps only — business logic holes, not documentation hygiene

---

## SEVERITY SCALE

| Level | Meaning |
|---|---|
| **P0** | Exploitable in production. Blocks launch or creates liability. |
| **P1** | Significant product/business gap. Must fix before paid users. |
| **P2** | Quality/operational gap. Fix before scale. |

---

## P0 — LAUNCH BLOCKERS (7)

### GAP-B1: No API Rate Limiting on Any Endpoint
**Severity:** P0 — Security
**Evidence:** `grep -rn "rate.*limit\|429\|throttl" specs/04-backend/API_CONTRACT.md` returns ZERO results. BUILD_GUIDE returns ZERO results. AI_INFRASTRUCTURE mentions rate limits for AI jobs only.
**Problem:**
- Zero rate limiting on task.create, task.accept, messaging.send, proof.submit, or ANY endpoint
- A single bad actor can: scrape entire task feed, spam-create tasks, flood messaging, DDoS the API
- No IP-based throttling, no per-user request limits, no endpoint-specific limits
- Redis is in the stack (AI_INFRASTRUCTURE §2) but never used for API rate limiting
**Impact:** First bot hits the API, the platform goes down or gets scraped.
**Fix:** Add §11 Rate Limiting to API_CONTRACT. Define per-endpoint limits (e.g., task.create: 10/hour/user, messaging.send: 60/min/user, task.list: 30/min/user). Use Redis sliding window. Return 429 with Retry-After header.

### GAP-B2: No Concurrent Task Limit for Workers
**Severity:** P0 — Marketplace integrity
**Evidence:** `grep -rn "concurrent\|max.*active\|one.*at.*time" specs/01-product/PRODUCT_SPEC.md` returns ZERO results. API_CONTRACT `task.accept` has no guard for existing active tasks.
**Problem:**
- A worker can accept unlimited tasks simultaneously
- Worker accepts 50 tasks → completes 0 → all 50 posters are stuck
- No `MAX_ACTIVE_TASKS` constant anywhere in specs
- task.accept guard checks only: "Worker assigned AND escrow FUNDED" — no active task check
**Impact:** A single bad-faith worker can lock up dozens of posters' tasks and escrows. This is the #1 marketplace abuse vector.
**Fix:** Add INV-TASK-1 to PRODUCT_SPEC §2: "Workers may have at most N active tasks (ACCEPTED or IN_PROGRESS) simultaneously." Suggested: 3 for ROOKIE/VERIFIED, 5 for TRUSTED/ELITE, 8 for MASTER. Add DB check constraint or application guard.

### GAP-B3: No Proof Rejection Loop Protection
**Severity:** P0 — Worker exploitation
**Evidence:** PRODUCT_SPEC §3.3 defines `reject: PROOF_SUBMITTED → ACCEPTED` with guard "Rejection reason provided." No max rejection count. No escalation.
**Problem:**
- Poster rejects proof → worker resubmits → poster rejects again → infinite loop
- Worker is trapped: can't get paid, can't cancel (task in ACCEPTED, not OPEN)
- No maximum rejection count per task
- No automatic escalation to dispute after N rejections
- No "poster is being unreasonable" detection
**Impact:** Abusive posters can extract free labor by endlessly rejecting adequate proof. Workers have no recourse except manually opening a dispute (which they may not know to do).
**Fix:** Add INV-PROOF-1 to PRODUCT_SPEC: "After 3 proof rejections on the same task, the system automatically opens a dispute and freezes the escrow. The poster cannot reject further proof; only dispute resolution can proceed." Add `rejection_count` column to tasks or track via proof state history.

### GAP-B4: No Maximum Task Price
**Severity:** P0 — Fraud/AML risk
**Evidence:** PRODUCT_SPEC §3.5 defines $5 minimum (STANDARD) and $15 minimum (LIVE). Schema.sql line 154 enforces `amount >= 500`. No maximum defined anywhere.
**Problem:**
- A poster can create a $100,000 task
- Money laundering vector: create high-value task, have accomplice "complete" it, money moves through Stripe
- Chargeback risk: $50K chargeback bankrupts the platform's Stripe reserve
- Stripe will flag high-value transactions and may freeze the platform account
**Impact:** Stripe account freeze, money laundering liability, massive chargeback exposure.
**Fix:** Add maximum price to PRODUCT_SPEC §3.5: $500 for STANDARD, $1,000 for LIVE (v1). Add DB constraint: `amount <= 50000` (cents) for STANDARD, `amount <= 100000` for LIVE. Higher amounts require admin pre-approval.

### GAP-B5: No Stale Acceptance Timeout
**Severity:** P0 — Marketplace reliability
**Evidence:** PRODUCT_SPEC §3.2 transitions: `accept: OPEN → ACCEPTED`. No timeout for ACCEPTED state. No transition back to OPEN.
**Problem:**
- Worker accepts task, then disappears (phone dies, loses interest, forgets)
- Task sits in ACCEPTED state indefinitely — poster can't reassign, can't cancel (undefined behavior)
- PRODUCT_SPEC §3.3 says cancel is allowed from ACCEPTED, but only by the poster — no automatic cancellation
- No EN_ROUTE deadline (worker accepted 3 hours ago, hasn't started moving)
- No reminder notification for idle accepted tasks
**Impact:** Posters create tasks that get accepted and then abandoned. Poster has to manually cancel and re-post. Terrible UX. First-time posters will churn.
**Fix:** Add §3.8 to PRODUCT_SPEC: "ACCEPTED tasks auto-cancel if worker does not transition to EN_ROUTE within the task's start window (default: 2 hours before deadline, or 4 hours for same-day tasks). System sends reminder at 1h and 30min before auto-cancel. Worker's cancellation_count incremented."

### GAP-B6: No Chargeback Handling Spec
**Severity:** P0 — Financial risk
**Evidence:** STRIPE_INTEGRATION §7.2 lists `charge.dispute.created` webhook handler with action "Lock escrow, alert." Zero spec for downstream effects.
**Problem:**
- Poster's card company initiates chargeback AFTER escrow was released to worker
- Stripe claws back funds from platform account
- Worker already has the money — platform is out the full amount
- No spec for: platform absorbing loss vs. recouping from worker, escrow state after chargeback, worker notification, trust impact
- No fraud screening BEFORE accepting payment (Radar is listed in §1.2 but not configured)
- No hold period after task completion before worker can withdraw
**Impact:** A single coordinated fraud ring (poster creates task, accomplice completes, poster does chargeback) costs the platform 100% of task value plus Stripe dispute fee ($15/dispute).
**Fix:** Add §8.4 Chargeback Protocol to STRIPE_INTEGRATION. Define: 48-hour hold on transfers after escrow release (Stripe supports delayed transfers), Radar rule configuration (block high-risk cards), chargeback state (escrow → DISPUTED_BY_CARD), worker notification, platform loss allocation, fraud pattern detection (poster who chargebacks → permanent ban).

### GAP-B7: No Proof Photo Content Scanning
**Severity:** P0 — Legal liability / App store removal
**Evidence:** `grep -rn "photo.*modera\|nsfw\|image.*scan" specs/` returns ZERO results. Content moderation spec in staging is a stub. Proof photos and message photos are unscanned.
**Problem:**
- Workers upload proof photos — no NSFW/illegal content check
- Message photo attachments — no NSFW check
- Profile photos — no NSFW check
- Illegal content (CSAM) uploaded as "proof" makes platform legally liable
- Apple and Google will remove the app if user-generated images are unmoderated
- Storage spec (STORAGE_SPEC.md) defines upload flows but zero content scanning
**Impact:** Legal liability for hosting illegal content. App store removal. User safety violation.
**Fix:** Add photo moderation pipeline to CONTENT_MODERATION_SPEC. Integrate cloud-based image moderation (AWS Rekognition, Google Cloud Vision Safety, or Cloudflare Images moderation). Scan ALL user-uploaded images before storage. Block + report illegal content. Flag NSFW for human review.

---

## P1 — PRE-REVENUE GAPS (7)

### GAP-B8: No User Block/Mute Mechanism
**Evidence:** `grep -rn "block.*user\|mute\|blacklist" specs/` returns zero relevant results. No `user_blocks` table in schema.sql.
**Problem:** Worker had a bad experience with a poster (rude, unsafe conditions, unfair rejection). Worker can't block that poster — they'll keep seeing their tasks. Poster can't block a worker who was problematic. No personal safety mechanism.
**Fix:** Add `user_blocks` table. Add user.block/user.unblock API endpoints. Feed query filters out tasks from blocked users. Bidirectional: poster blocks worker = worker doesn't see poster's tasks AND poster doesn't see worker in applicants.

### GAP-B9: Dispute Resolution Is Dangerously Thin
**Evidence:** PRODUCT_SPEC §7 is 20 lines total. No timeline, no SLA, no evidence criteria, no escalation deadlines.
**Problem:**
- No maximum time to resolve a dispute (escrow frozen indefinitely?)
- No SLA for AI triage vs human review
- No definition of "evidence" for dispute purposes (vs. Judge Agent evidence for proofs)
- No automatic resolution if admin is unresponsive (auto-release after 14 days?)
- No appeal process after resolution
- No spec for what happens if BOTH parties file disputes
**Fix:** Expand §7 to full dispute protocol. Define: 72h AI triage SLA, 7-day human review SLA, 14-day founder escalation SLA, auto-release to worker at 21 days if unresolved. Add appeal window (48h after resolution). Add evidence requirements matrix.

### GAP-B10: No Offline Action Queue
**Evidence:** SPATIAL_INTELLIGENCE §14 notes "No ETA updates" when offline. No spec for queuing critical actions.
**Problem:** Worker is in a basement doing a task, submits proof — fails silently. Worker marks arrival — fails silently. Message sends — fails silently. No offline queue retries these when connectivity returns.
**Fix:** Add offline queue spec to PLATFORM_SPECIFIC.md or new OFFLINE_RESILIENCE_SPEC.md. Define: critical actions queued locally (proof.submit, messaging.send, task.arrive), retry on reconnect, conflict resolution, staleness limits (queued action older than 30min = discard with user notification).

### GAP-B11: No Background Job Orchestration Spec
**Evidence:** 8+ cron jobs referenced across specs (credential expiry, XP decay, transfer retries, notification cleanup, task expiry, analytics rollup, evidence retention, moderation SLA). No unified spec.
**Problem:** No technology lock for job scheduler (BullMQ? Quirrel? Fly.io scheduled machines? Supabase pg_cron?). No failure handling. No monitoring. No dead letter queue. No idempotency guarantees. If credential expiry job fails for 3 days, expired-credential workers keep accessing restricted tasks.
**Fix:** Create BACKGROUND_JOBS_SPEC.md. Define: technology (pg_cron for DB-layer, BullMQ for application-layer), job registry with schedule, failure handling (retry 3x, then alert), monitoring (job completion logs), idempotency patterns.

### GAP-B12: No App Store Compliance Spec
**Evidence:** Zero mentions of "App Store", "Google Play", "Apple review", "IAP" in specs.
**Problem:**
- Apple requires privacy manifest (NSPrivacyTrackedDomains, tracking transparency)
- Google requires data safety section
- Both require content rating (mature content in disputes? task photos?)
- Stripe payments for physical services do NOT require IAP, but this must be documented as defense against Apple rejection
- Both stores require functioning support contact
- Apple requires IDFA disclosure if analytics SDK uses it
**Fix:** Create APP_STORE_COMPLIANCE_SPEC.md. Define: privacy manifests, data safety declarations, content rating justification, IAP exemption rationale (physical services, not digital goods), review preparation checklist.

### GAP-B13: No Worker Earnings Floor / Stripe Transfer Minimum
**Evidence:** Zero results for "minimum payout" or "payout threshold" across all specs.
**Problem:** Worker completes $5 task. Platform takes 15% ($0.75). Worker portion: $4.25. Stripe transfer fee: percentage-based for Express accounts. If instant payout is used, Stripe charges 1% + $0.50. For a $4.25 transfer with instant payout, worker gets ~$3.71. That's 74% of the posted price — misleading.
- No disclosure of effective take rate including Stripe fees
- No minimum accumulation threshold before payout
- No spec for instant vs standard payout options and their fee differences
**Fix:** Add payout policy to STRIPE_INTEGRATION. Define: standard payout (free, 2-day delay), instant payout (1% fee, disclosed to worker), minimum transfer threshold ($1.00), earnings dashboard shows gross vs net.

### GAP-B14: No CI/CD or Deployment Pipeline Spec
**Evidence:** No GitHub Actions, no deployment workflow, no environment definitions anywhere in the repo.
**Problem:** No spec for: how code gets from repo to production, staging vs production environments, database migration strategy for production (schema.sql is 2,400+ lines — how does this get applied?), rollback procedures, feature flags, canary deployments.
**Fix:** Create DEPLOYMENT_SPEC.md. Define: environments (local, staging, production), CI pipeline (lint, test, build), CD pipeline (staging auto-deploy on merge, production manual promote), database migration tool (Prisma Migrate or raw SQL versioning), rollback procedure.

---

## P2 — PRE-SCALE GAPS (4)

### GAP-B15: Staging Directory Bloat
**Problem:** 7 SPATIAL_INTELLIGENCE files in staging (V1 through V6 + Analysis). These are historical artifacts documenting a bug (V1-V5 never committed). They serve no ongoing purpose and clutter the repo.
**Fix:** Move to `_archive/staging-history/spatial/`. Keep only V6 (final) or none.

### GAP-B16: No Load Testing / Capacity Planning
**Problem:** No expected capacity targets: max concurrent WebSocket connections (Live Mode), max tasks/second, database connection pool size, Fly.io machine scaling rules. Google Maps costs estimated but infrastructure costs not modeled.
**Fix:** Create CAPACITY_PLANNING.md. Define: target load (1K concurrent users at launch), WebSocket limits (Fly.io proxy limits), DB connection pooling (Neon serverless limits), auto-scaling triggers.

### GAP-B17: No Internationalization Architecture
**Problem:** English-only implied but never stated. No copy string extraction. Hardcoded English in stitch prompts, UI specs, error messages. If internationalization is ever needed, it requires touching every file.
**Fix:** At minimum, add explicit "English-only for v1" statement to PRODUCT_SPEC. Ideally, define copy string extraction pattern (i18n key → English value) so strings aren't hardcoded in components.

### GAP-B18: 60+ Stitch Prompts with Ambiguous Authority (Unfixed from GAP-20)
**Problem:** Previous audit GAP-20 identified LOCKED vs non-LOCKED stitch prompt duplication. Still unfixed. `09-hustler-task-completion.md` AND `09-hustler-task-completion-LOCKED.md` both exist. No authority rule.
**Fix:** Add `STITCH_AUTHORITY_RULE.md`: LOCKED is canonical. Delete or move non-LOCKED drafts that have LOCKED counterparts to `_archive/stitch-drafts/`.

---

## SUMMARY

| Severity | Count | Category |
|---|---|---|
| P0 (Launch Blockers) | 7 | Rate limiting, concurrent tasks, rejection loops, max price, stale acceptance, chargebacks, photo moderation |
| P1 (Pre-Revenue) | 7 | User blocking, dispute depth, offline queue, background jobs, app store, payout floors, CI/CD |
| P2 (Pre-Scale) | 4 | Staging bloat, capacity planning, i18n, stitch authority |
| **Total** | **18** | |

### Combined with Prior Audit (24 gaps):
| | Prior Audit | This Audit | Total |
|---|---|---|---|
| P0 | 7 | 7 | **14** |
| P1 | 10 | 7 | **17** |
| P2 | 7 | 4 | **11** |
| **Total** | **24** | **18** | **42** |

---

## TOP 5 NEW PRIORITIES (Fix Order)

1. **GAP-B2: Concurrent task limit** — Without this, one bad worker can lock up the entire marketplace
2. **GAP-B3: Rejection loop protection** — Without this, abusive posters extract free labor
3. **GAP-B5: Stale acceptance timeout** — Without this, accepted tasks rot forever
4. **GAP-B1: API rate limiting** — Without this, first bot takes down the platform
5. **GAP-B7: Photo content scanning** — Without this, app gets removed from stores

---

## CROSS-REFERENCE: What the Prior Audit Got Right

The prior audit (COMPREHENSIVE_APP_BUSINESS_AUDIT.md) correctly identified:
- GAP-1: Tax reporting ✅ (IRS requirement, still unfixed)
- GAP-2: Customer support ✅ (still unfixed)
- GAP-3: Cancellation policy ✅ (this audit's GAP-B5 is the mechanical enforcement of that policy)
- GAP-4: Sybil prevention ✅ (still unfixed)
- GAP-5: Legal framework ✅ (still unfixed)
- GAP-6: Force update ✅ (still unfixed)
- GAP-7: Platform insurance ✅ (still unfixed)

**None of the prior audit's 24 gaps have been fixed.** They were identified and committed as an audit file, but zero spec files were created or modified to resolve them. This audit adds 18 more.

---

## WHAT THIS AUDIT DID NOT COVER

- Frontend code quality (HUSTLEXPFINAL1 repo)
- AI backend implementation (hustlexp-ai-backend repo)
- Visual design fidelity
- Performance benchmarks
- Accessibility compliance (noted in prior audit GAP-21)

---

**Commit hash:** 3ecdd86
