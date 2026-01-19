# Push Notification System Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Real-time notifications for task updates, messages, and system events

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Notifications are information, not interruptions.**

Users receive **only actionable, relevant notifications**. No spam. No marketing. No noise.

**What This Unlocks:**
- Faster task acceptance (instant alerts)
- Better coordination (real-time updates)
- Higher completion rates (deadline reminders)
- Reduced disputes (status updates)

---

## §1. Notification Categories

### 1.1 Task-Related Notifications

| Category | Trigger | Priority | Sound | Badge |
|----------|---------|----------|-------|-------|
| **Task Accepted** | Worker accepts your task | HIGH | Yes | Yes |
| **Task Completed** | Worker completes task | HIGH | Yes | Yes |
| **Proof Submitted** | Worker submits proof | HIGH | Yes | Yes |
| **Proof Approved** | Poster approves proof | MEDIUM | Yes | Yes |
| **Proof Rejected** | Poster rejects proof | HIGH | Yes | Yes |
| **Task Cancelled** | Task cancelled by poster | MEDIUM | Yes | No |
| **Task Expired** | Task deadline passed | LOW | No | No |
| **New Matching Task** | High-match task posted nearby | MEDIUM | No | Yes |
| **Live Mode Task** | LIVE task broadcast | HIGH | Yes | Yes |

### 1.2 Message Notifications

| Category | Trigger | Priority | Sound | Badge |
|----------|---------|----------|-------|-------|
| **New Message** | Message received in task thread | HIGH | Yes | Yes |
| **Unread Messages** | 3+ unread messages in thread | MEDIUM | No | Yes |

### 1.3 Trust & Reputation

| Category | Trigger | Priority | Sound | Badge |
|----------|---------|----------|-------|-------|
| **Trust Tier Upgraded** | User promoted to higher tier | HIGH | Yes | Yes |
| **Badge Earned** | New badge awarded | MEDIUM | No | Yes |
| **Dispute Opened** | Dispute filed against you | HIGH | Yes | Yes |
| **Dispute Resolved** | Dispute resolution complete | MEDIUM | Yes | No |

### 1.4 Escrow & Payment

| Category | Trigger | Priority | Sound | Badge |
|----------|---------|----------|-------|-------|
| **Escrow Funded** | Escrow payment confirmed | HIGH | Yes | Yes |
| **Payment Released** | Payment released to worker | HIGH | Yes | Yes |
| **Refund Issued** | Refund processed | MEDIUM | Yes | No |

### 1.5 System & Safety

| Category | Trigger | Priority | Sound | Badge |
|----------|---------|----------|-------|-------|
| **Account Suspended** | Account suspended (violation) | HIGH | Yes | Yes |
| **Security Alert** | Unusual login detected | HIGH | Yes | Yes |
| **Password Changed** | Password changed (confirmation) | LOW | No | No |

---

## §2. Notification Delivery Rules

### 2.1 Do Not Disturb (DND) Windows

**User-configurable quiet hours:**
- Default: 10 PM - 7 AM
- During DND: Only HIGH priority notifications
- DND can be overridden per category

**DND Exceptions:**
- Task accepted (always notify, even in DND)
- Payment released (always notify, even in DND)
- Security alerts (always notify, even in DND)

---

### 2.2 Frequency Limits

**Per-category limits:**

| Category | Max Per Hour | Max Per Day |
|----------|--------------|-------------|
| **New Matching Task** | 5 | 20 |
| **Live Mode Task** | 10 | 50 |
| **Message** | Unlimited | Unlimited (rate-limited by messaging system) |
| **Task Updates** | Unlimited | Unlimited |
| **Trust/Reputation** | 3 | 10 |
| **Escrow/Payment** | Unlimited | Unlimited |
| **System** | 5 | 20 |

**Exceeded Limits:**
- Notifications batched ("You have 5 new matching tasks")
- No individual notifications sent
- Batch notification sent at end of hour

---

### 2.3 Notification Grouping

**Group similar notifications:**

```
Before grouping:
- "Task accepted: Deep cleaning" (2:34 PM)
- "Task accepted: Moving help" (2:36 PM)
- "Task accepted: Dog walking" (2:38 PM)

After grouping:
- "3 tasks accepted" (2:38 PM)
  → Tap to see details
```

**Grouping Rules:**
- Same category notifications grouped if within 5 minutes
- Maximum 5 notifications per group
- Group breaks after 5 minutes of silence

---

## §3. Notification Content

### 3.1 Notification Title Format

**Task-Related:**
```
"Task Accepted: [Task Title]"
"Proof Submitted: [Task Title]"
"Payment Released: $45.00"
```

**Message:**
```
"[Sender Name]: [Message Preview]"
"New message from [Sender Name]"
```

**Trust:**
```
"Trust Tier Upgraded: VERIFIED"
"Badge Earned: Early Bird"
```

**System:**
```
"Security Alert"
"Account Action Required"
```

---

### 3.2 Notification Body Format

**Task-Related:**
```
"Your task 'Deep cleaning' was accepted by Sarah K. (VERIFIED). Escrow funded: $45.00"
"Sarah K. submitted proof for 'Deep cleaning'. Review now."
"Payment of $38.25 released to your account for 'Deep cleaning'."
```

**Message:**
```
"[First 100 characters of message]..."
```

**Trust:**
```
"You've been promoted to VERIFIED tier. New benefits unlocked!"
"You earned the 'Early Bird' badge for completing 10 morning tasks."
```

---

### 3.3 Deep Linking

**All notifications include deep links:**

```typescript
interface Notification {
  title: string;
  body: string;
  category: NotificationCategory;
  deep_link: string;  // e.g., "hustlexp://task/abc123" or "hustlexp://message/thread/xyz789"
  task_id?: string;  // If task-related
  metadata?: Record<string, any>;
}
```

**Deep Link Format:**
- Task: `hustlexp://task/{taskId}`
- Message: `hustlexp://message/{taskId}`
- Profile: `hustlexp://profile/{userId}`
- Trust: `hustlexp://trust`
- Settings: `hustlexp://settings/notifications`

---

## §4. Notification Preferences

### 4.1 Per-Category Preferences

**User can control:**

| Category | Enable/Disable | Sound | Badge | Quiet Hours Override |
|----------|----------------|-------|-------|---------------------|
| Task Accepted | ✅ | ✅ | ✅ | ✅ |
| Task Completed | ✅ | ✅ | ✅ | ✅ |
| Proof Submitted | ✅ | ✅ | ✅ | ✅ |
| Proof Approved | ✅ | ✅ | ✅ | ❌ |
| New Matching Task | ✅ | ❌ | ✅ | ❌ |
| Live Mode Task | ✅ | ✅ | ✅ | ✅ |
| New Message | ✅ | ✅ | ✅ | ✅ |
| Trust Tier Upgraded | ✅ | ✅ | ✅ | ❌ |
| Badge Earned | ✅ | ❌ | ✅ | ❌ |
| Escrow Funded | ✅ | ✅ | ✅ | ✅ |
| Payment Released | ✅ | ✅ | ✅ | ✅ |
| System Alerts | ✅ | ✅ | ✅ | ✅ |

**Default Settings:**
- All enabled
- All sounds enabled
- All badges enabled
- Quiet hours: 10 PM - 7 AM
- No quiet hours override (default)

---

### 4.2 Notification Channels

**Multi-channel delivery:**

| Channel | Priority | Use Case |
|---------|----------|----------|
| **Push (iOS/Android)** | Primary | Real-time alerts |
| **In-App** | Secondary | App open notifications |
| **Email** | Optional | Important only (payment, security) |
| **SMS** | Optional | Critical only (account suspension, security) |

**Email/SMS Opt-In:**
- Email: Opt-in for payment/security notifications
- SMS: Opt-in for critical security alerts only
- Default: Push notifications only

---

## §5. Notification Schema

### 5.1 Database Schema

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recipient
  user_id UUID NOT NULL REFERENCES users(id),
  
  -- Content
  category VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  
  -- Deep linking
  deep_link TEXT NOT NULL,
  task_id UUID REFERENCES tasks(id),
  metadata JSONB,
  
  -- Delivery
  channels TEXT[] NOT NULL DEFAULT ARRAY['push'],  -- 'push', 'email', 'sms', 'in_app'
  priority VARCHAR(10) NOT NULL CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  
  -- Status
  sent_at TIMESTAMPTZ,  -- NULL = pending
  delivered_at TIMESTAMPTZ,  -- NULL = not delivered
  read_at TIMESTAMPTZ,  -- NULL = unread
  clicked_at TIMESTAMPTZ,  -- NULL = not clicked
  
  -- Grouping
  group_id UUID,  -- NULL = not grouped, same UUID = grouped
  group_position INTEGER,  -- Position in group (1, 2, 3, ...)
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ,  -- NULL = no expiration
  
  CHECK (sent_at IS NULL OR sent_at >= created_at),
  CHECK (delivered_at IS NULL OR delivered_at >= sent_at),
  CHECK (read_at IS NULL OR read_at >= delivered_at)
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_user_recent ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_pending ON notifications(sent_at) WHERE sent_at IS NULL;
CREATE INDEX idx_notifications_task ON notifications(task_id) WHERE task_id IS NOT NULL;
```

### 5.2 User Preferences Schema

```sql
CREATE TABLE notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  
  -- Quiet hours
  quiet_hours_enabled BOOLEAN DEFAULT true,
  quiet_hours_start TIME DEFAULT '22:00:00',
  quiet_hours_end TIME DEFAULT '07:00:00',
  
  -- Channel preferences
  push_enabled BOOLEAN DEFAULT true,
  email_enabled BOOLEAN DEFAULT false,
  sms_enabled BOOLEAN DEFAULT false,
  
  -- Per-category preferences (JSONB for flexibility)
  category_preferences JSONB NOT NULL DEFAULT '{}',
  /* Example:
  {
    "task_accepted": {
      "enabled": true,
      "sound": true,
      "badge": true,
      "quiet_hours_override": true
    },
    "new_matching_task": {
      "enabled": true,
      "sound": false,
      "badge": true,
      "quiet_hours_override": false
    }
  }
  */
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

---

## §6. Notification Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **NOTIF-1** | Notifications only sent to task participants (poster/worker) | Backend validation |
| **NOTIF-2** | HIGH priority notifications bypass quiet hours | Backend logic |
| **NOTIF-3** | Frequency limits enforced per category | Backend rate limiting |
| **NOTIF-4** | Deep links must be valid (task exists, user has access) | Backend validation |
| **NOTIF-5** | Notifications expire after 30 days | Backend cleanup job |
| **NOTIF-6** | Grouped notifications share same category | Backend grouping logic |

---

## §7. Notification Delivery Service

### 7.1 Delivery Flow

```
1. Event occurs (task accepted, message sent, etc.)
2. NotificationService.createNotification() called
3. Check user preferences (enabled? quiet hours?)
4. Check frequency limits (rate limiting)
5. Create notification record (status: pending)
6. Queue for delivery (push service, email service, etc.)
7. Mark sent_at when queued
8. Mark delivered_at when confirmed by service
9. Track read_at when user opens notification
10. Track clicked_at when user taps deep link
```

### 7.2 Push Notification Service

**Integration with:**
- iOS: Apple Push Notification Service (APNs)
- Android: Firebase Cloud Messaging (FCM)

**Push Payload Format:**
```json
{
  "aps": {
    "alert": {
      "title": "Task Accepted",
      "body": "Your task 'Deep cleaning' was accepted by Sarah K."
    },
    "sound": "default",
    "badge": 1,
    "category": "TASK_ACCEPTED",
    "thread-id": "task-abc123"
  },
  "deep_link": "hustlexp://task/abc123",
  "task_id": "abc123"
}
```

---

## §8. API Endpoints

```typescript
// tRPC router: notifications
notifications.getList({
  input: {
    limit?: number;  // Default: 50
    offset?: number;  // Default: 0
    unread_only?: boolean;  // Default: false
  },
  output: {
    notifications: Notification[];
    total_count: number;
    unread_count: number;
    has_more: boolean;
  }
});

notifications.markRead({
  input: {
    notificationIds: string[];  // Array of notification IDs
  },
  output: {
    marked_count: number;
  }
});

notifications.markAllRead({
  input: {},
  output: {
    marked_count: number;
  }
});

notifications.getPreferences({
  input: {},
  output: {
    preferences: NotificationPreferences;
  }
});

notifications.updatePreferences({
  input: {
    preferences: Partial<NotificationPreferences>;
  },
  output: {
    preferences: NotificationPreferences;
  }
});
```

---

## §9. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Delivery rate** | >95% | Notifications delivered / Notifications sent |
| **Open rate** | >40% | Notifications opened / Notifications delivered |
| **Click-through rate** | >30% | Deep links clicked / Notifications opened |
| **Quiet hours compliance** | >99% | Notifications respecting quiet hours / Total notifications |
| **Frequency limit compliance** | 100% | No violations of rate limits |
| **Grouping effectiveness** | >20% reduction | Reduced notification volume via grouping |

---

## §10. Constitutional Alignment

### 10.1 Authority Model

- **Notification Creation**: Backend service (Layer 1)
- **Notification Delivery**: Backend service (Layer 1) + External services (APNs, FCM)
- **Preference Management**: Backend service (Layer 1)
- **Rate Limiting**: Backend service (Layer 1)

### 10.2 AI Authority

**No AI involvement in notifications** (pure system events)

---

## §11. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial notification specification |

---

**END OF NOTIFICATION_SPEC v1.0.0**
