# LEGAL FRAMEWORK SPECIFICATION

**Authority:** PRODUCT_SPEC | FINISHED_STATE boundary
**Status:** v1.0 — Launch-ready specification

---

## 1. Terms of Service (ToS)

### 1.1 Required Sections
- Service description: task marketplace connecting posters and workers
- User eligibility: 18+ years, valid US address, verified identity
- Independent contractor classification: workers are NOT employees
- Platform role: facilitator only, not employer or principal
- Payment terms: escrow, platform fee (15%), Stripe processing
- Dispute resolution: binding arbitration (mutual agreement)
- Limitation of liability: platform not liable for task outcomes
- Content policy: prohibited tasks, prohibited content
- Termination: platform may suspend/ban for policy violations
- Governing law: State of [incorporation state]

### 1.2 Acceptance Flow
- ToS acceptance required during signup (before account activation)
- Version-stamped: `tos_version` stored on user record
- ToS updates: users prompted to re-accept on next login
- Cannot use app until current ToS version accepted
- Acceptance timestamp and version logged for legal record

### 1.3 Database
```sql
-- Already in users table conceptually; enforce:
ALTER TABLE users ADD COLUMN IF NOT EXISTS tos_version TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS tos_accepted_at TIMESTAMPTZ;
```

## 2. Privacy Policy

### 2.1 Required Disclosures
- Data collected: name, email, phone, location (during tasks), photos, device info
- Data usage: marketplace operations, safety, fraud prevention, analytics
- Data sharing: Stripe (payments), Google Maps (location), Firebase (auth/push)
- Data retention: account data retained while active, deleted 30 days after account deletion
- User rights: access, correction, deletion (GDPR_COMPLIANCE_SPEC for detail)
- Cookies/tracking: analytics SDK disclosure, IDFA usage
- Children's privacy: no users under 18, COPPA compliance
- California residents: CCPA rights disclosure
- Contact: privacy@hustlexp.com

### 2.2 Privacy Manifest (iOS)
Required for App Store submission. See APP_STORE_COMPLIANCE_SPEC §2.

## 3. Independent Contractor Agreement

### 3.1 Worker Classification
Workers on HustleXP are independent contractors, not employees. Basis:
- Workers choose which tasks to accept (no obligation)
- Workers set their own schedule
- Workers can work for other platforms simultaneously
- Platform does not control HOW work is performed (only WHAT the task requires)
- Workers provide their own tools/equipment
- Workers are responsible for their own taxes (TAX_REPORTING_SPEC)

### 3.2 Worker Agreement Terms
- Acknowledged during Stripe Connect onboarding
- Includes: IC classification acknowledgment, payment terms, dispute process
- Worker confirms understanding that they are not an employee

### 3.3 Misclassification Risk Mitigation
- Platform never uses "employee" language in any communication
- No performance reviews, mandatory schedules, or exclusive dealing requirements
- No benefits, vacation, or sick leave offered
- All task instructions come from POSTER, not platform
- Platform's role limited to: matching, payment processing, dispute resolution

## 4. Platform Insurance

### 4.1 Required Coverage (Pre-Launch)

| Policy | Purpose | Minimum Coverage |
|--------|---------|-----------------|
| General Liability | Bodily injury/property damage claims | $1M per occurrence / $2M aggregate |
| Professional Liability (E&O) | Service failures, tech errors | $1M per occurrence |
| Cyber Liability | Data breach, privacy violations | $1M per occurrence |

### 4.2 Worker Insurance
- Workers are independent contractors — responsible for their own insurance
- Task categories requiring insurance (plumbing, electrical, etc.) enforced via ONBOARDING_SPEC verification
- Platform displays "Workers are independent contractors. Verify insurance before hiring." disclaimer

### 4.3 Poster Liability Waiver
- During task creation, poster acknowledges:
  - "I understand that workers are independent contractors"
  - "I am responsible for providing a safe work environment"
  - "HustleXP facilitates the connection but is not responsible for work quality"

## 5. Prohibited Tasks

Tasks that violate law, safety, or platform policy:

| Category | Examples | Enforcement |
|----------|----------|-------------|
| Illegal activity | Drug delivery, fraud, theft | Auto-reject + ban |
| Adult content | Sexual services | Auto-reject + ban |
| Dangerous tasks | Hazmat handling without certification | Verification gate |
| Discrimination | "Only [demographic] need apply" | Content moderation flag |
| Weapons | Firearms transport, ammunition | Auto-reject |
| Financial crime | Money laundering, counterfeit | Auto-reject + report |

Prohibited task detection: AI content filter on task.create (CONTENT_MODERATION_SPEC §3).

## 6. Background Check Policy

- Background checks available for workers in high-trust categories
- Powered by third-party provider (Checkr or equivalent)
- Results stored by provider, HustleXP stores only: PASS/FAIL/PENDING
- Workers can dispute results through provider's process
- Background check status visible to posters for applicable task categories

## 7. Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| LEGAL-1 | No account activation without ToS acceptance | Signup flow gate |
| LEGAL-2 | ToS version mismatch blocks app usage | API middleware check |
| LEGAL-3 | Privacy policy accessible from every screen (Settings) | UI requirement |
| LEGAL-4 | No "employee" language in any platform communication | Copy review |
| LEGAL-5 | Prohibited task list enforced at task.create | AI filter + manual review |

---

**END OF LEGAL_FRAMEWORK_SPEC v1.0**
