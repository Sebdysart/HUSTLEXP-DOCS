# AUTHORITY LADDER — AMBIGUITY RESOLUTION ORDER

**STATUS: CONSTITUTIONAL**
**PURPOSE: Eliminate guessing by defining resolution hierarchy**
**RULE: GUESSING IS FORBIDDEN**

---

## WHY THIS EXISTS

AI encounters ambiguity and wants to:
- Guess "reasonable defaults"
- Fill gaps with "common patterns"
- Produce *valid but wrong* output

This document eliminates that behavior entirely.

---

## THE LADDER (NON-NEGOTIABLE)

When ambiguity exists, AI MUST resolve in this exact order:

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: PROJECT_STATE.md                                       │
│          What phase are we in? What's the current focus?        │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 2: PUZZLE_MODE.md (FOR UI WORK)                           │
│          What layer are we working at? (0-4)                    │
│          What permissions does this layer have?                 │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 3: EXECUTION_CONSTITUTION.md                              │
│          How should AI behave in this situation?                │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 4: DICTIONARY.md                                          │
│          What does this term mean in this project?              │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 5: Relevant SPEC file or CONTRACT file                    │
│          What does the specification say?                       │
│          (BOOTSTRAP.md, screens-spec/*, *.contract.md, etc.)    │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 6: DONE_DEFINITION.md                                     │
│          What are the completion criteria?                      │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 7: ui-puzzle/* or reference/components/*                  │
│          Is there an existing pattern to copy?                  │
│          If answer is here → USE IT                             │
├─────────────────────────────────────────────────────────────────┤
│  STEP 8: STOP → ASK → DO NOT IMPLEMENT                          │
│          If ambiguity persists after steps 1-7:                 │
│          → STOP immediately                                     │
│          → ASK the user for clarification                       │
│          → DO NOT guess or implement                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## THE RULE

> **GUESSING IS FORBIDDEN.**
>
> If you reach Step 7, you STOP.
> You do not "use best judgment."
> You do not "apply common patterns."
> You do not "make reasonable assumptions."
>
> You STOP and ASK.

---

## EXAMPLES

### Example 1: Color Ambiguity

**Question:** "What color should this button be?"

```
Step 1: PROJECT_STATE.md
        → Current Focus: EntryScreen
        → Entry screens use purple brand

Step 2: EXECUTION_CONSTITUTION.md
        → Use tokens from reference/constants/

Step 3: DICTIONARY.md
        → Brand = Black + Purple, NOT green

RESOLVED at Step 3: Button is #5B2DFF (brand purple)
```

### Example 2: Layout Ambiguity

**Question:** "Should this be centered or full-width?"

```
Step 1: PROJECT_STATE.md
        → Current Focus: EntryScreen
        → UAP-5 required (Full-Canvas Immersion)

Step 2: EXECUTION_CONSTITUTION.md
        → Entry screens cannot use centered card layouts

Step 3: DICTIONARY.md
        → Full-Canvas = content flows top-to-bottom, not centered

RESOLVED at Step 3: Full-width layout, NOT centered
```

### Example 3: Unresolved Ambiguity

**Question:** "Should the logo animate left-to-right or fade-in?"

```
Step 1: PROJECT_STATE.md
        → Doesn't specify animation direction

Step 2: EXECUTION_CONSTITUTION.md
        → UAP-2 requires animations < 300ms, doesn't specify direction

Step 3: DICTIONARY.md
        → Doesn't specify animation direction

Step 4: BOOTSTRAP.md
        → Mentions "logo fade-in animation (300ms)"

RESOLVED at Step 4: Fade-in animation, not left-to-right
```

### Example 4: True Ambiguity (STOP)

**Question:** "What icon should we use for the settings button?"

```
Step 1-7: No answer found

Step 8: STOP → ASK

AI Response: "The spec doesn't specify which icon to use for settings.
Should I use:
A) SF Symbol 'gearshape'
B) SF Symbol 'gearshape.fill'
C) A different icon?"

WAIT for user response before proceeding.
```

### Example 5: Puzzle Layer Ambiguity

**Question:** "Can I add a new animation to this screen?"

```
Step 1: PROJECT_STATE.md
        → Working on EntryScreen
        → UI work in progress

Step 2: PUZZLE_MODE.md
        → Screen = Layer 4
        → Layer 4 permissions: "New Motion: NONE"
        → Animation must come from lower layers

RESOLVED at Step 2: NO. Screen layer cannot add new animations.
Animation must be defined in an Atom (Layer 1) first.
```

### Example 6: Molecule Composition

**Question:** "Can I use this color directly in the molecule?"

```
Step 1: PROJECT_STATE.md
        → Building molecule

Step 2: PUZZLE_MODE.md
        → Molecule = Layer 2
        → Layer 2 must use Layer 0 tokens only
        → Check ui-puzzle/tokens/colors.swift

RESOLVED at Step 2: Must use PuzzleColors token, not raw hex value.
```

---

## ANTI-PATTERNS

### ❌ FORBIDDEN: "Best Guess"

```
"The spec doesn't say, but it's probably X..."
→ FORBIDDEN
```

### ❌ FORBIDDEN: "Common Pattern"

```
"Most apps do it this way, so I'll do that..."
→ FORBIDDEN
```

### ❌ FORBIDDEN: "Reasonable Assumption"

```
"It makes sense that they'd want X..."
→ FORBIDDEN
```

### ❌ FORBIDDEN: "I'll Just Try"

```
"Let me implement something and we can adjust..."
→ FORBIDDEN
```

---

## ESCALATION FORMAT

When you reach Step 7 (STOP → ASK), use this format:

```
AMBIGUITY DETECTED

Context: [What you were trying to do]

Question: [The specific ambiguity]

Options (if applicable):
A) [Option 1]
B) [Option 2]
C) [Other - describe what you need]

Source documents checked:
- PROJECT_STATE.md: [not found / what was found]
- EXECUTION_CONSTITUTION.md: [not found / what was found]
- DICTIONARY.md: [not found / what was found]
- [Relevant SPEC]: [not found / what was found]

Awaiting clarification before proceeding.
```

---

## THE GUARANTEE

Following this ladder guarantees:

1. **No guessing** — Every decision has a documented source
2. **Traceability** — Every choice can be traced to authority
3. **Consistency** — Same question always yields same answer
4. **Quality** — No "valid but wrong" output

---

**If you cannot find the answer in Steps 1-6, you STOP.**
**Guessing is not allowed. Period.**
