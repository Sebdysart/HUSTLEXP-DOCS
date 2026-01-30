# PER-3: INVARIANT SIMULATION

**STATUS: MANDATORY PRE-MERGE GATE**
**GATE TYPE: HARD**
**PURPOSE: Mental execution before code execution**

---

## THE RULE

> Before merge, enumerate all invariants and simulate how the new code behaves under stress.
> If you cannot explain what happens when things go wrong, you cannot merge.
> Tests catch bugs. Simulation prevents them.

---

## WHEN SIMULATION IS REQUIRED

| Change Type | Simulation Required? |
|-------------|---------------------|
| Read-only query | No (unless touches eligibility) |
| State mutation | YES — Full simulation |
| Money/escrow operation | YES — Full simulation + manual review |
| Invariant-touching code | YES — Full simulation + kill test update |
| New endpoint | YES — Simulations 1-6 minimum |
| Bug fix | YES — Simulate original bug + touched paths |
| Refactor | YES — All touched invariants |

---

## SIMULATION CHECKLIST

For every change that mutates state:

### Simulation 1: Requests Duplicated

**Scenario:** Same request sent twice simultaneously (race condition, retry, network hiccup)

```markdown
## Simulation 1: Duplicate Requests

**Setup:** User clicks button twice rapidly, or network retries request

**Current Behavior:** [Describe what happens now]

**After This Change:** [Describe what will happen]

**Invariants Affected:** [List invariant IDs]

**Preserved?** [Yes/No]

**If No, mitigation:** [How to fix]
```

**Example Questions:**
- What if `awardXP()` is called twice with same escrowId?
- What if `releaseEscrow()` is called twice simultaneously?
- What if same task is accepted by two hustlers at once?

---

### Simulation 2: Requests Out of Order

**Scenario:** Requests arrive in unexpected sequence (network reordering, async processing)

```markdown
## Simulation 2: Out-of-Order Requests

**Setup:** Request B arrives before Request A, even though A was sent first

**Example Sequence:**
1. User sends "complete task"
2. User sends "submit proof"
3. Server receives "submit proof" first
4. Server receives "complete task" second

**Current Behavior:** [Describe]

**After This Change:** [Describe]

**Invariants Affected:** [List]

**Preserved?** [Yes/No]
```

**Example Questions:**
- What if proof is submitted after task is already completed?
- What if escrow release arrives before proof acceptance?
- What if XP award request arrives before escrow release completes?

---

### Simulation 3: Requests Fail Halfway

**Scenario:** Operation fails mid-transaction (DB timeout, external API error, process crash)

```markdown
## Simulation 3: Partial Failure

**Setup:** Operation starts, then fails at step N

**Failure Point:** [Which step fails]

**State Before:** [Describe state before operation]

**State If Fails At Step N:** [Describe state after partial failure]

**Expected Behavior:** [Complete rollback / partial state / error state]

**Actual Behavior After Change:** [Describe]

**Transaction Rollback Safe?** [Yes/No]

**If No, mitigation:** [How to ensure atomicity]
```

**Example Questions:**
- What if DB connection drops after proof is marked accepted but before escrow is released?
- What if Stripe API times out after payment intent created?
- What if server crashes after ledger entry but before user notification?

---

### Simulation 4: Malicious Input

**Scenario:** Attacker sends crafted input (negative values, SQL injection, XSS, type coercion)

```markdown
## Simulation 4: Malicious Input

**Attack Vectors Tested:**

| Input | Attack Type | Current Defense | After Change |
|-------|-------------|-----------------|--------------|
| amount: -100 | Negative value | [defense] | [still works?] |
| escrowId: "'; DROP TABLE--" | SQL injection | [defense] | [still works?] |
| description: "<script>..." | XSS | [defense] | [still works?] |
| userId: null | Null injection | [defense] | [still works?] |
| amount: "100" (string) | Type coercion | [defense] | [still works?] |

**New Attack Surfaces Introduced:** [List any new input paths]

**Mitigations:** [How new surfaces are protected]
```

**Example Questions:**
- What if someone sends negative escrow amount?
- What if someone sends another user's ID?
- What if someone sends extremely large values?

---

### Simulation 5: Stale State

**Scenario:** Cached data is outdated when operation executes

```markdown
## Simulation 5: Stale State

**Setup:** Cache contains state X, but actual state is Y

**Cache Location:** [Where is state cached]

**Staleness Window:** [How long can cache be stale]

**Scenario:**
1. User A views task (caches state: OPEN)
2. User B accepts task (state now: ACCEPTED)
3. User A attempts to accept (uses stale state: OPEN)

**Current Behavior:** [What happens]

**After This Change:** [What happens]

**Stale State Handled?** [Yes/No]

**Mitigation:** [How to handle stale state - optimistic locking, refetch, etc.]
```

**Example Questions:**
- What if feed cache shows task that's already accepted?
- What if capability profile cache is stale when checking eligibility?
- What if escrow state cache is stale during release?

---

### Simulation 6: Race Conditions

**Scenario:** Multiple users/processes compete for same resource

```markdown
## Simulation 6: Race Conditions

**Resource:** [What's being competed for]

**Competitors:** [Who/what is competing]

**Scenario:**
1. User A reads resource (state: available)
2. User B reads resource (state: available)
3. User A writes resource (claims it)
4. User B writes resource (also claims it?)

**Current Behavior:** [How is race handled]

**After This Change:** [How is race handled]

**Locking Mechanism:** [Optimistic/Pessimistic/None]

**Isolation Level:** [READ COMMITTED / SERIALIZABLE / etc.]

**Race Handled Correctly?** [Yes/No]
```

**Example Questions:**
- What if two hustlers accept same task simultaneously?
- What if two processes try to release same escrow?
- What if recompute runs while verification is updating?

---

### Simulation 7: Edge Cases

**Scenario:** Boundary values (zero, max int, empty string, null, Unicode)

```markdown
## Simulation 7: Edge Cases

| Edge Case | Input Value | Expected Behavior | Actual After Change |
|-----------|-------------|-------------------|---------------------|
| Zero | amount: 0 | [expected] | [actual] |
| Max integer | amount: 2^53 | [expected] | [actual] |
| Empty string | description: "" | [expected] | [actual] |
| Null | userId: null | [expected] | [actual] |
| Unicode | name: "日本語" | [expected] | [actual] |
| Very long | description: [10000 chars] | [expected] | [actual] |
| Special chars | name: "O'Brien" | [expected] | [actual] |

**Edge Cases Handled?** [Yes/No]
```

---

### Simulation 8: Cascading Failures

**Scenario:** Failure in one component causes failures in dependent components

```markdown
## Simulation 8: Cascading Failures

**Failure Origin:** [Which component fails first]

**Dependency Chain:**
Component A → Component B → Component C

**Cascade Scenario:**
1. Component A fails
2. Component B receives error/timeout
3. Component B's behavior: [describe]
4. Component C receives error/timeout
5. Component C's behavior: [describe]

**Circuit Breaker Present?** [Yes/No]

**Graceful Degradation?** [Yes/No]

**Cascade Contained?** [Yes/No]
```

---

## SIMULATION SUMMARY FORMAT

After completing all simulations, summarize:

```markdown
## SIMULATION SUMMARY

**Change:** [One sentence description]

**Invariants Touched:** [List all INV-* IDs]

| Simulation | Passed? | Notes |
|------------|---------|-------|
| 1. Duplicates | ✅/❌ | [brief note] |
| 2. Out of Order | ✅/❌ | [brief note] |
| 3. Partial Failure | ✅/❌ | [brief note] |
| 4. Malicious Input | ✅/❌ | [brief note] |
| 5. Stale State | ✅/❌ | [brief note] |
| 6. Race Conditions | ✅/❌ | [brief note] |
| 7. Edge Cases | ✅/❌ | [brief note] |
| 8. Cascading Failures | ✅/❌ | [brief note] |

**Overall:** READY TO MERGE / NEEDS FIXES

**Fixes Required:** [If any]
```

---

## ANTI-PATTERNS

```
❌ "This is a simple change, simulation not needed..."
❌ "The database handles concurrency..."
❌ "Input is already validated upstream..."
❌ "That edge case won't happen in practice..."
❌ "We'll handle that in a follow-up..."
❌ [Skips simulation for "obvious" changes]
```

---

## REQUIRED PATTERNS

```
✅ "Here's my simulation for duplicate requests: [details]"
✅ "Malicious input simulation: attacker sends -$100, result: [behavior]"
✅ "Race condition analysis: two users accept same task, winner determined by: [mechanism]"
✅ "Transaction rollback confirmed: if step 3 fails, steps 1-2 are reversed"
✅ "Simulation revealed issue in scenario 5. Adding mitigation: [fix]"
```

---

## WHY SIMULATION MATTERS

**Tests verify happy path.**
**Simulation verifies failure paths.**

Tests answer: "Does it work?"
Simulation answers: "What happens when it doesn't?"

| Approach | Catches | Misses |
|----------|---------|--------|
| Tests only | Known scenarios | Unknown scenarios |
| Simulation + Tests | Known + anticipated unknowns | True black swans |

**Simulation is thinking before coding.**
**It's cheaper to find bugs in your head than in production.**

---

**If you can't explain what happens when it fails, you don't understand what happens when it succeeds.**
