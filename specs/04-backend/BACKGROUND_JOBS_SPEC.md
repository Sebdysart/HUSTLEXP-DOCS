# BACKGROUND JOBS SPECIFICATION

**Authority:** ARCHITECTURE.md | BACKEND_STACK_LOCK.md
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| DB-layer jobs | `pg_cron` (Neon extension) | Periodic DB maintenance, expiry checks |
| Application-layer jobs | BullMQ + Redis | Complex jobs requiring application logic |
| Scheduling | BullMQ repeatable jobs | Cron-like scheduling with retries |
| Monitoring | BullMQ dashboard (Bull Board) | Job status, failure inspection |

**Rationale:** pg_cron handles simple SQL-based periodic tasks without application deployment. BullMQ handles jobs requiring Node.js logic, API calls, or multi-step workflows.

---

## §2. Job Registry

| Job ID | Layer | Schedule | Description | Failure Impact |
|---|---|---|---|---|
| `credential-expiry-check` | pg_cron | Daily 02:00 UTC | Flag workers with expired credentials | Expired workers access restricted tasks |
| `xp-decay` | pg_cron | Daily 03:00 UTC | Apply XP decay per PRODUCT_SPEC §8 | Inflated trust tiers |
| `stale-acceptance-check` | BullMQ | Every 15 min | Cancel ACCEPTED tasks past deadline (§21.4) | Tasks rot in ACCEPTED state |
| `transfer-retry` | BullMQ | Every 30 min | Retry failed Stripe transfers (§8.2) | Workers don't get paid |
| `notification-cleanup` | pg_cron | Daily 04:00 UTC | Archive notifications older than 90 days | DB bloat |
| `task-expiry` | BullMQ | Every 15 min | Cancel OPEN tasks past deadline | Stale tasks in feed |
| `analytics-rollup` | pg_cron | Daily 05:00 UTC | Aggregate daily metrics | Dashboard gaps |
| `evidence-retention` | pg_cron | Weekly Sun 03:00 UTC | Archive evidence older than retention period | Storage costs |
| `moderation-sla-check` | BullMQ | Every 1 hour | Escalate unreviewed moderation items past SLA | Content stays unreviewed |
| `dispute-sla-check` | BullMQ | Every 1 hour | Escalate disputes past SLA (§22.1) | Escrow frozen indefinitely |
| `reconciliation` | BullMQ | Daily 06:00 UTC | Compare DB escrows vs Stripe transfers (§14.4) | Earnings mismatch |
| `no-show-detection` | BullMQ | Every 15 min | Detect EN_ROUTE workers past deadline | No-shows unpenalized |
| `chargeback-monitor` | BullMQ | Every 1 hour | Check Stripe for new disputes | Chargebacks unhandled |
| `safety-pool-premium` | pg_cron | Daily 07:00 UTC | Calculate dynamic safety pool rates | Stale risk pricing |

---

## §3. Failure Handling

**Retry policy (BullMQ):**
- Default: 3 retries with exponential backoff (1min, 5min, 15min)
- Transfer-retry: 5 retries with backoff (5min, 15min, 1hr, 4hr, 12hr)
- After max retries: job moves to dead letter queue (DLQ)

**Dead Letter Queue:**
- All failed-past-retry jobs stored in `background_job_failures` table
- Alert sent to operations Slack channel on DLQ entry
- Manual retry available via admin dashboard
- DLQ entries auto-archived after 30 days

**pg_cron failures:**
- Logged to `pg_cron.job_run_details`
- If job fails 3 consecutive runs: alert operations team
- pg_cron does not have built-in retry — wrap SQL in exception handler

---

## §4. Idempotency

All BullMQ jobs MUST be idempotent. Running a job twice with the same input produces the same result.

**Patterns:**
- Use `INSERT ... ON CONFLICT DO NOTHING` for creation jobs
- Use `WHERE state = 'expected_state'` guards on state transitions
- Use `job_id` as idempotency key in `background_job_log` table
- Transfer jobs use Stripe idempotency keys (STRIPE_INTEGRATION §8.3)

---

## §5. Monitoring

| Metric | Alert Threshold | Channel |
|---|---|---|
| Job queue depth | > 100 pending | Slack |
| Job failure rate | > 10% in 1 hour | Slack + PagerDuty |
| DLQ size | > 0 entries | Slack |
| Job latency (p95) | > 5 minutes | Dashboard |
| Missed scheduled run | Any | Slack |

**Dashboard:** Bull Board mounted at `/admin/jobs` (admin-only access).

---

## §6. Schema

```sql
-- See schema.sql: background_job_log table
-- Additional: background_job_failures for DLQ
CREATE TABLE IF NOT EXISTS background_job_failures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id TEXT NOT NULL,
    job_type TEXT NOT NULL,
    payload JSONB,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    failed_at TIMESTAMPTZ DEFAULT now(),
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id)
);
CREATE INDEX idx_bjf_type ON background_job_failures(job_type);
CREATE INDEX idx_bjf_unresolved ON background_job_failures(resolved_at) WHERE resolved_at IS NULL;
```

---

**END OF BACKGROUND_JOBS_SPEC v1.0.0**
