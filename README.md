# HustleXP Repository

**This repository contains authoritative specifications and frontend scaffold code.**

The specifications are constitutional — code must conform to specs, not vice versa.

---

## Repository Structure

```
HustleXP-Fresh/
├── SPECIFICATIONS (Constitutional Authority)
│   ├── PRODUCT_SPEC.md        ← WHAT must be true
│   ├── ARCHITECTURE.md        ← WHO can make it true
│   ├── UI_SPEC.md             ← HOW it is expressed
│   ├── BUILD_GUIDE.md         ← HOW it is built
│   ├── ONBOARDING_SPEC.md     ← Onboarding flow
│   ├── AI_INFRASTRUCTURE.md   ← AI governance
│   ├── EXECUTION_INDEX.md     ← Implementation tracking
│   └── schema.sql             ← Database enforcement
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
| [PRODUCT_SPEC.md](./PRODUCT_SPEC.md) | Core invariants, state machines, business rules | ✅ v1.0.0 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Layer hierarchy, authority model | ✅ v1.0.0 |
| [UI_SPEC.md](./UI_SPEC.md) | Visual rules, animation constraints, copy guidelines | ✅ v1.0.0 |
| [BUILD_GUIDE.md](./BUILD_GUIDE.md) | Implementation rules, testing requirements, phase gates | ✅ v1.0.0 |
| [ONBOARDING_SPEC.md](./ONBOARDING_SPEC.md) | User onboarding flow, role inference | ✅ v1.2.0 |
| [AI_INFRASTRUCTURE.md](./AI_INFRASTRUCTURE.md) | AI governance, proposal/decision model | ✅ v1.1.0 |
| [EXECUTION_INDEX.md](./EXECUTION_INDEX.md) | Implementation tracking matrix | ✅ v1.1.0 |

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
