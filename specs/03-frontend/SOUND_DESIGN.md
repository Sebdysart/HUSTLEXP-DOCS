# HustleXP Sound Design System

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Design/Frontend Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All audio feedback must follow this spec. Sound is part of the Duolingo layer (Layer 2).

---

## Table of Contents

1. [Overview](#1-overview)
2. [Sound Categories](#2-sound-categories)
3. [UI Feedback Sounds](#3-ui-feedback-sounds)
4. [Celebration Sounds](#4-celebration-sounds)
5. [Notification Sounds](#5-notification-sounds)
6. [State Change Sounds](#6-state-change-sounds)
7. [Money Sounds](#7-money-sounds)
8. [Technical Implementation](#8-technical-implementation)
9. [Invariants](#9-invariants)

---

## 1. Overview

### Sound Design Philosophy

Sound in HustleXP follows the **Layered Influence Hierarchy** (UI_SPEC §2):

- **Layer 1 (Apple Glass):** Silent. Clean. No audio unless functional.
- **Layer 2 (Duolingo):** Micro-feedback sounds. Brief, satisfying, professional.
- **Layer 3 (COD/Clash):** Achievement sounds. Earned only.

> **Core Principle:** Duolingo's sound design is iconic because sounds are **anticipated, brief, and consistently satisfying**. We replicate that discipline.

### Audio Characteristics

| Attribute | Specification |
|-----------|---------------|
| **Format** | AAC or MP3 (44.1kHz) |
| **Duration** | 50ms - 800ms (max 2000ms for celebrations) |
| **Volume** | Normalized to -14 LUFS |
| **Style** | Clean, modern, organic (no 8-bit or chiptune) |
| **Tonality** | Major keys, consonant intervals |

### When Sound Plays

| Context | Sound Allowed | Layer |
|---------|---------------|-------|
| Button tap | Yes (optional) | Layer 2 |
| Task completion | Yes | Layer 2 |
| Payment received | Yes | Layer 2 + 3 |
| Badge unlock | Yes (first time only) | Layer 3 |
| Level up | Yes (first time only) | Layer 3 |
| Error | Yes (subtle) | Layer 2 |
| Navigation | No | - |
| Scrolling | No | - |
| Loading | No | - |

---

## 2. Sound Categories

### Category Matrix

| Category | Purpose | Max Duration | Example |
|----------|---------|--------------|---------|
| **UI_FEEDBACK** | Micro-confirmations | 150ms | Button tap, toggle |
| **STATE_CHANGE** | Transition acknowledgment | 300ms | Task accepted, proof submitted |
| **CELEBRATION** | Achievement unlock | 2000ms | Level up, badge unlock |
| **NOTIFICATION** | Alert arrival | 500ms | New task alert, message |
| **MONEY** | Financial confirmation | 800ms | Payment received, escrow released |
| **ERROR** | Failure feedback | 200ms | Validation error, rejection |

### Volume Hierarchy

```typescript
const VOLUME_LEVELS = {
  UI_FEEDBACK: 0.3,      // Subtle, not intrusive
  STATE_CHANGE: 0.5,     // Noticeable but brief
  CELEBRATION: 0.7,      // Prominent, earned moment
  NOTIFICATION: 0.6,     // Alert without alarm
  MONEY: 0.7,            // Important financial moment
  ERROR: 0.4,            // Gentle, not harsh
};
```

---

## 3. UI Feedback Sounds

### Button Tap

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `ui_tap_light` | Standard button press | 50ms | Soft "tick" |
| `ui_tap_confirm` | Primary action button | 80ms | Satisfying "pop" |
| `ui_tap_toggle` | Toggle switch | 60ms | Subtle "click" |

**Implementation:**
```typescript
const ButtonSounds = {
  standard: 'ui_tap_light',
  primary: 'ui_tap_confirm',
  toggle: 'ui_tap_toggle',
};

// Trigger on touchStart, not touchEnd (immediate feedback)
onPressIn={() => playSound(ButtonSounds.primary)}
```

### Form Interactions

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `ui_input_focus` | Input field focus | 40ms | Gentle "boop" |
| `ui_dropdown_open` | Dropdown expand | 60ms | Airy "whoosh" |
| `ui_dropdown_select` | Option selected | 50ms | Crisp "tick" |
| `ui_slider_tick` | Slider detent | 30ms | Tactile "click" |

### Gestures

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `ui_swipe_confirm` | Swipe action complete | 100ms | Satisfying "swoosh" |
| `ui_pull_refresh` | Pull-to-refresh trigger | 80ms | Subtle "spring" |
| `ui_long_press` | Long press activated | 60ms | Deep "pulse" |

---

## 4. Celebration Sounds

### Achievement Unlocks (Layer 3 - First Time Only)

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `celebration_badge_unlock` | Badge earned | 1200ms | Rising melodic phrase, triumphant |
| `celebration_level_up` | Level increase | 1500ms | Ascending scale, orchestral swell |
| `celebration_trust_tier_up` | Trust tier promotion | 1800ms | Grand, prestigious, earned |
| `celebration_first_task` | First task completed | 2000ms | Special, memorable, unique |

**Critical Rule:** Celebration sounds play **EXACTLY ONCE** per achievement per user. Server tracks via `animation_shown_at` field.

### XP Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `xp_count_tick` | XP counter incrementing | 20ms (per tick) | Quick "ding" per increment |
| `xp_count_complete` | XP count finished | 300ms | Satisfying "completion" |
| `xp_milestone` | XP milestone (100, 500, 1000) | 800ms | Notable, celebratory |

**XP Counter Animation:**
```typescript
// Count from 0 to earned XP
for (let i = 0; i < earnedXP; i++) {
  playSound('xp_count_tick');
  await delay(30); // 30ms between ticks
}
playSound('xp_count_complete');
```

### Streak Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `streak_continue` | Daily streak maintained | 400ms | Warm, encouraging |
| `streak_milestone_7` | 7-day streak | 800ms | Notable achievement |
| `streak_milestone_30` | 30-day streak | 1200ms | Major achievement |
| `streak_freeze_used` | Streak freeze consumed | 300ms | Neutral, informational |

---

## 5. Notification Sounds

### Alert Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `notif_live_task` | Live task nearby | 500ms | Attention-grabbing but not alarming |
| `notif_task_accepted` | Someone accepted your task | 400ms | Positive confirmation |
| `notif_message` | New message received | 300ms | Friendly ping |
| `notif_proof_submitted` | Hustler submitted proof | 350ms | Neutral alert |

### Priority Tiers

```typescript
const NOTIFICATION_PRIORITY = {
  HIGH: {
    sound: 'notif_live_task',
    vibration: [0, 200, 100, 200], // Pattern
    volume: VOLUME_LEVELS.NOTIFICATION,
  },
  MEDIUM: {
    sound: 'notif_task_accepted',
    vibration: [0, 150],
    volume: VOLUME_LEVELS.NOTIFICATION * 0.8,
  },
  LOW: {
    sound: 'notif_message',
    vibration: [0, 100],
    volume: VOLUME_LEVELS.NOTIFICATION * 0.6,
  },
};
```

### Forbidden Notification Sounds

| Pattern | Why Forbidden |
|---------|---------------|
| **Alarm sounds** | Anxiety-inducing, aggressive |
| **Sirens** | Emergency connotation |
| **Repetitive loops** | Attention hijacking |
| **Custom celebrity voices** | Unprofessional |
| **Meme sounds** | Degrades trust |

---

## 6. State Change Sounds

### Task Lifecycle Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `task_posted` | Task successfully posted | 300ms | Confirmation, clean |
| `task_accepted` | Task accepted by hustler | 400ms | Positive, momentum |
| `task_in_progress` | Work started | 200ms | Subtle activation |
| `task_proof_submitted` | Proof uploaded | 300ms | Progress confirmation |
| `task_completed` | Task marked complete | 500ms | Satisfying completion |
| `task_cancelled` | Task cancelled | 250ms | Neutral, informational |

### Escrow Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `escrow_funded` | Escrow successfully funded | 400ms | Secure, trustworthy |
| `escrow_released` | Payment released to hustler | 600ms | Rewarding, earned |
| `escrow_refunded` | Refund processed | 300ms | Neutral, resolution |

### Account Sounds

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `account_verified` | ID verification complete | 500ms | Professional achievement |
| `account_trust_upgraded` | Trust tier increased | 800ms | Prestigious, earned |
| `account_paused` | Account paused | 200ms | Neutral, respectful |
| `account_resumed` | Account resumed | 300ms | Welcome back |

---

## 7. Money Sounds

### Payment Sounds (Fintech Polish)

| Sound ID | Trigger | Duration | Characteristics |
|----------|---------|----------|-----------------|
| `money_incoming` | Payment received | 600ms | Cha-ching, satisfying, not cartoonish |
| `money_counter_tick` | Balance counter incrementing | 20ms (per tick) | Quick digit tick |
| `money_counter_complete` | Counter finished | 200ms | Clean resolution |
| `money_available` | Funds available for withdrawal | 400ms | Positive, empowering |
| `money_withdrawn` | Withdrawal initiated | 300ms | Confirmation |
| `money_withdrawn_complete` | Withdrawal complete | 400ms | Success |

### Money Counter Animation

```typescript
// Animate from old balance to new balance
const animateBalance = async (from: number, to: number) => {
  const diff = to - from;
  const steps = Math.min(diff, 30); // Max 30 ticks
  const increment = diff / steps;

  for (let i = 0; i < steps; i++) {
    playSound('money_counter_tick');
    setDisplayedBalance(from + (increment * (i + 1)));
    await delay(40); // 40ms between ticks
  }

  playSound('money_counter_complete');
  setDisplayedBalance(to);
};
```

### Forbidden Money Sounds

| Pattern | Why Forbidden |
|---------|---------------|
| **Slot machine sounds** | Gambling association |
| **Coin shower** | Casino psychology |
| **Jackpot alarms** | Manipulation |
| **Cash register "ka-ching"** | Too cartoonish |

---

## 8. Technical Implementation

### Sound Manager

```typescript
import { Audio } from 'expo-av';

class SoundManager {
  private sounds: Map<string, Audio.Sound> = new Map();
  private enabled: boolean = true;

  async preloadSounds() {
    const soundFiles = {
      ui_tap_confirm: require('@/assets/sounds/ui_tap_confirm.mp3'),
      celebration_badge_unlock: require('@/assets/sounds/celebration_badge.mp3'),
      money_incoming: require('@/assets/sounds/money_incoming.mp3'),
      // ... all sounds
    };

    for (const [id, file] of Object.entries(soundFiles)) {
      const { sound } = await Audio.Sound.createAsync(file);
      this.sounds.set(id, sound);
    }
  }

  async play(soundId: string, options?: { volume?: number }) {
    if (!this.enabled) return;

    const sound = this.sounds.get(soundId);
    if (!sound) {
      console.warn(`Sound not found: ${soundId}`);
      return;
    }

    await sound.setVolumeAsync(options?.volume ?? 1);
    await sound.replayAsync();
  }

  setEnabled(enabled: boolean) {
    this.enabled = enabled;
  }
}

export const soundManager = new SoundManager();
```

### Integration with Haptics

```typescript
import * as Haptics from 'expo-haptics';

const feedbackWithSound = async (soundId: string, hapticType: HapticType) => {
  // Play both simultaneously for reinforced feedback
  await Promise.all([
    soundManager.play(soundId),
    Haptics.impactAsync(hapticType),
  ]);
};

// Example: Task completion
feedbackWithSound('task_completed', Haptics.ImpactFeedbackStyle.Medium);
```

### Respecting User Settings

```typescript
const useSoundSettings = () => {
  const { settings } = useUserSettings();

  useEffect(() => {
    // Respect system mute switch
    Audio.setAudioModeAsync({
      playsInSilentModeIOS: false,
    });

    // Respect in-app setting
    soundManager.setEnabled(settings.soundEnabled);
  }, [settings.soundEnabled]);
};
```

### Sound Settings UI

```
SOUNDS & HAPTICS

[ Sound Effects    [ON] ]
  Play sounds for UI interactions and celebrations

[ Money Sounds     [ON] ]
  Play sounds when payments are received

[ Notification Sounds [ON] ]
  Play sounds for push notifications

[ Haptic Feedback  [ON] ]
  Vibration feedback for interactions
```

---

## 9. Invariants

### Sound Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **SOUND-1** | Celebration sounds play exactly once per achievement | Server flag check (`animation_shown_at`) |
| **SOUND-2** | No sound during active disputes | Context guard |
| **SOUND-3** | Poster UI has no gamification sounds | Role guard |
| **SOUND-4** | Sound respects system mute switch | `playsInSilentModeIOS: false` |
| **SOUND-5** | Sound duration ≤ 2000ms | File validation |
| **SOUND-6** | No looping sounds (except progress indicators) | Implementation review |
| **SOUND-7** | Volume normalized to -14 LUFS | Audio file validation |

### Forbidden Patterns

```typescript
const FORBIDDEN_SOUND_PATTERNS = [
  'slot_machine',    // Gambling association
  'alarm',           // Anxiety-inducing
  'siren',           // Emergency connotation
  'countdown_tick',  // False urgency
  'crowd_cheering',  // Over-the-top
  'air_horn',        // Meme sounds
  'loop',            // Attention hijacking (except loading)
];
```

### Context Guards

```typescript
// No celebration sounds during disputes
const canPlayCelebration = (context: AppContext): boolean => {
  if (context.hasActiveDispute) return false;
  if (context.userRole === 'poster') return false;
  return true;
};

// First-time only check
const canPlayFirstTimeSound = (soundId: string, user: User): boolean => {
  const firstTimeSounds = [
    'celebration_badge_unlock',
    'celebration_level_up',
    'celebration_first_task',
  ];

  if (!firstTimeSounds.includes(soundId)) return true;

  // Check server flag
  return user.animation_shown_at === null;
};
```

---

## Sound Asset Reference

### File Naming Convention

```
{category}_{action}_{variant?}.mp3

Examples:
- ui_tap_confirm.mp3
- celebration_badge_unlock.mp3
- money_incoming.mp3
- notif_live_task.mp3
```

### Directory Structure

```
assets/
  sounds/
    ui/
      ui_tap_light.mp3
      ui_tap_confirm.mp3
      ui_tap_toggle.mp3
      ui_swipe_confirm.mp3
    celebration/
      celebration_badge_unlock.mp3
      celebration_level_up.mp3
      celebration_first_task.mp3
    money/
      money_incoming.mp3
      money_counter_tick.mp3
      money_counter_complete.mp3
    notification/
      notif_live_task.mp3
      notif_message.mp3
    state/
      task_completed.mp3
      escrow_released.mp3
```

---

## Cross-Reference

| Section | Reference |
|---------|-----------|
| Layered Hierarchy | UI_SPEC.md §2 |
| Celebration Constraints | UI_SPEC.md §4.5 |
| Haptic Integration | UI_SPEC.md §21 (Haptics) |
| Notification UX | NOTIFICATION_UX.md |
| Reduced Motion | Accessibility: When `prefers-reduced-motion`, sounds still play (unless user disables) |

---

**END OF SOUND_DESIGN.md v1.0.0**
