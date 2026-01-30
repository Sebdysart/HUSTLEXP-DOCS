# SCREEN ARCHETYPES — HUSTLEXP v1.0

**STATUS: FROZEN — All 38 screens are categorized**  
**Rule: Identify archetype BEFORE implementation. Inherit, don't invent.**

---

## PURPOSE

Screens are NOT unique design problems.  
Screens are **instances of archetypes**.

This document:
1. Defines the 6 archetypes
2. Maps all 38 screens to archetypes
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
A1: AuthLoginScreen
A2: AuthSignupScreen
A3: AuthForgotPasswordScreen
A4: AuthPhoneVerificationScreen
O1: WelcomeScreen
O2: RoleSelectionScreen
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
H2: TaskFeedScreen
H3: TaskHistoryScreen
P3: ActiveTasksScreen
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
H5: TaskInProgressScreen
H6: HustlerEnRouteMapScreen
P5: TaskManagementScreen
P6: HustlerTrackingScreen
P7: ProofReviewScreen
P8: TaskCompletionScreen
SH1: TaskConversationScreen
SH2: TaskDetailScreen
SH3: ProofSubmissionScreen
SH4: DisputeScreen
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
O3: LocationPermissionScreen
O4: NotificationPermissionScreen
O5: ProfileSetupScreen
O6: OnboardingCompleteScreen
S1: SettingsMainScreen
S2: AccountSettingsScreen
S3: NotificationSettingsScreen
S4: PaymentSettingsScreen
S5: PrivacySettingsScreen
S6: VerificationScreen
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
H1: HustlerHomeScreen
H4: HustlerProfileScreen
H7: XPBreakdownScreen
H8: TrustTierScreen
H9: EarningsScreen
P1: PosterHomeScreen
P4: PosterProfileScreen
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
E1: NoTasksScreen
E2: EligibilityMismatchScreen
E3: NetworkErrorScreen
E4: MaintenanceScreen
E5: ForceUpdateScreen
S7: SupportScreen
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

## COMPLETE SCREEN-TO-ARCHETYPE MAP

| Screen | Code | Archetype |
|--------|------|-----------|
| AuthLoginScreen | A1 | A. Entry/Commitment |
| AuthSignupScreen | A2 | A. Entry/Commitment |
| AuthForgotPasswordScreen | A3 | A. Entry/Commitment |
| AuthPhoneVerificationScreen | A4 | A. Entry/Commitment |
| WelcomeScreen | O1 | A. Entry/Commitment |
| RoleSelectionScreen | O2 | A. Entry/Commitment |
| LocationPermissionScreen | O3 | D. Calibration/Capability |
| NotificationPermissionScreen | O4 | D. Calibration/Capability |
| ProfileSetupScreen | O5 | D. Calibration/Capability |
| OnboardingCompleteScreen | O6 | D. Calibration/Capability |
| HustlerHomeScreen | H1 | E. Progress/Status |
| TaskFeedScreen | H2 | B. Feed/Opportunity |
| TaskHistoryScreen | H3 | B. Feed/Opportunity |
| HustlerProfileScreen | H4 | E. Progress/Status |
| TaskInProgressScreen | H5 | C. Task Lifecycle |
| HustlerEnRouteMapScreen | H6 | C. Task Lifecycle |
| XPBreakdownScreen | H7 | E. Progress/Status |
| TrustTierScreen | H8 | E. Progress/Status |
| EarningsScreen | H9 | E. Progress/Status |
| PosterHomeScreen | P1 | E. Progress/Status |
| TaskCreationScreen | P2 | D. Calibration/Capability |
| ActiveTasksScreen | P3 | B. Feed/Opportunity |
| PosterProfileScreen | P4 | E. Progress/Status |
| TaskManagementScreen | P5 | C. Task Lifecycle |
| HustlerTrackingScreen | P6 | C. Task Lifecycle |
| ProofReviewScreen | P7 | C. Task Lifecycle |
| TaskCompletionScreen | P8 | C. Task Lifecycle |
| TaskConversationScreen | SH1 | C. Task Lifecycle |
| TaskDetailScreen | SH2 | C. Task Lifecycle |
| ProofSubmissionScreen | SH3 | C. Task Lifecycle |
| DisputeScreen | SH4 | C. Task Lifecycle |
| SettingsMainScreen | S1 | D. Calibration/Capability |
| AccountSettingsScreen | S2 | D. Calibration/Capability |
| NotificationSettingsScreen | S3 | D. Calibration/Capability |
| PaymentSettingsScreen | S4 | D. Calibration/Capability |
| PrivacySettingsScreen | S5 | D. Calibration/Capability |
| VerificationScreen | S6 | D. Calibration/Capability |
| SupportScreen | S7 | F. System/Interrupt |
| NoTasksScreen | E1 | F. System/Interrupt |
| EligibilityMismatchScreen | E2 | F. System/Interrupt |
| NetworkErrorScreen | E3 | F. System/Interrupt |
| MaintenanceScreen | E4 | F. System/Interrupt |
| ForceUpdateScreen | E5 | F. System/Interrupt |

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
