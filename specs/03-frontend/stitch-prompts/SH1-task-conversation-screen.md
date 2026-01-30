# Screen SH1: Task Conversation Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, MESSAGING_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Both (Hustler & Poster)

---

## Overview

In-task messaging thread between hustler and poster. Task-scoped: only available after task acceptance, read-only after completion.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ← Sarah M.                        ⋮     │  ← Header with user name
│   Furniture Assembly                    │  ← Task subtitle
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Task: Furniture Assembly            ││  ← Task context card
│  │ Status: In Progress                 ││
│  │ View Task →                         ││
│  └─────────────────────────────────────┘│
│                                         │
│              Today, 2:30 PM             │  ← Date separator
│                                         │
│  ┌───────────────────────┐              │
│  │ Hi! I'm heading to    │              │  ← Incoming (left)
│  │ your place now.       │              │
│  └───────────────────────┘ 2:30 PM      │
│                                         │
│              ┌───────────────────────┐  │
│              │ Great! See you soon. │  │  ← Outgoing (right)
│              └───────────────────────┘  │
│                              2:32 PM ✓  │  ← Timestamp + read receipt
│                                         │
│  ┌───────────────────────┐              │
│  │ On my way! ETA 15 min │              │
│  └───────────────────────┘ 2:45 PM      │
│                                         │
│  ┌───────────────────────┐              │
│  │ ┌───────────────────┐ │              │
│  │ │                   │ │              │  ← Photo message
│  │ │    [Photo]        │ │              │
│  │ │                   │ │              │
│  │ └───────────────────┘ │              │
│  │ Here's my parking     │              │
│  │ spot.                 │              │
│  └───────────────────────┘ 2:50 PM      │
│                                         │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ Type a message...              📷 ➤ │ │  ← Input field
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface TaskConversationScreenProps {
  // Thread info
  thread?: {
    id: string;
    taskId: string;
    taskTitle: string;
    taskStatus: string;
    isActive: boolean;       // false = read-only
  };

  // Other participant
  otherUser?: {
    id: string;
    displayName: string;
    avatarUrl?: string;
    role: 'HUSTLER' | 'POSTER';
  };

  // Messages
  messages?: Message[];

  // Current user ID (to determine incoming vs outgoing)
  currentUserId?: string;

  // Input state
  inputText?: string;

  // State
  isLoading?: boolean;
  isSending?: boolean;
  error?: Error | null;

  // Callbacks
  onInputChange?: (text: string) => void;
  onSendMessage?: () => void;
  onSendPhoto?: () => void;
  onViewTask?: () => void;
  onLoadMore?: () => void;
  onRetryMessage?: (messageId: string) => void;
  onBack?: () => void;
}

interface Message {
  id: string;
  senderId: string;
  content: string;
  type: 'TEXT' | 'PHOTO' | 'LOCATION' | 'SYSTEM';
  photoUrl?: string;
  location?: {
    latitude: number;
    longitude: number;
    address?: string;
  };
  sentAt: string;
  readAt?: string;
  status: 'SENDING' | 'SENT' | 'DELIVERED' | 'READ' | 'FAILED';
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Back button, user name, task subtitle |
| User name | `typography.body`, `fontWeight: 600` |
| Task subtitle | `typography.caption`, `colors.neutral[500]` |
| Task context card | `cardStyles.outlined`, `spacing[3]` padding |
| Task title | `typography.bodySmall`, `fontWeight: 500` |
| Task status | `typography.caption`, `colors.neutral[600]` |
| View task link | `typography.caption`, `colors.primary[500]` |
| Date separator | `typography.caption`, `colors.neutral[500]`, centered |
| Incoming bubble | `colors.neutral[100]` bg, left-aligned |
| Outgoing bubble | `colors.primary[500]` bg, white text, right-aligned |
| Bubble text | `typography.body` |
| Timestamp | `typography.caption`, `colors.neutral[500]` |
| Read receipt | ✓ sent, ✓✓ delivered, ✓✓ read (blue) |
| Photo | 200px max height, `radius.lg` |
| Input container | `colors.neutral[0]` bg, border top |
| Input field | `inputStyles.default`, flex |
| Photo button | 📷 `iconSize.md`, `colors.neutral[500]` |
| Send button | ➤ `colors.primary[500]`, disabled when empty |

---

## Message Bubble Styles

### Incoming (from other user)
```typescript
{
  backgroundColor: colors.neutral[100],
  borderRadius: 16,
  borderBottomLeftRadius: 4,
  maxWidth: '75%',
  alignSelf: 'flex-start',
}
```

### Outgoing (from current user)
```typescript
{
  backgroundColor: colors.primary[500],
  color: 'white',
  borderRadius: 16,
  borderBottomRightRadius: 4,
  maxWidth: '75%',
  alignSelf: 'flex-end',
}
```

---

## Message Status Icons

| Status | Icon | Color |
|--------|------|-------|
| SENDING | Spinner | `colors.neutral[400]` |
| SENT | ✓ | `colors.neutral[400]` |
| DELIVERED | ✓✓ | `colors.neutral[400]` |
| READ | ✓✓ | `colors.primary[500]` |
| FAILED | ⚠️ Tap to retry | `colors.error` |

---

## System Messages

```
─────────────────────────────
  Task accepted by Sarah
─────────────────────────────
```

Centered, `typography.caption`, `colors.neutral[500]`, divider lines.

---

## Closed Thread State (isActive: false)

```
┌─────────────────────────────────────────┐
│ 🔒 This conversation is closed.         │
│                                         │
│    Task completed on Jan 18, 2025       │
└─────────────────────────────────────────┘
```

- Input field disabled
- Background dimmed
- Past messages still visible

---

## Photo Message

```
┌───────────────────────┐
│ ┌───────────────────┐ │
│ │                   │ │
│ │    [Photo]        │ │  ← Tappable, opens full-screen
│ │                   │ │
│ └───────────────────┘ │
│ Caption text here     │  ← Optional
└───────────────────────┘
```

---

## Empty State (No Messages Yet)

```
┌─────────────────────────────────────────┐
│                                         │
│         No messages yet                 │
│                                         │
│   Send a message to coordinate          │
│   with your task partner.               │
│                                         │
└─────────────────────────────────────────┘
```

---

## Input Behavior

- Send enabled when text is not empty
- Photo button opens image picker
- Keyboard avoidance
- Auto-scroll to bottom on new message

---

**This screen is Cursor-ready. Build exactly as specified.**
