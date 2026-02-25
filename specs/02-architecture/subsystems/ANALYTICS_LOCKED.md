# ANALYTICS SPECIFICATION

**Authority:** PRODUCT_SPEC §15 | ARCHITECTURE.md
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED
**Resolves:** GAP-9 (analytics stub)

---

## §1. Analytics Architecture

```
Client Event → analytics_events table → Nightly ETL → Warehouse (Neon PostgreSQL) → Dashboard (PostHog)
```

**Technology lock:** PostHog (self-hosted or cloud). Open-source, GDPR-compliant, supports event tracking + session replay + feature flags.

**Fallback:** Mixpanel (if PostHog proves insufficient).

---

## §2. Event Taxonomy

### 2.1 User Lifecycle Events

| Event | Properties | Trigger |
|---|---|---|
| `user.signup_started` | auth_method, referral_code | Firebase Auth initiated |
| `user.signup_completed` | user_id, auth_method, referral_code | Account created |
| `user.email_verified` | user_id | Email link clicked |
| `user.onboarding_step` | user_id, step (O1-O5b), skipped | Each onboarding screen |
| `user.onboarding_completed` | user_id, duration_sec, steps_completed | Final onboarding step |
| `user.profile_completed` | user_id, has_photo, has_bio | Profile fields filled |
| `user.stripe_connected` | user_id, account_type | Stripe Connect setup |
| `user.trust_tier_changed` | user_id, old_tier, new_tier | Tier promotion/demotion |
| `user.session_start` | user_id, platform, app_version | App foreground |
| `user.session_end` | user_id, duration_sec, screens_visited | App background |
| `user.account_paused` | user_id, reason | Pause activated |
| `user.account_deleted` | user_id | GDPR deletion or voluntary |

### 2.2 Task Events

| Event | Properties | Trigger |
|---|---|---|
| `task.draft_started` | user_id, source (feed/direct) | Draft creation begins |
| `task.draft_abandoned` | user_id, last_step, duration_sec | Draft not submitted within 24h |
| `task.created` | task_id, poster_id, category, price, mode | Task posted |
| `task.viewed` | task_id, viewer_id, source (feed/search/deeplink) | Task detail opened |
| `task.accepted` | task_id, worker_id, time_to_accept_sec | Worker accepts |
| `task.en_route` | task_id, worker_id, eta_minutes | Worker starts travel |
| `task.arrived` | task_id, worker_id, actual_travel_min | Worker at location |
| `task.proof_submitted` | task_id, worker_id, photo_count | Proof uploaded |
| `task.proof_approved` | task_id, poster_id, time_to_approve_sec | Poster approves |
| `task.proof_rejected` | task_id, poster_id, rejection_count, reason | Poster rejects |
| `task.completed` | task_id, total_duration_min, price | Full cycle complete |
| `task.cancelled` | task_id, cancelled_by, reason, timing (early/late) | Any cancellation |
| `task.disputed` | task_id, initiated_by, reason | Dispute opened |
| `task.expired` | task_id, reason | Task deadline passed unfulfilled |

### 2.3 Payment Events

| Event | Properties | Trigger |
|---|---|---|
| `payment.escrow_created` | escrow_id, task_id, amount | Stripe PaymentIntent succeeds |
| `payment.escrow_released` | escrow_id, worker_id, amount, platform_fee | Proof approved |
| `payment.transfer_completed` | transfer_id, worker_id, net_amount | Stripe transfer succeeds |
| `payment.transfer_failed` | transfer_id, worker_id, error_code | Stripe transfer fails |
| `payment.card_declined` | user_id, error_code | Escrow creation fails |
| `payment.chargeback` | escrow_id, amount, dispute_reason | Stripe dispute created |
| `payment.refund` | escrow_id, amount, reason | Escrow refunded |

### 2.4 Engagement Events

| Event | Properties | Trigger |
|---|---|---|
| `feed.viewed` | user_id, filter_applied, result_count | Feed screen loaded |
| `feed.scrolled` | user_id, items_seen, duration_sec | Feed scroll depth |
| `search.executed` | user_id, query, result_count | Search performed |
| `message.sent` | sender_id, thread_id, has_attachment | Message sent |
| `notification.received` | user_id, type, channel | Push/in-app delivered |
| `notification.clicked` | user_id, type, screen_navigated | Notification tapped |
| `rating.submitted` | user_id, task_id, score, has_comment | Rating given |

---

## §3. Key Metrics & Dashboards

### 3.1 Growth Dashboard

| Metric | Definition | Target (Month 1) |
|---|---|---|
| DAU / MAU | Daily/Monthly active users | 100 DAU / 500 MAU |
| Signup → First Task Rate | % of signups who post or complete a task within 7 days | > 30% |
| D1 / D7 / D30 Retention | % of users returning after 1/7/30 days | 40% / 20% / 10% |
| Viral coefficient | Referral signups / total signups | > 0.1 |

### 3.2 Marketplace Dashboard

| Metric | Definition | Target |
|---|---|---|
| Task Fill Rate | % of posted tasks that get completed | > 60% |
| Time to Accept | Median seconds from task.created → task.accepted | < 30 min |
| Time to Complete | Median minutes from task.accepted → task.completed | < 4 hours |
| Cancellation Rate | % of accepted tasks that get cancelled | < 15% |
| Dispute Rate | % of completed tasks with disputes | < 5% |
| Supply/Demand Ratio | Active workers / active tasks per category per geo | 2:1 - 5:1 |

### 3.3 Revenue Dashboard

| Metric | Definition | Target |
|---|---|---|
| GMV | Gross Merchandise Value (total task payments) | Track |
| Net Revenue | GMV × 15% take rate | Track |
| ARPU | Average Revenue Per User (monthly) | Track |
| LTV | Lifetime Value (projected) | > 3× CAC |
| Chargeback Rate | Chargebacks / total transactions | < 0.5% |

### 3.4 Health Dashboard

| Metric | Definition | Alert Threshold |
|---|---|---|
| API Error Rate | 5xx responses / total requests | > 1% |
| Moderation Queue Depth | Items awaiting human review | > 50 |
| Dispute Resolution Time | Median hours to resolve | > 72h |
| Payment Failure Rate | Failed escrow / attempted escrow | > 5% |
| Trust Tier Distribution | % users per trust tier | Imbalanced if >80% at tier 1 |

---

## §4. Data Pipeline

### 4.1 Event Collection

```
Client SDK (PostHog iOS Swift) → PostHog Cloud/Self-hosted → PostgreSQL
Server-side events → PostHog API → PostgreSQL
```

- Client events: batched, sent every 30s or on app background
- Server events: sent immediately via PostHog Node SDK
- All events include: `user_id`, `timestamp`, `platform`, `app_version`, `session_id`

### 4.2 Data Retention

| Data Type | Retention | Reason |
|---|---|---|
| Raw events | 12 months | Analysis + debugging |
| Aggregated metrics | Indefinite | Trend analysis |
| Session recordings | 30 days | UX debugging |
| Personal identifiers | Per GDPR spec | Compliance |

### 4.3 Privacy Compliance

- All analytics respect user consent preferences (GDPR_COMPLIANCE_SPEC)
- PostHog configured with IP anonymization enabled
- No analytics in Incognito/guest mode
- Data export available for GDPR Subject Access Requests

---

## §5. Invariants

| ID | Rule | Enforcement |
|---|---|---|
| **ANA-1** | Every user action maps to exactly one event | Event taxonomy is exhaustive |
| **ANA-2** | No PII in event properties | Automated scrubbing, code review |
| **ANA-3** | Events are immutable after creation | append-only analytics_events table |
| **ANA-4** | Dashboard metrics refresh daily minimum | Nightly ETL job (BACKGROUND_JOBS_SPEC) |

---

## Amendment History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | Feb 2026 | HustleXP Core | Promoted from stub. Full event taxonomy (50+ events), pipeline architecture, 4 dashboards, data retention policy. Resolves GAP-9. |
