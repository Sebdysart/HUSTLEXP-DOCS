# FEATURE FREEZE — HUSTLEXP v1.0

**STATUS: ACTIVE — No new features without explicit approval**  
**Effective: January 2025**

---

## THE RULE

> **No new features may be added to HustleXP v1.0 without modifying FINISHED_STATE.md.**

This is not a guideline. This is law.

---

## WHAT "FROZEN" MEANS

### Frozen artifacts:
- `FINISHED_STATE.md` — The product definition
- `screens-spec/SCREEN_REGISTRY.md` — The 38 screens
- `specs/02-architecture/schema.sql` — The 32 tables + 4 views

### Frozen counts:
- **38 screens** — No new screens
- **32 tables** — No new tables
- **5 invariants** — No new invariants
- **12 onboarding screens** — No new onboarding steps

---

## WHAT IS ALLOWED

✅ **Bug fixes** — Fixing broken behavior  
✅ **Implementation** — Building what's already defined  
✅ **Refinement** — Improving UX within existing screens  
✅ **Performance** — Making existing features faster  
✅ **Testing** — Adding tests for existing features  

---

## WHAT IS NOT ALLOWED

❌ **New screens** — Unless SCREEN_REGISTRY.md is updated first  
❌ **New features** — Unless FINISHED_STATE.md is updated first  
❌ **New tables** — Unless schema.sql is updated first  
❌ **"Improvements"** — Unless explicitly requested by user  
❌ **"Nice to have"** — Deferred to v2  
❌ **"While we're at it"** — No scope creep  

---

## THE APPROVAL PROCESS

To add a feature to v1.0:

1. **User explicitly requests it** (not AI suggestion)
2. **FINISHED_STATE.md is updated** (feature added to checklist)
3. **SCREEN_REGISTRY.md is updated** (if new screens needed)
4. **schema.sql is updated** (if new tables needed)
5. **ONLY THEN** may implementation begin

AI tools (Claude Code, Cursor) **may not suggest or implement** features not in FINISHED_STATE.md.

---

## EXPLICITLY DEFERRED TO v2

These features are **acknowledged** but **not v1**:

| Feature | Why Deferred |
|---------|--------------|
| AI task suggestions | Complexity, not core |
| Smart pricing | Requires market data |
| Gamified streaks | Polish, not core |
| Text reviews | Ratings sufficient for v1 |
| Tipping | Complicates escrow |
| Recurring tasks | Edge cases |
| Team tasks | Coordination complexity |
| Bidding system | Changes marketplace model |
| Video proof | Storage/bandwidth |
| Voice messages | Complexity |
| Analytics dashboard | Polish, not core |
| Referral system | Growth, not core |
| Loyalty program | Retention, not core |

**These are not forgotten. They are intentionally excluded from v1.**

---

## TASK POSTING GATE (Critical)

> "Tasks may not be posted unless all execution-clarity requirements are satisfied.
> AI assistance exists to help users meet these requirements, not to bypass them."

See:
- `TASK_EXECUTION_REQUIREMENTS.md` — Required fields per category
- `TASK_CLARIFICATION_QUESTION_BANK.md` — Static question banks
- `TASK_CREATION_STATE_MACHINE.md` — DRAFT → CLARIFYING → READY → POSTED

**No skip paths. No "post anyway." No admin override for incomplete tasks.**

---

## ENFORCEMENT

### For Claude Code:
```
IF feature_not_in_FINISHED_STATE:
    STOP
    TELL USER: "This feature is not in FINISHED_STATE.md"
    DO NOT IMPLEMENT
```

### For Cursor:
```
IF screen_not_in_SCREEN_REGISTRY:
    STOP
    TELL USER: "This screen is not in SCREEN_REGISTRY.md"
    DO NOT CREATE
```

### For Both:
```
IF user_suggests_new_feature:
    ASK: "Should I add this to FINISHED_STATE.md first?"
    WAIT for explicit approval
    UPDATE docs BEFORE implementing
```

---

## WHY THIS EXISTS

Without a feature freeze:
- AI invents features endlessly
- Scope creeps invisibly
- "Done" never arrives
- You become the glue between tools

With a feature freeze:
- "Done" is defined
- AI executes, doesn't design
- Scope is visible
- You manage, not glue

---

## VIOLATIONS

If you notice:
- A screen that doesn't exist in SCREEN_REGISTRY
- A feature that doesn't exist in FINISHED_STATE
- A table that doesn't exist in schema.sql

**STOP. Report it. Do not continue.**

This is how we prevent drift.

---

**The freeze is active. Build what's defined. Nothing more.**
