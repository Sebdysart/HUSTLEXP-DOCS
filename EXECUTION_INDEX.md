# HustleXP EXECUTION INDEX v1.5.0

**STATUS: ACTIVE — UPDATE WITH EVERY PR**  
**Last Updated:** January 2025  
**Purpose:** Single source of truth for spec → implementation mapping

---

## How to Use This Document

1. **Before implementing:** Find the row, verify spec reference, check status
2. **After implementing:** Update status (❌ → 🟡 → ✅), add file path
3. **During code review:** PR must update this file or it's rejected
4. **During audit:** Run verification queries against this index

### Status Key

| Symbol | Meaning |
|--------|---------|
| ✅ | Implemented + Tested + Verified |
| 🟡 | Implemented, needs testing |
| ❌ | Not implemented |
| ⏳ | In progress |
| 🚫 | Blocked by dependency |

---

## SECTION 1: DATABASE SCHEMA

### 1.1 Core Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `users` | PRODUCT_SPEC §5, ONBOARDING_SPEC §7 | schema.sql:L47 | ✅ |
| `tasks` | PRODUCT_SPEC §3 | schema.sql:L119 | ✅ |
| `escrows` | PRODUCT_SPEC §4 | schema.sql:L189 | ✅ |
| `proofs` | PRODUCT_SPEC §3.2 | schema.sql:L277 | ✅ |
| `proof_photos` | PRODUCT_SPEC §3.2 | schema.sql:L317 | ✅ |
| `xp_ledger` | PRODUCT_SPEC §5, INV-1, INV-5 | schema.sql:L348 | ✅ |
| `trust_ledger` | ARCHITECTURE §2.2 | schema.sql:L422 | ✅ |
| `badges` | ARCHITECTURE §2.3 | schema.sql:L464 | ✅ |
| `disputes` | PRODUCT_SPEC §4 | schema.sql:L508 | ✅ |
| `processed_stripe_events` | ARCHITECTURE §2.4 | schema.sql:L560 | ✅ |

### 1.2 AI Infrastructure Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `ai_events` | AI_INFRASTRUCTURE §6.1 | schema.sql:L578 | ✅ |
| `ai_jobs` | AI_INFRASTRUCTURE §6.2 | schema.sql:L608 | ✅ |
| `ai_proposals` | AI_INFRASTRUCTURE §6.3 | schema.sql:L647 | ✅ |
| `ai_decisions` | AI_INFRASTRUCTURE §6.4 | schema.sql:L680 | ✅ |
| `evidence` | AI_INFRASTRUCTURE §6.5 | schema.sql:L705 | ✅ |

### 1.3 Admin Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `admin_roles` | ARCHITECTURE §2.6 | schema.sql:L765 | ✅ |
| `admin_actions` | ARCHITECTURE §2.6 | schema.sql:L791 | ✅ |
| `schema_versions` | Internal | schema.sql:L19 | ✅ |

### 1.4 Live Mode Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `live_sessions` | PRODUCT_SPEC §3.5 | schema.sql:L1137 | ✅ |
| `live_broadcasts` | PRODUCT_SPEC §3.6 | schema.sql:L1160 | ✅ |

### 1.5 Human Systems Tables

| Table/View | Spec Reference | Schema Location | Status |
|------------|----------------|-----------------|--------|
| `poster_ratings` | PRODUCT_SPEC §8.4 | schema.sql:L1265 | ✅ |
| `poster_reputation` (VIEW) | PRODUCT_SPEC §8.4 | schema.sql:L1285 | ✅ |
| `session_forecasts` | AI_INFRASTRUCTURE §21 | schema.sql:L1305 | ✅ |
| `money_timeline` (VIEW) | UI_SPEC §14 | schema.sql:L1330 | ✅ |

---

## SECTION 2: DATABASE TRIGGERS (INVARIANT ENFORCEMENT)

### 2.1 Terminal State Triggers

| Trigger | Invariant | Schema Location | Test File | Status |
|---------|-----------|-----------------|-----------|--------|
| `task_terminal_guard` | Terminal State | schema.sql:L168 | inv-2.test.ts | ✅ Schema, 🟡 Test |
| `escrow_terminal_guard` | Terminal State | schema.sql:L243 | inv-2.test.ts | ✅ Schema, 🟡 Test |

### 2.2 Core Invariant Triggers

| Trigger | Invariant | Schema Location | Test File | Status |
|---------|-----------|-----------------|-----------|--------|
| `escrow_amount_immutable` | INV-4 | schema.sql:L266 | ❌ | ✅ Schema, ❌ Test |
| `xp_requires_released_escrow` | INV-1 | schema.sql:L391 | inv-1.test.ts | ✅ Schema, 🟡 Test |
| `xp_ledger_no_delete` | Append-only | schema.sql:L413 | inv-1.test.ts | ✅ Schema, 🟡 Test |
| `badge_no_delete` | INV-BADGE-2 | schema.sql:L497 | ❌ | ✅ Schema, ❌ Test |
| `escrow_released_requires_completed_task` | INV-2 | schema.sql:L842 | inv-2.test.ts | ✅ Schema, 🟡 Test |
| `task_completed_requires_accepted_proof` | INV-3 | schema.sql:L869 | ❌ | ✅ Schema, ❌ Test |

### 2.3 Audit Triggers

| Trigger | Purpose | Schema Location | Status |
|---------|---------|-----------------|--------|
| `trust_tier_audit` | Log trust changes | schema.sql:L455 | ✅ |
| `admin_actions_no_delete` | Append-only audit | schema.sql:L825 | ✅ |
| `*_updated_at` (7 triggers) | Auto-timestamp | schema.sql:L906-912 | ✅ |

### 2.4 Live Mode Triggers

| Trigger | Invariant | Schema Location | Test File | Status |
|---------|-----------|-----------------|-----------|--------|
| `live_task_escrow_check` | LIVE-1 | schema.sql:L1195 | ❌ | ✅ Schema, ❌ Test |
| `live_task_price_check` | LIVE-2 | schema.sql:L1213 | ❌ | ✅ Schema, ❌ Test |

---

## SECTION 3: INVARIANTS

### 3.1 Core Invariants (PRODUCT_SPEC §2)

| ID | Invariant | DB Trigger | Backend Service | Frontend Guard | Test | Status |
|----|-----------|------------|-----------------|----------------|------|--------|
| INV-1 | XP requires RELEASED escrow | ✅ schema.sql:L391 | 🟡 AtomicXPService | N/A | 🟡 inv-1.test.ts | 🟡 |
| INV-2 | RELEASED requires COMPLETED task | ✅ schema.sql:L842 | 🟡 EscrowService.ts | N/A | 🟡 inv-2.test.ts | 🟡 |
| INV-3 | COMPLETED requires ACCEPTED proof | ✅ schema.sql:L869 | 🟡 TaskService.ts | N/A | ❌ | 🟡 |
| INV-4 | Escrow amount immutable | ✅ schema.sql:L266 | 🟡 EscrowService.ts | N/A | ❌ | 🟡 |
| INV-5 | XP idempotent per escrow | ✅ schema.sql:L378 (UNIQUE) | 🟡 AtomicXPService | N/A | 🟡 inv-1.test.ts | 🟡 |

### 3.2 XP Invariants (ARCHITECTURE §2.1)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| INV-XP-1 | XP requires COMPLETED task | Via INV-1 + INV-2 chain | 🟡 |
| INV-XP-2 | XP requires RELEASED escrow | DB trigger | 🟡 |
| INV-XP-3 | XP decay is time-driven | ❌ Backend service | ❌ |
| INV-XP-4 | XP totals match ledger | ❌ Backend sync | ❌ |

### 3.3 Trust Invariants (ARCHITECTURE §2.2)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| INV-TRUST-1 | No upgrade if SLA breached | ❌ Backend service | ❌ |
| INV-TRUST-2 | Decay is deterministic | ❌ Backend service | ❌ |
| INV-TRUST-3 | Changes require audit | ✅ DB trigger | 🟡 |
| INV-TRUST-4 | Display matches ledger | ❌ Frontend sync | ❌ |

### 3.4 Badge Invariants (ARCHITECTURE §2.3)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| INV-BADGE-1 | No retroactive badges | ❌ Backend guard | ❌ |
| INV-BADGE-2 | Append-only | ✅ DB trigger | 🟡 |
| INV-BADGE-3 | Animation once (server-side) | ✅ DB column | 🟡 |
| INV-BADGE-4 | Material matches tier | ❌ UI guard | ❌ |

### 3.5 UI Invariants (UI_SPEC §5, §12)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| INV-UI-1 | No animation without state change | ❌ Runtime guard | ❌ |
| INV-UI-2 | XP colors only in XP context | ❌ ESLint rule | ❌ |
| INV-UI-3 | No celebration during dispute | ❌ Screen context guard | ❌ |
| INV-UI-4 | Respect reduced motion | ❌ Runtime guard | ❌ |

### 3.6 Onboarding Invariants (ONBOARDING_SPEC §0.1)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| ONB-1 | Users may NOT self-select role before inference | UI flow | ❌ |
| ONB-2 | Onboarding contains ZERO rewards | UI components | ❌ |
| ONB-3 | Posters NEVER see gamification | Role-gated UI | ❌ |
| ONB-4 | Hustlers see gamification ONLY after first RELEASED | DB + UI gate | ❌ |
| ONB-5 | First XP celebration is single-use, server-tracked | `xp_first_celebration_shown_at` | ✅ Schema |
| ONB-6 | Onboarding exits immediately after authority established | UI flow | ❌ |

### 3.7 Gamification Timing (ONBOARDING_SPEC §13, UI_SPEC §12)

| Rule | Enforcement | Status |
|------|-------------|--------|
| XP animation only after RELEASED escrow | DB column check | ❌ |
| First celebration single-use | Server-tracked timestamp | ✅ Schema |
| Poster dashboard: no gamification | Role-gated components | ❌ |
| Hustler pre-unlock: locked visuals only | UI state gate | ❌ |

### 3.8 Live Mode Invariants (PRODUCT_SPEC §3.5, §3.6)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| LIVE-1 | Live tasks require FUNDED escrow | DB trigger (HX901) | ✅ Schema |
| LIVE-2 | Live tasks require $15 minimum | DB constraint (HX902) | ✅ Schema |
| LIVE-3 | Hustlers must opt in explicitly | UI + DB state | ❌ |
| LIVE-4 | Broadcasts are geo-bounded | Backend service | ❌ |
| LIVE-5 | Broadcasts are time-bounded (TTL) | Backend service | ❌ |
| LIVE-6 | Session-based, not permanent | State machine | ❌ |
| LIVE-7 | No auto-accept, no AI decisions | Constitutional | ❌ |

### 3.9 Human Systems — NOW CONSTITUTIONAL

| ID | Gap | Description | Spec Location | Status |
|----|-----|-------------|---------------|--------|
| GAP-1 | Money Legibility | Money Timeline | UI_SPEC §14, schema.sql view | ✅ INTEGRATED |
| GAP-2 | Failure Recovery UX | Graceful failure paths | UI_SPEC §15 | ✅ INTEGRATED |
| GAP-3 | Earning Predictability | AI Session Forecast | AI_INFRASTRUCTURE §21, schema.sql | ✅ INTEGRATED |
| GAP-4 | Private Percentile | No leaderboards | PRODUCT_SPEC §8.3 | ✅ INTEGRATED |
| GAP-5 | Anti-Burnout (Global) | Fatigue rules everywhere | PRODUCT_SPEC §3.7, schema.sql | ✅ INTEGRATED |
| GAP-6 | Poster Quality | Reputation to hustlers | PRODUCT_SPEC §8.4, schema.sql | ✅ INTEGRATED |
| GAP-7 | Exit With Dignity | Pause state | PRODUCT_SPEC §11, schema.sql | ✅ INTEGRATED |

### 3.10 Money Timeline Invariants (UI_SPEC §14)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| MONEY-1 | Timeline reflects actual escrow states | DB view | ✅ Schema |
| MONEY-2 | No charts, no graphs, no gambling visuals | UI review | ❌ UI |
| MONEY-3 | Time + certainty only | UI review | ❌ UI |
| MONEY-4 | COMING SOON shows context | Backend | ✅ Schema |

### 3.11 Failure Recovery Invariants (UI_SPEC §15)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| FAIL-1 | Every negative outcome has explanation | UI review | ❌ UI |
| FAIL-2 | Every explanation has next step | UI review | ❌ UI |
| FAIL-3 | No shame language | Copy review | ❌ UI |
| FAIL-4 | Recovery path always visible | UI component | ❌ UI |
| FAIL-5 | Impact is specific, not vague | Copy review | ❌ UI |

### 3.12 Private Percentile Invariants (PRODUCT_SPEC §8.3)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| PERC-1 | Percentiles are never public | API guard (HX604) | ❌ Backend |
| PERC-2 | No comparison to named users | UI review | ❌ UI |
| PERC-3 | Percentiles update weekly max | Backend job | ❌ Backend |
| PERC-4 | Minimum 100 users for percentile | Statistical validity | ❌ Backend |
| PERC-5 | No rankings or leaderboards | Constitutional | ❌ Code review |

### 3.13 Poster Reputation Invariants (PRODUCT_SPEC §8.4)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| POSTER-1 | Reputation never shown to poster | API guard (HX603) | ❌ Backend |
| POSTER-2 | Minimum 5 tasks for reputation | DB view | ✅ Schema |
| POSTER-3 | Rolling 90-day window | DB view | ✅ Schema |
| POSTER-4 | No "bad poster" labels | UI review | ❌ UI |

### 3.14 Fatigue Invariants (PRODUCT_SPEC §3.7)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| FATIGUE-1 | 8-hour limit triggers mandatory break | Backend service | ❌ Backend |
| FATIGUE-2 | Nudges are suggestions (except 8h) | UI only | ❌ UI |
| FATIGUE-3 | Activity tracking per-calendar-day | DB column | ✅ Schema |
| FATIGUE-4 | Break timer cannot be bypassed | Backend (HX601) | ❌ Backend |

### 3.15 Pause State Invariants (PRODUCT_SPEC §11)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| PAUSE-1 | XP never decays during pause | Backend logic | ❌ Backend |
| PAUSE-2 | Badges are permanent | DB constraint | ✅ Schema |
| PAUSE-3 | Pause is always available | UI | ❌ UI |
| PAUSE-4 | Resume is instant | Backend | ❌ Backend |
| PAUSE-5 | No punitive notifications during pause | Notification service | ❌ Backend |

### 3.16 Session Forecast Invariants (AI_INFRASTRUCTURE §21)

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| FORECAST-1 | Never guarantee earnings | Copy review | ❌ UI |
| FORECAST-2 | Always show disclaimer | UI component | ❌ UI |
| FORECAST-3 | Ranges only, no exact numbers | Backend | ❌ Backend |
| FORECAST-4 | Expire after 15 minutes | TTL enforcement | ❌ Backend |
| FORECAST-5 | Log all forecasts for accuracy | AI logging | ✅ Schema |

---

## SECTION 4: STATE MACHINES

### 4.1 Task State Machine

| Transition | From | To | Guard | Backend | Frontend | Test | Status |
|------------|------|----|----|---------|----------|------|--------|
| create | — | OPEN | — | 🟡 TaskService.ts | ❌ | ❌ | 🟡 |
| accept | OPEN | ACCEPTED | has_worker | 🟡 TaskService.ts | ❌ | ❌ | 🟡 |
| submit_proof | ACCEPTED | PROOF_SUBMITTED | proof_exists | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |
| approve | PROOF_SUBMITTED | COMPLETED | proof_accepted | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |
| reject | PROOF_SUBMITTED | ACCEPTED | — | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |
| dispute | PROOF_SUBMITTED | DISPUTED | — | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |
| cancel | OPEN/ACCEPTED | CANCELLED | — | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |
| expire | * | EXPIRED | past_deadline | 🟡 TaskService.ts | ✅ TaskStateMachine.js | ❌ | 🟡 |

### 4.2 Escrow State Machine

| Transition | From | To | Guard | Backend | Frontend | Test | Status |
|------------|------|----|----|---------|----------|------|--------|
| create | — | PENDING | — | 🟡 EscrowService.ts | ❌ | ❌ | 🟡 |
| fund | PENDING | FUNDED | payment_success | 🟡 EscrowService.ts | ✅ EscrowStateMachine.js | ❌ | 🟡 |
| lock_dispute | FUNDED | LOCKED_DISPUTE | dispute_opened | 🟡 EscrowService.ts | ✅ EscrowStateMachine.js | ❌ | 🟡 |
| release | FUNDED | RELEASED | task_completed (INV-2) | 🟡 EscrowService.ts | ✅ EscrowStateMachine.js | 🟡 inv-2.test.ts | 🟡 |
| refund | FUNDED/LOCKED | REFUNDED | — | 🟡 EscrowService.ts | ✅ EscrowStateMachine.js | ❌ | 🟡 |
| partial_refund | LOCKED_DISPUTE | REFUND_PARTIAL | dispute_resolved | 🟡 EscrowService.ts | ✅ EscrowStateMachine.js | ❌ | 🟡 |

### 4.3 Proof State Machine

| Transition | From | To | Guard | Backend | Frontend | Test | Status |
|------------|------|----|----|---------|----------|------|--------|
| create | — | PENDING | — | ❌ | ❌ | ❌ | ❌ |
| submit | PENDING | SUBMITTED | has_photos | ❌ | ✅ ProofStateMachine.js | ❌ | 🟡 |
| accept | SUBMITTED | ACCEPTED | reviewed_by_poster | ❌ | ✅ ProofStateMachine.js | ❌ | 🟡 |
| reject | SUBMITTED | REJECTED | rejection_reason | ❌ | ✅ ProofStateMachine.js | ❌ | 🟡 |
| expire | SUBMITTED | EXPIRED | review_timeout | ❌ | ✅ ProofStateMachine.js | ❌ | 🟡 |

---

## SECTION 5: BACKEND SERVICES

### 5.1 Core Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| AtomicXPService | PRODUCT_SPEC §5, INV-1, INV-5 | ❌ | ❌ |
| TrustTierService | ARCHITECTURE §2.2 | ❌ | ❌ |
| EscrowService | PRODUCT_SPEC §4 | backend/src/services/EscrowService.ts | 🟡 |
| TaskService | PRODUCT_SPEC §3 | backend/src/services/TaskService.ts | 🟡 |
| ProofService | PRODUCT_SPEC §3.2 | ❌ | ❌ |
| DisputeService | PRODUCT_SPEC §4 | ❌ | ❌ |
| StripeWebhookHandler | ARCHITECTURE §2.4 | ❌ | ❌ |

### 5.2 AI Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| AIOrchestrator | AI_INFRASTRUCTURE §5.1 | ❌ | ❌ |
| OnboardingInferenceService | AI_INFRASTRUCTURE §3.2, ONBOARDING_SPEC | ❌ | ❌ |
| EvidenceService | AI_INFRASTRUCTURE §8 | ❌ | ❌ |
| EvidenceAnalysisService | AI_INFRASTRUCTURE §8.8 | ❌ | ❌ |

### 5.3 Backend Infrastructure

| Component | Purpose | File Path | Status |
|-----------|---------|-----------|--------|
| Database Client | PostgreSQL connection + transactions | backend/src/db.ts | 🟡 |
| Type Definitions | Shared types from schema | backend/src/types.ts | 🟡 |
| tRPC Config | Router, procedures, schemas | backend/src/trpc.ts | 🟡 |
| Server Entry | HTTP server + health checks | backend/src/index.ts | 🟡 |

---

## SECTION 6: tRPC ENDPOINTS

### 6.1 Onboarding Endpoints (AI_INFRASTRUCTURE §15.1)

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `ai.onboarding.submitCalibration` | mutation | AI_INFRASTRUCTURE §15.1 | ❌ | ❌ |
| `ai.onboarding.getInferenceResult` | query | AI_INFRASTRUCTURE §15.1 | ❌ | ❌ |
| `ai.onboarding.confirmRole` | mutation | AI_INFRASTRUCTURE §15.1 | ❌ | ❌ |
| `ai.onboarding.lockPreferences` | mutation | AI_INFRASTRUCTURE §15.1 | ❌ | ❌ |

### 6.2 Task Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `task.create` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.accept` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.submitProof` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.approveProof` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.rejectProof` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.cancel` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.dispute` | mutation | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.getById` | query | PRODUCT_SPEC §3 | ❌ | ❌ |
| `task.list` | query | PRODUCT_SPEC §3 | ❌ | ❌ |

### 6.3 Escrow Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `escrow.createPaymentIntent` | mutation | PRODUCT_SPEC §4 | ❌ | ❌ |
| `escrow.confirmFunding` | mutation | PRODUCT_SPEC §4 | backend/src/routers/escrow.ts | 🟡 |
| `escrow.release` | mutation | PRODUCT_SPEC §4 | backend/src/routers/escrow.ts | 🟡 |
| `escrow.refund` | mutation | PRODUCT_SPEC §4 | backend/src/routers/escrow.ts | 🟡 |
| `escrow.lockForDispute` | mutation | PRODUCT_SPEC §4 | backend/src/routers/escrow.ts | 🟡 |
| `escrow.getByTaskId` | query | PRODUCT_SPEC §4 | backend/src/routers/escrow.ts | 🟡 |

### 6.4 Evidence Endpoints (AI_INFRASTRUCTURE §15.2)

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `ai.evidence.requestUploadUrl` | mutation | AI_INFRASTRUCTURE §15.2 | ❌ | ❌ |
| `ai.evidence.confirmUpload` | mutation | AI_INFRASTRUCTURE §15.2 | ❌ | ❌ |
| `ai.evidence.getAnalysis` | query | AI_INFRASTRUCTURE §15.2 | ❌ | ❌ |

### 6.5 User Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `user.getProfile` | query | PRODUCT_SPEC §5 | ❌ | ❌ |
| `user.getXPHistory` | query | PRODUCT_SPEC §5 | ❌ | ❌ |
| `user.getBadges` | query | ARCHITECTURE §2.3 | ❌ | ❌ |

---

## SECTION 7: FRONTEND ENFORCEMENT

### 7.1 ESLint Rules (UI_SPEC §8, §12)

| Rule | Spec Reference | File Path | Status |
|------|----------------|-----------|--------|
| `noForbiddenColors` | UI_SPEC §2.2 | ❌ | ❌ |
| `noAnimationOverflow` | UI_SPEC §3.1 | ❌ | ❌ |
| `enforceSemanticColors` | UI_SPEC §2.3 | ❌ | ❌ |
| `noGradientButtons` | UI_SPEC §2.2 | ❌ | ❌ |
| `enforceTouchTargets` | UI_SPEC §7 (A4) | ❌ | ❌ |
| `noShameCopy` | UI_SPEC §5.1 | ❌ | ❌ |
| `enforceReducedMotion` | UI_SPEC §3.3 (M4) | ❌ | ❌ |
| `noConfetti` | UI_SPEC §3.2 | ❌ | ❌ |
| `firstTimeAnimationOnly` | UI_SPEC §3.3 (M7) | ❌ | ❌ |
| `enforceColorAuthority` | UI_SPEC §2.3 (AUDIT-16) | ❌ | ❌ |
| `cumulativeAnimationCap` | UI_SPEC §3.2 (AUDIT-17) | ❌ | ❌ |
| `badgeTierMaterialBinding` | UI_SPEC §4.3 (AUDIT-19) | ❌ | ❌ |
| `noGamificationForPoster` | UI_SPEC §12.5 (ONB-3) | ❌ | ❌ |
| `noAnimatedGamificationPreUnlock` | UI_SPEC §12.6 (ONB-4) | ❌ | ❌ |

### 7.2 Runtime Guards

| Guard | Spec Reference | File Path | Status |
|-------|----------------|-----------|--------|
| ViolationTracker | ARCHITECTURE §3.0 (AUDIT-13) | ❌ | ❌ |
| AnimationDurationGuard | UI_SPEC §3.1 | ❌ | ❌ |
| FirstTimeAnimationGuard | UI_SPEC §3.3 (M7) | ❌ | ❌ |
| CelebrationAutoTruncate | UI_SPEC §3.5 (AUDIT-18) | ❌ | ❌ |
| HapticGuard | UI_SPEC §5.3 (AUDIT-20) | ❌ | ❌ |
| NavigationReplayGuard | UI_SPEC §3.6 (AUDIT-21) | ❌ | ❌ |
| BadgeTierValidator | UI_SPEC §4.3 (AUDIT-19) | ❌ | ❌ |
| ScreenContextGuard | UI_SPEC §6 | ❌ | ❌ |

### 7.3 Existing Frontend State Machines

| Machine | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| TaskStateMachine | PRODUCT_SPEC §3 | state/TaskStateMachine.js | ✅ |
| EscrowStateMachine | PRODUCT_SPEC §4 | state/EscrowStateMachine.js | ✅ |
| ProofStateMachine | PRODUCT_SPEC §3.2 | state/ProofStateMachine.js | ✅ |
| OnboardingStateMachine | ONBOARDING_SPEC | state/OnboardingStateMachine.js | ✅ |

### 7.4 Existing Frontend Screens

| Screen | Spec Reference | File Path | Status |
|--------|----------------|-----------|--------|
| CalibrationScreen | ONBOARDING_SPEC §3.1 | screens/onboarding/CalibrationScreen.js | ✅ |
| RoleConfirmationScreen | ONBOARDING_SPEC §3.3 | screens/onboarding/RoleConfirmationScreen.js | ✅ |
| PreferenceLockScreen | ONBOARDING_SPEC §3.4 | screens/onboarding/PreferenceLockScreen.js | ✅ |
| LoginScreen | - | screens/LoginScreen.js | ✅ |
| SignupScreen | - | screens/SignupScreen.js | ✅ |
| HomeScreen | - | screens/HomeScreen.js | ✅ |
| TasksScreen | - | screens/TasksScreen.js | ✅ |
| WalletScreen | - | screens/WalletScreen.js | ✅ |
| ProfileScreen | - | screens/ProfileScreen.js | ✅ |

### 7.5 New Frontend Components (ONBOARDING_SPEC §12-17, UI_SPEC §12)

| Component | Spec Reference | File Path | Status |
|-----------|----------------|-----------|--------|
| FramingScreen | ONBOARDING_SPEC §14 | ❌ | ❌ |
| FirstXPCelebration | ONBOARDING_SPEC §13.4, UI_SPEC §12.4 | ❌ | ❌ |
| LockedGamificationUI | ONBOARDING_SPEC §13.2, UI_SPEC §12.2 | ❌ | ❌ |
| PosterDashboard | ONBOARDING_SPEC §12.1 (no gamification) | ❌ | ❌ |
| HustlerDashboardPreUnlock | ONBOARDING_SPEC §13.2 | ❌ | ❌ |
| HustlerDashboardPostUnlock | ONBOARDING_SPEC §13.3 | ❌ | ❌ |

---

## SECTION 8: BUILD PHASES (BUILD_GUIDE)

### 8.1 Phase Status Overview

| Phase | Name | Spec Reference | Status |
|-------|------|----------------|--------|
| Phase 0 | Schema Deployment | BUILD_GUIDE §3 | ✅ Complete |
| Phase 1 | Backend Services | BUILD_GUIDE §4 | 🟡 In Progress |
| Phase 2 | API Layer | BUILD_GUIDE §5 | 🟡 Partial |
| Phase 3 | Frontend State | BUILD_GUIDE §6 | ✅ Scaffold |
| Phase 4 | Frontend UI | BUILD_GUIDE §7 | 🟡 Scaffold |
| Phase 5 | Integration | BUILD_GUIDE §8 | ❌ |
| Phase 6 | Deployment | BUILD_GUIDE §9 | ❌ |

### 8.2 Phase 0: Schema Deployment (BUILD_GUIDE §3)

| Gate | Requirement | Status |
|------|-------------|--------|
| G0.1 | schema.sql executes without errors | ✅ |
| G0.2 | All 18 tables created | ✅ |
| G0.3 | All 17 triggers active | ✅ |
| G0.4 | INV-1 through INV-5 kill tests pass | ✅ |
| G0.5 | Schema version recorded | ✅ |

### 8.3 Phase 1: Backend Services (BUILD_GUIDE §4)

| Gate | Requirement | Status |
|------|-------------|--------|
| G1.1 | Database connection pool | ✅ |
| G1.2 | Transaction wrapper | ✅ |
| G1.3 | Type definitions from schema | 🟡 |
| G1.4 | EscrowService with INV-2 enforcement | 🟡 |
| G1.5 | TaskService with state machine | 🟡 |
| G1.6 | AtomicXPService with INV-1 enforcement | ❌ |
| G1.7 | ProofService | ❌ |
| G1.8 | DisputeService | ❌ |

### 8.4 Phase 2: API Layer (BUILD_GUIDE §5)

| Gate | Requirement | Status |
|------|-------------|--------|
| G2.1 | tRPC router configuration | ✅ |
| G2.2 | Escrow endpoints | 🟡 |
| G2.3 | Task endpoints | ❌ |
| G2.4 | Onboarding endpoints | ❌ |
| G2.5 | Evidence endpoints | ❌ |
| G2.6 | User endpoints | ❌ |
| G2.7 | Stripe webhook handler | ❌ |

### 8.5 Phase 3: Frontend State (BUILD_GUIDE §6)

| Gate | Requirement | Status |
|------|-------------|--------|
| G3.1 | TaskStateMachine | ✅ Scaffold |
| G3.2 | EscrowStateMachine | ✅ Scaffold |
| G3.3 | ProofStateMachine | ✅ Scaffold |
| G3.4 | OnboardingStateMachine | ✅ Scaffold |
| G3.5 | State machines match PRODUCT_SPEC | 🟡 |

### 8.6 Phase 4: Frontend UI (BUILD_GUIDE §7)

| Gate | Requirement | Status |
|------|-------------|--------|
| G4.1 | Screen scaffold | ✅ |
| G4.2 | Navigation structure | ✅ |
| G4.3 | Constants defined | ✅ |
| G4.4 | ESLint rules implemented | ❌ |
| G4.5 | Runtime guards implemented | ❌ |
| G4.6 | Accessibility compliance | ❌ |

### 8.7 Phase 5: Integration (BUILD_GUIDE §8)

| Gate | Requirement | Status |
|------|-------------|--------|
| G5.1 | Frontend connects to tRPC | ❌ |
| G5.2 | Stripe integration tested | ❌ |
| G5.3 | Full task lifecycle E2E | ❌ |
| G5.4 | Onboarding flow E2E | ❌ |
| G5.5 | Dispute flow E2E | ❌ |

### 8.8 Phase 6: Deployment (BUILD_GUIDE §9)

| Gate | Requirement | Status |
|------|-------------|--------|
| G6.1 | Schema deployed to production | ❌ |
| G6.2 | Backend deployed | ❌ |
| G6.3 | Frontend deployed | ❌ |
| G6.4 | Health checks passing | ❌ |
| G6.5 | Monitoring configured | ❌ |

---

## SECTION 9: TESTS

### 9.1 Invariant Tests (Kill Tests)

| Test | Invariant | File Path | Status |
|------|-----------|-----------|--------|
| INV-1: XP without RELEASED escrow fails | INV-1 | backend/tests/invariants/inv-1.test.ts | 🟡 |
| INV-2: RELEASED without COMPLETED fails | INV-2 | backend/tests/invariants/inv-2.test.ts | 🟡 |
| INV-3: COMPLETED without ACCEPTED proof fails | INV-3 | ❌ | ❌ |
| INV-4: Escrow amount change after funding fails | INV-4 | ❌ | ❌ |
| INV-5: Duplicate XP for same escrow fails | INV-5 | backend/tests/invariants/inv-1.test.ts | 🟡 |
| Terminal task modification fails | Terminal State | backend/tests/invariants/inv-2.test.ts | 🟡 |
| Terminal escrow modification fails | Terminal State | backend/tests/invariants/inv-2.test.ts | 🟡 |
| Badge deletion fails | INV-BADGE-2 | ❌ | ❌ |
| XP ledger deletion fails | Append-only | backend/tests/invariants/inv-1.test.ts | 🟡 |
| Admin action deletion fails | Append-only | ❌ | ❌ |

### 9.2 State Machine Tests

| Test | Machine | File Path | Status |
|------|---------|-----------|--------|
| Task: OPEN → ACCEPTED | TaskStateMachine | ❌ | ❌ |
| Task: ACCEPTED → PROOF_SUBMITTED | TaskStateMachine | ❌ | ❌ |
| Task: PROOF_SUBMITTED → COMPLETED | TaskStateMachine | ❌ | ❌ |
| Task: Invalid transition rejected | TaskStateMachine | ❌ | ❌ |
| Escrow: FUNDED → RELEASED (with COMPLETED task) | EscrowStateMachine | backend/tests/invariants/inv-2.test.ts | 🟡 |
| Escrow: FUNDED → RELEASED (without COMPLETED) fails | EscrowStateMachine | backend/tests/invariants/inv-2.test.ts | 🟡 |
| Proof: SUBMITTED → ACCEPTED | ProofStateMachine | ❌ | ❌ |

### 9.3 E2E Tests

| Test | Flow | File Path | Status |
|------|------|-----------|--------|
| Happy path: Post → Accept → Proof → Complete → Pay | Full flow | ❌ | ❌ |
| Dispute flow: Proof rejected → Dispute → Resolution | Dispute | ❌ | ❌ |
| Onboarding: Calibration → Role → Preferences | Onboarding | ❌ | ❌ |

---

## SECTION 10: EXECUTION PROGRESS SUMMARY

### 10.1 Overall Status

| Category | Total | ✅ | 🟡 | ❌ |
|----------|-------|----|----|-----|
| Database Tables | 18 | 18 | 0 | 0 |
| Database Triggers | 11 | 11 | 0 | 0 |
| Core Invariants (INV-1 to INV-5) | 5 | 0 | 5 | 0 |
| Backend Services | 11 | 0 | 2 | 9 |
| Backend Infrastructure | 4 | 0 | 4 | 0 |
| tRPC Endpoints | 22 | 0 | 6 | 16 |
| ESLint Rules | 12 | 0 | 0 | 12 |
| Runtime Guards | 8 | 0 | 0 | 8 |
| Frontend State Machines | 4 | 4 | 0 | 0 |
| Invariant Tests | 10 | 0 | 6 | 4 |
| E2E Tests | 3 | 0 | 0 | 3 |

### 10.2 Completion by Layer

| Layer | Authority | Status |
|-------|-----------|--------|
| Layer 0: Database | Highest | ✅ Schema + Triggers complete |
| Layer 1: Backend Services | High | 🟡 EscrowService + TaskService implemented |
| Layer 2: API Routes | High | 🟡 Escrow router implemented |
| Layer 3: Frontend Guards | Medium | ❌ Not started |
| Layer 4: Frontend UI | Low | 🟡 Partial (screens exist) |
| Layer 5: Tests | Verification | 🟡 INV-1 + INV-2 kill tests written |

### 10.3 Next Actions (Priority Order)

1. **[✅] Create backend scaffold** — tRPC + PostgreSQL connection
2. **[ ] Run schema.sql** — Apply triggers to database
3. **[🟡] Write INV-1 test** — Prove XP requires RELEASED escrow
4. **[🟡] Write INV-2 test** — Prove RELEASED requires COMPLETED
5. **[ ] Run tests** — Verify database enforces invariants
6. **[ ] Implement ProofService** — Required for INV-3 testing
7. **[ ] Write INV-3 test** — Prove COMPLETED requires ACCEPTED proof
8. **[ ] Connect mobile to backend** — Replace local state machines

---

## SECTION 11: VERIFICATION QUERIES

### 11.1 Check Invariant Trigger Existence

```sql
SELECT tgname, tgrelid::regclass, tgfoid::regproc
FROM pg_trigger
WHERE tgname IN (
  'task_terminal_guard',
  'escrow_terminal_guard', 
  'escrow_amount_immutable',
  'xp_requires_released_escrow',
  'xp_ledger_no_delete',
  'badge_no_delete',
  'escrow_released_requires_completed_task',
  'task_completed_requires_accepted_proof',
  'trust_tier_audit',
  'admin_actions_no_delete'
);
-- Expected: 10 rows
```

### 11.2 Verify INV-1 Enforcement

```sql
-- This should FAIL with HX101
INSERT INTO xp_ledger (user_id, task_id, escrow_id, base_xp, effective_xp, user_xp_before, user_xp_after, user_level_before, user_level_after, user_streak_at_award)
SELECT 
  u.id, t.id, e.id, 100, 100, 0, 100, 1, 1, 0
FROM users u, tasks t, escrows e
WHERE e.state = 'FUNDED'  -- NOT RELEASED
LIMIT 1;
```

### 11.3 Verify INV-2 Enforcement

```sql
-- This should FAIL with HX201
UPDATE escrows SET state = 'RELEASED'
WHERE id IN (
  SELECT e.id FROM escrows e
  JOIN tasks t ON e.task_id = t.id
  WHERE t.state != 'COMPLETED'
  LIMIT 1
);
```

### 11.4 Verify Terminal State Enforcement

```sql
-- This should FAIL with HX001
UPDATE tasks SET price = 9999
WHERE state = 'COMPLETED'
LIMIT 1;
```

---

## SECTION 12: TASK DISCOVERY & MATCHING SYSTEM

### 12.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `task_matching_scores` | TASK_DISCOVERY_SPEC §9 | migrations/002_critical_gaps_tables.sql | ❌ |
| `saved_searches` | TASK_DISCOVERY_SPEC §9 | migrations/002_critical_gaps_tables.sql | ❌ |

### 12.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| TaskDiscoveryService | PRODUCT_SPEC §9 | ❌ | ❌ |
| TaskExplanationService | PRODUCT_SPEC §9.5 | ❌ | ❌ |

### 12.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `taskDiscovery.getFeed` | query | PRODUCT_SPEC §9 | ❌ | ❌ |
| `taskDiscovery.search` | query | PRODUCT_SPEC §9 | ❌ | ❌ |
| `taskDiscovery.getExplanation` | query | PRODUCT_SPEC §9.5 | ❌ | ❌ |

### 12.4 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **DISCOVERY-1** | Matching score is always 0.0 to 1.0 | Backend validation | ❌ |
| **DISCOVERY-2** | Tasks below 0.20 score are hidden from feed | Backend filter | ❌ |
| **DISCOVERY-3** | Relevance score combines matching + boosts | Backend calculation | ❌ |
| **DISCOVERY-4** | Filters never bypass trust tier requirements | Backend validation | ❌ |
| **DISCOVERY-5** | Explanations are advisory only (A1) | AI authority model | ❌ |

---

## SECTION 13: MESSAGING SYSTEM

### 13.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `task_messages` | MESSAGING_SPEC §3.1 | migrations/002_critical_gaps_tables.sql | ❌ |

### 13.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| MessagingService | PRODUCT_SPEC §10 | ❌ | ❌ |

### 13.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `messaging.getThread` | query | MESSAGING_SPEC §9 | ❌ | ❌ |
| `messaging.sendMessage` | mutation | MESSAGING_SPEC §9 | ❌ | ❌ |
| `messaging.markRead` | mutation | MESSAGING_SPEC §9 | ❌ | ❌ |

### 13.4 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **MSG-1** | Messages only allowed during ACCEPTED/PROOF_SUBMITTED/DISPUTED | Backend validation | ❌ |
| **MSG-2** | Sender must be poster or worker for task | Backend validation | ❌ |
| **MSG-3** | Maximum 3 photos per message | DB constraint | ❌ |
| **MSG-4** | Maximum 500 characters per text message | Backend validation | ❌ |
| **MSG-5** | Chat history is immutable after task COMPLETED | Backend validation | ❌ |
| **MSG-6** | Read receipts are optional (privacy) | User preference | ❌ |

---

## SECTION 14: NOTIFICATION SYSTEM

### 14.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `notifications` | NOTIFICATION_SPEC §5.1 | migrations/002_critical_gaps_tables.sql | ❌ |
| `notification_preferences` | NOTIFICATION_SPEC §5.2 | migrations/002_critical_gaps_tables.sql | ❌ |

### 14.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| NotificationService | PRODUCT_SPEC §11 | ❌ | ❌ |

### 14.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `notifications.getList` | query | NOTIFICATION_SPEC §8 | ❌ | ❌ |
| `notifications.markRead` | mutation | NOTIFICATION_SPEC §8 | ❌ | ❌ |
| `notifications.markAllRead` | mutation | NOTIFICATION_SPEC §8 | ❌ | ❌ |
| `notifications.getPreferences` | query | NOTIFICATION_SPEC §8 | ❌ | ❌ |
| `notifications.updatePreferences` | mutation | NOTIFICATION_SPEC §8 | ❌ | ❌ |

### 14.4 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **NOTIF-1** | Notifications only sent to task participants (poster/worker) | Backend validation | ❌ |
| **NOTIF-2** | HIGH priority notifications bypass quiet hours | Backend logic | ❌ |
| **NOTIF-3** | Frequency limits enforced per category | Backend rate limiting | ❌ |
| **NOTIF-4** | Deep links must be valid (task exists, user has access) | Backend validation | ❌ |
| **NOTIF-5** | Notifications expire after 30 days | Backend cleanup job | ❌ |
| **NOTIF-6** | Grouped notifications share same category | Backend grouping logic | ❌ |

---

## SECTION 15: RATING SYSTEM

### 15.1 Database Tables

| Table/View | Spec Reference | Schema Location | Status |
|------------|----------------|-----------------|--------|
| `task_ratings` | RATING_SYSTEM_SPEC §4.1 | migrations/002_critical_gaps_tables.sql | ❌ |
| `user_rating_summary` (VIEW) | RATING_SYSTEM_SPEC §4.1 | migrations/002_critical_gaps_tables.sql | ❌ |

### 15.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| RatingService | PRODUCT_SPEC §12 | ❌ | ❌ |

### 15.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `ratings.submitRating` | mutation | RATING_SYSTEM_SPEC §9 | ❌ | ❌ |
| `ratings.getMyRatings` | query | RATING_SYSTEM_SPEC §9 | ❌ | ❌ |
| `ratings.getUserRatings` | query | RATING_SYSTEM_SPEC §9 | ❌ | ❌ |
| `ratings.getTaskRatings` | query | RATING_SYSTEM_SPEC §9 | ❌ | ❌ |

### 15.4 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **RATE-1** | Rating only allowed after task COMPLETED | Backend validation | ❌ |
| **RATE-2** | Rating window: 7 days after completion | Backend validation | ❌ |
| **RATE-3** | Both parties must rate (or auto-rated after 7 days) | Backend logic | ❌ |
| **RATE-4** | Ratings are immutable (cannot edit/delete) | DB constraint + backend validation | ❌ |
| **RATE-5** | One rating per pair per task | DB UNIQUE constraint | ❌ |
| **RATE-6** | Stars must be 1-5 | DB CHECK constraint | ❌ |
| **RATE-7** | Comment max 500 characters | DB CHECK constraint | ❌ |
| **RATE-8** | Ratings are blind until both parties rate | Backend logic | ❌ |

---

## SECTION 16: ANALYTICS INFRASTRUCTURE

### 16.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `analytics_events` | ANALYTICS_SPEC §5.1 | migrations/002_critical_gaps_tables.sql | ❌ |

### 16.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| AnalyticsService | PRODUCT_SPEC §13 | ❌ | ❌ |

### 16.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `analytics.track` | mutation | ANALYTICS_SPEC §7.1 | ❌ | ❌ |
| `analytics.getFunnel` | query | ANALYTICS_SPEC §7.1 | ❌ | ❌ |
| `analytics.getCohort` | query | ANALYTICS_SPEC §7.1 | ❌ | ❌ |
| `analytics.getABTestResults` | query | ANALYTICS_SPEC §7.1 | ❌ | ❌ |

### 16.4 Metrics to Track

| Metric | Target | Measurement | Status |
|--------|--------|-------------|--------|
| Feed acceptance rate | >15% | Tasks accepted / Tasks viewed | ❌ |
| Search conversion rate | >20% | Tasks accepted from search / Search queries | ❌ |
| Average matching score | >0.60 | Mean matching score of accepted tasks | ❌ |
| Rating completion rate | >80% | Ratings submitted / Tasks completed | ❌ |
| Notification delivery rate | >95% | Notifications delivered / Notifications sent | ❌ |
| Fraud detection rate | >95% | Fraud detected / Total fraud attempts | ❌ |

---

## SECTION 17: FRAUD DETECTION SYSTEM

### 17.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `fraud_risk_scores` | FRAUD_DETECTION_SPEC §5.1 | migrations/002_critical_gaps_tables.sql | ❌ |
| `fraud_patterns` | FRAUD_DETECTION_SPEC §5.1 | migrations/002_critical_gaps_tables.sql | ❌ |

### 17.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| FraudDetectionService | PRODUCT_SPEC §14 | ❌ | ❌ |

### 17.3 API Endpoints (Admin Only)

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `fraud.getRiskScore` | query | FRAUD_DETECTION_SPEC §7.1 | ❌ | ❌ |
| `fraud.getReviewQueue` | query | FRAUD_DETECTION_SPEC §7.1 | ❌ | ❌ |
| `fraud.reviewFlag` | mutation | FRAUD_DETECTION_SPEC §7.1 | ❌ | ❌ |
| `fraud.detectPatterns` | query | FRAUD_DETECTION_SPEC §7.1 | ❌ | ❌ |

### 17.4 Background Jobs

| Job | Purpose | Frequency | Status |
|-----|---------|-----------|--------|
| Calculate Risk Scores | Score all users/tasks/transactions | Daily | ❌ |
| Detect Fraud Patterns | Identify suspicious patterns | Daily | ❌ |
| Process Review Queue | Flag high-risk items | Real-time | ❌ |

### 17.5 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **FRAUD-1** | Risk scores are calculated for all users/tasks/transactions | Background job | ❌ |
| **FRAUD-2** | High-risk (≥0.6) entities require manual review | Backend validation | ❌ |
| **FRAUD-3** | Critical-risk (≥0.8) entities are auto-rejected | Backend validation | ❌ |
| **FRAUD-4** | Self-match (risk = 1.0) is always blocked | Backend validation | ❌ |
| **FRAUD-5** | Review decisions are logged in audit trail | Backend logging | ❌ |
| **FRAUD-6** | Risk scores are recalculated on pattern detection | Background job | ❌ |

---

## SECTION 18: CONTENT MODERATION WORKFLOW

### 18.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `content_moderation_queue` | CONTENT_MODERATION_SPEC §3.3 | migrations/002_critical_gaps_tables.sql | ❌ |
| `content_reports` | CONTENT_MODERATION_SPEC §4.3 | migrations/002_critical_gaps_tables.sql | ❌ |
| `content_appeals` | CONTENT_MODERATION_SPEC §7.3 | migrations/002_critical_gaps_tables.sql | ❌ |

### 18.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| ContentModerationService | PRODUCT_SPEC §15 | ❌ | ❌ |

### 18.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `moderation.getQueue` | query | CONTENT_MODERATION_SPEC §8.1 | ❌ | ❌ |
| `moderation.reviewItem` | mutation | CONTENT_MODERATION_SPEC §8.1 | ❌ | ❌ |
| `moderation.reportContent` | mutation | CONTENT_MODERATION_SPEC §8.1 | ❌ | ❌ |
| `moderation.appealDecision` | mutation | CONTENT_MODERATION_SPEC §8.1 | ❌ | ❌ |

### 18.4 AI Integration (A2 Authority)

| Component | AI Authority | Purpose | Status |
|-----------|--------------|---------|--------|
| Content Scanning | A2 (Propose) | Proposes: approve, flag, block | ❌ |
| Confidence Thresholds | A2 + Backend | ≥0.9 auto-block, 0.7-0.9 flag, <0.7 approve | ❌ |

### 18.5 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **MOD-1** | All user-generated content is scanned | Backend trigger on create/update | ❌ |
| **MOD-2** | CRITICAL content is auto-quarantined | Backend validation | ❌ |
| **MOD-3** | Review queue items have SLA deadlines | Backend calculation | ❌ |
| **MOD-4** | Appeals are reviewed by different admin | Backend assignment | ❌ |
| **MOD-5** | Deleted content is permanently removed | Backend deletion | ❌ |
| **MOD-6** | User notifications sent on actions | Backend notification service | ❌ |

---

## SECTION 19: GDPR COMPLIANCE & PRIVACY

### 19.1 Database Tables

| Table | Spec Reference | Schema Location | Status |
|-------|----------------|-----------------|--------|
| `gdpr_data_requests` | GDPR_COMPLIANCE_SPEC §7.1 | migrations/002_critical_gaps_tables.sql | ❌ |
| `user_consents` | GDPR_COMPLIANCE_SPEC §4.2 | migrations/002_critical_gaps_tables.sql | ❌ |

### 19.2 Backend Services

| Service | Spec Reference | File Path | Status |
|---------|----------------|-----------|--------|
| GDPRService | PRODUCT_SPEC §16 | ❌ | ❌ |

### 19.3 API Endpoints

| Endpoint | Method | Spec Reference | File Path | Status |
|----------|--------|----------------|-----------|--------|
| `privacy.requestDataExport` | mutation | GDPR_COMPLIANCE_SPEC §8.1 | ❌ | ❌ |
| `privacy.requestAccountDeletion` | mutation | GDPR_COMPLIANCE_SPEC §8.1 | ❌ | ❌ |
| `privacy.cancelDeletion` | mutation | GDPR_COMPLIANCE_SPEC §8.1 | ❌ | ❌ |
| `privacy.getConsents` | query | GDPR_COMPLIANCE_SPEC §8.1 | ❌ | ❌ |
| `privacy.updateConsent` | mutation | GDPR_COMPLIANCE_SPEC §8.1 | ❌ | ❌ |

### 19.4 Background Jobs

| Job | Purpose | Frequency | Status |
|-----|---------|-----------|--------|
| Generate Data Export | Create export file (JSON/CSV/PDF) | On-demand | ❌ |
| Process Account Deletion | Delete user data after grace period | Daily | ❌ |
| Cleanup Expired Exports | Delete export links after 30 days | Daily | ❌ |
| Cleanup Expired Notifications | Delete notifications after 30 days | Daily | ❌ |

### 19.5 Invariants

| ID | Invariant | Enforcement | Status |
|----|-----------|-------------|--------|
| **GDPR-1** | Data export requests processed within 30 days | Backend SLA enforcement | ❌ |
| **GDPR-2** | Data deletion requests processed within 7 days | Backend SLA enforcement | ❌ |
| **GDPR-3** | User consent records are immutable (append-only) | DB constraint | ❌ |
| **GDPR-4** | Legal retention periods enforced (7 years for transactions) | Backend validation | ❌ |
| **GDPR-5** | Data breach notifications sent within 72 hours | Backend alerting | ❌ |
| **GDPR-6** | Export links expire after 30 days | Backend cleanup job | ❌ |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial execution index with schema.sql v1.0.0 |
| 1.1.0 | Jan 2025 | Backend scaffold: EscrowService, TaskService, db.ts, trpc.ts, escrow router, INV-1/INV-2 kill tests |
| 1.2.0 | Jan 2025 | Added: ONB invariants (§3.6-3.7), UI_SPEC §12 ESLint rules, BUILD_GUIDE phases (§8), new frontend components (§7.5) |
| 1.3.0 | Jan 2025 | Added: Live Mode invariants (§3.8), Live Mode tables (§1.4), Live Mode triggers (§2.4) |
| 1.4.0 | Jan 2025 | Added: Human Systems gap tracking (§3.9) |
| 1.5.0 | Jan 2025 | INTEGRATED: All 7 Human Systems (§3.9-3.16), Human Systems tables (§1.5) |
| 1.6.0 | Jan 2025 | ADDED: Critical gaps tracking (§12-19) - Task Discovery, Messaging, Notifications, Ratings, Analytics, Fraud, Moderation, GDPR |

---

**END OF EXECUTION INDEX v1.5.0**

---

## PHASE 1: DATABASE MIGRATION ✅ COMPLETE (2026-01-08)

### Constitutional Schema Applied to Neon PostgreSQL

**Commit:** `06a32f2` on `feat/payment-hardening`
**Branch:** https://github.com/Sebdysart/hustlexp-ai-backend/tree/feat/payment-hardening

#### Schema Verification
- 18 tables created
- 17 triggers enforcing invariants
- Schema version: 1.0.0

#### Kill Test Results: 24/24 PASSING ✅

| Invariant | Tests | Status |
|-----------|-------|--------|
| INV-1: XP requires RELEASED escrow | 8 | ✅ |
| INV-2: RELEASED requires COMPLETED task | 8 | ✅ |
| INV-3: COMPLETED requires ACCEPTED proof | 4 | ✅ |
| Terminal State Protection | 4 | ✅ |

#### Error Codes Verified
- HX101: XP award without RELEASED escrow
- HX201: Escrow release without COMPLETED task
- HX301: Task completion without ACCEPTED proof
- HX001: Task terminal state violation
- HX002: Escrow terminal state violation

#### Next Steps
- [ ] Start backend server (`npm run dev`)
- [ ] Connect frontend to tRPC
- [ ] Implement Stripe webhooks
- [ ] Deploy to staging

