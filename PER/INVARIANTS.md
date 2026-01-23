# INVARIANTS REGISTRY — HUSTLEXP v1.0

**STATUS: CONSTITUTIONAL — VIOLATIONS ARE SYSTEM FAILURES**
**PURPOSE: Single source of truth for all invariants**
**ENFORCEMENT: Database triggers + code review + kill tests**

---

## THE RULE

> Every invariant in this document is mechanically enforced.
> If an invariant can be violated, it is not an invariant — it is a suggestion.
> This document contains no suggestions.

---

## INVARIANT CATEGORIES

| Category | Count | Source |
|----------|-------|--------|
| Core Financial | 5 | PRODUCT_SPEC §2, schema.sql |
| Eligibility | 8 | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |
| Architectural | 4 | ARCHITECTURE.md §9.1 |
| Data Flow | 4 | ARCHITECTURE.md §9.2 |
| Audit | 5 | ARCHITECTURE.md §9.3 |
| Live Mode | 7 | ARCHITECTURE.md §10.3 |
| **Total** | **33** | — |

---

## CORE FINANCIAL INVARIANTS (INV-1 through INV-5)

These invariants protect the money chain. Violation = economic corruption.

### INV-1: XP Requires RELEASED Escrow

| Aspect | Value |
|--------|-------|
| **Rule** | XP can only be awarded when escrow state = RELEASED |
| **Error Code** | HX101 |
| **Trigger** | `xp_requires_released_escrow` |
| **Function** | `enforce_xp_requires_released_escrow()` |
| **Location** | schema.sql L509 (function), L534 (trigger) |
| **Source** | PRODUCT_SPEC §2 |

**Enforcement:**
```sql
CREATE TRIGGER xp_requires_released_escrow
BEFORE INSERT ON xp_ledger
FOR EACH ROW
EXECUTE FUNCTION check_escrow_released();
-- Raises HX101 if escrow.state != 'RELEASED'
```

**Kill Test:**
```typescript
it('MUST REJECT XP award when escrow not released', async () => {
  await expect(awardXP({ escrowId: 'pending-escrow' }))
    .rejects.toThrow('HX101');
});
```

---

### INV-2: RELEASED Escrow Requires COMPLETED Task

| Aspect | Value |
|--------|-------|
| **Rule** | Escrow can only be released when task state = COMPLETED |
| **Error Code** | HX201 |
| **Trigger** | `escrow_released_requires_completed_task` |
| **Location** | schema.sql L1060 |
| **Source** | PRODUCT_SPEC §2 |

**Enforcement:**
```sql
CREATE TRIGGER escrow_released_requires_completed_task
BEFORE UPDATE ON escrows
FOR EACH ROW
WHEN (NEW.state = 'RELEASED')
EXECUTE FUNCTION check_task_completed();
-- Raises HX201 if task.state != 'COMPLETED'
```

**Kill Test:**
```typescript
it('MUST REJECT escrow release when task not completed', async () => {
  await expect(releaseEscrow({ escrowId: 'escrow-with-pending-task' }))
    .rejects.toThrow('HX201');
});
```

---

### INV-3: COMPLETED Task Requires ACCEPTED Proof

| Aspect | Value |
|--------|-------|
| **Rule** | Task can only be completed when proof status = ACCEPTED |
| **Error Code** | HX301 |
| **Trigger** | `task_completed_requires_accepted_proof` |
| **Location** | schema.sql L1103 |
| **Source** | PRODUCT_SPEC §2 |

**Enforcement:**
```sql
CREATE TRIGGER task_completed_requires_accepted_proof
BEFORE UPDATE ON tasks
FOR EACH ROW
WHEN (NEW.state = 'COMPLETED')
EXECUTE FUNCTION check_proof_accepted();
-- Raises HX301 if no proof with status = 'ACCEPTED'
```

**Kill Test:**
```typescript
it('MUST REJECT task completion when proof not accepted', async () => {
  await expect(completeTask({ taskId: 'task-with-pending-proof' }))
    .rejects.toThrow('HX301');
});
```

---

### INV-4: Escrow Amount Is IMMUTABLE

| Aspect | Value |
|--------|-------|
| **Rule** | Once escrow is created, amount cannot be changed |
| **Error Code** | HX401 |
| **Trigger** | `escrow_amount_immutable` |
| **Location** | schema.sql L333 |
| **Source** | PRODUCT_SPEC §2 |

**Enforcement:**
```sql
CREATE TRIGGER escrow_amount_immutable
BEFORE UPDATE ON escrows
FOR EACH ROW
WHEN (OLD.amount != NEW.amount)
EXECUTE FUNCTION reject_amount_change();
-- Raises HX401 unconditionally
```

**Kill Test:**
```typescript
it('MUST REJECT escrow amount modification', async () => {
  await expect(
    db.escrows.update({ id: escrowId, amount: 0 })
  ).rejects.toThrow('HX401');
});
```

---

### INV-5: One XP Entry Per Escrow

| Aspect | Value |
|--------|-------|
| **Rule** | Each escrow can only generate one XP ledger entry |
| **Error Code** | HX501 |
| **Constraint** | UNIQUE constraint on `xp_ledger.escrow_id` |
| **Location** | schema.sql L495 |
| **Source** | PRODUCT_SPEC §2 |

**Enforcement:**
```sql
ALTER TABLE xp_ledger
ADD CONSTRAINT xp_ledger_escrow_unique
UNIQUE (escrow_id);
-- Raises HX501 on duplicate insert
```

**Kill Test:**
```typescript
it('MUST REJECT duplicate XP award for same escrow', async () => {
  await awardXP({ escrowId }); // First award succeeds
  await expect(awardXP({ escrowId }))
    .rejects.toThrow('HX501'); // Duplicate fails
});
```

---

## THE CHAIN

These five invariants form an unbreakable chain:

```
Task Created → Escrow Funded → Work Done → Proof Accepted → Escrow Released → XP Awarded

   INV-3: Cannot complete without accepted proof
           ↓
   INV-2: Cannot release without completed task
           ↓
   INV-1: Cannot award XP without released escrow
           ↓
   INV-5: Cannot award XP twice for same escrow
           ↓
   INV-4: Cannot modify escrow amount at any point
```

**Every arrow is enforced by database triggers. You cannot skip steps.**

---

## ELIGIBILITY INVARIANTS (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8)

These invariants protect the trust and verification system.

### INV-ELIGIBILITY-1: Trust Tier → Risk Clearance Mapping Is Immutable

| Aspect | Value |
|--------|-------|
| **Rule** | Trust tier determines risk clearance via fixed mapping |
| **Enforcement** | DB CHECK constraint |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

**Mapping (Fixed):**
| Trust Tier | Risk Clearance |
|------------|----------------|
| 1 (ROOKIE) | LOW |
| 2 (VERIFIED) | MEDIUM |
| 3 (TRUSTED) | HIGH |
| 4 (ELITE) | CRITICAL |

---

### INV-ELIGIBILITY-2: Verified Trades Must Have Active Verification

| Aspect | Value |
|--------|-------|
| **Rule** | A trade can only appear in `verified_trades` if verification is active and not expired |
| **Enforcement** | FK constraint + recomputation logic |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-3: Expired Credentials Invalidate Capabilities

| Aspect | Value |
|--------|-------|
| **Rule** | When a credential expires, associated capabilities are removed via recomputation |
| **Enforcement** | Cron job + recompute trigger |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-4: Insurance Validity Gated by Verification

| Aspect | Value |
|--------|-------|
| **Rule** | `insurance_valid` can only be TRUE if insurance_verification.status = 'verified' AND not expired |
| **Enforcement** | Recomputation logic |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-5: Background Check Validity Gated by Verification

| Aspect | Value |
|--------|-------|
| **Rule** | `background_check_valid` can only be TRUE if background_check.status = 'verified' AND not expired |
| **Enforcement** | Recomputation logic |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-6: Location State Must Be Valid US State Code

| Aspect | Value |
|--------|-------|
| **Rule** | `location_state` must be a valid 2-letter US state code |
| **Enforcement** | DB CHECK constraint |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-7: Willingness Flags Cannot Override Eligibility

| Aspect | Value |
|--------|-------|
| **Rule** | User preferences (willingness) cannot grant eligibility — only filter within eligible set |
| **Enforcement** | Feed query logic (SQL WHERE clause) |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md |

---

### INV-ELIGIBILITY-8: Capability Profile Is Never Mutated Directly

| Aspect | Value |
|--------|-------|
| **Rule** | Capability profile is always re-derived from verification records, never edited directly |
| **Enforcement** | Application logic + trigger preventing direct mutation |
| **Location** | CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md, ARCHITECTURE.md §11 |

---

## ARCHITECTURAL INVARIANTS (ARCH-1 through ARCH-4)

These invariants enforce the 7-layer hierarchy.

### ARCH-1: Layer N Cannot Bypass Layer N-1

| Aspect | Value |
|--------|-------|
| **Rule** | Each layer must go through the layer directly below it |
| **Enforcement** | Code review, no direct DB access from UI |
| **Location** | ARCHITECTURE.md §9.1 |

**Examples:**
- UI (Layer 5) cannot call DB (Layer 0) directly
- Frontend Logic (Layer 4) cannot bypass API (Layer 2)
- AI (Layer 3) cannot bypass Backend Services (Layer 1)

---

### ARCH-2: Only Layer 0 Can Enforce Invariants

| Aspect | Value |
|--------|-------|
| **Rule** | All invariants are enforced by database triggers/constraints |
| **Enforcement** | Triggers in schema.sql |
| **Location** | ARCHITECTURE.md §9.1 |

**Implication:** Application code may validate, but database enforces. If database doesn't reject invalid state, validation doesn't count.

---

### ARCH-3: AI (Layer 3) Cannot Write to Layer 0

| Aspect | Value |
|--------|-------|
| **Rule** | AI services have no database write credentials |
| **Enforcement** | No DB credentials for AI services |
| **Location** | ARCHITECTURE.md §9.1 |

**AI is A0/A1/A2/A3 authority only:**
- A0: Cannot access (money, core state)
- A1: Read-only
- A2: Propose only
- A3: Auto-execute only for low-stakes, high-confidence

---

### ARCH-4: UI (Layer 5) Cannot Call Layer 0 Directly

| Aspect | Value |
|--------|-------|
| **Rule** | All UI requests must go through API gateway |
| **Enforcement** | API gateway required |
| **Location** | ARCHITECTURE.md §9.1 |

---

## DATA FLOW INVARIANTS (DATA-1 through DATA-4)

### DATA-1: Authoritative State Flows Down Only

| Aspect | Value |
|--------|-------|
| **Rule** | Layer 0 → 1 → 2 → 4 → 5 (never upward) |
| **Enforcement** | Architecture review |
| **Location** | ARCHITECTURE.md §9.2 |

---

### DATA-2: Requests Flow Up Only

| Aspect | Value |
|--------|-------|
| **Rule** | Layer 5 → 4 → 2 → 1 → 0 (never downward) |
| **Enforcement** | Architecture review |
| **Location** | ARCHITECTURE.md §9.2 |

---

### DATA-3: No Layer Caches Another Layer's Authoritative State

| Aspect | Value |
|--------|-------|
| **Rule** | Caching for display only, never for decisions |
| **Enforcement** | Code review |
| **Location** | ARCHITECTURE.md §9.2 |

---

### DATA-4: All State Changes Are Transactional

| Aspect | Value |
|--------|-------|
| **Rule** | No partial state changes — all or nothing |
| **Enforcement** | DB transactions |
| **Location** | ARCHITECTURE.md §9.2 |

---

## AUDIT INVARIANTS (AUDIT-1 through AUDIT-5)

### AUDIT-1: Every XP Change Creates Ledger Entry

| Aspect | Value |
|--------|-------|
| **Rule** | XP changes only via xp_ledger INSERT |
| **Enforcement** | INV-1, INV-5 |
| **Location** | ARCHITECTURE.md §9.3 |

---

### AUDIT-2: Every Trust Change Creates Ledger Entry

| Aspect | Value |
|--------|-------|
| **Rule** | Trust tier changes logged to trust_ledger |
| **Enforcement** | `trust_tier_audit` trigger |
| **Location** | ARCHITECTURE.md §9.3 |

---

### AUDIT-3: Every Admin Action Creates Audit Entry

| Aspect | Value |
|--------|-------|
| **Rule** | Admin actions logged to admin_actions table |
| **Enforcement** | admin_actions table |
| **Location** | ARCHITECTURE.md §9.3 |

---

### AUDIT-4: Every AI Decision Creates Decision Record

| Aspect | Value |
|--------|-------|
| **Rule** | AI decisions logged to ai_decisions table |
| **Enforcement** | ai_decisions table |
| **Location** | ARCHITECTURE.md §9.3 |

---

### AUDIT-5: Audit Tables Are Append-Only

| Aspect | Value |
|--------|-------|
| **Rule** | No deletes from audit tables |
| **Enforcement** | `*_no_delete` triggers |
| **Location** | ARCHITECTURE.md §9.3 |

**Append-Only Tables:**
- `xp_ledger` — trigger: `xp_ledger_no_delete` (HX102)
- `trust_ledger` — trigger: `trust_ledger_no_delete`
- `admin_actions` — trigger: `admin_actions_no_delete`
- `ai_decisions` — trigger: `ai_decisions_no_delete`
- `badges` — trigger: `badge_no_delete` (HX501)

---

## LIVE MODE INVARIANTS (LIVE-1 through LIVE-7)

### LIVE-1: Live Tasks Require FUNDED Escrow

| Aspect | Value |
|--------|-------|
| **Rule** | Cannot broadcast live task without funded escrow |
| **Error Code** | HX901 |
| **Enforcement** | DB trigger |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.5 |

---

### LIVE-2: Live Tasks Require $15 Minimum

| Aspect | Value |
|--------|-------|
| **Rule** | Live task price must be >= $15 |
| **Error Code** | HX902 |
| **Enforcement** | DB constraint |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.5 |

---

### LIVE-3: Hustlers Must Opt In Explicitly

| Aspect | Value |
|--------|-------|
| **Rule** | Live mode requires explicit hustler toggle |
| **Enforcement** | UI + DB state |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.5 |

---

### LIVE-4: Broadcasts Are Geo-Bounded

| Aspect | Value |
|--------|-------|
| **Rule** | Broadcasts only reach hustlers within radius |
| **Enforcement** | Backend service |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.6 |

---

### LIVE-5: Broadcasts Are Time-Bounded

| Aspect | Value |
|--------|-------|
| **Rule** | Broadcasts expire after TTL |
| **Enforcement** | Backend service |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.6 |

---

### LIVE-6: Session-Based, Not Permanent

| Aspect | Value |
|--------|-------|
| **Rule** | Live mode is session-based availability, not permanent status |
| **Enforcement** | State machine |
| **Location** | ARCHITECTURE.md §10.3, PRODUCT_SPEC §3.5 |

---

### LIVE-7: No Auto-Accept, No AI Decisions

| Aspect | Value |
|--------|-------|
| **Rule** | AI cannot auto-accept tasks for hustlers in live mode |
| **Enforcement** | Constitutional (code review) |
| **Location** | ARCHITECTURE.md §10.3 |

---

## INVARIANT VIOLATION PROTOCOL

When an invariant is violated:

1. **System logs violation** with error code (HX series)
2. **Transaction rolls back** — no partial state
3. **Alert fires** to monitoring
4. **No silent failures** — violation is visible

**Error Code Ranges:**
| Range | Category |
|-------|----------|
| HX101-199 | XP invariants |
| HX201-299 | Escrow invariants |
| HX301-399 | Task/Proof invariants |
| HX401-499 | Immutability invariants |
| HX501-599 | Uniqueness invariants |
| HX901-999 | Live mode invariants |

---

## KILL TEST REQUIREMENTS

Every invariant in this document must have:

1. **At least one kill test** that proves the constraint works
2. **At least one test** that fails if the constraint is removed
3. **Documentation** of what happens when violated

**Minimum Kill Test Count: 24** (across all core financial invariants)

---

## CROSS-REFERENCE MATRIX

| Invariant | PRODUCT_SPEC | schema.sql | ARCHITECTURE.md |
|-----------|--------------|------------|-----------------|
| INV-1 | §2 | L509/L534 | §3.1 |
| INV-2 | §2 | L1060 | §6.4 |
| INV-3 | §2 | L1103 | §3.1 |
| INV-4 | §2 | L333 | §6.5 |
| INV-5 | §2 | L495 | §3.2 |
| ARCH-1 through ARCH-4 | — | — | §9.1 |
| DATA-1 through DATA-4 | — | — | §9.2 |
| AUDIT-1 through AUDIT-5 | — | — | §9.3 |
| LIVE-1 through LIVE-7 | §3.5-3.6 | — | §10.3 |
| INV-ELIGIBILITY-1 through 8 | §17 | — | §11 |

---

**This document is the single source of truth for invariants.**
**If an invariant is not here, it is not an invariant.**
**If it is here, it is non-negotiable.**
