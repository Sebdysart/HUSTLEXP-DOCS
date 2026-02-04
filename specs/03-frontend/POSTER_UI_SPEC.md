# HustleXP Poster UI Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** HustleXP Core
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All Poster-facing UI must follow this spec. Violations are build failures.
**Spatial Authority:** Worker location visibility on poster screens governed by SPATIAL_INTELLIGENCE_LOCKED.md §5 and INV-PRIVACY-2. Poster NEVER receives raw worker GPS at >100m.

---

## Overview

The Poster UI is **Apple Glass only**. No gamification. No celebrations. No XP.

> **Core Principle:** Posters are paying customers hiring help. They need to trust the platform with their money. The UI must feel like **infrastructure you trust with money** — not a game.

**If a Poster ever thinks "This feels like a game" — you failed.**

---

## §1. Design Philosophy

### 1.1 Apple Glass Only

Poster UI uses **only Layer 1** from the Layered Influence Hierarchy:

| Layer | Poster Access | Rationale |
|-------|---------------|-----------|
| **Layer 1: Apple Glass** | ✅ Always | Trust foundation |
| **Layer 2: Duolingo** | ❌ Never | No micro-feedback beyond essential |
| **Layer 3: COD/Clash** | ❌ Never | No gamification whatsoever |

### 1.2 Visual Characteristics

```
POSTER UI = Clean + Calm + Professional + Trustworthy
```

| Attribute | Specification |
|-----------|---------------|
| **Typography** | System fonts, clean hierarchy |
| **Colors** | Neutral palette, semantic colors only |
| **Animations** | Minimal — fades only, no celebrations |
| **Spacing** | Generous whitespace |
| **Tone** | Professional, precise, confident |

### 1.3 What Posters NEVER See

| Element | Reason |
|---------|--------|
| XP counters | Not relevant to their role |
| Level badges | Gamification element |
| Streak indicators | Gamification element |
| Progress rings | Gamification element |
| Celebration animations | Layer 3 forbidden |
| Confetti | Layer 3 forbidden |
| Achievement popups | Layer 3 forbidden |
| Leaderboards | Not relevant |
| Sound effects (celebratory) | Layer 2/3 forbidden |

---

## §2. Poster Screens

### 2.1 Screen Inventory

| Screen | Purpose | Key Elements |
|--------|---------|--------------|
| **Home/Dashboard** | Task management hub | Active tasks, pending actions |
| **Task Creation** | Post new task | Form, AI suggestions, escrow |
| **Task Detail** | Monitor task progress | Status, hustler info, actions |
| **Hustler On Way** | Graduated visibility (INV-PRIVACY-2) | ETA, proximity zone, hustler profile |
| **Proof Review** | Approve/dispute | Proof images, action buttons |
| **Task Complete** | Confirmation + rating | Summary, rating form |
| **Wallet** | Payment management | Balance, transactions, funding |
| **Messages** | Task communication | Chat thread |
| **Profile/Settings** | Account management | Personal info, preferences |

### 2.2 Home Dashboard

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          [Profile]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ACTIVE TASKS                                                   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Help moving furniture                                  │   │
│  │  Marcus • On the way • ETA 8 min                        │   │
│  │  $35.00 • Escrow funded                                 │   │
│  │                                            [ View ]     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Grocery pickup                                         │   │
│  │  Awaiting acceptance                                    │   │
│  │  $25.00 • Escrow funded                                 │   │
│  │                                            [ View ]     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  PENDING ACTIONS                                                │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ⚠️ Proof submitted — Review required                   │   │
│  │  Deep cleaning • Sarah submitted 2 photos              │   │
│  │                                    [ Review Now ]       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                                                                 │
│                   [ + Post a Task ]                            │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│  [Home]        [Tasks]        [Messages]        [Wallet]       │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- No XP or gamification elements
- Task cards show status, price, escrow state
- Pending actions prominently displayed
- Primary CTA: Post a Task
- Clean bottom navigation

### 2.3 Task Creation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Cancel                              Post a Task             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  WHAT DO YOU NEED DONE?                                        │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Help moving a couch to storage unit...                   │ │
│  │                                                           │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  💡 AI Suggestion: "Moving help - heavy furniture"             │
│     Typical price: $30-50                                       │
│                                                                 │
│  CATEGORY                                                       │
│  [ Moving & Delivery ▼ ]                                       │
│                                                                 │
│  PRICE                                                          │
│  [ $35.00 ]                                                     │
│                                                                 │
│  LOCATION                                                       │
│  [ 📍 123 Main St, Apt 4B ]                                    │
│                                                                 │
│  WHEN                                                           │
│  [ Now ] [ Schedule ▼ ]                                        │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  ESCROW REQUIRED                                                │
│  $35.00 will be held in escrow until task completion.          │
│  You're protected if the task isn't completed.                  │
│                                                                 │
│                   [ Post Task — $35.00 ]                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- AI assistance is helpful, not playful
- Clear price and escrow explanation
- No urgency language
- Single primary action button
- Professional, form-focused layout

### 2.4 Hustler On the Way (DoorDash Moment)

### 2.4 Hustler On The Way

**Authority:** SPATIAL_INTELLIGENCE_LOCKED.md §5, INV-PRIVACY-2

Worker location visibility graduates with proximity. Poster NEVER sees raw GPS coordinates until worker is within 100m. Server transmits `PosterVisibleLocation` objects — never `{lat, lng}`.

**State 1: >0.5mi (ETA + Direction Only)**
```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     Help moving...     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │                      [MAP]                                │ │
│  │                                                           │ │
│  │             📍 Your location                              │ │
│  │                                                           │ │
│  │      ← Heading your way (no worker pin shown)             │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  🟢 HUSTLER ON THE WAY                                    │ │
│  │                                                           │ │
│  │  Marcus • ⭐ VERIFIED • 47 tasks completed                │ │
│  │                                                           │ │
│  │  ETA: ~12 minutes • Heading your way                      │ │
│  │                                                           │ │
│  │  [ Contact via HustleXP ]                                 │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  TASK DETAILS                                                   │
│  Help moving furniture • $35.00 • Escrow: FUNDED ✓             │
└─────────────────────────────────────────────────────────────────┘
```

**State 2: ≤0.5mi (Approximate Zone)**
```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                     Help moving...     │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │               ⬤ (200m radius zone)                        │ │
│  │              /                                            │ │
│  │             📍 Your location                              │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  🟢 ALMOST HERE                                           │ │
│  │  Marcus • ETA: ~3 minutes • 0.3 mi away                  │ │
│  │  [ Contact via HustleXP ]                                 │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**State 3: ≤100m (Precise Pin — Arrived)**
```
┌─────────────────────────────────────────────────────────────────┐
│  ┌───────────────────────────────────────────────────────────┐ │
│  │               ● Marcus (precise pin)                      │ │
│  │             📍 Your location                              │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  🟢 ARRIVED                                               │ │
│  │  Marcus is at the task location                           │ │
│  │  [ Contact via HustleXP ]                                 │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Privacy-graduated map per INV-PRIVACY-2 (SPATIAL_INTELLIGENCE §5)
- ETA + direction only at >0.5mi (NO worker pin, NO route line)
- 200m-radius approximate zone at ≤0.5mi (coordinates rounded to 200m grid)
- Precise worker pin ONLY at ≤100m (verified proximity)
- Server computes `PosterVisibleLocation` — client NEVER receives raw worker GPS at >100m
- P0 bug if raw coordinates leak to poster at any distance >100m
- Hustler profile with trust tier (for credibility)
- Contact is system-mediated ("Contact via HustleXP")
- Escrow confirmation visible

### 2.5 Proof Review Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                      Review Proof      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROOF SUBMITTED                                                │
│  Marcus submitted proof for "Help moving furniture"            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │              [Proof Photo 1]                              │ │
│  │               Full width                                   │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │              [Proof Photo 2]                              │ │
│  │               Full width                                   │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  HUSTLER NOTE                                                   │
│  "Couch delivered to storage unit B-12. Left key with          │
│   front desk as requested."                                    │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Was the task completed as described?                          │
│                                                                 │
│  [ Approve & Release Payment — $35.00 ]                        │
│                                                                 │
│  [ Report an Issue ]                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Proof images prominent and zoomable
- Hustler note visible
- Clear binary choice: Approve or Report
- No celebration on approval (just confirmation)
- Neutral, factual presentation

### 2.6 Task Complete (Poster View)

```
┌─────────────────────────────────────────────────────────────────┐
│                                              Task Complete      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ✓                                      │
│                                                                 │
│                   Task Completed                                │
│                                                                 │
│  Help moving furniture                                          │
│  Completed by Marcus                                            │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  PAYMENT                                                        │
│  $35.00 released to Marcus                                      │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  HOW WAS YOUR EXPERIENCE?                                       │
│                                                                 │
│  Rate Marcus:                                                   │
│  [ 😊 Great ]  [ 😐 Okay ]  [ 😕 Difficult ]                  │
│                                                                 │
│  Optional feedback:                                             │
│  [ ] On time                                                    │
│  [ ] Good communication                                         │
│  [ ] Task done well                                             │
│  [ ] Would hire again                                           │
│                                                                 │
│                   [ Submit & Done ]                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Simple checkmark (no celebration animation)
- Clear payment confirmation
- Simple rating UI (not gamified)
- Optional feedback tags
- Single action to complete

---

## §3. Poster Color Palette

### 3.1 Primary Colors

| Token | Value | Usage |
|-------|-------|-------|
| `poster.background` | `#FFFFFF` (light) / `#000000` (dark) | Screen background |
| `poster.surface` | `#F5F5F5` (light) / `#1C1C1E` (dark) | Card background |
| `poster.text.primary` | `#000000` (light) / `#FFFFFF` (dark) | Main text |
| `poster.text.secondary` | `#6B7280` | Subtext, labels |

### 3.2 Semantic Colors

| Token | Value | Usage |
|-------|-------|-------|
| `poster.success` | `#10B981` | Payment sent, task complete |
| `poster.warning` | `#F59E0B` | Action required, pending |
| `poster.error` | `#EF4444` | Issues, disputes |
| `poster.info` | `#3B82F6` | Informational, neutral |

### 3.3 Escrow State Colors

| State | Color | Usage |
|-------|-------|-------|
| `PENDING` | `poster.warning` | Awaiting funding |
| `FUNDED` | `poster.success` | Money secured |
| `RELEASED` | `poster.success` | Paid to hustler |
| `REFUNDED` | `poster.info` | Returned to poster |
| `DISPUTED` | `poster.error` | Under review |

---

## §4. Poster Typography

### 4.1 Type Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `poster.h1` | 28px | 700 | Screen titles |
| `poster.h2` | 22px | 600 | Section headers |
| `poster.h3` | 18px | 600 | Card titles |
| `poster.body` | 16px | 400 | Body text |
| `poster.caption` | 14px | 400 | Subtext, metadata |
| `poster.label` | 12px | 500 | Form labels, tags |

### 4.2 Typography Rules

- System fonts only (SF Pro / Roboto)
- No playful fonts
- No emojis in functional text (only status indicators)
- Clear hierarchy through weight, not decoration

---

## §5. Poster Animations

### 5.1 Allowed Animations

| Animation | Duration | Usage |
|-----------|----------|-------|
| **Fade in** | 200ms | Screen transitions |
| **Fade out** | 150ms | Dismissals |
| **Slide up** | 250ms | Modals, sheets |
| **Progress fill** | 300ms | Upload progress |

### 5.2 Forbidden Animations

| Animation | Reason |
|-----------|--------|
| **Confetti** | Gamification |
| **Bounce** | Playful, not professional |
| **Shake** | Aggressive |
| **Pulse** | Attention-grabbing |
| **Scale pop** | Celebration |
| **Infinite loops** | Distracting |

---

## §6. Poster Sounds

### 6.1 Allowed Sounds (Minimal)

| Sound | Trigger | Duration |
|-------|---------|----------|
| `poster_task_posted` | Task successfully posted | 200ms |
| `poster_hustler_accepted` | Hustler accepts task | 300ms |
| `poster_hustler_arrived` | Hustler reaches location | 250ms |
| `poster_proof_submitted` | Proof ready for review | 200ms |
| `poster_payment_sent` | Payment released | 300ms |
| `poster_message` | New message received | 150ms |

### 6.2 Sound Characteristics

- **Volume:** 30% (subtle, not intrusive)
- **Style:** Clean, professional tones
- **No celebration sounds**
- **No achievement sounds**

### 6.3 Forbidden Sounds

| Sound Type | Reason |
|------------|--------|
| Celebration fanfares | Gamification |
| Level up sounds | Gamification |
| Badge unlock sounds | Gamification |
| XP tick sounds | Gamification |
| Any looping sounds | Attention-hijacking |

---

## §7. Poster Haptics

### 7.1 Allowed Haptics

| Action | Haptic | Type |
|--------|--------|------|
| Button tap | Light | `UIImpactFeedbackGenerator(.light)` |
| Task posted | Success | `UINotificationFeedbackGenerator(.success)` |
| Payment released | Success | `UINotificationFeedbackGenerator(.success)` |
| Error | Error | `UINotificationFeedbackGenerator(.error)` |
| Toggle | Light | `UIImpactFeedbackGenerator(.light)` |

### 7.2 Forbidden Haptics

| Haptic Pattern | Reason |
|----------------|--------|
| Celebration sequences | Gamification |
| Multiple pulses | Over-stimulating |
| Heavy impacts | Aggressive |

---

## §8. Poster Notifications

### 8.1 Notification Types

| Type | Template | Priority |
|------|----------|----------|
| **HUSTLER_ACCEPTED** | "{name} accepted your task" | High |
| **HUSTLER_ARRIVED** | "{name} has arrived" | High |
| **PROOF_SUBMITTED** | "Proof submitted — review required" | High |
| **PAYMENT_SENT** | "Payment of {amount} sent to {name}" | High |
| **MESSAGE** | "New message from {name}" | Medium |
| **TASK_EXPIRED** | "Your task expired — no one accepted" | Medium |

### 8.2 Notification Style

- **Tone:** Professional, factual
- **No urgency language:** No "Hurry!", "Act now!"
- **No celebration:** No "🎉 Great news!"
- **Actions:** View, Message, Approve

---

## §9. Poster Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **POSTER-1** | Zero XP displays in Poster UI | Component guard |
| **POSTER-2** | Zero badges in Poster UI | Component guard |
| **POSTER-3** | Zero celebration animations | Animation guard |
| **POSTER-4** | Zero gamification sounds | Audio guard |
| **POSTER-5** | Escrow state always visible on task cards | UI component |
| **POSTER-6** | Hustler trust tier visible (for credibility) | UI component |
| **POSTER-7** | No streak indicators | Component guard |
| **POSTER-8** | No progress rings | Component guard |
| **POSTER-9** | Rating is for feedback, not XP | Backend guard |

---

## §10. Poster ESLint Rules

```typescript
// poster-no-gamification
// Error: "Gamification components forbidden in Poster UI"

const FORBIDDEN_POSTER_COMPONENTS = [
  'XPCounter',
  'XPRing',
  'LevelBadge',
  'StreakIndicator',
  'ProgressRing',
  'BadgeGrid',
  'CelebrationAnimation',
  'ConfettiEffect',
];

// poster-no-celebration-sounds
// Error: "Celebration sounds forbidden in Poster context"

const FORBIDDEN_POSTER_SOUNDS = [
  'celebration_',
  'level_up',
  'badge_unlock',
  'xp_',
  'streak_',
];
```

---

## Cross-Reference

| Section | Reference |
|---------|-----------|
| Layered Hierarchy | UI_SPEC.md §2 |
| Poster Sound Rules | SOUND_DESIGN.md §POSTER |
| Poster Notifications | NOTIFICATION_UX.md §POSTER |
| Task Flow | PRODUCT_SPEC.md §3 |
| Escrow States | PRODUCT_SPEC.md §6 |

---

**END OF POSTER_UI_SPEC.md v1.0.0**
