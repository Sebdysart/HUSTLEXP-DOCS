# HustleXP Onboarding Flow Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Product/Design Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** Onboarding UX must follow this spec. References ONBOARDING_SPEC.md for business logic.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Onboarding Phases](#2-onboarding-phases)
3. [Screen-by-Screen Specification](#3-screen-by-screen-specification)
4. [First Task Guided Walkthrough](#4-first-task-guided-walkthrough)
5. [Permission Request Flows](#5-permission-request-flows)
6. [Progress Indicators](#6-progress-indicators)
7. [Gamification Unlock Moment](#7-gamification-unlock-moment)
8. [Error Handling](#8-error-handling)
9. [Invariants](#9-invariants)

---

## 1. Overview

### Onboarding Philosophy

HustleXP onboarding follows the **Duolingo model**: short, gamified, progress-driven, but with **Apple Glass restraint** during the actual flow.

> **Core Principle:** Onboarding sets expectations. Premature rewards teach users to expect unearned dopamine. Therefore: **zero celebration until first economic truth (RELEASED escrow).**

### Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Time to First Screen** | < 3 seconds | App launch to welcome |
| **Steps to Role Lock** | 5-7 taps | Welcome → Role confirmed |
| **Time to First Task** | < 2 minutes | Role lock → First task posted/browsed |
| **First Task Completion Rate** | > 70% | Users who complete onboarding AND first task |

### Visual Rules During Onboarding

Per UI_SPEC.md §12 (Onboarding Visual Rules):

| Element | Allowed | Rationale |
|---------|---------|-----------|
| XP colors | No | Nothing earned yet |
| Money colors | No | No transactions yet |
| Celebrations | No | Nothing to celebrate |
| Badges | No | None unlocked |
| Animation | Minimal | Professional tone |
| Progress bar | Yes | Shows completion |

---

## 2. Onboarding Phases

### Phase Overview

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 0       PHASE 1A       PHASE 1B          PHASE 2        PHASE 2B        PHASE 3     PHASE 4│
│  Welcome   →   Account    →   Calibration  →   Verification →  Legal      →   Role Lock →  First  │
│  (1 screen)    Verify (2)     (3 screens)       (optional)     Accept (1)     (1 screen)    Task   │
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | Purpose | Screens | Skippable |
|-------|---------|---------|-----------|
| **0: Welcome** | Hook + value prop | 1 | No |
| **1A: Account Verify** | Phone + email verification | 2 | No |
| **1B: Calibration** | Determine role intent | 3 | No |
| **2: Verification** | ID/Background (if required) | 1-2 | Depends on role |
| **2B: Legal Acceptance** | ToS, Privacy, IC Agreement | 1 | No |
| **3: Role Lock** | Confirm role selection | 1 | No |
| **4: First Task** | Guided walkthrough | 3-5 | No |

---

## 3. Screen-by-Screen Specification

### Phase 0: Welcome Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                                                                 │
│                        [HustleXP Logo]                         │
│                                                                 │
│                                                                 │
│                  Get things done. Get paid.                    │
│                                                                 │
│                                                                 │
│          Post tasks and find help in minutes.                  │
│          Or earn money completing tasks nearby.                │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                   [ Get Started ]                              │
│                                                                 │
│                                                                 │
│              Already have an account? Sign in                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Background:** Neutral white or subtle gradient (no brand gradient)
- **Animation:** Logo fade-in only (300ms)
- **Copy:** Clear, direct, no fluff
- **CTA:** Single primary button
- **Link:** Secondary text link for sign-in

### Phase 1A: Account Verification

**Authority:** PRODUCT_SPEC §23 (Sybil Prevention), §24 (Email Verification)

#### Screen 1A.1: Phone Number Verification

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                  Verify your phone number                       │
│                                                                 │
│          We'll send a 6-digit code via SMS.                    │
│          This helps keep HustleXP safe.                        │
│                                                                 │
│          ┌───────────────────────────────────┐                 │
│          │  +1  (___) ___-____              │                 │
│          └───────────────────────────────────┘                 │
│                                                                 │
│          ┌───────────────────────────────────┐                 │
│          │         Send Code                 │                 │
│          └───────────────────────────────────┘                 │
│                                                                 │
│          [After code sent: 6-digit input]                      │
│          ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐                      │
│          │  │ │  │ │  │ │  │ │  │ │  │                      │
│          └──┘ └──┘ └──┘ └──┘ └──┘ └──┘                      │
│                                                                 │
│          Didn't receive it? Resend (60s cooldown)              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Provider:** Firebase Auth phone verification (or Twilio)
- **Rate limit:** Max 3 SMS per phone number per hour
- **Validation:** US phone numbers only (v1), E.164 format
- **Sybil check:** Phone number checked against `banned_phones` table before sending
- **On success:** `phone_verified = true`, proceed to email verification
- **Error states:** Invalid format, already registered, banned number, rate limited

#### Screen 1A.2: Email Verification

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                  Check your email                              │
│                                                                 │
│          We sent a verification link to                        │
│          user@example.com                                      │
│                                                                 │
│          ┌───────────────────────────────────┐                 │
│          │       Open Email App              │                 │
│          └───────────────────────────────────┘                 │
│                                                                 │
│          ┌───────────────────────────────────┐                 │
│          │    I've verified, continue →      │                 │
│          └───────────────────────────────────┘                 │
│                                                                 │
│          Didn't receive it? Resend email                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Provider:** Firebase Auth email verification
- **Flow:** Firebase sends verification email → user taps link → returns to app
- **Deep link:** `hustlexp://verify-email?oobCode=...`
- **Polling:** App polls `email_verified` status every 5 seconds while on this screen
- **On success:** `email_verified = true`, proceed to calibration
- **Skip behavior:** NOT skippable. Account has limited functionality until verified.
- **Resend cooldown:** 60 seconds between resend requests

### Phase 1B: Calibration Screens

**Note:** Previously labeled "Phase 1". Renumbered to accommodate Phase 1A (Account Verification).

#### Screen 1.1: What brings you here?

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     1 of 3             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│               What brings you to HustleXP?                     │
│                                                                 │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  📤  I need help getting things done                      │ │
│  │      Post tasks and hire local help                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  💰  I want to earn money                                 │ │
│  │      Complete tasks and get paid                          │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  🔄  Both - I want to do both                             │ │
│  │      Post tasks and complete tasks                        │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Selection:** Single-select radio cards
- **Progress:** Thin bar at top (1/3)
- **Transition:** Tap selection → 150ms fade → Next screen
- **Animation:** Cards fade in staggered (50ms delay each)

#### Screen 1.2: Location Access

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     2 of 3             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                       [Map Icon]                               │
│                                                                 │
│              Where are you looking for tasks?                  │
│                                                                 │
│                                                                 │
│     We use your location to show relevant tasks nearby.        │
│     Your exact location is never shared with others.           │
│                                                                 │
│                                                                 │
│                                                                 │
│                   [ Enable Location ]                          │
│                                                                 │
│                    Maybe later                                  │
│                                                                 │
│                                                                 │
│     🔒 Privacy: We only access location when the app          │
│        is open. You can change this anytime.                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Icon:** Simple map pin, not animated
- **Copy:** Explains value + privacy in plain language
- **CTA:** Primary button triggers system permission dialog
- **Secondary:** "Maybe later" is text link, doesn't block progress
- **Privacy note:** Always visible, builds trust

#### Screen 1.3: Notification Permission

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     3 of 3             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                       [Bell Icon]                              │
│                                                                 │
│               Never miss an opportunity                        │
│                                                                 │
│                                                                 │
│     We'll notify you when:                                     │
│                                                                 │
│     ✓ A task nearby matches your skills                        │
│     ✓ Someone accepts your posted task                         │
│     ✓ You receive a payment                                    │
│                                                                 │
│                                                                 │
│                   [ Enable Notifications ]                     │
│                                                                 │
│                    Not now                                      │
│                                                                 │
│                                                                 │
│     You can customize notification types in Settings.          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Icon:** Simple bell, not animated
- **Copy:** Concrete examples of when notifications fire
- **CTA:** Primary button triggers system permission dialog
- **Secondary:** "Not now" is text link, doesn't block progress

### Phase 2: Verification (Conditional)

Only shown if role requires verification (Hustler or Dual).

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                       [Shield Icon]                            │
│                                                                 │
│                  Verify your identity                          │
│                                                                 │
│                                                                 │
│     To complete tasks and receive payments, we need to         │
│     verify your identity. This takes about 2 minutes.          │
│                                                                 │
│                                                                 │
│     You'll need:                                                │
│     ✓ A valid government ID (driver's license or passport)     │
│     ✓ A selfie for face matching                               │
│                                                                 │
│                                                                 │
│                   [ Start Verification ]                       │
│                                                                 │
│                    I'll do this later                           │
│                                                                 │
│                                                                 │
│     🔒 Your data is encrypted and only used for verification.  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Skip allowed:** Yes, but limits task acceptance
- **Provider:** Stripe Identity or similar
- **Time estimate:** Accurate ("about 2 minutes")
- **Requirements:** Listed clearly before starting

### Phase 2B: Legal Acceptance

**Authority:** LEGAL_FRAMEWORK_SPEC, PRODUCT_SPEC §25, TAX_REPORTING_SPEC

#### Screen 2B.1: Legal Documents Acceptance

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                  Almost there!                                 │
│                                                                 │
│          Before you start, please review and                   │
│          accept the following:                                 │
│                                                                 │
│          ☐  Terms of Service →                                 │
│          ☐  Privacy Policy →                                   │
│          ☐  Independent Contractor Agreement →                 │
│             (workers only — shown conditionally)               │
│                                                                 │
│          By continuing, you agree to these terms.              │
│                                                                 │
│          ┌───────────────────────────────────┐                 │
│          │       Accept & Continue            │                 │
│          └───────────────────────────────────┘                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Each document link** opens a full-screen scrollable view of the document
- **Checkboxes** are required — user must tap each to enable the Accept button
- **IC Agreement** shown ONLY if user's inferred role includes worker (Hustler or Dual)
- **Version tracking:** `user_consents` table records document versions accepted
- **Re-consent:** If documents update post-signup, user is prompted on next app open
- **Not skippable:** Account cannot proceed without acceptance
- **W-9 note for workers:** After acceptance, Stripe Connect onboarding (Phase 2) collects tax information. W-9 data flows through Stripe Connect's identity verification.
- **Cross-reference:** LEGAL_FRAMEWORK_SPEC §2, TAX_REPORTING_SPEC §2

### Phase 3: Role Lock Confirmation

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                                                                 │
│                   You're set up as a                           │
│                                                                 │
│                        HUSTLER                                 │
│                  (Task Completer)                              │
│                                                                 │
│                                                                 │
│     You can:                                                   │
│     ✓ Browse and accept tasks nearby                           │
│     ✓ Earn money for completed tasks                           │
│     ✓ Build your reputation and unlock badges                  │
│                                                                 │
│                                                                 │
│                                                                 │
│                   [ Let's Go ]                                  │
│                                                                 │
│             [ Change to Poster or Both ]                       │
│                                                                 │
│                                                                 │
│     You can switch roles anytime in Settings.                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Role display:** Large, clear text
- **Capabilities:** Bullet list of what they can do
- **Animation:** None (this is a confirmation, not a celebration)
- **Equal weight:** Both CTAs have equal visual weight
- **Note:** Role can be changed later

---

## 4. First Task Guided Walkthrough

### For Hustlers: First Task Discovery

#### Step 4.1: Task Feed Introduction

```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 1 of 3: Find Your First Task                            │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SPOTLIGHT OVERLAY                                      │   │
│  │  ↓ pointing to task card                                │   │
│  │                                                         │   │
│  │  This is a task card                                    │   │
│  │                                                         │   │
│  │  Each card shows:                                       │   │
│  │  • What needs to be done                                │   │
│  │  • How much you'll earn                                 │   │
│  │  • How far away it is                                   │   │
│  │                                                         │   │
│  │  Tap a card to see more details.                        │   │
│  │                                                         │   │
│  │  [ Got It ]                                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Help moving furniture              💰 $35              │   │
│  │  Sarah K. • 0.8 mi • Escrow funded                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Overlay style:** Semi-transparent dark with spotlight cutout
- **Progress:** Thin bar showing 1/3
- **Pointer:** Subtle arrow pointing to highlighted element
- **Dismiss:** "Got It" button advances to next step

#### Step 4.2: Task Detail Introduction

```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 2 of 3: Review Task Details                             │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SPOTLIGHT on escrow indicator                          │   │
│  │                                                         │   │
│  │  ✅ Escrow funded                                       │   │
│  │                                                         │   │
│  │  This means the poster has already deposited            │   │
│  │  the payment. You're guaranteed to be paid              │   │
│  │  when you complete the task.                            │   │
│  │                                                         │   │
│  │  [ Got It ]                                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Help moving furniture                                          │
│  Sarah K. • VERIFIED                                            │
│                                                                 │
│  💰 $35.00 (you receive ~$29.75)                               │
│  📍 0.8 miles away                                              │
│  ✅ Escrow: FUNDED ← SPOTLIGHT HERE                            │
│                                                                 │
│  [ Accept Task ]                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Step 4.3: Accept Your First Task

```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 3 of 3: Accept a Task                                   │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SPOTLIGHT on Accept button                             │   │
│  │                                                         │   │
│  │  Ready to go?                                           │   │
│  │                                                         │   │
│  │  Tap "Accept Task" to claim this job.                   │   │
│  │  You'll be connected with the poster                    │   │
│  │  and can start right away.                              │   │
│  │                                                         │   │
│  │  [ Accept Task ] ← Tap to continue                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Help moving furniture                                          │
│  Sarah K. • VERIFIED                                            │
│                                                                 │
│  💰 $35.00 (you receive ~$29.75)                               │
│  📍 0.8 miles away                                              │
│  ✅ Escrow: FUNDED                                             │
│                                                                 │
│  [ Accept Task ] ← SPOTLIGHT HERE                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### For Posters: First Task Creation

#### Step 4.1: Post Task Introduction

```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 1 of 3: Post Your First Task                            │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SPOTLIGHT on Post Task button                          │   │
│  │                                                         │   │
│  │  Let's post your first task                             │   │
│  │                                                         │   │
│  │  Describe what you need done, set a price,              │   │
│  │  and we'll connect you with help nearby.                │   │
│  │                                                         │   │
│  │  [ Post a Task ] ← Tap to continue                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │             No tasks posted yet                           │ │
│  │                                                           │ │
│  │             [ Post a Task ] ← SPOTLIGHT                   │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Permission Request Flows

### Permission Request Pattern

All permission requests follow this pattern:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                        [Relevant Icon]                         │
│                                                                 │
│                   [Clear benefit headline]                     │
│                                                                 │
│     [Explanation of why we need this]                          │
│     [How it helps the user specifically]                       │
│                                                                 │
│     [Privacy assurance in plain language]                      │
│                                                                 │
│                   [ Enable {Permission} ]                      │
│                                                                 │
│                    {Skip option}                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Permission Types

| Permission | When Asked | Can Skip | Impact if Skipped |
|------------|------------|----------|-------------------|
| **Location** | Phase 1 | Yes | Limited task visibility |
| **Notifications** | Phase 1 | Yes | No alerts for tasks/payments |
| **Camera** | During proof submission | Yes | Cannot submit photo proofs |
| **Photo Library** | During proof submission | Yes | Cannot upload existing photos |

### Re-prompt Pattern

If permission was denied, show contextual re-prompt when needed:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  To show tasks near you, we need location access.              │
│                                                                 │
│  [ Open Settings ]    [ Browse All Tasks ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Progress Indicators

### Progress Bar Style

```typescript
const OnboardingProgress = {
  height: 4,
  backgroundColor: colors.neutral[200],
  fillColor: colors.primary[500],
  borderRadius: radius.full,
  animation: {
    duration: 150,
    easing: easing.decelerate,
  },
};
```

### Progress Calculation

| Phase | Progress | Screens |
|-------|----------|---------|
| Phase 0: Welcome | 0% | 1 |
| Phase 1: Calibration | 10-30% | 3 |
| Phase 2: Verification | 40-50% | 1-2 |
| Phase 3: Role Lock | 60% | 1 |
| Phase 4: First Task | 70-100% | 3-5 |

### Step Indicator

For multi-step phases, show "X of Y" text:

```
← Back                                     2 of 3
```

---

## 7. Gamification Unlock Moment

### When Gamification Unlocks

Per UI_SPEC.md §2.4 and ONBOARDING_SPEC.md:

> Gamification (Layer 3) unlocks **only after first RELEASED escrow**.

### Pre-Unlock State (Hustler Dashboard)

```
┌─────────────────────────────────────────────────────────────────┐
│  HOME                                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  🔒 XP: 0                                               │   │
│  │     Level 1 • Locked                                    │   │
│  │     ░░░░░░░░░░░░░░░░░░░░                                │   │
│  │                                                         │   │
│  │     Complete your first task to unlock XP & badges      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  AVAILABLE TASKS                                                │
│  ...                                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### First Completion Celebration (Single-Use)

When first escrow is RELEASED:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                                                                 │
│                                                                 │
│                    First Task Complete!                        │
│                                                                 │
│                                                                 │
│                        +25 XP                                  │
│                    ████████░░░░░░░░░░                          │
│                                                                 │
│                                                                 │
│              You've unlocked the XP system!                    │
│              Complete more tasks to level up.                  │
│                                                                 │
│                                                                 │
│                   [ Continue ]                                  │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Animation Sequence (per UI_SPEC.md §12.4):**

| Time | Element |
|------|---------|
| 0-300ms | XP number fade in + scale 1.0→1.1→1.0 |
| 300-800ms | Progress bar linear fill |
| 800-1200ms | "First Task Complete!" fade in |
| 1200-1800ms | Badge unlock (if earned) |
| 1800-2000ms | Settle to static |

**Constraints:**
- No confetti (forbidden per UI_SPEC.md M2)
- Single sound effect (see SOUND_DESIGN.md)
- Single haptic pulse
- Server-tracked: `xp_first_celebration_shown_at`
- **Never replays** (even on reinstall)

---

## 8. Error Handling

### Validation Errors

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  Task description                                               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Help with                                                │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ⚠️ Task description must be at least 10 characters           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Specifications:**
- **Timing:** Show on blur, not on every keystroke
- **Position:** Directly below the input
- **Color:** Warning amber, not error red (less harsh)
- **Icon:** Warning icon, not X (less punitive)

### Network Errors

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                       [Cloud-off Icon]                         │
│                                                                 │
│                 Couldn't connect to server                     │
│                                                                 │
│     Check your internet connection and try again.              │
│                                                                 │
│                   [ Try Again ]                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Verification Failed

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                       [Alert Icon]                             │
│                                                                 │
│              Verification couldn't be completed                │
│                                                                 │
│     WHAT HAPPENED                                              │
│     The photo of your ID wasn't clear enough.                  │
│                                                                 │
│     WHAT YOU CAN DO                                            │
│     • Take a new photo in good lighting                        │
│     • Make sure all text is readable                           │
│     • Avoid glare and shadows                                  │
│                                                                 │
│                   [ Try Again ]                                 │
│                    Skip for now                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. Invariants

### Onboarding Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **ONB-UI-1** | No XP colors during onboarding (Phase 0-3) | UI component guard |
| **ONB-UI-2** | No celebrations until Phase 4 completion | Animation guard |
| **ONB-UI-3** | Progress bar always visible (Phase 1+) | UI layout |
| **ONB-UI-4** | Back button always available (except Phase 0) | Navigation guard |
| **ONB-UI-5** | Skip options don't block progress | Flow logic |
| **ONB-UI-6** | First celebration plays exactly once | Server flag check |
| **ONB-UI-7** | Guided walkthrough cannot be dismissed until complete | UI state |

### ESLint Rules

```typescript
// no-xp-during-onboarding
// Error: XP-related components forbidden during onboarding phases

// no-celebration-before-unlock
// Error: Celebration animations forbidden before first RELEASED escrow

// require-onboarding-progress
// Error: Onboarding screens must include progress indicator
```

---

## Mock Data for Onboarding

### First Task (Demo/Seed)

```typescript
const ONBOARDING_DEMO_TASK = {
  id: 'onboarding-demo-001',
  title: 'Help moving furniture',
  description: 'Need help moving a couch from my apartment to a storage unit. About 30 minutes of work.',
  price: 35.00,
  poster: {
    name: 'Sarah K.',
    trust_tier: 2, // VERIFIED
    tasks_posted: 12,
    disputes: 0,
  },
  escrow_state: 'FUNDED',
  location: {
    distance_miles: 0.8,
    city: 'Your City', // Dynamic based on user location
  },
};
```

---

## 10. Role-Specific Onboarding Content

### 10.1 Poster vs Hustler Messaging

Both roles go through the same phases, but messaging differs:

| Phase | Hustler Content | Poster Content |
|-------|-----------------|----------------|
| **Welcome** | "Get paid for tasks nearby" | "Get things done in minutes" |
| **Calibration** | "Earn money your way" | "Hire help your way" |
| **Verification** | Required for earning | Not required |
| **Role Lock** | "You're ready to earn!" | "You're ready to post!" |
| **First Action** | Browse/accept tasks | Post first task |

### 10.2 Poster Onboarding Flow (Full)

#### Phase 1.1: What brings you here? (Poster Path)

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     1 of 3             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│               What brings you to HustleXP?                     │
│                                                                 │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  ✓  I need help getting things done              SELECTED │ │
│  │      Post tasks and hire local help                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│                         ↓                                       │
│                                                                 │
│  What kinds of tasks do you need help with?                    │
│                                                                 │
│  [ ] Moving & delivery                                          │
│  [ ] Cleaning                                                   │
│  [ ] Errands & shopping                                         │
│  [ ] Assembly & repairs                                         │
│  [ ] Other                                                      │
│                                                                 │
│                   [ Continue ]                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Phase 1.2: Payment Setup (Poster Only)

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     2 of 3             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                       [Card Icon]                              │
│                                                                 │
│                  Add a payment method                          │
│                                                                 │
│                                                                 │
│     To post tasks, you'll need a payment method on file.       │
│     Payments are held in escrow until tasks are complete.      │
│                                                                 │
│                                                                 │
│     🔒 Your payment info is secured with bank-level            │
│        encryption. We never see your full card number.         │
│                                                                 │
│                                                                 │
│                   [ Add Payment Method ]                       │
│                                                                 │
│                    I'll do this later                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Note:** Poster can skip payment setup during onboarding but will be prompted when posting first task.

#### Phase 3: Role Lock (Poster Version)

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                                                                 │
│                   You're set up as a                           │
│                                                                 │
│                        POSTER                                  │
│                  (Task Creator)                                │
│                                                                 │
│                                                                 │
│     You can:                                                   │
│     ✓ Post tasks and get help nearby                           │
│     ✓ Pay securely through escrow                              │
│     ✓ Rate and review hustlers                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                   [ Let's Go ]                                  │
│                                                                 │
│             [ Change to Hustler or Both ]                      │
│                                                                 │
│                                                                 │
│     You can switch roles anytime in Settings.                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Phase 4: First Task Creation (Poster Walkthrough)

**Step 1: Empty State**
```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 1 of 3: Post Your First Task                            │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SPOTLIGHT                                              │   │
│  │                                                         │   │
│  │  Post your first task                                   │   │
│  │                                                         │   │
│  │  Describe what you need, set a price, and              │   │
│  │  we'll connect you with trusted help nearby.            │   │
│  │                                                         │   │
│  │  [ Post a Task ]                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                                                                 │
│  YOUR TASKS                                                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │             No tasks yet                                  │ │
│  │             Post a task to get started                    │ │
│  │                                                           │ │
│  │             [ + Post a Task ] ← SPOTLIGHT                 │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Step 2: Task Form**
```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 2 of 3: Describe Your Task                              │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  WHAT DO YOU NEED DONE?                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │  ← SPOTLIGHT: "Be specific about what you need"          │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  SET A PRICE                                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  $ [    ]                                                 │ │
│  │                                                           │ │
│  │  💡 AI suggests $25-40 for tasks like this               │ │
│  │  ← SPOTLIGHT: "Set a fair price to attract help"         │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ESCROW PROTECTION                                              │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  🔒 Your payment is protected                             │ │
│  │     Money is only released when you're satisfied          │ │
│  │     ← SPOTLIGHT: "Your money is protected"                │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│                   [ Post Task ]                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Task Posted Confirmation**
```
┌─────────────────────────────────────────────────────────────────┐
│  ══════════════════════════════════════════════════════════════ │
│  Step 3 of 3: You're All Set!                                 │
│  ══════════════════════════════════════════════════════════════ │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ✓                                      │
│                                                                 │
│                   Task Posted!                                  │
│                                                                 │
│  Help moving furniture • $35                                    │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  WHAT HAPPENS NEXT                                              │
│                                                                 │
│  1. Hustlers nearby will see your task                          │
│  2. Someone will accept and head your way                       │
│  3. You'll be notified when they arrive                        │
│  4. Review their work and release payment                       │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  We'll notify you when someone accepts.                        │
│  Average wait time: 5-15 minutes                               │
│                                                                 │
│                   [ Done ]                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 10.3 Poster Onboarding Differences

| Aspect | Hustler | Poster |
|--------|---------|--------|
| **Verification required** | Yes (ID + selfie) | No |
| **Payment method** | Receive (bank/Stripe) | Pay (card) |
| **First action** | Accept a task | Post a task |
| **XP preview** | Yes ("+25 XP on completion") | No XP shown |
| **Gamification mention** | "Unlock badges and level up" | Not mentioned |
| **Trust tier preview** | Yes ("Start at ROOKIE") | Not shown |
| **Post-onboarding screen** | Task feed | Empty dashboard |

### 10.4 Poster Visual Rules During Onboarding

| Element | Allowed | Rationale |
|---------|---------|-----------|
| XP colors | **No** | Posters don't earn XP |
| Badge previews | **No** | Posters don't earn badges |
| Trust tier | **No** | Poster tiers not gamified |
| Escrow explanation | **Yes** | Critical for trust |
| Payment setup | **Yes** | Required functionality |
| AI suggestions | **Yes** | Helps with pricing |

### 10.5 Poster Onboarding Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **ONB-POSTER-1** | No XP mentions in Poster onboarding | Copy guard |
| **ONB-POSTER-2** | No badge mentions in Poster onboarding | Copy guard |
| **ONB-POSTER-3** | Escrow explanation must appear before payment | Flow guard |
| **ONB-POSTER-4** | Payment method skippable but prompted at first task | Flow logic |
| **ONB-POSTER-5** | No celebration animations for Poster | Animation guard |

---

## Cross-Reference

| Section | Reference |
|---------|-----------|
| Business Logic | ONBOARDING_SPEC.md |
| Poster UI Spec | POSTER_UI_SPEC.md |
| Hustler UI Spec | HUSTLER_UI_SPEC.md |
| Visual Rules | UI_SPEC.md §12 |
| Layered Hierarchy | UI_SPEC.md §2 |
| First XP Animation | UI_SPEC.md §12.4 |
| Sound Design | SOUND_DESIGN.md |
| Mock Data | mock-data/tasks.js |

---

**END OF ONBOARDING_FLOW.md v1.0.0**
