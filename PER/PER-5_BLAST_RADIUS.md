# PER-5: BLAST RADIUS CONTAINMENT

**STATUS: RECOMMENDED (SOFT GATE)**
**GATE TYPE: SOFT**
**PURPOSE: Minimize damage when things go wrong**

---

## THE RULE

> Every change must be isolated to minimize blast radius.
> If it breaks, you should know exactly what broke and fix it in minutes.
> "It broke everything" is a containment failure.

---

## CONTAINMENT RULES

### Rule 1: Feature Flags / Branch Isolation

**For New Features:**
1. Create feature branch (`feature/XXX-description`)
2. Implement behind feature flag
3. Flag is OFF by default in production
4. Gradual rollout via flag percentage
5. Full rollout only after stability verified

**Feature Flag Pattern:**
```typescript
if (featureFlags.isEnabled('new-escrow-flow', userId)) {
  return newEscrowFlow(data);
} else {
  return currentEscrowFlow(data);
}
```

**Rollout Stages:**
| Stage | Flag Value | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Development | ON (dev only) | Until ready | Tests pass |
| Alpha | 5% | 24-48 hours | No critical errors |
| Beta | 25% | 48-72 hours | Metrics stable |
| GA | 100% | Permanent | Stable for 1 week |

---

### Rule 2: No Cross-Domain Edits in One PR

**FORBIDDEN in Single PR:**
```
❌ Backend + Frontend changes together
❌ Schema + Service changes (except migrations)
❌ Multiple unrelated features
❌ Bug fix + refactor combined
❌ Database + API + UI in one PR
```

**REQUIRED:**
```
✅ One domain per PR (backend OR frontend)
✅ One concern per PR
✅ Related changes only
✅ Migration gets its own PR
```

**Cross-Domain Change Process:**
1. Backend PR first (create endpoint)
2. Wait for backend merge + deploy
3. Frontend PR second (consume endpoint)
4. Each PR is independently deployable/revertable

---

### Rule 3: One Concern Per Diff

**PR should answer ONE question:**
- "What does this PR do?" → Single sentence answer
- If answer requires "and", split the PR

**Examples:**
```
✅ GOOD: "Adds escrow release endpoint"
❌ BAD:  "Adds escrow release endpoint and refactors user service"

✅ GOOD: "Fixes XP calculation bug"
❌ BAD:  "Fixes XP calculation bug and updates schema"

✅ GOOD: "Updates dependency versions"
❌ BAD:  "Updates dependencies and adds new feature"
```

---

### Rule 4: Migration Isolation

**Database Migrations:**
- One migration per concern
- Reversible migrations preferred
- Test rollback BEFORE merge
- Deploy migration BEFORE dependent code

**Migration Sequence:**
```
1. PR: Migration (adds column with default)
2. Deploy migration
3. Verify migration successful
4. PR: Code that uses new column
5. Deploy code
6. PR: Migration (remove old column if needed)
```

**Rollback Test:**
```bash
# Before merging migration
npm run migrate:up
npm run migrate:down  # Must succeed
npm run migrate:up    # Must succeed again
```

---

### Rule 5: Dependency Changes Are Isolated

**Package Updates:**
- Separate PR for dependency updates
- Test thoroughly before merge
- Lock file must be updated
- No mixing with feature work

**Dependency PR Template:**
```markdown
## Dependency Update

**Package:** [package-name]
**Old Version:** [X.Y.Z]
**New Version:** [A.B.C]

**Reason:** [security fix / feature needed / etc.]

**Testing Done:**
- [ ] All tests pass
- [ ] Manual smoke test
- [ ] No console errors
- [ ] Build succeeds
```

---

## BLAST RADIUS ASSESSMENT

Before merging, answer:

### 1. If This Breaks, What Stops Working?

| Blast Radius | Examples | Acceptable? |
|--------------|----------|-------------|
| Single endpoint | One API call fails | ✅ Yes |
| Single feature | One user flow broken | ⚠️ Maybe |
| Multiple features | Several flows broken | ❌ Split PR |
| Entire system | Nothing works | ❌ Never merge |

### 2. Who Is Affected?

| Affected Group | Risk Level |
|----------------|------------|
| Developer only (staging) | Low |
| Alpha users (flagged) | Medium |
| All users | High |

### 3. Rollback Time

| Rollback Method | Time | Acceptable? |
|-----------------|------|-------------|
| Revert commit | < 5 min | ✅ Ideal |
| Feature flag OFF | < 1 min | ✅ Best |
| Database migration rollback | 15-30 min | ⚠️ Plan carefully |
| Data fix required | Hours | ❌ Need manual review |

---

## CONTAINMENT CHECKLIST

Before every PR:

```
[ ] Single domain (backend OR frontend, not both)
[ ] Single concern (one sentence description)
[ ] Feature flag for new features
[ ] Migration isolated from code
[ ] Dependencies isolated from features
[ ] Rollback plan documented
[ ] Rollback time < 5 minutes
[ ] No "while I'm here" changes
```

---

## ANTI-PATTERNS

```
❌ "While I'm here, I'll also refactor..."
❌ "This small frontend fix needs a backend change too..."
❌ "I'll batch these 5 bug fixes into one PR..."
❌ "The migration and the code need to go together..."
❌ [PR with 20+ files changed across domains]
❌ [PR description requires multiple sentences]
```

---

## REQUIRED PATTERNS

```
✅ "I'll create separate PRs for backend and frontend"
✅ "This migration gets its own PR, deployed first"
✅ "Feature flag allows gradual rollout"
✅ "Single-concern PR: [one sentence description]"
✅ "Rollback plan: revert commit [hash]"
```

---

## PR SIZE GUIDELINES

| Files Changed | Lines Changed | Risk Level |
|---------------|---------------|------------|
| 1-3 files | < 100 lines | Low |
| 4-10 files | 100-300 lines | Medium |
| 11-20 files | 300-500 lines | High (split if possible) |
| 20+ files | 500+ lines | Very High (must split) |

**Exception:** Automated refactors (rename across codebase) can be large if they're purely mechanical and reviewed carefully.

---

## INCIDENT RESPONSE

When something breaks in production:

### 1. Contain (< 5 minutes)
- Feature flag OFF
- OR revert commit
- OR rollback migration

### 2. Assess (5-15 minutes)
- What broke?
- Who is affected?
- What data was corrupted (if any)?

### 3. Fix Forward or Revert (15-60 minutes)
- If fix is obvious and quick → fix forward
- If fix is complex → stay reverted, fix in dev

### 4. Postmortem (24-48 hours)
- What happened?
- Why didn't tests catch it?
- What PER rule was missed?
- What automation can prevent recurrence?

---

## WHY CONTAINMENT MATTERS

**Without Containment:**
1. PR changes 50 files across 3 domains
2. Something breaks in production
3. Can't tell which change caused it
4. Can't revert without losing unrelated changes
5. Takes hours to debug
6. Users affected for extended period

**With Containment:**
1. PR changes 5 files in one domain
2. Something breaks in production
3. Revert one commit
4. System stable in 5 minutes
5. Debug in dev environment
6. Users affected for minutes

---

**Small changes. Fast rollback. Limited blast radius.**
**If you can't explain the blast radius, don't merge.**
