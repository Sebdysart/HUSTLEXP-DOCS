# EXECUTION COMMITMENT PROTOCOL (ECP)

**STATUS: CONSTITUTIONAL**
**PURPOSE: Prevent compliance-only or analysis-only responses**
**RULE: If execution is legal, AI must COMMIT or REFUSE — no middle ground**

---

## WHY THIS EXISTS

AI can:
- Correctly execute HIC Step 0–3
- Correctly classify the protocol
- Correctly cite rules
- Correctly *explain* what should happen

…and then still:
- Provide **conceptual output**
- Provide **descriptive guidance**
- Provide **pseudo-execution**
- Avoid actually *doing* the constrained thing

This is **"Answer-Only Compliance"** — compliance without commitment.

This document makes that impossible.

---

## THE RULE

> **If a request is classified as IMPLEMENTATION_MODE or REFACTOR_MODE,
> AI must do EXACTLY ONE of the following:**

---

## OPTION A: COMMIT

Produce a **concrete artifact**:
- Code (actual implementation, not pseudocode)
- Spec (complete, not partial)
- Diagram (rendered, not described)
- File diff (real changes, not conceptual)

Requirements:
- Fully compliant with all acceptance gates (UAP-1 through UAP-5)
- Fully compliant with COLOR_SEMANTICS_LAW.md
- Ready for review or merge
- No placeholders (`// TODO`, `/* implement */`)
- No conceptual descriptions in place of code

**COMMIT means:** The artifact exists. It can be built. It can be tested.

---

## OPTION B: REFUSE

Explicitly state refusal with:
1. **Blocking rule** — Which constraint prevents execution
2. **Specific blocker** — Exactly what is unclear or missing
3. **Unblock condition** — What is needed to proceed

**REFUSE means:** Execution is impossible until condition is met.

### Refusal Template

```
EXECUTION REFUSED

Blocking Rule: [PER gate, invariant, or constraint]
Specific Blocker: [What exactly is unclear or missing]
Unblock Condition: [What user must provide or clarify]

I cannot proceed until this is resolved.
```

---

## FORBIDDEN RESPONSES

These responses are **INVALID** in IMPLEMENTATION_MODE or REFACTOR_MODE:

### Conceptual Guidance

```
❌ "Here's how you would implement this..."
❌ "One approach would be..."
❌ "You could consider..."
❌ "In theory, this would work by..."
❌ "The pattern for this is..."
```

### Partial Execution

```
❌ "Here's a sketch of the solution..."
❌ "The basic structure would be..."
❌ "Something like this..." (followed by incomplete code)
❌ Code with TODO comments
❌ Code with placeholder functions
```

### Deferred Action

```
❌ "We should first think about..."
❌ "Before implementing, consider..."
❌ "Let me outline the approach..."
❌ "I'll explain the strategy..."
```

**If execution is LEGAL → COMMIT**
**If execution is BLOCKED → REFUSE**
**There is no third option.**

---

## PROTOCOL-SPECIFIC BEHAVIOR

### RESEARCH_MODE
ECP does not apply. Analysis-only responses are valid.

### IMPLEMENTATION_MODE
ECP applies. Must COMMIT or REFUSE.

### REFACTOR_MODE
ECP applies. Must COMMIT or REFUSE.

### VALIDATION_MODE
ECP does not apply. Reporting without change is valid.

### RECOVERY_MODE (Ω)
ECP applies. Must fix or escalate.

### CLARIFICATION_REQUIRED
ECP does not apply. Asking is the correct action.

---

## DETECTION PATTERNS

AI should self-check before output:

### Am I Committing?

```
[ ] Output contains actual code/spec/artifact
[ ] Artifact is complete (no TODO placeholders)
[ ] Artifact is ready to be built/tested
[ ] No "you would/could/should" language
[ ] No "in theory" or "conceptually" language
```

### Am I Refusing?

```
[ ] Explicit statement of refusal
[ ] Blocking rule cited
[ ] Unblock condition stated
[ ] No partial or conceptual output
```

### Am I Violating ECP?

```
If in IMPLEMENTATION_MODE or REFACTOR_MODE:
  AND output contains conceptual guidance
  AND output does NOT contain real artifact
  AND output is NOT explicit refusal
→ ECP VIOLATION
```

---

## EXAMPLES

### ✅ Valid COMMIT

```
User: "Implement the button color fix per COLOR_SEMANTICS_LAW.md"

AI Response:
[Produces complete code edit changing backgroundColor from '#1FAD7E' to '#5B2DFF']
```

### ✅ Valid REFUSE

```
User: "Add a new onboarding screen"

AI Response:
EXECUTION REFUSED

Blocking Rule: FEATURE_FREEZE.md
Specific Blocker: Screen not in SCREEN_REGISTRY.md
Unblock Condition: User must add screen to registry or confirm exemption

I cannot proceed until this is resolved.
```

### ❌ Invalid (Conceptual Guidance)

```
User: "Implement the button color fix"

AI Response:
"The way to fix this would be to change the backgroundColor
from the green value to the purple brand color. You would
open EntryScreen.tsx and modify the style object..."
```

This describes but does not commit. **INVALID.**

### ❌ Invalid (Partial Execution)

```
User: "Implement the entry screen gradient"

AI Response:
"Here's the basic structure:

<LinearGradient
  colors={/* TODO: add gradient colors */}
  style={styles.gradient}
/>

You'll need to fill in the colors from COLOR_SEMANTICS_LAW.md..."
```

This has placeholders. **INVALID.**

---

## INTEGRATION WITH HIC

ECP is enforced at **HIC STEP 5: EXECUTION COMMITMENT**.

```
STEP 5 — EXECUTION COMMITMENT (ECP)

If protocol is IMPLEMENTATION_MODE or REFACTOR_MODE:
  → Check if execution is legal (STEP 3 passed)
  → If LEGAL → COMMIT (produce real artifact)
  → If BLOCKED → REFUSE (cite blocker + unblock condition)
  → NO OTHER RESPONSE IS VALID

Partial execution, conceptual guidance, or descriptive responses
are ECP violations.
```

---

## THE GUARANTEE

With ECP, the system guarantees:

| Outcome | Mechanism |
|---------|-----------|
| No hovering | Must COMMIT or REFUSE |
| No analysis paralysis | Conceptual-only responses invalid |
| Forward momentum | Every implementation request produces artifact or blocker |
| Clear blockers | Refusals state exactly what's needed |
| Shippable output | Committed artifacts are complete |

---

## ANTI-PATTERN: "HELPFUL COWARDICE"

The most common violation of ECP is:

> "I understand all constraints; here is how one *would* implement X…"

This *sounds compliant* but produces **no artifact**.

This is **helpful cowardice** — appearing useful while avoiding commitment.

ECP makes this structurally impossible.

---

**COMMIT or REFUSE.**
**There is no third option.**
**Compliance without commitment is not compliance.**
