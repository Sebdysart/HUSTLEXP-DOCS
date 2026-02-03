# Onboarding System Architecture

## Executive Summary

HustleXP uses **two complementary onboarding systems** that run sequentially to establish both UX personalization and legal eligibility. They are **not peers** — they serve different purposes and have different authority levels.

---

## System Overview

### System A: Calibration Onboarding (Role Inference & UX)
**Purpose:** Role inference, behavior profiling, UX personalization, safety signals

**Answers:** *"Who is this user and how should the system treat them?"*

**Authority:** UX personalization only (non-authoritative for eligibility)

**Flow:**
1. FramingScreen (Phase 0)
2. CalibrationScreen (Phase 1: 5 behavioral questions)
3. RoleConfirmationScreen (Phase 3: Authority Confirmation)
4. PreferenceLockScreen (Phase 4: Preference Lock-In)

**Screens:**
- `hustlexp-app/screens/onboarding/FramingScreen.tsx`
- `hustlexp-app/screens/onboarding/CalibrationScreen.tsx`
- `hustlexp-app/screens/onboarding/RoleConfirmationScreen.tsx`
- `hustlexp-app/screens/onboarding/PreferenceLockScreen.tsx`

**Spec Authority:** `HUSTLEXP-DOCS/ONBOARDING_SPEC.md`

---

### System B: Capability-Driven Onboarding (Eligibility & Verification)
**Purpose:** Legal eligibility, trade qualification, verification paths, feed gating

**Answers:** *"What work is this user legally and operationally allowed to do?"*

**Authority:** Eligibility authority (feed filtering, verification gating)

**Flow:**
1. RoleDeclarationScreen (Phase 0: Role Selection)
2. LocationSelectionScreen (Phase 1: Legal Jurisdiction)
3. CapabilityDeclarationScreen (Phase 2: Trade Claims)
4. CredentialClaimScreen (Phase 3: License Pre-Check) [Conditional]
5. LicenseMetadataScreen (Phase 4: License Capture) [Conditional]
6. InsuranceClaimScreen (Phase 5: Insurance Status) [Conditional]
7. RiskWillingnessScreen (Phase 6: Risk Preferences)
8. CapabilitySummaryScreen (Phase 7: Summary & Next Actions)

**Screens:**
- `hustlexp-app/screens/onboarding/capability/RoleDeclarationScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/LocationSelectionScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/CapabilityDeclarationScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/CredentialClaimScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/LicenseMetadataScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/InsuranceClaimScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/RiskWillingnessScreen.tsx`
- `hustlexp-app/screens/onboarding/capability/CapabilitySummaryScreen.tsx`

**Spec Authority:** `HUSTLEXP-DOCS/architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`

---

## Canonical Onboarding Flow (LOCKED)

The two systems run **sequentially**, not in parallel:

```
Auth
 → Calibration Onboarding (System A)
   → FramingScreen (Phase 0)
   → CalibrationScreen (Phase 1: 5 behavioral questions)
   → RoleConfirmationScreen (Phase 3: Authority Confirmation)
   → PreferenceLockScreen (Phase 4: Preference Lock-In)
 → Capability Onboarding (System B)
   → RoleDeclarationScreen (Phase 0: Role Selection)
   → LocationSelectionScreen (Phase 1: Legal Jurisdiction)
   → CapabilityDeclarationScreen (Phase 2: Trade Claims)
   → [Conditional: CredentialClaimScreen (Phase 3: License Pre-Check)]
   → [Conditional: LicenseMetadataScreen (Phase 4: License Capture)]
   → InsuranceClaimScreen (Phase 5: Insurance Status)
   → RiskWillingnessScreen (Phase 6: Risk Preferences)
   → CapabilitySummaryScreen (Phase 7: Summary & Next Actions)
 → HustlerHomeScreen
```

---

## Authority Hierarchy (NON-NEGOTIABLE)

### System A (Calibration): UX Personalization Only
- **Affects:** UX personalization, default preferences, role confidence
- **Does NOT affect:** Task eligibility, feed filtering, verification gating
- **Authority Level:** Low (suggestions, not permissions)

### System B (Capability-Driven): Eligibility Authority
- **Affects:** Task eligibility, feed filtering, verification paths, legal scope
- **Authority Level:** High (permissions, not suggestions)

**Only System B is allowed to affect:**
- Task visibility (feed filtering)
- Verification paths (license/insurance requirements)
- Payments (verification gating)
- Trust → risk clearance

---

## Which Screens Affect What?

### Calibration Onboarding (System A) → Claims vs Permissions

| Screen | Data Collected | Affects What | Does NOT Affect |
|--------|---------------|--------------|-----------------|
| FramingScreen | None (framing only) | UX tone, system authority display | Eligibility, feed, verification |
| CalibrationScreen | 5 behavioral answers | Role confidence, UX defaults | Eligibility, feed, verification |
| RoleConfirmationScreen | Role certainty (STRONG/MODERATE/WEAK) | Role confidence, UX behavior | Eligibility, feed, verification |
| PreferenceLockScreen | Task type preferences, availability flags | UX personalization, default filters | Eligibility, feed, verification |

**Key Principle:** System A collects **claims** (preferences, behavior signals), not **permissions** (eligibility, verification).

---

### Capability-Driven Onboarding (System B) → Claims vs Permissions

| Screen | Data Collected | Affects What | Does NOT Affect |
|--------|---------------|--------------|-----------------|
| RoleDeclarationScreen | Role (hustler/poster/both) | Flow branching | Eligibility, feed (yet) |
| LocationSelectionScreen | work_state, work_region | Legal jurisdiction, verification paths | Feed (yet) |
| CapabilityDeclarationScreen | claimed_trades | Verification paths unlocked | Feed, eligibility (yet) |
| CredentialClaimScreen | has_license, license_intent | Verification paths unlocked | Feed, eligibility (yet) |
| LicenseMetadataScreen | license_claims | Verification paths unlocked | Feed, eligibility (yet) |
| InsuranceClaimScreen | insurance_claimed, coi_uploaded | Verification paths unlocked | Feed, eligibility (yet) |
| RiskWillingnessScreen | risk_preferences | Verification prompts tailored | Feed, eligibility (yet) |
| CapabilitySummaryScreen | Summary + next actions | Verification handoff, feed access | Eligibility (capability profile drives feed) |

**Key Principle:** System B collects **claims** during onboarding, but **capability profile** (derived from verification) drives feed eligibility.

---

## What Happens After Onboarding Completion?

### 1. Calibration Onboarding Completes (System A)
- Role confidence stored
- UX preferences stored
- Default filters applied
- **No eligibility changes**

### 2. Capability Onboarding Completes (System B)
- **Capability Claims** stored (immutable audit trail)
- **Capability Profile** created (initial state: empty verified_trades, trust_tier: "A")
- **Verification Paths** unlocked (user can start verification in Settings)
- **Feed** becomes accessible (filtered by capability profile — shows only eligible tasks)

### 3. User Can Now:
- Access task feed (filtered by capability profile)
- Start verification in Settings → Work Eligibility
- See upgrade paths (e.g., "Verify Electrician License to unlock 14 gigs near you")

### 4. User Cannot:
- See ineligible tasks (feed is filtered)
- See "you can't do this" messages (tasks simply don't appear)
- Apply to tasks they're not eligible for (feed prevents it)

---

## Why This Architecture Works

### Users Feel Guided, Not Blocked
- **System A** provides warm UX personalization (feels welcoming)
- **System B** provides clear eligibility paths (feels transparent)
- "No" answers in System B do not block onboarding (low-risk work still available)

### Verification Feels Like an Upgrade, Not Punishment
- Verification is optional (low-risk work available without verification)
- Verification unlocks more tasks (not required for existing tasks)
- Settings screen shows verification as enhancement (not requirement)

### Posters Never See Unqualified Applicants
- Feed is filtered by capability profile (only eligible users see tasks)
- Task acceptance implies eligibility (feed construction ensures matching)
- No "why was I rejected?" tickets (users never rejected, just not shown)

### Legal Responsibility Stays Centralized
- Capability profile enforces legal requirements (insurance, licenses, background checks)
- Task requirements are explicit (regulatory compliance is encoded)
- Verification records are immutable (audit trail is preserved)

### Monetization Fits Naturally Later
- Verification can be gated by payment (post-onboarding)
- Trust tier progression can be gated by payment (post-onboarding)
- Premium features can be gated by payment (post-onboarding)

---

## Failure Modes Avoided

### Users Applying to Jobs They Can't Legally Do
**How:** Feed is filtered by capability profile. Ineligible tasks never appear.

**Evidence:** Feed query filters by `verified_trades`, `trust_tier`, `risk_clearance`, `insurance_valid`.

### "Why Was I Rejected?" Support Tickets
**How:** Users never rejected. Tasks simply don't appear.

**Evidence:** Feed construction excludes ineligible tasks (no rejection event exists).

### Trust Erosion from Posters
**How:** Only eligible users can accept tasks. Poster confidence is high.

**Evidence:** Feed construction ensures only users meeting requirements see tasks.

### Screenshots of Unsafe Gigs
**How:** Unsafe gigs don't appear for ineligible users.

**Evidence:** Risk level and trust tier matching prevent unsafe matching.

### Regulatory Ambiguity
**How:** Capability profile enforces legal requirements. Task requirements are explicit.

**Evidence:** Insurance, background checks, and licenses are verified and enforced.

---

## Implementation Checklist

- [x] System A (Calibration) screens implemented (4 screens)
- [x] System B (Capability-Driven) screens implemented (8 screens)
- [x] SCREEN_REGISTRY.json updated with all 12 onboarding screens
- [ ] Navigation flow wired (System A → System B → HustlerHomeScreen)
- [ ] Onboarding completion handlers (create capability_claims + capability_profile)
- [ ] Verification paths unlocked (link to Settings → Work Eligibility)
- [ ] Feed access granted (filtered by capability profile)

---

## Canonical Ruling (LOCKED)

**System B (Capability-Driven) is canonical for eligibility/verification.**

**System A (Calibration) is subordinate for UX personalization.**

They are **not peers**. System A runs FIRST (UX warmup), then System B runs SECOND (eligibility authority).

**Flow:** `Auth → Calibration (A) → Capability Onboarding (B) → HustlerHomeScreen`

**Authority:**
- System A: UX personalization (non-authoritative for eligibility)
- System B: Eligibility authority (feed filtering, verification gating)

**Only System B affects:**
- Task visibility (feed filtering)
- Verification paths (license/insurance requirements)
- Payments (verification gating)
- Trust → risk clearance

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
