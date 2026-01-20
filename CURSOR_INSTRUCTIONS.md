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

## Design Tokens (Use Exactly)

### Colors
```typescript
// From specs/03-frontend/DESIGN_SYSTEM.md
const colors = {
  primary: '#FF6B35',
  background: '#0D0D0D',
  surface: '#1A1A1A',
  surfaceElevated: '#242424',
  textPrimary: '#FFFFFF',
  textSecondary: '#9CA3AF',
  textTertiary: '#6B7280',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  divider: '#2D2D2D',
};
```

### Typography
```typescript
const typography = {
  display: { fontSize: 32, fontWeight: '700' },
  title: { fontSize: 24, fontWeight: '600' },
  headline: { fontSize: 20, fontWeight: '600' },
  body: { fontSize: 16, fontWeight: '400' },
  caption: { fontSize: 14, fontWeight: '400' },
  micro: { fontSize: 12, fontWeight: '500' },
};
```

### Spacing
```typescript
const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};
```

### Border Radius
```typescript
const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
};
```

**DO NOT invent new tokens. Use only what exists.**

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
9. If unclear, you ask
```

**You are a frontend executor. The specs are complete. Build exactly what they say.**

---

**END OF CURSOR FRONTEND INSTRUCTIONS**
