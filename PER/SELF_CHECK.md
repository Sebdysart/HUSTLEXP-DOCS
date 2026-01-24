# SELF CHECK — AUTOMATIC VIOLATION DETECTION

**STATUS: MANDATORY**
**PURPOSE: AI self-verification before every output**
**RULE: If ANY check fails → STOP and fix before continuing**

---

## WHY THIS EXISTS

AI can produce technically valid but contextually wrong output.
This document provides a checklist AI must run before every response.

Self-checking makes violations **visible** before they become problems.

---

## PRE-RESPONSE CHECKLIST

Before outputting ANY response, AI must verify:

### ✅ HIC COMPLIANCE

```
[ ] Response begins with HIC header block
[ ] Cold Start Verification is complete
[ ] All 6 fields filled with certainty
[ ] Protocol classification is exactly ONE
[ ] Legality check completed
[ ] Plan provided (if IMPLEMENTATION_MODE)
```

If ANY unchecked → Add HIC header before continuing

---

### ✅ PHASE COMPLIANCE

```
[ ] Action is allowed in current phase (Bootstrap)
[ ] Not creating screens beyond EntryScreen
[ ] Not adding navigation
[ ] Not adding backend calls
[ ] Not adding new dependencies
```

If ANY unchecked → STOP and explain why action is blocked

---

### ✅ COLOR COMPLIANCE

```
[ ] No green on entry/welcome screens (#1FAD7E, #34C759)
[ ] Using correct brand black (#0B0B0F, not #0D0D0D)
[ ] Using correct brand purple (#5B2DFF)
[ ] Entry gradient correct ['#1a0a2e', '#0B0B0F', '#000000']
[ ] Glow orb uses purple, not green
[ ] Button uses purple, not green
```

If ANY unchecked → Fix colors before outputting

---

### ✅ LAYOUT COMPLIANCE

```
[ ] Entry screen is NOT card-based
[ ] NOT using justifyContent: 'center' + alignItems: 'center' on container
[ ] Entry screen has gradient background
[ ] Entry screen has glow orb
[ ] Content flows top-to-bottom
[ ] CTA anchored at bottom with safe area
```

If ANY unchecked → Restructure layout before outputting

---

### ✅ PATTERN COMPLIANCE

```
[ ] Copying from reference/components/EntryScreen.js
[ ] Not inventing new UI patterns
[ ] Not using semantic equivalent card names
[ ] Not using rejected approaches
[ ] Following locked composition from DESIGN_AUTHORITY.md
```

If ANY unchecked → Use correct pattern before outputting

---

### ✅ AUTHORITY COMPLIANCE

```
[ ] Not touching COMPLETION_LOCK items
[ ] Not re-attempting REJECTED_APPROACHES
[ ] Followed AUTHORITY_LADDER for any ambiguity
[ ] Did not guess when uncertain
[ ] Did not "improve" beyond spec
```

If ANY unchecked → STOP and escalate or fix

---

### ✅ OUTPUT QUALITY

```
[ ] Output is MAX-TIER (not minimal)
[ ] All UAP gates considered
[ ] Matches spec exactly
[ ] No "temporary" or "placeholder" code
[ ] No TODOs in critical paths
```

If ANY unchecked → Improve quality before outputting

---

## VIOLATION DETECTION REGEX

Use these patterns to scan code output for violations:

### Color Violations

```regex
# Green on entry (FORBIDDEN)
backgroundColor:\s*['"]#(1FAD7E|34C759)['"]
shadowColor:\s*['"]#(1FAD7E|34C759)['"]

# Wrong black
backgroundColor:\s*['"]#0D0D0D['"]

# Wrong brand color
backgroundColor:\s*['"]#FF6B35['"]
```

### Layout Violations

```regex
# Centered container (FORBIDDEN for entry)
justifyContent:\s*['"]center['"][\s\S]*alignItems:\s*['"]center['"]

# Card-like patterns
<(HeroCard|Panel|OverlayContainer|CenteredStack|WelcomeTile|ContentBox|FloatingCard)
```

### Pattern Violations

```regex
# Flat black without gradient
backgroundColor:\s*['"]#000000['"](?![\s\S]*LinearGradient)

# Missing glow
(?![\s\S]*shadowColor:\s*['"]#5B2DFF['"])
```

---

## SELF-CHECK PROTOCOL

### Step 1: Run Checklist
Go through each section above.

### Step 2: Count Failures
How many checks failed?

### Step 3: Decide Action

| Failures | Action |
|----------|--------|
| 0 | Proceed with output |
| 1-2 | Fix before output, note fixes |
| 3+ | STOP, re-read PER documents, restart |

### Step 4: Document

If fixes were needed, include in response:
```
SELF-CHECK: [X] failures detected, fixed before output
- [description of fix 1]
- [description of fix 2]
```

---

## POST-OUTPUT VERIFICATION

After outputting code, verify:

```
[ ] Code compiles without errors
[ ] No forbidden patterns in output
[ ] Matches reference/components/EntryScreen.js structure
[ ] Uses exact colors from spec
[ ] Layout follows locked composition
[ ] Animation timings correct (300ms logo, 400ms content)
```

---

## COMMON FAILURE MODES

### Mode 1: Minimal Output
**Detection:** Output looks like a "quick fix" or "bootstrap"
**Fix:** Apply full pattern from reference/components/

### Mode 2: Color Drift
**Detection:** Using colors not in reference/constants/colors.js
**Fix:** Replace with exact values from token file

### Mode 3: Layout Invention
**Detection:** Creating new layout not in DESIGN_AUTHORITY.md
**Fix:** Use locked composition exactly

### Mode 4: Guess Without Escalation
**Detection:** "I assume..." or "probably..." in response
**Fix:** STOP, use AUTHORITY_LADDER, ask user

### Mode 5: Missing HIC Header
**Detection:** Response starts with explanation or code
**Fix:** Prepend HIC header block

---

## AUTOMATIC REJECTION TRIGGERS

If ANY of these are detected, response is INVALID:

```
❌ No HIC header at start of response
❌ Green color codes in entry screen code
❌ justifyContent: 'center' + alignItems: 'center' on container
❌ <Card>, <Panel>, or equivalent container names
❌ Flat #000000 background without gradient
❌ Missing purple glow orb
❌ "I think" or "probably" indicating guess
❌ Modifying locked items without unlock
❌ Re-using rejected approach pattern
```

---

## THE SELF-CHECK GUARANTEE

Running this checklist before every response guarantees:

1. **No silent failures** — Violations are detected before output
2. **No low-tier output** — Quality is verified
3. **No guessing** — Uncertainty is escalated
4. **No violations** — Rules are enforced

---

## COMPACT CHECKLIST (Quick Reference)

```
SELF-CHECK:
[ ] HIC header present
[ ] Cold Start complete
[ ] Single protocol
[ ] Legality verified
[ ] Plan provided (if impl)
[ ] No green on entry
[ ] Correct black (#0B0B0F)
[ ] Correct purple (#5B2DFF)
[ ] No card layout
[ ] Has gradient
[ ] Has glow
[ ] Full-canvas flow
[ ] Pattern from reference
[ ] No guessing
[ ] MAX-TIER quality
```

If all checked → Output is valid
If any unchecked → Fix before output

---

**Run this checklist before every response.**
**Violations caught here never reach the user.**
