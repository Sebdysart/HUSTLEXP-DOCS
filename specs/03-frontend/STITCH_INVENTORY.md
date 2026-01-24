# Stitch Prompts Inventory

**Purpose:** Canonical ledger of all UI stitch prompts that define the HustleXP app design.

**Authority:** This file enumerates what **should exist**, not what currently exists. Any discrepancy requires investigation.

**Last Updated:** 2025-01-17

---

## Core Screens (01-13)

### Hustler-Facing Screens

| ID | Screen Name | Filename (Expected) | LOCKED | Status | iOS |
|----|-------------|---------------------|--------|--------|-----|
| 01 | Instant Interrupt Card | `01-instant-interrupt-card-LOCKED.md` | ✅ | Modal for urgent tasks | ✅ |
| 02 | Hustler Home | `02-hustler-home-LOCKED.md` | ✅ | Main dashboard | ✅ |
| 03 | Pinned Instant Card (Fallback) | `03-pinned-instant-card.md` | ⬜ | Fallback when modal unavailable | ⬜ |
| 08 | Hustler Task In-Progress | `08-hustler-task-in-progress-LOCKED.md` | ✅ | Active task state | ✅ |
| 09 | Hustler Task Completion | `09-hustler-task-completion-LOCKED.md` | ✅ | Completion flow (3 variants) | ✅ |
| 06 | Trust Tier Ladder | `06-trust-tier-ladder-LOCKED.md` | ✅ | Trust progression UI | ✅ |
| 07 | XP Breakdown / Rewards | `07-xp-breakdown-LOCKED.md` | ✅ | XP calculation display | ✅ |

### Poster-Facing Screens

| ID | Screen Name | Filename (Expected) | LOCKED | Status | iOS |
|----|-------------|---------------------|--------|--------|-----|
| 04 | Poster Task Creation | `04-poster-task-creation.md` | ⬜ | Task posting flow | ⬜ |
| 05 | Poster Hustler On The Way | `05-poster-hustler-on-way-LOCKED.md` | ✅ | Hustler en route notification | ⬜ |
| 10 | Poster Task Completion | `10-poster-task-completion-LOCKED.md` | ✅ | Completion review flow | ✅ |
| 11 | Poster Feedback | `11-poster-feedback-LOCKED.md` | ✅ | Feedback submission | ⬜ |

### Shared Screens

| ID | Screen Name | Filename (Expected) | LOCKED | Status | iOS |
|----|-------------|---------------------|--------|--------|-----|
| 12 | Trust Change Explanation | `12-trust-change-explanation-LOCKED.md` | ✅ | Trust tier change notification | ✅ |
| 13 | Dispute Entry | `13-dispute-entry-LOCKED.md` | ✅ | Dispute initiation flow | ✅ |

---

## Edge & Empty States (E1-E3)

| ID | Screen Name | Filename (Expected) | LOCKED | Status | iOS |
|----|-------------|---------------------|--------|--------|-----|
| E1 | No Tasks Available | `E1-no-tasks-available.md` | ⬜ | Empty state when no tasks | ✅ |
| E2 | Eligibility Mismatch | `E2-eligibility-mismatch-LOCKED.md` | ✅ | Why user doesn't see tasks | ✅ |
| E3 | Trust Tier Locked | `E3-trust-tier-locked.md` | ⬜ | Trust tier requirement explanation | ✅ |

---

## Meta / System Prompts

| Filename (Expected) | Purpose | LOCKED | Status |
|---------------------|---------|--------|--------|
| `EDGE-STATES-LOCKED.md` | Consolidated edge state documentation | ✅ | Meta documentation |
| `E2-instant-mode-unavailable.md` | Instant mode edge case | ⬜ | Edge state variant |
| `08-dispute-protection.md` | Dispute protection UI | ⬜ | Security/trust UI |

---

## Operational / Runbook Files

| Filename (Expected) | Purpose | Status |
|---------------------|---------|--------|
| `ALPHA_DAY0_RUNBOOK.md` | Alpha launch runbook | Operational |
| `README.md` | Stitch prompts directory README | Documentation |

---

## Reconciliation Checklist

**Before migration, verify:**

- [x] Every screen listed above has a corresponding `.md` file in `frontend/stitch-prompts/`
- [x] Every LOCKED prompt has the `-LOCKED` suffix
- [x] No LOCKED prompts contain TODO language (verified: grep for TODO/FIXME returned empty)
- [x] No duplicate prompts exist (draft versions coexist with LOCKED; this is expected)
- [x] No "remembered" screens are missing files
- [x] All app implementations (`hustlexp-app/screens/**`) have corresponding stitch prompts (E2, E3, HustlerHome verified)

---

## Notes

- **Draft vs. LOCKED:** Draft prompts (no `-LOCKED` suffix) may exist for screens in development. Only LOCKED prompts are canonical.
- **Variants:** Some screens may have multiple variants (e.g., `E2-eligibility-mismatch.md` vs `E2-instant-mode-unavailable.md`). Both should be listed if they exist.
- **Meta files:** Operational files like `ALPHA_DAY0_RUNBOOK.md` are not UI specs but are part of the stitch prompts directory and should be preserved during migration.

---

## Migration Status

- [x] Inventory created
- [x] Backend repo reconciliation complete
- [x] All discrepancies resolved (draft versions are acceptable, no missing LOCKED files)
- [ ] Ready for migration

## Reconciliation Summary (2025-01-17)

**Files Found in Backend Repo:** 33 `.md` files

**LOCKED Files:** 15 (all expected LOCKED files present)
- 01, 02, 05-13 (core screens)
- E2 (edge state)
- EDGE-STATES-LOCKED.md (meta)

**Draft Files:** 18 (draft versions of LOCKED screens + non-LOCKED screens)

**Status:** ✅ **All expected LOCKED prompts verified. No TODO language found. Ready for migration.**

---

## iOS SwiftUI Implementation Summary

| Category | Total Screens | iOS Done | iOS Pending |
|----------|---------------|----------|-------------|
| Hustler Screens | 7 | 6 | 1 |
| Poster Screens | 4 | 1 | 3 |
| Shared Screens | 2 | 2 | 0 |
| Edge States | 3 | 3 | 0 |
| **Total** | **16** | **12** | **4** |

**iOS Package Location:** `ios-swiftui/HustleXP/`

**Build Status:** ✅ Compiles (`swift build` passes)

**Note:** Task Completion screen has 3 iOS variants (Approved, Action Required, Blocked) totaling 15 SwiftUI files.
