# ITERATION PATTERNS — AI DEVELOPMENT WORKFLOWS

**STATUS: OPERATIONAL**
**PURPOSE: Define workflows for planning, self-review, and iterative refinement**
**LAST UPDATED: 2026-01-24**
**VERSION: 2.0.0**

---

## The Iteration Philosophy

> "Don't try to build everything at once. Build a small piece, verify it works, then build the next piece."

AI tools are most effective when working in focused, verifiable chunks rather than attempting large monolithic implementations.

---

## Pattern 1: Plan Mode Workflow

**When to Use:** Complex features, multi-file changes, architectural decisions.

### Cursor Agent (Plan Mode)

```
1. Enter Plan Mode
   └── Shift+Tab in agent input OR type "plan: {task}"

2. Research Phase
   ├── AI reads relevant specs
   ├── AI identifies affected files
   └── AI checks for existing patterns

3. Propose Plan
   ├── Step-by-step implementation order
   ├── Files to create/modify
   ├── Dependencies between steps
   └── Test strategy

4. User Review
   ├── Approve: Proceed to implementation
   ├── Modify: Adjust plan based on feedback
   └── Reject: Start over with new approach

5. Incremental Implementation
   ├── Implement Step 1
   ├── Test Step 1
   ├── Mark todo as completed
   ├── Proceed to Step 2
   └── Repeat until complete
```

### Example Plan Output

```markdown
## Plan: Implement InstantInterruptCard (iOS)

### Step 1: Create Data Model
- Create `InstantTaskData` struct
- Add public properties: title, distance, amount
- ~30 lines, no dependencies

### Step 2: Create View Structure
- Create `InstantInterruptCard.swift`
- Import SwiftUI and HustleXP design system
- Define body with glass card layout
- ~80 lines, depends on Step 1

### Step 3: Add Timer Logic
- Implement countdown state
- Add Timer publisher
- Update UI on each tick
- ~40 lines, depends on Step 2

### Step 4: Add Actions
- Implement onAccept callback
- Implement onSkip callback
- Add button press animations
- ~30 lines, depends on Step 3

### Step 5: Add Preview
- Create #Preview with sample data
- Verify in Xcode canvas
- ~15 lines, depends on Steps 1-4

### Testing Strategy
- Run `swift build` after each step
- Verify preview renders correctly
- Check against STITCH spec
```

---

## Pattern 2: Self-Review Loop

**When to Use:** After completing a major feature, before marking as "done."

### The Loop

```
┌─────────────────────────────────────────────┐
│  1. Complete Implementation                 │
│     └── All planned steps finished          │
├─────────────────────────────────────────────┤
│  2. Request Self-Review                     │
│     └── "Review this implementation for     │
│          issues, inconsistencies, or        │
│          deviation from spec"               │
├─────────────────────────────────────────────┤
│  3. Receive Feedback Report                 │
│     ├── Issues found                        │
│     ├── Suggested fixes                     │
│     └── Confidence level                    │
├─────────────────────────────────────────────┤
│  4. Apply Fixes                             │
│     └── New session recommended for         │
│          fresh context                      │
├─────────────────────────────────────────────┤
│  5. Re-run Tests                            │
│     └── Verify all checks pass              │
└─────────────────────────────────────────────┘
```

### Self-Review Prompts

```
Prompt 1: Architecture Review
"Review the architecture of {files} for:
- Violation of layer boundaries
- Inconsistent patterns
- Missing error handling
- Potential performance issues"

Prompt 2: Spec Compliance Review
"Compare {implementation} against {spec_file} for:
- Missing features
- Incorrect behavior
- UI/UX deviations
- Edge cases not handled"

Prompt 3: Color Semantics Review
"Review {files} for color compliance:
- Green on entry screens (FORBIDDEN)
- Card layouts on entry screens (FORBIDDEN)
- Colors match COLOR_SEMANTICS_LAW.md
- Design tokens from DESIGN_SYSTEM.md"

Prompt 4: Security Review
"Review {files} for security issues:
- Input validation
- Authentication checks
- Data exposure risks
- Injection vulnerabilities"
```

### Example Feedback Report

```markdown
## Self-Review: InstantInterruptCard.swift

### Issues Found: 3

#### Issue 1: Missing Timer Cleanup (Medium)
- Location: Line 45
- Problem: Timer not invalidated on view disappear
- Fix: Add `.onDisappear { timer?.invalidate() }`

#### Issue 2: Hardcoded Color (Low)
- Location: Line 78
- Problem: Using `Color.orange` instead of `HustleColors`
- Fix: Replace with `Color.appleOrange`

#### Issue 3: Missing Accessibility (Medium)
- Location: Lines 60-75
- Problem: Buttons lack accessibility labels
- Fix: Add `.accessibilityLabel()` modifiers

### Confidence: 85%
- High confidence on issues 1-2
- Medium confidence on issue 3 (spec doesn't mention a11y)

### Recommendation
Apply fixes 1-2 immediately. Discuss fix 3 with user.
```

---

## Pattern 3: Iterate on Lints

**When to Use:** During and after code generation.

### Setup (Cursor)

```
Settings → Features → Enable "Iterate on Lints"
```

### Workflow

```
1. AI generates code
2. ESLint/TypeScript runs automatically
3. If errors found:
   └── AI reads error messages
   └── AI applies auto-fixes
   └── Process repeats until clean
4. Human reviews final diff
```

### Supported Linters

| Tool | Auto-Fix | AI Iteration |
|------|----------|--------------|
| ESLint | Yes | Yes |
| Prettier | Yes | Yes |
| TypeScript | No | Yes (manual fix) |
| SwiftLint | Yes | Yes |
| Swift Format | Yes | Yes |

---

## Pattern 4: Bite-Sized Tasks

**When to Use:** Always. This is the default approach.

### The Rule

```
No single AI task should:
- Touch more than 5 files
- Exceed 200 lines of changes
- Take more than one "step" in the execution queue
```

### Breaking Down Large Tasks

```
BAD: "Implement the entire onboarding flow"

GOOD:
1. "Implement FramingScreen structure"
2. "Add FramingScreen navigation"
3. "Implement CalibrationScreen structure"
4. "Add CalibrationScreen quiz logic"
5. ... (continue for each screen)
```

### Checkpoint Pattern

```
After each bite:
├── Build (swift build / npm run build)
├── Test (swift test / npm test)
├── Review (quick visual check)
└── Mark todo complete
```

---

## Pattern 5: Spec-First Implementation

**When to Use:** Every screen/feature implementation.

### Workflow

```
1. Read Spec
   └── Find relevant spec file in screens-spec/ or specs/

2. Extract Requirements
   ├── Data model (props interface)
   ├── UI structure (component hierarchy)
   ├── Interactions (callbacks, state changes)
   └── Edge cases (empty, error, loading)

3. Implement in Order
   ├── Data model first (types)
   ├── Static UI second (layout)
   ├── Interactions third (handlers)
   └── Edge cases last (states)

4. Validate Against Spec
   └── Checklist comparison
```

### Spec Compliance Checklist

```markdown
## Spec Compliance: {ScreenName}

### Data Model
- [ ] All props defined
- [ ] Types match spec
- [ ] Optional/required correct

### UI Structure
- [ ] All components present
- [ ] Layout matches spec
- [ ] Design tokens used (no hardcoding)
- [ ] Colors match COLOR_SEMANTICS_LAW.md

### Interactions
- [ ] All callbacks implemented
- [ ] State changes correct
- [ ] Animations match spec

### Edge Cases
- [ ] Empty state handled
- [ ] Error state handled
- [ ] Loading state handled
```

---

## Pattern 6: Fresh Context Sessions

**When to Use:** After major changes or when encountering confusion.

### Signs You Need Fresh Context

```
- AI contradicting previous statements
- AI forgetting recent changes
- AI suggesting already-rejected approaches
- AI unable to find files it just created
- Conversation exceeds 50 messages
- AI violating PER gates or HIC
```

### Fresh Start Protocol

```
1. Summarize current state
   └── "We've completed X, Y, Z. Next is A."

2. Save summary to file (optional)
   └── Update TODO or EXECUTION_QUEUE.md

3. Start new session
   └── Load foundation context (Level 1)
   └── Reference summary

4. Continue from checkpoint
```

---

## Pattern 7: HIC-Compliant Iteration

**When to Use:** Every Cursor response (mandatory).

### Workflow

```
1. User Request Received

2. Execute HIC
   ├── STEP 0: Repo Re-anchor (read PER documents)
   ├── STEP 1: Cold Start Verification (output proof)
   ├── STEP 2: Protocol Classification (ONE mode)
   ├── STEP 3: Legality Check
   ├── STEP 4: Plan (if implementation)
   └── STEP 5: Execute or Stop

3. Output with HIC Header

4. Self-Check Before Completion
   └── Run PER/SELF_CHECK.md checklist
```

---

## Pattern 8: Parallel Exploration

**When to Use:** Uncertain about approach, need to compare options.

### Workflow

```
Session A: Approach 1
├── Implement solution using Pattern X
├── Note pros/cons
└── Save as branch or draft

Session B: Approach 2
├── Implement solution using Pattern Y
├── Note pros/cons
└── Save as branch or draft

Comparison Session:
├── Load both approaches
├── Compare against requirements
└── Select winner
```

---

## Anti-Patterns (What NOT to Do)

### Anti-Pattern 1: Monolithic Implementation

```
❌ "Implement the entire hustler dashboard with all features"
✅ "Implement HustlerHomeScreen header section"
```

### Anti-Pattern 2: Skipping Plan Mode

```
❌ Jump straight to coding complex features
✅ Always plan multi-file changes first
```

### Anti-Pattern 3: Ignoring Lint Errors

```
❌ Accumulate errors and fix later
✅ Fix each error before proceeding
```

### Anti-Pattern 4: Stale Context

```
❌ Continue 100+ message session without refresh
✅ Start fresh after major milestones
```

### Anti-Pattern 5: No Verification

```
❌ Trust AI output without checking
✅ Always build, test, and review
```

### Anti-Pattern 6: Skipping HIC

```
❌ Output without HIC header (response is INVALID)
✅ Every response begins with HIC verification
```

### Anti-Pattern 7: Repeating Rejected Approaches

```
❌ Try card layout again for entry screen
✅ Check REJECTED_APPROACHES.md first
```

---

## Cross-References

- `AGENT_AUTONOMY_BOUNDARIES.md` — What AI can do
- `CONTEXT_MANAGEMENT_GUIDE.md` — How to load context
- `EXECUTION_QUEUE.md` — Build order
- `PER/INVOCATION_COMMAND.md` — HIC specification
- `PER/SELF_CHECK.md` — Pre-output verification
- `PER/REJECTED_APPROACHES.md` — Anti-loop protection
- `.cursorrules` — Cursor patterns
- `.claude/instructions.md` — Claude Code patterns

---

**Iteration beats perfection.**
**Small verified steps beat large uncertain leaps.**
