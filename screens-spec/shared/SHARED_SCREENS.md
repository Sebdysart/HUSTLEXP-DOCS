# Shared Screens Specification

**Location:** `src/screens/shared/`  
**Count:** 4 screens  
**Status:** ✅ All functional

These screens are used by both Hustlers and Posters.

---

## SH1: TaskConversationScreen

**File:** `TaskConversationScreen.tsx`  
**Spec:** UI_SPEC §9.1, PRODUCT_SPEC §10

### Purpose
In-task messaging between Hustler and Poster.

### Required Elements
- [ ] Message list (scrollable)
- [ ] Message input
- [ ] Send button
- [ ] Image attachment option
- [ ] Read receipts
- [ ] Typing indicator
- [ ] Task context header

### Props Interface
```typescript
interface TaskConversationProps {
  task?: Task;
  messages?: Message[];
  otherUser?: { name: string; photo?: string };
  onSendMessage?: (text: string) => void;
  onSendImage?: (uri: string) => void;
  isSending?: boolean;
}
```

### Real-time
- Messages via WebSocket
- Typing indicator via WebSocket

---

## SH2: TrustTierLadderScreen

**File:** `TrustTierLadderScreen.tsx`  
**Spec:** UI_SPEC §9.2, PRODUCT_SPEC §5.2

### Purpose
Visual representation of trust tier progression.

### Required Elements
- [ ] All 6 tiers displayed (0-5)
- [ ] Current tier highlighted
- [ ] XP required for each tier
- [ ] Benefits unlocked at each tier
- [ ] Progress to next tier

### Props Interface
```typescript
interface TrustTierLadderProps {
  currentTier?: number;
  currentXP?: number;
  tiers?: TierInfo[];
}
```

---

## SH3: TrustChangeExplanationScreen

**File:** `TrustChangeExplanationScreen.tsx`  
**Spec:** UI_SPEC §9.3, PRODUCT_SPEC §5.3

### Purpose
Explain why trust changed (up or down).

### Required Elements
- [ ] Previous tier
- [ ] New tier
- [ ] Change reason
- [ ] Contributing factors
- [ ] What to do next (if decreased)
- [ ] Celebration animation (if increased)

### Props Interface
```typescript
interface TrustChangeExplanationProps {
  previousTier?: number;
  newTier?: number;
  changeReason?: string;
  factors?: Factor[];
  recommendations?: string[];
}
```

---

## SH4: DisputeEntryScreen

**File:** `DisputeEntryScreen.tsx`  
**Spec:** UI_SPEC §9.4, PRODUCT_SPEC §4.3

### Purpose
File a dispute for a task.

### Required Elements
- [ ] Dispute reason selector
- [ ] Description input
- [ ] Evidence upload (photos)
- [ ] Task context summary
- [ ] Submit button
- [ ] What happens next explanation

### Props Interface
```typescript
interface DisputeEntryProps {
  task?: Task;
  onSubmit?: (dispute: DisputeDraft) => void;
  isSubmitting?: boolean;
}
```

### Dispute Reasons
- Work not completed
- Work quality issues
- Worker didn't show up
- Payment issue
- Safety concern
- Other

---

## Navigation

These screens are accessed from multiple places:

```
From TaskInProgressScreen → TaskConversationScreen
From HustlerOnWayScreen → TaskConversationScreen
From ProfileScreen → TrustTierLadderScreen
From Notification → TrustChangeExplanationScreen
From TaskCompletionScreen → DisputeEntryScreen
```
