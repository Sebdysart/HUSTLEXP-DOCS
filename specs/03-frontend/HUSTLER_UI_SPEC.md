# HustleXP Hustler UI Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** HustleXP Core
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All Hustler-facing UI must follow this spec. Violations are build failures.

---

## Overview

The Hustler UI uses **all three layers** of the Layered Influence Hierarchy — but **stacked, not blended**.

> **Core Principle:** Hustlers are earning money and building reputation. The UI should feel like a **professional achievement system** — serious status earned through work, not a casual game.

**Apple Glass is always the foundation. Duolingo adds polish. COD/Clash adds earned status.**

---

## §1. Design Philosophy

### 1.1 Three-Layer Stack

Hustler UI uses all layers from the Layered Influence Hierarchy:

| Layer | Hustler Access | Domain |
|-------|----------------|--------|
| **Layer 1: Apple Glass** | ✅ Always | Structure, layout, trust |
| **Layer 2: Duolingo** | ✅ Conditional | Micro-feedback, transitions |
| **Layer 3: COD/Clash** | ✅ Earned | Status, badges, achievements |

### 1.2 Layer Domains

Each layer has specific areas where it applies:

| Domain | Layer | Examples |
|--------|-------|----------|
| **Structure** | Apple Glass | Navigation, cards, forms |
| **Typography** | Apple Glass | Clean, professional text |
| **Spacing** | Apple Glass | Generous whitespace |
| **State transitions** | Duolingo | 150ms micro-feedback |
| **Button feedback** | Duolingo | Press → release animation |
| **XP displays** | COD/Clash | Rings, counters, progress |
| **Badges** | COD/Clash | Material-based, permanent |
| **Trust tiers** | COD/Clash | Earned status markers |
| **Celebrations** | COD/Clash | First-time only, server-tracked |

### 1.3 Pre-Unlock vs Post-Unlock

Hustler UI has two states based on economic truth:

**Pre-Unlock (Before First RELEASED Escrow):**
- Layer 1: ✅ Apple Glass (full)
- Layer 2: ✅ Duolingo (micro-feedback only)
- Layer 3: ❌ Locked (visible but grayed out)

**Post-Unlock (After First RELEASED Escrow):**
- Layer 1: ✅ Apple Glass (full)
- Layer 2: ✅ Duolingo (full)
- Layer 3: ✅ COD/Clash (full)

---

## §2. Hustler Screens

### 2.1 Screen Inventory

| Screen | Purpose | Key Elements |
|--------|---------|--------------|
| **Home Dashboard** | XP hub + task discovery | XP ring, stats, live tasks |
| **Task Feed** | Browse available tasks | Task cards, filters |
| **Task Detail** | View & accept task | Task info, escrow, accept |
| **Task In Progress** | Active task management | Status, timer, proof submit |
| **Task Complete** | Celebration + XP | XP earned, badge unlock |
| **Live Mode** | Instant task mode | Toggle, session stats |
| **Profile** | Achievements & stats | XP, badges, trust tier |
| **Wallet** | Earnings management | Balance, withdrawals |
| **Messages** | Task communication | Chat threads |

### 2.2 Home Dashboard

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                    🔔    [Profile]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌─────────────────┐                         │
│                    │                 │                         │
│                    │    2,847 XP     │  ← XP Ring              │
│                    │                 │     (Layer 3)           │
│                    │   ██████████░░░ │                         │
│                    │                 │                         │
│                    └─────────────────┘                         │
│                                                                 │
│           [ TIER 2 — VERIFIED ]  ← Trust Badge (Layer 3)       │
│           47 tasks • $4,231 earned                              │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  🔥 7-DAY STREAK                    ← Streak (Layer 3)         │
│     Keep it going!                                              │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  TODAY                                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  💰 $127.50 earned                                      │   │
│  │     3 tasks completed                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ⚡ LIVE MODE                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  [ ● ACTIVE ]                                           │   │
│  │  You'll see urgent tasks first                          │   │
│  │  Session: 47 min • 2 tasks • $52                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  NEARBY TASKS                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Help moving furniture              $35 • 0.8 mi       │   │
│  │  Sarah K. • VERIFIED • Escrow funded                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│  [Home]        [Tasks]        [Messages]        [Wallet]       │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- XP Ring prominent (Layer 3, earned status)
- Trust tier badge below XP (Layer 3)
- Streak indicator (Layer 3)
- Today's earnings (Layer 1 + 2)
- Live Mode toggle (Layer 2)
- Task cards (Layer 1)

### 2.3 Task Feed

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                      Available Tasks   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [ All ] [ Nearby ] [ Best Match ] [ Live 🔴 ]  ← Filters      │
│                                                                 │
│  🔴 LIVE TASKS                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  🔴 LIVE                                                │   │
│  │  Help moving furniture              $35 • 0.8 mi       │   │
│  │  Sarah K. • VERIFIED                                    │   │
│  │  ✅ Escrow funded                                       │   │
│  │                                            [ Accept ]   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  STANDARD TASKS                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Grocery pickup                     $25 • 1.2 mi       │   │
│  │  Mike R. • TRUSTED                                      │   │
│  │  ✅ Escrow funded                                       │   │
│  │                                            [ View ]     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Dog walking                        $20 • 0.5 mi       │   │
│  │  Lisa T. • VERIFIED                                     │   │
│  │  ✅ Escrow funded                                       │   │
│  │                                            [ View ]     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Live tasks highlighted with red badge
- Escrow state always visible (trust signal)
- Poster trust tier visible
- Distance and price prominent
- Quick accept for Live tasks

### 2.4 Task Detail (Pre-Accept)

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                        Task Details    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔴 LIVE TASK                                                   │
│                                                                 │
│  Help moving furniture                                          │
│  Need help moving a couch from apartment to storage unit.       │
│  About 30 minutes of work.                                      │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  PAYMENT                                                        │
│  💰 $35.00 total                                               │
│     You receive: ~$29.75 (after 15% fee)                       │
│     ✅ Escrow: FUNDED                                          │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  LOCATION                                                       │
│  📍 0.8 miles away                                              │
│     Downtown • 123 Main St                                      │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  POSTER                                                         │
│  Sarah K. • ⭐ VERIFIED                                        │
│  12 tasks posted • 0 disputes                                   │
│  Avg response: 2h • Hustlers rate: 😊 Great                    │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  XP REWARD                                                      │
│  +25 XP on completion                                           │
│                                                                 │
│                                                                 │
│                   [ Accept Task ]                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Live badge if applicable
- Clear payment breakdown
- Escrow state prominent (FUNDED = safe)
- Poster reputation visible (Layer 1 trust)
- XP reward preview (Layer 3)
- Single accept action

### 2.5 Task In Progress

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                      In Progress       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ● ──────── ● ──────── ◐ ──────── ○ ──────── ○                 │
│  Posted    Accepted   In Progress  Proof    Complete            │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Help moving furniture                                          │
│  Sarah K. • VERIFIED                                            │
│                                                                 │
│  TIME ACTIVE                                                    │
│  ⏱️ 23 minutes                                                  │
│                                                                 │
│  LOCATION                                                       │
│  📍 123 Main St, Apt 4B                                        │
│                                                                 │
│  [ Navigate ]     [ Message Sarah ]                            │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  READY TO SUBMIT PROOF?                                         │
│                                                                 │
│  Take photos of the completed task.                             │
│  The poster will review and release payment.                    │
│                                                                 │
│                   [ Submit Proof ]                              │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  PAYMENT ON COMPLETION                                          │
│  $29.75 + 25 XP                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Status breadcrumb at top (Layer 2)
- Active timer
- Quick actions: Navigate, Message
- Clear proof submission CTA
- Payment + XP reward visible

### 2.6 Task Complete (Celebration)

```
┌─────────────────────────────────────────────────────────────────┐
│                                              Task Complete      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ✓                                      │
│                                                                 │
│                   Task Completed!                               │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│                       +$29.75                                   │
│                    Payment received                             │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│                        +25 XP                                   │
│                                                                 │
│                    ██████████████░░░                            │
│                    2,847 → 2,872 XP                             │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  🔥 STREAK: 8 DAYS                                              │
│     +1 day added!                                               │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  🏆 BADGE UNLOCKED                                              │
│     "Early Bird" — Complete 5 tasks before 8am                  │
│     [ View Badge ]                                              │
│                                                                 │
│                                                                 │
│                   [ Continue ]                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Checkmark confirmation (Layer 1)
- Payment amount prominent
- XP earned with progress bar animation (Layer 3)
- Streak update (Layer 3)
- Badge unlock if applicable (Layer 3, first-time only)
- Single continue action
- **Animation sequence per DESIGN_SYSTEM.md §11**

### 2.7 Profile Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back                                           Profile      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌─────────────────┐                         │
│                    │                 │                         │
│                    │    [Avatar]     │                         │
│                    │                 │                         │
│                    └─────────────────┘                         │
│                                                                 │
│                        Marcus J.                                │
│                   [ TIER 2 — VERIFIED ]                        │
│                   Member since Jan 2024                         │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  XP PROGRESS                                                    │
│                    ┌─────────────────┐                         │
│                    │    2,847 XP     │                         │
│                    │   ██████████░░░ │                         │
│                    │  353 to Tier 3  │                         │
│                    └─────────────────┘                         │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  STATS                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │    47       │  │  $4,231     │  │    98%      │            │
│  │   Tasks     │  │  Earned     │  │ Completion  │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  BADGES (12)                                                    │
│  [ 🏆 ] [ 🏆 ] [ 🏆 ] [ 🏆 ] [ 🔒 ] [ 🔒 ]  [ See All → ]     │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  STREAK                                                         │
│  🔥 8 days current • 23 days best                              │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  YOUR STANDING (Private)                                        │
│  Reliability: Top 12%                                           │
│  Response Time: Top 25%                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rules:**
- Avatar and name (Layer 1)
- Trust tier badge prominent (Layer 3)
- XP ring with progress (Layer 3)
- Stats grid (Layer 1)
- Badge collection (Layer 3, earned only)
- Streak display (Layer 3)
- Private percentile (Layer 3, never public)

---

## §3. Hustler Color Palette

### 3.1 Base Colors (Apple Glass)

| Token | Value | Usage |
|-------|-------|-------|
| `hustler.background` | `#000000` | Screen background |
| `hustler.surface` | `#1C1C1E` | Card background |
| `hustler.text.primary` | `#FFFFFF` | Main text |
| `hustler.text.secondary` | `#8E8E93` | Subtext |

### 3.2 Gamification Colors (Layer 3)

| Token | Value | Usage |
|-------|-------|-------|
| `hustler.xp` | `#FF9500` | XP ring, counters (Apple orange) |
| `hustler.streak` | `#FF9500` | Streak fire icon (Apple orange) |
| `hustler.badge.matte` | `#71717A` | Tier 1 badges (Zinc 500) |
| `hustler.badge.metallic` | `#007AFF` | Tier 2 badges (Apple blue) |
| `hustler.badge.holographic` | Gradient | Tier 3 badges |
| `hustler.badge.obsidian` | `#1F2937` | Tier 4 badges |

### 3.3 Trust Tier Colors

| Tier | Color | Badge Color |
|------|-------|-------------|
| 1 (ROOKIE) | `#6B7280` | Gray |
| 2 (VERIFIED) | `#3B82F6` | Blue |
| 3 (TRUSTED) | `#10B981` | Green |
| 4 (ELITE) | `#F59E0B` | Gold |

### 3.4 State Colors

| Token | Value | Usage |
|-------|-------|-------|
| `hustler.success` | `#10B981` | Payment, completion |
| `hustler.live` | `#EF4444` | Live mode indicator |
| `hustler.warning` | `#F59E0B` | Attention needed |
| `hustler.info` | `#3B82F6` | Informational |

---

## §4. Hustler Animations

### 4.1 Layer 2 (Duolingo) Animations

| Animation | Duration | Trigger |
|-----------|----------|---------|
| **Button press** | 100ms | On press |
| **Card tap** | 150ms | On press |
| **Toggle** | 200ms | On change |
| **State transition** | 150ms | On state change |
| **Pull refresh** | 300ms | On release |

### 4.2 Layer 3 (COD/Clash) Animations

| Animation | Duration | Trigger | First-Time |
|-----------|----------|---------|------------|
| **XP count-up** | 800ms | Task complete | No |
| **Progress bar fill** | 500ms | XP awarded | No |
| **Badge unlock** | 1500ms | Badge earned | **Yes** |
| **Level up** | 1800ms | Level threshold | **Yes** |
| **Payment arrival** | 1200ms | Escrow released | No |
| **Streak milestone** | 1500ms | 7/30/100/365 days | **Yes** |

### 4.3 First-Time Animation Rules

Celebration animations marked **"First-Time: Yes"** play exactly once per achievement:

- Server tracks via `animation_shown_at` field
- Client checks flag before animating
- Client confirms animation played
- Never repeats (even on reinstall)

---

## §5. Hustler Sounds

### 5.1 Layer 2 (Micro-Feedback) Sounds

| Sound | Trigger | Duration |
|-------|---------|----------|
| `ui_tap_confirm` | Button press | 80ms |
| `ui_toggle` | Toggle change | 60ms |
| `task_accepted` | Task accepted | 400ms |
| `proof_submitted` | Proof sent | 300ms |

### 5.2 Layer 3 (Celebration) Sounds

| Sound | Trigger | Duration | First-Time |
|-------|---------|----------|------------|
| `celebration_first_task` | First RELEASED | 2000ms | **Yes** |
| `celebration_badge_unlock` | Badge earned | 1200ms | **Yes** |
| `celebration_level_up` | Level up | 1500ms | **Yes** |
| `money_incoming` | Payment received | 600ms | No |
| `streak_milestone` | 7/30/100/365 | 1500ms | **Yes** |
| `xp_count_tick` | XP counting | 20ms/tick | No |

---

## §6. Hustler Haptics

### 6.1 Layer 2 (Micro-Feedback) Haptics

| Action | Haptic |
|--------|--------|
| Button tap | Medium impact |
| Toggle | Light impact |
| Swipe action | Soft impact |
| Pull refresh | Light impact |

### 6.2 Layer 3 (Celebration) Haptics

| Action | Pattern |
|--------|---------|
| Task complete | Success + Success (double) |
| Payment received | Success + Heavy |
| Badge unlock | Success + Medium + Light (triple) |
| Level up | Success x3 (sequence) |
| Streak milestone | Success + Medium + Light |

---

## §7. Hustler Notifications

### 7.1 High Priority

| Type | Template |
|------|----------|
| **LIVE_TASK** | "🔴 LIVE TASK nearby — $35 • 0.8 mi" |
| **PAYMENT_RECEIVED** | "💰 You earned $29.75" |
| **TASK_ACCEPTED** | "✓ Task accepted — Head to location" |

### 7.2 Medium Priority

| Type | Template |
|------|----------|
| **PROOF_APPROVED** | "Proof approved — Payment releasing" |
| **MESSAGE** | "💬 New message from {poster}" |
| **BADGE_UNLOCKED** | "🏆 Badge Unlocked: {badge_name}" |

### 7.3 Low Priority

| Type | Template |
|------|----------|
| **STREAK_REMINDER** | "Complete a task to keep your streak!" |
| **LEVEL_UP** | "🎉 Level up! You're now Level {n}" |

---

## §8. Hustler Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **HUSTLER-1** | Layer 3 locked until first RELEASED | Backend flag |
| **HUSTLER-2** | First-time animations play once only | Server flag |
| **HUSTLER-3** | XP is server-authoritative | Backend calculation |
| **HUSTLER-4** | Badges cannot be revoked | DB constraint |
| **HUSTLER-5** | Streak state is server-authoritative | Backend calculation |
| **HUSTLER-6** | Percentile is private (never public) | API guard |
| **HUSTLER-7** | Celebrations respect reduced motion | Accessibility check |
| **HUSTLER-8** | Sounds respect user settings | Platform API |

---

## §9. Pre-Unlock State

Before first RELEASED escrow, Hustler UI shows locked gamification:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌─────────────────┐                         │
│                    │                 │                         │
│                    │    🔒 0 XP      │  ← Locked state         │
│                    │                 │                         │
│                    │   ░░░░░░░░░░░░░ │                         │
│                    │                 │                         │
│                    └─────────────────┘                         │
│                                                                 │
│           [ TIER 1 — ROOKIE ]                                  │
│           Complete your first task to unlock XP                 │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  🔒 STREAK                                                      │
│     Unlocks after first task                                    │
│                                                                 │
│  🔒 BADGES                                                      │
│     [ 🔒 ] [ 🔒 ] [ 🔒 ]                                        │
│     Earn badges by completing tasks                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pre-Unlock Rules:**
- XP ring visible but empty (0 XP)
- Progress bar empty
- Trust tier shows "ROOKIE"
- "Unlocks after first task" messaging
- Badges show as locked silhouettes
- Streak shows as locked
- No celebration animations possible

---

## Cross-Reference

| Section | Reference |
|---------|-----------|
| Layered Hierarchy | UI_SPEC.md §2 |
| Celebration Tokens | DESIGN_SYSTEM.md §11 |
| Sound Design | SOUND_DESIGN.md |
| Haptic Patterns | UI_SPEC.md §20 |
| Notifications | NOTIFICATION_UX.md |
| XP System | PRODUCT_SPEC.md §5 |
| Trust Tiers | PRODUCT_SPEC.md §4 |

---

**END OF HUSTLER_UI_SPEC.md v1.0.0**
