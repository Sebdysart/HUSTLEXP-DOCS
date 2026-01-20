# HustleXP Live Mode UI Specification v1.0.0

**STATUS: IMPLEMENTATION SPECIFICATION**
**Authority:** DESIGN_SYSTEM.md, API_CONTRACT.md §14 (Live Mode Endpoints)
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Table of Contents

1. [Overview](#overview)
2. [Live Mode Toggle](#live-mode-toggle)
3. [Active Session UI](#active-session-ui)
4. [Live Task Broadcast Card](#live-task-broadcast-card)
5. [Session Statistics](#session-statistics)
6. [States & Transitions](#states--transitions)

---

## 1. Overview

### What is Live Mode?

Live Mode allows hustlers to receive instant task broadcasts from nearby posters. When active, hustlers see time-sensitive tasks that require immediate acceptance.

### Design Principles

- **Layer 3 (Gamification)** — High energy, time pressure
- **Visual distinction** from standard feed
- **Clear session boundaries**
- **Fatigue protection** (automatic deactivation after extended use)

### Live Mode States

| State | Description | Visual Indicator |
|-------|-------------|------------------|
| `OFF` | Not receiving broadcasts | Gray toggle |
| `ACTIVE` | Receiving broadcasts | Pulsing green indicator |
| `COOLDOWN` | Temporary lockout | Orange countdown |
| `PAUSED` | User-initiated pause | Yellow indicator |

---

## 2. Live Mode Toggle

### 2.1 Toggle Button (Feed Header)

**Location:** Top of Hustler Feed, persistent

```
┌─────────────────────────────────────────┐
│  Tasks Near You               [LIVE ○]  │  ← OFF state
├─────────────────────────────────────────┤
│                                         │
│  [Standard feed content...]             │
│                                         │
└─────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────┐
│  Live Mode                    [LIVE ●]  │  ← ACTIVE state (pulsing)
├─────────────────────────────────────────┤
│                                         │
│  [Live task cards...]                   │
│                                         │
└─────────────────────────────────────────┘
```

### 2.2 Toggle Visual Spec

| State | Background | Icon | Animation |
|-------|------------|------|-----------|
| OFF | `colors.surface` | Circle outline | None |
| ACTIVE | `colors.success` | Filled circle | Pulse (1.2s loop) |
| COOLDOWN | `colors.warning` | Clock icon | Countdown number |
| PAUSED | `colors.warning` | Pause icon | None |

### 2.3 Props Interface

```typescript
interface LiveModeToggleProps {
  state: 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
  cooldownEndsAt?: string;      // ISO 8601, for countdown
  onToggle?: () => void;
  isLoading?: boolean;
}
```

---

## 3. Active Session UI

### 3.1 Session Header (Replaces Standard Header)

When Live Mode is active, the feed header transforms:

```
┌─────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐ │
│ │  ●  LIVE MODE ACTIVE                │ │  ← Green background, pulsing dot
│ │                                     │ │
│ │  Session: 24:32                     │ │  ← Time elapsed
│ │  Tasks: 3 accepted                  │ │  ← Session stats
│ │                                     │ │
│ │  [End Session]                      │ │  ← Secondary button
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
```

### 3.2 Session Header Props

```typescript
interface LiveSessionHeaderProps {
  isActive: boolean;
  sessionStartedAt: string;       // ISO 8601
  tasksAccepted: number;
  earningsThisSession: number;    // cents
  onEndSession?: () => void;
}
```

### 3.3 Session Header Visual Spec

| Element | Style |
|---------|-------|
| Container | `colors.success` background, `radius.lg` |
| "LIVE MODE ACTIVE" | `typography.headline`, white |
| Pulsing dot | 8px circle, white, pulse animation |
| Session time | `typography.body`, white/80% opacity |
| Stats | `typography.caption`, white/60% opacity |
| End button | Ghost style, white border |

---

## 4. Live Task Broadcast Card

### 4.1 Layout

Live task cards are visually distinct from standard task cards:

```
┌─────────────────────────────────────────┐
│ ⚡ LIVE TASK                    0:45 ⏱️ │  ← Countdown timer
├─────────────────────────────────────────┤
│                                         │
│  Move couch from apartment             │  ← Title
│  to storage unit                       │
│                                         │
│  📍 0.3 mi away                        │  ← Distance
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │            $75.00                   ││  ← Price, large
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │         ACCEPT NOW                  ││  ← Primary button, urgent
│  └─────────────────────────────────────┘│
│                                         │
│       Skip          Decline            │  ← Secondary actions
│                                         │
└─────────────────────────────────────────┘
```

### 4.2 Props Interface

```typescript
interface LiveTaskBroadcastCardProps {
  broadcast: {
    id: string;
    task: {
      id: string;
      title: string;
      description: string;
      price: number;          // cents
      category: string;
      location: string;
      distanceMiles: number;
    };
    expiresAt: string;        // ISO 8601
    broadcastedAt: string;    // ISO 8601
  };
  onAccept?: () => void;
  onDecline?: (reason?: string) => void;
  onSkip?: () => void;
  isAccepting?: boolean;
}
```

### 4.3 Visual Spec

| Element | Style |
|---------|-------|
| Container | `colors.surfaceElevated`, `radius.lg`, 2px `colors.primary` border |
| "LIVE TASK" badge | `colors.primary` background, white text, `typography.micro` |
| Lightning icon | `colors.primary`, 16px |
| Countdown timer | `typography.body`, `colors.warning` when < 30s |
| Title | `typography.title`, `textPrimary` |
| Distance | `typography.caption`, `textSecondary` |
| Price | 36px, `700` weight, `colors.success` |
| Accept button | `colors.primary`, full width, `typography.headline` |
| Skip/Decline | `typography.caption`, `textSecondary`, inline |

### 4.4 Countdown Behavior

| Time Remaining | Color | Animation |
|----------------|-------|-----------|
| > 30 seconds | `textSecondary` | None |
| 10-30 seconds | `colors.warning` | None |
| < 10 seconds | `colors.error` | Pulse |
| Expired | Card auto-dismisses | Fade out |

---

## 5. Session Statistics

### 5.1 End Session Summary

When hustler ends session or session auto-ends:

```
┌─────────────────────────────────────────┐
│                                         │
│            Session Complete             │  ← Title
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │  Duration          47 minutes       ││
│  │  Tasks Accepted    3                ││
│  │  Tasks Completed   2                ││
│  │  Earnings          $142.50          ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  Great session! You earned 23% more    │  ← Motivational copy (optional)
│  than your average.                    │
│                                         │
│     ┌─────────────────────────────────┐ │
│     │        Back to Feed             │ │
│     └─────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### 5.2 Props Interface

```typescript
interface SessionSummaryProps {
  session: {
    id: string;
    startedAt: string;
    endedAt: string;
    durationMinutes: number;
    tasksAccepted: number;
    tasksCompleted: number;
    tasksDeclined: number;
    earningsCents: number;
    endReason: 'MANUAL' | 'FATIGUE' | 'COOLDOWN';
  };
  comparison?: {
    percentVsAverage: number;   // e.g., 23 for "23% more"
  };
  onDismiss?: () => void;
}
```

---

## 6. States & Transitions

### 6.1 State Machine

```
┌─────────────────────────────────────────────────────┐
│                LIVE MODE STATE MACHINE               │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌───────┐                                          │
│  │  OFF  │◄──────────────────────────────┐          │
│  └───┬───┘                               │          │
│      │                                   │          │
│      │ onActivate                        │          │
│      │ (requires location)               │          │
│      ▼                                   │          │
│  ┌───────┐                               │          │
│  │ACTIVE │───── onDeactivate ────────────┤          │
│  └───┬───┘                               │          │
│      │                                   │          │
│      │ 3 declined in 5 min               │          │
│      │ OR 4 hours continuous             │          │
│      ▼                                   │          │
│  ┌────────┐                              │          │
│  │COOLDOWN│───── cooldownExpires ────────┘          │
│  └────────┘                                         │
│                                                      │
│  Cooldown duration: 15 minutes                       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 6.2 Activation Flow

```
User taps toggle
       │
       ▼
┌──────────────┐
│ Has location │──── No ────► Show "Enable location" prompt
│  permission? │
└──────┬───────┘
       │ Yes
       ▼
┌──────────────┐
│ In cooldown? │──── Yes ───► Show cooldown countdown
└──────┬───────┘
       │ No
       ▼
┌──────────────┐
│  Confirm     │──── Cancel ─► Return to OFF
│  dialog      │
└──────┬───────┘
       │ Confirm
       ▼
   Call liveMode.activate()
       │
       ▼
   State = ACTIVE
```

### 6.3 Confirmation Dialog

```
┌─────────────────────────────────────────┐
│                                         │
│         Start Live Mode?                │
│                                         │
│  You'll receive instant task alerts     │
│  from nearby posters.                   │
│                                         │
│  • Stay near your phone                 │
│  • Tasks expire in 60 seconds           │
│  • Declining too many triggers cooldown │
│                                         │
│     ┌─────────────────────────────────┐ │
│     │        Start Live Mode          │ │
│     └─────────────────────────────────┘ │
│                                         │
│              Cancel                     │
│                                         │
└─────────────────────────────────────────┘
```

### 6.4 Cooldown Display

When in cooldown state:

```
┌─────────────────────────────────────────┐
│  Tasks Near You          [🔒 12:34]     │  ← Locked toggle with countdown
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │  Live Mode on cooldown              ││
│  │                                     ││
│  │  Available again in 12:34           ││
│  │                                     ││
│  │  You can still browse and accept    ││
│  │  standard tasks.                    ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  [Standard feed below...]               │
│                                         │
└─────────────────────────────────────────┘
```

---

## 7. Error States

| Error | Display | Action |
|-------|---------|--------|
| Location unavailable | "Enable location to use Live Mode" | Settings link |
| Network error | "Connection lost. Reconnecting..." | Auto-retry |
| Broadcast expired | Card fades out | Next broadcast auto-appears |
| Session limit reached | "You've been live for 4 hours. Take a break!" | Force cooldown |

---

## 8. Sounds (Reference: SOUND_DESIGN.md)

| Event | Sound | Duration |
|-------|-------|----------|
| Live Mode activated | `live_on.mp3` | 400ms |
| Live Mode deactivated | `live_off.mp3` | 300ms |
| Broadcast received | `broadcast_alert.mp3` | 500ms |
| 10 seconds remaining | `urgent_tick.mp3` | 200ms |
| Task accepted | `task_accepted.mp3` | 400ms |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial Live Mode UI specification |

---

**END OF LIVE MODE UI SPECIFICATION**
