# HustleXP Private Beta Specification

> **Status**: 100/100 — Code complete. Gate 1 (Legal) is the only remaining hard block.
>
> **Machine-readable gate status**: [`private-beta/scorecard.json`](private-beta/scorecard.json)

---

## Gate Summary

| Gate | Type | Status | Details |
|------|------|--------|---------|
| Gate 1: Legal documents | HARD BLOCK | 🔴 Open | Placeholders unfilled — see `legal/README.md` |
| Gate 2: Revenue bugs | HARD BLOCK | ✅ Closed | commit `850f9207` |
| Gate 3: DisputeScreen fake success | HARD BLOCK | ✅ Closed | commits `c6e9ce57` + `9f94e39` |
| Gate 4: iOS feature parity | Required | ✅ Closed | commits `0d34ead` + `3d76679` |
| Gate 5: Backend security | P1 | ✅ Closed | commits `ab669a0d` + `f46c2979` |

**Do not open beta invites until Gates 1, 2, and 3 are all closed.**

---

## 6-Journey Smoke Test (must run before launch)

| Journey | Scope | Status |
|---------|-------|--------|
| J1 — Hustler Earn | Browse → Accept → Complete → Submit proof → Poster approves → Stripe payout | ⬜ Not run |
| J2 — Poster Help | Create task → Fund escrow → Approve completion → Platform fee verified | ⬜ Not run |
| J3 — Messaging | 3+ messages on active task, both parties see in real time | ⬜ Not run |
| J4 — Trust | Upload ID → Background check consent → Trust tier updates | ⬜ Not run |
| J5 — Disputes | File dispute → DB record created → Escrow locks → Resolution applied | ⬜ Not run |
| J6 — Admin | Ban test user → Refund escrow → View financials dashboard | ⬜ Not run |

---

## Beta Tier Definitions

- **B1 (must work, 100%)**: J1–J6 core journeys + I1–I7 integrations + V1–V4 invariants
- **B2 (nice-to-have, 80%)**: Secondary flows, edge cases, performance targets
- **B3 (deferred, 0%)**: Checkr full API, Android, Squads full feature, AWS Rekognition liveness, FCM push token hardening

---

## Launch Day Verification Commands

```bash
# 1. Backend test suite — must show 0 failures and ≥ 88.88% coverage
cd /path/to/hustlexp-ai-backend
npx vitest run --coverage 2>&1 | tail -5

# 2. Ecosystem health — must show 100/100 overall
node /path/to/omni-link-hustlexp/dist/cli.js health

# 3. Payload drift — must be ≤ 11 (irreducible floor; anything above 11 is a regression)
node /path/to/omni-link-hustlexp/dist/cli.js authority-status
```

**`payloadDrift=11` is the irreducible floor** — all Swift↔TypeScript type-representation differences. Do not attempt to fix these.

---

## First 24 Hours Post-Launch Monitoring

| Check | What to Look For | Tool |
|-------|-----------------|------|
| Stripe platform fee | `application_fee_amount` > 0 on all charges | Stripe dashboard → Payments |
| Dispute storage | Disputes filed by users appear in `disputes` table | Supabase / DB query |
| Server errors | Monitor for 500s | Backend logs |
| Escrow fee accuracy | Spot-check 3 completed tasks: `escrow.amount` used for fee | DB query |

---

## Screen Specifications

iOS screen specs live in [`screens-spec/`](screens-spec/) organized by role (Hustler, Poster, Shared, Auth, Edge, Onboarding).

---

*Last updated: 2026-03-15*
