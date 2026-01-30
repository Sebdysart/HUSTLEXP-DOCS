# PER-1: PROOF-OF-EXISTENCE GATE

**STATUS: MANDATORY PRE-EXECUTION CHECK**
**GATE TYPE: HARD**
**PURPOSE: AI cannot reference what it cannot prove exists**

---

## THE RULE

> AI may not reference anything it cannot prove exists.
> If you cannot quote the file path, line number, or document section, you cannot reference it.
> "I assume" is not proof. "I found" is proof.

---

## REQUIRED CONFIRMATIONS

Before ANY action that references code, schema, or specifications:

### 1. File Path Confirmation

**Before:**
> "I'll modify src/services/EscrowService.ts"

**Must Do:**
- Verify file exists using Read tool or Glob
- Quote exact file path from verification

**If Not Exists:**
- STOP
- State: "File not found at path: [path]"
- Ask user if file should be created

**Example:**
```
✅ CORRECT: "I verified EscrowService exists at backend/src/services/EscrowService.ts"
❌ WRONG: "I'll modify EscrowService.ts" (no verification)
```

---

### 2. Function Signature Confirmation

**Before:**
> "I'll call processEscrow(escrowId)"

**Must Do:**
- Read target file
- Confirm function exists with that exact signature
- Quote line number where function is defined

**If Not Exists:**
- STOP
- State: "Function not found: [functionName]"
- Ask user for correct function name

**Example:**
```
✅ CORRECT: "processEscrow(escrowId: string) exists at EscrowService.ts:47"
❌ WRONG: "I'll call processEscrow()" (no verification of signature)
```

---

### 3. Schema Confirmation

**Before:**
> "I'll update the escrows table"

**Must Do:**
- Read `specs/02-architecture/schema.sql`
- Confirm table exists
- Confirm columns exist with correct types
- Quote line numbers

**If Not Exists:**
- STOP
- State: "Table/column not found in schema.sql"
- Ask user if schema needs updating

**Example:**
```
✅ CORRECT: "escrows table exists at schema.sql L234, has columns: id, task_id, amount, state"
❌ WRONG: "I'll add a row to escrows" (no schema verification)
```

---

### 4. Enum/Constant Confirmation

**Before:**
> "I'll use TaskState.COMPLETED"

**Must Do:**
- Find enum definition in codebase
- Verify value exists in enum
- Quote file path and line number

**If Not Exists:**
- STOP
- State: "Enum value not found: [enumName].[value]"
- Ask user for correct value

**Example:**
```
✅ CORRECT: "TaskState.COMPLETED exists in types/task.ts:12"
❌ WRONG: "I'll set state to COMPLETED" (no enum verification)
```

---

### 5. Screen/Component Confirmation

**Before:**
> "I'll implement TaskFeedScreen"

**Must Do:**
- Check `screens-spec/SCREEN_REGISTRY.md`
- Verify screen is registered
- Quote screen ID and section

**If Not Exists:**
- STOP
- State: "Screen not in SCREEN_REGISTRY.md"
- Screen CANNOT be created without approval

**Example:**
```
✅ CORRECT: "TaskFeedScreen is registered as H2 in SCREEN_REGISTRY.md §3.2"
❌ WRONG: "I'll create a new feed screen" (not in registry)
```

---

### 6. Invariant Confirmation

**Before:**
> "This maintains INV-3"

**Must Do:**
- Check `PER/INVARIANTS.md`
- Verify invariant ID exists
- Quote the full invariant rule

**If Not Exists:**
- STOP
- State: "Invariant ID not found in INVARIANTS.md"
- Invariant reference is invalid

**Example:**
```
✅ CORRECT: "INV-3: COMPLETED task requires ACCEPTED proof (HX301)"
❌ WRONG: "This doesn't violate any invariants" (no specific check)
```

---

### 7. Spec Section Confirmation

**Before:**
> "Per PRODUCT_SPEC §5..."

**Must Do:**
- Read the specific section
- Verify section exists
- Quote relevant content

**If Not Exists:**
- STOP
- State: "Section not found in [document]"
- Reference is invalid

**Example:**
```
✅ CORRECT: "PRODUCT_SPEC §5.3 states: 'XP is permanent once awarded'"
❌ WRONG: "According to the spec..." (no section reference)
```

---

## EXISTENCE CHECK COMMANDS

### For Claude Code (Backend)

| Need to verify... | Command |
|-------------------|---------|
| File exists | `Read` tool or `Glob` pattern |
| Schema exists | Read `specs/02-architecture/schema.sql` |
| Invariant exists | Read `PER/INVARIANTS.md` |
| Service exists | `Glob backend/src/services/*.ts` |
| Endpoint exists | Read `backend/src/routers/*.ts` |
| Type exists | Read `src/types/*.ts` |

### For Cursor (Frontend)

| Need to verify... | Command |
|-------------------|---------|
| Screen exists | Read `screens-spec/SCREEN_REGISTRY.md` |
| Component exists | `Glob reference/components/*.tsx` |
| Token exists | Read `reference/constants/*.ts` |
| Props interface | Read screen spec file |
| Stitch exists | `Glob specs/03-frontend/stitch-prompts/*.md` |

---

## ENFORCEMENT

If existence cannot be proven:

1. **STOP immediately**
2. **State what cannot be verified**
3. **State where you looked**
4. **Ask user for clarification**
5. **DO NOT proceed with assumptions**

---

## ANTI-PATTERNS

These phrases indicate PER-1 violation:

```
❌ "I assume the UserService exists..."
❌ "The escrows table probably has a refund_amount column..."
❌ "TaskState likely includes CANCELLED..."
❌ "There should be a shared Button component..."
❌ "Based on typical patterns..."
❌ "Usually this would be..."
❌ "I'll create this if it doesn't exist..."
```

---

## REQUIRED PATTERNS

These phrases indicate PER-1 compliance:

```
✅ "I verified UserService exists at backend/src/services/UserService.ts"
✅ "I confirmed escrows table has refund_amount column in schema.sql L266"
✅ "TaskState includes CANCELLED per types/task.ts L12"
✅ "PrimaryActionButton exists at reference/components/PrimaryActionButton.tsx"
✅ "INV-3 is defined in PER/INVARIANTS.md as: [quote]"
✅ "PRODUCT_SPEC §5.3 states: [quote]"
```

---

## HALLUCINATION PREVENTION

PER-1 prevents these hallucinations:

| Hallucination | PER-1 Check |
|--------------|-------------|
| Inventing file paths | Must verify file exists |
| Inventing function signatures | Must find exact signature |
| Inventing database columns | Must check schema.sql |
| Inventing enum values | Must find enum definition |
| Inventing screen names | Must check SCREEN_REGISTRY |
| Inventing invariant IDs | Must check INVARIANTS.md |
| Misquoting spec sections | Must read actual section |

---

## WHY THIS MATTERS

**Without PER-1:**
- AI invents files that don't exist
- AI references functions with wrong signatures
- AI assumes database columns exist
- AI quotes specs inaccurately
- Hallucinations become code
- Code breaks on first run

**With PER-1:**
- Every reference is verified
- Hallucinations are caught at planning
- Code compiles on first try
- Specs are quoted accurately
- No "it should work" — it DOES work

---

**If you can't prove it exists, you can't use it.**
**Proof is a file path, line number, or document quote.**
**"I assume" is not proof.**
