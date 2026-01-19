# TASK CREATION STATE MACHINE — HUSTLEXP v1.0

**STATUS: FROZEN — No skip paths allowed**  
**Rule: Task must progress through states in order. Cannot jump to POSTED.**

---

## STATE DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│    ┌─────────┐     ┌─────────────┐     ┌─────────┐     ┌──────┐ │
│    │  DRAFT  │────▶│ CLARIFYING  │────▶│  READY  │────▶│POSTED│ │
│    └─────────┘     └─────────────┘     └─────────┘     └──────┘ │
│         │                │                  │                    │
│         │                │                  │                    │
│         ▼                ▼                  ▼                    │
│    ┌─────────┐     ┌─────────────┐     ┌─────────┐              │
│    │ABANDONED│     │  ABANDONED  │     │ABANDONED│              │
│    └─────────┘     └─────────────┘     └─────────┘              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**No skip paths. No shortcuts. No "post anyway."**

---

## STATE DEFINITIONS

### 1. DRAFT
```
DESCRIPTION:  User has started task creation
ENTRY:        User taps "Create Task"
UI STATE:     Task creation form visible
              Post button: HIDDEN
              
ALLOWED ACTIONS:
  - Enter description
  - Upload photos
  - Set initial fields
  - Request AI assistance
  - Abandon (discard draft)
  
TRANSITIONS:
  → CLARIFYING: When description entered and AI triggered
  → ABANDONED: User exits without saving
```

### 2. CLARIFYING
```
DESCRIPTION:  AI is gathering required information
ENTRY:        AI has classified task and identified missing fields
UI STATE:     Follow-up questions displayed
              Post button: DISABLED ("More details needed")
              Progress indicator showing completion %
              
ALLOWED ACTIONS:
  - Answer clarifying questions
  - Edit previous answers
  - View why each question is asked
  - Abandon (discard draft)
  
TRANSITIONS:
  → READY: All blocking questions answered + validated
  → ABANDONED: User exits without completing
  
BLOCKING CONDITIONS:
  - Any required field empty
  - Any required field invalid
  - AI clarity score < 3
```

### 3. READY
```
DESCRIPTION:  Task meets all execution requirements
ENTRY:        All blocking questions answered and validated
UI STATE:     Full task preview displayed
              Post button: ENABLED ("Post Task")
              Final review screen
              
ALLOWED ACTIONS:
  - Review full task details
  - Edit any field (may return to CLARIFYING if invalidated)
  - Set pricing (if not set)
  - Confirm and post
  - Abandon
  
TRANSITIONS:
  → POSTED: User taps "Post Task"
  → CLARIFYING: User edits field that becomes invalid
  → ABANDONED: User exits
```

### 4. POSTED
```
DESCRIPTION:  Task is live and visible to eligible hustlers
ENTRY:        User confirmed posting + escrow funded
UI STATE:     Confirmation screen
              Task visible in poster's active tasks
              
ALLOWED ACTIONS:
  - View task
  - Edit (limited fields, may require re-clarification)
  - Cancel (with rules)
  
TRANSITIONS:
  → ACCEPTED: Hustler accepts task (different state machine)
  
IRREVERSIBLE:
  - Escrow is funded
  - Task is public to eligible hustlers
```

### 5. ABANDONED
```
DESCRIPTION:  User exited without completing
ENTRY:        User closed task creation at any point
UI STATE:     Draft saved for 24 hours (optional resume)
              
ALLOWED ACTIONS:
  - Resume draft (returns to last state)
  - Permanently delete
  
TRANSITIONS:
  → DRAFT/CLARIFYING/READY: Resume at last state
  → (deleted): After 24 hours or explicit delete
```

---

## TRANSITION RULES

### DRAFT → CLARIFYING
```
TRIGGER:     Description entered (> 20 chars) + AI classification complete
REQUIRED:    
  - Task description present
  - AI has identified category
  - Required questions determined
AUTOMATIC:   Yes (triggers when description saved)
```

### CLARIFYING → READY
```
TRIGGER:     All blocking fields validated
REQUIRED:
  - All blocking questions answered
  - All answers pass validation
  - AI clarity score >= 3
  - Risk classification complete
  - Price set (or user accepts suggested)
AUTOMATIC:   Yes (triggers when last blocking field validated)
```

### READY → POSTED
```
TRIGGER:     User taps "Post Task"
REQUIRED:
  - All READY requirements still valid
  - Escrow amount confirmed
  - Payment method valid
  - Terms accepted
AUTOMATIC:   No (requires explicit user action)
```

### ANY → ABANDONED
```
TRIGGER:     User exits task creation
REQUIRED:    None
AUTOMATIC:   Yes (draft auto-saved)
```

---

## VALIDATION CHECKPOINTS

### At DRAFT
```
[ ] Description exists (> 20 chars)
[ ] No prohibited content detected
```

### At CLARIFYING → READY
```
[ ] All blocking questions answered
[ ] Address validated (geocodable)
[ ] Time window is in future
[ ] Duration estimate > 0
[ ] Proof of completion defined
[ ] Poster presence specified
[ ] Tools/materials responsibility clear
[ ] AI clarity score >= 3
[ ] Category classification confirmed
[ ] Trust tier requirement computed
```

### At READY → POSTED
```
[ ] All CLARIFYING validations still pass
[ ] Price meets minimum floor
[ ] Price within suggested range OR user acknowledged
[ ] Payment method on file
[ ] Escrow can be funded
[ ] Terms accepted
```

---

## UI STATE MAPPING

| State | Post Button | Progress | Questions | Preview |
|-------|-------------|----------|-----------|---------|
| DRAFT | Hidden | 0% | None | None |
| CLARIFYING | Disabled | 10-90% | Visible | Partial |
| READY | Enabled | 100% | Hidden | Full |
| POSTED | N/A | N/A | N/A | Confirmation |
| ABANDONED | Resume/Delete | Saved % | Saved | Saved |

---

## ERROR HANDLING

### Invalid Answer Given
```
STATE:    Remains in CLARIFYING
ACTION:   Show validation error inline
UI:       Highlight invalid field
          Explain what's wrong
          Suggest correction
BLOCKING: Cannot proceed until fixed
```

### AI Classification Failed
```
STATE:    Remains in DRAFT
ACTION:   Ask user to select category manually
UI:       Show category picker
          Explain AI couldn't determine
BLOCKING: Cannot proceed until category set
```

### Network Error During Post
```
STATE:    Remains in READY
ACTION:   Show error, allow retry
UI:       "Posting failed. Tap to retry."
DATA:     All data preserved
BLOCKING: Must retry or abandon
```

### Escrow Funding Failed
```
STATE:    Remains in READY
ACTION:   Show payment error
UI:       "Payment failed. Update payment method."
BLOCKING: Cannot post until payment succeeds
```

---

## DATA PERSISTENCE

### DRAFT State
```
SAVED:    Description, photos, any entered fields
STORAGE:  Local + server (user_task_drafts table)
EXPIRY:   24 hours from last edit
```

### CLARIFYING State
```
SAVED:    All answered questions, partial task object
STORAGE:  Server (user_task_drafts table)
EXPIRY:   24 hours from last edit
```

### READY State
```
SAVED:    Complete task object, not yet posted
STORAGE:  Server (user_task_drafts table)
EXPIRY:   1 hour (encourage completion)
```

### POSTED State
```
SAVED:    Permanent task record
STORAGE:  tasks table (primary)
EXPIRY:   Never (task lifecycle takes over)
```

---

## STATE MACHINE ENFORCEMENT

### Backend Enforcement
```typescript
async function transitionTaskState(
  taskDraftId: string, 
  targetState: TaskCreationState
): Promise<TaskDraft> {
  const draft = await getTaskDraft(taskDraftId);
  
  // Validate transition is allowed
  if (!isValidTransition(draft.state, targetState)) {
    throw new Error(`Invalid transition: ${draft.state} → ${targetState}`);
  }
  
  // Validate requirements for target state
  const validation = validateStateRequirements(draft, targetState);
  if (!validation.valid) {
    throw new Error(`Requirements not met: ${validation.errors.join(', ')}`);
  }
  
  // Execute transition
  return await updateTaskDraftState(taskDraftId, targetState);
}
```

### Frontend Enforcement
```typescript
// Post button only enabled in READY state
const canPost = taskDraft.state === 'READY' && 
                allValidationsPassing &&
                escrowReady;

// Progress indicator
const progress = calculateProgress(taskDraft);

// Questions only shown in CLARIFYING state
const showQuestions = taskDraft.state === 'CLARIFYING';
```

---

## NO SKIP PATHS

These transitions are **explicitly forbidden**:

```
❌ DRAFT → READY (must go through CLARIFYING)
❌ DRAFT → POSTED (must go through CLARIFYING + READY)
❌ CLARIFYING → POSTED (must go through READY)
❌ Any state → POSTED without all validations
```

**There is no "post anyway" option.**
**There is no "skip questions" option.**
**There is no admin override for incomplete tasks.**

---

## SIGNATURE

This state machine is FROZEN.
Tasks must progress through states in order.
No skip paths exist.
No bypass mechanisms exist.

**Quality is enforced by architecture, not policy.**
