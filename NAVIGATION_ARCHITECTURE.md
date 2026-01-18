# Navigation Architecture (MAX-TIER)

**Date:** 2025-01-17  
**Status:** LOCKED (Phase N1)  
**Authority:** Navigation wiring spec

---

## Executive Summary

Navigation structure for HustleXP app using React Navigation. Declarative route guards reference state (do not compute it). Canonical entry points enforce authority boundaries.

---

## Navigation Stack Structure

### Root Stack

```
RootStackNavigator
├── AuthStack (unauthenticated)
├── CalibrationOnboardingStack (System A)
├── CapabilityOnboardingStack (System B)
├── HustlerMainStack (role: hustler | both)
├── PosterMainStack (role: poster | both)
├── SettingsStack (accessible from main)
└── SharedModalStack (modals, accessible from any)
```

### Stack Details

#### 1. Auth Stack

**Purpose:** Authentication flow (unauthenticated users only)

**Screens:**
- `Login`
- `Signup`
- `ForgotPassword`

**Entry Guard:** `isUnauthenticated(state)`

**Exit Condition:** `isAuthenticated(state)` → CalibrationOnboarding

---

#### 2. Calibration Onboarding Stack (System A)

**Purpose:** Role inference and UX personalization

**Screens:**
- `Framing` (Phase 0)
- `Calibration` (Phase 1: 5 behavioral questions)
- `RoleConfirmation` (Phase 3)
- `PreferenceLock` (Phase 4)

**Entry Guard:** `isAuthenticated(state) && needsCalibration(state)`

**Exit Condition:** `isCalibrationComplete(state)` → CapabilityOnboarding

**Flow:** Sequential (Framing → Calibration → RoleConfirmation → PreferenceLock)

---

#### 3. Capability Onboarding Stack (System B)

**Purpose:** Eligibility and verification paths (authoritative)

**Screens:**
- `RoleDeclaration` (Phase 0)
- `LocationSelection` (Phase 1)
- `CapabilityDeclaration` (Phase 2)
- `CredentialClaim` (Phase 3 - conditional)
- `LicenseMetadata` (Phase 4 - conditional)
- `InsuranceClaim` (Phase 5 - conditional)
- `RiskWillingness` (Phase 6)
- `CapabilitySummary` (Phase 7)

**Entry Guard:** `isAuthenticated(state) && isCalibrationComplete(state) && needsCapability(state)`

**Exit Condition:** `isCapabilityComplete(state)` → HustlerMain or PosterMain

**Flow:** Sequential with conditional branches (Phases 3-5 conditional based on Phase 2 selections)

---

#### 4. Hustler Main Stack

**Purpose:** Hustler primary workflow

**Screens:**
- `Home` (HustlerHomeScreen)
- `TaskFeed` (TaskFeedScreen - canonical feed)
- `TaskHistory` (TaskHistoryScreen - past tasks only)
- `TaskDetail` (task detail view)
- `TaskInProgress` (EN_ROUTE / WORKING states)
- `TaskCompletion` (completion confirmation)
- `XPBreakdown` (XP breakdown view)
- `InstantInterrupt` (modal - instant task interrupt)

**Entry Guard:** `canAccessMainApp(state) && canAccessHustlerStack(state)`

**Initial Route:** `Home`

**Task-State Gated Routes:**
- `TaskInProgress`: `hasActiveTask(state) && (isTaskAccepted(state) || isTaskWorking(state))`
- `TaskCompletion`: `hasActiveTask(state) && isTaskCompleted(state)`
- `HustlerEnRouteMapScreen` (future): `isTaskEnRoute(state)`

---

#### 5. Poster Main Stack

**Purpose:** Poster primary workflow

**Screens:**
- `TaskCreation` (create new task)
- `HustlerOnWay` (hustler en-route status)
- `TaskCompletion` (task completion confirmation)
- `Feedback` (post-task feedback)

**Entry Guard:** `canAccessMainApp(state) && canAccessPosterStack(state)`

**Initial Route:** `TaskCreation`

**Task-State Gated Routes:**
- `HustlerOnWay`: `hasActiveTask(state) && (isTaskAccepted(state) || isTaskEnRoute(state) || isTaskWorking(state))`

---

#### 6. Settings Stack

**Purpose:** User settings (accessible from main stacks)

**Screens:**
- `Profile` (user profile, XP, badges)
- `Wallet` (earnings, payouts, payment settings)
- `WorkEligibility` (verification and eligibility status)

**Entry Guard:** `canAccessMainApp(state)`

**Access:** Navigated to from main stacks (not initial route)

---

#### 7. Shared Modal Stack

**Purpose:** Shared modals and edge states (accessible from any stack)

**Screens:**
- `TrustTierLadder` (trust tier explanation)
- `TrustChangeExplanation` (trust change details)
- `DisputeEntry` (dispute submission)
- `NoTasksAvailable` (E1 edge state)
- `EligibilityMismatch` (E2 edge state)
- `TrustTierLocked` (E3 edge state)

**Entry Guard:** None (accessible from any stack when state requires)

**Access:** Modal overlay from any stack

---

## Route Guards (Declarative)

Guards reference state, they do not compute it.

### Authentication Guards

| Guard | Condition | Used For |
|-------|-----------|----------|
| `isAuthenticated(state)` | `state.isAuthenticated === true` | Main stacks entry |
| `isUnauthenticated(state)` | `state.isAuthenticated === false` | Auth stack entry |

### Role-Based Guards

| Guard | Condition | Used For |
|-------|-----------|----------|
| `canAccessHustlerStack(state)` | `state.role === 'hustler' \|\| state.role === 'both'` | HustlerMain entry |
| `canAccessPosterStack(state)` | `state.role === 'poster' \|\| state.role === 'both'` | PosterMain entry |
| `hasRole(state)` | `state.role !== null` | Main stacks entry |

### Onboarding Guards

| Guard | Condition | Used For |
|-------|-----------|----------|
| `isCalibrationComplete(state)` | `state.onboarding.calibrationComplete === true` | CapabilityOnboarding entry |
| `isCapabilityComplete(state)` | `state.onboarding.capabilityComplete === true` | Main stacks entry |
| `isOnboardingComplete(state)` | Both calibration and capability complete | Main stacks entry |
| `needsCalibration(state)` | `!state.onboarding.calibrationComplete` | CalibrationOnboarding entry |
| `needsCapability(state)` | `!state.onboarding.capabilityComplete` | CapabilityOnboarding entry |

### Task-State Guards

| Guard | Condition | Used For |
|-------|-----------|----------|
| `isTaskEnRoute(state)` | `state.currentTask.status === 'EN_ROUTE'` | HustlerEnRouteMapScreen (future) |
| `isTaskAccepted(state)` | `state.currentTask.status === 'ACCEPTED'` | TaskInProgress entry |
| `isTaskWorking(state)` | `state.currentTask.status === 'WORKING'` | TaskInProgress entry |
| `isTaskCompleted(state)` | `state.currentTask.status === 'COMPLETED'` | TaskCompletion entry |
| `hasActiveTask(state)` | `state.currentTask.id !== null && state.currentTask.status !== null` | Task-state-gated routes |

### Combined Guards

| Guard | Condition | Used For |
|-------|-----------|----------|
| `canAccessMainApp(state)` | `isAuthenticated(state) && hasRole(state) && isOnboardingComplete(state)` | Main stacks entry |

---

## Canonical Entry Points (LOCKED)

Each screen has exactly one entry point:

| Screen | Entry Point | Guard |
|--------|-------------|-------|
| `TaskFeedScreen` | HustlerMain → TaskFeed | `canAccessMainApp(state) && canAccessHustlerStack(state)` |
| `TaskHistoryScreen` | HustlerMain → TaskHistory | `canAccessMainApp(state) && canAccessHustlerStack(state)` |
| `HustlerEnRouteMapScreen` (future) | HustlerMain → TaskInProgress → HustlerEnRouteMap | `isTaskEnRoute(state)` |
| `HustlerOnWayScreen` (with map) | PosterMain → HustlerOnWay | `isTaskAccepted(state) \|\| isTaskEnRoute(state) \|\| isTaskWorking(state)` |

**No deep links that bypass authority.**

---

## Initial Route Determination

Initial route is determined by state guards in this priority order:

1. **Auth** (if `isUnauthenticated(state)`)
2. **CalibrationOnboarding** (if `isAuthenticated(state) && needsCalibration(state)`)
3. **CapabilityOnboarding** (if `isAuthenticated(state) && isCalibrationComplete(state) && needsCapability(state)`)
4. **HustlerMain** (if `canAccessMainApp(state) && canAccessHustlerStack(state)`)
5. **PosterMain** (if `canAccessMainApp(state) && canAccessPosterStack(state)`)

**Function:** `getInitialRoute(state)`

---

## Forbidden Transitions (NON-NEGOTIABLE)

These transitions are **forbidden** and must be prevented:

1. **Auth → Main** (without onboarding)
   - Violation: Bypasses onboarding
   - Prevention: Guard checks `isOnboardingComplete(state)`

2. **Calibration → Main** (without Capability)
   - Violation: Bypasses capability onboarding
   - Prevention: Guard checks `isCapabilityComplete(state)`

3. **Capability → Main** (without Calibration)
   - Violation: Skips calibration
   - Prevention: Guard checks `isCalibrationComplete(state)`

4. **Main → TaskFeed** (bypassing auth)
   - Violation: Unauthenticated access
   - Prevention: Guard checks `isAuthenticated(state)`

5. **TaskDetail → TaskInProgress** (without task state)
   - Violation: Task-state-gated route without state
   - Prevention: Guard checks `hasActiveTask(state) && (isTaskAccepted(state) || isTaskWorking(state))`

6. **Any → Map Screen** (without EN_ROUTE state)
   - Violation: Map requires EN_ROUTE state
   - Prevention: Guard checks `isTaskEnRoute(state)`

---

## Navigation State (Mock - Phase N1)

Navigation state for Phase N1 (mock data):

```typescript
interface NavigationState {
  isAuthenticated: boolean;
  role: 'hustler' | 'poster' | 'both' | null;
  onboarding: {
    calibrationComplete: boolean;
    capabilityComplete: boolean;
  };
  currentTask: {
    id: string | null;
    status: 'ACCEPTED' | 'EN_ROUTE' | 'WORKING' | 'COMPLETED' | null;
  };
}
```

**Phase N1:** Mock state (hardcoded values for routing)

**Phase N2:** Real state (backend integration)

---

## File Structure

```
hustlexp-app/navigation/
├── index.ts              # Navigation exports
├── types.ts              # Navigation type definitions
├── guards.ts             # Declarative route guards
├── RootNavigator.tsx     # Root stack navigator (future)
├── AuthStack.tsx         # Auth stack (future)
├── CalibrationOnboardingStack.tsx  # System A stack (future)
├── CapabilityOnboardingStack.tsx   # System B stack (future)
├── HustlerMainStack.tsx  # Hustler main stack (future)
├── PosterMainStack.tsx   # Poster main stack (future)
├── SettingsStack.tsx     # Settings stack (future)
└── SharedModalStack.tsx  # Shared modals stack (future)
```

---

## Implementation Status

**Phase N1:** ✅ COMPLETE

**Completed:**
- ✅ Navigation types defined (`navigation/types.ts`)
- ✅ Route guards defined (`navigation/guards.ts`)
- ✅ Stack navigators implemented (all 7 stacks)
- ✅ RootNavigator implemented (`navigation/RootNavigator.tsx`)
- ✅ App.tsx wired to navigation
- ✅ Mock state wiring complete

**Phase N2:** Backend handlers integration (next phase)

---

## Dependencies

**Required:**
- `@react-navigation/native` (✅ installed)
- `@react-navigation/stack` (needs installation)
- `react-native-screens` (✅ installed)
- `react-native-safe-area-context` (✅ installed)

**Installation:**
```bash
npm install @react-navigation/stack
```

---

## Done Criteria (Phase N1)

Phase N1 is complete when:

- [x] Navigation types defined
- [x] Route guards defined
- [x] Stack navigators implemented
- [x] App.tsx wired to navigation
- [x] App launches with mock state only
- [x] No screen is reachable outside its authority
- [x] Navigation graph documented

**Status:** ✅ COMPLETE (2025-01-17)

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED (Phase N1 - Navigation Wiring)  
**Authority:** Navigation wiring spec
