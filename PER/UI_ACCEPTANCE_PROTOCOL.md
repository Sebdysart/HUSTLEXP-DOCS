# UI ACCEPTANCE PROTOCOL (UAP)

```
STATUS: CONSTITUTIONAL
SCOPE: ALL USER-FACING UI
VIOLATION: BUILD FAILURE
VERSION: 1.0.0
EFFECTIVE: 2025-01-24
```

---

## Authority Declaration

This protocol establishes **binding requirements** for all user-facing screens in HustleXP. No phase, implementation shortcut, or build constraint may override these gates.

### Authority Hierarchy (UI)

```
AUTHORITY ORDER (Highest → Lowest)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. UI_ACCEPTANCE_PROTOCOL (UAP)     ← THIS DOCUMENT
2. Screen Specs (screens-spec/*)
3. Phase Constraints (.cursorrules)
4. Implementation Instructions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**BINDING RULE:** No phase (including BOOTSTRAP) may override UAP gates for any user-facing screen. Phase authority is **subordinate** to UAP.

---

## Definition: User-Facing Screen

A **User-Facing Screen** is any screen that:

1. Appears in Simulator or App launch
2. Is reachable via navigation (any navigation path)
3. Is visible to a human without debug flags or compile-time flags

**BINDING RULE:** Any user-facing screen MUST pass UAP-0 through UAP-4, regardless of current phase.

---

## Definition: Bootstrap Screen (Exception)

A **Bootstrap Screen** is an internal verification screen that:

1. Is behind a compile-time flag (`#if DEBUG`), OR
2. Is named with prefix: `Internal*`, `Debug*`, `Verification*`, `Test*`
3. Is NOT referenced in SCREEN_REGISTRY.md as "complete" or "production"
4. Is NOT reachable via standard user navigation

**BINDING RULE:** Bootstrap screens are exempt from UAP gates but may NEVER be promoted to user-facing status. Bootstrap success does NOT equal screen completion.

---

## UAP Gates

### UAP-0: Purpose Gate

**Requirement:** Every user-facing screen MUST answer three questions within 3 seconds of viewing:

| Question | Must Be Answered |
|----------|------------------|
| **WHO** is this screen for? | Role clarity (Hustler/Poster/Both) |
| **WHAT** do I do next? | Clear primary action |
| **WHY** should I care? | Value proposition or context |

**Failure Examples:**
- Screen with only a logo and button (no value prop)
- Screen without clear next action
- Screen that could belong to any app

**Pass Examples:**
- "Get things done. Get paid." + role explanation + CTA
- Task detail with price, description, and Accept button
- Wallet showing balance and withdrawal option

**Test:** Show screen to someone unfamiliar with HustleXP. Can they answer all three questions in 3 seconds?

---

### UAP-1: Hierarchy Gate

**Requirement:** Every user-facing screen MUST contain at minimum 3 visual layers:

| Layer | Purpose | Required |
|-------|---------|----------|
| **Primary Action** | The main thing user can do | YES |
| **Supporting Context** | Information to inform decision | YES |
| **Brand/Emotional Signal** | Trust, polish, identity | YES |

**Failure Examples:**
- Single button on blank screen
- Text + button only (no context)
- All elements same visual weight

**Pass Examples:**
- Welcome: Logo (brand) + value prop (context) + Get Started (action)
- Task Card: Price (context) + description (context) + Accept (action) + escrow badge (trust)

**Test:** Can you identify all three layers? If any layer is missing, screen fails.

---

### UAP-2: Motion/Depth Gate

**Requirement:** Entry screens, onboarding screens, and first-impression surfaces MUST include at least ONE of:

| Element | Description |
|---------|-------------|
| **Animation** | Fade-in, scale, transition (within spec limits) |
| **Gradient** | Subtle background or element gradient |
| **Glass/Blur** | Glassmorphism, depth layers |
| **Shadow/Elevation** | Visual depth through shadows |
| **Parallax** | Layered motion on scroll |

**Applies To:**
- Welcome/Entry screen
- All onboarding screens (Phase 0-4)
- First screen after login
- Empty states with CTA

**Does NOT Apply To:**
- Settings screens
- Transaction history lists
- Form screens (data entry focus)
- Error states

**Failure Examples:**
- Flat black screen with white text and button
- Pure solid colors with no depth
- Static screens where motion would enhance comprehension

**Pass Examples:**
- Logo with 300ms fade-in
- Glass card with subtle border
- Button with press state animation

---

### UAP-3: Spec Fidelity Gate

**Requirement:** Screen MUST match its spec reference EXACTLY in:

| Element | Tolerance |
|---------|-----------|
| **Layout structure** | Must match wireframe hierarchy |
| **Copy text** | Must match spec copy verbatim (no AI rewrites) |
| **Color usage** | Must use specified tokens only |
| **Typography** | Must use specified scale only |
| **Spacing** | Must use specified spacing scale only |
| **Components** | Must use specified components only |

**Verification Process:**
1. Identify spec reference (e.g., `ONBOARDING_FLOW.md §3.1`)
2. Compare screen element-by-element against spec
3. Any deviation = FAIL unless explicitly approved

**Failure Examples:**
- Spec says "Get things done. Get paid." — screen says "Welcome to HustleXP"
- Spec says white/gradient background — screen uses black
- Spec says 3 calibration screens — implementation has 1

**Pass Examples:**
- Every element matches spec wireframe
- Copy matches spec word-for-word
- Colors match spec tokens exactly

---

### UAP-4: Bootstrap Separation Gate

**Requirement:** Bootstrap/verification screens may NEVER be promoted to user-facing status.

**Verification:**
1. Is this screen in SCREEN_REGISTRY.md?
2. If yes, is it marked as `INTERNAL` or `PRODUCTION`?
3. If `PRODUCTION`, has it passed UAP-0 through UAP-3?

**BINDING RULES:**
- A screen that exists only to verify "app boots" is NOT a production screen
- A screen that passes build but fails UAP is NOT complete
- "Renders without crashing" is NECESSARY but INSUFFICIENT

**Failure Examples:**
- Shipping `BootstrapScreen` as the entry point
- Marking a placeholder as "complete" because it builds
- Promoting `VerificationScreen` to production navigation

**Pass Examples:**
- Bootstrap screen exists behind `#if DEBUG` only
- Production entry screen passes all UAP gates
- SCREEN_REGISTRY clearly separates INTERNAL vs PRODUCTION

---

## Enforcement

### Gate Failure = Build Failure

If ANY UAP gate fails, the screen is **incomplete regardless of build success**.

```
BUILD SUCCESS + UAP FAILURE = INCOMPLETE SCREEN
```

This is not a style suggestion. This is a hard constraint.

### Verification Checklist

Before marking ANY screen as complete:

```
[ ] UAP-0: Screen answers WHO/WHAT/WHY in 3 seconds
[ ] UAP-1: Has primary action + context + brand signal
[ ] UAP-2: Has motion OR depth (if entry/onboarding)
[ ] UAP-3: Matches spec layout/copy/colors exactly
[ ] UAP-4: Not a bootstrap placeholder promoted to production

If ANY checkbox is unchecked → SCREEN IS NOT COMPLETE
```

### SCREEN_REGISTRY Integration

All screens in `screens-spec/SCREEN_REGISTRY.md` must include:

| Column | Values |
|--------|--------|
| **UAP Status** | `PENDING` / `PASSED` / `FAILED` / `INTERNAL` |

Rules:
- No screen may be marked COMPLETE unless UAP Status = `PASSED`
- Bootstrap screens must be marked `INTERNAL`
- Failed screens must have notes explaining failure

---

## Examples

### FAIL: Current Bootstrap Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│            HustleXP                 │
│                                     │
│         [ Get Started ]             │
│                                     │
│                                     │
└─────────────────────────────────────┘
Background: #000000 (black)
```

**UAP-0:** FAIL — No value prop, no role clarity, no "why"
**UAP-1:** FAIL — Missing context layer, missing brand signal
**UAP-2:** FAIL — No motion, no depth, flat black
**UAP-3:** FAIL — Spec requires value prop copy, white/gradient bg
**UAP-4:** FAIL — Bootstrap screen promoted to production

**Verdict:** 0/5 gates passed. Screen is INCOMPLETE.

### PASS: Spec-Compliant Welcome Screen

```
┌─────────────────────────────────────┐
│                                     │
│         [HustleXP Logo]             │  ← Brand signal (fade-in 300ms)
│                                     │
│    Get things done. Get paid.       │  ← Value prop (WHO/WHY)
│                                     │
│    Post tasks and find help in      │  ← Context
│    minutes. Or earn money           │
│    completing tasks nearby.         │
│                                     │
│         [ Get Started ]             │  ← Primary action (WHAT)
│                                     │
│    Already have an account? Sign in │  ← Secondary action
│                                     │
└─────────────────────────────────────┘
Background: White/subtle gradient
Animation: Logo fade-in 300ms
```

**UAP-0:** PASS — Answers who (posters/hustlers), what (get started), why (get things done/get paid)
**UAP-1:** PASS — Action (button) + context (description) + brand (logo)
**UAP-2:** PASS — Logo fade-in animation
**UAP-3:** PASS — Matches ONBOARDING_FLOW.md §3.1 exactly
**UAP-4:** PASS — Production screen, not bootstrap

**Verdict:** 5/5 gates passed. Screen is COMPLETE.

---

## Cross-References

| Document | Relationship |
|----------|--------------|
| `UI_SPEC.md` | Defines visual rules UAP enforces |
| `ONBOARDING_FLOW.md` | Defines screen specs UAP-3 verifies against |
| `SCREEN_REGISTRY.md` | Tracks UAP status per screen |
| `.cursorrules` | References UAP as superior authority |
| `CURSOR_INSTRUCTIONS.md` | Includes UAP checklist for implementers |

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2025-01-24 | Initial constitutional authority |

---

**END OF UI_ACCEPTANCE_PROTOCOL.md v1.0.0**
