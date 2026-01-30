# Edge Screens Specification

**Location:** `src/screens/edge/`  
**Count:** 3 screens  
**Status:** ✅ All functional

These screens handle edge cases and error states.

---

## E1: NoTasksAvailableScreen

**File:** `NoTasksAvailableScreen.tsx`  
**Spec:** UI_SPEC §10.1

### Purpose
Shown when task feed is empty.

### Required Elements
- [ ] Empty state illustration
- [ ] "No tasks available" message
- [ ] Possible reasons:
  - No tasks in your area
  - No tasks match your capabilities
  - All tasks are taken
- [ ] Suggestions:
  - Expand work radius
  - Add more capabilities
  - Enable notifications
- [ ] Refresh button
- [ ] Link to WorkEligibilityScreen

### Props Interface
```typescript
interface NoTasksAvailableProps {
  possibleReasons?: string[];
  suggestions?: Suggestion[];
  onRefresh?: () => void;
  onExpandRadius?: () => void;
  onAddCapabilities?: () => void;
}
```

### Copy Guidelines
- Be encouraging, not discouraging
- Provide actionable next steps
- Don't blame the user

---

## E2: EligibilityMismatchScreen

**File:** `EligibilityMismatchScreen.tsx`  
**Spec:** UI_SPEC §10.2

### Purpose
Explain why user can't see or accept a specific task.

### Required Elements
- [ ] Task summary (what they tried to access)
- [ ] Specific requirements not met
- [ ] User's current status for each requirement
- [ ] How to become eligible
- [ ] Link to relevant upgrade action

### Props Interface
```typescript
interface EligibilityMismatchProps {
  task?: Task;
  requirements?: Requirement[];
  userStatus?: {
    [requirementId: string]: {
      met: boolean;
      current: string;
      needed: string;
    };
  };
  upgradeActions?: UpgradeAction[];
}
```

### Example Display
```
Task: "Licensed Electrician Needed"

❌ Trust Tier: You have Tier 2, task requires Tier 3
✅ Location: California (matches)
❌ License: Task requires Electrician License
✅ Insurance: Verified

To become eligible:
→ Complete 5 more tasks to reach Tier 3
→ Add your Electrician License in Settings
```

---

## E3: TrustTierLockedScreen

**File:** `TrustTierLockedScreen.tsx`  
**Spec:** UI_SPEC §10.3

### Purpose
Explain that user's trust tier is too low for a task.

### Required Elements
- [ ] Task summary
- [ ] Required trust tier
- [ ] User's current tier
- [ ] XP needed to reach required tier
- [ ] Estimated tasks to complete
- [ ] Progress visualization
- [ ] Link to TrustTierLadderScreen

### Props Interface
```typescript
interface TrustTierLockedProps {
  task?: Task;
  requiredTier?: number;
  currentTier?: number;
  currentXP?: number;
  xpNeeded?: number;
  estimatedTasksToComplete?: number;
}
```

### Copy Guidelines
- Frame as opportunity, not rejection
- "Keep going!" not "You can't"
- Show progress, not just gap

---

## Navigation

These screens are typically shown as modals or replacements:

```
TaskFeedScreen
    │
    ├── (empty feed) ──▶ NoTasksAvailableScreen
    │
    └── TaskDetailScreen
            │
            ├── (not eligible) ──▶ EligibilityMismatchScreen
            │
            └── (trust too low) ──▶ TrustTierLockedScreen
```

---

## Design Principles for Edge Screens

1. **Never blame the user**
   - "This task requires..." not "You don't have..."

2. **Always provide next steps**
   - What can they do to become eligible?
   - Link to the action

3. **Be specific**
   - Show exact requirements
   - Show exact gaps
   - Show exact path forward

4. **Encourage progression**
   - Frame as journey
   - Celebrate progress
   - Show how close they are
