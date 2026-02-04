# CONTENT MODERATION SPECIFICATION

**Authority:** PRODUCT_SPEC §15.7 (MOD-1 through MOD-4) | ARCHITECTURE.md
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED
**Resolves:** GAP-B7 (photo content scanning), GAP-10 (moderation stub)

---

## §1. Scope

All user-generated content (UGC) must pass through a moderation pipeline before becoming visible to other users. This covers:

- **Proof photos** (worker-submitted task completion evidence)
- **Message attachments** (in-app messaging photos)
- **Profile photos** (avatar uploads)
- **Task photos** (poster-attached task images)
- **Task descriptions** (text content in task creation)
- **Message text** (in-app messaging content)
- **Usernames / display names**
- **Dispute evidence submissions**

---

## §2. Moderation Architecture

```
User Upload → Pre-Storage Scan → Cloud Moderation API → Decision Router
                                                              │
                                    ┌─────────────┬───────────┼──────────────┐
                                    ▼             ▼           ▼              ▼
                                 APPROVED     FLAGGED     REJECTED      ILLEGAL
                                    │             │           │              │
                                 Store +       Queue for     Block +      Block +
                                 Serve        Human Review   Notify User  Report to
                                                                         NCMEC/Law
```

### 2.1 Image Moderation Pipeline

**Technology:** Google Cloud Vision SafeSearch Detection (primary) + AWS Rekognition Content Moderation (fallback)

**Flow:**
1. Client uploads image via signed URL (STORAGE_SPEC.md flow)
2. BEFORE moving to permanent storage, image is sent to moderation API
3. Moderation API returns category scores
4. Decision router applies thresholds (see §3)
5. Image either stored (approved), queued (flagged), or blocked (rejected/illegal)

```typescript
interface ModerationResult {
  image_id: string;
  provider: 'google_vision' | 'aws_rekognition';
  scores: {
    adult: number;       // 0.0 - 1.0 (nudity, sexual content)
    violence: number;    // 0.0 - 1.0 (gore, weapons)
    racy: number;        // 0.0 - 1.0 (suggestive but not explicit)
    medical: number;     // 0.0 - 1.0 (medical/injury images)
    spoof: number;       // 0.0 - 1.0 (fake/manipulated)
  };
  csam_detected: boolean;  // Separate binary flag — zero tolerance
  decision: 'APPROVED' | 'FLAGGED' | 'REJECTED' | 'ILLEGAL';
  moderated_at: string;    // ISO timestamp
}
```

### 2.2 Text Moderation Pipeline

**Technology:** OpenAI Moderation API (free, fast) or custom classifier

**Covered text:** Task descriptions, messages, display names, dispute evidence text.

```typescript
interface TextModerationResult {
  text_hash: string;
  categories: {
    harassment: boolean;
    hate_speech: boolean;
    self_harm: boolean;
    sexual: boolean;
    violence: boolean;
    spam: boolean;
  };
  flagged: boolean;
  decision: 'APPROVED' | 'FLAGGED' | 'REJECTED';
}
```

---

## §3. Decision Thresholds

### 3.1 Image Thresholds

| Category | Auto-Approve | Flag for Review | Auto-Reject |
|---|---|---|---|
| adult | < 0.3 | 0.3 – 0.7 | > 0.7 |
| violence | < 0.4 | 0.4 – 0.7 | > 0.7 |
| racy | < 0.5 | 0.5 – 0.8 | > 0.8 |
| medical | < 0.6 | 0.6 – 0.9 | > 0.9 |
| spoof | < 0.8 | N/A | > 0.8 (proof photos only) |
| csam_detected | N/A | N/A | ANY true → ILLEGAL |

**Compound rule:** If ANY category triggers auto-reject, the image is rejected. If ANY category is in the review range AND no category triggers auto-reject, the image is flagged.

### 3.2 Text Thresholds

| Category | Action |
|---|---|
| harassment = true | Flag for review |
| hate_speech = true | Auto-reject |
| self_harm = true | Flag for review + alert |
| sexual = true | Auto-reject |
| violence = true | Flag for review |
| spam = true | Auto-reject + shadow flag user |

---

## §4. Content-Type Specific Rules

### 4.1 Proof Photos (Critical Path)

Proof photos are the most sensitive UGC because they affect payment flow.

- **Scan timing:** Synchronous — worker cannot submit proof until ALL proof photos pass moderation
- **Timeout:** 10 seconds max. If moderation API times out, queue for async review and allow submission with `moderation_status: PENDING`
- **Pending state:** Task stays in PROOF_SUBMITTED but payout is held until moderation resolves
- **False positive handling:** If proof photo is flagged and later approved by human review, task flow continues normally

### 4.2 Message Attachments

- **Scan timing:** Asynchronous — message sends immediately with placeholder, replaced with image after approval
- **Rejected:** Message shows "[Image removed — violates community guidelines]"
- **User notification:** Sender notified that their image was removed

### 4.3 Profile Photos

- **Scan timing:** Asynchronous — default avatar shown until photo approved
- **Rejected:** Reverts to default avatar. User notified with reason.

### 4.4 Task Photos

- **Scan timing:** Synchronous — task cannot be posted until photos pass
- **Same rules as proof photos** (affects marketplace integrity)

---

## §5. Human Review Queue

### 5.1 Queue Management

Flagged content enters the `content_moderation_queue` table (schema.sql):

```
Queue priority:
1. ILLEGAL reports (immediate — <15 min SLA)
2. Proof photos (blocks payment — <1 hour SLA)
3. Task photos (blocks posting — <1 hour SLA)
4. Messages (user experience — <4 hour SLA)
5. Profile photos (cosmetic — <24 hour SLA)
```

### 5.2 Admin Review Actions

| Action | Effect |
|---|---|
| **Approve** | Content becomes visible. Moderation status → APPROVED_MANUAL. |
| **Reject** | Content permanently blocked. User notified with reason and policy link. |
| **Escalate** | Forward to senior admin / legal. Content remains hidden. |
| **Ban User** | Account suspended. All pending content rejected. |

### 5.3 SLA Enforcement

Background job monitors queue age. If SLA exceeded:
- 1× SLA: alert operations Slack channel
- 2× SLA: alert founder
- For proof photos: if review pending >4 hours, auto-approve with flag for retrospective review (don't block worker payment indefinitely)

---

## §6. CSAM / Illegal Content Protocol

**Zero tolerance. Mandatory reporting.**

1. If `csam_detected = true` from ANY moderation provider:
   - Content NEVER stored (delete from temp storage immediately)
   - User account suspended instantly
   - Report filed with NCMEC (National Center for Missing & Exploited Children) via CyberTipline API
   - All user content queued for retrospective scan
   - IP address and device fingerprint logged for law enforcement
   - Internal incident report created

2. If human reviewer identifies potential illegal content:
   - Same protocol as automated detection
   - Reviewer does not need to confirm — report first, investigate second

**Legal requirement:** 18 U.S.C. § 2258A requires electronic service providers to report CSAM to NCMEC.

---

## §7. User-Reported Content

### 7.1 Report Flow

Any user can report content via in-app report button.

**Report categories:**
- Inappropriate/sexual content
- Harassment/threats
- Spam/scam
- Fake/misleading proof
- Other (free text)

**Report creates entry in `content_reports` table.**

### 7.2 Report Processing

- 3+ unique reports on same content → auto-hide + priority queue for review
- Reporter receives "Thank you" confirmation
- Reporter is NOT notified of outcome (prevents weaponized reporting)
- False reporting pattern (>10 reports, <20% confirmed) → reporter warned, then report-banned

---

## §8. Appeals

### 8.1 Appeal Flow

Users can appeal rejected content via `content_appeals` table.

- Appeal window: 7 days from rejection
- One appeal per content item
- Different human reviewer handles appeal (not original reviewer)
- Appeal decision is final

### 8.2 Appeal SLAs

| Content Type | Appeal Review SLA |
|---|---|
| Proof photos | 24 hours |
| Task photos | 24 hours |
| Messages | 48 hours |
| Profile photos | 72 hours |

---

## §9. Moderation Invariants

| ID | Rule | Enforcement |
|---|---|---|
| **MOD-1** | No UGC visible without moderation pass | Pre-storage scan for sync content, placeholder for async |
| **MOD-2** | CSAM = instant block + NCMEC report | Automated pipeline, no human in the loop for blocking |
| **MOD-3** | Human review SLA enforced | Background job + alerting |
| **MOD-4** | Appeals handled by different reviewer | Application guard on reviewer assignment |
| **MOD-5** | Moderation API failure ≠ content blocked | Timeout → queue for async, allow with PENDING status |
| **MOD-6** | No content stored before scan | Temp storage only until moderation completes |

---

## §10. Cost Estimation

| Provider | Pricing | Estimated Monthly (1K users) |
|---|---|---|
| Google Cloud Vision | $1.50/1K images | ~$75 (50K images/month) |
| AWS Rekognition | $1.00/1K images | ~$50 (fallback only) |
| OpenAI Moderation API | Free | $0 |

---

## §11. Schema Dependencies

Tables used: `content_moderation_queue`, `content_reports`, `content_appeals` (already in schema.sql).

Additional columns needed on existing tables:
- `proof_photos.moderation_status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'FLAGGED')
- `task_messages.moderation_status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'FLAGGED') — for attachments
- `users.profile_photo_moderation_status`

---

## Amendment History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | Feb 2026 | HustleXP Core | Promoted from stub. Full moderation pipeline, photo scanning, CSAM protocol, human review queue, appeals, SLA enforcement. Resolves GAP-B7 + GAP-10. |
