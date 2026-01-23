# CRASH PROTOCOL — HUSTLEXP v1.0

**STATUS: EMERGENCY RESPONSE PROCEDURE**
**PURPOSE: Structured response when the app crashes**

---

## CRASH SEVERITY LEVELS

| Level | Description | Response Time | Escalation |
|-------|-------------|---------------|------------|
| **P0** | Production down, all users affected | < 15 minutes | Immediate Ω consideration |
| **P1** | Critical feature broken, many users affected | < 1 hour | Senior review |
| **P2** | Feature degraded, some users affected | < 4 hours | Standard fix |
| **P3** | Minor issue, workaround exists | < 24 hours | Next sprint |

---

## FIRST RESPONSE CHECKLIST

When a crash occurs:

### Step 1: Assess (< 5 minutes)

```
[ ] What crashed? (app / service / database / build)
[ ] Who is affected? (all users / some users / dev only)
[ ] When did it start? (timestamp)
[ ] What changed recently? (last deploy / last commit)
[ ] Is it reproducible? (always / sometimes / once)
```

### Step 2: Contain (< 10 minutes)

```
[ ] Can we revert? (last known working commit)
[ ] Can we feature flag? (disable problematic feature)
[ ] Can we redirect? (maintenance page / fallback)
[ ] Is data at risk? (stop writes if needed)
```

### Step 3: Communicate (< 15 minutes)

```
[ ] Team notified (Slack / Discord / etc.)
[ ] Stakeholders informed (if user-facing)
[ ] Status page updated (if applicable)
[ ] Timeline estimated
```

---

## BUILD CRASH PROTOCOL

### Symptoms
- `npm run build` fails
- TypeScript errors
- Module not found
- Dependency resolution failure

### Quick Checks

```bash
# 1. Clean and reinstall
rm -rf node_modules
rm package-lock.json
npm install

# 2. Clear caches
npm cache clean --force
rm -rf .next / dist / build (as applicable)

# 3. Check Node version
node -v  # Should match .nvmrc or engines

# 4. Check for lockfile conflicts
git status  # Look for merge conflicts in package-lock.json
```

### If Quick Checks Fail

```bash
# Try last known working state
git stash  # Save current changes
git checkout [LAST_KNOWN_GOOD_TAG]
npm install
npm run build

# If this works: problem is in recent changes
# If this fails: problem is environmental → consider Ω
```

---

## RUNTIME CRASH PROTOCOL

### Symptoms
- App crashes on startup
- White screen / blank page
- Uncaught exception
- Process exit

### Quick Checks

```bash
# 1. Check logs
tail -f logs/app.log  # or appropriate log location

# 2. Check environment
env | grep -E "(NODE_ENV|DATABASE|API)"  # Verify env vars

# 3. Check database connection
psql $DATABASE_URL -c "SELECT 1"  # Can we connect?

# 4. Check external services
curl $API_ENDPOINT/health  # Are dependencies up?
```

### If Quick Checks Pass But App Still Crashes

```
1. Enable verbose logging
2. Run in debug mode
3. Check for stack trace
4. Identify failing component
5. Isolate with feature flags

If no clear cause after 30 minutes → Consider Ω
```

---

## DATABASE CRASH PROTOCOL

### Symptoms
- Connection refused
- Query timeout
- Transaction deadlock
- Data corruption

### Quick Checks

```sql
-- Check connections
SELECT count(*) FROM pg_stat_activity;

-- Check locks
SELECT * FROM pg_locks WHERE NOT granted;

-- Check active queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active';
```

### Recovery Steps

```
1. If connection pool exhausted:
   - Restart connection pool
   - Increase pool size (temporary)
   - Find connection leak

2. If deadlock:
   - Identify blocking transaction
   - Cancel if safe: SELECT pg_cancel_backend(pid);
   - Review transaction isolation

3. If data corruption:
   - STOP ALL WRITES
   - Assess extent of corruption
   - Restore from backup if necessary
   - THIS IS Ω TERRITORY
```

---

## DEPLOYMENT CRASH PROTOCOL

### Symptoms
- Deploy fails
- Health check fails after deploy
- Rolling back automatically
- Container crash loop

### Quick Checks

```bash
# 1. Check deploy logs
fly logs  # or equivalent

# 2. Check health endpoint
curl https://app.hustlexp.com/health

# 3. Check resource usage
fly status  # or equivalent

# 4. Check recent changes
git log --oneline -10
```

### Recovery Steps

```
1. If health check fails:
   - Rollback to previous version immediately
   - Investigate in staging

2. If crash loop:
   - Check startup logs
   - Verify environment variables
   - Check secrets/credentials

3. If resource exhaustion:
   - Scale up temporarily
   - Identify resource leak
```

---

## WHEN TO TRIGGER Ω

Escalate to OMEGA PROTOCOL when:

```
[ ] Build fails after clean reinstall + checkout of known-good
[ ] Crash persists after all quick checks
[ ] Root cause unclear after 60 minutes
[ ] Multiple systems failing simultaneously
[ ] AI suggestions aren't helping
```

**See:** `PER/OMEGA_PROTOCOL.md`

---

## CRASH DOCUMENTATION

Every crash should be documented:

```markdown
## Crash Report: [Date] [Time]

### Summary
[One sentence description]

### Severity
P[0-3]

### Timeline
- [Time]: First report
- [Time]: Investigation started
- [Time]: Root cause identified
- [Time]: Fix deployed
- [Time]: Confirmed resolved

### Root Cause
[What actually broke]

### Resolution
[How it was fixed]

### Prevention
[What guard/test/check prevents recurrence]
```

---

## EMERGENCY CONTACTS

| Role | Contact | When to Reach |
|------|---------|---------------|
| On-call engineer | [contact] | P0/P1 |
| Tech lead | [contact] | P0 or Ω trigger |
| Database admin | [contact] | Database issues |
| DevOps | [contact] | Infrastructure issues |

---

## RUNBOOK QUICK REFERENCE

| Problem | First Action | Escalation |
|---------|--------------|------------|
| Build fails | Clean reinstall | Checkout known-good |
| App crashes | Check logs | Enable debug mode |
| DB connection | Check pool | Restart pool |
| API timeout | Check external services | Feature flag |
| Deploy fails | Rollback | Check staging |
| Unknown | Follow protocol | Trigger Ω at 60 min |

---

**Crashes happen. Panic doesn't help.**
**Follow the protocol. Contain first. Fix second.**
**When in doubt, Ω is always available.**
