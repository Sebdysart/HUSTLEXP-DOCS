# HustleXP Screen Registry v1.0

**STATUS: CONSTITUTIONAL REFERENCE**
**Total Screens: 32** (was 38, reduced by onboarding simplification from 12→6 screens)
**Functional: 32/32** (all build successfully in HUSTLEXPFINAL1 repo)
**Last Updated: February 5, 2026**

**Note:** UAP (UI Acceptance Protocol) verification has been deferred to post-MVP. All screens are currently marked as implementation-complete pending user testing.

---

## UI Acceptance Protocol (UAP) Integration

**Authority:** `PER/UI_ACCEPTANCE_PROTOCOL.md`

All screens now track UAP compliance status. A screen is NOT complete unless:
- Builds without crashing (necessary but insufficient)
- Passes all 5 UAP gates (UAP-0 through UAP-4)

**UAP Status Values:**
| Status | Meaning |
|--------|---------|
| `PENDING` | Not yet verified against UAP |
| `PASSED` | All 5 UAP gates passed — screen is COMPLETE |
| `FAILED` | One or more UAP gates failed — see notes |
| `INTERNAL` | Bootstrap/debug screen — exempt from UAP |

**CRITICAL RULE:** No screen may be marked COMPLETE unless UAP Status = `PASSED`.

---

## Quick Reference

| Category | Count | Location | Build Status |
|----------|-------|----------|--------------|
| Auth | 4 | `screens/auth/` | ✅ 4/4 |
| Hustler | 9 | `screens/hustler/` | ✅ 9/9 |
| Poster | 4 | `screens/poster/` | ✅ 4/4 |
| Onboarding | 6 | `screens/onboarding/` | ✅ 6/6 |
| Settings | 5 | `screens/settings/` | ✅ 5/5 |
| Shared | 4 | `screens/edge/` | ✅ 4/4 |
| **TOTAL** | **32** | — | **✅ 32/32** |

---

## §1. Auth Screens (4)

Location: `src/screens/auth/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| A1 | Login | `LoginScreen.tsx` | ONBOARDING_SPEC §2 | ✅ | Entry point for existing users |
| A2 | Signup | `SignupScreen.tsx` | ONBOARDING_SPEC §3 | ✅ | New user registration |
| A3 | Forgot Password | `ForgotPasswordScreen.tsx` | ONBOARDING_SPEC §2.3 | ✅ | Password reset flow |
| A4 | Phone Verification | `AuthPhoneVerificationScreen.tsx` | ONBOARDING_SPEC §3.1 | ✅ | SMS/OTP verification after signup |

### Auth Flow
```
App Launch → LoginScreen
         ↓ (no account)
      SignupScreen → AuthPhoneVerificationScreen (A4) → Onboarding Flow (O1-O6)
         ↓ (forgot)
      ForgotPasswordScreen → LoginScreen
```

---

## §2. Hustler Screens (9)

Location: `src/screens/hustler/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| H1 | Hustler Home | `HustlerHomeScreen.tsx` | UI_SPEC §5.1, PRODUCT_SPEC §3 | ✅ | Main dashboard for workers |
| H2 | Task Feed | `TaskFeedScreen.tsx` | UI_SPEC §5.2, PRODUCT_SPEC §9 | ✅ | Browse available tasks |
| H3 | Task History | `TaskHistoryScreen.tsx` | UI_SPEC §5.3 | ✅ | Past completed tasks |
| H4 | Task Detail | `TaskDetailScreen.tsx` | UI_SPEC §5.4, PRODUCT_SPEC §3.1 | ✅ | Single task view before accepting |
| H5 | Task In Progress | `TaskInProgressScreen.tsx` | UI_SPEC §5.5, PRODUCT_SPEC §3.2 | ✅ | Active task with map |
| H6 | Task Completion | `HustlerTaskCompletionScreen.tsx` | UI_SPEC §5.6, PRODUCT_SPEC §3.3 | ✅ | Submit proof, mark complete (Hustler view) |
| H7 | En Route Map | `HustlerEnRouteMapScreen.tsx` | UI_SPEC §5.5.2, SPATIAL_INTELLIGENCE_LOCKED.md | ✅ | Full-screen navigation, travel mode, proximity zones |
| H8 | XP Breakdown | `XPBreakdownScreen.tsx` | UI_SPEC §7, PRODUCT_SPEC §5 | ✅ | Detailed XP history |
| H9 | Instant Interrupt | `InstantInterruptCard.tsx` | UI_SPEC §14, PRODUCT_SPEC §3.5 | ✅ | Live Mode interrupt card |

### Hustler Task Flow
```
HustlerHomeScreen → TaskFeedScreen → TaskDetailScreen
                                          ↓ (accept)
                               TaskInProgressScreen ←→ HustlerEnRouteMapScreen
                                          ↓ (complete)
                               HustlerTaskCompletionScreen → XPBreakdownScreen
```


---

## §3. Poster Screens (4)

Location: `src/screens/poster/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| P1 | Poster Home | `PosterHomeScreen.tsx` | UI_SPEC §6.0, PRODUCT_SPEC §3 | ✅ | Main dashboard for task creators |
| P2 | Task Creation | `TaskCreationScreen.tsx` | UI_SPEC §6.1, PRODUCT_SPEC §3.1 | ✅ | Create & fund task |
| P3 | Hustler On Way | `HustlerOnWayScreen.tsx` | UI_SPEC §6.2, PRODUCT_SPEC §3.2 | ✅ | Track worker en route |
| P4 | Proof Review | `PosterProofReviewScreen.tsx` | UI_SPEC §6.3, PRODUCT_SPEC §3.3 | ✅ | Review proof, release escrow (Poster view) |

### Poster Task Flow
```
PosterHomeScreen (P1) → TaskCreationScreen (P2) → (wait for acceptance)
                                      ↓ (accepted)
                             HustlerOnWayScreen (P3) → (wait for completion)
                                      ↓ (proof submitted)
                             PosterProofReviewScreen (P4)
                 TaskCompletionScreen → FeedbackScreen
```

---

## §4. Onboarding Screens (6)

Location: `src/screens/onboarding/`

**Note:** This is the simplified v1.0 MVP flow. The capability-driven 12-screen flow (O1-O12 with granular skill selection) is deferred to v2.0 per EXECUTION_QUEUE.md canonical build sequence.

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| O1 | Welcome | `WelcomeScreen.tsx` | ONBOARDING_SCREENS.md §O1 | ✅ | Initial welcome & value prop |
| O2 | Role Selection | `RoleSelectionScreen.tsx` | ONBOARDING_SCREENS.md §O2 | ✅ | Hustler, Poster, or Both |
| O3 | Location Permission | `LocationPermissionScreen.tsx` | ONBOARDING_SCREENS.md §O3 | ✅ | Request GPS access |
| O4 | Notification Permission | `NotificationPermissionScreen.tsx` | ONBOARDING_SCREENS.md §O4 | ✅ | Request push notifications |
| O5 | Profile Setup | `ProfileSetupScreen.tsx` | ONBOARDING_SCREENS.md §O5 | ✅ | Basic profile info |
| O6 | Onboarding Complete | `OnboardingCompleteScreen.tsx` | ONBOARDING_SCREENS.md §O6 | ✅ | Success screen |

### Onboarding Flow
```
SignupScreen → FramingScreen → CalibrationScreen → RoleConfirmationScreen
                                                          ↓
                    PreferenceLockScreen ← CapabilitySummaryScreen
                           ↓                       ↑
                    HustlerHomeScreen    (8 capability screens)
                                         O5 → O5b → O6 → ... → O12
```

---

## §5. Settings Screens (3)

Location: `src/screens/settings/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| S1 | Profile | `ProfileScreen.tsx` | UI_SPEC §8.1 | ✅ | User profile management |
| S2 | Wallet | `WalletScreen.tsx` | UI_SPEC §8.2, PRODUCT_SPEC §4 | ✅ | Payment methods, earnings |
| S3 | Work Eligibility | `WorkEligibilityScreen.tsx` | UI_SPEC §8.3, PRODUCT_SPEC §17.5 | ✅ | **CRITICAL: Eligibility interpretability** |
| S4 | Help & Support | `HelpSupportScreen.tsx` | CUSTOMER_SUPPORT_SPEC | ✅ | Ticket creation, FAQ, contact support |
| S5 | Tax Documents | `TaxDocumentsScreen.tsx` | TAX_REPORTING_SPEC §4 | ✅ | 1099 downloads, W-9 status, earnings-to-date |


---

## §6. Shared Screens (4)

Location: `src/screens/shared/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| SH1 | Task Conversation | `TaskConversationScreen.tsx` | UI_SPEC §9.1, PRODUCT_SPEC §10 | ✅ | In-task messaging |
| SH2 | Trust Tier Ladder | `TrustTierLadderScreen.tsx` | UI_SPEC §9.2, PRODUCT_SPEC §5.2 | ✅ | Visual trust progression |
| SH3 | Trust Change | `TrustChangeExplanationScreen.tsx` | UI_SPEC §9.3, PRODUCT_SPEC §5.3 | ✅ | Why trust changed |
| SH4 | Dispute Entry | `DisputeEntryScreen.tsx` | UI_SPEC §9.4, PRODUCT_SPEC §4.3 | ✅ | File a dispute |

---

## §7. Edge Screens (3)

Location: `src/screens/edge/`

| # | Screen | File | Spec Reference | Build | Notes |
|---|--------|------|----------------|-------|-------|
| E1 | No Tasks Available | `NoTasksAvailableScreen.tsx` | UI_SPEC §10.1 | ✅ | Empty feed state |
| E2 | Eligibility Mismatch | `EligibilityMismatchScreen.tsx` | UI_SPEC §10.2 | ✅ | Why you can't see task |
| E3 | Trust Tier Locked | `TrustTierLockedScreen.tsx` | UI_SPEC §10.3 | ✅ | Trust too low for task |
| E4 | Instant Mode Unavailable | `InstantModeUnavailableScreen.tsx` | PRODUCT_SPEC §3.7 | ✅ | Live mode not yet unlocked |
| E5 | Force Update | `ForceUpdateScreen.tsx` | API_CONTRACT Force Update | ✅ | Blocking: app version too old |

---

## §8. Screen Dependencies

### Navigation Stacks

```
RootNavigator
├── AuthStack (not authenticated)
│   ├── LoginScreen
│   ├── SignupScreen
│   └── ForgotPasswordScreen
│
├── OnboardingStack (authenticated, not onboarded)
│   ├── FramingScreen
│   ├── CalibrationScreen
│   ├── RoleConfirmationScreen
│   ├── CapabilityStack (8 screens)
│   └── PreferenceLockScreen
│
└── MainTabs (authenticated + onboarded)
    ├── HustlerStack
    │   ├── HustlerHomeScreen
    │   ├── TaskFeedScreen
    │   ├── TaskDetailScreen
    │   ├── TaskInProgressScreen
    │   ├── TaskCompletionScreen
    │   └── XPBreakdownScreen
    │
    ├── PosterStack
    │   ├── PosterHomeScreen
    │   ├── TaskCreationScreen
    │   ├── HustlerOnWayScreen
    │   ├── TaskCompletionScreen
    │   └── FeedbackScreen
    │
    └── SettingsStack
        ├── ProfileScreen
        ├── WalletScreen
        └── WorkEligibilityScreen
```

### Shared Component Usage

| Component | Used By Screens |
|-----------|-----------------|
| `GlassCard` | All screens |
| `PrimaryActionButton` | All screens with actions |
| `SectionHeader` | Settings, Details, History |
| `TrustBadge` | Profile, TaskDetail, TaskCompletion |
| `XPDisplay` | Home, XPBreakdown, TaskCompletion |
| `MapView` | TaskInProgress, HustlerOnWay, EnRoute |

---

## §9. Known Issues

| Screen | Issue | Priority | Fix |
|--------|-------|----------|-----|
| `FramingScreen.tsx` | Continue button doesn't navigate | 🔴 HIGH | Add `useNavigation` hook |

### Fix for FramingScreen

```tsx
// BEFORE (broken)
<PrimaryActionButton label="Continue" onPress={() => {}} />

// AFTER (fixed)
import { useNavigation } from '@react-navigation/native';

const navigation = useNavigation();
<PrimaryActionButton 
  label="Continue" 
  onPress={() => navigation.navigate('Calibration')} 
/>
```

---

## §10. Implementation Checklist

Use this for tracking implementation status:

```
[ ] Auth (3/3)
  [x] LoginScreen
  [x] SignupScreen  
  [x] ForgotPasswordScreen

[ ] Hustler (9/9)
  [x] HustlerHomeScreen
  [x] TaskFeedScreen
  [x] TaskHistoryScreen
  [x] TaskDetailScreen
  [x] TaskInProgressScreen
  [x] TaskCompletionScreen
  [x] HustlerEnRouteMapScreen
  [x] XPBreakdownScreen
  [x] InstantInterruptCard

[ ] Poster (4/4)
  [x] TaskCreationScreen
  [x] HustlerOnWayScreen
  [x] TaskCompletionScreen
  [x] FeedbackScreen

[ ] Onboarding (11/12)
  [ ] FramingScreen ← NEEDS FIX
  [x] CalibrationScreen
  [x] RoleConfirmationScreen
  [x] PreferenceLockScreen
  [x] CapabilityIntroScreen
  [x] LocationSetupScreen
  [x] TradeVerificationScreen
  [x] InsuranceUploadScreen
  [x] BackgroundCheckScreen
  [x] VehicleSetupScreen
  [x] AvailabilityScreen
  [x] CapabilitySummaryScreen

[ ] Settings (3/3)
  [x] ProfileScreen
  [x] WalletScreen
  [x] WorkEligibilityScreen

[ ] Shared (4/4)
  [x] TaskConversationScreen
  [x] TrustTierLadderScreen
  [x] TrustChangeExplanationScreen
  [x] DisputeEntryScreen

[ ] Edge (5/5)
  [x] NoTasksAvailableScreen
  [x] EligibilityMismatchScreen
  [x] TrustTierLockedScreen
```

**Total: 37/38 functional**

---

## §11. iOS SwiftUI Implementation (SECONDARY PLATFORM)

**NOTE:** This section tracks an iOS native implementation. The **canonical screen list is §1-§7 (React Native)**. SwiftUI screens reference the same screen codes but are a secondary platform build.

Location: `ios-swiftui/HustleXP/`

**Status:** 15/38 screens implemented (SwiftUI native, iOS 17+)

| # | Screen | SwiftUI File | Source STITCH | Status |
|---|--------|--------------|---------------|--------|
| H1 | Hustler Home | `HustlerHomeScreen.swift` | 02-hustler-home.html | ✅ |
| H5 | Task In Progress | `TaskInProgressScreen.swift` | 08-hustler-task-in-progress.html | ✅ |
| H6 | Task Completion (Approved) | `TaskCompletionApprovedScreen.swift` | 09-hustler-task-completion-APPROVED.html | ✅ |
| H6 | Task Completion (Action Req) | `TaskCompletionActionRequiredScreen.swift` | 09-hustler-task-completion-ACTION-REQUIRED.html | ✅ |
| H6 | Task Completion (Blocked) | `TaskCompletionBlockedScreen.swift` | 09-hustler-task-completion-BLOCKED.html | ✅ |
| H8 | XP Breakdown | `XPBreakdownScreen.swift` | 07-xp-breakdown.html | ✅ |
| H9 | Instant Interrupt | `InstantInterruptCard.swift` | 01-instant-interrupt-card.html | ✅ |
| P3 | Poster Completion | `PosterTaskCompletionScreen.swift` | 10-poster-task-completion-FIXED.html | ✅ |
| SH2 | Trust Tier Ladder | `TrustTierLadderScreen.swift` | 06-trust-tier-ladder.html | ✅ |
| SH3 | Trust Change | `TrustChangeExplanationScreen.swift` | 12-trust-change-explanation-FIXED.html | ✅ |
| SH4 | Dispute Entry | `DisputeEntryScreen.swift` | 13-dispute-entry-*.html | ✅ |
| E1 | No Tasks Available | `NoTasksAvailableScreen.swift` | E1-no-tasks-available.html | ✅ |
| E2 | Eligibility Mismatch | `EligibilityMismatchScreen.swift` | E2-eligibility-mismatch.html | ✅ |
| E3 | Trust Tier Locked | `TrustTierLockedScreen.swift` | E3-trust-tier-locked.html | ✅ |
| E4 | Instant Mode Unavailable | `InstantModeUnavailableScreen.swift` | N/A | ⬜ |
| E5 | Force Update | `ForceUpdateScreen.swift` | N/A | ⬜ |

### Design System
- `HustleColors.swift` — Color tokens from DESIGN_SYSTEM.md
- `HustleTypography.swift` — Font system (8 sizes)
- `HustleComponents.swift` — GlassCard, PrimaryButton, ProgressRing, etc.

### Build Instructions
```bash
cd ios-swiftui/HustleXP && swift build
```

