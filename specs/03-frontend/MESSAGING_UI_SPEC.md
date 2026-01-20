# HustleXP Messaging UI Specification v1.0.0

**STATUS: IMPLEMENTATION SPECIFICATION**
**Authority:** DESIGN_SYSTEM.md, API_CONTRACT.md §9 (Messaging Endpoints)
**Cursor-Ready:** YES

---

## Table of Contents

1. [Overview](#overview)
2. [Message List Screen](#message-list-screen)
3. [Thread View Screen](#thread-view-screen)
4. [Message Components](#message-components)
5. [States & Interactions](#states--interactions)

---

## 1. Overview

### Scope

Messaging in HustleXP is **task-scoped**. Users can only message each other within the context of an active task.

### Key Rules

1. **No messaging before task acceptance** — Conversations start when task is accepted
2. **No messaging after task completion** — Thread becomes read-only after rating
3. **Task context always visible** — Thread header shows task info
4. **Moderation active** — Messages are scanned for PII and off-platform solicitation

### Design Principles

- **Apple Glass Layer** (functional, not playful)
- **Clear task context**
- **Minimal friction**

---

## 2. Message List Screen

### 2.1 Layout

**Screen ID:** `MESSAGE_LIST`
**Navigation:** Bottom Tab → Messages

```
┌─────────────────────────────────────────┐
│ Messages                                │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 👤 Sarah M.                    2m   ││  ← Thread preview
│  │    Furniture Assembly               ││  ← Task title
│  │    "On my way! ETA 15 min"      ●   ││  ← Last message + unread dot
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 👤 Mike T.                    1h    ││
│  │    Grocery Delivery                 ││
│  │    "Thanks for the quick delivery"  ││  ← No unread dot
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 👤 Lisa K.                    2d    ││
│  │    Moving Help                      ││
│  │    "Task completed. Thanks!"    🔒  ││  ← Lock = thread closed
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

### 2.2 Props Interface

```typescript
interface MessageListScreenProps {
  threads: MessageThread[];
  isLoading?: boolean;
  error?: Error | null;
  onThreadPress?: (threadId: string) => void;
  onRefresh?: () => void;
}

interface MessageThread {
  id: string;
  taskId: string;
  taskTitle: string;
  otherUser: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
  lastMessage: {
    content: string;
    sentAt: string;           // ISO 8601
    isFromMe: boolean;
  };
  unreadCount: number;
  isActive: boolean;          // false = thread closed (task completed)
}
```

### 2.3 Thread Preview Visual Spec

| Element | Style |
|---------|-------|
| Container | `colors.surface`, `radius.md`, `spacing.md` padding |
| Avatar | 40px circle, fallback to initials |
| Name | `typography.body`, `textPrimary`, `600` weight |
| Time | `typography.caption`, `textTertiary` |
| Task title | `typography.caption`, `textSecondary` |
| Last message | `typography.body`, `textSecondary`, 1 line max |
| Unread dot | 8px circle, `colors.primary` |
| Lock icon | 16px, `textTertiary` |

---

## 3. Thread View Screen

### 3.1 Layout

**Screen ID:** `MESSAGE_THREAD`
**Navigation:** Message List → Thread

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
│  │ Hi! I'm heading to    │              │  ← Incoming message (left)
│  │ your place now.       │              │
│  └───────────────────────┘ 2:30 PM      │
│                                         │
│              ┌───────────────────────┐  │
│              │ Great! See you soon. │  │  ← Outgoing message (right)
│              └───────────────────────┘  │
│                              2:32 PM ✓  │  ← Timestamp + read receipt
│                                         │
│  ┌───────────────────────┐              │
│  │ On my way! ETA 15 min │              │
│  └───────────────────────┘ 2:45 PM      │
│                                         │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ Type a message...              📷 ➤ │ │  ← Input field
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 3.2 Props Interface

```typescript
interface MessageThreadScreenProps {
  thread: {
    id: string;
    taskId: string;
    taskTitle: string;
    taskStatus: string;
    isActive: boolean;
  };
  otherUser: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
  messages: Message[];
  isLoading?: boolean;
  isSending?: boolean;
  error?: Error | null;
  onSendMessage?: (content: string) => void;
  onSendPhoto?: (photoUri: string) => void;
  onViewTask?: () => void;
  onLoadMore?: () => void;
}

interface Message {
  id: string;
  senderId: string;
  content: string;
  type: 'TEXT' | 'PHOTO' | 'LOCATION' | 'SYSTEM';
  photoUrl?: string;
  location?: {
    lat: number;
    lng: number;
  };
  sentAt: string;
  readAt?: string;
  status: 'sending' | 'sent' | 'delivered' | 'read' | 'failed';
}
```

### 3.3 Closed Thread State

When task is completed, the thread becomes read-only:

```
┌─────────────────────────────────────────┐
│ ← Lisa K.                               │
│   Moving Help                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✓ Task Completed                    ││  ← Completed badge
│  │   January 15, 2025                  ││
│  │   View Task →                       ││
│  └─────────────────────────────────────┘│
│                                         │
│  [Previous messages...]                 │
│                                         │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🔒 This conversation is closed.     │ │  ← Locked input
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 4. Message Components

### 4.1 MessageBubble

```typescript
interface MessageBubbleProps {
  content: string;
  type: 'TEXT' | 'PHOTO' | 'LOCATION';
  isFromMe: boolean;
  photoUrl?: string;
  status?: 'sending' | 'sent' | 'delivered' | 'read' | 'failed';
  timestamp: string;
  onRetry?: () => void;
}
```

#### Visual Spec

| Property | Incoming (left) | Outgoing (right) |
|----------|-----------------|------------------|
| Background | `colors.surface` | `colors.primary` |
| Text color | `textPrimary` | `white` |
| Border radius | 16px (0 bottom-left) | 16px (0 bottom-right) |
| Max width | 75% of screen | 75% of screen |
| Timestamp | Below, left-aligned | Below, right-aligned |
| Status icon | N/A | ✓ sent, ✓✓ delivered, ✓✓ read (blue) |

### 4.2 PhotoMessage

```
┌───────────────────────┐
│ ┌───────────────────┐ │
│ │                   │ │
│ │    [Photo]        │ │  ← 200px max height, aspect-fit
│ │                   │ │
│ └───────────────────┘ │
│ Caption text here     │  ← Optional caption
└───────────────────────┘
```

### 4.3 LocationMessage

```
┌───────────────────────┐
│ ┌───────────────────┐ │
│ │   [Map Preview]   │ │  ← Static map image, 150px height
│ └───────────────────┘ │
│ 📍 123 Main St        │  ← Address (if available)
│    Open in Maps →     │  ← Action link
└───────────────────────┘
```

### 4.4 SystemMessage

For automated messages (task status changes):

```
         ─────────────────────
         Task accepted by Sarah
         ─────────────────────
```

| Property | Style |
|----------|-------|
| Background | None |
| Text | `typography.caption`, `textTertiary`, centered |
| Dividers | 1px `colors.divider` |

### 4.5 DateSeparator

```
         ─── Today, 2:30 PM ───
```

| Property | Style |
|----------|-------|
| Text | `typography.micro`, `textTertiary`, centered |
| Lines | 1px `colors.divider`, flex |

---

## 5. States & Interactions

### 5.1 Message States

| State | Visual | Behavior |
|-------|--------|----------|
| Sending | Spinner next to message | Disable send button |
| Sent | Single checkmark | N/A |
| Delivered | Double checkmark | N/A |
| Read | Blue double checkmark | N/A |
| Failed | Red "!" icon + "Tap to retry" | onRetry callback |

### 5.2 Input Field

```typescript
interface MessageInputProps {
  value: string;
  isDisabled?: boolean;       // true when thread closed
  isSending?: boolean;
  placeholder?: string;
  onChangeText?: (text: string) => void;
  onSend?: () => void;
  onPhotoPress?: () => void;
}
```

#### Visual Spec

| State | Background | Border |
|-------|------------|--------|
| Default | `colors.surface` | 1px `colors.divider` |
| Focused | `colors.surface` | 1px `colors.primary` |
| Disabled | `colors.surface` opacity 50% | 1px `colors.divider` |

#### Buttons

| Button | Position | Enabled When |
|--------|----------|--------------|
| Photo (📷) | Left of input | Thread active |
| Send (➤) | Right of input | Text not empty |

### 5.3 Loading States

| Screen | Loading Display |
|--------|-----------------|
| Message List | Skeleton thread previews |
| Thread View | Spinner at top when loading more |
| Sending | Spinner in send button |

### 5.4 Empty States

**No Messages (New Thread):**
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

**No Threads:**
```
┌─────────────────────────────────────────┐
│                                         │
│         No conversations                │
│                                         │
│   Accept a task to start messaging      │
│   with posters.                         │
│                                         │
└─────────────────────────────────────────┘
```

### 5.5 Error States

| Error | Display | Action |
|-------|---------|--------|
| Send failed | Red bubble with retry | Tap to retry |
| Load failed | "Couldn't load messages" + Retry button | Pull to refresh |
| Moderation block | "Message blocked for review" | Contact support link |

---

## 6. Moderation Integration

### Flagged Content Warning

When a message is flagged but not blocked:

```
┌───────────────────────────────────────┐
│ ⚠️ This message is being reviewed.    │
│    It will be delivered after         │
│    moderation.                        │
└───────────────────────────────────────┘
```

### Blocked Content

When a message is blocked (e.g., contains phone number):

```
┌───────────────────────────────────────┐
│ 🚫 Message not sent                   │
│                                       │
│    Sharing contact info off-platform  │
│    is not allowed.                    │
│                                       │
│    Why? →                             │
└───────────────────────────────────────┘
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial Messaging UI specification |

---

**END OF MESSAGING UI SPECIFICATION**
