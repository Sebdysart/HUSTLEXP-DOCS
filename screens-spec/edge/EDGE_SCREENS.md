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

## E4: InstantModeUnavailableScreen

**File:** `InstantModeUnavailableScreen.tsx`
**Spec:** PRODUCT_SPEC §3.7
**Stitch-Prompt:** `E4-instant-mode-unavailable.md`

### Purpose
Shown when a worker tries to access Live/Instant Mode but doesn't meet requirements.

### Required Elements
- [x] Clear explanation of why instant mode is unavailable
- [x] Trust tier requirement display (minimum tier for instant mode)
- [x] Current user trust tier
- [x] Progress indicator toward eligibility
- [x] CTA: "View requirements" or "Keep earning"

### Props Interface
```typescript
interface InstantModeUnavailableScreenProps {
  currentTier: number;
  requiredTier: number;
  reason: 'TRUST_TOO_LOW' | 'NO_LIVE_TASKS' | 'REGION_UNAVAILABLE';
}
```

### Copy Guidelines
- "Live Mode unlocks at Trust Level 3" (not "You're not trusted enough")
- Show concrete progress: "2 more completed tasks to reach Level 3"

---

## E5: ForceUpdateScreen

**File:** `ForceUpdateScreen.tsx`
**Spec:** API_CONTRACT §Force Update Protocol
**Stitch-Prompt:** N/A (blocking screen, no stitch needed)

### Purpose
Blocking screen shown when app version is below minimum required. User CANNOT dismiss or navigate away.

### Required Elements
- [x] HustleXP logo
- [x] "Update Required" title
- [x] Brief explanation: "A new version of HustleXP is available with important updates."
- [x] Single CTA: "Update Now" → links to App Store / Google Play
- [x] NO dismiss button, NO skip, NO close

### Props Interface
```typescript
interface ForceUpdateScreenProps {
  currentVersion: string;
  minimumVersion: string;
  storeUrl: string; // Platform-specific store URL
}
```

### Behavior
- Triggered when API returns `X-Force-Update: true` header
- Covers entire screen — no navigation possible
- Persists across app restart (cached `X-Min-Version` check)
- "Update Now" opens platform store listing via deep link
- App rechecks version on return from store

### Copy Guidelines
- Friendly, not alarming: "A new version is ready!"
- Do NOT mention security vulnerabilities specifically

---

## Navigation

These screens are typically shown as modals or replacements:

```
TaskFeedScreen
    │
    ├── (empty feed) ──▶ NoTasksAvailableScreen
    │
    ├── (instant mode blocked) ──▶ InstantModeUnavailableScreen
    │
    └── TaskDetailScreen
            │
            ├── (not eligible) ──▶ EligibilityMismatchScreen
            │
            └── (trust too low) ──▶ TrustTierLockedScreen

AppRoot
    │
    └── (version check fail) ──▶ ForceUpdateScreen (BLOCKING)
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
