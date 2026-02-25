# UNIT ECONOMICS

**Authority:** PRODUCT_SPEC | STRIPE_INTEGRATION | FINISHED_STATE
**Status:** v1.0 — Living document (updated as costs change)

---

## §1. Revenue Model

| Source | Rate | Applied To |
|---|---|---|
| Platform fee | 15% | Every completed task |
| Safety pool premium | ~1-3% (dynamic) | Per-task, risk-adjusted (RISK_TRUST_ENGINE) |
| **Effective take rate** | **~16-18%** | Total platform revenue per task |

**Revenue per task (average $25 task):**
- Platform fee: $3.75
- Safety pool: ~$0.50
- **Gross revenue: ~$4.25**

---

## §2. Cost Structure (Per Transaction)

| Cost | Amount | Source |
|---|---|---|
| Stripe processing (2.9% + $0.30) | ~$1.03 | Payment processing |
| Stripe Connect transfer | Included in above | Worker payout |
| Stripe Connect payout (standard) | $0.00 | Free for standard speed |
| **Net revenue per $25 task** | **~$3.22** | After Stripe |

---

## §3. Fixed Costs (Monthly, Estimated at 1K Users)

| Service | Cost | Notes |
|---|---|---|
| Railway hosting | $50-150 | 2-3 instances, auto-scale |
| Neon database | $19-69 | Pro plan, branching |
| Redis (Upstash) | $10-30 | Rate limiting, job queues |
| Google Maps API | $200-500 | Geocoding, directions, Places |
| Firebase Auth | Free | Spark plan covers auth |
| Checkr background checks | $25-85/check | One-time per worker |
| Sentry error tracking | $26 | Team plan |
| Analytics (PostHog/Mixpanel) | $0-50 | Free tier initially |
| Stripe Radar (fraud) | $0.05/screened | Per transaction |
| Image moderation API | $1-5/1K images | Cloud Vision or Rekognition |
| Push notifications (APNs) | Free | Apple Push Notification service |
| **Total monthly fixed** | **~$400-1,000** | At 1K users |

---

## §4. Break-Even Analysis

**Assumptions:**
- Average task value: $25
- Net revenue per task: $3.22
- Monthly fixed costs: $700 (midpoint)

**Break-even:** $700 / $3.22 = **~217 completed tasks/month** (~7/day)

**At 1,000 monthly tasks:** $3,220 revenue - $700 costs = **$2,520 monthly profit**

---

## §5. Sensitivity Analysis

| Scenario | Take Rate | Avg Task | Monthly Tasks | Monthly Profit |
|---|---|---|---|---|
| Conservative | 15% | $20 | 200 | $-60 (loss) |
| Base case | 15% | $25 | 500 | $910 |
| Growth | 15% | $30 | 1,000 | $3,250 |
| Scale | 15% | $25 | 5,000 | $15,400 |

**Key sensitivity:** Google Maps costs scale with usage. At 10K users, Maps alone could be $2-5K/month. Implement caching aggressively (SPATIAL_INTELLIGENCE §3 cost tiers).

---

## §6. Checkr Cost Model

Background checks are one-time per worker:
- Basic: $25 (criminal + sex offender)
- Standard: $50 (+ county courts)
- Premium: $85 (+ federal + education)

**HustleXP v1:** Basic check for all workers ($25). Who pays:
- Platform absorbs cost for first 500 workers (growth investment: $12,500)
- After 500: worker pays, deducted from first earnings

---

**END OF UNIT_ECONOMICS v1.0.0**
