# GDPR & Privacy Compliance Specification

**STATUS: CONSTITUTIONAL AUTHORITY — READY FOR INTEGRATION**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Purpose:** GDPR compliance, data privacy, and user rights management

---

## §0. Executive Summary

**Core Principle (LOCK THIS):**
> **User data belongs to users. They control it.**

GDPR compliance is not optional. It's a legal requirement. Users have the right to access, export, delete, and control their data.

**What This Unlocks:**
- Legal compliance (no fines, no shutdown risk)
- User trust (transparent data handling)
- Competitive advantage (users trust us with their data)
- Scalability (ready for EU expansion)

---

## §1. GDPR Rights

### 1.1 User Rights

| Right | Description | Implementation |
|-------|-------------|----------------|
| **Right to Access** | Users can request all their data | Export feature (JSON/CSV) |
| **Right to Rectification** | Users can correct inaccurate data | Profile edit, data correction |
| **Right to Erasure** | Users can delete their data | Account deletion, data purge |
| **Right to Data Portability** | Users can export their data | Data export feature |
| **Right to Restrict Processing** | Users can limit data use | Opt-out preferences |
| **Right to Object** | Users can object to processing | Opt-out preferences |
| **Right to Withdraw Consent** | Users can revoke consent | Consent management |

---

### 1.2 Data Categories

| Category | Examples | Retention | Deletion |
|----------|----------|-----------|----------|
| **Account Data** | Email, name, phone | Until account deletion | Immediate |
| **Profile Data** | Bio, photos, preferences | Until account deletion | Immediate |
| **Task Data** | Tasks, descriptions, photos | 7 years (tax/legal) | After retention |
| **Transaction Data** | Payments, escrow, refunds | 7 years (tax/legal) | After retention |
| **Message Data** | Chat messages, photos | 90 days after task completion | After retention |
| **Analytics Data** | Events, tracking | 90 days (raw), 2 years (aggregated) | After retention |
| **Location Data** | GPS coordinates | 30 days | After retention |

---

## §2. Data Export Feature

### 2.1 Export Scope

**Export Includes:**
- Account information (email, name, phone, etc.)
- Profile data (bio, photos, preferences)
- Task history (all tasks posted/accepted)
- Transaction history (payments, escrow, refunds)
- Message history (last 90 days)
- Rating history (ratings given/received)
- Trust tier history (tier changes, badges)
- Analytics events (last 90 days)

---

### 2.2 Export Format

**Export Formats:**
- JSON (structured, machine-readable)
- CSV (spreadsheet-compatible)
- PDF (human-readable report)

**Export Structure:**
```
hustlexp-export-{userId}-{timestamp}.zip
├── account.json
├── profile.json
├── tasks.json
├── transactions.json
├── messages.json
├── ratings.json
├── trust-history.json
├── analytics-events.json
└── README.txt (explanation of data)
```

---

### 2.3 Export Process

**User Requests Export:**
1. User goes to Settings → Privacy → Export My Data
2. User confirms request
3. System generates export (async job)
4. User receives email with download link (expires in 7 days)
5. Export available for 30 days, then deleted

**SLA:** Export generated within 30 days (GDPR requirement: 1 month)

---

## §3. Data Deletion Feature

### 3.1 Deletion Scope

**Immediate Deletion:**
- Account data (email, name, phone)
- Profile data (bio, photos, preferences)
- Preferences (notifications, privacy settings)
- Location data (last 30 days)
- Analytics events (last 90 days)

**Retention (Legal/Tax Requirements):**
- Transaction data (7 years)
- Task data (7 years)
- Dispute records (7 years)
- Tax documents (7 years)

**Anonymization (Instead of Deletion):**
- Tasks: Remove user_id, anonymize content
- Transactions: Remove user_id, keep amounts for tax
- Messages: Delete after 90 days (or anonymize)

---

### 3.2 Deletion Process

**User Requests Deletion:**
1. User goes to Settings → Privacy → Delete My Account
2. User confirms deletion (requires password)
3. System schedules deletion (7-day grace period)
4. User receives confirmation email
5. Account marked for deletion
6. After 7 days: Deletion executed
7. User receives final confirmation

**Grace Period (7 days):**
- User can cancel deletion within 7 days
- Account is suspended during grace period
- After 7 days: Permanent deletion

---

### 3.3 Cascade Deletion Rules

**When User Deletes Account:**
- **Tasks (as poster):** Anonymize (remove user_id, keep task data)
- **Tasks (as worker):** Anonymize (remove user_id, keep task data)
- **Messages:** Delete (after 90 days) or anonymize
- **Ratings:** Anonymize (remove user_id, keep rating data)
- **Analytics Events:** Delete (after 90 days)
- **Location Data:** Delete immediately

**Legal Retention Exceptions:**
- Transactions: Keep for 7 years (tax requirement)
- Disputes: Keep for 7 years (legal requirement)
- Tax documents: Keep for 7 years (IRS requirement)

---

## §4. Consent Management

### 4.1 Consent Types

| Consent Type | Purpose | Required | Withdrawable |
|--------------|---------|----------|--------------|
| **Account Creation** | Create account, use platform | ✅ Yes | ❌ No (required) |
| **Email Notifications** | Send email notifications | ❌ No | ✅ Yes |
| **Marketing Emails** | Send marketing communications | ❌ No | ✅ Yes |
| **Analytics Tracking** | Track user behavior | ❌ No | ✅ Yes |
| **Location Tracking** | Track location for matching | ✅ Yes (for matching) | ✅ Yes (opt-out) |
| **Photo Storage** | Store uploaded photos | ✅ Yes (for tasks) | ❌ No (required) |

---

### 4.2 Consent Schema

```sql
CREATE TABLE user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  -- Consent type
  consent_type VARCHAR(50) NOT NULL,
  purpose TEXT NOT NULL,
  
  -- Consent status
  granted BOOLEAN NOT NULL,
  granted_at TIMESTAMPTZ,
  withdrawn_at TIMESTAMPTZ,
  
  -- Metadata
  ip_address TEXT,  -- Anonymized
  user_agent TEXT,  -- Anonymized
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  UNIQUE(user_id, consent_type)
);

CREATE INDEX idx_user_consents_user ON user_consents(user_id, consent_type);
CREATE INDEX idx_user_consents_granted ON user_consents(granted, consent_type) WHERE granted = true;
```

---

## §5. Privacy Policy & Terms

### 5.1 Privacy Policy Requirements

**Must Include:**
- What data we collect
- Why we collect it
- How we use it
- Who we share it with (if anyone)
- How long we keep it
- User rights (GDPR rights)
- How to exercise rights (contact info)
- Cookie policy (if web)
- Data breach notification procedure

---

### 5.2 Terms of Service Requirements

**Must Include:**
- Platform rules (no harassment, no fraud)
- User responsibilities
- Platform responsibilities
- Dispute resolution process
- Limitation of liability
- Intellectual property rights
- Termination clause

---

## §6. Data Breach Notification

### 6.1 Breach Detection

**Breach Indicators:**
- Unauthorized database access
- Data leak detected
- Security incident reported
- Unusual data export activity

---

### 6.2 Breach Response

**Within 72 Hours (GDPR Requirement):**
1. Detect breach
2. Assess impact (what data, how many users)
3. Report to Data Protection Authority (DPA)
4. Notify affected users (if high risk)
5. Document breach (for audit)

**User Notification:**
- Email notification (within 72 hours)
- Explain what happened
- Explain what data was affected
- Explain what we're doing about it
- Explain what users should do

---

## §7. GDPR Compliance Schema

### 7.1 Data Request Schema

```sql
CREATE TABLE gdpr_data_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  -- Request type
  request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('export', 'deletion', 'rectification', 'restriction')),
  
  -- Request details
  request_details JSONB,
  /* Example:
  {
    "reason": "Moving to another platform",
    "format": "json",
    "scope": ["account", "tasks", "transactions"]
  }
  */
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'rejected', 'cancelled')),
  processed_by UUID REFERENCES users(id),
  processed_at TIMESTAMPTZ,
  
  -- Result
  result_url TEXT,  -- Download link for exports
  result_expires_at TIMESTAMPTZ,  -- Link expiration
  
  -- Timestamps
  requested_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  deadline TIMESTAMPTZ NOT NULL,  -- 30 days for export, 7 days for deletion
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_gdpr_requests_user ON gdpr_data_requests(user_id, requested_at DESC);
CREATE INDEX idx_gdpr_requests_status ON gdpr_data_requests(status, deadline) WHERE status IN ('pending', 'processing');
```

---

## §8. GDPR Service

### 8.1 API Endpoints

```typescript
// tRPC router: privacy
privacy.requestDataExport({
  input: {
    format?: 'json' | 'csv' | 'pdf';
    scope?: string[];  // Optional: specific data categories
  },
  output: {
    requestId: string;
    estimatedCompletion: Date;  // Within 30 days
    status: 'pending';
  }
});

privacy.requestAccountDeletion({
  input: {
    password: string;  // Confirmation
    reason?: string;
  },
  output: {
    requestId: string;
    deletionDate: Date;  // 7 days from now
    status: 'scheduled';
    canCancel: boolean;
  }
});

privacy.cancelDeletion({
  input: {
    requestId: string;
  },
  output: {
    status: 'cancelled';
  }
});

privacy.getConsents({
  input: {},
  output: {
    consents: Consent[];
  }
});

privacy.updateConsent({
  input: {
    consentType: string;
    granted: boolean;
  },
  output: {
    consent: Consent;
  }
});
```

---

## §9. GDPR Compliance Checklist

### 9.1 Pre-Launch Requirements

- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] Cookie policy (if web)
- [ ] Consent management UI implemented
- [ ] Data export feature implemented
- [ ] Data deletion feature implemented
- [ ] Data breach notification procedure documented
- [ ] DPA contact information registered (if EU users)
- [ ] Data Processing Agreement (DPA) with vendors (Stripe, etc.)

---

### 9.2 Ongoing Compliance

- [ ] Data export requests processed within 30 days
- [ ] Data deletion requests processed within 7 days
- [ ] Consent records maintained (audit trail)
- [ ] Data breach incidents reported within 72 hours
- [ ] Privacy policy updated annually
- [ ] User data retention policies enforced
- [ ] Third-party vendor DPAs reviewed annually

---

## §10. GDPR Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **GDPR-1** | Data export requests processed within 30 days | Backend SLA enforcement |
| **GDPR-2** | Data deletion requests processed within 7 days | Backend SLA enforcement |
| **GDPR-3** | User consent records are immutable (append-only) | DB constraint |
| **GDPR-4** | Legal retention periods enforced (7 years for transactions) | Backend validation |
| **GDPR-5** | Data breach notifications sent within 72 hours | Backend alerting |
| **GDPR-6** | Export links expire after 30 days | Backend cleanup job |

---

## §11. Metrics to Track

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Export request completion rate** | 100% | Exports completed / Exports requested |
| **Export request SLA compliance** | 100% | Exports within 30 days / Total exports |
| **Deletion request SLA compliance** | 100% | Deletions within 7 days / Total deletions |
| **Consent withdrawal rate** | TBD | Consent withdrawals / Total consents |
| **Data breach incidents** | 0 | Breaches detected (should be 0) |

---

## §12. Constitutional Alignment

### 12.1 Authority Model

- **Data Export**: Backend service (Layer 1)
- **Data Deletion**: Backend service (Layer 1)
- **Consent Management**: Backend service (Layer 1)
- **Privacy Policy**: Legal/Compliance (Layer 6 - Human)

### 12.2 AI Authority

**No AI involvement in GDPR compliance** (pure system processes)

---

## §13. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial GDPR compliance specification |

---

**END OF GDPR_COMPLIANCE_SPEC v1.0.0**
