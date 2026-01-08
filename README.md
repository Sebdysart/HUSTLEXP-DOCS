# HustleXP Documentation Repository

**This repository contains authoritative specifications only.**

No application code lives here. Implementation repos reference these documents as the source of truth.

---

## Specification Documents

| Document | Purpose | Status |
|----------|---------|--------|
| [PRODUCT_SPEC.md](./PRODUCT_SPEC.md) | Core invariants, state machines, business rules | ✅ v1.0.0 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Layer hierarchy, authority model | ⏳ Pending |
| [UI_SPEC.md](./UI_SPEC.md) | Visual rules, animation constraints, copy guidelines | ⏳ Pending |
| [BUILD_GUIDE.md](./BUILD_GUIDE.md) | Implementation rules, testing requirements | ⏳ Pending |
| [ONBOARDING_SPEC.md](./ONBOARDING_SPEC.md) | User onboarding flow, role inference | ✅ v1.2.0 |
| [AI_INFRASTRUCTURE.md](./AI_INFRASTRUCTURE.md) | AI governance, proposal/decision model | ✅ v1.1.0 |
| [EXECUTION_INDEX.md](./EXECUTION_INDEX.md) | Implementation tracking matrix | ✅ v1.1.0 |

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

---

## Governance

- Specs are **constitutional** — code must conform to specs, not vice versa
- Changes require review + 24h cooling period
- PRODUCT_SPEC.md is the root authority document

---

## Contact

Owner: Sebastian Dysart  
Project: HustleXP
