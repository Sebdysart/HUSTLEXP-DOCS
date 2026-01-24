# PER MASTER INDEX — HUSTLEXP v2.1

**STATUS: CONSTITUTIONAL AUTHORITY**
**VERSION: MAX-TIER + HIC**
**ENFORCEMENT: MANDATORY — VIOLATIONS ARE SYSTEM FAILURES**

---

## 🔒 HUSTLEXP INVOCATION COMMAND (HIC v1.0)

> **EVERY CURSOR PROMPT MUST BEGIN WITH:**
>
> ```
> HUSTLEXP_INVOCATION()
> ```
>
> **EVERY RESPONSE MUST BEGIN WITH HIC HEADER:**
>
> ```
> ┌─────────────────────────────────────────────────────────────────┐
> │ HIC v1.0 — HUSTLEXP INVOCATION RESPONSE                         │
> ├─────────────────────────────────────────────────────────────────┤
> │ STEP 0: REPO RE-ANCHOR        ✓ Complete                        │
> │ STEP 1: COLD START            [verification]                    │
> │ STEP 2: CLASSIFICATION        [protocol]                        │
> │ STEP 3: LEGALITY              [LEGAL/ILLEGAL]                   │
> │ STEP 4: PLAN                  [if implementation]               │
> │ STEP 5: EXECUTION             [proceed/stop]                    │
> └─────────────────────────────────────────────────────────────────┘
> ```
>
> **Responses missing HIC header are INVALID.**
>
> See `PER/INVOCATION_COMMAND.md` for full specification.
> See `PER/SELF_CHECK.md` for pre-output verification.

---

## PER v2.1: SESSION START PROTOCOL

> **AI MUST READ THESE FIRST — IN ORDER:**
>
> 1. `PER/PER_MASTER_INDEX.md` — Root authority (this file)
> 2. `PER/INVOCATION_COMMAND.md` — HIC syscall specification
> 3. `PER/PROJECT_STATE.md` — Know where we are in the build
> 4. `PER/DICTIONARY.md` — Know what terms mean
> 5. `PER/DONE_DEFINITION.md` — Know what "done" means
> 6. `PER/FORBIDDEN_OUTPUTS.md` — Know explicit patterns that FAIL
> 7. `PER/EXECUTION_CONSTITUTION.md` — Know how AI must operate
> 8. `PER/AUTHORITY_LADDER.md` — Know how to resolve ambiguity
> 9. `PER/DESIGN_AUTHORITY.md` — Know that entry layout is LOCKED
> 10. `PER/REJECTED_APPROACHES.md` — Don't repeat failures
> 11. `PER/COMPLETION_LOCK.md` — Protect finished work
> 12. `PER/SELF_CHECK.md` — Pre-output verification

---

## THE PRIME DIRECTIVE

> **Prevention → Detection → Containment → Recovery**
>
> There is no such thing as "AI never makes mistakes."
> What this system guarantees is:
> - Mistakes are **impossible to merge**
> - Hallucinations are **immediately detectable**
> - Damage is **reversible and localized**
> - Every failure has a **guaranteed escape**

---

## PER LEVELS OVERVIEW

| Level | Name | Gate Type | Enforcement |
|-------|------|-----------|-------------|
| **PER-0** | Authority & Scope Lock | HARD | SPEC exists, INVARIANTS defined, OWNERSHIP clear |
| **PER-1** | Proof-of-Existence Gate | HARD | Cannot reference what cannot be proven |
| **PER-2** | Plan-First, Code-Second | HARD | No code without approved execution plan |
| **PER-3** | Invariant Simulation | HARD | Mental execution before merge |
| **PER-4** | Deterministic Test Harness | HARD | Tests that fail if constraints removed |
| **PER-5** | Blast Radius Containment | SOFT | Feature flags, one concern per PR |
| **PER-6** | Human Diff Audit | SOFT | Explicit verification checklist |
| **PER-Ω** | Omega Escape Protocol | NUCLEAR | Guaranteed recovery from any failure |

---

## PER-0: AUTHORITY & SCOPE LOCK

### Required Artifacts

| Document | Purpose | Location |
|----------|---------|----------|
| **FINISHED_STATE.md** | What must exist (product boundary) | `/FINISHED_STATE.md` |
| **INVARIANTS.md** | What must never break (all invariants) | `/PER/INVARIANTS.md` |
| **DO_NOT_TOUCH.md** | What is forbidden (explicit prohibitions) | `/PER/DO_NOT_TOUCH.md` |
| **OWNERSHIP.md** | Who owns what (layer authority) | `/PER/OWNERSHIP.md` |
| **FEATURE_FREEZE.md** | What is frozen (scope lock) | `/FEATURE_FREEZE.md` |

### The Rule

> If a file is not explicitly allowed, AI may only READ it.
> If a feature is not in FINISHED_STATE.md, AI may not implement it.
> If an invariant is in INVARIANTS.md, AI may not violate it.

---

## PER-1: PROOF-OF-EXISTENCE GATE

**Document:** `/PER/PER-1_EXISTENCE_GATE.md`

### The Rule

> AI may not reference anything it cannot prove exists.

### Required Confirmations Before Any Action

- [ ] File path exists (verified by read/glob)
- [ ] Function signature exists (verified by reading target file)
- [ ] Schema/table/column exists (verified in schema.sql)
- [ ] Enum/constant exists (verified in codebase)
- [ ] Screen exists (verified in SCREEN_REGISTRY.md)
- [ ] Invariant ID exists (verified in INVARIANTS.md)

**If existence cannot be proven → STOP and ask.**

---

## PER-2: PLAN-FIRST, CODE-SECOND

**Document:** `/PER/PER-2_EXECUTION_PLAN.md`

### The Rule

> No code may be written without an approved execution plan.

### Required Plan Contents

1. **Files to modify** (explicit paths)
2. **Reason for each change** (justification)
3. **Invariants touched** (or "none")
4. **New failure modes** (what could break)
5. **Rollback plan** (how to undo)
6. **Test coverage required** (what tests needed)

**If plan not approved → No code is written.**

---

## PER-3: INVARIANT SIMULATION

**Document:** `/PER/PER-3_SIMULATION_CHECKLIST.md`

### The Rule

> Before merge, AI must enumerate all invariants and simulate failure scenarios.

### Required Simulations

1. **Requests duplicated** — Same request sent twice
2. **Requests out of order** — Unexpected sequence
3. **Requests fail halfway** — Mid-transaction failure
4. **Malicious input** — Attacker-crafted data
5. **Stale state** — Outdated cached data
6. **Race conditions** — Concurrent access
7. **Edge cases** — Boundary values

**If simulation reveals vulnerability → Fix before merge.**

---

## PER-4: DETERMINISTIC TEST HARNESS

**Document:** `/PER/PER-4_TEST_REQUIREMENTS.md`

### The Rule

> Every invariant must have tests that fail when the constraint is removed.

### Required Test Types

| Type | Purpose | Minimum |
|------|---------|---------|
| **Invariant tests** | Prove constraints work | 24 tests |
| **Idempotency tests** | Same result on repeat | Per mutation |
| **Permission boundary tests** | Layer violations rejected | Per endpoint |
| **Failure-path tests** | Rollback works | Per transaction |

### Hard Rules

- **NO MOCKS** for money, auth, or state transitions
- Tests must **FAIL** if constraints are removed
- Tests run locally **BEFORE** merge

---

## PER-5: BLAST RADIUS CONTAINMENT

**Document:** `/PER/PER-5_BLAST_RADIUS.md`

### The Rule

> Every change must be isolated to minimize blast radius.

### Containment Rules

- Feature flags or branch isolation
- No cross-domain edits in one PR
- One concern per diff
- If it breaks, rollback in < 5 minutes

---

## PER-6: HUMAN DIFF AUDIT

**Document:** `/PER/PER-6_DIFF_AUDIT.md`

### The Rule

> Every diff must be human-verifiable against a checklist.

### Audit Checklist

- [ ] No invariant shortcuts
- [ ] No silent behavior changes
- [ ] No "temporary" hacks
- [ ] No TODOs in critical paths
- [ ] No unsafe patterns
- [ ] No missing error handling
- [ ] No test gaps

**If you can't explain the diff → It doesn't merge.**

---

## PER-Ω: OMEGA ESCAPE PROTOCOL (NUCLEAR FALLBACK)

**Document:** `/PER/OMEGA_PROTOCOL.md`

### The Rule

> When all else fails, there is always a guaranteed escape.

### Trigger Conditions (ANY ONE activates Ω)

- App will not build after toolchain reset + last-known-good checkout
- Crashes persist across clean environment + fresh clone
- Root cause unclear after 60-90 minutes of structured debugging
- Multiple subsystems implicated simultaneously
- AI explanations diverge or contradict

### Ω Response

**AI loses all autonomy. Human takes control.**

| Phase | Action |
|-------|--------|
| **Ω-1** | ABSOLUTE FREEZE — No new fixes, no updates, no "one more try" |
| **Ω-2** | CANONICAL RESET — Fresh clone, tagged release, fresh toolchain |
| **Ω-3** | SUBTRACTIVE RECONSTRUCTION — Rebuild backward, one invariant at a time |
| **Ω-4** | AI ROLE DEMOTION — AI observes only, human decides |
| **Ω-5** | POSTMORTEM UPGRADE — New invariant, new PER rule, new guard |

**This works 100% of the time because it eliminates uncertainty.**

---

## DOCUMENT HIERARCHY

```
PER_MASTER_INDEX.md (THIS FILE - ROOT AUTHORITY)
├── INVARIANTS.md (Consolidated invariant registry)
├── DO_NOT_TOUCH.md (Forbidden files/concepts)
├── OWNERSHIP.md (Layer boundaries)
├── PER-1_EXISTENCE_GATE.md (Proof-of-existence)
├── PER-2_EXECUTION_PLAN.md (Plan-first gate)
├── PER-3_SIMULATION_CHECKLIST.md (Invariant simulation)
├── PER-4_TEST_REQUIREMENTS.md (Test harness)
├── PER-5_BLAST_RADIUS.md (Containment rules)
├── PER-6_DIFF_AUDIT.md (Human verification)
├── OMEGA_PROTOCOL.md (Nuclear fallback)
├── CRASH_PROTOCOL.md (Crash response)
└── LAST_KNOWN_GOOD.md (Recovery anchors)
```

---

## ENFORCEMENT CHAIN

```
User Request
    ↓
PER-0: Is this in scope? (FINISHED_STATE.md, FEATURE_FREEZE.md)
    ↓ HARD GATE
PER-1: Does everything exist? (file paths, schemas, functions)
    ↓ HARD GATE
PER-2: Approved execution plan?
    ↓ HARD GATE
PER-3: Invariants simulated?
    ↓ HARD GATE
[IMPLEMENTATION]
    ↓
PER-4: Tests exist and pass?
    ↓ HARD GATE
PER-5: Blast radius contained?
    ↓ SOFT GATE
PER-6: Human audited diff?
    ↓ SOFT GATE
MERGE
    ↓
[If failure persists]
    ↓
PER-Ω: Omega Protocol (NUCLEAR)
    ↓
GUARANTEED RECOVERY
```

---

## TOOL-SPECIFIC ENFORCEMENT

| PER Level | Claude Code (Backend) | Cursor (Frontend) |
|-----------|----------------------|-------------------|
| PER-0 | `.claude/instructions.md` | `.cursorrules` |
| PER-1 | Verify before action | Verify before action |
| PER-2 | Present plan | Present plan |
| PER-3 | Simulate invariants | N/A (no invariants in frontend) |
| PER-4 | Write/update tests | Write/update tests |
| PER-5 | One concern per PR | One concern per PR |
| PER-6 | Human reviews | Human reviews |
| PER-Ω | Loses write permissions | Loses write permissions |

---

## ANTI-BYPASS MEASURES

### 1. Mandatory First Step Pattern
Both `.claude/instructions.md` and `.cursorrules` require checking PER documents BEFORE any action.

### 2. Cross-Reference Validation
Every invariant has an ID and source document. Invalid references are detectable.

### 3. Explicit Enumeration
DO_NOT_TOUCH.md lists forbidden actions explicitly. No room for interpretation.

### 4. Gate Dependencies
PER-2 requires PER-1. PER-3 requires PER-2. PER-4 requires PER-3. Gates cannot be skipped.

### 5. Omega Escape
If all else fails, PER-Ω guarantees recovery. No infinite loops. No death spirals.

---

## THE GUARANTEE

This system guarantees:

| Guarantee | How |
|-----------|-----|
| Mistakes cannot merge | PER-1 through PER-4 gates |
| Hallucinations are detectable | PER-1 existence checks |
| Damage is reversible | PER-5 containment + PER-Ω reset |
| Every failure has escape | PER-Ω nuclear fallback |
| AI cannot make things worse | PER-Ω role demotion |
| Progress is inevitable | Subtractive reconstruction |

**Not because it's clever, but because it's inescapable.**

---

## RELATED DOCUMENTS

| Document | Purpose |
|----------|---------|
| `FINISHED_STATE.md` | Product boundary definition |
| `FEATURE_FREEZE.md` | Scope lock |
| `AI_GUARDRAILS.md` | AI constraint rules |
| `.claude/instructions.md` | Backend enforcement policy |
| `.cursorrules` | Frontend enforcement policy |
| `ARCHITECTURE.md` | 7-layer authority model |
| `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` | Eligibility invariants |
| `VERIFICATION_PIPELINE_LOCKED.md` | Trust verification pipeline |

---

**This is MAX-TIER. Not because it's perfect, but because it's inescapable.**
