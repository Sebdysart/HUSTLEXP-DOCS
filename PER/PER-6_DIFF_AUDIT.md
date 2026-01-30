# PER-6: HUMAN DIFF AUDIT

**STATUS: RECOMMENDED (SOFT GATE)**
**GATE TYPE: SOFT**
**PURPOSE: Human verification before merge**

---

## THE RULE

> Every diff must be human-verifiable against a checklist.
> If you can't explain every line, don't approve.
> Code review is not "looks good to me" — it's verification.

---

## DIFF AUDIT CHECKLIST

Before approving ANY diff, verify each section:

### 1. No Invariant Shortcuts

```
[ ] No code that bypasses database constraints
[ ] No code that assumes success without checking
[ ] No code that skips the proof → release → XP chain
[ ] No code that trusts frontend-computed values
[ ] No code that lets AI make final decisions
[ ] No direct writes to append-only tables
[ ] No modifications to escrow amounts
```

**Red Flags:**
```typescript
// 🚨 Direct ledger write
db.xp_ledger.create({ ... })

// 🚨 Bypassing escrow check
if (shouldAward) awardXP(...)

// 🚨 Trusting frontend value
const amount = req.body.calculatedAmount
```

---

### 2. No Silent Behavior Changes

```
[ ] No changes to existing function signatures without updating callers
[ ] No changes to error codes or error messages
[ ] No changes to response shapes
[ ] No changes to state machine transitions
[ ] No changes to invariant enforcement
[ ] No changes to default values
```

**Red Flags:**
```typescript
// 🚨 Signature change
- function process(id: string): Result
+ function process(id: string, options?: Options): Result  // Callers may break

// 🚨 Error code change
- throw new Error('HX101')
+ throw new Error('HX102')  // Monitoring/handling may break

// 🚨 Response shape change
- return { success: true, data }
+ return { ok: true, result: data }  // Consumers may break
```

---

### 3. No "Temporary" Hacks

```
[ ] No TODO comments in production code paths
[ ] No FIXME comments in critical paths
[ ] No "temporary" workarounds
[ ] No commented-out code
[ ] No magic numbers without explanation
[ ] No "we'll fix this later" patterns
```

**Red Flags:**
```typescript
// 🚨 TODO in production path
// TODO: handle edge case
if (data) process(data)

// 🚨 Magic number
if (retryCount < 3) // Why 3?

// 🚨 Commented code
// const oldImplementation = ...
```

---

### 4. No TODOs in Critical Paths

**Critical Paths (MUST have zero TODOs):**
- Money operations (escrow, payment, refund)
- XP operations (award, ledger)
- Trust operations (tier changes, badges)
- Auth operations (login, permissions)
- State transitions (task lifecycle)

```
[ ] Money operations have no TODOs
[ ] XP operations have no TODOs
[ ] Trust operations have no TODOs
[ ] Auth operations have no TODOs
[ ] State transitions have no TODOs
```

---

### 5. No Unsafe Patterns

```
[ ] No SQL injection vectors (raw string concatenation)
[ ] No XSS vectors (unescaped user input)
[ ] No hardcoded secrets
[ ] No console.log with sensitive data
[ ] No unhandled promise rejections in critical paths
[ ] No eval() or dynamic code execution
[ ] No prototype pollution risks
```

**Red Flags:**
```typescript
// 🚨 SQL injection
db.query(`SELECT * FROM users WHERE id = '${userId}'`)

// 🚨 Hardcoded secret
const API_KEY = 'sk_live_abc123'

// 🚨 Sensitive data logged
console.log('Payment details:', paymentData)

// 🚨 Unhandled rejection
fetchData().then(process)  // No .catch()
```

---

### 6. No Missing Error Handling

```
[ ] All async operations have try/catch
[ ] All database operations have transaction handling
[ ] All external API calls have timeout and retry
[ ] All user-facing errors have appropriate messages
[ ] All errors are logged appropriately
[ ] No swallowed exceptions (empty catch blocks)
```

**Red Flags:**
```typescript
// 🚨 No error handling
const data = await fetchData()

// 🚨 Swallowed exception
try { riskyOperation() } catch (e) { }

// 🚨 Generic error message
throw new Error('Something went wrong')
```

---

### 7. No Test Gaps

```
[ ] New code has tests
[ ] Modified code has updated tests
[ ] Tests actually test the behavior (not just coverage)
[ ] No tests commented out
[ ] No tests marked as .skip without reason
[ ] Edge cases are tested
```

**Red Flags:**
```typescript
// 🚨 Commented test
// it('should handle edge case', ...)

// 🚨 Skipped without reason
it.skip('should validate input', ...)

// 🚨 Test that doesn't test anything
it('should work', () => {
  expect(true).toBe(true)
})
```

---

## AUDIT PROCESS

### Step 1: Read PR Description
- Does the description match what the code does?
- Is the scope clear?
- Is the "why" explained?

### Step 2: Check File List
- Are all changed files related to the stated purpose?
- Any unexpected files?
- Cross-domain changes? (should be separate PR)

### Step 3: Review Each File
For each file:
1. Understand the change
2. Apply checklist above
3. Note any concerns

### Step 4: Verify Tests
- Do tests exist for changes?
- Do tests actually test the changes?
- Would removing the code break the tests?

### Step 5: Sign Off or Request Changes
- If all checks pass → Approve
- If any concerns → Request changes with specific feedback

---

## RED FLAGS (Request Changes Immediately)

These patterns require immediate changes request:

| Red Flag | Why It's Dangerous |
|----------|-------------------|
| Any direct write to xp_ledger | Bypasses XPService enforcement |
| Any direct write to trust_ledger | Bypasses TrustService enforcement |
| Any direct write to badges | Bypasses BadgeService enforcement |
| Any modification to schema.sql constraints | Changes invariant enforcement |
| Any change to trigger functions | May break invariants |
| Any new endpoint without permission checks | Security vulnerability |
| Any money operation without idempotency | Double-charge risk |
| Any TODO in critical path | Production risk |
| Any "temporary" comment | Technical debt |
| Any hardcoded credentials | Security vulnerability |
| Any SQL with string concatenation | SQL injection |

---

## AUDIT DOCUMENTATION

After completing audit, document in PR comment:

```markdown
## Diff Audit: PR #XXX

**Auditor:** [your name]
**Date:** [date]

### Checklist Results:
- [x] No invariant shortcuts
- [x] No silent behavior changes
- [x] No temporary hacks
- [x] No TODOs in critical paths
- [x] No unsafe patterns
- [x] No missing error handling
- [x] No test gaps

### Files Reviewed:
- `src/services/EscrowService.ts` - ✅
- `src/routers/escrow.ts` - ✅
- `__tests__/escrow.test.ts` - ✅

### Notes:
[Any observations, concerns, or suggestions]

### Verdict: ✅ APPROVED / ❌ CHANGES REQUESTED

[If changes requested, list specific issues]
```

---

## APPROVAL CRITERIA

**Approve when:**
- All checklist items pass
- Code is understandable
- Tests are adequate
- No security concerns
- No architectural concerns

**Request Changes when:**
- Any checklist item fails
- Code is confusing
- Tests are missing or inadequate
- Security concern exists
- Architectural concern exists
- Better approach exists

**Block/Reject when:**
- Critical security vulnerability
- Invariant violation
- Architectural violation
- DO_NOT_TOUCH file modified without approval

---

## COMMON MISTAKES

### Mistake 1: "LGTM" Without Review
**Problem:** Approving without actually reviewing
**Solution:** Use the checklist. Every time.

### Mistake 2: Assuming Tests Are Sufficient
**Problem:** If tests pass, code must be good
**Solution:** Tests prove it works. Checklist proves it's safe.

### Mistake 3: Trusting the Author
**Problem:** "They know what they're doing"
**Solution:** Everyone makes mistakes. Verify everything.

### Mistake 4: Skipping Small PRs
**Problem:** "It's just a small change"
**Solution:** Small changes can have big impacts. Review all.

### Mistake 5: Time Pressure
**Problem:** "We need to ship this today"
**Solution:** A bug shipped fast is still a bug. Take the time.

---

**Code review is not a formality.**
**It's the last line of defense before production.**
**If you can't explain every line, don't approve.**
