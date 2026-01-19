# Poster AI Task Card — Interactive Completion System (Max Tier)

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Transform task creation from enrichment to contract-completion

---

## §0. Executive Summary

This specification defines the **AI Task Completion System**, a contract-completion engine that ensures **zero ambiguity before escrow is funded**.

**Core Principle (LOCK THIS):**
> **AI does not chat.  
> AI closes gaps in a contract.**

The goal is not conversation.  
The goal is **zero ambiguity before escrow is funded**.

**What This Unlocks:**
- Cleanest tasks in the market
- Directly drives fulfillment speed
- Increases trust
- Increases repeat usage
- Prevents disputes **before** money moves

---

## §1. System Role Definition

### 1.1 AI Role

**AI role:**
A compliance-oriented task completion assistant.

**AI is allowed to:**
- Detect missing or ambiguous fields
- Ask **targeted**, minimal clarification questions
- Suggest defaults based on task class
- Enforce required constraints

**AI is NOT allowed to:**
- Ask open-ended questions
- Negotiate on behalf of either party
- Change confirmed fields
- Ask questions after escrow is funded

### 1.2 Authority Model

Per `AI_INFRASTRUCTURE.md`, this system operates at **A1 (Advisory)** authority:
- AI proposes completions
- Poster confirms or edits
- AI cannot auto-accept
- AI cannot bypass poster confirmation

---

## §2. Task Completion State Machine

### 2.1 States

The task card exists in **four AI states** before posting:

```
DRAFT → INCOMPLETE → COMPLETE → LOCKED
```

### 2.2 State Definitions

| State | Description | AI Questions Allowed | Escrow Allowed | Can Edit Fields |
|-------|-------------|---------------------|----------------|-----------------|
| **DRAFT** | Initial creation, minimal fields | ✅ Yes | ❌ No | ✅ Yes |
| **INCOMPLETE** | Missing required fields | ✅ Yes | ❌ No | ✅ Yes |
| **COMPLETE** | All required fields satisfied, zero ambiguity | ❌ No | ✅ Yes | ✅ Yes (until escrow funded) |
| **LOCKED** | Escrow funded, task posted | ❌ No | ✅ Already funded | ❌ No (terminal) |

### 2.3 State Transitions

```
POSTER CREATES TASK
    ↓
[DRAFT] (minimal input)
    ↓
AI analyzes confidence
    ↓
IF confidence < 0.85:
    ↓
[INCOMPLETE] → AI asks question → POSTER answers → [INCOMPLETE or COMPLETE]
    ↓
IF confidence ≥ 0.85:
    ↓
[COMPLETE] → AI proposes → POSTER confirms/edits → [COMPLETE]
    ↓
POSTER funds escrow
    ↓
[LOCKED] (immutable)
```

### 2.4 Transition Rules

| Transition | Guard | Enforcement |
|------------|-------|-------------|
| DRAFT → INCOMPLETE | Missing required field OR confidence < 0.85 | Backend AI analysis |
| INCOMPLETE → COMPLETE | All required fields present AND confidence ≥ 0.85 | Backend AI analysis |
| COMPLETE → LOCKED | Escrow funded | DB trigger (HX201) |
| LOCKED → (any) | ❌ Forbidden | Terminal state (HX001) |

### 2.5 Server-Side Enforcement

**Rule:** State machine transitions must be enforced server-side.

```typescript
// Backend validation
if (task.state === 'LOCKED') {
  throw new InvariantViolation('HX001', 'Task is locked after escrow funding');
}

if (task.ai_completion_state === 'LOCKED' && fieldUpdate) {
  throw new InvariantViolation('HX001', 'Cannot edit task after escrow funding');
}
```

---

## §3. Confidence Threshold Rule

### 3.1 Core Rule

AI questions are triggered **only if required fields cannot be inferred with sufficient confidence**.

```
IF confidence < 0.85 → ASK
IF confidence ≥ 0.85 → AUTO-FILL + CONFIRM
```

### 3.2 Confidence Calculation

Confidence is calculated per **field cluster**, not per field:

| Field Cluster | Required Fields | Confidence Source |
|---------------|----------------|-------------------|
| **Location** | start_location, end_location (if moving), location_clarity | Geo-parsing, context analysis |
| **Time** | deadline, time_window, live_mode_eligible | Date parsing, urgency signals |
| **Scope** | description_clarity, complexity, stairs_involved | NLP analysis, task class inference |
| **Proof** | proof_type, proof_requirements | Task class defaults, poster preference |

### 3.3 Confidence Thresholds

| Confidence Level | Action | UI Behavior |
|-----------------|--------|-------------|
| **< 0.60** | Ask question (required) | Red indicator, question mandatory |
| **0.60 - 0.85** | Ask question (recommended) | Amber indicator, question suggested |
| **≥ 0.85** | Auto-fill + confirm | Green indicator, proposal shown |

### 3.4 What This Prevents

- ❌ Over-questioning
- ❌ Friction
- ❌ "Chatbot fatigue"
- ❌ Unnecessary back-and-forth

---

## §4. Question Types (Strictly Limited)

AI questions fall into **four and only four categories**. No exceptions.

### 4.1 Question Type 1: Location Clarity

**Triggered when:**
- Multiple locations referenced
- Vague area ("near campus", "downtown")
- No start/end distinction (moving tasks)

**Example Question:**
```
"Is the couch being moved from one location to another, or staying within the same building?"

[ Options ]
• Moving between locations
• Same building, different floor
• Same location
```

**Backend Logic:**
```typescript
if (task.category === 'moving' && locationClarity < 0.85) {
  return {
    question_type: 'LOCATION_CLARITY',
    question: generateLocationQuestion(task),
    options: ['BETWEEN_LOCATIONS', 'SAME_BUILDING', 'SAME_LOCATION']
  };
}
```

---

### 4.2 Question Type 2: Time Constraints

**Triggered when:**
- Deadline is vague ("today", "ASAP", "whenever")
- Live Mode eligibility unclear
- Time window ambiguous

**Example Question:**
```
"What's the latest acceptable completion time?"

[ Options ]
• Today by 5pm
• Tonight by 9pm
• Tomorrow by 12pm
• Flexible (within 24 hours)
```

**Backend Logic:**
```typescript
if (deadlineConfidence < 0.85 || (liveModeEnabled && timeWindowUnclear)) {
  return {
    question_type: 'TIME_CONSTRAINTS',
    question: generateTimeQuestion(task, liveModeEnabled),
    options: generateTimeOptions(task, liveModeEnabled)
  };
}
```

**No free-text** unless absolutely necessary (e.g., custom deadline requires calendar picker).

---

### 4.3 Question Type 3: Task Scope

**Triggered when:**
- Task complexity ambiguous
- Risk of under-specification
- Stairs/accessibility unclear

**Example Question:**
```
"Will stairs be involved at either location?"

[ Options ]
• Yes, both locations
• Yes, only pickup location
• Yes, only delivery location
• No stairs involved
```

**Why This Matters:**
This single question prevents a **large percentage** of disputes.

**Backend Logic:**
```typescript
if (task.category === 'moving' && stairsConfidence < 0.85) {
  return {
    question_type: 'TASK_SCOPE',
    question: generateScopeQuestion(task),
    options: ['BOTH_LOCATIONS', 'PICKUP_ONLY', 'DELIVERY_ONLY', 'NONE']
  };
}
```

---

### 4.4 Question Type 4: Proof Expectation

**Triggered when:**
- Task outcome could be subjective
- Proof type unclear from description
- Multiple proof types possible

**Example Question:**
```
"Which best confirms completion?"

[ Options ]
• Photo at destination
• Before & after photos
• Location verification only
• Video proof
```

**AI Selects Defaults:**
AI proposes based on task class, poster confirms.

**Backend Logic:**
```typescript
if (proofTypeConfidence < 0.85) {
  const suggestedProofType = inferProofTypeFromTaskClass(task.category);
  return {
    question_type: 'PROOF_EXPECTATION',
    question: generateProofQuestion(task),
    options: generateProofOptions(task.category),
    suggested: suggestedProofType
  };
}
```

---

## §5. Question UX Rules

### 5.1 Presentation Rules

- **One question at a time** — Never bombard poster with multiple questions
- **Inline on the task card** — No modal spam, no chatbot bubble UI
- **No interruption** — Questions appear as part of the form, not popups

### 5.2 Visual Design

```
┌─────────────────────────────────────────────────────────┐
│  Task: Deep cleaning needed                            │
│  Price: $45.00                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  We just need one more detail to finalize your task:   │
│                                                         │
│  ⚠️ Will stairs be involved?                           │
│                                                         │
│  [ ○ Yes, both locations    ]                          │
│  [ ○ Yes, only pickup       ]                          │
│  [ ○ Yes, only delivery     ]                          │
│  [ ● No stairs involved     ] ← Suggested              │
│                                                         │
│  [ Continue ]                                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 5.3 What This Feels Like

**Feels like:** Finishing a form  
**Does NOT feel like:** Chatting with AI

### 5.4 Forbidden Patterns

```typescript
const FORBIDDEN_UX_PATTERNS = [
  'Chatbot bubble UI',
  'Multiple questions at once',
  'Modal dialogs',
  'Interrupting popups',
  'Conversation history',
  '"Chat with AI" button',
  'Open text input for answers (use structured options)'
];
```

---

## §6. AI Auto-Fill + Confirm Pattern

### 6.1 When AI is Confident

When AI confidence ≥ 0.85, it does **not ask** — it **proposes**.

### 6.2 Example Auto-Fill

```
Task: Couch move
Price: $35.00

✓ We've assumed this task will take 30–45 minutes.
  [ Adjust time estimate ]

✓ We've set proof type to "Photo at destination".
  [ Change proof type ]

✓ Location is clear from your description.
  [ Edit location ]

[ Review & Continue → ]
```

### 6.3 What This Preserves

- ✅ **Speed** — No unnecessary questions
- ✅ **Authority** — Poster stays in control
- ✅ **Clarity** — All assumptions visible

### 6.4 Poster Control

Poster can:
- Edit any auto-filled field
- Override any AI suggestion
- Add additional details

AI never **forces** a choice.

---

## §7. "Flawless Execution" Guarantee

### 7.1 When Task Reaches COMPLETE

When a task reaches **COMPLETE** state, the system can assert:

- ✅ **Scope is explicit** — No "that's not what I meant"
- ✅ **Time window is bounded** — No "I thought it was ASAP"
- ✅ **Proof expectations are clear** — No "I wanted proof differently"
- ✅ **Price is within rational range** — No "this should've cost less"
- ✅ **Location is unambiguous** — No "I thought it was closer"
- ✅ **Dispute probability is minimized** — All edge cases addressed

### 7.2 How You Earn This Right

This is how you earn the right to say:

> **"Money moves only when work is proven."**

If the task is ambiguous, you cannot enforce this principle.

---

## §8. Live Mode Integration

### 8.1 Additional Mandatory Questions

If poster enables **LIVE MODE**, AI must ask **additional mandatory questions**:

| Question | Options | Why Required |
|----------|---------|--------------|
| **"Are you available to respond within 30 minutes?"** | Yes / No | Live Mode requires real-time response |
| **"Is the task accessible immediately?"** | Yes / No | Live tasks must start immediately |
| **"Is the price final?"** | Yes / No | No negotiation in Live Mode |

### 8.2 Live Mode Blocking Rules

**If any answer is "no" → Live Mode is blocked.**

```typescript
if (liveModeEnabled) {
  const liveModeEligibility = checkLiveModeEligibility(task, poster);
  
  if (!liveModeEligibility.available_to_respond) {
    return {
      state: 'INCOMPLETE',
      block_live_mode: true,
      reason: 'Poster must be available to respond within 30 minutes'
    };
  }
  
  if (!liveModeEligibility.task_accessible_immediately) {
    return {
      state: 'INCOMPLETE',
      block_live_mode: true,
      reason: 'Live tasks must be accessible immediately'
    };
  }
}
```

### 8.3 This Protects Both Sides

- **Posters**: Prevents unrealistic Live Mode expectations
- **Hustlers**: Prevents wasted time on tasks that can't start immediately

---

## §9. Failure Prevention (Why This Matters)

### 9.1 Disputes This System Prevents

| Dispute Type | Prevention Mechanism |
|--------------|---------------------|
| **"That's not what I meant"** | Scope questions (Question Type 3) |
| **"I thought it was closer"** | Location clarity (Question Type 1) |
| **"I didn't know there were stairs"** | Task scope questions (Question Type 3) |
| **"I wanted proof differently"** | Proof expectation (Question Type 4) |
| **"This should've cost less"** | Price validation + scope clarity |

### 9.2 The Difference

**Most gig apps:**
- Try to resolve disputes **after** they happen
- Rely on mediation
- Accept disputes as "cost of doing business"

**HustleXP:**
- Prevents disputes **before** money moves
- Zero ambiguity = zero disputes
- Escrow only funds when contract is complete

---

## §10. AI Voice Rules (Non-Negotiable)

### 10.1 Required Tone

The AI voice must be:

- ✅ **Neutral** — No bias, no judgment
- ✅ **Precise** — No ambiguity in language
- ✅ **Slightly formal** — Professional, not casual
- ✅ **Outcome-focused** — Get to completion, not conversation

### 10.2 Correct Tone Examples

```
✓ "To avoid confusion during completion, we need one clarification."
✓ "We've assumed this task will take 30–45 minutes. You can adjust this if needed."
✓ "Which best confirms completion?"
✓ "Is the couch being moved from one location to another?"
```

### 10.3 Forbidden Tone Patterns

```typescript
const FORBIDDEN_TONE_PATTERNS = [
  'Casual',              // ❌ "Hey! Just need a quick question..."
  'Playful',             // ❌ "Just curious! 😊"
  'Apologetic',          // ❌ "Sorry to bother you, but..."
  'Salesy',              // ❌ "Want to boost your task visibility?"
  'Conversational',      // ❌ "How's your day going? Also..."
  'Uncertain',           // ❌ "I think we might need..."
  'Emotional',           // ❌ "I'm excited to help you create the perfect task!"
];
```

---

## §11. Metrics & Tracking

### 11.1 Metrics This System Should Track

To prove this is working, log:

| Metric | Target | Measurement |
|--------|--------|-------------|
| **% tasks reaching COMPLETE without edits** | >70% | Backend analytics |
| **Dispute rate: AI-assisted vs manual** | <50% of manual | Dispute tracking |
| **Average completion time** | <5 min | Task creation to posting |
| **Proof rejection rate** | <5% | Proof acceptance tracking |
| **Live Mode fulfillment speed** | <10 min avg | Live Mode analytics |
| **Question abandonment rate** | <10% | Question flow tracking |

### 11.2 How AI Improves (Without Authority Creep)

- Track which questions are most effective (reduce disputes)
- Track which auto-fills are most accurate (increase confidence thresholds)
- Track task completion time (optimize question order)
- **Never auto-accept** — Poster always confirms

---

## §12. Implementation Requirements

### 12.1 Backend Service

**Service Name:** `TaskCompletionService` (or extend existing `TaskCardGenerator`)

**Responsibilities:**
- Analyze task input for completeness
- Calculate confidence scores per field cluster
- Generate targeted questions when confidence < 0.85
- Auto-fill fields when confidence ≥ 0.85
- Enforce state machine transitions
- Validate Live Mode eligibility

### 12.2 Database Schema

```sql
-- Extend tasks table
ALTER TABLE tasks ADD COLUMN ai_completion_state VARCHAR(20) DEFAULT 'DRAFT'
  CHECK (ai_completion_state IN ('DRAFT', 'INCOMPLETE', 'COMPLETE', 'LOCKED'));

ALTER TABLE tasks ADD COLUMN confidence_score DECIMAL(3,2); -- 0.00 to 1.00
ALTER TABLE tasks ADD COLUMN location_confidence DECIMAL(3,2);
ALTER TABLE tasks ADD COLUMN time_confidence DECIMAL(3,2);
ALTER TABLE tasks ADD COLUMN scope_confidence DECIMAL(3,2);
ALTER TABLE tasks ADD COLUMN proof_confidence DECIMAL(3,2);

-- Track AI questions asked
CREATE TABLE task_completion_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id),
  question_type VARCHAR(20) NOT NULL CHECK (question_type IN ('LOCATION_CLARITY', 'TIME_CONSTRAINTS', 'TASK_SCOPE', 'PROOF_EXPECTATION')),
  question_text TEXT NOT NULL,
  options JSONB NOT NULL,
  poster_response TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  answered_at TIMESTAMPTZ
);

CREATE INDEX idx_task_completion_questions_task ON task_completion_questions(task_id);
```

### 12.3 State Machine Enforcement

```sql
-- Trigger: Enforce LOCKED state after escrow funding
CREATE OR REPLACE FUNCTION lock_task_on_escrow_funding()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.state = 'FUNDED' AND OLD.state != 'FUNDED' THEN
    UPDATE tasks
    SET ai_completion_state = 'LOCKED'
    WHERE id = NEW.task_id
    AND ai_completion_state != 'LOCKED';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_lock_task_on_escrow_funding
  AFTER UPDATE ON escrows
  FOR EACH ROW
  WHEN (NEW.state = 'FUNDED' AND OLD.state != 'FUNDED')
  EXECUTE FUNCTION lock_task_on_escrow_funding();
```

### 12.4 API Endpoints

```typescript
// tRPC router: taskCompletion
taskCompletion.analyze({
  input: {
    rawText: string;
    category?: TaskCategory;
    location?: string;
    price?: number;
    liveModeEnabled?: boolean;
  },
  output: {
    state: 'DRAFT' | 'INCOMPLETE' | 'COMPLETE';
    confidence: number;
    location_confidence: number;
    time_confidence: number;
    scope_confidence: number;
    proof_confidence: number;
    question?: {
      type: QuestionType;
      text: string;
      options: string[];
      suggested?: string;
    };
    autoFills?: {
      field: string;
      value: any;
      confidence: number;
    }[];
  }
});

taskCompletion.answerQuestion({
  input: {
    taskId: string;
    questionId: string;
    answer: string;
  },
  output: {
    state: 'INCOMPLETE' | 'COMPLETE';
    nextQuestion?: Question;
    autoFills?: AutoFill[];
  }
});
```

---

## §13. Constitutional Alignment

### 13.1 Authority Model

Per `AI_INFRASTRUCTURE.md`:
- **AI Authority**: A1 (Advisory) — Proposals only, never decisions
- **Poster Authority**: Final confirmation required
- **System Authority**: State machine enforced at Layer 0 (database)

### 13.2 Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **COMPLETE-1** | AI questions only allowed in DRAFT/INCOMPLETE | Backend service |
| **COMPLETE-2** | COMPLETE requires zero unresolved ambiguity | Backend validation |
| **COMPLETE-3** | LOCKED disables AI entirely | DB trigger + backend |
| **COMPLETE-4** | Escrow cannot fund unless state = COMPLETE | DB trigger (HX201) |
| **COMPLETE-5** | Only 4 question types allowed | Backend validation |

### 13.3 Error Codes

| Code | Meaning | Trigger |
|------|---------|---------|
| **HX701** | AI question attempted after LOCKED | COMPLETE-3 violation |
| **HX702** | Escrow funding attempted before COMPLETE | COMPLETE-4 violation |
| **HX703** | Invalid question type (not in 4 allowed types) | COMPLETE-5 violation |
| **HX704** | Confidence threshold bypass attempt | Backend validation |

---

## §14. What to Lock Next (Priority Order)

### Option 1: AI Task Completion State Machine (RECOMMENDED)

**Add to BUILD_GUIDE.md:**
- Phase 1.5: Task Completion State Machine
- Define state transitions precisely
- Enforce at database level
- Test state machine exhaustively

**Why First:** Foundation for everything else.

---

### Option 2: Required Field Matrix Per Task Type

**Add to PRODUCT_SPEC.md:**
- Define required fields per task category
- Define confidence calculation rules
- Define auto-fill defaults per category

**Why Second:** Enables confidence scoring.

---

### Option 3: Confidence Scoring + Thresholds

**Add to AI_INFRASTRUCTURE.md:**
- Define confidence calculation algorithm
- Define threshold rules (0.60, 0.85)
- Define per-field-cluster scoring

**Why Third:** Enables question triggering logic.

---

### Option 4: Inline Question UI

**Add to UI_SPEC.md:**
- Define question UI component
- Define auto-fill confirmation UI
- Define state indicators (red/amber/green)

**Why Fourth:** Frontend implementation follows backend.

---

### Option 5: Anti-Abuse Rules for Poster Manipulation

**Add to PRODUCT_SPEC.md:**
- Prevent question spam
- Prevent confidence gaming
- Prevent state machine bypass

**Why Last:** Security hardening after core works.

---

## §15. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial max-tier specification |

---

**END OF AI_TASK_COMPLETION_SPEC v1.0.0**
