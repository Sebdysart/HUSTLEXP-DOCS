# PER-2: PLAN-FIRST, CODE-SECOND

**STATUS: MANDATORY PRE-CODE GATE**
**GATE TYPE: HARD**
**PURPOSE: No code without an approved execution plan**

---

## THE RULE

> No code may be written without an approved execution plan.
> The plan must be explicit, not implicit.
> "I'll figure it out as I go" is not a plan.

---

## EXECUTION PLAN TEMPLATE

Before writing ANY code, present this plan to the user:

```markdown
## EXECUTION PLAN

### 1. Summary
[One sentence: What are we doing and why]

### 2. Files to Modify
| File | Action | Lines Affected |
|------|--------|----------------|
| [exact path] | create/modify/delete | [line numbers or "new file"] |

### 3. Reason for Each Change
| File | Change | Justification |
|------|--------|---------------|
| [path] | [what changes] | [why this is necessary] |

### 4. Invariants Touched
| Invariant ID | Current State | After Change | Still Satisfied? |
|--------------|---------------|--------------|------------------|
| [INV-X] | [description] | [description] | Yes/No |

(If no invariants touched, state: "No invariants touched by this change")

### 5. New Failure Modes
| Failure Mode | Trigger Condition | Impact | Mitigation |
|--------------|-------------------|--------|------------|
| [what could fail] | [when/how] | [consequences] | [how to handle] |

(If no new failure modes, state: "No new failure modes introduced")

### 6. Rollback Plan
If this change fails or causes issues:
1. [Step 1 to undo]
2. [Step 2 to undo]
3. [Step 3 to undo]

### 7. Test Coverage Required
| Test Type | Test Case | Expected Result |
|-----------|-----------|-----------------|
| [unit/integration/invariant] | [test description] | [pass criteria] |

### 8. Dependencies
- [x] PER-1 existence checks completed
- [ ] Files verified to exist
- [ ] Schemas verified
- [ ] Invariants verified
```

---

## APPROVAL PROCESS

### Step 1: Present Plan
Show the complete plan to the user. Do not abbreviate.

### Step 2: Wait for Approval
Wait for explicit approval:
- "Approved"
- "Proceed"
- "Looks good"
- "Go ahead"

**Silence is NOT approval.**
**Questions are NOT approval.**

### Step 3: Handle Feedback
If user requests changes:
- Update the plan
- Re-present the updated plan
- Wait for new approval

### Step 4: Begin Implementation
Only after explicit approval, begin coding.

### Step 5: Scope Changes
If scope changes during implementation:
- STOP coding
- Update the plan
- Re-present for approval
- Wait for new approval

---

## PLAN COMPLEXITY THRESHOLDS

| Change Type | Plan Level | Required Sections |
|-------------|------------|-------------------|
| Single file, < 10 lines | MINIMAL | Files + Reason |
| Multiple files OR > 10 lines | STANDARD | Full template |
| Touches invariants | DETAILED | Full template + simulation (PER-3) |
| Touches money/escrow | DETAILED | Full template + rollback tested |
| New endpoint | STANDARD | Full template |
| Bug fix | MINIMAL | Files + Reason + Test |
| Refactor | STANDARD | Full template |

---

## MINIMAL PLAN (< 10 lines, single file)

```markdown
## EXECUTION PLAN (Minimal)

**Change:** [One sentence description]

**File:** [exact path]

**Lines:** [line numbers]

**Reason:** [Why this change is necessary]

**Rollback:** Revert commit / restore lines [X-Y]

**Test:** [How to verify it works]
```

---

## STANDARD PLAN (Multiple files OR > 10 lines)

Use the full template from the EXECUTION PLAN TEMPLATE section.

---

## DETAILED PLAN (Invariants or Money)

Use the full template PLUS:

```markdown
### 9. Invariant Simulation (PER-3)
[Complete PER-3 checklist embedded here]

### 10. Transaction Boundaries
| Operation | Transaction Scope | Rollback Behavior |
|-----------|------------------|-------------------|
| [operation] | [scope] | [what happens on failure] |

### 11. Manual Rollback Test
Before deploying:
1. Execute change in test environment
2. Intentionally cause failure at step [X]
3. Verify rollback completes cleanly
4. Document rollback time: [X seconds/minutes]
```

---

## ANTI-PATTERNS

These phrases indicate PER-2 violation:

```
❌ "I'll just add this quick fix..."
❌ "Let me refactor while I'm here..."
❌ "This is straightforward, no plan needed..."
❌ "I'll figure it out as I go..."
❌ "Let me start coding and we'll see..."
❌ [Starts writing code without presenting plan]
❌ [Presents abbreviated plan]
```

---

## REQUIRED PATTERNS

These phrases indicate PER-2 compliance:

```
✅ "Here's my execution plan for this change: [full plan]"
✅ "Before I begin, let me outline what I'll modify: [file list]"
✅ "This change touches INV-3. Here's my analysis: [details]"
✅ "Rollback plan if this fails: [steps]"
✅ "Waiting for your approval before I proceed."
✅ "You requested changes. Here's the updated plan: [plan]"
```

---

## WHY PLANS MATTER

### Without Plans

1. Developer starts coding
2. Discovers missing dependency
3. Pivots approach mid-stream
4. Touches unexpected files
5. Breaks something unrelated
6. Spends 2 hours debugging
7. Reverts and starts over

### With Plans

1. Plan identifies all files upfront
2. Plan identifies dependencies
3. User approves approach
4. Implementation matches plan
5. If something breaks, rollback is known
6. Debugging is localized
7. First attempt works

---

## PLAN VALIDATION CHECKLIST

Before presenting a plan, verify:

```
[ ] All files listed exist (PER-1)
[ ] All functions referenced exist (PER-1)
[ ] All schemas verified (PER-1)
[ ] All invariants identified
[ ] Rollback plan is actionable
[ ] Test coverage is specified
[ ] No assumptions (everything is verified)
```

---

## SCOPE CHANGE PROTOCOL

If during implementation you discover:
- Need to modify additional files
- Need to change approach
- Original plan was incorrect

**DO NOT continue with modified scope.**

Instead:

1. STOP coding
2. Document what changed
3. Create updated plan
4. Present updated plan to user
5. Wait for new approval
6. Only then continue

---

## PLAN LIFECYCLE

```
[User Request]
    ↓
[PER-1: Verify existence]
    ↓
[Create Plan]
    ↓
[Present Plan to User]
    ↓
[User Approves?] ─No→ [Update Plan] ─→ [Re-present]
    ↓ Yes
[Begin Implementation]
    ↓
[Scope Changes?] ─Yes→ [STOP] → [Update Plan] → [Re-present]
    ↓ No
[Complete Implementation]
    ↓
[Run Tests]
    ↓
[PER-4: Verify tests pass]
```

---

**No plan = No code.**
**Implicit plan = No plan.**
**Plan changes = New approval.**
