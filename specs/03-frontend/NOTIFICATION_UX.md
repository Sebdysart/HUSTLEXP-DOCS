# HustleXP Notification UX Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Product/Design Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All push notifications and in-app notifications must follow this spec.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Push Notification Templates](#2-push-notification-templates)
3. [Rich Notification Formats](#3-rich-notification-formats)
4. [Quick Actions](#4-quick-actions)
5. [In-App Notification Center](#5-in-app-notification-center)
6. [Notification Grouping](#6-notification-grouping)
7. [Sound & Haptics](#7-sound--haptics)
8. [User Preferences](#8-user-preferences)
9. [Forbidden Patterns](#9-forbidden-patterns)
10. [Invariants](#10-invariants)

---

## 1. Overview

### Notification Philosophy

Notifications are **state signals**, not advertisements. They inform users of things they asked to know about.

> **Core Principle:** Every notification must pass the "Would the user thank us for this?" test. If not, don't send it.

### Notification Types

| Type | Purpose | Priority | Sound |
|------|---------|----------|-------|
| **LIVE_TASK** | Live task nearby | High | Yes |
| **TASK_ACCEPTED** | Someone accepted your task | High | Yes |
| **PAYMENT** | Payment received/sent | High | Yes |
| **PROOF_SUBMITTED** | Hustler submitted proof | Medium | Yes |
| **MESSAGE** | New message | Medium | Yes |
| **TASK_UPDATE** | Task state changed | Medium | Optional |
| **BADGE_UNLOCK** | Badge earned | Low | Optional |
| **PROMOTIONAL** | System announcements | Low | No |

### Platform Considerations

| Platform | Rich Media | Actions | Grouping |
|----------|------------|---------|----------|
| **iOS** | Images, video previews | Up to 4 | Thread-based |
| **Android** | Images, expanded layout | Up to 3 | Channel-based |

---

## 2. Push Notification Templates

### Live Task Nearby (Hustler)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          now         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔴 LIVE TASK nearby                                           │
│  Help moving furniture • $35 • 0.8 mi                          │
│                                                                 │
│  ✅ Escrow funded                                              │
│                                                                 │
│  [ View Task ]                [ Accept ]                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 🔴 LIVE TASK nearby
Body: {task_title} • ${price} • {distance} mi
Subtitle: ✅ Escrow funded
Actions: [View Task, Accept]
Sound: notif_live_task
```

### Task Accepted (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          2m ago      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🟢 Hustler on the way                                         │
│  Marcus accepted "Help moving furniture"                       │
│                                                                 │
│  ETA: ~12 minutes • 1.2 mi away                               │
│                                                                 │
│  [ View Details ]              [ Message ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 🟢 Hustler on the way
Body: {hustler_name} accepted "{task_title}"
Subtitle: ETA: ~{eta} minutes • {distance} mi away
Actions: [View Details, Message]
Sound: notif_task_accepted
```

### Payment Received (Hustler)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          just now    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  💰 You earned $29.75                                          │
│  Help moving furniture • Payment released                      │
│                                                                 │
│  Available for withdrawal now                                   │
│                                                                 │
│  [ View Wallet ]               [ Withdraw ]                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 💰 You earned ${amount}
Body: {task_title} • Payment released
Subtitle: Available for withdrawal now
Actions: [View Wallet, Withdraw]
Sound: money_incoming
```

### Proof Submitted (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          5m ago      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📷 Proof submitted                                            │
│  Marcus submitted proof for "Help moving furniture"            │
│                                                                 │
│  Review and release payment                                     │
│                                                                 │
│  [ View Proof ]                [ Approve ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 📷 Proof submitted
Body: {hustler_name} submitted proof for "{task_title}"
Subtitle: Review and release payment
Actions: [View Proof, Approve]
Sound: notif_proof_submitted
```

### New Message

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          1m ago      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  💬 New message from Sarah                                     │
│  "I'm on my way, be there in 10!"                              │
│                                                                 │
│  Re: Help moving furniture                                      │
│                                                                 │
│  [ Reply ]                     [ View Chat ]                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 💬 New message from {sender_name}
Body: "{message_preview}"
Subtitle: Re: {task_title}
Actions: [Reply, View Chat]
Sound: notif_message
```

### Badge Unlocked

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          10m ago     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🏆 Badge Unlocked: Early Bird                                 │
│  Complete 5 tasks before 8am                                    │
│                                                                 │
│  [ View Badge ]                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Template:**
```
Title: 🏆 Badge Unlocked: {badge_name}
Body: {badge_description}
Actions: [View Badge]
Sound: celebration_badge_unlock (optional, based on settings)
```

---

## 3. Rich Notification Formats

### iOS Rich Notifications

#### Notification with Image

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          5m ago      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📷 Proof submitted                                            │
│  Marcus submitted proof for "Help moving furniture"            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │              [Proof Image Thumbnail]                      │ │
│  │                    200x200                                │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  [ View Proof ]                [ Approve ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Implementation (iOS):**
```swift
let content = UNMutableNotificationContent()
content.title = "📷 Proof submitted"
content.body = "Marcus submitted proof for \"Help moving furniture\""

// Attach image
let attachment = try UNNotificationAttachment(
  identifier: "proof-image",
  url: imageURL,
  options: [UNNotificationAttachmentOptionsThumbnailClippingRectKey: ...]
)
content.attachments = [attachment]
```

#### Notification with Map

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          now         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🟢 Hustler on the way                                         │
│  Marcus is heading to your location                            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │              [Map Preview with Route]                     │ │
│  │                    200x100                                │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ETA: ~12 minutes                                              │
│                                                                 │
│  [ View Details ]              [ Message ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Android Expanded Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          5m ago  ⋮   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📷 Proof submitted                                            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │              [Large Proof Image]                          │ │
│  │                    full width                             │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Marcus submitted proof for "Help moving furniture"            │
│  Review and release payment when ready.                        │
│                                                                 │
│  [ VIEW PROOF ]        [ APPROVE ]        [ DISPUTE ]         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Quick Actions

### Action Buttons per Notification Type

| Notification | Action 1 | Action 2 | Action 3 |
|--------------|----------|----------|----------|
| **LIVE_TASK** | View Task | Accept | - |
| **TASK_ACCEPTED** | View Details | Message | - |
| **PAYMENT** | View Wallet | Withdraw | - |
| **PROOF_SUBMITTED** | View Proof | Approve | Dispute |
| **MESSAGE** | Reply | View Chat | - |
| **BADGE_UNLOCK** | View Badge | - | - |

### Inline Reply (Messages)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  💬 New message from Sarah                                     │
│  "I'm on my way, be there in 10!"                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Type a reply...                              [ Send ]    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Implementation (iOS):**
```swift
let replyAction = UNTextInputNotificationAction(
  identifier: "REPLY_ACTION",
  title: "Reply",
  textInputButtonTitle: "Send",
  textInputPlaceholder: "Type a reply..."
)
```

### Confirmation Actions

For actions that change state (Accept, Approve), show confirmation:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  [ Approving... ]                                              │
│                                                                 │
│  ✅ Payment released to Marcus                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. In-App Notification Center

### Notification Center UI

```
┌─────────────────────────────────────────────────────────────────┐
│  NOTIFICATIONS                               [ Mark All Read ] │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TODAY                                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ● 💰 You earned $29.75                        5m ago   │   │
│  │     Help moving furniture • Payment released            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ● 📷 Proof submitted                         15m ago   │   │
│  │     Marcus submitted proof for...                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  YESTERDAY                                                      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    🟢 Hustler on the way                      2:34 PM   │   │
│  │     Marcus accepted "Help moving..."                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │    🏆 Badge Unlocked: Early Bird              9:15 AM   │   │
│  │     Complete 5 tasks before 8am                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Notification States

| State | Visual |
|-------|--------|
| **Unread** | Blue dot indicator (●), slightly bolder text |
| **Read** | No indicator, standard text weight |
| **Actioned** | Grayed out, moved to "Earlier" section |

### Badge Count

```typescript
const calculateBadgeCount = (notifications: Notification[]): number => {
  return notifications.filter(n => !n.read && n.priority !== 'LOW').length;
};
```

**Badge Rules:**
- Only HIGH and MEDIUM priority notifications count
- Maximum display: 99+ (if > 99)
- Clear when notification center opened

### Notification Retention

| Type | Retention |
|------|-----------|
| **Payment** | 90 days |
| **Task-related** | 30 days after task completion |
| **Messages** | 30 days |
| **Badges** | Permanent (in achievements) |
| **Promotional** | 7 days |

---

## 6. Notification Grouping

### iOS Thread Grouping

```typescript
// Group by task
const threadIdentifier = `task-${task.id}`;

// Group by type
const threadIdentifier = `payments`;
```

**Example Grouped:**
```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP • Help moving furniture                   3 updates  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  💰 You earned $29.75                                          │
│  📷 Proof submitted                                            │
│  🟢 Hustler on the way                                         │
│                                                                 │
│  [ Expand ]                                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Android Channels

```typescript
const NOTIFICATION_CHANNELS = {
  TASKS: {
    id: 'tasks',
    name: 'Task Updates',
    description: 'Notifications about your tasks',
    importance: 'HIGH',
    sound: 'notif_task_accepted',
  },
  PAYMENTS: {
    id: 'payments',
    name: 'Payments',
    description: 'Payment and earning notifications',
    importance: 'HIGH',
    sound: 'money_incoming',
  },
  MESSAGES: {
    id: 'messages',
    name: 'Messages',
    description: 'Chat messages',
    importance: 'HIGH',
    sound: 'notif_message',
  },
  ACHIEVEMENTS: {
    id: 'achievements',
    name: 'Achievements',
    description: 'Badges and milestones',
    importance: 'LOW',
    sound: null,
  },
};
```

---

## 7. Sound & Haptics

### Sound Mapping

| Notification Type | Sound ID | Duration |
|-------------------|----------|----------|
| LIVE_TASK | `notif_live_task` | 500ms |
| TASK_ACCEPTED | `notif_task_accepted` | 400ms |
| PAYMENT | `money_incoming` | 600ms |
| PROOF_SUBMITTED | `notif_proof_submitted` | 350ms |
| MESSAGE | `notif_message` | 300ms |
| BADGE_UNLOCK | `celebration_badge_unlock` | 1200ms |

See SOUND_DESIGN.md for full audio specifications.

### Haptic Patterns

| Notification Type | Haptic Pattern |
|-------------------|----------------|
| LIVE_TASK | Double pulse (attention) |
| TASK_ACCEPTED | Single medium impact |
| PAYMENT | Success pattern |
| MESSAGE | Light tap |
| BADGE_UNLOCK | Success burst |

```typescript
const NOTIFICATION_HAPTICS = {
  LIVE_TASK: [0, 200, 100, 200], // Double pulse
  TASK_ACCEPTED: [0, 150],       // Single medium
  PAYMENT: [0, 100, 50, 100, 50, 200], // Success pattern
  MESSAGE: [0, 50],              // Light tap
  BADGE_UNLOCK: [0, 150, 50, 150], // Success burst
};
```

---

## 8. User Preferences

### Notification Settings UI

```
┌─────────────────────────────────────────────────────────────────┐
│  NOTIFICATION SETTINGS                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TASK NOTIFICATIONS                                             │
│                                                                 │
│  [ Live tasks nearby           [ON] ]                          │
│  [ Task accepted               [ON] ]                          │
│  [ Proof submitted             [ON] ]                          │
│  [ Task completed              [ON] ]                          │
│                                                                 │
│  PAYMENT NOTIFICATIONS                                          │
│                                                                 │
│  [ Payment received            [ON] ]                          │
│  [ Payment sent                [ON] ]                          │
│                                                                 │
│  MESSAGE NOTIFICATIONS                                          │
│                                                                 │
│  [ New messages                [ON] ]                          │
│                                                                 │
│  ACHIEVEMENT NOTIFICATIONS                                      │
│                                                                 │
│  [ Badges unlocked             [OFF] ]                         │
│  [ Level ups                   [OFF] ]                         │
│                                                                 │
│  QUIET HOURS                                                    │
│                                                                 │
│  [ Enable quiet hours          [ON] ]                          │
│    From: 10:00 PM                                               │
│    To: 7:00 AM                                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Default Settings

| Setting | Default | Reason |
|---------|---------|--------|
| Live tasks nearby | ON | Core functionality |
| Task accepted | ON | Important state change |
| Payment received | ON | Financial notification |
| Badges unlocked | OFF | Not essential, opt-in |
| Quiet hours | OFF | User preference |

### Quiet Hours

During quiet hours:
- No sounds
- No vibration
- Notifications still delivered but silently
- Badge count still updates

---

## 9. Forbidden Patterns

### Forbidden Notification Content

| Pattern | Why Forbidden | Example |
|---------|---------------|---------|
| **Urgency language** | Manipulation | "ACT NOW!", "Hurry!" |
| **FOMO triggers** | Anxiety-inducing | "You're missing out!" |
| **Fake scarcity** | Deceptive | "Only 3 tasks left!" |
| **Re-engagement spam** | Annoying | "We miss you!" |
| **Unrelated promotions** | Trust erosion | App ads unrelated to tasks |
| **Emoji spam** | Unprofessional | "🎉🎊🥳 OMG!!!" |

### Forbidden Patterns Code

```typescript
const FORBIDDEN_NOTIFICATION_PATTERNS = [
  // Urgency
  /act now/i, /hurry/i, /limited time/i, /expires soon/i,

  // FOMO
  /missing out/i, /don't miss/i, /last chance/i,

  // Fake scarcity
  /only \d+ left/i, /running out/i, /almost gone/i,

  // Re-engagement spam
  /we miss you/i, /come back/i, /haven't seen you/i,

  // Emoji spam (more than 2 emojis)
  /[\u{1F300}-\u{1F9FF}]{3,}/u,
];
```

### Notification Frequency Limits

| Type | Max per Hour | Max per Day |
|------|--------------|-------------|
| LIVE_TASK | 6 | 20 |
| TASK_ACCEPTED | No limit | No limit |
| PAYMENT | No limit | No limit |
| PROMOTIONAL | 0 | 1 |
| BADGE_UNLOCK | 3 | 10 |

---

## 10. Invariants

### Notification Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **NOTIF-1** | No urgency language in notifications | Content validation |
| **NOTIF-2** | Payment notifications always include amount | Template validation |
| **NOTIF-3** | Task notifications include escrow state | Backend ensures data |
| **NOTIF-4** | Sound respects user settings | Platform API |
| **NOTIF-5** | Quiet hours respected | Backend scheduling |
| **NOTIF-6** | Max 1 notification per task per state change | Deduplication logic |
| **NOTIF-7** | No promotional notifications without user consent | Settings check |

### Deduplication Logic

```typescript
const shouldSendNotification = (
  userId: string,
  type: NotificationType,
  taskId: string | null,
  state: string | null
): boolean => {
  const key = `${userId}:${type}:${taskId || 'global'}:${state || 'none'}`;
  const lastSent = cache.get(key);

  if (lastSent && Date.now() - lastSent < DEDUP_WINDOW_MS) {
    return false;
  }

  cache.set(key, Date.now());
  return true;
};

const DEDUP_WINDOW_MS = 60 * 1000; // 1 minute
```

---

## API Contract

### Send Notification

```typescript
POST /api/notifications/send

{
  user_id: string;
  type: NotificationType;
  title: string;
  body: string;
  subtitle?: string;
  data: {
    task_id?: string;
    escrow_id?: string;
    message_id?: string;
    badge_id?: string;
  };
  actions?: NotificationAction[];
  image_url?: string;
  sound?: string;
  priority: 'HIGH' | 'MEDIUM' | 'LOW';
}
```

### Notification Payload (FCM/APNs)

```json
{
  "notification": {
    "title": "💰 You earned $29.75",
    "body": "Help moving furniture • Payment released",
    "sound": "money_incoming.wav"
  },
  "data": {
    "type": "PAYMENT",
    "task_id": "task-123",
    "escrow_id": "escrow-456",
    "amount": "29.75",
    "deep_link": "hustlexp://wallet"
  },
  "apns": {
    "payload": {
      "aps": {
        "thread-id": "payments",
        "category": "PAYMENT_ACTIONS"
      }
    }
  },
  "android": {
    "notification": {
      "channel_id": "payments"
    }
  }
}
```

---

## 11. Poster Notifications

### 11.1 Poster Notification Philosophy

Poster notifications are **transactional, not celebratory**. They inform, not gamify.

> **Core Principle:** Posters are paying customers. Notifications should feel like **professional service updates**, not achievements.

### 11.2 Poster Notification Types

| Type | Template | Priority | Sound |
|------|----------|----------|-------|
| **HUSTLER_ACCEPTED** | "{name} accepted your task" | High | `poster_hustler_accepted` |
| **HUSTLER_EN_ROUTE** | "{name} is on the way — ETA {min} min" | High | None |
| **HUSTLER_ARRIVED** | "{name} has arrived at your location" | High | `poster_hustler_arrived` |
| **PROOF_SUBMITTED** | "Proof submitted — Review required" | High | `poster_proof_submitted` |
| **PAYMENT_SENT** | "Payment of ${amount} sent to {name}" | High | `poster_payment_sent` |
| **MESSAGE** | "New message from {name}" | Medium | `poster_message` |
| **TASK_EXPIRED** | "Your task expired — No one accepted" | Medium | None |
| **DISPUTE_UPDATE** | "Update on your dispute" | High | None |

### 11.3 Poster Push Templates

#### Hustler Accepted (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          just now    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✓ Hustler accepted                                            │
│  Marcus accepted "Help moving furniture"                       │
│                                                                 │
│  ⭐ VERIFIED • 47 tasks completed                              │
│                                                                 │
│  [ View Details ]              [ Message ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Hustler Arrived (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          just now    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📍 Hustler arrived                                            │
│  Marcus has arrived at your location                           │
│                                                                 │
│  Help moving furniture                                          │
│                                                                 │
│  [ View Task ]                 [ Message ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Proof Submitted (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          2m ago      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📷 Proof submitted                                            │
│  Marcus submitted proof for "Help moving furniture"            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              [Proof Image Thumbnail]                      │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  [ View Proof ]                [ Approve ]                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Payment Sent (Poster)

```
┌─────────────────────────────────────────────────────────────────┐
│  HustleXP                                          just now    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✓ Payment sent                                                │
│  $35.00 sent to Marcus for "Help moving furniture"             │
│                                                                 │
│  [ View Receipt ]                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 11.4 Forbidden Poster Notifications

| Notification Type | Reason |
|-------------------|--------|
| **XP earned** | Posters don't earn XP |
| **Badge unlocked** | Posters don't earn badges |
| **Level up** | No levels for posters |
| **Streak** | No streaks for posters |
| **Leaderboard** | No leaderboards for posters |
| **"Great job!" celebrations** | No gamification language |

### 11.5 Poster Notification Settings

```
┌─────────────────────────────────────────────────────────────────┐
│  NOTIFICATION SETTINGS                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TASK UPDATES                                                   │
│                                                                 │
│  [ Hustler accepted          [ON] ]                            │
│  [ Hustler en route          [ON] ]                            │
│  [ Hustler arrived           [ON] ]                            │
│  [ Proof submitted           [ON] ]                            │
│                                                                 │
│  PAYMENTS                                                       │
│                                                                 │
│  [ Payment confirmations     [ON] ]                            │
│                                                                 │
│  MESSAGES                                                       │
│                                                                 │
│  [ New messages              [ON] ]                            │
│                                                                 │
│  QUIET HOURS                                                    │
│                                                                 │
│  [ Enable quiet hours        [OFF] ]                           │
│    From: 10:00 PM                                               │
│    To: 7:00 AM                                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Note:** No "Achievement" section for posters.

### 11.6 Poster Notification Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **NOTIF-POSTER-1** | No gamification notifications to posters | Role guard |
| **NOTIF-POSTER-2** | No celebration language in poster notifications | Copy guard |
| **NOTIF-POSTER-3** | Poster sound palette only (max 300ms) | Audio guard |
| **NOTIF-POSTER-4** | Payment notifications always include amount | Template validation |
| **NOTIF-POSTER-5** | Hustler trust tier visible in acceptance notifications | Template validation |

### 11.7 Implementation Guard

```typescript
const canSendNotification = (
  userId: string,
  type: NotificationType,
  userRole: 'hustler' | 'poster'
): boolean => {
  // Poster cannot receive gamification notifications
  if (userRole === 'poster') {
    const FORBIDDEN_POSTER_TYPES = [
      'XP_EARNED',
      'BADGE_UNLOCKED',
      'LEVEL_UP',
      'STREAK_UPDATE',
      'LEADERBOARD_UPDATE',
    ];

    if (FORBIDDEN_POSTER_TYPES.includes(type)) {
      return false;
    }
  }

  return true;
};
```

---

## Cross-Reference

| Section | Reference |
|---------|-----------|
| Sound Design | SOUND_DESIGN.md |
| Poster UI Spec | POSTER_UI_SPEC.md |
| Hustler UI Spec | HUSTLER_UI_SPEC.md |
| Push Infrastructure | (To be added to Backend specs) |
| UI_SPEC | UI_SPEC.md §13.5 (Live Mode Notifications) |
| API Contract | API_CONTRACT.md |

---

**END OF NOTIFICATION_UX.md v1.1.0**
