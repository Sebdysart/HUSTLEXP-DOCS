# GDPR & PRIVACY COMPLIANCE SPECIFICATION

**Authority:** PRODUCT_SPEC §16 (GDPR-1 through GDPR-5) | LEGAL_FRAMEWORK_SPEC
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED
**Resolves:** GAP-17 (GDPR stub)

---

## §1. Regulatory Scope

| Regulation | Applies When | HustleXP Trigger |
|---|---|---|
| **GDPR** (EU) | Processing data of EU residents | EU users sign up |
| **CCPA/CPRA** (California) | >$25M revenue OR >50K CA consumers | CA users sign up |
| **CAN-SPAM** | Sending commercial email to US users | Transactional + marketing email |
| **COPPA** | Users under 13 | N/A — platform is 18+ only |

**v1 launch market:** US only. GDPR applies if EU users access the platform. CCPA applies for California users.

---

## §2. Data Processing Inventory

### 2.1 Personal Data Collected

| Category | Data Points | Lawful Basis | Retention |
|---|---|---|---|
| **Identity** | Name, email, phone, profile photo | Contract performance | Account lifetime + 30 days |
| **Financial** | Stripe account ID, bank details (held by Stripe) | Contract performance | Per Stripe retention (7 years) |
| **Location** | GPS coordinates during tasks | Legitimate interest + consent | 90 days after task completion |
| **Communications** | Messages, support tickets | Contract performance | Account lifetime + 90 days |
| **Behavioral** | App usage, analytics events | Legitimate interest + consent | 12 months (raw), indefinite (aggregated) |
| **Verification** | Background check results, license photos | Legal obligation + consent | Account lifetime + 7 years (tax) |
| **Device** | Device fingerprint, IP address, app version | Legitimate interest | 90 days |
| **Trust** | XP, trust tier, shadow scores, fraud flags | Legitimate interest | Account lifetime |

### 2.2 Third-Party Data Processors

| Processor | Data Shared | DPA Required | Status |
|---|---|---|---|
| Stripe | Financial, identity | Yes | Stripe DPA covers |
| Firebase/Google | Auth tokens, push tokens | Yes | Google Cloud DPA |
| Supabase | All DB data | Yes | Supabase DPA |
| Checkr | Identity for background checks | Yes | Checkr DPA |
| PostHog | Analytics events (anonymized) | Yes | PostHog DPA |
| Google Maps | Location queries (no user ID) | No (anonymized) | N/A |
| Cloud Vision/Rekognition | Uploaded images (temp) | Yes | Provider DPA |

---

## §3. User Rights Implementation

### 3.1 Right to Access (GDPR Art. 15 / CCPA §1798.100)

**Endpoint:** `GET /api/v1/user/data-export`
**Process:**
1. User requests data export via Settings → Privacy → Download My Data
2. System creates entry in `gdpr_data_requests` table (type: 'EXPORT')
3. Background job compiles all user data into JSON within 72 hours
4. User receives push notification + email when export is ready
5. Download link valid for 7 days

**Data included:** Profile, tasks (posted + completed), messages, ratings, XP history, trust history, payment history, verification status, analytics events (last 12 months).

**SLA:** 72 hours (GDPR requires 30 days max, but we target 72h).

### 3.2 Right to Erasure (GDPR Art. 17 / CCPA §1798.105)

**Endpoint:** `POST /api/v1/user/delete-account`
**Process:**
1. User requests deletion via Settings → Privacy → Delete My Account
2. Confirmation prompt: "This will permanently delete your account and all data. Active tasks will be cancelled. This cannot be undone."
3. 7-day cooling-off period (user can cancel deletion request)
4. After 7 days, deletion job executes:

**Deletion scope:**
| Data | Action | Reason |
|---|---|---|
| Profile (name, email, phone, photo) | Delete | User data |
| Messages | Delete content, retain metadata (anonymized) | Counterparty record integrity |
| Tasks | Anonymize poster/worker ID | Transaction record integrity |
| Ratings | Anonymize author | Marketplace integrity |
| XP/Trust history | Delete | User data |
| Payment records | Retain anonymized for 7 years | Tax/legal requirement |
| Analytics events | Delete user_id linkage | Privacy |
| Stripe Connect account | Deauthorize (Stripe retains per their policy) | Stripe requirement |
| Background check results | Delete | User data |
| Device fingerprints | Delete | User data |
| Content moderation records | Retain anonymized | Platform safety |

**Exceptions to deletion:** Court orders, active disputes (deletion paused until resolved), tax records (anonymized but retained).

### 3.3 Right to Rectification (GDPR Art. 16)

Users can update their profile data at any time via Settings. Historical records (completed tasks, ratings) are immutable.

### 3.4 Right to Data Portability (GDPR Art. 20)

Same as Right to Access — data export is in machine-readable JSON format.

### 3.5 Right to Object to Processing (GDPR Art. 21)

**Analytics opt-out:** Settings → Privacy → Analytics → Off
- Disables PostHog tracking
- Disables non-essential analytics events
- Essential operational events (payment, trust) continue under legitimate interest

### 3.6 CCPA-Specific: Do Not Sell

HustleXP does NOT sell personal information. "Do Not Sell My Personal Information" link required in settings and privacy policy. Clicking it shows confirmation that no data is sold.

---

## §4. Consent Management

### 4.1 Consent Collection Points

| Consent | When Collected | Granularity | Default |
|---|---|---|---|
| Terms of Service | Signup (O-series) | All-or-nothing | Required |
| Privacy Policy | Signup (O-series) | All-or-nothing | Required |
| Analytics tracking | Signup (O-series) | Toggleable | Opt-in (EU) / Opt-out (US) |
| Push notifications | First task event | Toggleable | Opt-in |
| Marketing email | Signup (O-series) | Toggleable | Opt-in |
| Location services | First task creation/acceptance | Toggleable | Required for task flow |

### 4.2 Consent Storage

`user_consents` table (schema.sql) stores:
- consent_type, granted (boolean), granted_at, revoked_at, ip_address, app_version

### 4.3 Re-Consent

When Privacy Policy or ToS changes:
1. Version number incremented in `legal_document_versions` table
2. Next app open: blocking modal "We've updated our [Privacy Policy/ToS]. Please review and accept to continue."
3. User must accept to proceed
4. New consent record created with updated version

---

## §5. Cookie / Tracking Policy

**Web (if applicable):**
- Essential cookies: session, CSRF token — no consent required
- Analytics cookies: PostHog — consent required (EU), opt-out available (US)
- No third-party advertising cookies

**Mobile app:**
- No cookies (native app)
- IDFA/GAID: NOT collected unless analytics consent granted
- Apple ATT prompt: shown if analytics enabled (iOS 14.5+)

---

## §6. Data Breach Response

### 6.1 Detection

- Automated monitoring: Supabase audit logs, unusual data access patterns
- Human reporting: Any team member can report suspected breach

### 6.2 Response Timeline (GDPR Art. 33/34)

| Action | Deadline | Owner |
|---|---|---|
| Breach confirmed | Immediate | Engineering lead |
| Supervisory authority notified | 72 hours | Legal / Founder |
| Affected users notified | Without undue delay | Operations |
| Incident report completed | 7 days | Engineering lead |
| Remediation implemented | 30 days | Engineering team |

### 6.3 Notification Content

Notification to users includes: nature of breach, data affected, measures taken, contact information, recommendations for user self-protection.

---

## §7. Invariants

| ID | Rule | Enforcement |
|---|---|---|
| **GDPR-1** | User can export all personal data within 72 hours | Background job + SLA monitoring |
| **GDPR-2** | User can delete account with 7-day cooling off | Deletion pipeline + cooling period |
| **GDPR-3** | Consent is granular, recorded, and revocable | user_consents table + UI toggles |
| **GDPR-4** | No data processing without lawful basis | Data inventory (§2) maps every field |
| **GDPR-5** | Breach notification within 72 hours | Incident response protocol (§6) |
| **GDPR-6** | Third-party processors have DPAs | Processor inventory (§2.2) |
| **GDPR-7** | Anonymized data retained for business purposes | Deletion scope (§3.2) |

---

## Amendment History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | Feb 2026 | HustleXP Core | Promoted from stub. Full GDPR + CCPA coverage, data inventory, user rights implementation, consent management, breach response. Resolves GAP-17. |
