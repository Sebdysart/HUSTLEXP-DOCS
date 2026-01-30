# In-App Messaging Specification

**STATUS: STAGING (Detailed Implementation)**
**Owner:** Product Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Authority:** PRODUCT_SPEC.md §10 is canonical. This document provides implementation details.

---

## Overview

Messaging exists to coordinate task completion, not to socialize. Every message is task-scoped.

> **Core Principle:** No general chat. No DMs. Only task-specific coordination.

---

## Message Scope

### When Messaging Is Allowed

| Task State | Messaging |
|------------|-----------|
| OPEN | Blocked (no worker assigned) |
| ACCEPTED | Allowed |
| PROOF_SUBMITTED | Allowed |
| DISPUTED | Allowed |
| COMPLETED | Read-only archive |
| CANCELLED | Read-only archive |
| EXPIRED | Read-only archive |

### Participants

Only two roles can message on a task:
- **Poster** - Task creator
- **Worker** - Assigned worker

Admins can view messages for dispute resolution but cannot send messages.

---

## Message Types

### Text Messages

```typescript
interface TextMessage {
  type: 'text';
  content: string;  // Max 500 characters
  // Links are stripped/disabled
}
```

**Validation:**
- Max 500 characters
- No external links (auto-stripped)
- Scanned for moderation (A2 authority)

### Quick Responses

```typescript
const QUICK_RESPONSES = [
  { id: 'on_my_way', label: 'On my way', icon: 'navigation' },
  { id: 'running_late', label: 'Running late (10 min)', icon: 'clock' },
  { id: 'arrived', label: 'I\'ve arrived', icon: 'map-pin' },
  { id: 'started', label: 'Started working', icon: 'play' },
  { id: 'almost_done', label: 'Almost done', icon: 'check-circle' },
  { id: 'completed', label: 'Completed!', icon: 'check' },
  { id: 'question', label: 'Quick question', icon: 'help-circle' },
];
```

### Photo Messages

```typescript
interface PhotoMessage {
  type: 'photo';
  photos: PhotoAttachment[];  // Max 3
  caption?: string;  // Max 200 characters
}

interface PhotoAttachment {
  storage_key: string;
  thumbnail_url: string;
  full_url: string;
  width: number;
  height: number;
}
```

**Validation:**
- Max 3 photos per message
- Max 5 MB per photo
- JPEG, PNG only
- Stored in `messages/` bucket (see STORAGE_SPEC.md)
- Scanned for moderation

### Location Sharing

```typescript
interface LocationMessage {
  type: 'location';
  latitude: number;
  longitude: number;
  accuracy_meters: number;
  expires_at: string;  // 15 minutes from share
}
```

**Behavior:**
- One-time share ("I'm here")
- Expires after 15 minutes
- Not real-time tracking
- Optional (user can decline)

---

## Database Schema

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES tasks(id),
  sender_id UUID NOT NULL REFERENCES users(id),
  message_type message_type NOT NULL DEFAULT 'text',
  content TEXT,  -- For text messages
  photos JSONB,  -- For photo messages
  location JSONB,  -- For location messages
  quick_response_id TEXT,  -- For quick responses
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Constraints
ALTER TABLE messages ADD CONSTRAINT message_content_length
  CHECK (content IS NULL OR LENGTH(content) <= 500);

-- Indexes
CREATE INDEX idx_messages_task_id ON messages(task_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

---

## Real-Time Updates

### WebSocket Events

```typescript
// Subscribe to task messages
socket.on('task:message', (message: Message) => {
  // New message in task
});

socket.on('task:message:read', (data: { message_id: string }) => {
  // Message read receipt
});

socket.on('task:typing', (data: { user_id: string, task_id: string }) => {
  // Typing indicator (optional)
});
```

### Polling Fallback

If WebSocket unavailable:
- Poll every 5 seconds when chat is open
- Poll every 30 seconds when in background

---

## Content Moderation

### AI Scanning (A2 Authority)

All messages are scanned before delivery:

```typescript
interface ModerationResult {
  approved: boolean;
  confidence: number;
  category?: ModerationCategory;
  action: 'approve' | 'flag' | 'block';
}

async function moderateMessage(content: string): Promise<ModerationResult> {
  // High confidence (>0.9): Auto-block
  // Medium confidence (0.7-0.9): Flag for review, allow
  // Low confidence (<0.7): Approve, monitor
}
```

### Blocked Content Response

```typescript
{
  "success": false,
  "error": {
    "code": "MESSAGE_BLOCKED",
    "message": "Message could not be sent. Please review our community guidelines."
  }
}
```

---

## API Endpoints

### GET /api/tasks/:id/messages

Get all messages for a task.

**Response:**
```typescript
{
  "success": true,
  "data": {
    "messages": Message[],
    "participants": {
      "poster": UserSummary,
      "worker": UserSummary
    },
    "has_more": boolean,
    "cursor": string | null
  }
}
```

### POST /api/tasks/:id/messages

Send a message.

**Request:**
```typescript
{
  "type": "text" | "photo" | "location" | "quick_response",
  "content"?: string,
  "photos"?: string[],  // Storage keys
  "location"?: { latitude: number, longitude: number },
  "quick_response_id"?: string
}
```

### PATCH /api/tasks/:id/messages/:messageId/read

Mark message as read.

---

## UI Components

### Chat Bubble

```typescript
interface ChatBubbleProps {
  message: Message;
  isSender: boolean;
  showAvatar: boolean;
  showTimestamp: boolean;
}
```

**Styling:**
- Sender: Primary color, right-aligned
- Receiver: Neutral color, left-aligned
- Max width: 80% of screen

### Quick Response Bar

Horizontal scroll of quick response chips.
Visible when text input is empty.

### Photo Grid

- 1 photo: Full width
- 2 photos: Side by side
- 3 photos: 2 + 1 grid

---

## Notifications

### Push Notifications

```typescript
{
  title: "{sender_name}",
  body: "{message_preview}",  // Max 100 chars
  data: {
    type: "task_message",
    task_id: string,
    message_id: string
  }
}
```

### Notification Rules

- Don't notify for own messages
- Batch if multiple messages within 30 seconds
- Respect DND settings
- Deep link to specific message

---

## Error Codes

| Code | Trigger | HTTP |
|------|---------|------|
| HX801 | Message outside allowed states | 409 |
| HX802 | Sender not task participant | 403 |
| HX803 | Photo count exceeds 3 | 400 |
| HX804 | Content exceeds 500 chars | 400 |

---

**See PRODUCT_SPEC.md §10 for canonical definitions.**

**END OF MESSAGING_SPEC v1.0.0**
