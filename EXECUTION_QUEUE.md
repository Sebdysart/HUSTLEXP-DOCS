# EXECUTION QUEUE — HUSTLEXP v1.0 FRONTEND

**STATUS: ACTIVE — This is the ONLY file Cursor reads during build**  
**Frontend Repo: [HUSTLEXPFINAL1](https://github.com/Sebdysart/HUSTLEXPFINAL1)**  
**Rule: Execute steps in order. No skipping. No inventing. No "improving."**

---

## 🎯 MANDATORY PRE-STEP (For ALL Screen Steps)

**Before implementing ANY screen (Steps 020+), you MUST:**

```
1. Read SCREEN_ARCHETYPES.md
2. Find this screen's archetype (A-F)
3. Read that archetype's patterns (tone, visuals, motion)
4. Read UI_COMPONENT_HIERARCHY.md
5. Identify which atoms/molecules you will use
6. THEN proceed with the step
```

**Archetypes:**
- A = Entry/Commitment (Auth, Welcome, Role Selection)
- B = Feed/Opportunity (Task Feed, History)
- C = Task Lifecycle (In Progress, Proof, Conversation)
- D = Calibration/Capability (Onboarding, Settings)
- E = Progress/Status (Home, Profile, XP, Trust)
- F = System/Interrupt (Errors, Maintenance)

**If you skip archetype identification, you WILL produce inconsistent UI.**

---

## CURRENT PHASE: BOOTSTRAP

**Gate:** Nothing proceeds until Bootstrap passes.

---

## QUEUE FORMAT

```
STEP XXX: [Action]
Input: [Spec file]
Output: [File path]
Depends: [Previous step or "none"]
Constraints: [Hard rules]
Done: [ ] (check when complete)
```

---

## BOOTSTRAP PHASE (Steps 001-005)

### STEP 001: Create App Entry Point
```
Input: BOOTSTRAP.md
Output: App.tsx
Depends: none
Constraints:
  - Single SafeAreaView
  - Single Text component saying "HustleXP"
  - No navigation yet
  - No imports beyond react-native core
Done: [ ]
```

### STEP 002: Verify Xcode Build
```
Input: BOOTSTRAP.md
Output: Xcode build log (success)
Depends: STEP 001
Constraints:
  - Must build without errors
  - Must launch in iOS Simulator
  - Must display "HustleXP" text
Done: [ ]
```

### STEP 003: Add Bootstrap Button
```
Input: BOOTSTRAP.md
Output: App.tsx (modified)
Depends: STEP 002
Constraints:
  - Add single Button
  - Button logs "Bootstrap button pressed" to console
  - No styling beyond default
Done: [ ]
```

### STEP 004: Verify 30-Second Stability
```
Input: BOOTSTRAP.md
Output: Console log showing no crashes for 30 seconds
Depends: STEP 003
Constraints:
  - App must not crash
  - App must not freeze
  - Console must show button press logs
Done: [ ]
```

### STEP 005: Bootstrap Gate Complete
```
Input: BOOTSTRAP.md
Output: CURRENT_PHASE.md updated to "NAVIGATION"
Depends: STEP 004
Constraints:
  - All Bootstrap checks pass
  - User confirms advancement
Done: [ ]
```

---

## NAVIGATION PHASE (Steps 010-025)

### STEP 010: Create Navigation Container
```
Input: screens-spec/SCREEN_REGISTRY.md §Navigation
Output: src/navigation/RootNavigator.tsx
Depends: STEP 005
Constraints:
  - Use @react-navigation/native
  - NavigationContainer wrapper only
  - No screens yet, just structure
Done: [ ]
```

### STEP 011: Create Auth Stack
```
Input: screens-spec/auth/AUTH_SCREENS.md
Output: src/navigation/AuthStack.tsx
Depends: STEP 010
Constraints:
  - Stack.Navigator with 4 screens (stub)
  - A1: AuthLoginScreen
  - A2: AuthSignupScreen
  - A3: AuthForgotPasswordScreen
  - A4: AuthPhoneVerificationScreen
  - All screens are empty stubs returning <Text>Screen Name</Text>
Done: [ ]
```

### STEP 012: Create Onboarding Stack
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md
Output: src/navigation/OnboardingStack.tsx
Depends: STEP 010
Constraints:
  - Stack.Navigator with 6 screens (stub)
  - O1-O6 as listed in spec
  - All screens are empty stubs
Done: [ ]
```

### STEP 013: Create Hustler Tab Navigator
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md
Output: src/navigation/HustlerTabs.tsx
Depends: STEP 010
Constraints:
  - Tab.Navigator with 4 tabs
  - Home, Feed, History, Profile
  - All screens are empty stubs
Done: [ ]
```

### STEP 014: Create Poster Tab Navigator
```
Input: screens-spec/poster/POSTER_SCREENS.md
Output: src/navigation/PosterTabs.tsx
Depends: STEP 010
Constraints:
  - Tab.Navigator with 4 tabs
  - Home, Create, Active, Profile
  - All screens are empty stubs
Done: [ ]
```

### STEP 015: Create Settings Stack
```
Input: screens-spec/settings/SETTINGS_SCREENS.md
Output: src/navigation/SettingsStack.tsx
Depends: STEP 010
Constraints:
  - Stack.Navigator with 7 screens (stub)
  - S1-S7 as listed in spec
  - All screens are empty stubs
Done: [ ]
```

### STEP 016: Create Shared Screens
```
Input: screens-spec/shared/SHARED_SCREENS.md
Output: src/screens/shared/*.tsx (4 files)
Depends: STEP 010
Constraints:
  - SH1: TaskConversationScreen (stub)
  - SH2: TaskDetailScreen (stub)
  - SH3: ProofSubmissionScreen (stub)
  - SH4: DisputeScreen (stub)
Done: [ ]
```

### STEP 017: Create Edge State Screens
```
Input: screens-spec/edge/EDGE_SCREENS.md
Output: src/screens/edge/*.tsx (5 files)
Depends: STEP 010
Constraints:
  - E1-E5 as listed in spec
  - All screens are empty stubs
Done: [ ]
```

### STEP 018: Wire Root Navigator
```
Input: screens-spec/SCREEN_REGISTRY.md §Navigation Flow
Output: src/navigation/RootNavigator.tsx (modified)
Depends: STEP 011-017
Constraints:
  - Conditional rendering based on auth state (stub)
  - Auth → Onboarding → Main flow
  - No actual auth logic yet
Done: [ ]
```

### STEP 019: Navigation Gate Complete
```
Input: SCREEN_REGISTRY.md
Output: CURRENT_PHASE.md updated to "SCREENS"
Depends: STEP 018
Constraints:
  - All 38 screens exist as stubs
  - Navigation compiles
  - App runs with stub navigation
  - User confirms advancement
Done: [ ]
```

---

## SCREENS PHASE (Steps 020-060)

### AUTH SCREENS (Steps 020-023)

### STEP 020: Implement A1 AuthLoginScreen
```
Input: screens-spec/auth/AUTH_SCREENS.md §A1
Output: src/screens/auth/AuthLoginScreen.tsx
Depends: STEP 019
Constraints:
  - Email input
  - Password input
  - Login button (logs to console)
  - "Forgot Password" link
  - "Sign Up" link
  - No actual auth logic
  - Use design tokens from reference/constants/
Done: [ ]
```

### STEP 021: Implement A2 AuthSignupScreen
```
Input: screens-spec/auth/AUTH_SCREENS.md §A2
Output: src/screens/auth/AuthSignupScreen.tsx
Depends: STEP 020
Constraints:
  - Name, Email, Password, Confirm Password inputs
  - Sign Up button (logs to console)
  - "Already have account" link
  - No actual auth logic
Done: [ ]
```

### STEP 022: Implement A3 AuthForgotPasswordScreen
```
Input: screens-spec/auth/AUTH_SCREENS.md §A3
Output: src/screens/auth/AuthForgotPasswordScreen.tsx
Depends: STEP 020
Constraints:
  - Email input
  - Submit button (logs to console)
  - Back link
Done: [ ]
```

### STEP 023: Implement A4 AuthPhoneVerificationScreen
```
Input: screens-spec/auth/AUTH_SCREENS.md §A4
Output: src/screens/auth/AuthPhoneVerificationScreen.tsx
Depends: STEP 020
Constraints:
  - 6-digit code input
  - Verify button (logs to console)
  - Resend link
Done: [ ]
```

### ONBOARDING SCREENS (Steps 024-029)

### STEP 024: Implement O1 WelcomeScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O1
Output: src/screens/onboarding/WelcomeScreen.tsx
Depends: STEP 023
Constraints:
  - Logo
  - Welcome text
  - "Get Started" button
Done: [ ]
```

### STEP 025: Implement O2 RoleSelectionScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O2
Output: src/screens/onboarding/RoleSelectionScreen.tsx
Depends: STEP 024
Constraints:
  - "I want to post tasks" card
  - "I want to complete tasks" card
  - Selection state
  - Continue button
Done: [ ]
```

### STEP 026: Implement O3 LocationPermissionScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O3
Output: src/screens/onboarding/LocationPermissionScreen.tsx
Depends: STEP 025
Constraints:
  - Explanation text
  - "Allow Location" button (logs to console)
  - "Skip" option
Done: [ ]
```

### STEP 027: Implement O4 NotificationPermissionScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O4
Output: src/screens/onboarding/NotificationPermissionScreen.tsx
Depends: STEP 026
Constraints:
  - Explanation text
  - "Allow Notifications" button (logs to console)
  - "Skip" option
Done: [ ]
```

### STEP 028: Implement O5 ProfileSetupScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O5
Output: src/screens/onboarding/ProfileSetupScreen.tsx
Depends: STEP 027
Constraints:
  - Photo upload placeholder
  - Display name input
  - Bio input (optional)
  - Continue button
Done: [ ]
```

### STEP 029: Implement O6 OnboardingCompleteScreen
```
Input: screens-spec/onboarding/ONBOARDING_SCREENS.md §O6
Output: src/screens/onboarding/OnboardingCompleteScreen.tsx
Depends: STEP 028
Constraints:
  - Success message
  - "Start Using HustleXP" button
Done: [ ]
```

### HUSTLER SCREENS (Steps 030-039)

### STEP 030: Implement H1 HustlerHomeScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H1
Output: src/screens/hustler/HustlerHomeScreen.tsx
Depends: STEP 029
Constraints:
  - Welcome header with user name
  - Active task card (if exists)
  - Quick stats (XP, Trust Tier)
  - Recent activity list (empty state)
Done: [ ]
```

### STEP 031: Implement H2 TaskFeedScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H2
Output: src/screens/hustler/TaskFeedScreen.tsx
Depends: STEP 030
Constraints:
  - Task list (scrollable)
  - Filter controls (category, distance, pay)
  - Sort options
  - Pull-to-refresh
  - Empty state: "No tasks available"
Done: [ ]
```

### STEP 032: Implement H3 TaskHistoryScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H3
Output: src/screens/hustler/TaskHistoryScreen.tsx
Depends: STEP 031
Constraints:
  - Completed tasks list
  - Earnings summary
  - Filter by date range
  - Empty state
Done: [ ]
```

### STEP 033: Implement H4 HustlerProfileScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H4
Output: src/screens/hustler/HustlerProfileScreen.tsx
Depends: STEP 032
Constraints:
  - Profile photo
  - Display name
  - Trust tier badge
  - XP progress bar
  - Rating display
  - Settings link
Done: [ ]
```

### STEP 034: Implement H5 TaskInProgressScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H5
Output: src/screens/hustler/TaskInProgressScreen.tsx
Depends: STEP 033
Constraints:
  - Task details
  - Timer (time on task)
  - Contact poster button
  - Submit proof button
  - Cancel button (with warning)
Done: [ ]
```

### STEP 035: Implement H6 HustlerEnRouteMapScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H6
Output: src/screens/hustler/HustlerEnRouteMapScreen.tsx
Depends: STEP 034
Constraints:
  - Map placeholder (no actual map yet)
  - "I've arrived" button
  - Task location marker (placeholder)
  - ETA display (placeholder)
Done: [ ]
```

### STEP 036: Implement H7 XPBreakdownScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H7
Output: src/screens/hustler/XPBreakdownScreen.tsx
Depends: STEP 035
Constraints:
  - Total XP
  - XP by category
  - Recent XP gains
  - Level progress
Done: [ ]
```

### STEP 037: Implement H8 TrustTierScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H8
Output: src/screens/hustler/TrustTierScreen.tsx
Depends: STEP 036
Constraints:
  - Current tier
  - Next tier requirements
  - Tier benefits
  - Progress indicators
Done: [ ]
```

### STEP 038: Implement H9 EarningsScreen
```
Input: screens-spec/hustler/HUSTLER_SCREENS.md §H9
Output: src/screens/hustler/EarningsScreen.tsx
Depends: STEP 037
Constraints:
  - Total earnings
  - Pending payouts
  - Earnings history
  - Payout button (placeholder)
Done: [ ]
```

### POSTER SCREENS (Steps 040-049)

### STEP 040: Implement P1 PosterHomeScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P1
Output: src/screens/poster/PosterHomeScreen.tsx
Depends: STEP 038
Constraints:
  - Active tasks summary
  - Quick create button
  - Recent activity
Done: [ ]
```

### STEP 041: Implement P2 TaskCreationScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P2
Output: src/screens/poster/TaskCreationScreen.tsx
Depends: STEP 040
Constraints:
  - Title input
  - Description input
  - Category selector
  - Location input (placeholder)
  - Price input
  - AI assist indicator (placeholder)
  - Post button (disabled until requirements met)
Done: [ ]
```

### STEP 042: Implement P3 ActiveTasksScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P3
Output: src/screens/poster/ActiveTasksScreen.tsx
Depends: STEP 041
Constraints:
  - List of active tasks
  - Status indicators
  - Tap to view details
  - Empty state
Done: [ ]
```

### STEP 043: Implement P4 PosterProfileScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P4
Output: src/screens/poster/PosterProfileScreen.tsx
Depends: STEP 042
Constraints:
  - Profile info
  - Tasks posted count
  - Tasks completed count
  - Settings link
Done: [ ]
```

### STEP 044: Implement P5 TaskManagementScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P5
Output: src/screens/poster/TaskManagementScreen.tsx
Depends: STEP 043
Constraints:
  - Task details
  - Hustler info (when assigned)
  - Cancel task button
  - Edit task button (if not accepted)
Done: [ ]
```

### STEP 045: Implement P6 HustlerTrackingScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P6
Output: src/screens/poster/HustlerTrackingScreen.tsx
Depends: STEP 044
Constraints:
  - Map placeholder
  - Hustler location marker (placeholder)
  - ETA display
  - Contact hustler button
Done: [ ]
```

### STEP 046: Implement P7 ProofReviewScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P7
Output: src/screens/poster/ProofReviewScreen.tsx
Depends: STEP 045
Constraints:
  - Proof images/text display
  - Approve button
  - Dispute button
  - Request revision button
Done: [ ]
```

### STEP 047: Implement P8 TaskCompletionScreen
```
Input: screens-spec/poster/POSTER_SCREENS.md §P8
Output: src/screens/poster/TaskCompletionScreen.tsx
Depends: STEP 046
Constraints:
  - Completion summary
  - Rating input (1-5 stars)
  - Review text input (optional)
  - Submit button
Done: [ ]
```

### SHARED SCREENS (Steps 050-053)

### STEP 050: Implement SH1 TaskConversationScreen
```
Input: screens-spec/shared/SHARED_SCREENS.md §SH1
Output: src/screens/shared/TaskConversationScreen.tsx
Depends: STEP 047
Constraints:
  - Message list
  - Message input
  - Send button
  - Task context header
Done: [ ]
```

### STEP 051: Implement SH2 TaskDetailScreen
```
Input: screens-spec/shared/SHARED_SCREENS.md §SH2
Output: src/screens/shared/TaskDetailScreen.tsx
Depends: STEP 050
Constraints:
  - Task title, description
  - Category, location, price
  - Poster info
  - Accept button (for hustlers)
Done: [ ]
```

### STEP 052: Implement SH3 ProofSubmissionScreen
```
Input: screens-spec/shared/SHARED_SCREENS.md §SH3
Output: src/screens/shared/ProofSubmissionScreen.tsx
Depends: STEP 051
Constraints:
  - Photo upload
  - Text description
  - Submit button
Done: [ ]
```

### STEP 053: Implement SH4 DisputeScreen
```
Input: screens-spec/shared/SHARED_SCREENS.md §SH4
Output: src/screens/shared/DisputeScreen.tsx
Depends: STEP 052
Constraints:
  - Dispute reason selector
  - Description input
  - Evidence upload
  - Submit button
Done: [ ]
```

### SETTINGS SCREENS (Steps 054-060)

### STEP 054: Implement S1 SettingsMainScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S1
Output: src/screens/settings/SettingsMainScreen.tsx
Depends: STEP 053
Constraints:
  - Account section
  - Preferences section
  - About section
  - Logout button
Done: [ ]
```

### STEP 055: Implement S2 AccountSettingsScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S2
Output: src/screens/settings/AccountSettingsScreen.tsx
Depends: STEP 054
Constraints:
  - Email display
  - Phone display
  - Change password link
  - Delete account link
Done: [ ]
```

### STEP 056: Implement S3 NotificationSettingsScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S3
Output: src/screens/settings/NotificationSettingsScreen.tsx
Depends: STEP 055
Constraints:
  - Push notifications toggle
  - Email notifications toggle
  - SMS notifications toggle
Done: [ ]
```

### STEP 057: Implement S4 PaymentSettingsScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S4
Output: src/screens/settings/PaymentSettingsScreen.tsx
Depends: STEP 056
Constraints:
  - Saved payment methods list
  - Add payment method button
  - Default payment indicator
Done: [ ]
```

### STEP 058: Implement S5 PrivacySettingsScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S5
Output: src/screens/settings/PrivacySettingsScreen.tsx
Depends: STEP 057
Constraints:
  - Location sharing toggle
  - Profile visibility options
  - Data export button
Done: [ ]
```

### STEP 059: Implement S6 VerificationScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S6
Output: src/screens/settings/VerificationScreen.tsx
Depends: STEP 058
Constraints:
  - Verification status
  - ID verification button (placeholder)
  - Background check status (placeholder)
Done: [ ]
```

### STEP 060: Implement S7 SupportScreen
```
Input: screens-spec/settings/SETTINGS_SCREENS.md §S7
Output: src/screens/settings/SupportScreen.tsx
Depends: STEP 059
Constraints:
  - FAQ list
  - Contact support button
  - Report issue button
Done: [ ]
```

### EDGE SCREENS (Steps 061-065)

### STEP 061: Implement E1 NoTasksScreen
```
Input: screens-spec/edge/EDGE_SCREENS.md §E1
Output: src/screens/edge/NoTasksScreen.tsx
Depends: STEP 060
Constraints:
  - Empty state illustration
  - "No tasks in your area" message
  - Expand search radius button
Done: [ ]
```

### STEP 062: Implement E2 EligibilityMismatchScreen
```
Input: screens-spec/edge/EDGE_SCREENS.md §E2
Output: src/screens/edge/EligibilityMismatchScreen.tsx
Depends: STEP 061
Constraints:
  - Explanation of why task is unavailable
  - Requirements list
  - "How to qualify" link
Done: [ ]
```

### STEP 063: Implement E3 NetworkErrorScreen
```
Input: screens-spec/edge/EDGE_SCREENS.md §E3
Output: src/screens/edge/NetworkErrorScreen.tsx
Depends: STEP 062
Constraints:
  - Error illustration
  - Retry button
  - "Check connection" message
Done: [ ]
```

### STEP 064: Implement E4 MaintenanceScreen
```
Input: screens-spec/edge/EDGE_SCREENS.md §E4
Output: src/screens/edge/MaintenanceScreen.tsx
Depends: STEP 063
Constraints:
  - Maintenance message
  - Expected return time (if available)
Done: [ ]
```

### STEP 065: Implement E5 ForceUpdateScreen
```
Input: screens-spec/edge/EDGE_SCREENS.md §E5
Output: src/screens/edge/ForceUpdateScreen.tsx
Depends: STEP 064
Constraints:
  - Update required message
  - App Store link button
Done: [ ]
```

---

## SCREENS PHASE COMPLETE (Step 066)

### STEP 066: Screens Gate Complete
```
Input: SCREEN_REGISTRY.md
Output: CURRENT_PHASE.md updated to "WIRING"
Depends: STEP 065
Constraints:
  - All 38 screens implemented
  - All screens compile
  - Navigation works end-to-end
  - No console errors
  - User confirms advancement
Done: [ ]
```

---

## WIRING PHASE (Steps 070-099)

> This phase connects screens to mock data and state.
> Backend integration is NOT in scope for this phase.

(To be detailed after Screens Phase complete)

---

## QUEUE RULES

1. **Execute steps in order. No skipping.**
2. **Mark "Done: [x]" only when step passes.**
3. **If a step fails, stop and fix before proceeding.**
4. **No step may add features not in its spec.**
5. **No step may modify previous steps without approval.**
6. **If unclear, STOP and ask. Do not guess.**

---

## CURSOR COMMAND

When starting a build session, Cursor should run:

```
Read EXECUTION_QUEUE.md
Find first step where Done: [ ]
Execute that step only
Mark Done: [x] when complete
Stop
```

**Cursor does NOT:**
- Look ahead
- Plan multiple steps
- Suggest improvements
- Refactor existing code
- Add features not in current step
