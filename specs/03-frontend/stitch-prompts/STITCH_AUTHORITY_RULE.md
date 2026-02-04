# STITCH PROMPT AUTHORITY RULE

**Authority:** This file is the canonical rule for stitch prompt precedence.
**Status:** LOCKED — Enforced immediately.

---

## Rule

When both `{name}.md` and `{name}-LOCKED.md` exist in `specs/03-frontend/stitch-prompts/`:

**`{name}-LOCKED.md` is the ONLY canonical version.**

The non-LOCKED `{name}.md` is a historical draft and MUST NOT be used for implementation.

---

## Enforcement

1. AI coding agents: When resolving a stitch prompt for any screen, ALWAYS use the `-LOCKED.md` variant if it exists
2. If only the non-LOCKED version exists, it IS the canonical version
3. Non-LOCKED drafts that have LOCKED counterparts should be moved to `_archive/stitch-drafts/` during cleanup

---

## Current LOCKED Files (Canonical)

| LOCKED File | Draft File (Superseded) |
|---|---|
| `01-instant-interrupt-card-LOCKED.md` | `01-instant-interrupt-card.md` |
| `02-hustler-home-LOCKED.md` | `02-hustler-home.md` |
| `03-pinned-instant-card-LOCKED.md` | `03-pinned-instant-card.md` |
| `04-poster-task-creation-LOCKED.md` | `04-poster-task-creation.md` |
| `05-poster-hustler-on-way-LOCKED.md` | `05-poster-hustler-on-way.md` |
| `06-trust-tier-ladder-LOCKED.md` | `06-trust-tier-ladder.md` |
| `07-xp-breakdown-LOCKED.md` | `07-xp-breakdown.md` |
| `08-hustler-task-in-progress-LOCKED.md` | `08-hustler-task-in-progress.md` |
| `09-hustler-task-completion-LOCKED.md` | `09-hustler-task-completion.md` |
| `10-poster-task-completion-LOCKED.md` | `10-poster-task-completion.md` |
| `11-poster-feedback-LOCKED.md` | `11-poster-feedback.md` |
| `12-trust-change-explanation-LOCKED.md` | `12-trust-change-explanation.md` |
| `13-dispute-entry-LOCKED.md` | `13-dispute-entry.md` |
| `E1-no-tasks-available-LOCKED.md` | `E1-no-tasks-available.md` |
| `E2-eligibility-mismatch-LOCKED.md` | `E2-eligibility-mismatch.md` |
| `E3-trust-tier-locked-LOCKED.md` | `E3-trust-tier-locked.md` |
| `EDGE-STATES-LOCKED.md` | N/A (no draft counterpart) |

---

**Non-LOCKED files without LOCKED counterpart (these ARE canonical):**
- `A1-login-screen.md`, `A2-signup-screen.md`, `A3-forgot-password-screen.md`
- `E4-instant-mode-unavailable.md`
- `H2-task-feed-screen.md` through `H7-en-route-map-screen.md`
- `O1` through `O12` onboarding screens
- `S1-profile-screen.md`, `S2-wallet-screen.md`, `S3-work-eligibility-screen.md`
- `SH1-task-conversation-screen.md`
- `08-dispute-protection.md` (no LOCKED counterpart)

---

**END OF STITCH_AUTHORITY_RULE v1.0.0**
