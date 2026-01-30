# UI Acceptance Checklist

**Authority:** `PER/UI_ACCEPTANCE_PROTOCOL.md`
**Purpose:** Per-screen verification template for UAP gate compliance

---

## Instructions

1. Copy this checklist for each screen being implemented
2. Complete ALL gates before marking screen as COMPLETE
3. If ANY gate fails, screen is INCOMPLETE regardless of build status
4. Update SCREEN_REGISTRY.md with UAP Status after verification

---

## Screen Verification Template

### Screen Information

```
Screen Name: _________________________________
Spec Reference: ______________________________
Implementer: _________________________________
Date: _______________________________________
```

---

### UAP-0: Purpose Gate

**Requirement:** Screen must answer WHO/WHAT/WHY within 3 seconds.

| Question | Answer | Present? |
|----------|--------|----------|
| WHO is this screen for? | | [ ] Yes [ ] No |
| WHAT do I do next? | | [ ] Yes [ ] No |
| WHY should I care? | | [ ] Yes [ ] No |

**Test:** Show to unfamiliar person. Can they answer all three in 3 seconds?

```
[ ] UAP-0 PASSED
[ ] UAP-0 FAILED — Reason: _________________________________
```

---

### UAP-1: Hierarchy Gate

**Requirement:** Screen must have 3 visual layers minimum.

| Layer | Element Identified | Present? |
|-------|-------------------|----------|
| Primary Action | | [ ] Yes [ ] No |
| Supporting Context | | [ ] Yes [ ] No |
| Brand/Emotional Signal | | [ ] Yes [ ] No |

**Test:** Can you point to all three layers? If any missing, FAIL.

```
[ ] UAP-1 PASSED
[ ] UAP-1 FAILED — Reason: _________________________________
```

---

### UAP-2: Motion/Depth Gate

**Requirement:** Entry/onboarding screens must have motion OR depth.

**Does this gate apply?**
```
[ ] YES — This is entry, onboarding, or first-impression screen
[ ] NO — This is settings, list, form, or utility screen (skip to UAP-3)
```

**If YES, which element is present?**

| Element | Description | Present? |
|---------|-------------|----------|
| Animation | Fade, scale, transition | [ ] |
| Gradient | Background or element | [ ] |
| Glass/Blur | Glassmorphism, depth | [ ] |
| Shadow/Elevation | Visual depth | [ ] |
| Parallax | Layered motion | [ ] |

**At least ONE must be checked.**

```
[ ] UAP-2 PASSED
[ ] UAP-2 NOT APPLICABLE (utility screen)
[ ] UAP-2 FAILED — Reason: _________________________________
```

---

### UAP-3: Spec Fidelity Gate

**Requirement:** Screen must match spec reference exactly.

**Spec Reference:** _________________________________ (e.g., ONBOARDING_FLOW.md §3.1)

| Element | Spec Says | Implementation Has | Match? |
|---------|-----------|-------------------|--------|
| Layout structure | | | [ ] |
| Copy text (verbatim) | | | [ ] |
| Colors (tokens) | | | [ ] |
| Typography (scale) | | | [ ] |
| Spacing (scale) | | | [ ] |
| Components | | | [ ] |

**ALL must match. Any deviation = FAIL unless explicitly approved.**

```
[ ] UAP-3 PASSED
[ ] UAP-3 FAILED — Deviation: _________________________________
```

---

### UAP-4: Bootstrap Separation Gate

**Requirement:** Bootstrap screens cannot be user-facing.

**Classification:**
```
[ ] PRODUCTION — User-facing screen (must pass UAP-0 through UAP-3)
[ ] INTERNAL — Debug/verification only (behind compile flag)
```

**If PRODUCTION:**
```
[ ] Screen is in SCREEN_REGISTRY.md
[ ] Screen is NOT named Internal*/Debug*/Test*/Verification*
[ ] Screen is reachable via standard navigation
[ ] Screen is NOT a placeholder that "just renders"
```

**If INTERNAL:**
```
[ ] Screen is behind #if DEBUG or compile-time flag
[ ] Screen is marked INTERNAL in SCREEN_REGISTRY.md
[ ] Screen is NOT in production navigation
```

```
[ ] UAP-4 PASSED
[ ] UAP-4 FAILED — Reason: _________________________________
```

---

## Final Verification

### Gate Summary

| Gate | Status |
|------|--------|
| UAP-0: Purpose | [ ] PASS [ ] FAIL |
| UAP-1: Hierarchy | [ ] PASS [ ] FAIL |
| UAP-2: Motion/Depth | [ ] PASS [ ] FAIL [ ] N/A |
| UAP-3: Spec Fidelity | [ ] PASS [ ] FAIL |
| UAP-4: Bootstrap Separation | [ ] PASS [ ] FAIL |

### Final Status

```
[ ] ALL GATES PASSED — Screen is COMPLETE
    → Update SCREEN_REGISTRY.md: UAP Status = PASSED

[ ] ONE OR MORE GATES FAILED — Screen is INCOMPLETE
    → Do NOT mark as complete
    → Fix issues and re-verify
    → Update SCREEN_REGISTRY.md: UAP Status = FAILED (with notes)
```

---

## Sign-Off

```
☐ Screen reviewed against UAP
☐ Screen approved for user-facing exposure

Reviewer: __________________________________________
Date: ______________________________________________
Notes: _____________________________________________
___________________________________________________
```

---

## Quick Reference

**BUILD SUCCESS + UAP FAILURE = INCOMPLETE SCREEN**

Authority hierarchy:
1. UI_ACCEPTANCE_PROTOCOL (UAP) ← HIGHEST
2. Screen Specs
3. Phase Constraints
4. Implementation Instructions

**If you cannot pass all gates, STOP and ask.**

---

**END OF UI_ACCEPTANCE_CHECKLIST.md**
