# HUSTLEXP-DOCS Deep Audit — February 2026

**Auditor:** Claude (automated cross-reference analysis)
**Scope:** Full repository integrity, cross-file consistency, gap analysis
**Date:** 2026-02-05

---

## Executive Summary

The repo is **structurally solid** with strong invariant documentation and state machine coverage. The previous P0/P1 fixes from the build readiness audit are holding. However, this deeper audit uncovered **3 P0 issues**, **6 P1 issues**, and **5 P2 issues** across cross-reference consistency, API coverage gaps, and repo hygiene.

---

## P0 — Critical (Will Break Build)

### P0-1: Proof State Enum Mismatch (API_CONTRACT vs Schema)

**Files:** `API_CONTRACT.md` ProofState type vs `schema.sql` proofs.state CHECK
**Problem:** API_CONTRACT defines 5 proof states:
```
PENDING | SUBMITTED | ACCEPTED | REJECTED | EXPIRED
```
Schema defines **10 proof states** (Judge Agent pipeline):
```
PENDING | SUBMITTED | ANALYZING | PASS | FAIL | UNCERTAIN | ACCEPTED | REJECTED | MANUAL_REVIEW | EXPIRED
```
**Impact:** Backend service implementing API_CONTRACT will reject valid proof records in `ANALYZING`, `PASS`, `FAIL`, `UNCERTAIN`, or `MANUAL_REVIEW` states. Any frontend polling proof status will not handle these states.
**Fix:** Update API_CONTRACT ProofState enum to include all 10 schema states, OR add a derivation note (like the dispute fix) explaining which states the API collapses/hides.

### P0-2: EN_ROUTE Referenced But Not a Task State

**Files:** `PRODUCT_SPEC.md` §21.4, §21.5 vs `schema.sql` tasks.state CHECK
**Problem:** PRODUCT_SPEC references `EN_ROUTE` as a task concept:
- "worker does not transition to EN_ROUTE within the acceptance window"
- "Poster Late Cancel After Acceptance (worker already EN_ROUTE)"

But `EN_ROUTE` is **not** in the schema task states: `OPEN | ACCEPTED | PROOF_SUBMITTED | DISPUTED | COMPLETED | CANCELLED | EXPIRED`.
**Impact:** Background job checking "transition to EN_ROUTE" has no state to check. Cancellation penalty logic referencing EN_ROUTE will fail.
**Fix:** Either add EN_ROUTE as a formal task state (between ACCEPTED and PROOF_SUBMITTED), OR clarify that EN_ROUTE is a **live_mode_state** / location flag rather than a task state, and rewrite the guards accordingly.

### P0-3: Error Codes in Schema with No API_CONTRACT Mapping

**Files:** `schema.sql` vs `API_CONTRACT.md`
**Problem:** 7 error codes are raised by schema triggers/constraints but have **no entry** in API_CONTRACT's error code table:
- `HX601` — Fatigue mandatory break bypass
- `HX602` — Pause state violation
- `HX603` — Poster reputation access violation
- `HX604` — Percentile public exposure attempt
- `HX903` — Hustler not in ACTIVE live mode state
- `HX904` — Live Mode toggle cooldown violation
- `HX905` — Live Mode banned

**Impact:** When these triggers fire, the API layer has no defined error response to return to the client. Frontend error handling will show generic errors.
**Fix:** Add all 7 codes to API_CONTRACT error code table with descriptions and HTTP status codes.

---

## P1 — Important (Won't crash, but will cause bugs or confusion)

### P1-1: Referral Tables Missing from Main Schema

**Files:** `REFERRAL_SYSTEM_SPEC.md` §5 vs `schema.sql`
**Problem:** REFERRAL_SYSTEM_SPEC defines `referrals` and `referral_credits` tables, but they do **not exist** in `schema.sql`. No migration file creates them either.
**Fix:** Add referral tables to schema.sql or create migration `008_referral_system.sql`.

### P1-2: Error Code Divergence Between PRODUCT_SPEC and ERROR_CODES.md

**Files:** `PRODUCT_SPEC.md` §19 vs `ERROR_CODES.md`
**Problem:** 9 error codes exist in PRODUCT_SPEC but NOT in ERROR_CODES.md:
`HX605, HX606, HX607, HX608, HX609, HX911, HX912, HX913, HX914`

18 error codes exist in ERROR_CODES.md but NOT in PRODUCT_SPEC:
`HX003, HX005, HX006, HX099, HX199, HX299, HX305, HX399, HX499, HX502-505, HX599, HX699, HX799, HX899, HX999`

**Impact:** Developers will get conflicting information depending on which file they consult.
**Fix:** Reconcile both files. ERROR_CODES.md should be the single canonical error code registry, with PRODUCT_SPEC referencing it rather than maintaining its own list.

### P1-3: Saved Searches + Task Drafts — No API Endpoints

**Files:** `schema.sql` (saved_searches, user_task_drafts tables) vs `API_CONTRACT.md`
**Problem:** Both tables exist in schema but have **zero** API endpoints defined. Task drafts have spatial columns from migration 005.
**Fix:** Add CRUD endpoints for both, or explicitly mark them as "internal/Phase 2" in API_CONTRACT with a note.

### P1-4: PRODUCT_SPEC §6 (Proof System) Missing Judge Agent States

**Files:** `PRODUCT_SPEC.md` §6.1 vs `schema.sql` proofs table
**Problem:** PRODUCT_SPEC §6.1 lists only 5 proof states. The schema has 10 states supporting the Judge Agent AI pipeline (ANALYZING, PASS, FAIL, UNCERTAIN, MANUAL_REVIEW). The PRODUCT_SPEC has no section explaining:
- How Judge Agent integrates with the proof lifecycle
- Multi-sig (poster response) window rules
- Auto-release logic
- Max 3 attempt tracking

The `JUDGE_AGENT_SPEC_LOCKED.md` subsystem exists but PRODUCT_SPEC §6 doesn't reference it.
**Fix:** Add §6.x subsection to PRODUCT_SPEC cross-referencing the Judge Agent pipeline or expand the state table.

### P1-5: API_CONTRACT Version Notes Mention Features Without Endpoint Specs

**Files:** `API_CONTRACT.md` version history vs actual endpoints
**Problem:** Version 1.5.0 notes mention `user.block/unblock` — these endpoints DO exist in the contract. However:
- No `savedSearch.create/list/delete` endpoints
- No `taskDraft.save/get/delete` endpoints
- No `referral.create/getCode/getStatus` endpoints

These features have schema tables but no API surface.
**Fix:** Either add endpoint stubs with "Phase 2" markers or add them to a Phase 2 backlog doc.

### P1-6: Proof Photo Triggers Use Plain RAISE (No Error Code)

**Files:** `schema.sql` lines 485, 510
**Problem:** `enforce_proof_photo_limit()` and `enforce_proof_photo_minimum()` triggers raise exceptions without HX error codes:
```sql
RAISE EXCEPTION 'Maximum 5 photos per proof (PROOF-PHOTO-1)';
RAISE EXCEPTION 'Minimum 1 photo required per proof (PROOF-PHOTO-2)';
```
All other triggers use `USING ERRCODE = 'HXnnn'` format.
**Fix:** Assign proper HX codes (e.g., HX302-range or a new photo range) for consistency.

---

## P2 — Polish (Won't cause bugs, but weakens documentation quality)

### P2-1: 409M ios/ Directory in Docs Repo (Local Bloat)

The `ios/` directory (409MB) exists locally with Pods, build artifacts, etc. It's gitignored and not tracked, but its presence in a docs repo is confusing for anyone cloning/working locally.

### P2-2: Root-Level Spec Files vs /specs/ Organization

Files like `SCREEN_ARCHETYPES.md`, `UI_COMPONENT_HIERARCHY.md`, `AI_CHECKPOINTS.md`, `BOOTSTRAP.md`, etc. live at the repo root rather than in `specs/`. The `specs/` directory is well-organized (00-overview through 04-backend) but ~25 spec-adjacent files at root create navigation confusion.

### P2-3: TRIGGERS_AND_CONSTRAINTS.sql May Be Stale

`specs/04-backend/TRIGGERS_AND_CONSTRAINTS.sql` (856 lines) exists alongside `schema.sql` (2708 lines). If TRIGGERS_AND_CONSTRAINTS.sql was a pre-consolidation artifact, it may contain stale trigger definitions that contradict the canonical schema.sql.

### P2-4: Mock Data May Not Reflect Schema Changes

`mock-data/*.js` files (12 files) haven't been audited against the 42-gap audit schema additions. Fields like `cancellation_count`, `no_show_count`, `phone`, spatial columns, and capability system tables may not have mock data.

### P2-5: UAP Status All "PENDING" in SCREEN_REGISTRY

All 42+ screens show `UAP Status: PENDING` in `screens-spec/SCREEN_REGISTRY.md`. If any screens have actually been verified, the registry is stale.

---

## Summary Matrix

| Priority | Count | Est. Fix Time |
|----------|-------|---------------|
| P0 | 3 | ~30 min |
| P1 | 6 | ~45 min |
| P2 | 5 | ~30 min |
| **Total** | **14** | **~1h 45m** |

---

## What's Strong

- **State machines** (task, escrow) are perfectly aligned across all 3 backbone files
- **Core invariant chain** (INV-1 through INV-5) is bulletproof with trigger enforcement
- **Subsystem architecture** with 15 locked specs provides clear Phase 2 boundaries
- **Stitch prompt coverage** at 43 screen-level prompts is comprehensive
- **Error code framework** exists with range allocation — just needs reconciliation
- **Migration history** is clean and sequential (002 through 007 + eligibility)
- **Build guide** has proper phased gates with verification queries
