# HustleXP iOS App — Current UI Plan Summary

> **Status**: Constitutional Authority (UI_SPEC.md v1.3.0)  
> **Last Updated**: January 2025  
> **Purpose**: Complete overview of UI/UX design system, screens, and components

---

## 🎯 Executive Summary

**UI Philosophy:**
> **The UI has zero decision authority. It expresses decisions made elsewhere.**

The UI plan follows a **constitutional architecture** where:
- Colors have semantic meaning (not decorative)
- Animations acknowledge confirmed state (never imply unconfirmed)
- Copy avoids shame language
- Screen contexts determine what's allowed/forbidden

---

## 📱 App Structure

### Navigation Architecture

**Bottom Tab Navigator (4 Tabs):**
1. **Home** (Dashboard) — Role-specific dashboard
2. **Tasks** (Task Feed) — Browse/accept tasks
3. **Profile** — XP, badges, trust tier, ratings
4. **Wallet** — Earnings, Money Timeline, transfers

**Additional Navigation:**
- **Onboarding Flow** — Modal stack (4 screens)
- **Auth Flow** — Login/Signup screens
- **Task Detail** — Modal/Stack navigation
- **Chat/Messaging** — Modal (task-scoped)
- **Settings** — Stack navigation

---

## 🎨 Visual Design System

### Color Authority (UI_SPEC §2)

**Colors have legal meaning. They are not decorative.**

#### XP Colors (Emerald Palette)
```
XP_PRIMARY:    #10B981 (Emerald 500)  → XP displays, level indicators
XP_SECONDARY:  #34D399 (Emerald 400)  → Progress bars, streak counters
XP_BACKGROUND: #D1FAE5 (Emerald 100)  → XP backgrounds
XP_ACCENT:     #059669 (Emerald 600)  → Level-up celebrations
```

**Allowed:** XP displays, level badges, streak indicators, progression bars  
**Forbidden:** Task cards (before completion), escrow states, navigation, generic buttons

#### Money Colors
```
MONEY_POSITIVE: #10B981 (Green)  → Incoming payments
MONEY_NEGATIVE: #EF4444 (Red)     → Outgoing payments
MONEY_NEUTRAL:  #6B7280 (Gray)    → Pending states
MONEY_LOCKED:   #F59E0B (Amber)   → Disputed escrows
```

**Allowed:** Escrow state indicators, payment amounts, wallet balances, transaction history  
**Forbidden:** XP displays, task descriptions, decorative elements

#### Status Colors
```
SUCCESS: #10B981 (Confirmation, completion)
WARNING: #F59E0B (Attention needed, caution)
ERROR:   #EF4444 (Failure, rejection, danger)
INFO:    #3B82F6 (Neutral information)
```

---

### Animation Constraints (UI_SPEC §3)

**Forbidden:**
- ❌ Confetti (casino psychology)
- ❌ Infinite loops (attention hijacking)
- ❌ Randomized motion (untrustworthy)
- ❌ Shake/vibrate (anxiety-inducing)
- ❌ Slot machine reveals (gambling association)
- ❌ Countdown urgency (false scarcity)

**Allowed:**
- ✅ State transition animations (300ms max)
- ✅ Progress bar fills (acknowledging confirmed progress)
- ✅ First XP celebration (single-use, server-tracked)
- ✅ Badge unlock (once per badge, server-tracked)

**Duration Limits:**
- Micro-interactions: 150ms max
- State transitions: 300ms max
- Celebrations: 2000ms max (first XP only)

---

## 📺 Screen Inventory

### 1. Authentication Screens

| Screen | Purpose | Status |
|--------|---------|--------|
| **LoginScreen** | Email/password login | ✅ Scaffold exists |
| **SignupScreen** | Account creation | ✅ Scaffold exists |
| **ForgotPasswordScreen** | Password reset | ✅ Scaffold exists |

**Design Rules:**
- No gamification
- No XP colors
- No money colors
- Minimal animation

---

### 2. Onboarding Screens (ONBOARDING_SPEC)

| Screen | Purpose | Status |
|--------|---------|--------|
| **FramingScreen** | "HustleXP supports two ways..." | ✅ Scaffold exists |
| **CalibrationScreen** | 5 calibration questions | ✅ Scaffold exists |
| **RoleConfirmationScreen** | System role decision | ✅ Scaffold exists |
| **PreferenceLockScreen** | Role-specific preferences | ✅ Scaffold exists |

**Critical Rules:**
- ❌ **Zero rewards during onboarding** (ONB-2)
- ❌ **No gamification** (ONB-3)
- ❌ **No XP colors** (user hasn't earned anything)
- ❌ **No celebrations** (nothing to celebrate)
- ✅ **First XP celebration is single-use, server-tracked** (ONB-5)

**Flow:**
```
Framing → Calibration → Role Confirmation → Preference Lock → Main App
```

---

### 3. Main App Screens

#### HomeScreen (Dashboard)

**For Posters:**
- Active tasks list
- Pending reviews
- Completed tasks
- Payment history
- ❌ **No gamification** (ONB-3)

**For Workers (Pre-Unlock):**
- **LockedGamificationUI** component
  - Static XP ("0 XP", grayed)
  - Level indicator ("Level 1 • Locked")
  - Streak ("Inactive")
  - Badge silhouettes (locked/greyed)
  - "Unlocks after first task" label
- Quick stats

**For Workers (Post-Unlock):**
- Active gamification
  - XP display (XP colors allowed)
  - Level progress bar
  - Streak counter
  - Badges
- Quick stats
- Recent tasks

**Status:** ✅ Scaffold exists

---

#### TasksScreen (Task Feed)

**Purpose:** Browse and discover tasks

**Design Rules:**
- ❌ **No XP colors** (tasks aren't XP)
- ❌ **No success colors** (nothing succeeded yet)
- ❌ **No celebrations** (neutral territory)
- ❌ **No urgency indicators** (no manipulation)
- ✅ Price displayed in neutral gray
- ✅ Task cards with: title, description, price, distance, deadline, poster trust tier
- ✅ Filter/sort options (category, price, distance, time, trust tier)
- ✅ Search bar (full-text search)
- ✅ "Why this task?" explanations (AI-generated, A1 authority)

**Features (New - GAP A):**
- Matching score display (0.0-1.0)
- Relevance ranking (not just chronological)
- Filter by: category, price range, distance, time window, trust tier, mode (STANDARD/LIVE), escrow status
- Sort by: relevance (default), distance, price (high/low), deadline, trust tier, recently posted
- Search: full-text on title, description, location, category

**Status:** ✅ Scaffold exists, needs GAP A features

---

#### TaskDetailScreen

**Purpose:** View task details, accept task, submit proof

**Design Rules:**
- ✅ **Money colors allowed** (escrow state)
- ❌ **No celebrations** (unless just completed)
- ⚠️ **Disputes visible** (if applicable)
- ❌ **No XP colors** (task detail, not XP context)

**Content:**
- Task title, description, photos
- Poster info (name, trust tier, rating)
- Price breakdown (task price, platform fee, worker receives)
- Escrow status (PENDING, FUNDED, RELEASED)
- Location (map view)
- Deadline
- Proof requirements
- Action buttons (Accept, Submit Proof, Approve/Reject Proof)

**Features (New - GAP B):**
- **Task-scoped messaging** (chat thread)
- Auto-messages ("On my way", "Running late", "Completed")
- Photo sharing in chat
- Location sharing (optional, one-time)

**Status:** ✅ Scaffold exists, needs GAP B features

---

#### ProfileScreen

**Purpose:** View XP, badges, trust tier, ratings, stats

**Design Rules:**
- ✅ **XP colors allowed** (XP displays)
- ✅ **Money colors allowed** (earnings history)
- ✅ **Celebrations allowed** (badge unlocks, level ups)
- ❌ **Disputes hidden** (not appropriate context)

**Content:**
- User avatar, name, trust tier
- XP total, current level, level progress bar
- Current streak
- Badges (unlocked + locked silhouettes)
- Rating summary (average rating, total ratings, recent feedback)
- Task history (completed tasks count)
- Earnings history (optional, if worker)

**Features (New - GAP E):**
- **Bidirectional rating display**
  - Average rating (1-5 stars)
  - Total ratings count
  - Star distribution (5-star, 4-star, etc.)
  - Recent feedback (last 10 public ratings with comments and tags)

**Status:** ✅ Scaffold exists, needs GAP E features

---

#### WalletScreen

**Purpose:** View earnings, Money Timeline, transfer to bank

**Design Rules:**
- ✅ **Money colors required** (financial state)
- ❌ **No XP colors** (wallet, not XP context)
- ❌ **No celebrations** (financial context)

**Content:**
- **MoneyTimeline Component** (UI_SPEC §14)
  - **AVAILABLE NOW:** Withdrawable balance (green)
  - **TODAY:** Recent releases (green, with timestamps)
  - **COMING SOON:** Earned not released (amber, with task names)
  - **BLOCKED:** Frozen in dispute (red, with reason)
- Transfer to Bank button
- Transaction history

**Money Timeline Rules:**
- ❌ **No charts, graphs, gambling visuals**
- ❌ **No vague language** ("Pending", "Processing")
- ❌ **No over-optimism** ("Potential earnings")
- ✅ **Time + certainty only**

**Status:** ✅ Scaffold exists, MoneyTimeline component created

---

### 4. New Screens (Critical Gaps)

#### ChatScreen (GAP B - Messaging)

**Purpose:** Task-scoped messaging between poster and worker

**Design Rules:**
- Only accessible during task lifecycle (ACCEPTED, PROOF_SUBMITTED, DISPUTED)
- Read-only archive after task COMPLETED/CANCELLED
- No general DMs (task-scoped only)

**Content:**
- Message thread (chronological)
- Quick actions: "On my way", "Running late", "Completed", "Need clarification"
- Photo sharing (max 3 per message)
- Location sharing (optional, one-time)
- Read receipts (optional, user preference)

**Status:** ❌ Not implemented (GAP B)

---

#### NotificationScreen (GAP D - Notifications)

**Purpose:** View all notifications

**Design Rules:**
- Grouped notifications (similar notifications within 5 minutes)
- Unread indicators
- Deep linking to relevant screens

**Content:**
- Notification list (grouped)
- Filter by category (task, message, trust, payment, system)
- Mark as read / Mark all as read
- Notification preferences link

**Status:** ❌ Not implemented (GAP D)

---

#### NotificationPreferencesScreen (GAP D)

**Purpose:** Configure notification preferences

**Content:**
- Per-category toggles (enable/disable)
- Sound preferences (on/off per category)
- Badge preferences (on/off per category)
- Quiet hours (start time, end time)
- Quiet hours override (per category)
- Channel preferences (push, email, SMS)

**Status:** ❌ Not implemented (GAP D)

---

#### RatingScreen (GAP E - Ratings)

**Purpose:** Submit rating after task completion

**Design Rules:**
- Only accessible after task COMPLETED
- 7-day window (auto-rating after 7 days)
- Blind ratings (hidden until both parties rate)

**Content:**
- Star rating (1-5, required)
- Comment (optional, max 500 chars)
- Tags (optional, multi-select)
  - Worker rates poster: "Clear Instructions", "Fair Payment", "Responsive", etc.
  - Poster rates worker: "On Time", "Professional", "High Quality", etc.
- Submit button

**Status:** ❌ Not implemented (GAP E)

---

#### SearchScreen (GAP A - Task Discovery)

**Purpose:** Search and filter tasks

**Content:**
- Search bar (full-text search)
- Filter panel:
  - Category (multi-select)
  - Price range (min/max)
  - Distance (max miles: 1, 3, 5, 10, 20, 50)
  - Time window (hours until deadline: 1h, 3h, 6h, 12h, 24h, 48h+)
  - Trust tier (multi-select: ROOKIE, VERIFIED, TRUSTED, ELITE)
  - Mode (STANDARD, LIVE, All)
  - Escrow status (PENDING, FUNDED)
- Sort options:
  - Relevance (default)
  - Distance
  - Price (high/low)
  - Deadline (soon/later)
  - Trust tier
  - Recently posted
- Results list (with matching scores)

**Status:** ❌ Not implemented (GAP A)

---

## 🧩 Component Library

### Core Components

| Component | Purpose | Status |
|-----------|---------|--------|
| **Button** | Standard button (44×44 min) | ✅ Scaffold exists |
| **Card** | Task cards, info cards | ✅ Scaffold exists |
| **Text** | Typography (h1, h2, body, caption) | ✅ Scaffold exists |
| **Input** | Form inputs with validation | ✅ Scaffold exists |

### Constitutional Components

| Component | Purpose | Status |
|-----------|---------|--------|
| **FirstXPCelebration** | First XP celebration (single-use) | ✅ Created |
| **LockedGamificationUI** | Pre-unlock gamification display | ✅ Created |
| **MoneyTimeline** | Financial legibility (GAP-1) | ✅ Created |
| **FailureRecovery** | Graceful failure UX (GAP-2) | ✅ Created |
| **LiveModeUI** | Live Mode visual components | ✅ Created |

### New Components Needed (Critical Gaps)

| Component | Purpose | Status |
|-----------|---------|--------|
| **TaskCard** | Task feed card with matching score | ❌ GAP A |
| **TaskExplanation** | "Why this task?" AI explanation | ❌ GAP A |
| **FilterPanel** | Task discovery filters | ❌ GAP A |
| **SearchBar** | Full-text search input | ❌ GAP A |
| **ChatThread** | Task-scoped messaging | ❌ GAP B |
| **AutoMessageButtons** | Quick action buttons | ❌ GAP B |
| **NotificationList** | Notification feed | ❌ GAP D |
| **RatingModal** | Rating submission | ❌ GAP E |
| **RatingDisplay** | Profile rating display | ❌ GAP E |

---

## 🎯 Screen Context Rules

### Screen Context Matrix (UI_SPEC §6.1)

| Screen | XP Colors | Money Colors | Celebrations | Disputes Visible |
|--------|-----------|--------------|--------------|------------------|
| **Home/Dashboard** | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| **Task Feed** | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |
| **Task Detail** | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ⚠️ If applicable |
| **Wallet** | ❌ Forbidden | ✅ Required | ❌ Forbidden | ❌ Hidden |
| **Profile** | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| **Dispute** | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ✅ Required |
| **Onboarding** | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |
| **Chat** | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ⚠️ If dispute context |
| **Notifications** | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ❌ Hidden |
| **Search** | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |

---

## 🎨 Design Tokens

### Colors (constants/colors.js)

**XP Colors:**
- `XP_PRIMARY: #10B981`
- `XP_SECONDARY: #34D399`
- `XP_BACKGROUND: #D1FAE5`
- `XP_ACCENT: #059669`

**Money Colors:**
- `MONEY_POSITIVE: #10B981`
- `MONEY_NEGATIVE: #EF4444`
- `MONEY_NEUTRAL: #6B7280`
- `MONEY_LOCKED: #F59E0B`

**Status Colors:**
- `SUCCESS: #10B981`
- `WARNING: #F59E0B`
- `ERROR: #EF4444`
- `INFO: #3B82F6`

**Neutral Colors:**
- `GRAY[50-900]` — Gray scale
- `WHITE: #FFFFFF`
- `BLACK: #000000`

### Typography (constants/typography.js)

**Font Sizes:**
- `h1: 32px` — Main headings
- `h2: 24px` — Section headings
- `h3: 20px` — Subsection headings
- `body: 16px` — Body text
- `bodySmall: 14px` — Secondary text
- `caption: 12px` — Captions, labels
- `label: 14px` — Form labels

**Font Weights:**
- `regular: 400`
- `semibold: 600`
- `bold: 700`

### Spacing (constants/spacing.js)

**Touch Targets:**
- `TOUCH.MIN: 44` — Minimum touch target (WCAG A4)

**Spacing Scale:**
- `4, 8, 12, 16, 20, 24, 32, 40, 48, 64` — Consistent spacing

### Animations (constants/animations.js)

**Durations:**
- `MICRO: 150ms` — Micro-interactions
- `TRANSITION: 300ms` — State transitions
- `CELEBRATION: 2000ms` — First XP celebration (max)

**Easing:**
- `EASE_OUT: cubic-bezier(0.0, 0, 0.2, 1)` — Standard easing
- `EASE_IN: cubic-bezier(0.4, 0, 1, 1)` — Entrance animations

---

## 🚫 Forbidden Patterns

### Copy Forbidden Patterns (UI_SPEC §5)

**Shame Language:**
- "You failed"
- "Your fault"
- "Mistake"
- "You're behind"

**Punitive Language:**
- "Penalty"
- "Punished"
- "Strike"
- "Warning"
- "Demotion"
- "Banned"

**False Urgency:**
- "Act now!"
- "Hurry!"
- "Limited time!"
- "Only X left!"

**Vague Impact:**
- "Consequences"
- "Action taken"
- "Noted"
- "We'll review"

**Passive Aggressive:**
- "Unfortunately"
- "Regrettably"
- "We had to"
- "Sorry, but"

### Visual Forbidden Patterns

**Gambling Psychology:**
- ❌ Confetti
- ❌ Slot machine reveals
- ❌ Randomized motion
- ❌ Countdown timers
- ❌ Pulsing/flashing animations

**Manipulation:**
- ❌ False urgency indicators
- ❌ Fake scarcity ("Only 3 left!")
- ❌ Dark patterns (hidden costs, forced actions)

---

## ✅ Accessibility Requirements

### WCAG 2.1 AA Compliance

| Requirement | Standard | Enforcement |
|-------------|----------|-------------|
| **Color Contrast** | 4.5:1 (text), 3:1 (UI) | Automated testing |
| **Touch Targets** | Minimum 44×44 points | Component constraint |
| **Focus Indicators** | Visible on all interactive elements | Runtime check |
| **Screen Reader** | All content accessible | Manual audit |
| **Reduced Motion** | Respected system-wide | Runtime guard |

### Color Independence

**Rule:** Information must never be conveyed by color alone.

**Bad:** Green = Success (no other indicator)  
**Good:** ✓ Success (green) — Icon + color

---

## 🔧 Enforcement Mechanisms

### ESLint Rules (UI_SPEC §8.1)

| Rule | Enforces | Error Level |
|------|----------|-------------|
| `no-xp-color-outside-context` | §2.2 | Error |
| `no-money-color-decorative` | §2.3 | Error |
| `no-success-without-confirmation` | §2.4 | Error |
| `no-forbidden-animation` | §3.2 | Error |
| `max-animation-duration` | §3.3 | Warning |
| `no-shame-copy` | §5.2 | Error |
| `no-false-urgency` | §5.2 | Error |
| `badge-tier-material-match` | §4.1 | Error |
| `touch-target-minimum` | §7.1 | Error |
| `color-contrast-minimum` | §7.1 | Warning |

### Runtime Guards (UI_SPEC §8.2)

| Guard | Enforces | Behavior on Violation |
|-------|----------|----------------------|
| `AnimationContextGuard` | No celebration during dispute | Block animation |
| `ReducedMotionGuard` | Respect reduced motion | Replace with static |
| `FirstTimeAnimationGuard` | First XP celebration single-use | Check server flag |
| `ColorContextGuard` | Color authority | Log warning |
| `StateConfirmationGuard` | No unconfirmed state | Block render until server confirms |

---

## 📊 Implementation Status

### Screens Status

| Screen | Status | Notes |
|--------|--------|-------|
| **LoginScreen** | ✅ Scaffold | Basic structure |
| **SignupScreen** | ✅ Scaffold | Basic structure |
| **ForgotPasswordScreen** | ✅ Scaffold | Basic structure |
| **FramingScreen** | ✅ Scaffold | Onboarding Phase 0 |
| **CalibrationScreen** | ✅ Scaffold | Onboarding Phase 1 |
| **RoleConfirmationScreen** | ✅ Scaffold | Onboarding Phase 3 |
| **PreferenceLockScreen** | ✅ Scaffold | Onboarding Phase 4 |
| **HomeScreen** | ✅ Scaffold | Needs role-specific logic |
| **TasksScreen** | ✅ Scaffold | Needs GAP A features |
| **TaskDetailScreen** | ✅ Scaffold | Needs GAP B features |
| **ProfileScreen** | ✅ Scaffold | Needs GAP E features |
| **WalletScreen** | ✅ Scaffold | MoneyTimeline component ready |
| **ChatScreen** | ❌ Not Started | GAP B |
| **NotificationScreen** | ❌ Not Started | GAP D |
| **NotificationPreferencesScreen** | ❌ Not Started | GAP D |
| **RatingScreen** | ❌ Not Started | GAP E |
| **SearchScreen** | ❌ Not Started | GAP A |

### Components Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Button** | ✅ Scaffold | Basic structure |
| **Card** | ✅ Scaffold | Basic structure |
| **Text** | ✅ Scaffold | Basic structure |
| **Input** | ✅ Scaffold | Basic structure |
| **FirstXPCelebration** | ✅ Created | First XP celebration |
| **LockedGamificationUI** | ✅ Created | Pre-unlock display |
| **MoneyTimeline** | ✅ Created | Financial legibility |
| **FailureRecovery** | ✅ Created | Graceful failures |
| **LiveModeUI** | ✅ Created | Live Mode components |
| **TaskCard** | ❌ Not Started | GAP A |
| **TaskExplanation** | ❌ Not Started | GAP A |
| **FilterPanel** | ❌ Not Started | GAP A |
| **SearchBar** | ❌ Not Started | GAP A |
| **ChatThread** | ❌ Not Started | GAP B |
| **AutoMessageButtons** | ❌ Not Started | GAP B |
| **NotificationList** | ❌ Not Started | GAP D |
| **RatingModal** | ❌ Not Started | GAP E |
| **RatingDisplay** | ❌ Not Started | GAP E |

---

## 🎯 Key UI Principles

### 1. Zero Decision Authority

**UI Rules:**
- ✅ UI may render state
- ✅ UI may request actions
- ❌ UI may **never** compute, decide, or assume
- ❌ UI may **never** display unconfirmed state

**Example:**
```javascript
// ❌ FORBIDDEN: Optimistic update
setTaskState('COMPLETED');
await api.task.complete(taskId);

// ✅ CORRECT: Wait for server confirmation
const result = await api.task.complete(taskId);
setTaskState(result.state); // Server-confirmed
```

---

### 2. Semantic Color Authority

**Colors have meaning:**
- XP colors = Earned value, progression
- Money colors = Financial state
- Status colors = System state
- Neutral colors = No semantic meaning

**Violation:** Using XP colors outside XP context implies unearned value.

---

### 3. Animation Constraints

**Animations may:**
- ✅ Acknowledge confirmed state changes
- ✅ Provide feedback for user actions
- ✅ Guide attention (subtle)

**Animations may never:**
- ❌ Imply state changes that haven't occurred
- ❌ Play without server-confirmed trigger
- ❌ Create false urgency
- ❌ Manipulate user decisions

---

### 4. No Shame Language

**Forbidden:**
- "You failed"
- "Your fault"
- "Penalty"
- "Punished"
- "Unfortunately"

**Required:**
- Clear explanation (WHAT HAPPENED)
- Specific impact (IMPACT)
- Concrete next steps (WHAT YOU CAN DO)
- Recovery path (hope)

---

### 5. Role-Specific UI

**Posters:**
- ❌ Never see gamification (ONB-3)
- ✅ See task management UI
- ✅ See payment history

**Workers (Pre-Unlock):**
- ✅ See locked gamification (LockedGamificationUI)
- ❌ No XP colors (haven't earned)
- ❌ No celebrations (nothing to celebrate)

**Workers (Post-Unlock):**
- ✅ See active gamification
- ✅ XP colors allowed
- ✅ Celebrations allowed (after confirmed state)

---

## 📋 Next Steps for Implementation

### Phase 1: Core Screens (Current)

1. ✅ **Onboarding Flow** — Complete (4 screens scaffolded)
2. ✅ **Home/Dashboard** — Scaffold exists, needs role-specific logic
3. ✅ **Task Feed** — Scaffold exists, needs GAP A features
4. ✅ **Task Detail** — Scaffold exists, needs GAP B features
5. ✅ **Profile** — Scaffold exists, needs GAP E features
6. ✅ **Wallet** — Scaffold exists, MoneyTimeline ready

### Phase 2: Critical Gap Features (Next)

1. **GAP A: Task Discovery** (HIGH priority)
   - TaskCard component with matching score
   - TaskExplanation component (AI-generated)
   - FilterPanel component
   - SearchScreen
   - SearchBar component

2. **GAP B: Messaging** (HIGH priority)
   - ChatScreen
   - ChatThread component
   - AutoMessageButtons component
   - Photo sharing in chat
   - Location sharing (optional)

3. **GAP D: Notifications** (HIGH priority)
   - NotificationScreen
   - NotificationList component
   - NotificationPreferencesScreen
   - Push notification integration (APNs)

4. **GAP E: Ratings** (MEDIUM priority)
   - RatingScreen (modal)
   - RatingModal component
   - RatingDisplay component (profile)
   - Rating history screen

### Phase 3: Additional Features (Post-Launch)

- Analytics dashboard (GAP J)
- Fraud detection UI (admin only, GAP K)
- Content moderation UI (admin only, GAP L)
- GDPR compliance UI (GAP M)

---

## 🏗️ Technical Stack

**Framework:** Swift / SwiftUI (native iOS)  
**Navigation:** NavigationStack + TabView  
**State Management:** @Observable + State Machines  
**API Integration:** tRPC client (custom Swift implementation)  
**Styling:** SwiftUI modifiers + ViewModifiers  
**Design Tokens:** Theme.swift (colors, typography, spacing, animations)  
**NOTE:** Originally spec'd as React Native/Expo but implemented as native SwiftUI. See `reference/` for legacy RN scaffold.

---

## 📚 Reference Documents

- **UI_SPEC.md v1.3.0** — Complete UI specification (constitutional authority)
- **FRONTEND_ARCHITECTURE.md** — Implementation architecture guide
- **ONBOARDING_SPEC.md v1.3.0** — Onboarding flow and gamification timing
- **PRODUCT_SPEC.md v1.4.0** — Product requirements (state machines, business logic)
- **ARCHITECTURE.md** — System architecture (authority hierarchy)

---

## ✅ Compliance Checklist

Before any UI implementation:

- [ ] Colors follow semantic authority (XP, Money, Status, Neutral)
- [ ] Animations acknowledge confirmed state only
- [ ] No shame language in copy
- [ ] No false urgency indicators
- [ ] Screen context rules followed (XP colors, money colors, celebrations)
- [ ] Touch targets minimum 44×44 points
- [ ] Color contrast WCAG 2.1 AA compliant
- [ ] Reduced motion respected
- [ ] Server-authoritative state (no optimistic updates)
- [ ] ESLint rules pass
- [ ] Runtime guards active

---

**Last Updated:** January 2025  
**Version:** 1.0.0  
**Status:** ✅ Complete UI Plan Summary
