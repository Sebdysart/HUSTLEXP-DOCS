# DEPLOYMENT SPECIFICATION

**Authority:** BACKEND_STACK_LOCK.md | ARCHITECTURE.md
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. Environments

| Environment | Purpose | URL Pattern | Auto-Deploy |
|---|---|---|---|
| Local | Developer machine | `localhost:3000` / `localhost:8080` | N/A |
| Staging | Pre-production testing | `staging.hustlexp.com` | On merge to `staging` branch |
| Production | Live users | `api.hustlexp.com` | Manual promote from staging |

**Environment isolation:**
- Separate Neon projects per environment
- Separate Stripe accounts (test mode for staging, live for production)
- Separate Firebase projects
- Separate Railway projects

---

## §2. CI Pipeline (GitHub Actions)

**Triggered on:** Every push to any branch, every PR.

| Step | Tool | Failure = |
|---|---|---|
| Lint (frontend) | ESLint + custom rules (ESLINT_CUSTOM_RULES.md) | Block merge |
| Lint (backend) | ESLint | Block merge |
| Type check | TypeScript `tsc --noEmit` | Block merge |
| Unit tests | Jest / Vitest | Block merge |
| Integration tests | Supertest + test DB | Block merge |
| Build (frontend) | Xcode build (SwiftUI) | Block merge |
| Build (backend) | Docker build | Block merge |
| Schema validation | `pg_prove` or SQL syntax check | Block merge |

**Branch protection (main):**
- Require passing CI
- Require 1 approval (when team > 1)
- No force push

---

## §3. CD Pipeline

### 3.1 Staging Deployment
- Trigger: merge to `staging` branch
- Backend: Railway auto-deploy from `staging` branch
- Frontend: Xcode archive + TestFlight distribution
- Database: Run pending migrations against staging DB

### 3.2 Production Deployment
- Trigger: manual (Railway promote from staging OR GitHub Actions workflow dispatch)
- Pre-deploy checklist:
  1. Staging tested and stable for ≥24 hours
  2. No open P0 bugs
  3. Database migration tested on staging
  4. Rollback plan documented in deploy PR
- Backend: Railway promote from staging (rolling deploy)
- Frontend: Xcode archive + App Store submission
- Database: Run pending migrations against production DB

---

## §4. Database Migration Strategy

**Tool:** Raw SQL migration files (versioned).

**Directory:** `migrations/` in backend repo.

**File naming:** `NNNN_description.sql` (e.g., `0001_initial_schema.sql`, `0002_add_user_blocks.sql`)

**Execution:**
- Migrations run in order by filename
- Each migration wrapped in a transaction
- `schema_migrations` table tracks which migrations have been applied
- Never modify an applied migration — create a new one
- Destructive migrations (DROP, ALTER column type) require explicit approval

**Rollback:**
- Each migration file has a `-- DOWN` section with reverse SQL
- Rollback command: apply DOWN sections in reverse order
- Test rollback in staging before production deploy

---

## §5. Rollback Procedures

| Component | Rollback Method | Time |
|---|---|---|
| Backend API | Railway rollback to previous deploy | < 1 min |
| Frontend (binary) | App Store rollback not possible; push hotfix | Hours |
| Database | Run DOWN migrations | Varies |

**Rollback decision criteria:**
- Error rate > 5× baseline → immediate rollback
- P0 bug discovered → rollback within 15 minutes
- Performance degradation > 2× → rollback within 30 minutes

---

## §6. Feature Flags

**Tool:** Environment variables + database `feature_flags` table.

**Pattern:**
```typescript
const isEnabled = await featureFlags.check('new_matching_algorithm', userId);
```

**Flag types:**
- Global: on/off for all users
- Percentage: gradual rollout (10% → 50% → 100%)
- User-specific: enable for specific test accounts

**Required for:** Any user-facing behavior change in production.

---

**END OF DEPLOYMENT_SPEC v1.0.0**
