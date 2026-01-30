# Onboarding Screens Specification

**Location:** `src/screens/onboarding/`
**Count:** 12 screens
**Status:** ✅ All screens have stitch-prompts

---

## Core Calibration Screens (4)

### O1: FramingScreen ✅

**File:** `FramingScreen.tsx`
**Spec:** ONBOARDING_SPEC §4.1
**Stitch-Prompt:** `O1-framing-screen.md`

### Purpose
Welcome and frame the HustleXP value proposition.

### Required Elements
- [x] Welcome message
- [x] Value proposition cards
- [x] How it works explanation
- [x] Continue button → CalibrationScreen

### Props Interface
```typescript
interface FramingScreenProps {
  onContinue?: () => void;
  currentStep?: number;
  totalSteps?: number;
}
```

---

### O2: CalibrationScreen

**File:** `CalibrationScreen.tsx`  
**Spec:** ONBOARDING_SPEC §4.2

### Purpose
Trust calibration quiz to set initial trust tier.

### Required Elements
- [ ] Question cards (swipeable)
- [ ] Progress indicator
- [ ] Answer options
- [ ] Skip option (with warning)

---

### O3: RoleConfirmationScreen

**File:** `RoleConfirmationScreen.tsx`  
**Spec:** ONBOARDING_SPEC §4.3

### Purpose
Choose primary role: Hustler, Poster, or Both.

### Required Elements
- [ ] Hustler option card
- [ ] Poster option card
- [ ] Both option
- [ ] Explanation of each role
- [ ] Continue button

---

### O4: PreferenceLockScreen

**File:** `PreferenceLockScreen.tsx`  
**Spec:** ONBOARDING_SPEC §4.4

### Purpose
Confirm and lock initial preferences.

### Required Elements
- [ ] Summary of selections
- [ ] Edit links for each section
- [ ] Confirm button (locks preferences)
- [ ] Warning: "These can be changed in Settings"

---

## Capability Screens (8)

**Location:** `src/screens/onboarding/capability/`

### O5: CapabilityIntroScreen

**File:** `CapabilityIntroScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.1

### Purpose
Explain what capabilities are and why they matter.

---

### O6: LocationSetupScreen

**File:** `LocationSetupScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.2

### Purpose
Set work location preferences.

### Required Elements
- [ ] State/region selector
- [ ] Work radius slider
- [ ] Map preview

---

### O7: TradeVerificationScreen

**File:** `TradeVerificationScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.3

### Purpose
Input professional licenses.

### Required Elements
- [ ] License type selector
- [ ] License number input
- [ ] Photo upload (license image)
- [ ] Verification status display

---

### O8: InsuranceUploadScreen

**File:** `InsuranceUploadScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.4

### Purpose
Upload liability insurance documents.

### Required Elements
- [ ] Insurance type selector
- [ ] Document upload
- [ ] Expiration date input
- [ ] Verification status

---

### O9: BackgroundCheckScreen

**File:** `BackgroundCheckScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.5

### Purpose
Consent and initiate background check.

### Required Elements
- [ ] Background check explanation
- [ ] Consent checkbox
- [ ] SSN input (last 4) - USER ENTERS, NOT AI
- [ ] Initiate button
- [ ] Status tracking

---

### O10: VehicleSetupScreen

**File:** `VehicleSetupScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.6

### Purpose
Vehicle information for delivery tasks.

### Required Elements
- [ ] Vehicle type selector
- [ ] Year/Make/Model inputs
- [ ] License plate input
- [ ] Photo upload

---

### O11: AvailabilityScreen

**File:** `AvailabilityScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.7

### Purpose
Set weekly availability slots.

### Required Elements
- [ ] Day-by-day availability grid
- [ ] Time slot selector
- [ ] Quick presets (weekdays, weekends)

---

### O12: CapabilitySummaryScreen

**File:** `CapabilitySummaryScreen.tsx`  
**Spec:** ONBOARDING_SPEC §5.8

### Purpose
Review all capabilities before confirming.

### Required Elements
- [ ] All capability sections listed
- [ ] Status for each (complete/incomplete)
- [ ] Edit links
- [ ] Finish button (completes onboarding)

---

## Navigation Flow

```
SignupScreen
    │
    ▼
FramingScreen → CalibrationScreen → RoleConfirmationScreen
                                           │
    ┌──────────────────────────────────────┴─────────────────────┐
    │                                                            │
    ▼ (Hustler or Both)                                    ▼ (Poster only)
CapabilityIntroScreen                                 PreferenceLockScreen
    │                                                        │
    ▼                                                        ▼
LocationSetupScreen → TradeVerification → Insurance →  HustlerHomeScreen
    │                                                  or PosterHomeScreen
    ▼
BackgroundCheck → VehicleSetup → Availability
    │
    ▼
CapabilitySummaryScreen → PreferenceLockScreen → MainApp
```
