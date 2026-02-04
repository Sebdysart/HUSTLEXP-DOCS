# HustleXP Screen Registry v1.1.0

**STATUS: CONSTITUTIONAL REFERENCE**
**Total Screens: 38**
**Functional: 37** (FramingScreen needs navigation fix)
**UAP Verified: 0/38** (UI Acceptance Protocol verification pending)
**Last Updated: January 2025**

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

| Category | Count | Location | Build Status | UAP Status |
|----------|-------|----------|--------------|------------|
| Auth | 3 | `screens/auth/` | ✅ All build | PENDING |
| Hustler | 9 | `screens/hustler/` | ✅ All build | PENDING |
| Poster | 4 | `screens/poster/` | ✅ All build | PENDING |
| Onboarding | 12 | `screens/onboarding/` | ⚠️ 11/12 build | PENDING |
| Settings | 3 | `screens/settings/` | ✅ All build | PENDING |
| Shared | 4 | `screens/shared/` | ✅ All build | PENDING |
| Edge | 3 | `screens/edge/` | ✅ All build | PENDING |

---

## §1. Auth Screens (3)

Location: `src/screens/auth/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| A1 | Login | `LoginScreen.tsx` | ONBOARDING_SPEC §2 | ✅ | PENDING | Entry point for existing users |
| A2 | Signup | `SignupScreen.tsx` | ONBOARDING_SPEC §3 | ✅ | PENDING | New user registration |
| A3 | Forgot Password | `ForgotPasswordScreen.tsx` | ONBOARDING_SPEC §2.3 | ✅ | PENDING | Password reset flow |

### Auth Flow
```
App Launch → LoginScreen
         ↓ (no account)
      SignupScreen → Onboarding Flow
         ↓ (forgot)
      ForgotPasswordScreen → LoginScreen
```

---

## §2. Hustler Screens (9)

Location: `src/screens/hustler/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| H1 | Hustler Home | `HustlerHomeScreen.tsx` | UI_SPEC §5.1, PRODUCT_SPEC §3 | ✅ | PENDING | Main dashboard for workers |
| H2 | Task Feed | `TaskFeedScreen.tsx` | UI_SPEC §5.2, PRODUCT_SPEC §9 | ✅ | PENDING | Browse available tasks |
| H3 | Task History | `TaskHistoryScreen.tsx` | UI_SPEC §5.3 | ✅ | PENDING | Past completed tasks |
| H4 | Task Detail | `TaskDetailScreen.tsx` | UI_SPEC §5.4, PRODUCT_SPEC §3.1 | ✅ | PENDING | Single task view before accepting |
| H5 | Task In Progress | `TaskInProgressScreen.tsx` | UI_SPEC §5.5, PRODUCT_SPEC §3.2 | ✅ | PENDING | Active task with map |
| H6 | Task Completion | `TaskCompletionScreen.tsx` | UI_SPEC §5.6, PRODUCT_SPEC §3.3 | ✅ | PENDING | Submit proof, mark complete |
| H7 | En Route Map | `HustlerEnRouteMapScreen.tsx` | UI_SPEC §5.5.2, SPATIAL_INTELLIGENCE_LOCKED.md | ✅ | PENDING | Full-screen navigation, travel mode, proximity zones |
| H8 | XP Breakdown | `XPBreakdownScreen.tsx` | UI_SPEC §7, PRODUCT_SPEC §5 | ✅ | PENDING | Detailed XP history |
| H9 | Instant Interrupt | `InstantInterruptCard.tsx` | UI_SPEC §14, PRODUCT_SPEC §3.5 | ✅ | PENDING | Live Mode interrupt card |

### Hustler Task Flow
```
HustlerHomeScreen → TaskFeedScreen → TaskDetailScreen
                                          ↓ (accept)
                               TaskInProgressScreen ←→ HustlerEnRouteMapScreen
                                          ↓ (complete)
                               TaskCompletionScreen → XPBreakdownScreen
```


---

## §3. Poster Screens (4)

Location: `src/screens/poster/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| P1 | Task Creation | `TaskCreationScreen.tsx` | UI_SPEC §6.1, PRODUCT_SPEC §3.1 | ✅ | PENDING | Create & fund task |
| P2 | Hustler On Way | `HustlerOnWayScreen.tsx` | UI_SPEC §6.2, PRODUCT_SPEC §3.2 | ✅ | PENDING | Track worker en route |
| P3 | Task Completion | `TaskCompletionScreen.tsx` | UI_SPEC §6.3, PRODUCT_SPEC §3.3 | ✅ | PENDING | Review proof, release escrow |
| P4 | Feedback | `FeedbackScreen.tsx` | UI_SPEC §6.4, PRODUCT_SPEC §12 | ✅ | PENDING | Rate the hustler |

### Poster Task Flow
```
PosterHomeScreen → TaskCreationScreen → (wait for acceptance)
                          ↓ (accepted)
                 HustlerOnWayScreen → (wait for completion)
                          ↓ (proof submitted)
                 TaskCompletionScreen → FeedbackScreen
```

---

## §4. Onboarding Screens (12)

Location: `src/screens/onboarding/`

### §4.1 Core Calibration (4)

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| O1 | Framing | `FramingScreen.tsx` | ONBOARDING_SPEC §4.1 | ⚠️ | PENDING | **BROKEN: Continue button missing useNavigation** |
| O2 | Calibration | `CalibrationScreen.tsx` | ONBOARDING_SPEC §4.2 | ✅ | PENDING | Trust calibration quiz |
| O3 | Role Confirmation | `RoleConfirmationScreen.tsx` | ONBOARDING_SPEC §4.3 | ✅ | PENDING | Hustler vs Poster vs Both |
| O4 | Preference Lock | `PreferenceLockScreen.tsx` | ONBOARDING_SPEC §4.4 | ✅ | PENDING | Lock initial preferences |

### §4.2 Capability Screens (8)

Location: `src/screens/onboarding/capability/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| O5 | Capability Intro | `CapabilityIntroScreen.tsx` | ONBOARDING_SPEC §5.1 | ✅ | PENDING | Category selection (6 cards → O5b) |
| O5b | Skill Cloud | `SkillCloudScreen.tsx` | SKILL_TAXONOMY.md, ONBOARDING_SPEC §5.1b | ✅ | PENDING | Bubble-tap granular skill selection within chosen categories. 130+ skills. IC self-selection evidence. |
| O6 | Location Setup | `LocationSetupScreen.tsx` | ONBOARDING_SPEC §5.2 | ✅ | PENDING | Work location preferences |
| O7 | Trade Verification | `TradeVerificationScreen.tsx` | ONBOARDING_SPEC §5.3 | ✅ | PENDING | Professional license input |
| O8 | Insurance Upload | `InsuranceUploadScreen.tsx` | ONBOARDING_SPEC §5.4 | ✅ | PENDING | Liability insurance docs |
| O9 | Background Check | `BackgroundCheckScreen.tsx` | ONBOARDING_SPEC §5.5 | ✅ | PENDING | Consent & initiation |
| O10 | Vehicle Setup | `VehicleSetupScreen.tsx` | ONBOARDING_SPEC §5.6 | ✅ | PENDING | Vehicle info for delivery |
| O11 | Availability | `AvailabilityScreen.tsx` | ONBOARDING_SPEC §5.7 | ✅ | PENDING | Weekly availability slots |
| O12 | Capability Summary | `CapabilitySummaryScreen.tsx` | ONBOARDING_SPEC §5.8 | ✅ | PENDING | Review & confirm |

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

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| S1 | Profile | `ProfileScreen.tsx` | UI_SPEC §8.1 | ✅ | PENDING | User profile management |
| S2 | Wallet | `WalletScreen.tsx` | UI_SPEC §8.2, PRODUCT_SPEC §4 | ✅ | PENDING | Payment methods, earnings |
| S3 | Work Eligibility | `WorkEligibilityScreen.tsx` | UI_SPEC §8.3, PRODUCT_SPEC §17.5 | ✅ | PENDING | **CRITICAL: Eligibility interpretability** |


---

## §6. Shared Screens (4)

Location: `src/screens/shared/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| SH1 | Task Conversation | `TaskConversationScreen.tsx` | UI_SPEC §9.1, PRODUCT_SPEC §10 | ✅ | PENDING | In-task messaging |
| SH2 | Trust Tier Ladder | `TrustTierLadderScreen.tsx` | UI_SPEC §9.2, PRODUCT_SPEC §5.2 | ✅ | PENDING | Visual trust progression |
| SH3 | Trust Change | `TrustChangeExplanationScreen.tsx` | UI_SPEC §9.3, PRODUCT_SPEC §5.3 | ✅ | PENDING | Why trust changed |
| SH4 | Dispute Entry | `DisputeEntryScreen.tsx` | UI_SPEC §9.4, PRODUCT_SPEC §4.3 | ✅ | PENDING | File a dispute |

---

## §7. Edge Screens (3)

Location: `src/screens/edge/`

| # | Screen | File | Spec Reference | Build | UAP Status | Notes |
|---|--------|------|----------------|-------|------------|-------|
| E1 | No Tasks Available | `NoTasksAvailableScreen.tsx` | UI_SPEC §10.1 | ✅ | PENDING | Empty feed state |
| E2 | Eligibility Mismatch | `EligibilityMismatchScreen.tsx` | UI_SPEC §10.2 | ✅ | PENDING | Why you can't see task |
| E3 | Trust Tier Locked | `TrustTierLockedScreen.tsx` | UI_SPEC §10.3 | ✅ | PENDING | Trust too low for task |

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

[ ] Edge (3/3)
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

### Design System
- `HustleColors.swift` — Color tokens from DESIGN_SYSTEM.md
- `HustleTypography.swift` — Font system (8 sizes)
- `HustleComponents.swift` — GlassCard, PrimaryButton, ProgressRing, etc.

### Build Instructions
```bash
cd ios-swiftui/HustleXP && swift build
```

