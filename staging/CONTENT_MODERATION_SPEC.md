# Content Moderation Workflow Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** Automated content scanning, human review queue, and user reporting system

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **Content moderation protects platform quality and user safety.**

All user-generated content is scanned automatically. Flagged content enters a review queue. Users can report violations. Escalation rules ensure swift action on serious issues.

**What This Unlocks:**
- Prevents harassment, spam, and abuse
- Maintains platform quality (no inappropriate content)
- Builds trust (users feel safe)
- Legal compliance (removes liability)
- Scalable moderation (automated + human)

---

## §1. Content Types to Moderate

### 1.1 Moderation Targets

| Content Type | Auto-Scan | Human Review | User Reporting |
|--------------|-----------|--------------|----------------|
| **Task Descriptions** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Task Titles** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Messages** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Profile Descriptions** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Ratings/Comments** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Photos (Task Proof)** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Profile Photos** | ✅ Yes | ✅ Yes | ✅ Yes |

---

### 1.2 Moderation Categories

| Category | Description | Severity | Action |
|----------|-------------|----------|--------|
| **Profanity** | Swear words, offensive language | Low | Auto-flag, review |
| **Harassment** | Threats, bullying, hate speech | High | Auto-flag, immediate review |
| **Spam** | Repetitive content, scams | Medium | Auto-flag, review |
| **Inappropriate** | Sexual content, violence | Critical | Auto-flag, immediate removal |
| **Personal Info** | Phone numbers, addresses | Medium | Auto-redact, review |
| **Phishing** | Links to suspicious sites | High | Auto-block, review |
| **Misleading** | False information, fake tasks | Medium | Auto-flag, review |

---

## §2. Automated Content Scanning

### 2.1 AI Scanning (A2 Authority)

**AI Role:** Propose moderation actions (A2 - Propose)

**AI Scanning Flow:**
```
Content submitted
  → AI scans content (A2 - Propose)
  → AI proposes: approve, flag, block
  → Backend decides based on confidence
  → High confidence (>0.9): Auto-block
  → Medium confidence (0.7-0.9): Flag for review
  → Low confidence (<0.7): Approve, monitor
```

---

### 2.2 AI Confidence Thresholds

| AI Confidence | Action | Human Review Required |
|---------------|--------|----------------------|
| **≥ 0.9** | Auto-block, quarantine | No (auto-action) |
| **0.7 - 0.9** | Flag, send to review queue | Yes (priority) |
| **0.5 - 0.7** | Flag, send to review queue | Yes (normal) |
| **< 0.5** | Approve, monitor | No (low priority) |

---

### 2.3 Scanning Triggers

**Real-Time Scanning:**
- Task created/updated
- Message sent
- Rating submitted
- Profile updated
- Photo uploaded

**Batch Scanning:**
- Daily scan of all active content (re-check)
- Scan content from flagged users (priority)

---

## §3. Human Review Queue

### 3.1 Queue Structure

**Review Queue Priority Levels:**

| Priority | Criteria | SLA |
|----------|----------|-----|
| **CRITICAL** | Harassment, threats, illegal content | 1 hour |
| **HIGH** | Spam, phishing, inappropriate | 4 hours |
| **MEDIUM** | Profanity, personal info | 24 hours |
| **LOW** | Misleading, borderline | 48 hours |

---

### 3.2 Review Workflow

**Review Process:**
1. Admin opens review queue
2. Admin sees flagged content with AI recommendations
3. Admin reviews content context (user history, related content)
4. Admin decides: approve, reject, escalate
5. Decision logged, user notified (if rejected)
6. Content actioned (hidden, deleted, or approved)

---

### 3.3 Review Queue Schema

```sql
CREATE TABLE content_moderation_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Content context
  content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('task', 'message', 'rating', 'profile', 'photo')),
  content_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id),
  
  -- Content snapshot (at time of flag)
  content_text TEXT,
  content_url TEXT,  -- For photos
  
  -- Moderation
  moderation_category VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  ai_confidence DECIMAL(3,2) CHECK (ai_confidence >= 0.0 AND ai_confidence <= 1.0),
  ai_recommendation VARCHAR(20) CHECK (ai_recommendation IN ('approve', 'flag', 'block')),
  
  -- Source
  flagged_by VARCHAR(20) NOT NULL CHECK (flagged_by IN ('ai', 'user_report', 'admin')),
  reporter_user_id UUID REFERENCES users(id),  -- If user-reported
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'approved', 'rejected', 'escalated')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20) CHECK (review_decision IN ('approve', 'reject', 'escalate', 'no_action')),
  review_notes TEXT,
  
  -- Timestamps
  flagged_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  sla_deadline TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_moderation_queue_status ON content_moderation_queue(status, severity, flagged_at);
CREATE INDEX idx_moderation_queue_sla ON content_moderation_queue(sla_deadline) WHERE status = 'pending';
CREATE INDEX idx_moderation_queue_user ON content_moderation_queue(user_id, flagged_at DESC);
```

---

## §4. User Reporting System

### 4.1 Report Categories

| Category | Description | Auto-Action |
|----------|-------------|-------------|
| **Harassment** | Bullying, threats, hate speech | Immediate flag, priority review |
| **Spam** | Repetitive, scam content | Auto-flag, normal review |
| **Inappropriate** | Sexual content, violence | Immediate flag, priority review |
| **Fake Task** | Misleading, fraudulent task | Auto-flag, normal review |
| **Personal Info** | Phone number, address exposed | Auto-redact, normal review |
| **Other** | Other violation | Flag, normal review |

---

### 4.2 Reporting Flow

**User Reports Content:**
1. User taps "Report" on content
2. User selects category (required)
3. User adds optional description
4. Report submitted → Content flagged
5. Priority assigned based on category
6. Added to review queue
7. User notified when resolved (optional)

---

### 4.3 Reporting Schema

```sql
CREATE TABLE content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Content being reported
  content_type VARCHAR(50) NOT NULL,
  content_id UUID NOT NULL,
  reported_content_user_id UUID NOT NULL REFERENCES users(id),
  
  -- Reporter
  reporter_user_id UUID NOT NULL REFERENCES users(id),
  
  -- Report details
  category VARCHAR(50) NOT NULL,
  description TEXT,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20),
  review_notes TEXT,
  
  -- Timestamps
  reported_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_content_reports_status ON content_reports(status, reported_at DESC);
CREATE INDEX idx_content_reports_content ON content_reports(content_type, content_id);
CREATE INDEX idx_content_reports_reporter ON content_reports(reporter_user_id, reported_at DESC);
```

---

## §5. Escalation Process

### 5.1 Escalation Rules

**Auto-Escalate Conditions:**
- Multiple reports on same content (≥3 reports)
- Multiple reports on same user (≥5 reports in 7 days)
- CRITICAL severity content (harassment, threats)
- Admin escalation request

---

### 5.2 Escalation Actions

| Escalation Level | Action | Who Handles |
|------------------|--------|-------------|
| **Level 1** | Normal review queue | Regular admin |
| **Level 2** | Priority review queue | Senior admin |
| **Level 3** | Immediate review | Lead admin + legal (if needed) |

---

## §6. Content Actions

### 6.1 Action Types

| Action | Description | Reversible |
|--------|-------------|------------|
| **Approve** | Content is fine, publish/keep | N/A |
| **Hide** | Hide from public, user can see | ✅ Yes |
| **Delete** | Permanently remove content | ❌ No |
| **Redact** | Remove sensitive parts, keep rest | ✅ Yes |
| **Warn User** | Send warning, keep content | N/A |
| **Suspend Account** | Temporarily suspend user | ✅ Yes |
| **Ban Account** | Permanently ban user | ❌ No |

---

### 6.2 User Notifications

**When Content is Rejected:**
```
"Your [content type] was removed for violating our community guidelines.
Reason: [category]
If you believe this is an error, you can appeal."
```

**When Account is Suspended:**
```
"Your account has been temporarily suspended for [reason].
Suspension ends: [date]
You can appeal this decision."
```

**No shame language. Just facts.**

---

## §7. Appeal Process

### 7.1 Appeal Rules

**Appeals Allowed For:**
- Content rejection
- Account suspension
- Account ban (permanent)

**Appeal Timeframe:**
- Content rejection: 7 days to appeal
- Account suspension: 14 days to appeal
- Account ban: 30 days to appeal

---

### 7.2 Appeal Workflow

1. User submits appeal (with explanation)
2. Appeal added to review queue (priority)
3. Different admin reviews (not original reviewer)
4. Admin decides: uphold or overturn
5. User notified of decision (final)

---

### 7.3 Appeal Schema

```sql
CREATE TABLE content_appeals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Original moderation action
  moderation_queue_id UUID REFERENCES content_moderation_queue(id),
  original_decision VARCHAR(20) NOT NULL,
  
  -- Appellant
  user_id UUID NOT NULL REFERENCES users(id),
  appeal_reason TEXT NOT NULL,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'upheld', 'overturned')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  review_decision VARCHAR(20),
  review_notes TEXT,
  
  -- Timestamps
  submitted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  deadline TIMESTAMPTZ NOT NULL  -- 7/14/30 days from original action
);

CREATE INDEX idx_content_appeals_status ON content_appeals(status, submitted_at DESC);
CREATE INDEX idx_content_appeals_user ON content_appeals(user_id, submitted_at DESC);
```

---

## §8. Content Moderation Service

### 8.1 API Endpoints

```typescript
// tRPC router: moderation (admin only)
moderation.getQueue({
  input: {
    priority?: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
    status?: 'pending' | 'reviewing';
    limit?: number;
    offset?: number;
  },
  output: {
    items: ModerationQueueItem[];
    totalCount: number;
  }
});

moderation.reviewItem({
  input: {
    queueId: string;
    decision: 'approve' | 'reject' | 'escalate';
    notes?: string;
    action?: 'hide' | 'delete' | 'redact' | 'warn' | 'suspend' | 'ban';
  },
  output: {
    status: 'reviewed';
    queueId: string;
  }
});

moderation.reportContent({
  input: {
    contentType: 'task' | 'message' | 'rating' | 'profile' | 'photo';
    contentId: string;
    category: string;
    description?: string;
  },
  output: {
    reportId: string;
    status: 'reported';
  }
});

moderation.appealDecision({
  input: {
    moderationQueueId: string;
    reason: string;
  },
  output: {
    appealId: string;
    status: 'pending';
  }
});
```

---

## §9. Content Moderation Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MOD-1** | All user-generated content is scanned | Backend trigger on create/update |
| **MOD-2** | CRITICAL content is auto-quarantined | Backend validation |
| **MOD-3** | Review queue items have SLA deadlines | Backend calculation |
| **MOD-4** | Appeals are reviewed by different admin | Backend assignment |
| **MOD-5** | Deleted content is permanently removed | Backend deletion |
| **MOD-6** | User notifications sent on actions | Backend notification service |

---

## §10. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Content scan coverage** | 100% | Content scanned / Content created |
| **Review queue SLA compliance** | >95% | Reviews completed within SLA / Total reviews |
| **False positive rate** | <10% | Appeals overturned / Total appeals |
| **User report accuracy** | >60% | Reports confirmed / Total reports |
| **Average review time** | <12h | Mean time from flag to review |
| **Appeal resolution time** | <48h | Mean time from appeal to decision |

---

## §11. Constitutional Alignment

### 11.1 Authority Model

- **Content Scanning**: AI (A2 - Propose), Backend (decide)
- **Flagging**: Automated (Layer 1)
- **Review Queue**: Admin (Layer 6 - Human)
- **Appeals**: Admin (Layer 6 - Human)

### 11.2 AI Authority

**Content Moderation is A2 (Propose):**
- AI proposes: approve, flag, block
- Backend decides based on confidence
- High confidence (>0.9): Auto-block
- Medium/low confidence: Human review

---

## §12. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial content moderation specification |

---

**END OF CONTENT_MODERATION_SPEC v1.0.0**
