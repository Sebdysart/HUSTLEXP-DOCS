# REFERRAL SYSTEM SPECIFICATION

**Authority:** PRODUCT_SPEC | STRIPE_INTEGRATION | ONBOARDING_SPEC
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. Overview

Referrals are the #1 growth lever for gig marketplaces. Every user receives a unique referral code. Rewards are issued after the referee completes meaningful platform activity.

---

## §2. Referral Code

- Generated at account creation: `{first_name_upper}{random_4_alphanumeric}` (e.g., `ALEX7K2M`)
- Unique constraint in database
- Shareable via: SMS, clipboard copy, native share sheet
- Deep link: `hustlexp://referral/{code}` → pre-fills referral field on signup

---

## §3. Reward Structure

| Event | Referrer Reward | Referee Reward |
|---|---|---|
| Referee signs up | None | None |
| Referee completes first task (as worker) | $10 credit | $5 credit |
| Referee posts first task (as poster) | $10 credit | $5 off first task |

**Credit behavior:**
- Credits applied automatically to next task payment (poster) or added to wallet balance (worker)
- Credits expire after 90 days
- Credits are non-transferable and non-cashable
- Maximum referral rewards per user per month: $200 (anti-farming)

---

## §4. Fraud Prevention

| Attack | Defense |
|---|---|
| Self-referral | Same device fingerprint check (PRODUCT_SPEC §23.2) |
| Referral farming (fake accounts) | Reward requires completed task (real work done) |
| Referral code sharing on public forums | Monthly cap ($200) limits damage |
| Collusion (refer friend, friend refers back) | Mutual referral allowed (both do real work) |

---

## §5. Schema

```sql
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID NOT NULL REFERENCES users(id),
    referee_id UUID NOT NULL REFERENCES users(id),
    referral_code TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'QUALIFIED', 'REWARDED', 'EXPIRED', 'FRAUDULENT')),
    qualified_at TIMESTAMPTZ,
    rewarded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE UNIQUE INDEX idx_referral_referee ON referrals(referee_id);
CREATE INDEX idx_referral_referrer ON referrals(referrer_id);

CREATE TABLE IF NOT EXISTS referral_credits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount INTEGER NOT NULL CHECK (amount > 0),
    source TEXT NOT NULL CHECK (source IN ('REFERRAL_REWARD', 'REFEREE_BONUS')),
    referral_id UUID REFERENCES referrals(id),
    applied_to_task UUID REFERENCES tasks(id),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
```

---

## §6. API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `referral.getCode` | GET | Get user's referral code |
| `referral.getStats` | GET | Referral count, rewards earned |
| `referral.apply` | POST | Apply referral code during signup |

---

**END OF REFERRAL_SYSTEM_SPEC v1.0.0**
