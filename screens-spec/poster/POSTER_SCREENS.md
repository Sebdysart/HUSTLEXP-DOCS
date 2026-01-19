# Poster Screens Specification

**Location:** `hustlexp-app/screens/poster/`  
**Count:** 4 screens  
**Status:** ✅ All functional

---

## P1: TaskCreationScreen

**File:** `TaskCreationScreen.tsx`  
**Spec:** UI_SPEC §6.1, PRODUCT_SPEC §3.1

### Purpose
Create and fund a new task.

### Required Elements
- [ ] Task title input
- [ ] Task description input
- [ ] Category selector
- [ ] Location picker (map)
- [ ] Pay amount input (with minimum shown)
- [ ] Required trust tier selector
- [ ] Required capabilities selector
- [ ] Photo upload (optional)
- [ ] Post button (creates task + escrow)
- [ ] Price breakdown (pay + fees)

### Props Interface
```typescript
interface TaskCreationProps {
  userBalance?: number;
  minimumPay?: number;
  categories?: Category[];
  onSubmit?: (task: TaskDraft) => void;
  isSubmitting?: boolean;
}
```

### Validation
- Title: 5-100 characters
- Description: 20-1000 characters
- Pay: >= minimum (server-provided)
- Location: Required

---

## P2: HustlerOnWayScreen

**File:** `HustlerOnWayScreen.tsx`  
**Spec:** UI_SPEC §6.2, PRODUCT_SPEC §3.2

### Purpose
Track the assigned hustler en route to task.

### Required Elements
- [ ] Map with hustler location (live)
- [ ] Hustler info card (name, rating, photo)
- [ ] ETA display
- [ ] Chat button (open TaskConversation)
- [ ] Cancel button (with confirmation)
- [ ] Task summary

### Props Interface
```typescript
interface HustlerOnWayProps {
  task?: Task;
  hustler?: {
    id: string;
    name: string;
    rating: number;
    photo?: string;
    location?: { lat: number; lng: number };
  };
  eta?: number; // minutes
  onChat?: () => void;
  onCancel?: () => void;
}
```

### Real-time Updates
- Hustler location updates via WebSocket
- ETA recalculates on location change

---

## P3: TaskCompletionScreen (Poster View)

**File:** `TaskCompletionScreen.tsx`  
**Spec:** UI_SPEC §6.3, PRODUCT_SPEC §3.3

### Purpose
Review proof and release payment.

### Required Elements
- [ ] Proof photos (expandable)
- [ ] Proof note (if provided)
- [ ] Hustler info
- [ ] Approve button (releases escrow)
- [ ] Dispute button (opens dispute flow)
- [ ] Task summary

### Props Interface
```typescript
interface TaskCompletionPosterProps {
  task?: Task;
  proof?: {
    photos: string[];
    note?: string;
    submittedAt: Date;
  };
  hustler?: { name: string; rating: number };
  onApprove?: () => void;
  onDispute?: () => void;
  isApproving?: boolean;
}
```

### States
- Pending: "Waiting for hustler to complete"
- Proof Submitted: Show proof, action buttons
- Approved: "Payment released" confirmation
- Disputed: Show dispute status

---

## P4: FeedbackScreen

**File:** `FeedbackScreen.tsx`  
**Spec:** UI_SPEC §6.4, PRODUCT_SPEC §12

### Purpose
Rate the hustler after task completion.

### Required Elements
- [ ] Star rating (1-5)
- [ ] Optional comment input
- [ ] Specific feedback options (on time, quality, communication)
- [ ] Submit button
- [ ] Skip option (but encouraged to rate)

### Props Interface
```typescript
interface FeedbackProps {
  task?: Task;
  hustler?: { name: string; photo?: string };
  onSubmit?: (rating: RatingData) => void;
  onSkip?: () => void;
  isSubmitting?: boolean;
}
```

---

## Navigation Flow

```
PosterHomeScreen
    │
    └──▶ TaskCreationScreen
              │
              ▼ (task posted, hustler accepts)
         HustlerOnWayScreen
              │
              ▼ (hustler completes)
         TaskCompletionScreen
              │
              ▼ (approved)
         FeedbackScreen
              │
              ▼
         PosterHomeScreen
```
