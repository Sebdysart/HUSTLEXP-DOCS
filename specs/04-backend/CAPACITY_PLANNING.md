# CAPACITY PLANNING

**Authority:** BACKEND_STACK_LOCK.md | ARCHITECTURE.md
**Status:** v1.0 — Living document (updated pre-launch and at each growth milestone)

---

## §1. Launch Targets (v1.0)

| Metric | Target | Rationale |
|---|---|---|
| Concurrent users | 1,000 | Initial market (single metro) |
| Tasks created/day | 200 | ~20% of users post daily |
| Tasks completed/day | 150 | ~75% completion rate |
| Peak API requests/min | 2,000 | ~2 req/min per active user |
| WebSocket connections (Live Mode) | 200 concurrent | ~20% of users in Live Mode |
| Database connections | 50 pooled | Neon serverless pooling |

---

## §2. Infrastructure Sizing

### 2.1 Fly.io Compute
| Component | Size | Count | Auto-Scale |
|---|---|---|---|
| API server | shared-cpu-2x (512MB) | 2 min, 5 max | CPU > 70% for 2 min |
| WebSocket server | shared-cpu-2x (1GB) | 1 min, 3 max | Connections > 150 |
| Background worker | shared-cpu-1x (256MB) | 1 | N/A (always 1) |

### 2.2 Neon Database
| Plan | Connections | Storage | Compute |
|---|---|---|---|
| Pro ($19/mo) | 100 pooled (PgBouncer) | 50GB | 0.25-2 CU auto-scale |

**Connection limits:** Application uses connection pooling. Each Fly.io machine gets 10 connections from pool.

### 2.3 Redis (Upstash)
| Use | Memory | Commands/Day |
|---|---|---|
| Rate limiting | ~10MB | ~100K |
| BullMQ job queue | ~50MB | ~50K |
| Session/cache | ~20MB | ~30K |

---

## §3. Scaling Triggers

| Metric | Threshold | Action |
|---|---|---|
| API p95 latency | > 500ms | Add Fly.io machine |
| DB connection utilization | > 80% | Upgrade Neon plan |
| WebSocket connections | > 80% of limit | Add WebSocket machine |
| Redis memory | > 80% | Upgrade Upstash plan |
| Google Maps monthly cost | > $500 | Review caching strategy |
| Background job queue depth | > 500 | Add worker machine |

---

## §4. Cost Projections

| Users | Fly.io | Neon | Redis | Maps | Total/mo |
|---|---|---|---|---|---|
| 1K | $30 | $19 | $10 | $200 | $259 |
| 5K | $80 | $69 | $30 | $600 | $779 |
| 10K | $150 | $69 | $50 | $1,500 | $1,769 |
| 50K | $500 | $199 | $100 | $5,000 | $5,799 |

---

## §5. Load Testing Plan

**Pre-launch:** Run load tests against staging environment.

| Test | Tool | Target |
|---|---|---|
| API throughput | k6 or Artillery | 2,000 req/min sustained for 10 min |
| WebSocket load | k6 WebSocket | 200 concurrent connections |
| Database stress | pgbench | 100 concurrent queries |
| Payment flow | Stripe test mode | 50 concurrent payment intents |

**Pass criteria:** p95 latency < 500ms, zero 5xx errors, no connection pool exhaustion.

---

**END OF CAPACITY_PLANNING v1.0.0**
