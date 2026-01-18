# HustleXP Frontend Execution Prompts — MAX-TIER

**Status:** LOCKED  
**Date:** January 2025  
**Purpose:** Exact prompts for Cursor to generate frontend screens without hallucination or backend assumptions

---

## Critical Rules (Non-Negotiable)

1. **NO backend logic in frontend**
2. **NO mock eligibility decisions**
3. **UI shells only — props, placeholders, loading states**
4. **Spec-driven — every element must reference HUSTLEXP-DOCS**
5. **Use existing shared components — GlassCard, PrimaryActionButton, SectionHeader**

---

## PROMPT 1: Settings → Work Eligibility Screen (CRITICAL)

**Execution Order:** Phase F-1, Task #1  
**Priority:** CRITICAL — Must be built first  
**Blocking:** All other screens depend on eligibility interpretability

---

### Exact Cursor Prompt (Copy/Paste Verbatim)

```
You are implementing the Settings → Work Eligibility screen for HustleXP iOS app.

YOUR TASK:
Generate a React Native screen component at:
hustlexp-app/screens/settings/WorkEligibilityScreen.tsx

CRITICAL RULES (DO NOT VIOLATE):

1. THIS IS UI-ONLY. NO BACKEND LOGIC.
   - Use placeholder props/interfaces for all data
   - NO eligibility computation in the component
   - NO "isEligible()" functions
   - NO trust tier comparisons
   - NO client-side filtering

2. SPEC-DRIVEN. EVERY ELEMENT MUST REFERENCE DOCS.
   - Read: architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md
   - Read: PRODUCT_SPEC.md §17.5 "Settings explains reality"
   - Follow page structure EXACTLY: Eligibility Summary → Verified Trades → Insurance → Background Checks → Upgrade Opportunities → System Notices

3. USE EXISTING SHARED COMPONENTS.
   - Import GlassCard from: hustlexp-app/ui/GlassCard.tsx
   - Import PrimaryActionButton from: hustlexp-app/ui/PrimaryActionButton.tsx
   - Import SectionHeader from: hustlexp-app/ui/SectionHeader.tsx
   - Import colors, spacing, typography from: hustlexp-app/ui/

4. PLACEHOLDER DATA ONLY.
   - Define TypeScript interfaces for props (never fetch data)
   - Example: interface WorkEligibilityProps { currentTrustTier?: number; verifiedTrades?: string[]; }
   - All data comes from props (parent component will wire later)

5. FORBIDDEN PATTERNS (NEVER DO THESE):
   - ❌ fetch('/api/eligibility')
   - ❌ if (user.trust_tier >= task.required_tier)
   - ❌ const isEligible = computeEligibility(...)
   - ❌ Hardcoded eligibility decisions
   - ❌ Mock API calls
   - ❌ State management (Redux, Context for data)

6. ALLOWED PATTERNS (ONLY DO THESE):
   - ✅ Props interface: interface EligibilityData { ... }
   - ✅ Loading state UI: <View><Text>Loading eligibility...</Text></View>
   - ✅ Empty states: "No verified trades" when verifiedTrades?.length === 0
   - ✅ Placeholder buttons: <PrimaryActionButton label="Verify License" onPress={() => {}} disabled={true} />
   - ✅ Display-only: Show what props provide, nothing more

7. PAGE STRUCTURE (EXACT ORDER FROM SPEC):
   Section 1: Eligibility Summary (Read-Only)
   - Current Trust Tier
   - Active Risk Clearance (Low / Medium / High / Critical)
   - Work Location (State)
   - Copy: "You're eligible for: ..." / "Not eligible for: ..."
   - NO buttons, NO upsells here

   Section 2: Verified Trades
   - For each trade (from props.verifiedTrades array):
     * State A: Not Verified → Status: ❌, Action: "Verify license" button (disabled placeholder)
     * State B: Pending → Status: ⏳, No action
     * State C: Verified → Status: ✅, Show trade + state + expiration
     * State D: Expired → Status: ⚠️, Action: "Renew verification" button (disabled placeholder)
   - NO toggles. Verification status is truth (display-only).

   Section 3: Insurance Section (Conditional)
   - Shown ONLY if: user has at least one verified trade (from props)
   - States: ❌ Not on file → "Add insurance", ⏳ Pending, ✅ Active (show coverage + expiry), ⚠️ Expired → "Renew insurance"

   Section 4: Background Checks (Conditional)
   - Shown ONLY if: user opted into critical tasks (from props)
   - States: ❌ Not completed, ⏳ Pending, ✅ Verified (show expiry), ⚠️ Expired

   Section 5: Upgrade Opportunities (Computed Display Only)
   - Show card ONLY if: props.upgradeOpportunities?.length > 0
   - Display what props provide (no computation)
   - Example card: "Verify Electrician License" → "Unlocks 7 active gigs near you"
   - NO hypothetical counts, NO "up to" language

   Section 6: System Notices (Expiry Only)
   - Badge/count if props.hasExpiredCredentials === true
   - Inline alert at top if props.hasExpiredCredentials === true
   - Text: "Credential expired" (non-negotiable tone from spec)

8. COPY GUIDELINES (FROM SPEC):
   - Use EXACT wording from SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md
   - NO emotional language
   - NO "unlock", "get verified", "become a pro"
   - Factual only: "Verified", "Pending", "Expired"

9. SCREEN METADATA (REQUIRED HEADER):
   Add this exact comment block at top of file:
   /**
    * Settings → Work Eligibility Screen
    * 
    * Screen: SETTINGS_WORK_ELIGIBILITY
    * Spec: HUSTLEXP-DOCS/architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md
    * Version: v1
    * Status: LOCKED
    * Components (required): GlassCard, PrimaryActionButton, SectionHeader
    * Tokens (required): colors.json, spacing.json, typography.json
    * 
    * CRITICAL: This is UI-only. NO eligibility computation. NO backend logic.
    * All data comes from props. Placeholder buttons are disabled.
    */

10. VERIFICATION CHECKLIST (BEFORE COMMITTING):
   - [ ] No fetch() calls
   - [ ] No eligibility computation functions
   - [ ] All data from props
   - [ ] Uses GlassCard, PrimaryActionButton, SectionHeader
   - [ ] Follows exact page structure from spec
   - [ ] Header comment references spec file
   - [ ] All buttons are placeholders (disabled or console.log)
   - [ ] Loading/empty states present

OUTPUT REQUIREMENTS:
- Single file: hustlexp-app/screens/settings/WorkEligibilityScreen.tsx
- TypeScript (not JavaScript)
- React Native (View, Text, ScrollView, StyleSheet)
- SafeAreaView for notch handling
- All styling from design tokens (no inline magic numbers)

IF SOMETHING IS UNCLEAR:
- Read the spec file first: architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md
- If still unclear, ask — do NOT invent behavior.

Generate the screen now.
```

---

## PROMPT 2: Capability-Driven Onboarding Screens (HIGH)

**Execution Order:** Phase F-2, Task #3  
**Priority:** HIGH — Build after Settings screen  
**Blocking:** Cannot collect capability claims without onboarding UI

---

### Exact Cursor Prompt (Copy/Paste Verbatim)

```
You are implementing the Capability-Driven Onboarding flow for HustleXP iOS app.

YOUR TASK:
Generate React Native screen components for the 7-phase onboarding flow at:
hustlexp-app/screens/onboarding/

CRITICAL RULES (DO NOT VIOLATE):

1. THIS IS UI-ONLY. NO VERIFICATION LOGIC.
   - Collect answers via props/callbacks
   - NO verification execution
   - NO eligibility granting
   - NO backend API calls

2. SPEC-DRIVEN. FOLLOW EXACT PHASE STRUCTURE.
   - Read: architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md
   - Follow 7 phases EXACTLY: Role Declaration → Location → Capability Declaration → Credential Claim → License Metadata → Insurance → Risk Willingness → Summary

3. USE EXISTING SHARED COMPONENTS.
   - Import GlassCard from: hustlexp-app/ui/GlassCard.tsx
   - Import PrimaryActionButton from: hustlexp-app/ui/PrimaryActionButton.tsx
   - Import SectionHeader from: hustlexp-app/ui/SectionHeader.tsx
   - Import colors, spacing, typography from: hustlexp-app/ui/

4. PROPS-BASED DATA FLOW.
   - Each screen accepts: { onNext: (data) => void, onBack: () => void, initialData?: object }
   - Data flows UP to parent (onboarding container/wrapper)
   - NO local state persistence (parent handles it)

5. FORBIDDEN PATTERNS:
   - ❌ await submitVerification(...)
   - ❌ if (tradeVerified) { unlockGigs() }
   - ❌ fetch('/api/onboarding/submit')
   - ❌ LocalStorage/sessionStorage for data
   - ❌ Navigation assumptions (no "navigate to feed")

6. ALLOWED PATTERNS:
   - ✅ Form inputs with controlled values
   - ✅ onNext({ role: 'hustler', claimedTrades: ['electrician'] })
   - ✅ Conditional UI based on props (e.g., show license fields if regulated trade selected)
   - ✅ Validation UI (required field indicators)
   - ✅ Loading states (spinner while parent processes)

7. REQUIRED SCREENS (GENERATE ALL 7):

   Screen 1: RoleDeclarationScreen.tsx
   - Q0: "How do you want to use HustleXP?"
   - Options: "I want to earn money", "I want to post gigs", "Both"
   - onNext({ role: 'hustler' | 'poster' | 'both' })
   - Spec: CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md PHASE 0

   Screen 2: LocationScreen.tsx
   - Q1: "Where will you be working?"
   - State dropdown (required)
   - City/ZIP (optional)
   - onNext({ workState: 'WA', workRegion: 'Seattle' })
   - Spec: PHASE 1

   Screen 3: CapabilityDeclarationScreen.tsx
   - Q2: "What types of work are you qualified to do?"
   - Multi-select checkboxes
   - Trades visually marked: "License required"
   - onNext({ claimedTrades: ['electrician', 'moving'] })
   - Spec: PHASE 2

   Screen 4: CredentialClaimScreen.tsx
   - Q3: "Do you currently hold a valid license?"
   - Yes/No/Not sure
   - If No: "You won't see licensed gigs until verification is complete."
   - If Yes: Proceed to next screen
   - onNext({ hasLicense: true | false })
   - Spec: PHASE 3

   Screen 5: LicenseMetadataScreen.tsx
   - Q4: License details (only shown if hasLicense === true)
   - License number input
   - Issuing state dropdown
   - Trade type (auto-filled from previous screen)
   - Expiration date (optional)
   - onNext({ licenseClaims: [{ trade: 'electrician', state: 'WA', licenseNumber: 'EL12345' }] })
   - Spec: PHASE 4

   Screen 6: InsuranceScreen.tsx
   - Q5: "Do you currently carry active professional insurance?"
   - Yes/No
   - If No: "Insurance is required for certain higher-risk gigs..."
   - onNext({ insuranceClaimed: true | false })
   - Spec: PHASE 5

   Screen 7: RiskWillingnessScreen.tsx
   - Q6: "Are you willing to do the following?"
   - In-home work checkbox
   - Urgent/same-day gigs checkbox
   - High-value installs checkbox
   - onNext({ riskPreferences: { inHome: true, urgent: true, highValue: false } })
   - Spec: PHASE 6

   Screen 8: OnboardingSummaryScreen.tsx
   - Summary of all answers
   - "You're set up to earn on HustleXP"
   - Locked sections: "Verify Electrician License to unlock 14 gigs near you"
   - onNext() → Complete onboarding
   - Spec: PHASE 7

8. SCREEN METADATA (REQUIRED HEADER):
   Add this exact comment block at top of each file:
   /**
    * Onboarding Screen: [Phase Name]
    * 
    * Screen: ONBOARDING_[PHASE_NAME]
    * Spec: HUSTLEXP-DOCS/architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md
    * Phase: [0-7]
    * Version: v1
    * Status: LOCKED
    * Components (required): GlassCard, PrimaryActionButton, SectionHeader
    * 
    * CRITICAL: UI-only. NO verification execution. NO eligibility granting.
    * Data flows via onNext callback to parent.
    */

9. FILE STRUCTURE:
   Create directory: hustlexp-app/screens/onboarding/
   Files:
   - RoleDeclarationScreen.tsx
   - LocationScreen.tsx
   - CapabilityDeclarationScreen.tsx
   - CredentialClaimScreen.tsx
   - LicenseMetadataScreen.tsx
   - InsuranceScreen.tsx
   - RiskWillingnessScreen.tsx
   - OnboardingSummaryScreen.tsx

10. VERIFICATION CHECKLIST:
   - [ ] All 8 screens generated
   - [ ] No verification API calls
   - [ ] Data flows via onNext callbacks
   - [ ] Uses shared components
   - [ ] Follows exact phase structure from spec
   - [ ] Header comments reference spec file
   - [ ] No navigation assumptions
   - [ ] Conditional UI based on props/answers

OUTPUT REQUIREMENTS:
- 8 TypeScript files in hustlexp-app/screens/onboarding/
- React Native components (View, Text, ScrollView, TextInput, Checkbox/Select)
- SafeAreaView for notch handling
- All styling from design tokens

Generate all 8 screens now.
```

---

## PROMPT 3: Feed UI Shell (LATER — When Backend Ready)

**Execution Order:** Phase F-3, Task #5  
**Priority:** MEDIUM — Build after Settings + Onboarding  
**Blocking:** Feed resolver must exist in backend (Phase 1.3 complete)

---

### Exact Cursor Prompt (Copy/Paste Verbatim)

```
You are implementing the Task Feed UI shell for HustleXP iOS app.

YOUR TASK:
Generate a React Native screen component at:
hustlexp-app/screens/hustler/TaskFeedScreen.tsx

CRITICAL RULES (DO NOT VIOLATE):

1. THIS IS UI-ONLY. NO ELIGIBILITY FILTERING.
   - Display tasks from props.tasks array
   - NO client-side filtering
   - NO eligibility computation
   - NO "isEligible()" checks

2. SPEC-DRIVEN. FOLLOW FEED STRUCTURE.
   - Read: architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md
   - Feed modes: normal, urgent, nearby (display only, no logic)
   - Pagination UI (cursor passed via props, no computation)

3. USE EXISTING SHARED COMPONENTS.
   - Import GlassCard, PrimaryActionButton, SectionHeader
   - Import design tokens

4. PROPS-BASED DATA.
   - interface TaskFeedProps { tasks: Task[], feedMode: 'normal' | 'urgent' | 'nearby', onLoadMore: () => void, isLoading: boolean }
   - All tasks come from props (backend will filter)

5. FORBIDDEN PATTERNS:
   - ❌ tasks.filter(task => isEligible(task))
   - ❌ if (user.trustTier >= task.requiredTrustTier)
   - ❌ fetch('/api/feed').then(filter)
   - ❌ Client-side eligibility computation of ANY kind

6. ALLOWED PATTERNS:
   - ✅ Display tasks from props.tasks array
   - ✅ Loading state: <ActivityIndicator />
   - ✅ Empty state: "No tasks available" (if props.tasks.length === 0)
   - ✅ Pagination: onLoadMore callback when scrolled to bottom
   - ✅ Task cards with GlassCard

7. TASK CARD STRUCTURE (Display Only):
   - Task title
   - Task category
   - Location
   - Payout amount
   - Accept button (onPress callback, no eligibility check)

8. SCREEN METADATA:
   /**
    * Task Feed Screen (UI Shell)
    * 
    * Screen: HUSTLER_TASK_FEED
    * Spec: HUSTLEXP-DOCS/architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md
    * Version: v1
    * Status: UI-ONLY (eligibility filtering handled by backend)
    * 
    * CRITICAL: NO client-side eligibility filtering. Tasks are pre-filtered by backend.
    * All tasks in props.tasks are eligible (backend guarantees this).
    */

9. VERIFICATION CHECKLIST:
   - [ ] No filtering logic
   - [ ] Tasks from props only
   - [ ] Loading/empty states
   - [ ] Uses shared components
   - [ ] Header comment states "UI-ONLY"

Generate the feed screen now.
```

---

## Execution Order Summary

1. **PROMPT 1** → Settings → Work Eligibility Screen (CRITICAL, Phase F-1)
2. **PROMPT 2** → Capability-Driven Onboarding Screens (HIGH, Phase F-2)
3. **PROMPT 3** → Feed UI Shell (MEDIUM, Phase F-3 — wait until backend Phase 1.3 complete)

---

## Common Forbidden Patterns (Apply to ALL Prompts)

- ❌ `fetch('/api/...')` calls
- ❌ `isEligible()`, `computeEligibility()`, `filterEligibleTasks()`
- ❌ `if (user.trustTier >= task.requiredTrustTier)`
- ❌ `localStorage` / `AsyncStorage` for eligibility data
- ❌ Mock API responses
- ❌ Hardcoded eligibility decisions

---

## Common Required Patterns (Apply to ALL Prompts)

- ✅ Props interfaces for all data
- ✅ Loading states (`isLoading` prop)
- ✅ Empty states (when `props.items?.length === 0`)
- ✅ Shared components (GlassCard, PrimaryActionButton, SectionHeader)
- ✅ Design tokens (colors, spacing, typography)
- ✅ Header comments with spec references
- ✅ SafeAreaView for notch handling

---

**END OF FRONTEND EXECUTION PROMPTS**
