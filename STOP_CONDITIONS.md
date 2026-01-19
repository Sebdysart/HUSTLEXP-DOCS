# STOP CONDITIONS — HUSTLEXP v1.0

**STATUS: ACTIVE — These rules prevent overbuilding**  
**Rule: Stop building when conditions are met. Do not improve.**

---

## PURPOSE

This document defines **when to stop building**.

Without these rules, AI tools will:
- Refactor working code
- Add "helpful" features
- Optimize prematurely
- Improve UX beyond spec
- Never declare "done"

**This document prevents that.**

---

## UNIVERSAL STOP CONDITIONS

### STOP building a screen IF:

```
✅ File exists at specified path
✅ File compiles without errors
✅ File matches spec requirements
✅ No TODO markers remain in file
✅ All required elements from spec are present
✅ Screen renders without crash
```

### STOP building a navigation stack IF:

```
✅ File exists at specified path
✅ All child screens are registered (even as stubs)
✅ Navigation compiles
✅ Stack renders without crash
```

### STOP building the entire phase IF:

```
✅ All steps in phase marked Done: [x]
✅ App compiles
✅ App runs without crash
✅ User confirms phase advancement
```

---

## DO NOT (EVER)

### ❌ DO NOT Refactor
```
- Do not reorganize imports
- Do not rename variables for "clarity"
- Do not extract components unless spec requires
- Do not move files to "better" locations
- Do not change file structure
```

### ❌ DO NOT Improve
```
- Do not add animations unless spec requires
- Do not add loading states unless spec requires
- Do not add error handling beyond spec
- Do not add accessibility features beyond spec
- Do not add comments for "documentation"
```

### ❌ DO NOT Optimize
```
- Do not memoize components
- Do not add useCallback/useMemo
- Do not lazy load
- Do not code split
- Do not measure performance
```

### ❌ DO NOT Add Features
```
- Do not add "nice to have" features
- Do not add features from other screens
- Do not add features you think are missing
- Do not add features that "make sense"
- Do not add anything not in current step spec
```

### ❌ DO NOT Suggest
```
- Do not suggest improvements
- Do not suggest "while we're here" changes
- Do not suggest future optimizations
- Do not suggest better patterns
- Do not suggest anything
```

---

## STEP COMPLETION CHECKLIST

Before marking any step `Done: [x]`, verify:

```
[ ] Output file exists at exact path specified
[ ] Output file compiles (no TypeScript errors)
[ ] Output file runs (no runtime crashes)
[ ] All spec requirements are implemented
[ ] No spec requirements are exceeded
[ ] No features added beyond spec
[ ] No "improvements" made
[ ] No TODOs left in file
[ ] Matches spec, nothing more
```

---

## PHASE GATE CHECKLIST

### Bootstrap Gate (Step 005)
```
[ ] App.tsx exists
[ ] App builds in Xcode without errors
[ ] App launches in iOS Simulator
[ ] App displays "HustleXP" text
[ ] Button exists and logs to console
[ ] App stable for 30 seconds
[ ] No crash, no freeze
```

### Navigation Gate (Step 019)
```
[ ] All 6 navigation files exist
[ ] All 38 screen stubs exist
[ ] App compiles
[ ] App runs
[ ] Navigation between stubs works
[ ] No additional screens added
[ ] No navigation logic added (just structure)
```

### Screens Gate (Step 066)
```
[ ] All 38 screens implemented (not stubs)
[ ] All screens match their specs
[ ] All screens compile
[ ] All screens render
[ ] No additional features added
[ ] No "improvements" made
```

---

## WHAT "DONE" MEANS

A screen is **DONE** when:

```
It matches the spec.
It compiles.
It renders.
It does nothing more.
```

A screen is **NOT DONE** when:

```
It has TODOs
It has console.warn about missing features
It has commented-out code
It has placeholder data that should be real
It's missing spec requirements
```

A screen is **OVER-DONE** when:

```
It has features not in spec ← THIS IS A BUG
It has animations not in spec ← THIS IS A BUG
It has error handling not in spec ← THIS IS A BUG
It has been "improved" ← THIS IS A BUG
```

---

## CURSOR BEHAVIOR RULES

When building a step:

```
1. Read the step from EXECUTION_QUEUE.md
2. Read the spec file referenced
3. Build EXACTLY what the spec says
4. Stop when spec requirements are met
5. Mark step Done: [x]
6. Do not touch the file again
```

When a step is complete:

```
✅ Move to next step
❌ Do not revisit completed steps
❌ Do not "improve" completed steps
❌ Do not refactor completed steps
❌ Do not touch completed steps at all
```

When uncertain:

```
STOP.
ASK.
DO NOT GUESS.
DO NOT "MAKE IT WORK".
DO NOT ASSUME INTENT.
```

---

## ANTI-PATTERNS TO REJECT

### "While I'm here..."
```
STOP. You are not "here" to do anything else.
Complete current step only.
```

### "This would be better if..."
```
STOP. "Better" is not your concern.
Match the spec exactly.
```

### "I noticed this could use..."
```
STOP. Your observations are not requested.
Execute the current step.
```

### "For consistency, I'll also..."
```
STOP. Consistency is handled by specs.
Do not modify other files.
```

### "This is a common pattern..."
```
STOP. Common patterns are not requested.
Follow the spec pattern.
```

### "Best practice would be..."
```
STOP. Best practices are in the spec.
If not in spec, not required.
```

---

## COMPLETION SIGNALS

### How Cursor knows a step is done:

```
1. File exists ✓
2. File compiles ✓
3. File renders ✓
4. Spec checklist complete ✓
→ Mark Done: [x]
→ STOP
→ Move to next step
```

### How Cursor knows a phase is done:

```
1. All steps marked Done: [x] ✓
2. App compiles ✓
3. App runs ✓
4. Gate checklist complete ✓
→ Update CURRENT_PHASE.md
→ STOP
→ Wait for user confirmation
```

---

## GOLDEN RULE

> **If it's not in the spec, don't build it.**
> **If it's not in the current step, don't touch it.**
> **If you're not sure, stop and ask.**

---

## ENFORCEMENT

These stop conditions are **not suggestions**.

They are **hard rules**.

Violating them means:
- Wasted time
- Scope creep
- Technical debt
- Context loss
- Project failure

**Follow them exactly.**
