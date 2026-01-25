# HUSTLEXP INVOCATION COMMAND (HIC v1.1)

**STATUS: MANDATORY SYSCALL**
**PURPOSE: Force repo re-anchor and prove alignment before ANY action**
**RULE: Every Cursor prompt MUST begin with HUSTLEXP_INVOCATION()**
**VERSION: 1.1 (ECP Integration)**

---

## WHY THIS EXISTS

Cursor has no persistent memory between sessions.
Without explicit re-anchoring, it will:
- Drift from project state
- Forget constraints
- Produce low-tier output
- Repeat rejected approaches

This command is the **syscall into the Project Operating System**.
It forces Cursor to prove alignment before doing anything.

---

## THE COMMAND (PASTE THIS VERBATIM)

```
HUSTLEXP_INVOCATION()

You are operating inside the HustleXP repository.
Before responding, you MUST execute the following steps in order.

════════════════════════════════════════════════════════════════════
STEP 0 — REPO RE-ANCHOR (MANDATORY)
════════════════════════════════════════════════════════════════════
Re-read and ground yourself in the following authoritative files:

1. PER/PER_MASTER_INDEX.md
2. PER/PROJECT_STATE.md
3. PER/EXECUTION_CONSTITUTION.md
4. PER/PUZZLE_MODE.md          ← UI Assembly Constraint System
5. PER/DICTIONARY.md
6. PER/DONE_DEFINITION.md
7. PER/FORBIDDEN_OUTPUTS.md
8. PER/AUTHORITY_LADDER.md
9. PER/DESIGN_AUTHORITY.md
10. PER/REJECTED_APPROACHES.md
11. PER/COMPLETION_LOCK.md

If any file is missing or unclear, STOP and ask.

════════════════════════════════════════════════════════════════════
STEP 1 — COLD START VERIFICATION (PROOF OF ALIGNMENT)
════════════════════════════════════════════════════════════════════
Output the following verbatim before any reasoning or code:

┌─────────────────────────────────────────────────────────────────┐
│ COLD START VERIFICATION                                        │
├─────────────────────────────────────────────────────────────────┤
│ CURRENT_FOCUS:           [from PROJECT_STATE.md]                │
│ CURRENT_PHASE:           [from CURRENT_PHASE.md]                │
│ PUZZLE_LAYER:            [0=Token|1=Atom|2=Molecule|3=Section|4=Screen]│
│ LOCKED_CONSTRAINTS:      [list from PROJECT_STATE.md]           │
│ FORBIDDEN_ACTIONS:       [from FORBIDDEN_OUTPUTS.md]            │
│ ACCEPTANCE_GATES:        [UAP gates that apply]                 │
│ NEXT_LEGAL_ACTION:       [from PROJECT_STATE.md]                │
└─────────────────────────────────────────────────────────────────┘

If any field cannot be filled with certainty → DO NOT CONTINUE.

════════════════════════════════════════════════════════════════════
STEP 2 — REQUEST CLASSIFICATION
════════════════════════════════════════════════════════════════════
Classify this user request into EXACTLY ONE protocol:

┌─────────────────────────────────────────────────────────────────┐
│ PROTOCOL              │ DESCRIPTION                             │
├───────────────────────┼─────────────────────────────────────────┤
│ RESEARCH_MODE         │ Read files, search, explain, no edits   │
│ IMPLEMENTATION_MODE   │ Create/edit code per approved plan      │
│ REFACTOR_MODE         │ Restructure existing code (rare)        │
│ VALIDATION_MODE       │ Run tests, verify builds, check quality │
│ RECOVERY_MODE (Ω)     │ Fix crashes, restore function           │
│ CLARIFICATION_REQUIRED│ Request is ambiguous, NO ACTION         │
└───────────────────────┴─────────────────────────────────────────┘

If the request spans multiple protocols:
→ STOP
→ REQUEST SPLIT into separate actions

════════════════════════════════════════════════════════════════════
STEP 3 — LEGALITY CHECK
════════════════════════════════════════════════════════════════════
Verify the request is LEGAL under:

• PROJECT_STATE.md     — Is this allowed in current phase?
• DONE_DEFINITION.md   — Does this match completion criteria?
• FORBIDDEN_OUTPUTS.md — Does this avoid all banned patterns?
• COMPLETION_LOCK.md   — Does this respect locked items?
• REJECTED_APPROACHES.md — Has this been tried and failed?

┌─────────────────────────────────────────────────────────────────┐
│ LEGALITY CHECK                                                  │
├─────────────────────────────────────────────────────────────────┤
│ Phase allows action:         [YES/NO]                           │
│ No forbidden patterns:       [YES/NO]                           │
│ No locked items touched:     [YES/NO]                           │
│ Not a rejected approach:     [YES/NO]                           │
│ LEGAL:                       [YES/NO]                           │
└─────────────────────────────────────────────────────────────────┘

If ILLEGAL:
→ REJECT the request
→ CITE the exact rule violated
→ PROPOSE a legal alternative

════════════════════════════════════════════════════════════════════
STEP 4 — PLAN BEFORE EXECUTION
════════════════════════════════════════════════════════════════════
If and only if in IMPLEMENTATION_MODE or REFACTOR_MODE:

┌─────────────────────────────────────────────────────────────────┐
│ EXECUTION PLAN                                                  │
├─────────────────────────────────────────────────────────────────┤
│ Action:          [what will be done]                            │
│ Files changed:   [list of files]                                │
│ PUZZLE_LAYER:    [Layer 0-4, what permissions apply]            │
│ Pattern used:    [reference/components/X or existing pattern]   │
│ UAP gates:       [which gates apply]                            │
│ Forbidden check: [confirm no forbidden patterns]                │
│ Estimated scope: [minimal/moderate/large]                       │
└─────────────────────────────────────────────────────────────────┘

Do NOT write code until plan is acknowledged.

════════════════════════════════════════════════════════════════════
STEP 5 — EXECUTION COMMITMENT (ECP)
════════════════════════════════════════════════════════════════════
Proceed ONLY if all previous steps passed.

If protocol is IMPLEMENTATION_MODE or REFACTOR_MODE:
→ Check if execution is LEGAL (STEP 3 passed)
→ If LEGAL → COMMIT (produce real artifact)
→ If BLOCKED → REFUSE (cite blocker + unblock condition)
→ NO OTHER RESPONSE IS VALID

COMMIT means:
• Code (actual implementation, not pseudocode)
• Spec (complete, not partial)
• Diagram (rendered, not described)
• File diff (real changes, not conceptual)
• No placeholders (// TODO, /* implement */)
• Ready for review or merge

REFUSE means:
• Explicit statement of refusal
• Blocking rule cited
• Unblock condition stated
• Format: "EXECUTION REFUSED: [rule] → [blocker] → [unblock]"

FORBIDDEN responses in IMPLEMENTATION_MODE or REFACTOR_MODE:
❌ "Here's how you would implement this..."
❌ "One approach would be..."
❌ "You could consider..."
❌ Code with TODO comments
❌ Partial or conceptual output

If at any point ambiguity, conflict, or uncertainty appears:
→ STOP immediately
→ ESCALATE via PER/AUTHORITY_LADDER.md
→ ASK for clarification
→ DO NOT guess

See: PER/EXECUTION_COMMITMENT_PROTOCOL.md for full specification

════════════════════════════════════════════════════════════════════
IMMUTABLE RULES
════════════════════════════════════════════════════════════════════
• Guessing is FORBIDDEN
• Bootstrap output is NEVER user-facing
• MAX-TIER quality is MANDATORY
• Build success ≠ completion
• DONE is binary (all checkboxes or nothing)
• Green on entry screens = INSTANT FAIL
• Card layouts on entry = INSTANT FAIL
• Renaming patterns does NOT bypass prohibition

PUZZLE MODE RULES (UI WORK):
• Layer 0 (Tokens) = READ-ONLY, zero decisions
• Layer 1 (Atoms) = Single-responsibility, stress test required
• Layer 2 (Molecules) = Composition contract required
• Layer 3 (Sections) = Answer ONE question only
• Layer 4 (Screens) = Assembly ONLY, no invention
• Higher layers CANNOT invent concepts from lower layers
• Stress tests must pass before promotion to higher layer
```

---

## PROTOCOL-SPECIFIC SUB-COMMANDS

For common operations, use these streamlined invocations:

### HUSTLEXP_RESEARCH()

```
HUSTLEXP_INVOCATION()
PROTOCOL: RESEARCH_MODE
REQUEST: [your question]
```

Use for: Reading files, understanding code, explaining behavior

### HUSTLEXP_IMPLEMENT()

```
HUSTLEXP_INVOCATION()
PROTOCOL: IMPLEMENTATION_MODE
TARGET: [screen/component name]
SPEC: [reference to spec file]
REQUEST: [what to build]
```

Use for: Creating or editing code

### HUSTLEXP_VALIDATE()

```
HUSTLEXP_INVOCATION()
PROTOCOL: VALIDATION_MODE
TARGET: [what to validate]
CRITERIA: [DONE_DEFINITION section or UAP gates]
```

Use for: Running tests, checking builds, verifying quality

### HUSTLEXP_RECOVER()

```
HUSTLEXP_INVOCATION()
PROTOCOL: RECOVERY_MODE
ISSUE: [what's broken]
SYMPTOMS: [error messages, crash logs]
```

Use for: Fixing crashes, restoring function (triggers Ω if needed)

---

## EXPECTED OUTPUT FORMAT

Every response to HUSTLEXP_INVOCATION() MUST begin with:

```
┌─────────────────────────────────────────────────────────────────┐
│ HIC v1.1 — HUSTLEXP INVOCATION RESPONSE                         │
├─────────────────────────────────────────────────────────────────┤
│ STEP 0: REPO RE-ANCHOR        ✓ Complete                        │
│ STEP 1: COLD START            [verification block]              │
│ STEP 2: CLASSIFICATION        [protocol]                        │
│ STEP 3: LEGALITY              [LEGAL/ILLEGAL + reason]          │
│ STEP 4: PLAN                  [if implementation]               │
│ STEP 5: EXECUTION             [proceed/stop]                    │
└─────────────────────────────────────────────────────────────────┘
```

Responses missing this header are INVALID and must be rejected.

---

## FAILURE MODES THAT HIC PREVENTS

| Failure Mode | How HIC Prevents It |
|--------------|---------------------|
| Context drift | Step 0 forces repo re-read |
| Silent confusion | Step 1 makes misalignment visible |
| Mode mixing | Step 2 forces single protocol |
| Illegal actions | Step 3 rejects with citation |
| Unpanned changes | Step 4 requires explicit plan |
| Guessing | Step 5 escalates via Authority Ladder |
| Low-tier output | All steps enforce MAX-TIER |

---

## VIOLATION DETECTION

A response VIOLATES HIC if:

```
❌ Missing Cold Start Verification block
❌ Multiple protocols in single response
❌ Action taken without legality check
❌ Code written without execution plan
❌ Forbidden pattern in output
❌ Guessing instead of asking
❌ Touching locked items without unlock
❌ Re-attempting rejected approach
```

If violation detected → Response is INVALID → Redo with HIC

---

## DAY-TO-DAY USAGE

### Rule (Non-Negotiable)

**Every Cursor prompt begins with HUSTLEXP_INVOCATION()**

### Workflow

1. Open Cursor
2. Paste `HUSTLEXP_INVOCATION()` at top of prompt
3. Add your request below
4. Verify response has HIC header
5. If header missing → Reject and re-invoke

### Example Prompt

```
HUSTLEXP_INVOCATION()

Build the EntryScreen component according to
reference/components/EntryScreen.js pattern.
Ensure it passes UAP-5 and uses purple brand colors.
```

### Expected Response

```
┌─────────────────────────────────────────────────────────────────┐
│ HIC v1.1 — HUSTLEXP INVOCATION RESPONSE                         │
├─────────────────────────────────────────────────────────────────┤
│ STEP 0: REPO RE-ANCHOR        ✓ Complete                        │
│ STEP 1: COLD START                                              │
│   CURRENT_FOCUS: EntryScreen                                    │
│   CURRENT_PHASE: Bootstrap                                      │
│   LOCKED_CONSTRAINTS: Brand (Black+Purple), Layout (Full-Canvas)│
│   FORBIDDEN_ACTIONS: Green, Cards, Flat black                   │
│   ACCEPTANCE_GATES: UAP-1 through UAP-5                         │
│   NEXT_LEGAL_ACTION: Implement EntryScreen                      │
│ STEP 2: CLASSIFICATION        IMPLEMENTATION_MODE               │
│ STEP 3: LEGALITY              LEGAL                             │
│ STEP 4: PLAN                                                    │
│   Action: Create EntryScreen.tsx                                │
│   Files: screens/EntryScreen.tsx                                │
│   Pattern: reference/components/EntryScreen.js                  │
│   UAP gates: UAP-1, UAP-2, UAP-3, UAP-5                         │
│   Forbidden check: No green, no cards, has gradient             │
│ STEP 5: EXECUTION             PROCEED                           │
└─────────────────────────────────────────────────────────────────┘

[Implementation follows...]
```

---

## THE GUARANTEE

HIC guarantees:

1. **No execution without alignment** — Misalignment is visible
2. **No mode confusion** — One protocol per response
3. **No illegal actions** — Rejected with citation
4. **No unplanned changes** — Plan before code
5. **No guessing** — Escalate or stop
6. **No low-tier output** — MAX-TIER enforced at every step

---

**This is the final control layer.**
**HIC is the syscall into the Project Operating System.**
**Use it every time. No exceptions.**
