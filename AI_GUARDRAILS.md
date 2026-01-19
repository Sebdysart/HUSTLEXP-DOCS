# AI GUARDRAILS — HUSTLEXP

**STATUS: ACTIVE — Both Claude Code and Cursor must obey**  
**Purpose: Prevent AI drift, hallucination, and scope creep**

---

## THE PRIME DIRECTIVE

> **AI tools execute. They do not design.**

The product is defined in `FINISHED_STATE.md`.  
The screens are defined in `SCREEN_REGISTRY.md`.  
The schema is defined in `schema.sql`.

**AI implements what exists. AI does not invent what doesn't.**

---

## AI GOVERNANCE RULE (In-Product)

> **AI features in v1 are ASSISTIVE ONLY.**
> 
> AI may suggest, summarize, clarify, or classify.
> AI may NOT autonomously act, decide, message, or transact.
> 
> The human always confirms. The human always decides.

---

## AI TASK CREATION ASSISTANT — SPECIFIC RULES

### The Goal
Ensure every task has **crystal clear execution instructions** before posting.

### Required Behavior: Clarifying Questions

When a poster creates a task, AI MUST ask clarifying questions if the description is ambiguous:

```
REQUIRED QUESTIONS (ask as needed):
1. "What specific outcome marks this as complete?"
2. "Are there any tools/materials the hustler needs to bring?"
3. "What's the exact location/address?"
4. "Any time constraints or deadlines?"
5. "What should the hustler do if [common issue for this task type]?"
```

### When to Ask Questions

```
ALWAYS ASK if:
- Description is < 50 characters
- No completion criteria specified
- Location is vague ("my house" vs specific address)
- Time/deadline not mentioned
- Task type typically needs specific tools

SKIP questions if:
- All required info is already present
- User explicitly says "no questions needed"
- Repeat task from template (already clarified)
```

### AI Task Assistant Capabilities

```
✅ MAY DO:
- Suggest task title based on description
- Suggest category based on content
- Suggest duration estimate
- Suggest trust tier / risk level
- Suggest price range ("Suggested: $X-$Y")
- Ask clarifying questions
- Rewrite vague descriptions into clear instructions
- Score task clarity (1-5)
- Flag ambiguous requirements
- Show "AI Assisted" badge on helped tasks

❌ MAY NOT DO:
- Auto-submit without poster review
- Set price automatically (only suggest)
- Skip clarifying questions when needed
- Create tasks autonomously
- Send any messages
```

### Task Creation Enforcement Rule

> "AI may enforce clarification requirements but may NOT reduce, skip, or reinterpret required execution fields."

```
❌ AI may NOT invent new required questions (use TASK_CLARIFICATION_QUESTION_BANK.md)
❌ AI may NOT waive required questions
❌ AI may NOT accept ambiguous answers
❌ AI may NOT skip blocking fields
❌ AI may NOT allow "post anyway" for incomplete tasks
✅ AI may ONLY select from static question banks per category
✅ AI may ONLY enforce requirements defined in TASK_EXECUTION_REQUIREMENTS.md
```

**See:**
- `TASK_EXECUTION_REQUIREMENTS.md` — Required fields per category
- `TASK_CLARIFICATION_QUESTION_BANK.md` — Static question banks
- `TASK_CREATION_STATE_MACHINE.md` — State transitions

---

## UNIVERSAL RULES (Both Tools)

### Rule 1: No Inventing Features
```
❌ FORBIDDEN: "I'll add a feature that would improve..."
❌ FORBIDDEN: "It would be better if we also..."
❌ FORBIDDEN: "Users might want..."
❌ FORBIDDEN: "While I'm here, I could also..."

✅ REQUIRED: "This feature is not in FINISHED_STATE.md. Should I add it?"
✅ REQUIRED: "This screen is not in SCREEN_REGISTRY.md. Should I create it?"
```

### Rule 2: No Suggesting Improvements
```
❌ FORBIDDEN: "Here's a better way to structure this..."
❌ FORBIDDEN: "I recommend adding..."
❌ FORBIDDEN: "Best practice would be to..."

✅ ALLOWED: "The spec says X. I will implement X."
✅ ALLOWED: "The spec is unclear about Y. Please clarify."
```

### Rule 3: No Filling Gaps
```
❌ FORBIDDEN: Assuming what a missing field should be
❌ FORBIDDEN: Creating mock data that implies behavior
❌ FORBIDDEN: Adding "helper" functions not in spec

✅ REQUIRED: "The spec doesn't define this. What should it be?"
✅ REQUIRED: "I need this data but it's not in the props interface."
```

### Rule 4: Stop on Uncertainty
```
❌ FORBIDDEN: Guessing and continuing
❌ FORBIDDEN: "I'll assume you meant..."
❌ FORBIDDEN: Making "reasonable" decisions

✅ REQUIRED: STOP
✅ REQUIRED: State what's unclear
✅ REQUIRED: Wait for user response
```

---

## CLAUDE CODE SPECIFIC GUARDRAILS

### Boundary: Layers 0-2 Only
```
✅ Layer 0: Database (your domain)
✅ Layer 1: Backend services (your domain)
✅ Layer 2: API endpoints (your domain)
❌ Layer 3+: Frontend (NOT your domain)
```

### AI Backend Implementation Rules
```
✅ Build AI suggestion endpoints
✅ Build clarifying question logic
✅ Build task clarity scoring
✅ Build price suggestion algorithm
✅ Return suggestions, not decisions
❌ Never auto-execute AI suggestions
❌ Never let AI write to ledgers directly
❌ Never let AI send messages for users
```

### Forbidden Actions
```
❌ Creating React components
❌ Suggesting UI changes
❌ "Helping" with screens
❌ Defining frontend data shapes
❌ Bypassing database constraints
❌ Letting AI make decisions (AI proposes only)
```

### Required Behavior
```
✅ Check FINISHED_STATE.md before implementing
✅ Check schema.sql before adding tables
✅ Write kill tests for invariants
✅ Enforce the 5 invariants always
✅ Ask user if feature not in FINISHED_STATE
```

---

## CURSOR SPECIFIC GUARDRAILS

### Boundary: UI Shells Only
```
✅ Props interfaces
✅ Loading states
✅ Empty states
✅ Display logic
❌ Business logic
❌ Data fetching
❌ Eligibility computation
```

### AI UI Display Rules
```
✅ Show AI suggestions clearly labeled
✅ Show clarifying questions as form fields
✅ Show "Suggested: $X-$Y" for pricing
✅ Show clarity score with explanation
✅ Allow user to edit/reject all suggestions
✅ Require confirmation before posting
❌ Auto-accept AI suggestions
❌ Hide that content is AI-generated
❌ Submit without user review
```

### Forbidden Actions
```
❌ Creating screens not in SCREEN_REGISTRY
❌ Adding npm dependencies without approval
❌ Computing eligibility, XP, trust, pricing
❌ Making API calls from screens
❌ Inventing data fields
❌ Modifying navigation structure
```

### Required Behavior
```
✅ Check SCREEN_REGISTRY.md before creating screens
✅ Check FINISHED_STATE.md before implementing features
✅ Use only existing design tokens
✅ Use only existing shared components
✅ Ask user if screen not in registry
```

---

## THE VALIDATION CHECKLIST

Before implementing ANYTHING, both tools must verify:

### For Features
```
[ ] Is this feature in FINISHED_STATE.md?
    YES → Proceed
    NO  → STOP. Ask user.
```

### For Screens
```
[ ] Is this screen in SCREEN_REGISTRY.md?
    YES → Proceed
    NO  → STOP. Ask user.
```

### For Tables
```
[ ] Is this table in schema.sql?
    YES → Proceed
    NO  → STOP. Ask user.
```

### For Components
```
[ ] Does this component exist in reference/components/?
    YES → Use it
    NO  → STOP. Ask user if should create.
```

---

## HALLUCINATION PREVENTION

### Common Hallucinations to Reject

```
❌ "The user probably wants..."
   → You don't know what the user wants. Ask.

❌ "This is a standard pattern..."
   → Standards don't override specs. Follow specs.

❌ "It makes sense to also add..."
   → It makes sense to implement what's defined. Nothing more.

❌ "I'll include this for completeness..."
   → Completeness is defined by FINISHED_STATE, not your judgment.

❌ "Best practice suggests..."
   → Best practice is to follow the spec exactly.
```

### How to Handle Ambiguity

```
1. State what's ambiguous
2. State what you would do if you had to guess
3. Ask: "Is this correct, or should I do something else?"
4. Wait for answer
5. Do NOT proceed without answer
```

---

## ENFORCEMENT MECHANISM

### Self-Check Questions (Ask Before Every Action)

1. **Is this in FINISHED_STATE.md?**
2. **Is this in SCREEN_REGISTRY.md?** (if screen)
3. **Is this in schema.sql?** (if table)
4. **Am I inventing or implementing?**
5. **Am I in my layer/domain?**
6. **Did the user explicitly ask for this?**

If ANY answer is NO or UNCLEAR → **STOP and ask.**

---

## THE GOAL

When these guardrails are followed:
- No drift
- No hallucination
- No scope creep
- Predictable execution
- User controls the product, not AI

**AI is a tool. Tools don't have opinions. Tools execute.**
