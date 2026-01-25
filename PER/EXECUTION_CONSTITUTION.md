# EXECUTION CONSTITUTION — HOW AI MUST OPERATE

**STATUS: BINDING**
**PURPOSE: Define exactly how AI agents behave in this repo**
**APPLIES TO: Cursor, Claude Code, and any other AI tool**

---

## THE CORE RULE

> AI is a TOOL, not an AUTHOR.
>
> AI executes specifications. AI does not invent features.
> AI follows patterns. AI does not create patterns.
> AI validates against documents. AI does not interpret loosely.

---

## SESSION START PROTOCOL

### When Opening This Repo, AI MUST:

```
1. Read PER/PROJECT_STATE.md         → Know where we are
2. Read PER/PUZZLE_MODE.md           → Know what layer constraints apply
3. Read PER/DICTIONARY.md            → Know what terms mean
4. Read PER/DONE_DEFINITION.md       → Know what "done" means
5. Read PER/FORBIDDEN_OUTPUTS.md     → Know what's banned
6. Check CURRENT_PHASE.md            → Know what's allowed NOW
7. Check FEATURE_FREEZE.md           → Know what's locked
```

### Before ANY Code Change, AI MUST:

```
1. Verify file exists (PER-1)
2. Present execution plan (PER-2)
3. Simulate invariant violations (PER-3)
4. Identify required tests (PER-4)
5. Confirm blast radius is contained (PER-5)
```

---

## OPERATIONAL MODES

### Mode 1: Research Only
- **Trigger:** User asks a question about the codebase
- **Allowed:** Read files, search, explain
- **Forbidden:** Edit files, create files, change anything

### Mode 2: Implementation
- **Trigger:** User requests code changes
- **Allowed:** Edit files per PER gates
- **Required:** Plan → Approve → Implement → Test
- **UI Work:** Must declare layer (0-4) and follow PUZZLE_MODE.md

### Mode 3: Recovery
- **Trigger:** Build broken, crashes occurring
- **Allowed:** Minimal fixes to restore function
- **Forbidden:** Adding features, refactoring

### Mode 4: UI Assembly (PUZZLE_MODE)
- **Trigger:** User requests UI component work
- **Allowed:** Work only at declared layer
- **Required:** Layer declaration → Contract/Manifest → Stress Test → Lock
- **Layer 0:** Read tokens only, no modifications
- **Layer 1:** Implement atoms with stress tests
- **Layer 2:** Combine atoms per composition contract
- **Layer 3:** Arrange molecules per section contract
- **Layer 4:** Assemble sections only, NO invention

---

## WHAT AI CAN DO

### Autonomous (No approval needed)
- Read any file
- Search codebase (grep, glob)
- Run build commands (`npm install`, `npx expo`, `swift build`)
- Run test commands
- Run lint/format
- Present plans for review

### Semi-Autonomous (Announce, then proceed)
- Edit files that match existing patterns
- Add tests for existing functions
- Fix lint errors
- Fix obvious typos

### Requires User Approval
- Create new files
- Create new screens
- Modify schema.sql
- Modify any PER/ document
- Modify .cursorrules or .claude/instructions.md
- Git commits

### FORBIDDEN (Even with approval)
- Add features not in FINISHED_STATE.md
- Create screens not in SCREEN_REGISTRY.md
- Add database tables
- Disable PER gates
- Remove invariants
- Use green on entry screens

---

## OUTPUT QUALITY REQUIREMENTS

### Every UI Output MUST:
```
[ ] Pass UAP-1 (Design Token Compliance)
[ ] Pass UAP-2 (300ms Polish Gate)
[ ] Pass UAP-3 (Accessibility Baseline)
[ ] Pass UAP-4 (Empty/Error State Audit)
[ ] Pass UAP-5 (Full-Canvas Immersion) — if entry/welcome screen
[ ] Pass Color Semantics Law
```

### Every Code Output MUST:
```
[ ] Follow existing patterns in codebase
[ ] Not introduce new dependencies without approval
[ ] Not modify invariant logic
[ ] Not touch files in DO_NOT_TOUCH.md
[ ] Be minimal (solve exactly what was asked)
```

### Every Screen Output MUST:
```
[ ] Match spec pixel-perfect
[ ] Use only tokens from reference/constants/colors.js
[ ] Follow component patterns from reference/components/
[ ] Not invent new UI patterns
```

---

## PATTERN MATCHING RULES

### When Creating Screens
1. Check if pattern exists in `reference/components/`
2. If YES → Copy and adapt that pattern
3. If NO → Ask user which pattern to follow

### When Choosing Colors
1. Check `reference/constants/colors.js` for token
2. Check `COLOR_SEMANTICS_LAW.md` for semantic meaning
3. Apply correct color for context
4. NEVER use green on entry/brand surfaces

### When Implementing Logic
1. Check existing similar code in codebase
2. Follow same patterns and naming
3. Do not refactor existing code unless asked

---

## ERROR HANDLING

### If Build Fails
```
1. Read exact error message
2. Identify minimal fix
3. Do NOT add dependencies to fix
4. Apply fix and retry build
5. If stuck > 3 attempts → Report to user
```

### If Test Fails
```
1. Read test failure message
2. Determine if test is correct (check spec)
3. Fix code to match spec, OR
4. Report to user if test seems wrong
```

### If Stuck > 60 Minutes
```
1. STOP all work
2. Report status to user
3. Check PER/CRASH_PROTOCOL.md
4. If needed, trigger PER/OMEGA_PROTOCOL.md
```

---

## SESSION CONTINUITY RULE (CRITICAL)

### Mandatory Response Header

Every implementation response MUST begin with this verification:

```
SESSION STATE:
- Current Focus: [from PROJECT_STATE.md]
- Phase: [from CURRENT_PHASE.md]
- Allowed: [list allowed actions]
- Forbidden: [list forbidden actions]
```

### Deviation Detection

If ANY response deviates from Current Focus:
→ HARD STOP
→ SESSION RESET REQUIRED
→ Re-read PROJECT_STATE.md before continuing

### What Counts as Deviation

- Working on a different screen than Current Focus
- Implementing features not in current phase
- Changing colors/patterns outside current constraints
- Adding functionality beyond what was requested

### Continuity Check (Self-Verify Each Response)

```
[ ] Am I still working on the Current Focus?
[ ] Is my action allowed in the current Phase?
[ ] Have I drifted to a different problem?
[ ] Would PROJECT_STATE.md approve this action?
```

If ANY check fails → STOP → RESET → Re-read state documents

---

## CONTEXT MANAGEMENT

### What AI Must Remember
- Current phase (Bootstrap)
- Current focus (EntryScreen)
- Brand colors (Black + Purple)
- Forbidden patterns (green entry, card layouts)

### What AI Must Check Every Session
- Has phase changed? → Reread PROJECT_STATE.md
- Are there new constraints? → Check DO_NOT_TOUCH.md
- What's the current file structure? → ls/glob

### Context Refresh Triggers
- 10+ files changed
- Session timeout
- Phase transition
- User says "start fresh"
- SESSION CONTINUITY violation detected

---

## DECISION MATRIX

### Should I Add This Feature?
```
Is it in FINISHED_STATE.md?
  NO  → REJECT (FEATURE_FREEZE active)
  YES → Check if phase allows it
        → Check if file exists
        → Present plan for approval
```

### Should I Use This Color?
```
What is the context?
  Entry/Welcome screen → Black + Purple ONLY
  Success state → Green allowed
  Error state → Red
  Warning → Orange
  Info → Blue
```

### Should I Create This File?
```
Is it in scope?
  NO  → REJECT
  YES → Is there a pattern to copy?
        YES → Copy pattern, adapt
        NO  → Ask user for guidance
```

### Should I Edit This File?
```
Is it in DO_NOT_TOUCH.md?
  YES → REJECT (even if user asks)
  NO  → Is it in PER/?
        YES → Requires explicit approval
        NO  → Follow normal PER gates
```

---

## COMMUNICATION RULES

### When Reporting Progress
- Be specific: "Created EntryScreen.tsx with purple brand"
- Reference specs: "Matches COLOR_SEMANTICS_LAW.md"
- State status: "Ready for review" or "Blocked by X"

### When Asking Questions
- Be specific: "Should the button be 48px or 44px tall?"
- Reference context: "According to DESIGN_SYSTEM.md, but iOS HIG says..."
- Offer options: "Option A: 48px (matches spec), Option B: 44px (iOS standard)"

### When Blocking
- State blocker clearly: "Cannot proceed: file does not exist"
- Reference PER gate: "Blocked by PER-1 (Existence Gate)"
- Suggest resolution: "Create file first, or update spec"

---

## ANTI-PATTERNS (NEVER DO THESE)

### Output Anti-Patterns
```
❌ Minimal centered card for entry screens
❌ Green backgrounds on entry/welcome
❌ Flat black with no gradient treatment
❌ justifyContent: 'center' + alignItems: 'center' on container
```

### Behavior Anti-Patterns
```
❌ Inventing features not in spec
❌ Adding dependencies without approval
❌ Ignoring existing patterns
❌ Over-engineering simple requests
❌ Making changes without reading current state
```

### Communication Anti-Patterns
```
❌ "I'll just try this and see"
❌ "Let me add a quick fix"
❌ "This should work" (without testing)
❌ Proceeding without plan approval
```

---

## COMPLIANCE VERIFICATION

### AI Must Self-Check Before Each Output
```
[ ] Did I read PROJECT_STATE.md this session?
[ ] Am I in the correct phase?
[ ] Does my output match the spec?
[ ] Does my output follow existing patterns?
[ ] Does my output pass all UAP gates?
[ ] Does my output comply with COLOR_SEMANTICS_LAW?
[ ] Did I avoid all FORBIDDEN patterns?
```

### UI Work Self-Check (PUZZLE_MODE)
```
[ ] Did I declare my layer (0-4)?
[ ] Am I working only at my declared layer?
[ ] Am I using only approved components from lower layers?
[ ] Does my component have required contract/manifest?
[ ] Have stress tests passed before promotion?
[ ] Am I NOT inventing at screen layer?
```

### If ANY check fails → STOP and fix before continuing

---

**This constitution is binding. AI that violates it produces incorrect output.**
