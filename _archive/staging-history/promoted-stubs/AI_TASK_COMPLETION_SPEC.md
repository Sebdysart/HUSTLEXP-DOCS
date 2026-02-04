# AI Task Completion Specification

**STATUS: STAGING (Detailed Implementation)**
**Owner:** Product/AI Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Authority:** PRODUCT_SPEC.md §8 is canonical. This document provides implementation details.

---

## Overview

AI Task Completion ensures every task reaches zero ambiguity before escrow is funded. This specification details the implementation of the task completion system described in PRODUCT_SPEC.md §8.

> **Core Principle:** AI does not chat. AI closes gaps in a contract.

---

## State Machine

### Task AI States

```
DRAFT → INCOMPLETE → COMPLETE → LOCKED
```

| State | AI Questions | Escrow Funding | Field Edits |
|-------|-------------|----------------|-------------|
| DRAFT | Allowed | Blocked | Allowed |
| INCOMPLETE | Allowed | Blocked | Allowed |
| COMPLETE | Blocked | Allowed | Allowed (until funded) |
| LOCKED | Blocked | Already done | Blocked |

### State Transition Rules

```typescript
type AIStateTransition = {
  from: TaskAIState;
  to: TaskAIState;
  trigger: string;
  guard: () => boolean;
};

const transitions: AIStateTransition[] = [
  {
    from: 'DRAFT',
    to: 'INCOMPLETE',
    trigger: 'user_adds_description',
    guard: () => hasDescription && confidenceScore < 0.85,
  },
  {
    from: 'DRAFT',
    to: 'COMPLETE',
    trigger: 'user_adds_description',
    guard: () => hasDescription && confidenceScore >= 0.85,
  },
  {
    from: 'INCOMPLETE',
    to: 'COMPLETE',
    trigger: 'ai_question_answered',
    guard: () => allRequiredFieldsSatisfied && confidenceScore >= 0.85,
  },
  {
    from: 'COMPLETE',
    to: 'LOCKED',
    trigger: 'escrow_funded',
    guard: () => escrowState === 'FUNDED',
  },
];
```

---

## Confidence Threshold

### Threshold Rule

```
IF confidence < 0.85 → ASK question
IF confidence ≥ 0.85 → AUTO-FILL + CONFIRM
```

### Confidence Calculation

```typescript
interface ConfidenceFactors {
  location_clarity: number;    // 0-1
  time_specificity: number;    // 0-1
  scope_definition: number;    // 0-1
  proof_expectation: number;   // 0-1
}

function calculateConfidence(factors: ConfidenceFactors): number {
  return (
    factors.location_clarity * 0.30 +
    factors.time_specificity * 0.25 +
    factors.scope_definition * 0.30 +
    factors.proof_expectation * 0.15
  );
}
```

### Per-Field Confidence

| Field Cluster | Weight | Triggers Question When |
|---------------|--------|----------------------|
| Location | 30% | Multiple locations, vague area |
| Time | 25% | No deadline, "ASAP" only |
| Scope | 30% | Complexity unclear, missing details |
| Proof | 15% | Subjective outcome |

---

## Question Types

### Allowed Question Types (Only 4)

| Type | Trigger | Example |
|------|---------|---------|
| `LOCATION_CLARITY` | Multiple locations or vague area | "Is the pickup and dropoff at the same address?" |
| `TIME_CONSTRAINTS` | Deadline vague or Live eligibility unclear | "When do you need this completed by?" |
| `TASK_SCOPE` | Complexity ambiguous | "How many items need to be moved?" |
| `PROOF_EXPECTATION` | Outcome could be subjective | "What photo would confirm this is complete?" |

### Question Format

```typescript
interface AIQuestion {
  id: string;
  type: AIQuestionType;
  question: string;
  options?: string[];           // Multiple choice (if applicable)
  free_text_allowed: boolean;
  confidence_before: number;
  field_to_update: string;      // Which task field this affects
}
```

### Question Generation Rules

```typescript
function shouldAskQuestion(
  field: string,
  currentValue: any,
  confidence: number
): boolean {
  // Never ask if confidence is high enough
  if (confidence >= 0.85) return false;

  // Never ask in COMPLETE or LOCKED state
  if (taskAIState in ['COMPLETE', 'LOCKED']) return false;

  // Don't ask again if already answered
  if (questionHistory.has(field)) return false;

  return true;
}
```

---

## Auto-Fill Pattern

When confidence ≥ 0.85, AI auto-fills rather than asking:

```typescript
interface AutoFillSuggestion {
  field: string;
  suggested_value: any;
  confidence: number;
  editable: boolean;  // Always true
  reason: string;     // Why this was suggested
}

// Example auto-fills
const suggestions: AutoFillSuggestion[] = [
  {
    field: 'estimated_duration_minutes',
    suggested_value: 45,
    confidence: 0.88,
    editable: true,
    reason: 'Based on similar moving tasks in your area',
  },
  {
    field: 'proof_type',
    suggested_value: 'photo_at_destination',
    confidence: 0.92,
    editable: true,
    reason: 'Standard proof for delivery tasks',
  },
];
```

### UI Display

```
✓ We've estimated this task will take 30–45 minutes.
  [ Adjust time estimate ]

✓ We've set proof type to "Photo at destination".
  [ Change proof type ]
```

---

## Live Mode Integration

### Additional Mandatory Questions

When poster enables LIVE MODE, AI must ask:

1. "Are you available to respond within 30 minutes?" (Yes/No)
2. "Is the task accessible immediately?" (Yes/No)
3. "Is the price final?" (Yes/No)

**If any answer is "No" → Live Mode is blocked.**

### Live Mode Validation

```typescript
function validateLiveMode(task: Task, answers: LiveModeAnswers): ValidationResult {
  const errors: string[] = [];

  if (!answers.available_to_respond) {
    errors.push('Live Mode requires you to respond within 30 minutes');
  }

  if (!answers.task_accessible) {
    errors.push('Task location must be immediately accessible for Live Mode');
  }

  if (!answers.price_final) {
    errors.push('Price must be final for Live Mode');
  }

  if (task.price < 1500) {
    errors.push('Live Mode requires minimum $15.00 price');
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}
```

---

## AI Voice Rules

### Allowed Patterns

- Neutral: "Please specify the delivery address."
- Precise: "Is the pickup location different from the dropoff?"
- Outcome-focused: "What photo would confirm completion?"

### Forbidden Patterns

```typescript
const FORBIDDEN_PATTERNS = [
  /hey!?/i,
  /just (a )?quick/i,
  /curious/i,
  /sorry to/i,
  /want to boost/i,
  /\ud83d|\ud83c/,  // Emoji detection
];

function validateAIMessage(message: string): boolean {
  return !FORBIDDEN_PATTERNS.some(pattern => pattern.test(message));
}
```

---

## Database Schema

```sql
-- AI completion tracking per task
CREATE TABLE task_ai_completion (
  id UUID PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES tasks(id),
  ai_state task_ai_state NOT NULL DEFAULT 'DRAFT',
  confidence_score NUMERIC(3,2),
  questions_asked JSONB DEFAULT '[]',
  auto_filled_fields JSONB DEFAULT '{}',
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI question history
CREATE TABLE task_ai_questions (
  id UUID PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES tasks(id),
  question_type question_type NOT NULL,
  question_text TEXT NOT NULL,
  answer_text TEXT,
  confidence_before NUMERIC(3,2),
  confidence_after NUMERIC(3,2),
  answered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Tasks reaching COMPLETE without manual edits | >70% | `auto_filled_fields` analysis |
| Dispute rate (AI-assisted vs manual) | <50% of manual | Dispute tracking |
| Average completion time | <5 min | Task creation → escrow funded |
| Proof rejection rate | <5% | Proof state analysis |

---

## Error Codes

| Code | Trigger | Message |
|------|---------|---------|
| HX701 | AI question after LOCKED | "Task is locked, no questions allowed" |
| HX702 | Escrow funding before COMPLETE | "Task must be COMPLETE to fund escrow" |
| HX703 | Invalid question type | "Invalid question type" |
| HX704 | Confidence bypass attempt | "Confidence threshold cannot be bypassed" |

---

**See PRODUCT_SPEC.md §8 for canonical definitions.**

**END OF AI_TASK_COMPLETION_SPEC v1.0.0**
