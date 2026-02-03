# HustleXP Staging Specs

**STATUS: MIXED — Some promoted, some stubs, some superseded**

---

## SUPERSEDED (Promoted to canonical locations — DO NOT USE)

| File | Canonical Location | Lines |
|------|--------------------|-------|
| `FRAUD_DETECTION_SPEC.md` | `specs/02-architecture/subsystems/RISK_TRUST_ENGINE_LOCKED.md` | 1,096 |
| `MESSAGING_SPEC.md` | `specs/01-product/features/MESSAGING_SPEC.md` | 456 |
| `NOTIFICATION_SPEC.md` | `specs/01-product/features/NOTIFICATION_SPEC.md` | 498 |
| `RATING_SYSTEM_SPEC.md` | `specs/01-product/features/RATING_SYSTEM_SPEC.md` | 493 |

## ACTIVE STAGING (Stubs — to be expanded post-v1.0)

| File | Purpose | Launch-Blocking? |
|------|---------|-----------------|
| `AI_TASK_COMPLETION_SPEC.md` | AI-powered task completion verification | No (Judge Agent covers core) |
| `ANALYTICS_SPEC.md` | Product analytics and metrics | No |
| `CONTENT_MODERATION_SPEC.md` | User content moderation | No (Judge Agent §4.2 covers basics) |
| `GDPR_COMPLIANCE_SPEC.md` | EU privacy compliance | No (US launch only; AI_INFRASTRUCTURE §9.6 covers retention) |
| `TASK_DISCOVERY_SPEC.md` | Advanced search/filter UX | No (FEED_QUERY_AND_ELIGIBILITY_RESOLVER covers core) |

---

**Rule:** Stubs in staging are NOT implementation-ready. Check the canonical spec directories first.
