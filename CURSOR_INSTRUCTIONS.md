# CURSOR IMPLEMENTATION INSTRUCTIONS

**Purpose:** Step-by-step guide for Cursor to build HustleXP MVP without hallucination
**Status:** ACTIVE — Follow these instructions exactly
**Last Updated:** January 2025

---

## CRITICAL: Read Before Building Anything

### The One Rule
```
IMPLEMENT EXACTLY WHAT THE SPECS SAY.
DO NOT INVENT. DO NOT IMPROVE. DO NOT ASSUME.
IF UNCLEAR, STOP AND ASK.
```

### Your Role
You are an **executor**, not a designer. The specs are complete. Your job is to translate them into working code.

---

## Step 0: Understand the Architecture

### File Hierarchy (Read in Order)
```
1. BUILD_READINESS.md         ← Start here (overview + build order)
2. specs/04-backend/BUILD_GUIDE.md  ← Master authority hierarchy
3. specs/02-architecture/schema.sql  ← All database tables
4. specs/04-backend/API_CONTRACT.md  ← All API endpoints
5. specs/SPEC_CLARIFICATIONS.md      ← Conflict resolutions
```

### Authority Layers (Never Violate)
```
Layer 0: PostgreSQL constraints     ← HIGHEST (immutable)
Layer 1: Backend state machines     ← Business logic
Layer 2: Temporal enforcement       ← Time rules
Layer 3: Stripe integration         ← Payments
Layer 4: AI proposals               ← Suggestions only
Layer 5: Frontend state             ← UI state
Layer 6: Client rendering           ← Display only
```

**Rule:** Higher layers cannot override lower layers. Frontend NEVER computes eligibility, XP, or trust.

---

## Step 1: Set Up the Project

### Tech Stack (Required)
```
Frontend:
  - React Native with Expo
  - TypeScript (strict mode)
  - React Query for server state
  - Zustand for UI state only

Backend:
  - Node.js + TypeScript
  - tRPC for API
  - PostgreSQL (use Supabase or Neon)
  - Redis for caching + Live Mode

Auth: Firebase Auth
Payments: Stripe Connect
Storage: Cloudflare R2
```

### Directory Structure
```
hustlexp/
├── apps/
│   └── mobile/           ← React Native app
│       ├── src/
│       │   ├── screens/  ← Screen components
│       │   ├── components/ ← Shared UI
│       │   ├── hooks/    ← React hooks
│       │   ├── api/      ← tRPC client
│       │   └── types/    ← TypeScript types
│       └── app.json
│
├── packages/
│   ├── api/              ← tRPC router definitions
│   │   ├── src/
│   │   │   ├── routers/  ← task.ts, user.ts, etc.
│   │   │   └── trpc.ts   ← tRPC setup
│   │   └── package.json
│   │
│   └── db/               ← Database utilities
│       ├── src/
│       │   ├── schema.ts ← Drizzle/Prisma schema
│       │   └── client.ts ← DB client
│       └── package.json
│
└── package.json          ← Workspace root
```

---

## Step 2: Implement Database Schema

### Source File
```
specs/02-architecture/schema.sql
```

### Instructions
1. Read the entire schema.sql file
2. Create all tables in the exact order they appear
3. Create all triggers and functions
4. Run the schema against your PostgreSQL instance
5. Verify all constraints are active

### Validation Checklist
```
[ ] users table created with all columns
[ ] tasks table created with state CHECK constraint
[ ] escrows table created with terminal state trigger
[ ] xp_ledger table created with INV-1 trigger
[ ] All 31 tables created
[ ] All indexes created
[ ] All triggers created
```

### DO NOT
- Modify column names
- Add columns not in the spec
- Remove constraints
- Skip triggers

---

## Step 3: Implement API Endpoints

### Source File
```
specs/04-backend/API_CONTRACT.md
```

### Implementation Order
```
Phase 1: Core CRUD
  1. user.getProfile
  2. user.updateProfile
  3. task.create
  4. task.getById
  5. task.list

Phase 2: Task Lifecycle
  6. task.accept
  7. task.submitProof
  8. proof.accept / proof.reject
  9. task.complete
  10. task.cancel

Phase 3: Escrow
  11. escrow.createIntent
  12. escrow.release
  13. escrow.refund
  14. Stripe webhook handler

Phase 4: Onboarding
  15. onboarding.getProgress
  16. onboarding.setRole
  17. onboarding.submitCapabilities
  18. onboarding.completeStep
  19. onboarding.complete

Phase 5: Verification
  20. verification.submitLicense
  21. verification.submitInsurance
  22. verification.initiateBackgroundCheck
  23. verification.getStatus
  24. verification.getCapabilityProfile

Phase 6: Feed & Matching
  25. task.getFeed
  26. task.getMatchingScore

Phase 7: Live Mode
  27. liveMode.activate
  28. liveMode.deactivate
  29. liveMode.getStatus
  30. liveMode.updateLocation
  31. liveMode.respondToBroadcast

Phase 8: Messaging & Notifications
  32. messaging.getThread
  33. messaging.sendMessage
  34. messaging.markRead
  35. notification.list
  36. notification.markRead

Phase 9: Disputes & Ratings
  37. dispute.create
  38. dispute.resolve
  39. rating endpoints
```

### For Each Endpoint
1. Copy the Input type from API_CONTRACT.md
2. Copy the Output type from API_CONTRACT.md
3. Implement the handler
4. Validate input against the schema
5. Return exact output shape
6. Handle all documented error codes

### DO NOT
- Add fields not in the spec
- Remove required fields
- Change field types
- Invent new endpoints

---

## Step 4: Implement Matching Algorithm

### Source File
```
specs/04-backend/MATCHING_ALGORITHMS.md
```

### Instructions
1. Implement the master formula exactly:
   ```
   matchingScore = Σ(component × weight) × eligibilityMultiplier
   ```
2. Implement all 6 component calculations
3. Use the exact weights specified
4. Implement eligibility checks in order
5. Implement feed sorting with tie-breakers

### DO NOT
- Change the weights
- Add new components
- Skip eligibility checks
- Modify the formula

---

## Step 5: Implement AI Services (Optional for MVP)

### Source File
```
specs/04-backend/AI_SERVICE_INTERFACES.md
```

### Key Rule
**AI proposes, deterministic systems decide, database enforces.**

### For MVP
- Implement **fallback functions only** (no AI calls needed)
- Fallbacks are provided in the spec
- AI integration can come later

### DO NOT
- Let AI write directly to database
- Let AI bypass eligibility checks
- Let AI award XP or change trust tier

---

## Step 6: Implement Frontend Screens

### Source Files
```
specs/03-frontend/HUSTLER_UI_SPEC.md   ← Hustler role
specs/03-frontend/POSTER_UI_SPEC.md    ← Poster role
specs/03-frontend/DESIGN_SYSTEM.md     ← Colors, typography, spacing
specs/03-frontend/ONBOARDING_FLOW.md   ← Onboarding screens
```

### The Screen Contract
Every screen follows this pattern:
```typescript
interface ScreenProps {
  data?: DataType;        // From parent, never fetched in screen
  isLoading?: boolean;    // Loading state
  error?: Error;          // Error state
  onAction?: () => void;  // Callbacks to parent
}

export function Screen({ data, isLoading, error, onAction }: ScreenProps) {
  if (isLoading) return <LoadingState />;
  if (error) return <ErrorState error={error} />;
  if (!data) return <EmptyState />;
  return <Content data={data} onAction={onAction} />;
}
```

### CRITICAL Frontend Rules
```
1. Screens NEVER fetch data (props only)
2. Screens NEVER compute eligibility
3. Screens NEVER compute XP or trust
4. Screens NEVER filter tasks
5. All business logic lives in backend
6. Frontend is DISPLAY ONLY
```

### Forbidden Patterns
```typescript
// ❌ NEVER DO THIS
const isEligible = user.trustTier >= task.requiredTier;

// ❌ NEVER DO THIS
const xp = calculateXP(task);

// ❌ NEVER DO THIS
const filteredTasks = tasks.filter(t => canAccept(t));

// ❌ NEVER DO THIS
fetch('/api/tasks').then(setTasks);

// ✅ CORRECT - Display what props provide
return <TaskCard task={props.task} />;

// ✅ CORRECT - Call parent callback
<Button onPress={props.onAcceptTask} />;
```

---

## Step 7: Handle Edge Cases

### Source File
```
specs/SPEC_CLARIFICATIONS.md
```

### Key Clarifications

**Eligibility Precedence:**
```
1. Location State Match (REQUIRED)
2. Trade Verification (IF REQUIRED)
3. Trust Tier (ALWAYS)
4. Risk Clearance (ALWAYS)
5. Insurance (IF REQUIRED)
6. Background Check (IF REQUIRED)
```

**Rating Reveal Timing:**
```
Reveal when: (both_parties_rated) OR (7_days_elapsed)
```

**XP Award Timing:**
```
XP awarded when: escrow.state = 'RELEASED'
NOT when: funds settle or hustler withdraws
```

**Price Minimums:**
```
STANDARD mode: $5.00 minimum (500 cents)
LIVE mode: $15.00 minimum (1500 cents)
```

---

## Step 8: Testing

### Unit Tests Required
```
- All API endpoint handlers
- Matching algorithm calculations
- Eligibility check logic
- XP calculation formulas
- State machine transitions
```

### Integration Tests Required
```
- Task lifecycle: create → accept → proof → complete
- Escrow flow: create → fund → release
- Live mode: broadcast → accept
- Rating reveal: both rate → reveal
```

### E2E Tests Required
```
- Complete hustler journey
- Complete poster journey
- Dispute flow
- Onboarding flow
```

---

## Anti-Hallucination Checklist

Before committing any code, verify:

```
[ ] Code matches spec exactly (no additions)
[ ] No invented fields or endpoints
[ ] No client-side business logic
[ ] No eligibility computation in frontend
[ ] No XP/trust computation in frontend
[ ] All types match API_CONTRACT.md
[ ] All database writes match schema.sql
[ ] All invariants respected (INV-1 through INV-5)
[ ] Error codes match spec
[ ] State transitions match spec
```

---

## When to Stop and Ask

**STOP and ask the user if:**
```
1. Spec seems incomplete
2. Spec seems contradictory
3. You think the spec is wrong
4. You want to add something not in spec
5. You want to improve something
6. Implementation requires external dependency not listed
7. You need to modify database constraints
8. You need to add a new endpoint
```

**DO NOT:**
```
1. Guess what the spec meant
2. Fill in gaps with assumptions
3. "Improve" the spec
4. Add features not requested
5. Change the architecture
```

---

## Quick Reference: File → Purpose

| File | When to Read |
|------|--------------|
| `BUILD_READINESS.md` | Starting a new phase |
| `specs/04-backend/BUILD_GUIDE.md` | Understanding authority |
| `specs/02-architecture/schema.sql` | Creating/modifying tables |
| `specs/04-backend/API_CONTRACT.md` | Implementing endpoints |
| `specs/04-backend/MATCHING_ALGORITHMS.md` | Implementing feed |
| `specs/04-backend/AI_SERVICE_INTERFACES.md` | Implementing AI |
| `specs/SPEC_CLARIFICATIONS.md` | Resolving ambiguities |
| `specs/03-frontend/DESIGN_SYSTEM.md` | Styling components |
| `specs/03-frontend/HUSTLER_UI_SPEC.md` | Building hustler screens |
| `specs/03-frontend/POSTER_UI_SPEC.md` | Building poster screens |

---

## Summary

```
1. Read the spec
2. Implement exactly what it says
3. Do not add anything
4. Do not improve anything
5. If unclear, ask
6. Verify against checklist
7. Commit
```

**The specs are complete. Your job is execution, not design.**

---

**END OF CURSOR INSTRUCTIONS**
