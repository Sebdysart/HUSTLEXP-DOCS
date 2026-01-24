# COMPLETION LOCK — PROTECT FINISHED WORK

**STATUS: CONSTITUTIONAL**
**PURPOSE: Prevent degradation of completed work**
**RULE: DONE items are immutable without explicit unlock**

---

## WHY THIS EXISTS

Even with DONE_DEFINITION, AI may:
- Re-open completed work
- "Improve" finished surfaces
- Accidentally degrade quality
- Refactor working code

This document protects max-tier output from erosion.

---

## THE RULE

> **If an item is marked DONE:**
>
> - It is **IMMUTABLE**
> - Changes require **explicit unlock**
> - Unlock requires **reason + approval**
> - AI may NOT refactor or restyle DONE work

---

## WHAT "DONE" MEANS

An item is DONE when:

1. All checkboxes in DONE_DEFINITION.md are checked
2. User has confirmed completion
3. Work has been committed

Once DONE, the item enters COMPLETION LOCK.

---

## COMPLETION LOCK STATES

### LOCKED (Default for DONE items)

```
State: LOCKED
Meaning: No modifications allowed
AI May: Read, reference, but not edit
User May: Request unlock
```

### UNLOCKED (Requires explicit action)

```
State: UNLOCKED
Meaning: Modifications allowed with reason
AI May: Make approved changes
Duration: Until re-locked
```

### RE-LOCKED (After modification)

```
State: RE-LOCKED
Meaning: New work is now protected
Requires: New DONE verification
```

---

## LOCK REGISTRY

### Currently LOCKED Items

| Item | Locked Date | Commit | Status |
|------|-------------|--------|--------|
| (none yet) | — | — | — |

*Items are added here when they achieve DONE status.*

### Example Entry (When Bootstrap Passes)

```
| EntryScreen (Bootstrap) | 2026-01-XX | abc123 | LOCKED |
```

---

## UNLOCK PROTOCOL

To unlock a DONE item:

### Step 1: Request Unlock

User must explicitly say:
- "Unlock [item] for [reason]"
- Example: "Unlock EntryScreen to change button copy"

### Step 2: Document Reason

```
UNLOCK REQUEST:
Item: EntryScreen
Reason: Change CTA button text from "Get Started" to "Start Now"
Scope: Only button text, no other changes
Requested by: User
Date: 2026-01-XX
```

### Step 3: AI Confirms Scope

AI must confirm:
- What will change
- What will NOT change
- Estimated impact

### Step 4: Make Minimal Change

- Only change what was unlocked
- Do not "improve" other parts
- Do not refactor
- Do not add features

### Step 5: Re-Lock

After change is complete:
- Verify DONE_DEFINITION still passes
- Re-lock the item
- Update Lock Registry

---

## PROHIBITED ACTIONS ON LOCKED ITEMS

### ❌ FORBIDDEN: Unsolicited Improvements

```
"While I'm here, let me also clean up this code..."
→ FORBIDDEN on locked items
```

### ❌ FORBIDDEN: Refactoring

```
"I noticed this could be more efficient..."
→ FORBIDDEN on locked items
```

### ❌ FORBIDDEN: Styling Changes

```
"Let me adjust these margins slightly..."
→ FORBIDDEN on locked items
```

### ❌ FORBIDDEN: "Bug Fixes" Without Proof

```
"This looks like a bug, let me fix it..."
→ FORBIDDEN unless bug is verified and unlock is granted
```

---

## WHAT AI CAN DO WITH LOCKED ITEMS

### ✅ ALLOWED: Read and Reference

```
"Looking at EntryScreen.tsx for the correct pattern..."
→ ALLOWED
```

### ✅ ALLOWED: Copy Patterns

```
"Using the same gradient treatment from EntryScreen..."
→ ALLOWED
```

### ✅ ALLOWED: Report Issues

```
"I noticed a potential issue in the locked EntryScreen:
[description]. Would you like to unlock it for review?"
→ ALLOWED (reporting, not fixing)
```

---

## LOCK VERIFICATION

Before modifying any file, AI must check:

```
1. Is this file part of a DONE item?
   YES → Check Lock Registry
   NO  → Proceed normally

2. Is the item LOCKED?
   YES → STOP, request unlock
   NO  → Proceed with modification

3. Does modification exceed unlock scope?
   YES → STOP, request expanded scope
   NO  → Proceed with modification
```

---

## EXCEPTION: Critical Bug

If a locked item has a **critical bug** (crashes, security issue):

1. Report the bug to user
2. Request emergency unlock
3. User grants emergency unlock
4. Fix ONLY the critical bug
5. Re-lock immediately

```
EMERGENCY UNLOCK:
Item: EntryScreen
Reason: App crashes on button press (null pointer)
Scope: Fix crash only
Duration: Until fix verified
```

---

## THE PROTECTION GUARANTEE

This document guarantees:

1. **No quality erosion** — DONE work stays DONE
2. **No scope creep** — Changes are minimal and approved
3. **No accidental damage** — Locked items are safe
4. **Audit trail** — All unlocks are documented

---

## PRACTICAL WORKFLOW

### When Building New Work

1. Build to DONE_DEFINITION standard
2. Verify all checkboxes
3. Get user confirmation
4. Commit work
5. Add to Lock Registry
6. Item is now protected

### When Modifying Existing Work

1. Check Lock Registry
2. If LOCKED → Request unlock
3. If UNLOCKED → Make approved change
4. Verify DONE_DEFINITION still passes
5. Re-lock

---

**DONE is not a suggestion. DONE is a lock.**
**Locked items are immutable without explicit approval.**
