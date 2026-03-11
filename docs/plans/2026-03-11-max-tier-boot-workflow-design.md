# Max-Tier Phased Boot Workflow — Design Document

**Status:** ACTIVE — Constitutional authority for all Claude Code + omni-link sessions
**Version:** 1.0.0
**Date:** 2026-03-11
**Operational Reference:** `/Users/sebastiandysart/omni-link-hustlexp/WORKFLOW.md`
**Audience:** Human (audit) + Claude Code (execution)

---

## Purpose

Every Claude Code session operating on the HustleXP ecosystem must boot from a known, verified state before doing any work. Without a structured boot, Claude may act on a stale digest, ignore failing tests, misclassify irreducible drift as blocking, or apply changes against an incorrect health baseline.

This document defines the canonical boot protocol: a 4-phase, zero-improvisation sequence that maps every possible ecosystem state to a deterministic action plan. No undefined forks. No abstract function calls. Every path pre-labeled, pre-scripted, pre-verified.

---

## Architecture

### Why Phased Boot vs. Linear Checklist

The existing PER system uses linear checklists because Cursor's frontend tasks are largely sequential: does a screen exist? build it. The omni-link backend workflow has real branching logic:

- Digest can be fresh or stale → different actions
- Tests can be passing or failing → different actions
- Drift can be blocking (real mismatches) or informational (irreducible type-repr) → completely different responses
- Health gap can be 5, 11, or 21 points → different remediation tiers

A linear checklist forces improvisation at every branch. A phased decision tree pre-answers every question before it occurs.

### Why Decision Trees vs. State Machine

State machines are precise but hard to audit. A human reviewing Claude's behavior cannot easily trace "why did Claude take action X?" through a state transition table. Decision trees produce a readable path: PHASE 2 → step 3 → severity=blocking → EXIT-ASSESS-DRIFT-BLOCKING → PHASE 3 → action plan → PHASE 4.

### Zero-Improvisation Mandate

Claude must not reason about what to do. Claude must look up what to do. Every scenario is pre-mapped. If a scenario is not in the tree, the exit is always: surface to human, do not act.

---

## Grounding Decisions (4 Resolved Gaps)

These are the specific design choices made to prevent silent failure against the real HustleXP/omni-link stack:

### Gap 1: Composite Snapshot

The snapshot is not a single CLI output. It is assembled from 4 sources in sequence:

| Field Group | Source |
|---|---|
| `digest.*` | omni-link session-start inject (already in context) |
| `tests.*` | `coverage/coverage-summary.json` or fresh `npx vitest run --coverage` |
| `drift.*` + `extra.security_alert` | `node .../dist/cli.js authority-status` |
| `health.*` | `node .../dist/cli.js health` |

Fields with no real source (`error_logs_last_hour`, `resource_util_percent`) are excluded. `extra` is scoped to `security_alert` only, sourced from `contractStatus.mismatches.length > 0`.

### Gap 2: Irreducible Drift Floor

`payloadDrift=11` is the permanent floor of the HustleXP ecosystem. All 11 items are Swift↔TypeScript type-representation differences that cannot be resolved without changing the language semantics of either platform:

- Swift named enums vs. TypeScript string literals
- `[String:Bool]` / `Dictionary<String,Bool>` vs. `Record<string, boolean>`
- Named Swift structs vs. TypeScript inline object types

**Rule:** If `drift.count == 11` OR every area matches the irreducible pattern set → force-classify as `informational`. Never block. Never attempt to reconcile. Never loop.

Any drift count other than 11, or any area NOT matching the pattern set, is a real mismatch → classify as `blocking` → trigger manual fix.

### Gap 3: Rollback Without CI/On-Call

There is no CI pipeline, no on-call rotation, no automated rollback infrastructure. HEALTH-CRITICAL-21 recovery is:

```
git log --oneline -8     # show recent commits to human
# human selects stable SHA
git reset --hard <SHA>   # human-confirmed only
npx vitest run           # verify recovery
```

Claude never selects the SHA. Claude never runs `git reset --hard` without a human-supplied commit hash in the session.

### Gap 4: Real Binary Paths

All abstract function calls replaced with absolute paths and timeouts:

| Abstract | Real Command |
|---|---|
| `refresh_digest()` | `timeout 30s node /Users/sebastiandysart/omni-link-hustlexp/dist/cli.js scan` |
| `reconcile_drift()` | `timeout 30s node /Users/sebastiandysart/omni-link-hustlexp/dist/cli.js authority-status` then manual Swift/TS fix |
| `check_health()` | `timeout 30s node /Users/sebastiandysart/omni-link-hustlexp/dist/cli.js health` |
| `auto-fix template` | invoke `superpowers:systematic-debugging` skill on each failing test |

---

## Phase Summary

```
PHASE 1: READ        Assemble + validate snapshot. No interpretation.
PHASE 2: ASSESS      Classify state via strict decision tree. Stop at first exit.
PHASE 3: DECIDE      Map assessment exit → exact action plan. No new analysis.
PHASE 4: ACT         Execute plan → verify → confirm or escalate.
```

Full specification: `/Users/sebastiandysart/omni-link-hustlexp/WORKFLOW.md`

---

## Enforced Limits

- Total boot must complete in < 7 minutes or emit `EXIT-TIMEOUT`
- Max 2 re-entries to any phase; third attempt = `EXIT-LOOP-FAIL`
- Every CLI call logged with full command + exit code
- Any output outside required format → surface to human, do not continue

---

## Current Ecosystem Baseline (as of 2026-03-11)

| Metric | Value |
|---|---|
| Ecosystem health | 100/100 |
| Test coverage | 88.88% |
| Failing tests | 0 |
| PayloadDrift | 11 (all irreducible — informational) |
| Obsolete calls | 0 |
| Binary | `/Users/sebastiandysart/omni-link-hustlexp/dist/cli.js` |

---

## Revision Policy

This document is updated when:
- Ecosystem infrastructure changes (CI added, on-call added, new CLI commands)
- The irreducible drift floor changes (new Swift↔TS type boundary added)
- Health target changes (currently 95)
- A new exit code is needed that isn't in the decision tree

All revisions must be committed to both this file and `omni-link-hustlexp/WORKFLOW.md` in the same operation to keep them synchronized.
