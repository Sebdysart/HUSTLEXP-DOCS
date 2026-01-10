# HustleXP Repository

**This repository contains authoritative specifications and frontend scaffold code.**

The specifications are constitutional — code must conform to specs, not vice versa.

---

## Repository Structure

```
HustleXP-Fresh/
├── SPECIFICATIONS (Constitutional Authority)
│   ├── PRODUCT_SPEC.md        ← WHAT must be true (+ Live Mode §3.5-3.6)
│   ├── ARCHITECTURE.md        ← WHO can make it true (+ Live Mode §10)
│   ├── UI_SPEC.md             ← HOW it is expressed (+ Live Mode §13)
│   ├── BUILD_GUIDE.md         ← HOW it is built
│   ├── ONBOARDING_SPEC.md     ← Onboarding flow
│   ├── AI_INFRASTRUCTURE.md   ← AI governance
│   ├── EXECUTION_INDEX.md     ← Implementation tracking
│   └── schema.sql             ← Database enforcement (+ Live Mode tables)
│
├── STAGING (Reference / Archive)
│   └── LIVE_MODE_SPEC.md      ← Original spec (INTEGRATED into main specs)
│
├── FRONTEND SCAFFOLD (Reference Implementation)
│   ├── screens/               ← Screen components
│   ├── state/                 ← State machines
│   ├── components/            ← UI components
│   ├── constants/             ← Design tokens
│   └── navigation/            ← Navigation structure
│
└── PLATFORM (Generated)
    ├── ios/                   ← iOS build artifacts
    ├── android/               ← Android build artifacts
    └── node_modules/          ← Dependencies
```

---

## Specification Documents

| Document | Purpose | Status |
|----------|---------|--------|
| [PRODUCT_SPEC.md](./PRODUCT_SPEC.md) | Core invariants, state machines, **All Critical Gaps, AI Task Completion** | ✅ v1.4.0 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Layer hierarchy, authority model, **Live Mode authority** | ✅ v1.1.0 |
| [UI_SPEC.md](./UI_SPEC.md) | Visual rules, **Layered Hierarchy, Max-Tier UI, All Human Systems** | ✅ v1.5.0 |
| [BUILD_GUIDE.md](./BUILD_GUIDE.md) | Implementation rules, testing requirements, phase gates (phases 0-14) | ✅ v1.0.0 |
| [ONBOARDING_SPEC.md](./ONBOARDING_SPEC.md) | User onboarding flow, role inference | ✅ v1.3.0 |
| [AI_INFRASTRUCTURE.md](./AI_INFRASTRUCTURE.md) | AI governance, **Session Forecast** | ✅ v1.2.0 |
| [EXECUTION_INDEX.md](./EXECUTION_INDEX.md) | Implementation tracking, **All features (sections 1-19)** | ✅ v1.6.0 |
| [schema.sql](./schema.sql) | Database schema, **All tables including critical gaps** | ✅ v1.1.0 |

---

## Staging Documents

Staging documents are **reference/archive** after integration.

### Integrated Specs (Reference)

| Document | Purpose | Status |
|----------|---------|--------|
| [LIVE_MODE_SPEC.md](./staging/LIVE_MODE_SPEC.md) | Original real-time task spec | ✅ INTEGRATED |
| [HUMAN_SYSTEMS_SPEC.md](./staging/HUMAN_SYSTEMS_SPEC.md) | Original human systems spec | ✅ INTEGRATED |
| [AI_TASK_COMPLETION_SPEC.md](./staging/AI_TASK_COMPLETION_SPEC.md) | AI contract-completion engine spec | ✅ INTEGRATED |

### Integrated Critical Gap Specs (Reference)

| Document | Purpose | Status |
|----------|---------|--------|
| [TASK_DISCOVERY_SPEC.md](./staging/TASK_DISCOVERY_SPEC.md) | Task discovery & matching algorithm | ✅ **INTEGRATED** → PRODUCT_SPEC §9 |
| [MESSAGING_SPEC.md](./staging/MESSAGING_SPEC.md) | In-app messaging system | ✅ **INTEGRATED** → PRODUCT_SPEC §10 |
| [NOTIFICATION_SPEC.md](./staging/NOTIFICATION_SPEC.md) | Push notification system | ✅ **INTEGRATED** → PRODUCT_SPEC §11 |
| [RATING_SYSTEM_SPEC.md](./staging/RATING_SYSTEM_SPEC.md) | Bidirectional rating system | ✅ **INTEGRATED** → PRODUCT_SPEC §12 |
| [ANALYTICS_SPEC.md](./staging/ANALYTICS_SPEC.md) | Analytics & metrics infrastructure | ✅ **INTEGRATED** → PRODUCT_SPEC §13 |
| [FRAUD_DETECTION_SPEC.md](./staging/FRAUD_DETECTION_SPEC.md) | Fraud detection & risk scoring | ✅ **INTEGRATED** → PRODUCT_SPEC §14 |
| [CONTENT_MODERATION_SPEC.md](./staging/CONTENT_MODERATION_SPEC.md) | Content moderation workflow | ✅ **INTEGRATED** → PRODUCT_SPEC §15 |
| [GDPR_COMPLIANCE_SPEC.md](./staging/GDPR_COMPLIANCE_SPEC.md) | GDPR & privacy compliance | ✅ **INTEGRATED** → PRODUCT_SPEC §16 |

**All 9 critical gap specs are now constitutional law. Tables integrated into schema.sql v1.1.0.**

### Integration Map

**Integrated Specs:**
| Original Spec | Integrated Into | Status |
|--------------|-----------------|--------|
| LIVE_MODE_SPEC | PRODUCT_SPEC §3.5-3.6, ARCHITECTURE §10, UI_SPEC §14, schema.sql | ✅ Complete |
| HUMAN_SYSTEMS GAP-1 | UI_SPEC §15 (Money Timeline), schema.sql (money_timeline view) | ✅ Complete |
| HUMAN_SYSTEMS GAP-2 | UI_SPEC §16 (Failure Recovery UX) | ✅ Complete |
| HUMAN_SYSTEMS GAP-3 | UI_SPEC §17 (Session Forecast), schema.sql | ✅ Complete |
| HUMAN_SYSTEMS GAP-4 | UI_SPEC §18 (Private Percentile) | ✅ Complete |
| HUMAN_SYSTEMS GAP-5 | UI_SPEC §14 (Live Mode only, per product decision) | ✅ Complete |
| HUMAN_SYSTEMS GAP-6 | UI_SPEC §19 (Poster Reputation), schema.sql | ✅ Complete |
| HUMAN_SYSTEMS GAP-7 | UI_SPEC §20 (Pause State), schema.sql | ✅ Complete |
| AI_TASK_COMPLETION | PRODUCT_SPEC §8, BUILD_GUIDE §4.6 | ✅ Complete |
| **Layered Influence Hierarchy** | UI_SPEC §2 (The UI Stack) | ✅ Complete |
| TASK_DISCOVERY_SPEC | PRODUCT_SPEC §9, schema.sql §11.1 | ✅ Complete |
| MESSAGING_SPEC | PRODUCT_SPEC §10, schema.sql §11.2 | ✅ Complete |
| NOTIFICATION_SPEC | PRODUCT_SPEC §11, schema.sql §11.3 | ✅ Complete |
| RATING_SYSTEM_SPEC | PRODUCT_SPEC §12, schema.sql §11.4 | ✅ Complete |
| ANALYTICS_SPEC | PRODUCT_SPEC §13, schema.sql §11.5 | ✅ Complete |
| FRAUD_DETECTION_SPEC | PRODUCT_SPEC §14, schema.sql §11.6 | ✅ Complete |
| CONTENT_MODERATION_SPEC | PRODUCT_SPEC §15, schema.sql §11.7 | ✅ Complete |
| GDPR_COMPLIANCE_SPEC | PRODUCT_SPEC §16, schema.sql §11.8 | ✅ Complete |

---

## Document Hierarchy

```
PRODUCT_SPEC.md      ← Defines WHAT must be true (v1.4.0)
    ↓
ARCHITECTURE.md      ← Defines WHO can make it true (v1.1.0)
    ↓
UI_SPEC.md           ← Defines HOW it is expressed (v1.5.0 - MAX-TIER)
    ↓
BUILD_GUIDE.md       ← Defines HOW it is built (v1.0.0 - phases 0-14)
    ↓
schema.sql           ← Database enforcement (v1.1.0 - all tables)
```

**Key Features:**
- **Layered Influence Hierarchy** (UI_SPEC §2): The UI Stack (Apple Glass → Duolingo → COD/Clash Royale)
- **All Critical Gaps Integrated**: Task Discovery, Messaging, Notifications, Ratings, Analytics, Fraud, Moderation, GDPR
- **Max-Tier UI Complete**: All 7 human systems + layered hierarchy with 7 invariants

All other specs and code derive authority from this chain.

---

## Frontend Scaffold

The frontend code in this repository is a **reference implementation scaffold** that demonstrates:
- State machine structure matching backend definitions
- Screen organization following UI_SPEC rules
- Component patterns following accessibility requirements

This code is **not production-ready**. It exists to:
1. Validate spec feasibility
2. Provide implementation guidance
3. Establish patterns for the full implementation

**Production implementation** should be built following BUILD_GUIDE.md phases.

---

## Related Repositories

| Repository | Purpose |
|------------|---------|
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Backend services, API, database |

---

## Schema

The canonical database schema lives in [`schema.sql`](./schema.sql) (v1.1.0, ~1,900 lines).

This schema enforces all core invariants (INV-1 through INV-5) at Layer 0 via PostgreSQL triggers.

**Schema Contents:**
- ✅ Core tables (18): users, tasks, escrows, proofs, XP, trust, badges, disputes, etc.
- ✅ AI Infrastructure tables (5): ai_events, ai_jobs, ai_proposals, ai_decisions, evidence
- ✅ Live Mode tables (2): live_sessions, live_broadcasts
- ✅ Human Systems tables/views (4): poster_ratings, poster_reputation, session_forecasts, money_timeline
- ✅ **Critical Gap tables (14)**: task_matching_scores, task_messages, notifications, task_ratings, analytics_events, fraud_risk_scores, content_moderation_queue, gdpr_data_requests, etc.

**Applied to production:** ✅ Neon PostgreSQL  
**Kill tests passing:** 24/24 ✅  
**Total tables:** 32 tables + 4 views

---

## Governance

- Specs are **constitutional** — code must conform to specs, not vice versa
- Changes require review + 24h cooling period
- PRODUCT_SPEC.md is the root authority document
- Violations are build failures, not style issues

---

## Quick Reference

### Core Invariants

| ID | Rule | Enforcement |
|----|------|-------------|
| INV-1 | XP requires RELEASED escrow | DB trigger HX101 |
| INV-2 | RELEASED requires COMPLETED task | DB trigger HX201 |
| INV-3 | COMPLETED requires ACCEPTED proof | DB trigger HX301 |
| INV-4 | Escrow amount immutable | DB trigger HX401 |
| INV-5 | XP idempotent per escrow | UNIQUE constraint |

### Layer Hierarchy

| Layer | Authority |
|-------|-----------|
| 0 — Database | Absolute truth |
| 1 — Backend | Orchestration |
| 2 — API | Transport |
| 3 — AI | Proposals only |
| 4 — Frontend Logic | UX state only |
| 5 — UI | Representation only |
| 6 — Human | Bounded override |

### Build Phases

| Phase | Gate |
|-------|------|
| 0 — Schema | All triggers verified |
| 1 — Backend Services | All kill tests pass |
| 2 — API Layer | All endpoints tested |
| 3 — Frontend State | State machines match backend |
| 4 — Frontend UI | ESLint + guards pass |
| 5 — Integration | E2E tests pass |
| 6 — Deployment | Production verified |

---

## Contact

Owner: Sebastian Dysart  
Project: HustleXP
