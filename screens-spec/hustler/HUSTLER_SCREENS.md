# Hustler Screens Specification

**Location:** `src/screens/hustler/`  
**Count:** 9 screens  
**Status:** ✅ All functional

---

## H1: HustlerHomeScreen

**File:** `HustlerHomeScreen.tsx`  
**Spec:** UI_SPEC §5.1, PRODUCT_SPEC §3

### Purpose
Main dashboard for workers. Shows available work, current stats, and quick actions.

### Required Elements
- [ ] XP display (current XP, level progress)
- [ ] Trust tier badge
- [ ] Available tasks count
- [ ] Quick action: "Find Work" button
- [ ] Active task card (if any)
- [ ] Recent earnings summary

### Props Interface
```typescript
interface HustlerHomeProps {
  user?: {
    xp: number;
    level: number;
    trustTier: number;
  };
  activeTask?: Task;
  availableTasksCount?: number;
  recentEarnings?: number;
  isLoading?: boolean;
}
```

### States
- Loading: Skeleton cards
- Empty: "No active tasks" message
- Active: Show active task card prominently

---

## H2: TaskFeedScreen

**File:** `TaskFeedScreen.tsx`  
**Spec:** UI_SPEC §5.2, PRODUCT_SPEC §9

### Purpose
Browse available tasks. List view with filters.

### Required Elements
- [ ] Task list (scrollable)
- [ ] Filter controls (category, distance, pay range)
- [ ] Sort options (newest, highest pay, closest)
- [ ] Pull-to-refresh
- [ ] Empty state: "No tasks available"

### Props Interface
```typescript
interface TaskFeedProps {
  tasks?: Task[];
  filters?: FilterState;
  onFilterChange?: (filters: FilterState) => void;
  onTaskSelect?: (taskId: string) => void;
  isLoading?: boolean;
  onRefresh?: () => void;
}
```

---

## H3: TaskHistoryScreen

**File:** `TaskHistoryScreen.tsx`  
**Spec:** UI_SPEC §5.3

### Purpose
View past completed tasks.

### Required Elements
- [ ] Task history list
- [ ] Completed/cancelled status
- [ ] Earnings per task
- [ ] Date completed
- [ ] Link to task details

---

## H4: TaskDetailScreen

**File:** `TaskDetailScreen.tsx`  
**Spec:** UI_SPEC §5.4, PRODUCT_SPEC §3.1

### Purpose
Single task view before accepting. Shows all task requirements.

### Required Elements
- [ ] Task title & description
- [ ] Pay amount (escrow)
- [ ] Required trust tier (with lock if ineligible)
- [ ] Required capabilities
- [ ] Location (map preview)
- [ ] Poster info (rating, task count)
- [ ] Accept button (disabled if ineligible)
- [ ] Eligibility explanation (if not eligible)

### Props Interface
```typescript
interface TaskDetailProps {
  task?: Task;
  eligibilityStatus?: 'eligible' | 'ineligible' | 'checking';
  eligibilityReason?: string;
  onAccept?: () => void;
  isLoading?: boolean;
}
```

---

## H5: TaskInProgressScreen

**File:** `TaskInProgressScreen.tsx`  
**Spec:** UI_SPEC §5.5, PRODUCT_SPEC §3.2

### Purpose
Active task view. Shows task details, navigation, timer.

### Required Elements
- [ ] Task summary card
- [ ] Map with directions
- [ ] Navigation button (open in Maps)
- [ ] Time tracking
- [ ] Cancel task button (with warning)
- [ ] Chat button (open TaskConversation)
- [ ] Complete button (enabled when at location)

---

## H6: TaskCompletionScreen

**File:** `TaskCompletionScreen.tsx`  
**Spec:** UI_SPEC §5.6, PRODUCT_SPEC §3.3

### Purpose
Submit proof of completion.

### Required Elements
- [ ] Photo upload (required)
- [ ] Note input (optional)
- [ ] Submit button
- [ ] Review what you're submitting
- [ ] Confirmation state

### States
- Action Required: Upload proof
- Submitted: Waiting for approval
- Approved: Show XP earned
- Rejected: Show reason, allow resubmit

---

## H7: HustlerEnRouteMapScreen

**File:** `HustlerEnRouteMapScreen.tsx`  
**Spec:** UI_SPEC §5.5.2

### Purpose
Full-screen navigation view.

### Required Elements
- [ ] Full-screen map
- [ ] Current location marker
- [ ] Destination marker
- [ ] Route line
- [ ] ETA display
- [ ] Exit button (return to TaskInProgress)

---

## H8: XPBreakdownScreen

**File:** `XPBreakdownScreen.tsx`  
**Spec:** UI_SPEC §7, PRODUCT_SPEC §5

### Purpose
Detailed XP history and breakdown.

### Required Elements
- [ ] Total XP display
- [ ] Level progress bar
- [ ] XP history list (with dates)
- [ ] XP sources breakdown
- [ ] Trust tier impact explanation

---

## H9: InstantInterruptCard

**File:** `InstantInterruptCard.tsx`  
**Spec:** UI_SPEC §14, PRODUCT_SPEC §3.5

### Purpose
Live Mode interrupt card shown when matching task found.

### Required Elements
- [ ] Task summary
- [ ] Pay amount
- [ ] Distance
- [ ] Accept button (countdown timer)
- [ ] Decline button
- [ ] Auto-dismiss after timeout

### Behavior
- Appears as modal/overlay
- 30-second countdown
- Sound/vibration on appear
- Auto-decline if timeout

---

## Navigation Flow

```
HustlerHomeScreen
    │
    ├──▶ TaskFeedScreen ──▶ TaskDetailScreen
    │                            │
    │                            ▼ (accept)
    │                     TaskInProgressScreen ◀──▶ HustlerEnRouteMapScreen
    │                            │
    │                            ▼ (complete)
    │                     TaskCompletionScreen
    │                            │
    │                            ▼ (approved)
    │                     XPBreakdownScreen
    │
    └──▶ TaskHistoryScreen
```
