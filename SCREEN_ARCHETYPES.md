# SCREEN ARCHETYPES — HUSTLEXP v1.0

**STATUS: FROZEN — All 38 screens are categorized**
**Authority: SCREEN_REGISTRY.md (screens-spec/SCREEN_REGISTRY.md) is the constitutional reference for screen codes and names.**
**Rule: Identify archetype BEFORE implementation. Inherit, don't invent.**

---

## PURPOSE

Screens are NOT unique design problems.
Screens are **instances of archetypes**.

This document:
1. Defines the 6 archetypes
2. Maps all 38 screens (per SCREEN_REGISTRY) to archetypes
3. Specifies what each archetype inherits

**Cursor must identify the archetype BEFORE building any screen.**

---

## THE 6 ARCHETYPES

### A. ENTRY / COMMITMENT

**Purpose:** User decides to engage with the system

**Emotional tone:**
- You are ALREADY welcome
- This is easy
- Success is expected

**Visual patterns:**
- Centered content
- Minimal form fields
- Single primary action
- Soft, inviting colors
- No intimidating walls of text

**Motion:**
- Gentle fade-in
- Subtle micro-interactions on focus
- Satisfying button press feedback

**Screens in this archetype:**
```
A1: Login
A2: Signup
A3: Forgot Password
O1: Framing
O3: Role Confirmation
```

**Anti-patterns (FORBIDDEN):**
- ❌ Long forms that feel like interrogation
- ❌ Neutral language ("enter your credentials")
- ❌ Empty states at first load
- ❌ Any UI that makes user feel they might fail

---

### B. FEED / OPPORTUNITY

**Purpose:** User discovers options and selects

**Emotional tone:**
- Abundance is implied
- Good things are waiting
- Selection is easy

**Visual patterns:**
- Scrollable card list
- Clear visual hierarchy per card
- Filters that feel like refinement, not limitation
- Pull-to-refresh
- Skeleton loading (not spinners)

**Motion:**
- Cards animate in with stagger
- Pull-to-refresh has satisfying bounce
- Filter changes animate smoothly

**Screens in this archetype:**
```
H2: Task Feed
H3: Task History
```

**Anti-patterns (FORBIDDEN):**
- ❌ Empty states that feel permanent
- ❌ "No results" without helpful guidance
- ❌ Filters that feel like rejection
- ❌ Loading states that feel like waiting

---

### C. TASK LIFECYCLE

**Purpose:** Active work in progress

**Emotional tone:**
- You are doing important work
- Progress is visible
- Completion is achievable

**Visual patterns:**
- Status prominently displayed
- Clear next action
- Timer/progress when relevant
- Action buttons at bottom (thumb zone)
- Conversation accessible but not dominant

**Motion:**
- Status changes animate
- Progress fills smoothly
- Success states celebrate briefly

**Screens in this archetype:**
```
H4: Task Detail
H5: Task In Progress
H6: Task Completion
H7: En Route Map
P2: Hustler On Way
P3: Task Completion (Poster)
SH1: Task Conversation
SH4: Dispute Entry
```

**Anti-patterns (FORBIDDEN):**
- ❌ Unclear what to do next
- ❌ Hidden or buried actions
- ❌ Status that requires interpretation
- ❌ Completion without acknowledgment

---

### D. CALIBRATION / CAPABILITY

**Purpose:** User configures their profile and capabilities

**Emotional tone:**
- This makes you more powerful
- Each step unlocks something
- You are building toward greatness

**Visual patterns:**
- Progress indicator (steps, percentage)
- One question/action per view when possible
- Clear benefit of each input
- Skip options when appropriate
- Completion celebration

**Motion:**
- Progress bar fills satisfyingly
- Step transitions slide naturally
- Completion has celebratory moment

**Screens in this archetype:**
```
O2: Calibration
O4: Preference Lock
O5: Capability Intro
O6: Location Setup
O7: Trade Verification
O8: Insurance Upload
O9: Background Check
O10: Vehicle Setup
O11: Availability
O12: Capability Summary
P1: Task Creation
P4: Feedback
S1: Profile
S3: Work Eligibility
```

**Anti-patterns (FORBIDDEN):**
- ❌ Forms that feel like bureaucracy
- ❌ Unclear why information is needed
- ❌ No visible progress
- ❌ Settings that feel like punishment

---

### E. PROGRESS / STATUS

**Purpose:** User sees their standing and growth

**Emotional tone:**
- You have accomplished things
- Growth is visible
- More is achievable

**Visual patterns:**
- Numbers prominently displayed
- Progress visualizations (bars, charts)
- Comparison to previous state
- Next milestone visible
- Achievement moments highlighted

**Motion:**
- Numbers count up
- Progress bars fill on load
- Achievements animate in

**Screens in this archetype:**
```
H1: Hustler Home
H8: XP Breakdown
S2: Wallet
SH2: Trust Tier Ladder
SH3: Trust Change Explanation
```

**Anti-patterns (FORBIDDEN):**
- ❌ Zero states that feel like failure
- ❌ Progress without context
- ❌ Growth that isn't celebrated
- ❌ Static, lifeless numbers

---

### F. SYSTEM / INTERRUPT

**Purpose:** System communicates critical information

**Emotional tone:**
- This is temporary
- Resolution is possible
- You are not at fault (usually)

**Visual patterns:**
- Centered content
- Clear icon/illustration
- Single message
- Single action (retry, update, etc.)
- No navigation away (intentional)

**Motion:**
- Subtle breathing/pulse on icon
- Button has clear tap feedback
- Transition out is satisfying

**Screens in this archetype:**
```
H9: Instant Interrupt
E1: No Tasks Available
E2: Eligibility Mismatch
E3: Trust Tier Locked
```

**Anti-patterns (FORBIDDEN):**
- ❌ Blame language
- ❌ Technical jargon
- ❌ No clear action
- ❌ Permanent-feeling messages

---

## ARCHETYPE INHERITANCE RULES

### When building a screen:

```
1. Identify which archetype this screen belongs to
2. Read the archetype specification above
3. Inherit:
   - Emotional tone
   - Visual patterns
   - Motion patterns
4. DO NOT:
   - Invent new patterns
   - Mix archetypes
   - Ignore the emotional tone
```

### If a screen feels like it belongs to multiple archetypes:

```
STOP.
Choose the PRIMARY purpose.
Build for that archetype.
If truly unclear, ASK.
```

---

## COMPLETE SCREEN-TO-ARCHETYPE MAP (38 SCREENS)

**Authority: SCREEN_REGISTRY.md — codes and names are canonical.**

| Code | Screen | File | Archetype |
|------|--------|------|-----------|
| A1 | Login | `LoginScreen.tsx` | A. Entry/Commitment |
| A2 | Signup | `SignupScreen.tsx` | A. Entry/Commitment |
| A3 | Forgot Password | `ForgotPasswordScreen.tsx` | A. Entry/Commitment |
| H1 | Hustler Home | `HustlerHomeScreen.tsx` | E. Progress/Status |
| H2 | Task Feed | `TaskFeedScreen.tsx` | B. Feed/Opportunity |
| H3 | Task History | `TaskHistoryScreen.tsx` | B. Feed/Opportunity |
| H4 | Task Detail | `TaskDetailScreen.tsx` | C. Task Lifecycle |
| H5 | Task In Progress | `TaskInProgressScreen.tsx` | C. Task Lifecycle |
| H6 | Task Completion | `TaskCompletionScreen.tsx` | C. Task Lifecycle |
| H7 | En Route Map | `HustlerEnRouteMapScreen.tsx` | C. Task Lifecycle |
| H8 | XP Breakdown | `XPBreakdownScreen.tsx` | E. Progress/Status |
| H9 | Instant Interrupt | `InstantInterruptCard.tsx` | F. System/Interrupt |
| P1 | Task Creation | `TaskCreationScreen.tsx` | D. Calibration/Capability |
| P2 | Hustler On Way | `HustlerOnWayScreen.tsx` | C. Task Lifecycle |
| P3 | Task Completion | `TaskCompletionScreen.tsx` | C. Task Lifecycle |
| P4 | Feedback | `FeedbackScreen.tsx` | D. Calibration/Capability |
| O1 | Framing | `FramingScreen.tsx` | A. Entry/Commitment |
| O2 | Calibration | `CalibrationScreen.tsx` | D. Calibration/Capability |
| O3 | Role Confirmation | `RoleConfirmationScreen.tsx` | A. Entry/Commitment |
| O4 | Preference Lock | `PreferenceLockScreen.tsx` | D. Calibration/Capability |
| O5 | Capability Intro | `CapabilityIntroScreen.tsx` | D. Calibration/Capability |
| O6 | Location Setup | `LocationSetupScreen.tsx` | D. Calibration/Capability |
| O7 | Trade Verification | `TradeVerificationScreen.tsx` | D. Calibration/Capability |
| O8 | Insurance Upload | `InsuranceUploadScreen.tsx` | D. Calibration/Capability |
| O9 | Background Check | `BackgroundCheckScreen.tsx` | D. Calibration/Capability |
| O10 | Vehicle Setup | `VehicleSetupScreen.tsx` | D. Calibration/Capability |
| O11 | Availability | `AvailabilityScreen.tsx` | D. Calibration/Capability |
| O12 | Capability Summary | `CapabilitySummaryScreen.tsx` | D. Calibration/Capability |
| S1 | Profile | `ProfileScreen.tsx` | D. Calibration/Capability |
| S2 | Wallet | `WalletScreen.tsx` | E. Progress/Status |
| S3 | Work Eligibility | `WorkEligibilityScreen.tsx` | D. Calibration/Capability |
| SH1 | Task Conversation | `TaskConversationScreen.tsx` | C. Task Lifecycle |
| SH2 | Trust Tier Ladder | `TrustTierLadderScreen.tsx` | E. Progress/Status |
| SH3 | Trust Change | `TrustChangeExplanationScreen.tsx` | E. Progress/Status |
| SH4 | Dispute Entry | `DisputeEntryScreen.tsx` | C. Task Lifecycle |
| E1 | No Tasks Available | `NoTasksAvailableScreen.tsx` | F. System/Interrupt |
| E2 | Eligibility Mismatch | `EligibilityMismatchScreen.tsx` | F. System/Interrupt |
| E3 | Trust Tier Locked | `TrustTierLockedScreen.tsx` | F. System/Interrupt |

---

## ARCHETYPE COUNTS

| Archetype | Count | Screens |
|-----------|-------|---------|
| A. Entry/Commitment | 5 | A1, A2, A3, O1, O3 |
| B. Feed/Opportunity | 2 | H2, H3 |
| C. Task Lifecycle | 8 | H4, H5, H6, H7, P2, P3, SH1, SH4 |
| D. Calibration/Capability | 14 | O2, O4-O12, P1, P4, S1, S3 |
| E. Progress/Status | 5 | H1, H8, S2, SH2, SH3 |
| F. System/Interrupt | 4 | H9, E1, E2, E3 |
| **TOTAL** | **38** | |

---

## CURSOR ENFORCEMENT

Before implementing ANY screen:

```
1. Find the screen in the map above
2. Note its archetype letter (A-F)
3. Read that archetype's specification
4. Inherit ALL patterns from that archetype
5. Build the screen

If you skip step 1-4, you WILL produce inconsistent UI.
```

**Screens are instances, not inventions.**
