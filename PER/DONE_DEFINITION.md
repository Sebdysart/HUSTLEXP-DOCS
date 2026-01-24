# DONE DEFINITION — BINARY COMPLETION CRITERIA

**STATUS: AUTHORITATIVE**
**PURPOSE: Remove ambiguity about when something is "done"**
**RULE: If ANY checkbox is unchecked → NOT DONE**

---

## WHY THIS EXISTS

"Done" is not a feeling. "Done" is a set of checkboxes.

AI often says "I think this is ready" when criteria are not met.

This document defines exactly what "done" means for each type of work.

---

## BOOTSTRAP: DONE DEFINITION

### The app is BOOTSTRAP-DONE when:

```
[ ] Xcode builds with zero errors
[ ] Xcode builds with zero warnings in our code
[ ] iOS Simulator launches without crashing
[ ] EntryScreen renders visually
[ ] Purple gradient background visible (#1a0a2e → #0B0B0F → #000000)
[ ] Purple glow orb visible (#5B2DFF with 0.2 opacity)
[ ] "HustleXP" brand name visible in white (#FFFFFF)
[ ] "Get Started" button visible with purple background (#5B2DFF)
[ ] Button tap triggers console log
[ ] No crashes for 30 seconds of idle
[ ] No red error screens
[ ] No yellow warning screens
[ ] No green anywhere on entry screen

ALL CHECKBOXES MUST BE CHECKED.
If ANY is unchecked → BOOTSTRAP NOT DONE.
```

---

## ENTRY SCREEN: DONE DEFINITION

### EntryScreen is DONE when:

```
UAP-1: Design Token Compliance
[ ] All colors from reference/constants/colors.js
[ ] All fonts match DESIGN_SYSTEM.md
[ ] All spacing uses standard increments

UAP-2: 300ms Polish Gate
[ ] Logo fade-in animation (300ms)
[ ] Content fade-in animation (400ms)
[ ] No jank or stutter

UAP-3: Accessibility Baseline
[ ] VoiceOver can read all elements
[ ] Minimum contrast ratios met
[ ] Touch targets >= 44px

UAP-4: Empty/Error State Audit
[ ] N/A for Entry Screen (no data states)

UAP-5: Full-Canvas Immersion Gate
[ ] NOT card-based layout
[ ] NOT justifyContent: 'center' + alignItems: 'center' on container
[ ] Background has gradient treatment
[ ] Glow effect behind brand
[ ] Content flows top-to-bottom
[ ] CTA anchored at bottom

COLOR SEMANTICS LAW
[ ] No green anywhere
[ ] Purple (#5B2DFF) for brand accents
[ ] Black (#0B0B0F) for background
[ ] Purple gradient (#1a0a2e → #0B0B0F → #000000)

PATTERN COMPLIANCE
[ ] Matches reference/components/EntryScreen.js pattern
[ ] Uses useSafeAreaInsets()
[ ] Uses LinearGradient from expo-linear-gradient
[ ] Has Animated fade-in effects

ALL CHECKBOXES MUST BE CHECKED.
```

---

## SCREEN (GENERIC): DONE DEFINITION

### Any screen is DONE when:

```
SPECIFICATION MATCH
[ ] Matches spec document pixel-perfect
[ ] All required elements present
[ ] No extra elements added
[ ] Correct hierarchy and ordering

UAP GATES
[ ] Passes UAP-1 (tokens)
[ ] Passes UAP-2 (animations)
[ ] Passes UAP-3 (a11y)
[ ] Passes UAP-4 (states)
[ ] Passes UAP-5 (if entry/welcome screen)

CODE QUALITY
[ ] Follows existing patterns
[ ] No new dependencies added
[ ] TypeScript compiles without errors
[ ] ESLint passes
[ ] No console warnings

FUNCTIONAL
[ ] All interactions work
[ ] Navigation works (if applicable)
[ ] State updates correctly
[ ] No crashes on interaction

ALL CHECKBOXES MUST BE CHECKED.
```

---

## INVARIANT: DONE DEFINITION

### An invariant is DONE when:

```
DEFINITION
[ ] Documented in PER/INVARIANTS.md
[ ] Has unique ID (INV-X, ARCH-X, etc.)
[ ] Has error code (HX series)
[ ] Has clear rule statement

ENFORCEMENT
[ ] Database trigger exists in schema.sql
[ ] Trigger raises correct error code
[ ] Trigger prevents invalid state

TESTING
[ ] Kill test exists
[ ] Kill test FAILS if constraint removed
[ ] Kill test passes normally
[ ] Test is in test suite

DOCUMENTATION
[ ] Cross-referenced in INVARIANTS.md
[ ] Source document cited (PRODUCT_SPEC, ARCHITECTURE, etc.)
[ ] Line numbers documented for schema.sql

ALL CHECKBOXES MUST BE CHECKED.
```

---

## API ENDPOINT: DONE DEFINITION

### An API endpoint is DONE when:

```
SPECIFICATION
[ ] Matches API_CONTRACT.md definition
[ ] Correct HTTP method
[ ] Correct path
[ ] Correct request schema
[ ] Correct response schema

IMPLEMENTATION
[ ] tRPC router implemented
[ ] Input validation via Zod
[ ] Error codes from ERROR_CODES.md only
[ ] Proper authentication check
[ ] Proper authorization check

TESTING
[ ] Unit tests exist
[ ] Unit tests pass
[ ] Integration test exists
[ ] Idempotency tested (if mutation)

INVARIANTS
[ ] Respects all relevant invariants
[ ] Simulated against PER-3 scenarios

ALL CHECKBOXES MUST BE CHECKED.
```

---

## FIX/BUG: DONE DEFINITION

### A bug fix is DONE when:

```
ROOT CAUSE
[ ] Root cause identified
[ ] Root cause documented (in commit or PR)

FIX
[ ] Minimal fix applied
[ ] No unrelated changes
[ ] Fix addresses root cause (not symptom)

VERIFICATION
[ ] Bug no longer reproduces
[ ] Existing tests still pass
[ ] No new warnings introduced
[ ] No regressions in related areas

ALL CHECKBOXES MUST BE CHECKED.
```

---

## COMMIT: DONE DEFINITION

### A commit is DONE when:

```
CONTENT
[ ] Only includes related changes
[ ] No commented-out code
[ ] No console.log/debug statements
[ ] No TODOs in critical paths

MESSAGE
[ ] Clear, descriptive commit message
[ ] References issue/ticket if applicable
[ ] Follows conventional commit format

VERIFICATION
[ ] All tests pass
[ ] Build succeeds
[ ] Lint passes
[ ] No type errors

ALL CHECKBOXES MUST BE CHECKED.
```

---

## PHASE TRANSITION: DONE DEFINITION

### A phase transition is DONE when:

```
CURRENT PHASE
[ ] All phase criteria met
[ ] All required artifacts exist
[ ] All tests pass
[ ] Documentation updated

GATE APPROVAL
[ ] Human has reviewed
[ ] Human has approved transition
[ ] CURRENT_PHASE.md updated
[ ] PROJECT_STATE.md updated

HANDOFF
[ ] Next phase clearly defined
[ ] Next phase owner identified
[ ] Blockers documented
[ ] Dependencies documented

ALL CHECKBOXES MUST BE CHECKED.
```

---

## UNIVERSAL: NOT DONE IF

Work is automatically NOT DONE if any of these are true:

```
❌ Build fails
❌ Tests fail
❌ Lint errors exist
❌ Type errors exist
❌ Console warnings in our code
❌ Crashes on any interaction
❌ Invariant violation possible
❌ COLOR_SEMANTICS_LAW violated
❌ UAP gate failed
❌ Pattern not followed
❌ Spec not matched
❌ FORBIDDEN pattern detected
```

---

## HOW TO USE THIS DOCUMENT

### Before Saying "Done"

1. Find the relevant DONE DEFINITION above
2. Go through EVERY checkbox
3. If ANY is unchecked → NOT DONE
4. If ALL are checked → Report as DONE

### When Reporting Status

```
❌ WRONG:
"I think this looks good"
"This should work"
"Ready for review"

✅ CORRECT:
"DONE: EntryScreen passes all 18 checkboxes per DONE_DEFINITION.md"
"NOT DONE: UAP-5 fails (still using centered card layout)"
"BLOCKED: Cannot complete UAP-3 (missing accessibility labels)"
```

---

## THE RULE

> "Done" means ALL checkboxes checked.
>
> Not "mostly done."
> Not "basically done."
> Not "done except for..."
>
> ALL. CHECKBOXES. CHECKED.

---

**This document removes ambiguity. Either it's done or it's not.**
