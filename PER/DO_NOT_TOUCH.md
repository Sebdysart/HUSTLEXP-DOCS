# DO NOT TOUCH — HUSTLEXP v1.0

**STATUS: ABSOLUTE PROHIBITION**
**PURPOSE: Explicit list of files, concepts, and patterns that are FORBIDDEN to modify**
**ENFORCEMENT: Violation = system failure**

---

## THE RULE

> If it's in this document, you cannot modify it without explicit user approval.
> If you need to modify a DO_NOT_TOUCH item, STOP and ask.
> There are no exceptions. There are no "quick fixes."

---

## FORBIDDEN FILES (Constitutional Documents)

These files define the system's authority model. Modification requires:
1. Explicit user approval
2. Update to PER_MASTER_INDEX.md changelog
3. Audit entry explaining why

### Tier 1: Never Modify (Database Authority)

| File | Owner | Reason |
|------|-------|--------|
| `specs/02-architecture/schema.sql` | Backend | Database is single source of truth |
| Trigger functions in schema.sql | Backend | Enforce invariants INV-1 through INV-5 |

**If you modify schema.sql triggers, you break the money chain.**

### Tier 2: Constitutional Documents (Require Approval)

| File | Owner | Reason |
|------|-------|--------|
| `specs/02-architecture/ARCHITECTURE.md` | Core | 7-layer authority model |
| `FINISHED_STATE.md` | Core | Product boundary definition |
| `FEATURE_FREEZE.md` | Core | Scope lock |
| `PER/PER_MASTER_INDEX.md` | Core | PER system root |
| `PER/INVARIANTS.md` | Core | All invariants consolidated |

### Tier 3: Locked Specifications

| File | Owner | Reason |
|------|-------|--------|
| `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` | Backend | Eligibility authority |
| `VERIFICATION_PIPELINE_LOCKED.md` | Backend | Trust verification pipeline |
| `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` | Backend | Feed eligibility logic |
| `VERIFICATION_PAYMENT_UX_AND_COPY_LOCKED.md` | Frontend | Payment UX authority |
| `specs/03-frontend/stitch-prompts/*-LOCKED.md` | Frontend | All locked stitch prompts (01-14) |

### Tier 4: Enforcement Policies

| File | Owner | Reason |
|------|-------|--------|
| `.claude/instructions.md` | Backend | Backend enforcement policy |
| `.cursorrules` | Frontend | Frontend enforcement policy |
| `AI_GUARDRAILS.md` | Core | AI constraint rules |

---

## FORBIDDEN TABLES (Append-Only Ledgers)

These tables are append-only. DELETE and UPDATE are blocked by triggers.

| Table | Trigger | Error Code | Purpose |
|-------|---------|------------|---------|
| `xp_ledger` | `xp_ledger_no_delete` | HX102 | XP history is permanent |
| `trust_ledger` | `trust_ledger_no_delete` | HX_TRUST | Trust history is auditable |
| `admin_actions` | `admin_actions_no_delete` | HX_ADMIN | Admin audit trail |
| `ai_decisions` | `ai_decisions_no_delete` | HX_AI | AI decision audit trail |
| `badges` | `badge_no_delete` | HX501 | Achievements are permanent |

**Rule:** If you need to "correct" an entry in these tables, you INSERT a correction entry — you do not DELETE or UPDATE.

---

## FORBIDDEN CONCEPTS (Backend)

### Backend May NEVER:

1. **Trust frontend-computed values**
   - XP amount
   - Trust tier
   - Eligibility status
   - Price calculations
   - Time calculations

2. **Bypass database constraints**
   - Direct UPDATE bypassing triggers
   - Disabling constraints "temporarily"
   - Using raw SQL to avoid ORM validation

3. **Let AI write to ledgers**
   - AI has no write access to xp_ledger, trust_ledger, badges
   - AI proposes, deterministic systems decide, database enforces

4. **Modify escrow amounts after creation**
   - INV-4 is absolute
   - No "adjustment" entries
   - No "correction" to amount field

5. **Skip the proof → release → XP chain**
   - INV-1, INV-2, INV-3 are absolute
   - No shortcuts, no "fast path"
   - Every step is enforced by database

6. **Award XP without released escrow**
   - HX101 will reject this
   - No "test" awards, no "manual" awards
   - Escrow must be RELEASED first

---

## FORBIDDEN CONCEPTS (Frontend)

### Frontend May NEVER:

1. **Compute eligibility, XP, trust, or pricing**
   - These are server-computed
   - Frontend displays only
   - If you write `if (user.trustTier >= ...)`, you're wrong

2. **Make API calls from screen components**
   - Screens receive props
   - Screens do not fetch
   - Data fetching is in hooks/services

3. **Cache authoritative state for decisions**
   - Cache for display: OK
   - Cache for decisions: FORBIDDEN
   - If cache affects behavior, it's wrong

4. **Invent data fields not in props interface**
   - Props are defined in screen specs
   - If it's not in the spec, it doesn't exist
   - No "helper" fields, no "derived" fields in component

5. **Create screens not in SCREEN_REGISTRY.md**
   - 38 screens are defined
   - No new screens without approval
   - Check SCREEN_REGISTRY.md first

6. **Modify navigation structure**
   - Navigation is defined in specs
   - No new routes without approval
   - No "convenience" links

---

## FORBIDDEN CONCEPTS (AI Systems)

### AI May NEVER:

1. **Insert rows into xp_ledger**
   - AI has no write access
   - AI proposes, backend decides
   - HX101 will reject if somehow attempted

2. **Update escrows.state**
   - AI cannot release money
   - AI cannot refund money
   - This is A0 authority (forbidden)

3. **Update users.trust_tier**
   - Trust tier changes require audit
   - AI can propose, TrustService decides
   - This is A0 authority

4. **Insert rows into badges**
   - Badges are earned, not granted
   - AI cannot grant achievements
   - This is A0 authority

5. **Execute Stripe API calls**
   - AI has no payment credentials
   - Money operations are backend-only
   - This path does not exist in code

6. **Approve payments without human checkpoint**
   - A3 authority has limits
   - Money operations always have human checkpoint
   - No "auto-approve" for payments

7. **Operate without audit logging**
   - Every AI decision creates ai_decisions entry
   - If it's not logged, it didn't happen
   - Audit is mandatory

---

## FORBIDDEN CODE PATTERNS

### These patterns are ALWAYS wrong. If you write them, stop and reconsider.

#### Pattern 1: Bypass database for money

```typescript
// ❌ FORBIDDEN
if (shouldReleaseEscrow) {
  user.balance += escrow.amount; // WRONG: bypasses Layer 0
}

// ✅ CORRECT
await db.escrows.update({
  where: { id: escrowId },
  data: { state: 'RELEASED' }
}); // Trigger enforces INV-2
```

#### Pattern 2: Let AI decide

```typescript
// ❌ FORBIDDEN
const aiDecision = await ai.shouldApproveProof(proof);
if (aiDecision) approveProof(proof); // WRONG: AI decides

// ✅ CORRECT
const proposal = await ai.proposeProofDecision(proof);
const decision = deterministicRules.evaluate(proposal);
await applyDecision(decision); // System decides, not AI
```

#### Pattern 3: Trust frontend values

```typescript
// ❌ FORBIDDEN
const xpAmount = req.body.calculatedXP; // WRONG: frontend computed
await awardXP(xpAmount);

// ✅ CORRECT
const xpAmount = calculateXP(task, proof); // Server-side only
await awardXP({ escrowId, amount: xpAmount });
```

#### Pattern 4: Modify escrow amount

```typescript
// ❌ FORBIDDEN
await db.escrows.update({ amount: newAmount }); // WRONG: INV-4 violation

// ✅ CORRECT
// Escrow amount is set at creation and NEVER modified
// If wrong amount, cancel and create new escrow
```

#### Pattern 5: Skip the chain

```typescript
// ❌ FORBIDDEN
await db.xp_ledger.insert({ ... }); // Without checking escrow.state === 'RELEASED'

// ✅ CORRECT
// Database trigger will reject this automatically
// But don't even try — check state first
if (escrow.state !== 'RELEASED') {
  throw new Error('Cannot award XP: escrow not released');
}
```

#### Pattern 6: Client-side eligibility

```javascript
// ❌ FORBIDDEN
const isEligible = user.trustTier >= task.requiredTier;
if (isEligible) showApplyButton();

// ✅ CORRECT
// Feed only contains eligible tasks (server-filtered)
// If task is in feed, user is eligible
const feed = await api.feed.get.query({ userId });
```

#### Pattern 7: Fetch in screen components

```javascript
// ❌ FORBIDDEN
const TaskScreen = () => {
  const data = await fetch('/api/task'); // WRONG: fetch in screen
  return <View>...</View>;
};

// ✅ CORRECT
const TaskScreen = ({ task }) => { // Props from hook/container
  return <View>...</View>;
};
```

#### Pattern 8: Direct capability profile mutation

```typescript
// ❌ FORBIDDEN
await db.query(`
  UPDATE capability_profiles
  SET verified_trades = ARRAY['electrician']
  WHERE user_id = $1
`);

// ✅ CORRECT
// Update source record, trigger recompute
await db.query(`
  UPDATE license_verifications
  SET status = 'verified'
  WHERE id = $1
`);
await capabilityProfileService.recompute(userId);
```

---

## FORBIDDEN DEFERRED FEATURES (v2+)

These features are explicitly deferred. Do not implement them:

| Feature | Deferred To | Reason |
|---------|-------------|--------|
| Voice messages | v2 | Scope limit |
| Video proof | v2 | Scope limit |
| Team tasks | v2 | Complexity |
| Tipping | Never (v1) | Economic complexity |
| AI autonomous actions | Never | Authority model |
| Bidding system | Never (v1) | UX complexity |
| Analytics dashboard | v2 | Scope limit |
| Smart pricing | v2 | AI complexity |
| Gamified streaks | v2 | Scope limit |
| Recurring tasks | v2 | Scope limit |
| Referral system | v2 | Scope limit |
| Loyalty program | v2 | Scope limit |

**If asked to implement a deferred feature, STOP and point to FEATURE_FREEZE.md.**

---

## MODIFICATION PROTOCOL

If you MUST modify a DO_NOT_TOUCH item:

### Step 1: STOP
Do not make the change. Do not "try it out." Do not "see what happens."

### Step 2: STATE
State exactly:
- Which DO_NOT_TOUCH item you need to modify
- WHY it must be modified (not "it would be better")
- What happens if you DON'T modify it

### Step 3: WAIT
Wait for explicit user approval. "Proceed" or "approved" — not silence.

### Step 4: AUDIT
After approval:
- Update PER_MASTER_INDEX.md changelog (if constitutional)
- Create audit entry explaining the change
- Update any cross-references

### Step 5: TEST
Verify all invariants still hold after the change.

---

## ANTI-PATTERNS (How Violations Happen)

### "Quick Fix" Violation
> "I'll just update this directly to fix the bug..."

**Problem:** Bypasses constraints that exist for a reason.
**Solution:** Find the proper path. The constraint is protecting you.

### "Temporary" Violation
> "This is temporary, we'll fix it properly later..."

**Problem:** Temporary becomes permanent. Technical debt compounds.
**Solution:** Do it properly now or don't do it.

### "Test Mode" Violation
> "This is just for testing, it won't go to production..."

**Problem:** Test code becomes production code.
**Solution:** Tests must respect the same constraints as production.

### "Edge Case" Violation
> "This is an edge case, the normal rules don't apply..."

**Problem:** Edge cases are where bugs hide.
**Solution:** The rules especially apply to edge cases.

### "I Know What I'm Doing" Violation
> "I understand the risk, it's fine..."

**Problem:** Confidence is not correctness.
**Solution:** If you need to say this, you probably shouldn't do it.

---

## VERIFICATION

Before any PR that touches anything near these forbidden items:

```
[ ] I have not modified any Tier 1 files (schema.sql triggers)
[ ] I have not modified any Tier 2 files without approval
[ ] I have not modified any Tier 3 locked specs
[ ] I have not written any forbidden code patterns
[ ] I have not implemented any deferred features
[ ] I have not bypassed any layer in the hierarchy
[ ] All invariants still pass after my change
```

If ANY checkbox is unchecked, the PR is blocked.

---

**This document exists because developers make mistakes.**
**The mistakes it prevents are the ones that kill projects.**
**Respect the boundaries. They're protecting you.**
