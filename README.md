# HustleXP Documentation Repository

**This repository contains authoritative specifications only.**

No application code lives here. Implementation repos reference these documents as the source of truth.

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

All other specs derive authority from this chain.

---

## Related Repositories

| Repository | Purpose |
|------------|---------|
| [hustlexp-ai-backend](https://github.com/Sebdysart/hustlexp-ai-backend) | Backend services, API, database |
| HustleXP Mobile (private) | React Native mobile app |

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

---

## Contact

Owner: Sebastian Dysart  
Project: HustleXP
