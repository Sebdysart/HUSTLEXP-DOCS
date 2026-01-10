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
| [PRODUCT_SPEC.md](./PRODUCT_SPEC.md) | Core invariants, state machines, **Human Systems, AI Task Completion** | ✅ v1.3.0 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Layer hierarchy, authority model, **Live Mode authority** | ✅ v1.1.0 |
| [UI_SPEC.md](./UI_SPEC.md) | Visual rules, **Money Timeline, Failure Recovery** | ✅ v1.3.0 |
| [BUILD_GUIDE.md](./BUILD_GUIDE.md) | Implementation rules, testing requirements, phase gates | ✅ v1.0.0 |
| [ONBOARDING_SPEC.md](./ONBOARDING_SPEC.md) | User onboarding flow, role inference | ✅ v1.3.0 |
| [AI_INFRASTRUCTURE.md](./AI_INFRASTRUCTURE.md) | AI governance, **Session Forecast** | ✅ v1.2.0 |
| [EXECUTION_INDEX.md](./EXECUTION_INDEX.md) | Implementation tracking, **Human Systems invariants** | ✅ v1.5.0 |

---

## Staging Documents

Staging documents are **reference/archive** after integration.

### Integrated Specs (Reference)

| Document | Purpose | Status |
|----------|---------|--------|
| [LIVE_MODE_SPEC.md](./staging/LIVE_MODE_SPEC.md) | Original real-time task spec | ✅ INTEGRATED |
| [HUMAN_SYSTEMS_SPEC.md](./staging/HUMAN_SYSTEMS_SPEC.md) | Original human systems spec | ✅ INTEGRATED |
| [AI_TASK_COMPLETION_SPEC.md](./staging/AI_TASK_COMPLETION_SPEC.md) | AI contract-completion engine spec | ✅ INTEGRATED |

### New Critical Gap Specs (Ready for Integration)

| Document | Purpose | Status |
|----------|---------|--------|
| [TASK_DISCOVERY_SPEC.md](./staging/TASK_DISCOVERY_SPEC.md) | Task discovery & matching algorithm | ✅ v1.0.0 - Ready |
| [MESSAGING_SPEC.md](./staging/MESSAGING_SPEC.md) | In-app messaging system | ✅ v1.0.0 - Ready |
| [NOTIFICATION_SPEC.md](./staging/NOTIFICATION_SPEC.md) | Push notification system | ✅ v1.0.0 - Ready |
| [RATING_SYSTEM_SPEC.md](./staging/RATING_SYSTEM_SPEC.md) | Bidirectional rating system | ✅ v1.0.0 - Ready |
| [ANALYTICS_SPEC.md](./staging/ANALYTICS_SPEC.md) | Analytics & metrics infrastructure | ✅ v1.0.0 - Ready |
| [FRAUD_DETECTION_SPEC.md](./staging/FRAUD_DETECTION_SPEC.md) | Fraud detection & risk scoring | ✅ v1.0.0 - Ready |
| [CONTENT_MODERATION_SPEC.md](./staging/CONTENT_MODERATION_SPEC.md) | Content moderation workflow | ✅ v1.0.0 - Ready |
| [GDPR_COMPLIANCE_SPEC.md](./staging/GDPR_COMPLIANCE_SPEC.md) | GDPR & privacy compliance | ✅ v1.0.0 - Ready |

**These specs address all 9 critical gaps identified in the deep scan audit. Ready for integration into constitutional law.**

### Integration Map

**Integrated:**
| Original Spec | Integrated Into |
|--------------|-----------------|
| LIVE_MODE_SPEC | PRODUCT_SPEC §3.5-3.6, ARCHITECTURE §10, UI_SPEC §13, schema.sql |
| HUMAN_SYSTEMS GAP-1 | UI_SPEC §14 (Money Timeline), schema.sql (money_timeline view) |
| HUMAN_SYSTEMS GAP-2 | UI_SPEC §15 (Failure Recovery UX) |
| HUMAN_SYSTEMS GAP-3 | AI_INFRASTRUCTURE §21 (Session Forecast), schema.sql |
| HUMAN_SYSTEMS GAP-4 | PRODUCT_SPEC §8.3 (Private Percentile) |
| HUMAN_SYSTEMS GAP-5 | PRODUCT_SPEC §3.7 (Global Fatigue), schema.sql |
| HUMAN_SYSTEMS GAP-6 | PRODUCT_SPEC §8.4 (Poster Reputation), schema.sql |
| HUMAN_SYSTEMS GAP-7 | PRODUCT_SPEC §11 (Account Pause), schema.sql |
| AI_TASK_COMPLETION | PRODUCT_SPEC §8 (AI Task Completion), BUILD_GUIDE §4.6 |

**Pending Integration (Critical Gaps):**
| New Spec | Priority | Ready For Integration |
|----------|----------|----------------------|
| TASK_DISCOVERY_SPEC | 🔴 CRITICAL | ✅ Yes - Lock first |
| MESSAGING_SPEC | 🔴 HIGH | ✅ Yes |
| NOTIFICATION_SPEC | 🔴 HIGH | ✅ Yes |
| RATING_SYSTEM_SPEC | 🟡 MEDIUM | ✅ Yes |
| ANALYTICS_SPEC | 🔴 HIGH | ✅ Yes |
| FRAUD_DETECTION_SPEC | 🔴 CRITICAL | ✅ Yes |
| CONTENT_MODERATION_SPEC | 🔴 HIGH | ✅ Yes |
| GDPR_COMPLIANCE_SPEC | 🔴 CRITICAL | ✅ Yes |

---

## Document Hierarchy

```
PRODUCT_SPEC.md      ← Defines WHAT must be true
    ↓
ARCHITECTURE.md      ← Defines WHO can make it true
    ↓
UI_SPEC.md           ← Defines HOW it is expressed
    ↓
BUILD_GUIDE.md       ← Defines HOW it is built
```

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

The canonical database schema lives in [`schema.sql`](./schema.sql) (1,130 lines).

This schema enforces all core invariants (INV-1 through INV-5) at Layer 0 via PostgreSQL triggers.

**Applied to production:** ✅ Neon PostgreSQL  
**Kill tests passing:** 24/24 ✅

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
