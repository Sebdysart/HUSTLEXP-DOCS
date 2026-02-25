# OPERATIONS RUNBOOK

**Authority:** DEPLOYMENT_SPEC | BACKEND_STACK_LOCK.md
**Status:** v1.0 — Living document (updated after each incident)

---

## §1. Incident Severity Levels

| Level | Definition | Response Time | Example |
|---|---|---|---|
| SEV1 | Platform down, all users affected | 15 minutes | API unreachable, DB down |
| SEV2 | Major feature broken, many users affected | 1 hour | Payments failing, auth broken |
| SEV3 | Minor feature broken, some users affected | 4 hours | Notifications delayed, map errors |
| SEV4 | Cosmetic or low-impact issue | Next business day | UI glitch, non-critical log errors |

---

## §2. On-Call Rotation

**v1 (solo founder):** Founder is on-call 24/7. Set up:
- PagerDuty or Opsgenie for alerting
- Railway status alerts → PagerDuty
- Neon status alerts → PagerDuty
- Stripe webhook failure alerts → PagerDuty
- Sentry error spike alerts → PagerDuty

**Escalation:** If founder unresponsive for 30 minutes on SEV1 → auto-page again.

---

## §3. Backup & Recovery

### 3.1 Database (Neon)
- Point-in-time recovery: up to 7 days (Pro plan)
- Recovery command: Neon Console → Branches → Create branch from point in time
- RTO (Recovery Time Objective): < 15 minutes
- RPO (Recovery Point Objective): < 1 minute (WAL-based)

### 3.2 File Storage (Cloudflare R2)
- Proof photos and uploads: R2 with versioning
- Backup: R2 cross-region replication (if budget allows)
- Recovery: restore from R2 version history

### 3.3 Redis (Upstash)
- Ephemeral by design — rate limits and job queues rebuild automatically
- No backup needed (data reconstructed from DB state)

---

## §4. Failover Procedures

| Service | Failure | Failover |
|---|---|---|
| Railway API instance | Instance crash | Auto-restart (Railway health checks). If region down → failover to backup region |
| Neon database | Primary down | Neon auto-failover to read replica. Manual promote if needed |
| Stripe | Outage | Queue payment actions, retry when Stripe recovers. Show user "Payment processing delayed" |
| Firebase Auth | Outage | Users can't log in. No failover possible. Display maintenance screen |
| Google Maps Platform | Server-side API outage (Geocoding, Directions, Distance Matrix) | Fallback to cached geocode results. Disable real-time ETA/routing. Static task locations still work |
| Apple MapKit (iOS) | Client-side map rendering outage | Fallback to cached map tiles. Show list view instead of map. Core task functionality unaffected |

---

## §5. Common Runbook Procedures

### 5.1 Escrow Stuck in Wrong State
```sql
-- Audit first
SELECT * FROM escrows WHERE task_id = 'XXX';
-- Fix with logging
UPDATE escrows SET state = 'CORRECT_STATE', updated_at = now()
WHERE id = 'YYY' AND state = 'WRONG_STATE';
-- Log the manual intervention
INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, details)
VALUES ('founder_id', 'manual_escrow_fix', 'escrow', 'YYY', 'Reason: ...');
```

### 5.2 Worker Can't Get Paid (Transfer Failed)
1. Check `stripe_transfers` table for error
2. Check Stripe Dashboard for transfer status
3. If Stripe account issue: contact worker to update banking info
4. If platform issue: manually retry transfer via Stripe API

### 5.3 Database Connection Pool Exhaustion
1. Check Neon dashboard for connection count
2. Identify long-running queries: `SELECT * FROM pg_stat_activity WHERE state = 'active';`
3. Kill stuck queries: `SELECT pg_terminate_backend(pid);`
4. If persistent: restart Railway instances to reset connection pool

---

## §6. Status Page

- Tool: Atlassian Statuspage or instatus.com
- URL: `status.hustlexp.com`
- Components monitored: API, Payments, Messaging, Maps, Authentication
- Auto-update from Railway and Stripe health checks

---

## §7. Post-Incident Review

After every SEV1 or SEV2 incident:
1. **Timeline:** What happened, when, in what order
2. **Root cause:** Why did it happen
3. **Impact:** How many users affected, for how long
4. **Fix:** What was done to resolve it
5. **Prevention:** What changes prevent recurrence
6. **Action items:** Specific tasks with owners and deadlines

Document in `tracking/incidents/YYYY-MM-DD_description.md`

---

**END OF OPS_RUNBOOK v1.0.0**
