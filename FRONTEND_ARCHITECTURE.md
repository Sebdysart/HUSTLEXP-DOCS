# HustleXP Frontend Architecture

> **⚠️ TECH STACK NOTE:** Code examples in this document use JavaScript/React patterns (legacy scaffold). The active iOS app (HUSTLEXPFINAL1) is **native Swift/SwiftUI**. Map to SwiftUI equivalents (NavigationContainer → NavigationStack, state machines → Swift enums, etc.). The architectural principles, color authority, animation constraints, and UI rules remain authoritative regardless of framework.
> - **Note:** Originally spec'd as React Native/Expo but implemented as native SwiftUI

**Authority:** UI_SPEC.md v1.3.0, ONBOARDING_SPEC.md v1.3.0, ARCHITECTURE.md  
**Status:** Constitutional Implementation Guide  
**Last Updated:** January 2025

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Visual Design System](#visual-design-system)
3. [Component Architecture](#component-architecture)
4. [User Flows](#user-flows)
5. [State Management](#state-management)
6. [API Integration](#api-integration)
7. [Enforcement & Compliance](#enforcement--compliance)

---

## Core Principles

### 1.1 UI Authority (ARCHITECTURE.md §2.5)

**The UI has zero decision authority.**

```
┌─────────────────────────────────────────────────────────┐
│  LAYER HIERARCHY (Authority)                            │
├─────────────────────────────────────────────────────────┤
│  Layer 0: Database    → Absolute truth                   │
│  Layer 1: Backend     → Orchestration                   │
│  Layer 2: API         → Transport                       │
│  Layer 3: AI          → Proposals only                   │
│  Layer 4: Frontend Logic → UX state only                │
│  Layer 5: UI          → Representation only              │
│  Layer 6: Human       → Bounded override                 │
└─────────────────────────────────────────────────────────┘
```

**UI Rules:**
- ✅ UI may render state
- ✅ UI may request actions
- ❌ UI may **never** compute, decide, or assume
- ❌ UI may **never** display unconfirmed state

**Prime Directive:** "AI proposes. Deterministic systems decide. Databases enforce. UI reveals."

---

### 1.2 Constitutional Compliance

Every UI element must align with:
- **UI_SPEC.md** - Visual expression rules
- **ONBOARDING_SPEC.md** - Onboarding flow and gamification timing
- **PRODUCT_SPEC.md** - State machines and business logic
- **ARCHITECTURE.md** - Authority hierarchy

**Violations are build failures, not style issues.**

---

## Visual Design System

### 2.1 Color Authority (UI_SPEC §2)

Colors have **legal meaning**. They are not decorative.

#### XP Colors (Emerald Palette)
```
XP_PRIMARY:    #10B981 (Emerald 500)  → XP displays, level indicators
XP_SECONDARY:  #34D399 (Emerald 400)  → Progress bars, streak counters
XP_BACKGROUND: #D1FAE5 (Emerald 100)   → XP backgrounds
XP_ACCENT:     #059669 (Emerald 600)   → Level-up celebrations
```

**Allowed Contexts:**
- XP amount displays
- Level badges
- Streak indicators
- Progression bars
- Level-up celebrations

**Forbidden Contexts:**
- Task cards (before completion)
- Escrow states
- Navigation elements
- Generic buttons
- Error states

#### Money Colors
```
MONEY_POSITIVE: #10B981 (Green)  → Incoming payments
MONEY_NEGATIVE: #EF4444 (Red)    → Outgoing payments
MONEY_NEUTRAL:  #6B7280 (Gray)   → Pending states
MONEY_LOCKED:   #F59E0B (Amber)  → Disputed escrows
```

**Allowed Contexts:**
- Escrow state indicators
- Payment amounts
- Wallet balances
- Transaction history

#### Status Colors
```
SUCCESS: #10B981  → Confirmation, completion (after server confirms)
WARNING: #F59E0B  → Attention needed, caution
ERROR:   #EF4444  → Failure, rejection, danger
INFO:    #3B82F6  → Neutral information
```

**Usage Rules:**
- SUCCESS: Only after server confirms positive outcome
- ERROR: Only for actual failures, never for emphasis
- WARNING: Only for actionable caution states

---

### 2.2 Typography & Spacing

**Typography Scale:**
- `h1` - 48px (XP amounts, major headings)
- `h2` - 36px (Screen titles)
- `h3` - 24px (Section headers)
- `body` - 16px (Primary text)
- `bodySmall` - 14px (Secondary text)
- `caption` - 12px (Labels, hints)

**Spacing Scale:**
- `SPACING[1]` - 4px
- `SPACING[2]` - 8px
- `SPACING[3]` - 12px
- `SPACING[4]` - 16px
- `SPACING[5]` - 20px
- `SPACING[6]` - 24px
- `SPACING[8]` - 32px
- `SPACING[12]` - 48px

---

### 2.3 Animation System (UI_SPEC §3)

**Duration Limits:**
- Micro-feedback: 150ms max (button press, toggle)
- State transition: 300ms max (screen change, modal)
- Celebration: 2000ms max (level up, badge unlock)
- Loading: Indefinite (but must show progress)

**Forbidden Patterns:**
- ❌ Confetti (casino psychology)
- ❌ Infinite loops (attention hijacking)
- ❌ Randomized motion (untrustworthy)
- ❌ Shake/vibrate (anxiety-inducing)
- ❌ Slot machine reveals (gambling association)
- ❌ Countdown urgency (false scarcity)

**First XP Celebration Sequence (2000ms):**
```
0-300ms:    XP number fade in + scale 1.0→1.1→1.0
300-800ms:  Progress bar linear fill
800-1200ms: "First Task Complete!" fade in
1200-1800ms: Badge unlock (if earned)
1800-2000ms: Settle to static
```

**Reduced Motion:**
- All animations become instant when `prefers-reduced-motion` is enabled
- No exceptions for "important" animations

---

## Component Architecture

### 3.1 Component Hierarchy

```
App.js
├── NavigationContainer
│   ├── AuthNavigator (if not authenticated)
│   ├── OnboardingNavigator (if authenticated, not onboarded)
│   │   ├── FramingScreen (Phase 0)
│   │   ├── CalibrationScreen (Phase 1)
│   │   ├── RoleConfirmationScreen (Phase 3)
│   │   └── PreferenceLockScreen (Phase 4)
│   └── TabNavigator (if authenticated + onboarded)
│       ├── HomeScreen
│       ├── TasksScreen
│       ├── WalletScreen
│       └── ProfileScreen
```

---

### 3.2 Core Components

#### Button Component
- Minimum size: 44×44 points (accessibility)
- Disabled state: Visually distinct, non-interactive
- Loading state: Spinner replaces text, same size
- Success state: Only after server confirmation
- Double-tap prevention: Disabled during request

#### Card Component
- Variants: `elevated`, `outlined`, `flat`
- Padding: Consistent spacing scale
- Border radius: 12px (standard), 8px (compact)

#### Text Component (HXText)
- Variants: `h1`, `h2`, `h3`, `body`, `bodySmall`, `caption`, `label`
- Colors: `primary`, `secondary`, `tertiary` (semantic)
- Weight: `regular`, `semibold`, `bold`

#### Input Component
- Validation: Show errors inline, after blur
- Submission: Disable form during request
- Error recovery: Preserve valid input on error

---

### 3.3 Constitutional Components

#### FirstXPCelebration
**Purpose:** Celebrate first XP award (single-use, server-tracked)

**Visual:**
- XP number with scale animation
- Progress bar fill
- "First Task Complete!" message
- Badge unlock (if earned)
- Total duration: 2000ms max

**Constraints:**
- No confetti, sound, or shake/vibrate
- Server-tracked via `xp_first_celebration_shown_at`
- Reduced motion: All instant

#### LockedGamificationUI
**Purpose:** Show gamification before first RELEASED escrow

**Visual:**
- Static XP display ("0 XP", grayed)
- Level indicator ("Level 1 • Locked")
- Streak counter ("Inactive")
- Badge silhouettes (locked/greyed)
- Empty progress bar
- "Unlocks after first task" label

**Constraints:**
- No animations
- No celebrations
- No unlocked visuals

#### MoneyTimeline
**Purpose:** Financial legibility (UI_SPEC §14)

**Sections:**
- **AVAILABLE NOW:** Withdrawable (green)
- **TODAY:** Recent releases (green)
- **COMING SOON:** Earned not released (amber)
- **BLOCKED:** Frozen in dispute (red)

**Constraints:**
- No charts, graphs, gambling visuals
- No vague language ("Pending", "Processing")
- No over-optimism ("Potential earnings")

#### FailureRecovery
**Purpose:** Graceful failure UX (UI_SPEC §15)

**Required Elements:**
- WHAT HAPPENED (clear explanation)
- IMPACT (concrete consequences)
- WHAT YOU CAN DO (specific actions)
- Recovery path (hope/next steps)

**Forbidden Copy:**
- Shame language ("You failed", "Your fault")
- Punitive language ("Penalty", "Punished")
- Vague impact ("Consequences", "Action taken")
- Passive aggressive ("Unfortunately", "Regrettably")

#### LiveModeUI
**Purpose:** Live Mode visual components (UI_SPEC §13)

**Components:**
- `LiveTaskCard` - Live task display
- `LiveModeToggle` - Hustler toggle
- `PosterLiveConfirmation` - Poster confirmation

**Constraints:**
- Red "🔴 LIVE" badge (top-left)
- Escrow state always visible
- Distance always visible
- Clear price breakdown
- No countdown timers
- No urgency copy
- No pulsing animations

---

## User Flows

### 4.1 Onboarding Flow (ONBOARDING_SPEC)

```
┌─────────────────────────────────────────────────────────┐
│  ONBOARDING FLOW                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. FramingScreen (Phase 0)                            │
│     → "HustleXP supports two ways..."                  │
│     → [ Continue ]                                      │
│                                                         │
│  2. CalibrationScreen (Phase 1)                        │
│     → 5 calibration questions                           │
│     → Binary/ternary choices                           │
│     → No explanations, no emojis                        │
│                                                         │
│  3. RoleConfirmationScreen (Phase 3)                    │
│     → System decision displayed                         │
│     → Certainty tier affects copy                       │
│     → [ Continue ] or [ Adjust role ]                  │
│                                                         │
│  4. PreferenceLockScreen (Phase 4)                      │
│     → Role-specific preferences                         │
│     → Lock preferences                                  │
│                                                         │
│  → Main App                                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Onboarding Rules:**
- ❌ Zero rewards during onboarding (ONB-2)
- ❌ Posters never see gamification (ONB-3)
- ❌ Hustlers see locked gamification until first RELEASED (ONB-4)
- ✅ First XP celebration is single-use, server-tracked (ONB-5)

---

### 4.2 Home Screen Flow

**For Posters:**
```
HomeScreen (Poster)
├── No gamification (ONB-3)
├── Active tasks list
├── Pending reviews
├── Completed tasks
└── Payment history
```

**For Workers (Pre-Unlock):**
```
HomeScreen (Worker, before first RELEASED)
├── LockedGamificationUI
│   ├── Static XP ("0 XP", grayed)
│   ├── Level indicator ("Level 1 • Locked")
│   ├── Streak ("Inactive")
│   ├── Badge silhouettes
│   └── "Unlocks after first task"
└── Quick stats
```

**For Workers (Post-Unlock):**
```
HomeScreen (Worker, after first RELEASED)
├── Active gamification
│   ├── XP display (XP colors allowed)
│   ├── Level progress bar
│   ├── Streak counter
│   └── Badges
└── Quick stats
```

---

### 4.3 Task Lifecycle Flow

```
Task Feed (Neutral Territory)
├── No XP colors
├── No success colors
├── Price in neutral gray
└── No urgency indicators

Task Detail
├── Money colors allowed (escrow state)
├── No celebrations (unless just completed)
└── Disputes visible (if applicable)

Task Completion
├── Server confirms COMPLETED state
├── Escrow transitions to RELEASED
├── XP awarded (if first: FirstXPCelebration)
└── MoneyTimeline updates
```

---

### 4.4 Money Timeline Flow

```
WalletScreen
├── MoneyTimeline component
│   ├── AVAILABLE NOW
│   │   └── $127.50 (withdrawable)
│   ├── TODAY
│   │   ├── + $21.25 (Couch move — Released 2:34 PM)
│   │   └── + $15.00 (Grocery pickup — Released 11:20 AM)
│   ├── COMING SOON
│   │   ├── + $40.00 (Deep cleaning — In escrow)
│   │   └── + $25.00 (Package delivery — In escrow)
│   └── BLOCKED
│       └── ⚠️ $15.00 (Furniture assembly — Under review)
└── Transfer to Bank button
```

---

## State Management

### 5.1 State Machines (PRODUCT_SPEC)

**TaskStateMachine:**
```javascript
States: OPEN → ACCEPTED → PROOF_SUBMITTED → COMPLETED
        ↓         ↓              ↓
      CANCELLED  EXPIRED      DISPUTED

Terminal States: COMPLETED, CANCELLED, EXPIRED
```

**EscrowStateMachine:**
```javascript
States: PENDING → FUNDED → RELEASED
                    ↓
              LOCKED_DISPUTE → REFUNDED / REFUND_PARTIAL

Terminal States: RELEASED, REFUNDED, REFUND_PARTIAL
```

**ProofStateMachine:**
```javascript
States: PENDING → SUBMITTED → ACCEPTED / REJECTED / EXPIRED
```

**OnboardingStateMachine:**
```javascript
States: FRAMING → CALIBRATION → ROLE_CONFIRMATION → PREFERENCE_LOCK → COMPLETE
```

---

### 5.2 Server-Authoritative State

**Rule:** UI only displays server-confirmed state (UI_SPEC §9.1)

```javascript
// ❌ FORBIDDEN: Optimistic update
setTaskState('COMPLETED');
await api.task.complete(taskId);

// ✅ CORRECT: Wait for server confirmation
const result = await api.task.complete(taskId);
setTaskState(result.state); // Server-confirmed
```

**State Confirmation Flow:**
1. User action → Show loading state
2. API request → Disable interactions
3. Server response → Update UI with confirmed state
4. Error handling → Clear optimistic state, show error

---

## API Integration

### 6.1 API Client Structure

```javascript
import apiClient from './utils/apiClient';

// Animation tracking
const shouldShow = await apiClient.shouldShowFirstXPCelebration(userId);
await apiClient.markFirstXPCelebrationShown(userId);

// State confirmation
const taskState = await apiClient.getTaskState(taskId);
const escrowState = await apiClient.getEscrowState(escrowId);

// Violation reporting (automatic via guards)
await apiClient.reportViolation({ type, rule, component, context });

// Onboarding status
const status = await apiClient.getUserOnboardingStatus(userId);
```

---

### 6.2 Error Handling

**Network Errors:**
- Show error message
- Provide retry action
- Preserve valid input

**Server Errors:**
- Display specific error message
- Clear optimistic state
- Log violation if optimistic state was shown

**Timeout Handling:**
- Show timeout UI after 10s
- Provide manual refresh
- Disable actions requiring fresh state

---

## Enforcement & Compliance

### 7.1 Runtime Guards

**Animation Guards:**
- `AnimationDurationGuard` - Enforces max durations
- `ReducedMotionGuard` - Respects prefers-reduced-motion
- `FirstTimeAnimationGuard` - Tracks server-tracked animations
- `AnimationContextGuard` - Blocks inappropriate animations
- `ForbiddenAnimationGuard` - Blocks forbidden patterns

**Color Guards:**
- `ColorContextGuard` - Validates color usage context

**State Guards:**
- `StateConfirmationGuard` - Ensures server-confirmed state
- `ScreenContextGuard` - Enforces screen-specific rules

**Violation Tracking:**
- `ViolationTracker` - Logs and reports violations

---

### 7.2 ESLint Rules (Planned)

**Color Rules:**
- `no-xp-color-outside-context`
- `no-money-color-decorative`
- `no-success-without-confirmation`

**Animation Rules:**
- `no-forbidden-animation`
- `max-animation-duration`
- `no-animated-gamification-pre-unlock`

**Copy Rules:**
- `no-shame-copy`
- `no-false-urgency`
- `no-urgency-copy-live-mode`

**Onboarding Rules:**
- `no-gamification-for-poster`
- `no-animated-gamification-pre-unlock`

---

### 7.3 Build-Time Checks

**Contrast Audit:**
- All text must meet WCAG 2.1 AA (4.5:1 ratio)
- UI elements must meet 3:1 ratio

**Touch Target Audit:**
- All interactive elements must be ≥44×44 points

**Copy Audit:**
- Forbidden patterns detected
- Required elements present

**Animation Audit:**
- Duration limits enforced
- Forbidden patterns blocked

---

## Screen-Specific Rules

### 8.1 Screen Context Matrix (UI_SPEC §6.1)

| Screen | XP Colors | Money Colors | Celebrations | Disputes Visible |
|--------|-----------|--------------|--------------|------------------|
| Home/Dashboard | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| Task Feed | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |
| Task Detail | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ⚠️ If applicable |
| Wallet | ❌ Forbidden | ✅ Required | ❌ Forbidden | ❌ Hidden |
| Profile | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| Dispute | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ✅ Required |
| Onboarding | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |

---

### 8.2 Onboarding Screen Rules

**During Onboarding:**
- ❌ No XP colors (user hasn't earned anything)
- ❌ No money colors (no transactions yet)
- ❌ No celebrations (nothing to celebrate)
- ❌ No badges (none unlocked)
- ✅ Minimal animation (professional tone)

**Rationale:** Onboarding sets expectations. Premature rewards teach users to expect unearned dopamine.

---

### 8.3 Dispute Screen Rules

**During Active Disputes:**
- ❌ No celebrations (inappropriate context)
- ❌ No XP displays (outcome uncertain)
- ✅ Neutral color palette
- ✅ Clear, factual copy only
- ✅ Evidence displayed without editorializing

---

## Accessibility Requirements

### 9.1 Non-Negotiable Standards

| Requirement | Standard | Enforcement |
|-------------|----------|-------------|
| Color contrast | WCAG 2.1 AA (4.5:1 text, 3:1 UI) | Automated testing |
| Touch targets | Minimum 44×44 points | Component constraint |
| Focus indicators | Visible on all interactive elements | Runtime check |
| Screen reader | All content accessible | Manual audit |
| Reduced motion | Respected system-wide | Runtime guard |

---

### 9.2 Color Independence

**Information must never be conveyed by color alone.**

**Bad:**
```
● Green = Success
● Red = Error
(No other indicator)
```

**Good:**
```
✓ Success (green)
✗ Error (red)
(Icon + color)
```

---

## Component Patterns

### 10.1 Loading States

**When awaiting server response:**
- Show loading indicator (spinner, skeleton)
- Disable interactive elements
- Never show "assumed" state

**Minimum loading time:** 100ms (prevent flash)  
**Maximum before timeout UI:** 10s

---

### 10.2 Empty States

**Empty states must:**
- Acknowledge the empty state clearly
- Provide next action (if applicable)
- Not shame or guilt

**Bad:**
```
"Looks lonely here... 😢 Why not post a task?"
```

**Good:**
```
"No tasks yet. [Post a Task]"
```

---

### 10.3 Error States

**When server returns error:**
- Display error immediately
- Clear any optimistic state
- Provide retry action (if applicable)
- Log violation if optimistic state was shown

---

## Live Mode UI

### 11.1 Live Task Card

```
┌─────────────────────────────────────────────────────────┐
│  🔴 LIVE                    ← Red badge, top-left       │
├─────────────────────────────────────────────────────────┤
│  Task title                                             │
│  Poster name • VERIFIED                                 │
│                                                         │
│  💰 $35.00 (you receive ~$29.75)  ← Clear breakdown    │
│  📍 1.2 miles away                ← Distance visible   │
│  ✅ Escrow: FUNDED               ← Trust signal        │
│                                                         │
│  [ Accept Task ]                                        │
└─────────────────────────────────────────────────────────┘
```

**Required:**
- Red "🔴 LIVE" badge
- Escrow state always visible
- Distance always visible
- Clear price breakdown

**Forbidden:**
- Countdown timers
- Urgency copy ("Act now!", "Hurry!")
- Pulsing/flashing animations
- Custom sound effects

---

### 11.2 Hustler Live Mode Toggle

```
┌─────────────────────────────────────────────────────────┐
│  LIVE MODE                                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [ ● ACTIVE ]   ← Green when active                    │
│                                                         │
│  🟢 Actively available                                  │
│  Session: 47 min • Tasks: 2 • Earned: $52              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Required:**
- Toggle visible on home screen or persistent header
- Session stats visible when active
- Cooldown countdown visible when in cooldown
- State change requires confirmation tap

---

## Money Timeline

### 12.1 Financial Legibility (UI_SPEC §14)

**Purpose:** Transform HustleXP from a gig app into a financial planning tool.

**Answers:**
- What money do I have **now**?
- What money is **coming**?
- What money is **blocked**?

**Categories:**
- **AVAILABLE NOW:** Withdrawable (green)
- **TODAY:** Recent releases (green)
- **COMING SOON:** Earned not released (amber)
- **BLOCKED:** Frozen in dispute (red)

**Forbidden:**
- Charts, graphs, gambling visuals
- Vague language ("Pending", "Processing")
- Over-optimism ("Potential earnings", "Could earn")

---

## Failure Recovery

### 13.1 Core Principle (UI_SPEC §15)

**Every negative outcome has:**
1. Clear explanation of what happened
2. Concrete impact (if any)
3. Specific next step
4. **No shame language**

**Required Elements:**
- WHAT HAPPENED (always explain)
- IMPACT (always specify)
- WHAT YOU CAN DO (always provide action)
- Recovery path (always show hope)

---

## Technical Stack

### 14.1 Core Technologies

- **Framework:** Native SwiftUI (iOS 17+)
- **Navigation:** NavigationStack + TabView (SwiftUI native)
- **State Management:** @Observable / @StateObject / @EnvironmentObject
- **API Client:** TRPCClient (custom async/await tRPC caller)
- **Styling:** Custom Design System (ColorTokens, TypographyTokens, AdaptiveLayout)
- **Testing:** XCTest + Swift Testing
- **Note:** Originally spec'd as React Native/Expo but implemented as native SwiftUI

---

### 14.2 Project Structure (Actual SwiftUI Implementation)

```
hustleXP final1/
├── hustleXP_final1App.swift      # App entry point
├── ContentView.swift              # Root navigation
│
├── DesignSystem/                  # Design tokens & components
│   ├── ColorTokens.swift          # Brand colors (#5B2DFF primary)
│   ├── TypographyTokens.swift     # Typography scale
│   ├── AdaptiveLayout.swift       # Responsive layout
│   └── Atoms/                     # 8 atomic components
│
├── Components/                    # 31 molecule components
│   ├── HXButton.swift
│   ├── HXCard.swift
│   ├── HXTextField.swift
│   └── ... (31 total)
│
├── Screens/                       # 39+ screens
│   ├── Onboarding/               # Auth & role selection
│   ├── Poster/                   # Task posting flow
│   ├── Hustler/                  # Task discovery & proof
│   ├── Shared/                   # Profile, wallet, settings
│   └── Navigation/               # Tab & navigation structure
│
├── Services/                      # tRPC API services
│   ├── TRPCClient.swift          # Generic tRPC caller
│   ├── AuthService.swift         # Firebase Auth
│   ├── TaskService.swift         # Task CRUD & discovery
│   ├── EscrowService.swift       # Payments & escrow
│   ├── MessagingService.swift    # In-app messaging & ratings
│   ├── ProofService.swift        # Photo upload & proof
│   ├── SkillService.swift        # Worker skills & licenses
│   └── TaxService.swift          # XP tax & insurance
│
├── Models/                        # 11 model files
│   ├── Task.swift
│   ├── Message.swift
│   ├── UserProfile.swift
│   └── ... (11 total)
│
└── Utils/                         # Utilities
    └── MockDataService.swift      # Dev mock data
```

---

## Development Workflow

### 15.1 Local Development

```bash
# Open in Xcode
open "hustleXP final1.xcodeproj"

# Build and run (Cmd+R in Xcode)
# Target: iOS 17+ Simulator or Device

# Launch Android emulator
npm run android

# Run tests
npm test
```

---

### 15.2 Code Quality

**Before Committing:**
- ✅ ESLint passes (no violations)
- ✅ Runtime guards active
- ✅ Color usage validated
- ✅ Animation durations checked
- ✅ Accessibility standards met

**Build Checks:**
- ✅ Contrast audit passes
- ✅ Touch target audit passes
- ✅ Copy audit passes
- ✅ Animation audit passes

---

## Summary

The HustleXP frontend is:

1. **Constitutional** - Every element aligns with UI_SPEC, ONBOARDING_SPEC, PRODUCT_SPEC
2. **Server-Authoritative** - UI only displays confirmed state
3. **Accessible** - WCAG 2.1 AA compliant, reduced motion support
4. **Enforced** - Runtime guards and ESLint rules prevent violations
5. **Role-Aware** - Different experiences for workers vs posters
6. **Gamification-Timed** - Gamification unlocks only after first RELEASED escrow
7. **Financially-Legible** - Money Timeline provides clear financial visibility
8. **Failure-Graceful** - Failure recovery provides explanation, impact, and next steps

**The frontend is a faithful representation of the constitutional specifications, not a creative interpretation.**

---

**END OF FRONTEND ARCHITECTURE DOCUMENT**
