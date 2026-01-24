# CURSOR FRONTEND INSTRUCTIONS

**Purpose:** Step-by-step guide for Cursor to build HustleXP frontend WITHOUT hallucination
**Scope:** FRONTEND ONLY — React Native / Expo
**Status:** ACTIVE

---

## THE ONE RULE

```
YOU ARE A FRONTEND ENGINEER.
YOU BUILD UI SHELLS THAT DISPLAY DATA FROM PROPS.
YOU DO NOT COMPUTE BUSINESS LOGIC.
YOU DO NOT FETCH DATA.
YOU DO NOT INVENT FEATURES.
```

---

## Your Role

You are a **frontend executor**. Your job is to:
1. Read UI specs
2. Build screens that accept props
3. Display data from props
4. Call callbacks passed as props
5. Style using design tokens

You are NOT responsible for:
- Database
- API endpoints
- Business logic
- Eligibility computation
- XP calculation
- Trust tier logic
- Matching algorithms
- Payment processing

**If you need backend data, it comes via props. You never fetch.**

---

## Files You MUST Read

### Before Building Any Screen
```
1. specs/03-frontend/DESIGN_SYSTEM.md      ← Colors, typography, spacing
2. specs/03-frontend/HUSTLER_UI_SPEC.md    ← Hustler role screens
3. specs/03-frontend/POSTER_UI_SPEC.md     ← Poster role screens
4. specs/03-frontend/ONBOARDING_FLOW.md    ← Onboarding screens
5. specs/03-frontend/WALLET_UI_SPEC.md     ← Wallet & payments
6. specs/03-frontend/LIVE_MODE_UI_SPEC.md  ← Live mode (hustler)
7. specs/03-frontend/MESSAGING_UI_SPEC.md  ← In-task messaging
```

### For Specific Screens
```
specs/03-frontend/stitch-prompts/          ← Individual screen specs
prompts/CURSOR_FRONTEND.md                 ← Execution prompts
```

### Files You MAY NOT Read (Backend Concern)
```
❌ specs/01-product/**           ← Product requirements (backend decides)
❌ specs/02-architecture/**      ← Database schema (backend concern)
❌ specs/04-backend/**           ← API contracts (backend builds these)
❌ BUILD_READINESS.md            ← Full-stack guide (not your concern)
```

---

## The Screen Contract

**Every screen you build MUST follow this exact pattern:**

```typescript
/**
 * Screen: [SCREEN_NAME]
 * Spec: specs/03-frontend/[SPEC_FILE].md
 *
 * CRITICAL: UI-only. All data from props. No business logic.
 */

interface ScreenNameProps {
  // Data (comes from parent, you NEVER fetch)
  data?: DataType;

  // Loading state
  isLoading?: boolean;

  // Error state
  error?: Error | null;

  // Callbacks (parent handles logic)
  onAction?: () => void;
  onNavigate?: (screen: string) => void;
}

export function ScreenName({
  data,
  isLoading,
  error,
  onAction
}: ScreenNameProps) {
  // Loading state
  if (isLoading) {
    return <LoadingState />;
  }

  // Error state
  if (error) {
    return <ErrorState message={error.message} />;
  }

  // Empty state
  if (!data) {
    return <EmptyState />;
  }

  // Content state - DISPLAY ONLY
  return (
    <SafeAreaView style={styles.container}>
      <Content data={data} />
      <Button onPress={onAction} title="Action" />
    </SafeAreaView>
  );
}
```

---

## FORBIDDEN Patterns (NEVER Do These)

### ❌ Fetching Data
```typescript
// FORBIDDEN - Screens don't fetch
const [data, setData] = useState();
useEffect(() => {
  fetch('/api/tasks').then(res => setData(res));
}, []);

// CORRECT - Data comes from props
function TaskScreen({ tasks }: { tasks: Task[] }) {
  return <TaskList tasks={tasks} />;
}
```

### ❌ Computing Eligibility
```typescript
// FORBIDDEN - Business logic
const isEligible = user.trustTier >= task.requiredTier;
const canAccept = checkEligibility(user, task);

// CORRECT - Display what props say
function TaskCard({ task, isEligible }: Props) {
  return (
    <Card>
      <Text>{task.title}</Text>
      {!isEligible && <Text>Not eligible</Text>}
    </Card>
  );
}
```

### ❌ Computing XP or Trust
```typescript
// FORBIDDEN - Backend computes this
const xpEarned = calculateXP(task.price, user.streak);
const newTier = computeTrustTier(user.completedTasks);

// CORRECT - Display from props
function XPDisplay({ xpTotal, currentLevel }: Props) {
  return <Text>Level {currentLevel} • {xpTotal} XP</Text>;
}
```

### ❌ Filtering Tasks
```typescript
// FORBIDDEN - Backend filters
const eligibleTasks = tasks.filter(t => canAccept(user, t));
const nearbyTasks = tasks.filter(t => t.distance < 25);

// CORRECT - Display what backend sent (already filtered)
function TaskFeed({ tasks }: { tasks: Task[] }) {
  return tasks.map(task => <TaskCard key={task.id} task={task} />);
}
```

### ❌ Making Decisions
```typescript
// FORBIDDEN - Logic decisions
if (user.verified && task.requiresVerification) {
  showAcceptButton();
}

// CORRECT - Props tell you what to show
function TaskCard({ task, showAcceptButton }: Props) {
  return (
    <Card>
      {showAcceptButton && <Button title="Accept" />}
    </Card>
  );
}
```

### ❌ Inventing Fields
```typescript
// FORBIDDEN - Field not in spec
<Text>{task.estimatedDuration}</Text>  // Where did this come from?

// CORRECT - Only use fields from spec
<Text>{task.title}</Text>
<Text>${task.price / 100}</Text>
```

---

## ALLOWED Patterns (Do These)

### ✅ Props Interface
```typescript
interface TaskCardProps {
  task: {
    id: string;
    title: string;
    price: number;
    category: string;
  };
  onAccept?: () => void;
  isLoading?: boolean;
}
```

### ✅ Loading States
```typescript
if (isLoading) {
  return (
    <View style={styles.loading}>
      <ActivityIndicator />
      <Text>Loading tasks...</Text>
    </View>
  );
}
```

### ✅ Empty States
```typescript
if (!tasks || tasks.length === 0) {
  return (
    <View style={styles.empty}>
      <Text>No tasks available</Text>
      <Text>Check back later</Text>
    </View>
  );
}
```

### ✅ Error States
```typescript
if (error) {
  return (
    <View style={styles.error}>
      <Text>Something went wrong</Text>
      <Button title="Retry" onPress={onRetry} />
    </View>
  );
}
```

### ✅ Callbacks to Parent
```typescript
<Button
  title="Accept Task"
  onPress={() => onAccept?.(task.id)}
/>
```

### ✅ Conditional Display (from props)
```typescript
{props.showPrice && <Text>${props.task.price / 100}</Text>}
{props.isEligible ? <AcceptButton /> : <IneligibleBadge />}
```

---

## Design Tokens (AUTHORITATIVE — Use Exactly)

**Source: STITCH HTML specifications + BOOTSTRAP.md**

### Colors
```typescript
// AUTHORITATIVE COLOR TOKENS — DO NOT CHANGE
export const colors = {
  // Brand
  brand: {
    primary: '#1FAD7E',      // HustleXP teal-green (NOT #FF6B35)
    yellow: '#FFD900',       // Instant mode
  },

  // Apple System Colors
  apple: {
    red: '#FF3B30',
    orange: '#FF9500',
    green: '#34C759',
    blue: '#007AFF',
    gray: '#8E8E93',
  },

  // Semantic
  success: '#34C759',        // Apple green
  error: '#FF3B30',          // Apple red
  warning: '#FF9500',        // Apple orange
  info: '#007AFF',           // Apple blue

  // Background
  background: {
    primary: '#000000',      // Pure black (NOT #0D0D0D)
    elevated: '#1C1C1E',
  },

  // Glass (glassmorphism)
  glass: {
    surface: 'rgba(28, 28, 30, 0.6)',
    border: 'rgba(255, 255, 255, 0.1)',
  },

  // Text
  text: {
    primary: '#FFFFFF',
    secondary: '#E5E5EA',
    muted: '#8E8E93',
  },

  // Zinc scale (for subtle UI)
  zinc: {
    400: '#A1A1AA',
    500: '#71717A',
    600: '#52525B',
    700: '#3F3F46',
    800: '#27272A',
  },
} as const;
```

### Typography
```typescript
const typography = {
  display: { fontSize: 36, fontWeight: '700', tracking: -0.5 },
  title1: { fontSize: 28, fontWeight: '700', tracking: -0.3 },
  title2: { fontSize: 24, fontWeight: '600' },
  headline: { fontSize: 18, fontWeight: '600' },
  body: { fontSize: 16, fontWeight: '400' },
  callout: { fontSize: 14, fontWeight: '400' },
  caption: { fontSize: 12, fontWeight: '500' },
  micro: { fontSize: 10, fontWeight: '600', tracking: 1 },
};
```

### Spacing
```typescript
const spacing = {
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
};
```

### Border Radius
```typescript
const radius = {
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  '2xl': 24,
  full: 9999,
};
```

**DO NOT invent new tokens. Use only what exists.**
**If colors here conflict with DESIGN_SYSTEM.md, THIS FILE WINS.**

---

## Screen Categories

### Hustler Screens (specs/03-frontend/HUSTLER_UI_SPEC.md)
```
- Task Feed
- Task Detail
- Accept Task
- Active Task
- Submit Proof
- Task Complete (XP animation)
- Profile
- Settings
```

### Hustler Wallet (specs/03-frontend/WALLET_UI_SPEC.md)
```
- Wallet Home (balance, transactions)
- Withdrawal Flow (3 steps)
- Payout Settings
```

### Hustler Live Mode (specs/03-frontend/LIVE_MODE_UI_SPEC.md)
```
- Live Mode Toggle
- Active Session Header
- Live Task Broadcast Card
- Session Summary
- Cooldown Display
```

### Poster Screens (specs/03-frontend/POSTER_UI_SPEC.md)
```
- Create Task
- My Posted Tasks
- Task Detail (poster view)
- Hustler On Way (tracking)
- Review Proof
- Approve/Reject
- Profile
- Settings
```

### Poster Payments (specs/03-frontend/WALLET_UI_SPEC.md)
```
- Payment Methods
- Transaction History
```

### Onboarding Screens (specs/03-frontend/ONBOARDING_FLOW.md)
```
- Role Selection
- Location Setup
- Capability Declaration
- License Claim
- Insurance Claim
- Risk Preferences
- Summary
```

### Messaging (specs/03-frontend/MESSAGING_UI_SPEC.md)
```
- Message List
- Thread View
- Closed Thread State
```

### Shared Screens
```
- Login/Signup (Firebase Auth UI)
- Notifications
- Dispute Flow
- Rating Screen
```

---

## Implementation Checklist

Before committing ANY screen, verify:

```
[ ] Data comes from props (not fetched)
[ ] No business logic in component
[ ] No eligibility computation
[ ] No XP/trust calculation
[ ] No task filtering
[ ] Loading state implemented
[ ] Empty state implemented
[ ] Error state implemented
[ ] Uses design tokens only
[ ] All fields exist in spec
[ ] Callbacks go to parent
[ ] Header comment references spec file
```

---

## When to STOP and ASK

**STOP immediately and ask the user if:**

```
1. Screen is not in the spec
2. You need a field not defined in the spec
3. You need to compute something
4. You need to fetch data
5. You need to add a dependency
6. The spec seems incomplete
7. You want to "improve" the design
8. You're unsure about anything
```

**DO NOT:**
```
1. Guess what the spec meant
2. Fill in gaps with assumptions
3. Add features not in spec
4. "Improve" the UI beyond spec
5. Make it "better" than specified
```

---

## Stitch Prompts

For detailed screen implementations, use the stitch prompts:

```
specs/03-frontend/stitch-prompts/
├── 01-instant-interrupt-card.md
├── 04-poster-task-creation.md
├── 09-hustler-task-completion.md
├── 11-poster-feedback.md
├── 12-trust-change-explanation.md
├── E1-no-tasks-available.md
├── E2-eligibility-mismatch.md
└── ...
```

Each stitch prompt contains:
- Exact layout specifications
- Pixel-perfect measurements
- Copy text to use
- Component hierarchy
- Interaction states

**Follow stitch prompts EXACTLY.**

---

## File Structure

```
hustlexp-app/
├── src/
│   ├── screens/
│   │   ├── hustler/
│   │   │   ├── TaskFeedScreen.tsx
│   │   │   ├── TaskDetailScreen.tsx
│   │   │   ├── ActiveTaskScreen.tsx
│   │   │   └── ...
│   │   ├── poster/
│   │   │   ├── CreateTaskScreen.tsx
│   │   │   ├── ReviewProofScreen.tsx
│   │   │   └── ...
│   │   ├── onboarding/
│   │   │   ├── RoleSelectionScreen.tsx
│   │   │   ├── LocationScreen.tsx
│   │   │   └── ...
│   │   └── shared/
│   │       ├── MessagingScreen.tsx
│   │       ├── NotificationsScreen.tsx
│   │       └── ...
│   │
│   ├── components/
│   │   ├── GlassCard.tsx
│   │   ├── PrimaryButton.tsx
│   │   ├── SectionHeader.tsx
│   │   ├── LoadingState.tsx
│   │   ├── EmptyState.tsx
│   │   └── ...
│   │
│   ├── constants/
│   │   ├── colors.ts
│   │   ├── typography.ts
│   │   ├── spacing.ts
│   │   └── ...
│   │
│   └── types/
│       ├── task.ts
│       ├── user.ts
│       └── ...
│
└── app.json
```

---

## When Is a Screen DONE?

**CRITICAL: "Builds without crashing" is NECESSARY but INSUFFICIENT.**

A screen is DONE **only if ALL of the following are true**:

### UAP Gate Checklist (MANDATORY)

```
[ ] UAP-0: PURPOSE GATE
    - Screen answers WHO is this for?
    - Screen answers WHAT do I do next?
    - Screen answers WHY should I care?
    - All three answerable within 3 seconds

[ ] UAP-1: HIERARCHY GATE
    - Has PRIMARY ACTION (the main thing user can do)
    - Has SUPPORTING CONTEXT (information to inform decision)
    - Has BRAND/EMOTIONAL SIGNAL (trust, polish, identity)

[ ] UAP-2: MOTION/DEPTH GATE (Entry/Onboarding only)
    - Has animation, gradient, glass, shadow, OR parallax
    - Static flat screens NOT allowed for entry/onboarding

[ ] UAP-3: SPEC FIDELITY GATE
    - Layout matches spec wireframe exactly
    - Copy text matches spec verbatim (no AI rewrites)
    - Colors use spec tokens only
    - Typography uses spec scale only
    - Spacing uses spec scale only

[ ] UAP-4: BOOTSTRAP SEPARATION GATE
    - Screen is NOT a bootstrap/verification placeholder
    - Screen is in SCREEN_REGISTRY with UAP Status = PASSED
    - If bootstrap: is behind debug flag and marked INTERNAL

If ANY checkbox is unchecked → SCREEN IS NOT COMPLETE
```

### What "Complete" Means

| Status | Meaning |
|--------|---------|
| **BUILDS** | Code compiles, no crashes |
| **RENDERS** | UI appears on screen |
| **COMPLETE** | Passes all 5 UAP gates |

**BUILD SUCCESS + UAP FAILURE = INCOMPLETE SCREEN**

### Authority Hierarchy

```
AUTHORITY ORDER (Highest → Lowest)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. UI_ACCEPTANCE_PROTOCOL (UAP)     ← HIGHEST
2. Screen Specs (screens-spec/*)
3. Phase Constraints (.cursorrules)
4. Implementation Instructions (this file)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

UAP outranks ALL phase constraints. No phase (including BOOTSTRAP) may override UAP for user-facing screens.

### Before Marking Any Screen Complete

1. Run the UAP Gate Checklist above
2. Compare output to spec reference element-by-element
3. Verify screen is listed in SCREEN_REGISTRY.md
4. Update UAP Status column to PASSED or FAILED

**If you cannot pass all gates, STOP and ask the user.**

See: `PER/UI_ACCEPTANCE_PROTOCOL.md` for full gate definitions and examples.

---

## Summary

```
1. You build UI shells
2. Data comes from props
3. You never fetch
4. You never compute
5. You display what you're given
6. You call callbacks for actions
7. You use design tokens exactly
8. You follow specs exactly
9. You verify against UAP gates
10. "Builds" ≠ "Complete"
11. If unclear, you ask
```

**You are a frontend executor. The specs are complete. Build exactly what they say. Verify against UAP before marking done.**

---

**END OF CURSOR FRONTEND INSTRUCTIONS**
