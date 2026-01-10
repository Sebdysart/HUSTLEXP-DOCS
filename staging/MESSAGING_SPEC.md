# In-App Messaging System Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Task-scoped communication between poster and worker

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Messaging exists to coordinate task completion, not to socialize.**

Every message is **task-scoped**. No general chat. No DMs. Only task-specific coordination.

**What This Unlocks:**
- Prevents disputes (coordination reduces misunderstandings)
- Reduces "no show" rate (real-time updates)
- Builds trust (transparent communication)
- Provides dispute evidence (chat history)

---

## §1. Messaging Scope Rules

### 1.1 Task-Scoped Only

**Rule:** Messages can only be sent **within an active task context**.

**Allowed:**
- ✅ Poster and worker can message during task lifecycle (ACCEPTED, PROOF_SUBMITTED, DISPUTED)
- ✅ Messages are scoped to specific task_id
- ✅ Messages are visible to both parties + admins (for disputes)

**Forbidden:**
- ❌ General DMs (no task context)
- ❌ Messages after task COMPLETED/CANCELLED (read-only archive)
- ❌ Messages before task ACCEPTED (no worker assigned)
- ❌ Messages to other users (only task participants)

### 1.2 Task Lifecycle Messaging Rules

| Task State | Can Poster Message? | Can Worker Message? | Purpose |
|------------|---------------------|---------------------|---------|
| **OPEN** | ❌ No | ❌ No | No worker assigned yet |
| **ACCEPTED** | ✅ Yes | ✅ Yes | Coordination during work |
| **PROOF_SUBMITTED** | ✅ Yes | ✅ Yes | Proof clarification |
| **DISPUTED** | ✅ Yes | ✅ Yes | Dispute discussion |
| **COMPLETED** | ❌ No (read-only) | ❌ No (read-only) | Archive only |
| **CANCELLED** | ❌ No (read-only) | ❌ No (read-only) | Archive only |
| **EXPIRED** | ❌ No (read-only) | ❌ No (read-only) | Archive only |

---

## §2. Message Types

### 2.1 Text Messages

**Standard text communication:**
- Maximum length: 500 characters
- No links (prevent phishing)
- No phone numbers (keep on platform)
- No email addresses (keep on platform)

**Content Moderation:**
- All messages scanned via AI (A2 authority)
- Flagged messages quarantined for review
- Users notified of moderation action (generic message)

---

### 2.2 Auto-Messages (Preset Responses)

**Quick responses to reduce typing:**

| Auto-Message | When to Use | Sends |
|--------------|-------------|-------|
| **"On my way"** | Worker heading to location | "I'm on my way to the task location. ETA: ~X minutes." |
| **"Running late"** | Worker delayed | "I'm running about X minutes late. I'll arrive at [time]." |
| **"Completed"** | Work finished, proof coming | "I've completed the task. Submitting proof now." |
| **"Need clarification"** | Unclear instructions | "I need clarification on [specific aspect]." |
| **"Photo request"** | Need more proof | "Could you take a photo of [specific thing]?" |

**Rules:**
- Auto-messages can be customized (user adds details)
- Auto-messages are logged same as text messages
- Auto-messages appear in chat history

---

### 2.3 Photo Sharing

**Photo sharing in chat:**
- Maximum 3 photos per message
- Maximum 5MB per photo
- Photos stored in evidence table (same as proof photos)
- Photos accessible in dispute resolution

**Use Cases:**
- Worker: "Is this what you meant?" (shows photo)
- Poster: "I need a photo of this area" (shows reference photo)
- Worker: "Here's progress update" (shows work in progress)

---

### 2.4 Location Sharing (Optional)

**Live location sharing:**
- Worker can share "I'm here" location (one-time)
- Poster sees worker location on map
- Location expires after 15 minutes
- Location only shared during ACCEPTED state

**Privacy:**
- Location not stored permanently
- Location not shared outside task context
- Location requires explicit user consent

---

## §3. Message Schema

### 3.1 Database Schema

```sql
CREATE TABLE task_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Context
  task_id UUID NOT NULL REFERENCES tasks(id),
  sender_id UUID NOT NULL REFERENCES users(id),
  receiver_id UUID NOT NULL REFERENCES users(id),
  
  -- Content
  message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('TEXT', 'AUTO', 'PHOTO', 'LOCATION')),
  content TEXT,  -- NULL for PHOTO/LOCATION types
  auto_message_template VARCHAR(50),  -- For AUTO type
  
  -- Photo attachments (for PHOTO type)
  photo_urls TEXT[],  -- Array of evidence IDs or URLs
  photo_count INTEGER DEFAULT 0 CHECK (photo_count >= 0 AND photo_count <= 3),
  
  -- Location (for LOCATION type)
  location_latitude DECIMAL(10, 8),
  location_longitude DECIMAL(11, 8),
  location_expires_at TIMESTAMPTZ,
  
  -- Status
  read_at TIMESTAMPTZ,  -- NULL = unread
  deleted_at TIMESTAMPTZ,  -- Soft delete (archived)
  
  -- Moderation
  moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'flagged', 'quarantined')),
  moderation_flags TEXT[],
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_task_messages_task ON task_messages(task_id, created_at DESC);
CREATE INDEX idx_task_messages_unread ON task_messages(receiver_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_task_messages_moderation ON task_messages(moderation_status) WHERE moderation_status = 'pending';
```

### 3.2 Message Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MSG-1** | Messages only allowed during ACCEPTED/PROOF_SUBMITTED/DISPUTED | Backend validation |
| **MSG-2** | Sender must be poster or worker for task | Backend validation |
| **MSG-3** | Maximum 3 photos per message | DB constraint |
| **MSG-4** | Maximum 500 characters per text message | Backend validation |
| **MSG-5** | Chat history is immutable after task COMPLETED | Backend validation |
| **MSG-6** | Read receipts are optional (privacy) | User preference |

---

## §4. Message Flow

### 4.1 Normal Coordination Flow

```
1. Task ACCEPTED
   → Worker receives: "Task accepted! You can message the poster."
   → Poster receives: "Worker assigned! You can message the worker."

2. Worker sends: "On my way" (auto-message)
   → Poster sees: "I'm on my way to the task location. ETA: ~15 minutes."

3. Worker sends: "I'm here" (location)
   → Poster sees: Worker location on map

4. Worker sends: "Completed!" (text)
   → Poster sees: "Completed!"

5. Poster sends: "Great! Submitting proof?" (text)
   → Worker sees: "Great! Submitting proof?"

6. Worker submits proof
   → Task state: PROOF_SUBMITTED
   → Messaging continues (for clarification)

7. Poster approves proof
   → Task state: COMPLETED
   → Messaging: READ-ONLY (archive)
```

---

### 4.2 Dispute Flow

```
1. Task DISPUTED
   → Messaging unlocked for both parties
   → Messages visible to admins

2. Both parties can send:
   - Evidence photos
   - Explanations
   - Clarifications

3. Admin can view all messages
   → Messages inform dispute resolution

4. Dispute resolved
   → Task state: COMPLETED or CANCELLED
   → Messaging: READ-ONLY (archive)
```

---

## §5. Read Receipts (Optional)

### 5.1 Read Receipt Rules

**Read Receipts are OPTIONAL:**
- User can enable/disable in settings
- Default: ENABLED
- Can't see read receipts if receiver disabled them

**Read Receipt Display:**
- "Delivered" = Message sent (server received)
- "Read" = Receiver opened chat (read_at timestamp)
- "Read at [time]" = Exact timestamp (if enabled)

### 5.2 Privacy Protection

**If receiver disabled read receipts:**
- Sender sees: "Delivered" only
- No "Read" indicator
- No timestamp

**This prevents:**
- Pressure to respond immediately
- Privacy invasion
- Stalking behavior

---

## §6. Content Moderation

### 6.1 Moderation Flow

**All messages are scanned via AI (A2 authority):**

```
Message sent
  → AI scans content (A2 - Propose)
  → If flagged: Quarantine, notify admin
  → If clean: Approve, deliver to receiver
```

### 6.2 Moderation Rules

| Content Type | Action | AI Authority |
|--------------|--------|--------------|
| **Profanity** | Flag → Quarantine | A2 |
| **Harassment** | Flag → Quarantine + Admin alert | A2 |
| **Spam** | Flag → Quarantine | A2 |
| **Phishing (links)** | Block → Don't send | A2 |
| **Personal info** | Warn → Allow (false positives) | A2 |
| **Clean** | Approve → Deliver | A2 |

### 6.3 User Notification

**If message is quarantined:**
```
"Your message was flagged for review. It will be delivered after moderation."
```

**If message is blocked:**
```
"Your message could not be sent. Please review our community guidelines."
```

**No shame language. Just facts.**

---

## §7. Chat History as Dispute Evidence

### 7.1 Evidence Rules

**Chat history is automatically available in disputes:**
- All messages from task are included
- Messages are immutable (cannot be edited)
- Messages are timestamped (chronological order)
- Photos shared in chat are evidence

### 7.2 Access Control

**During active task:**
- Poster and worker can see all messages

**During dispute:**
- Poster, worker, and admins can see all messages

**After task COMPLETED:**
- Messages archived (read-only)
- Accessible for 90 days after completion
- Deleted after 90 days (unless dispute)

---

## §8. Rate Limiting

### 8.1 Per-Task Limits

| Limit | Window | Reason |
|-------|--------|--------|
| **10 messages** | Per hour | Prevent spam |
| **3 photos** | Per message | Prevent abuse |
| **1 location share** | Per 15 minutes | Prevent tracking |

### 8.2 System Limits

| Limit | Window | Reason |
|-------|--------|--------|
| **100 messages** | Per day (per user) | Prevent platform abuse |
| **50 photos** | Per day (per user) | Prevent storage abuse |

**Exceeded Limits:**
- Return error: "Rate limit exceeded. Please wait [X] minutes."
- No shame language
- Clear explanation

---

## §9. API Endpoints

```typescript
// tRPC router: messaging
messaging.getThread({
  input: {
    taskId: string;
  },
  output: {
    messages: Message[];
    task_state: TaskState;
    can_send: boolean;  // Based on task state
  }
});

messaging.sendMessage({
  input: {
    taskId: string;
    messageType: 'TEXT' | 'AUTO' | 'PHOTO' | 'LOCATION';
    content?: string;  // For TEXT/AUTO
    autoMessageTemplate?: string;  // For AUTO
    photoUrls?: string[];  // For PHOTO
    location?: { lat: number; lng: number };  // For LOCATION
  },
  output: {
    messageId: string;
    status: 'sent' | 'pending_moderation' | 'blocked';
  }
});

messaging.markRead({
  input: {
    taskId: string;
    messageIds: string[];  // Array of message IDs to mark read
  },
  output: {
    marked_count: number;
  }
});
```

---

## §10. UI Requirements

### 10.1 Chat Screen

```
┌─────────────────────────────────────────────────────────┐
│  ← Task: Deep cleaning                                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Message history scrolls here]                         │
│                                                         │
│  Worker: On my way! ETA: ~15 min     2:34 PM           │
│                                                         │
│  Poster: Great, see you soon!         2:35 PM    ✓✓    │
│                                                         │
│  Worker: I'm here                     2:48 PM    ✓✓    │
│  [Location map preview]                                 │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [ Quick Actions: On my way | Running late | ... ]     │
│  [ Type message... ]                                    │
│  [ 📷 ] [ 📍 ] [ Send ]                                 │
└─────────────────────────────────────────────────────────┘
```

### 10.2 Auto-Message UI

**Quick action buttons:**
- "On my way" → Opens modal: "ETA? [input]" → Sends auto-message
- "Running late" → Opens modal: "How many minutes? [input]" → Sends auto-message
- "Completed" → Sends auto-message + prompts proof submission
- "Need clarification" → Opens text input → Sends as auto-message

---

## §11. Constitutional Alignment

### 11.1 Authority Model

- **Message Sending**: Backend service (Layer 1) validates task state
- **Content Moderation**: AI (A2 - Propose), Backend (decide)
- **Chat History Access**: Backend service (Layer 1) enforces access control
- **Read Receipts**: User preference (Layer 6), Backend (enforce)

### 11.2 AI Authority

**Content Moderation is A2 (Propose):**
- AI proposes: approve, flag, block
- Backend decides based on confidence
- High confidence (>0.9): Auto-block
- Low confidence (<0.9): Human review

---

## §12. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial messaging specification |

---

**END OF MESSAGING_SPEC v1.0.0**
