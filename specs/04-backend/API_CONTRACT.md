# HustleXP API Contract v1.5.0

**STATUS: RECONCILIATION IN PROGRESS**
**Authority:** `backend/src/routers` implementation, `HUSTLEXPFINAL1` service call surface, `schema.sql`, and this document
**Last Updated:** March 8, 2026
**Protocol:** tRPC over HTTP
**Authentication:** Firebase JWT tokens

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Error Codes](#error-codes)
4. [Task Endpoints](#task-endpoints)
5. [Escrow Endpoints](#escrow-endpoints)
6. [Proof Endpoints](#proof-endpoints)
7. [User Endpoints](#user-endpoints)
8. [Dispute Endpoints](#dispute-endpoints)
9. [Messaging Endpoints](#messaging-endpoints)
10. [Notification Endpoints](#notification-endpoints)
11. [Webhook Endpoints](#webhook-endpoints)
12. [Onboarding Endpoints](#onboarding-endpoints)
13. [Verification Endpoints](#verification-endpoints)
14. [Live Mode Endpoints](#live-mode-endpoints)
15. [Task Feed Endpoints](#task-feed-endpoints)

---

## Overview

### Reconciliation Snapshot (March 8, 2026)

Live authority analysis from `omni-link-hustlexp` currently reports:

- documented procedures in this file: `100`
- live backend procedures detected in `backend/src/routers`: `247`
- live Swift tRPC calls detected in `HUSTLEXPFINAL1`: `139`
- direct Swift↔backend bridge matches: `150`
- docs-only procedures still requiring implementation or removal: `33`
- backend-only procedures still requiring documentation: `180`
- obsolete Swift calls still requiring removal or remapping: `0`
- payload drift findings still requiring normalization: `57`

This means the contract is still authoritative in intent, but incomplete as a live implementation reference. Until reconciliation is complete:

- `backend/src/routers` is the implemented source of truth
- `HUSTLEXPFINAL1` service calls are the consumer source of truth
- this document must be updated in lockstep with backend/client contract changes

### Current Reconciliation Focus

**Tranche completed in this pass:**
- `task.*` authority now covers the live task router surface (`create`, `accept`, `start`, `submitProof`, `getProof`, `reviewProof`, `complete`, `cancel`, `getById`, `getState`, `listByPoster`, `listByWorker`, `listOpen`)
- `escrow.*` authority now covers the live escrow router surface (`getById`, `getState`, `getByTaskId`, `createPaymentIntent`, `confirmFunding`, `release`, `refund`, `lockForDispute`, `getHistory`, `awardXP`)
- `user.*` authority now reflects the live mobile-facing procedures (`me`, `getById`, `register`, `updateProfile`, `xpHistory`, `badges`, onboarding, verification)
- `live.*`, `health.*`, and `instant.*` authority sections now match the current live routers
- `messaging.*`, `notification.*`, and `rating.*` authority sections now match the current live mobile/backend surface
- stale headings from the previous contract naming (`task.list`, `escrow.createIntent`, `user.getProfile`, `user.getXP`, `user.getBadges`, `user.getTrustTier`, `liveMode.*`) are now explicitly marked legacy/deprecated instead of being counted as active authority

**Backend-only families to document next:**
- `gdpr.*`, `analytics.*`, `fraud.*`, `moderation.*`
- `skills.*`, `pricing.*`, `geofence.*`, `heatmap.*`, `featured.*`, `subscription.*`, `capability.*`

**Docs-only procedures still to verify or remove:**
- `proof.submit`
- `proof.accept`
- `proof.reject`
- `proof.getByTaskId`
- `dispute.create`
- `dispute.resolve`
- `dispute.getByTaskId`
- `messaging.getThread`
- `messaging.markRead`
- `notification.list`
- `notification.markRead`
- `onboarding.getProgress`
- `onboarding.setRole`
- `onboarding.submitCapabilities`
- admin/support/tax contract entries that still lack live router parity

**Obsolete Swift calls to remove or remap first:**
- completed in the current reconciliation pass: previously stale `flags.*`, `tracking.*`, `insurance` premium-upgrade calls, `recurringTask.*`, task batching, legacy skill verification, and stale squad task calls have been removed from the live Swift contract surface
- current consumer drift is now concentrated in payload shape mismatches and in still-undocumented backend procedures, not in dead Swift procedure names

**Payload drift hotspots to normalize next:**
- `escrow.confirmFunding` still drifts on output shape beyond the current authority fields (`posterId`, `workerId`, fee fields, payout helpers)
- `task.submitProof` and `task.getProof` still drift between backend reality, Swift models, and the authority contract
- `user.getOnboardingStatus` still drifts between the backend response and the current Swift `OnboardingStatus` model
- `notification.getPreferences` still drifts heavily between docs authority and the Swift consumer shape

### Base URL
```
Production: https://api.hustlexp.com/trpc
Development: http://localhost:3000/trpc
```

### Request Format
All endpoints use tRPC protocol. Queries use GET, mutations use POST.

### Response Format
```typescript
// Success
{
  result: {
    data: T
  }
}

// Error
{
  error: {
    message: string;
    code: string; // HX error code
    data?: any;
  }
}
```

---

## Authentication

All protected endpoints require a valid Firebase JWT token in the Authorization header.

```
Authorization: Bearer <firebase_jwt_token>
```

### Auth Levels
- **Public**: No authentication required
- **Protected**: Valid user token required
- **Admin**: Valid admin token required (has admin role)

### Required Headers

| Header | Required | Description |
|---|---|---|
| `Authorization` | Protected/Admin endpoints | `Bearer <firebase_jwt_token>` |
| `X-App-Version` | All requests | Client app version (e.g., `1.0.0`) |
| `X-Platform` | All requests | `ios` or `android` |
| `X-Device-Id` | All requests | Device fingerprint for sybil detection |

### Force Update Protocol

Server checks `X-App-Version` header against minimum required version.

| Response Header | Meaning |
|---|---|
| `X-Min-Version: 1.0.0` | Minimum supported version |
| `X-Force-Update: true` | Client MUST update before continuing |
| `X-Update-URL: https://...` | App store link for update |

If `X-App-Version < X-Min-Version` AND `X-Force-Update: true`:
- Server returns HTTP 426 (Upgrade Required) for ALL endpoints
- Client displays blocking "Update Required" screen (E5-force-update-screen)
- No API calls succeed until app is updated

Version policy: support current version + 1 previous major version.

### Rate Limiting

All endpoints are rate-limited per authenticated user and per IP. See PRODUCT_SPEC §21.6 for limits.

Rate limit response headers on ALL responses:
| Header | Description |
|---|---|
| `X-RateLimit-Limit` | Maximum requests in window |
| `X-RateLimit-Remaining` | Requests remaining in window |
| `X-RateLimit-Reset` | Unix timestamp when window resets |

When limit exceeded: HTTP 429 with `Retry-After` header (seconds).
Error code: `RATE_LIMITED` — "Rate limit exceeded"

---

## Error Codes

### Database Invariant Errors (HXxxx)

| Code | Meaning | Recovery |
|------|---------|----------|
| HX001 | Task terminal state violation | Cannot modify completed/cancelled/expired task |
| HX002 | Escrow terminal state violation | Cannot modify released/refunded escrow |
| HX004 | INV-4: Escrow amount immutability | Amount is immutable after funding |
| HX101 | INV-1: XP without RELEASED escrow | Task must be completed first |
| HX102 | XP ledger immutable | Cannot delete XP entries |
| HX201 | INV-2: RELEASED without COMPLETED task | Task must be completed first |
| HX301 | INV-3: COMPLETED without ACCEPTED proof | Proof must be accepted first |
| HX302 | INV-TASK-1: Maximum active tasks reached | Complete or cancel active task |
| HX303 | INV-PROOF-1: Max rejections reached, dispute auto-opened | Dispute resolution required |
| HX304 | INV-PRICE-1: Task price exceeds maximum | Reduce price |
| HX305 | INV-ACCEPT-1: Acceptance window expired | Task returned to OPEN |
| HX401 | INV-BADGE-2: Badge deletion attempt | Badge ledger is append-only |
| HX501 | Admin action audit immutability | Cannot delete admin audit records |
| HX901 | LIVE-1: Live broadcast without funded escrow | Fund escrow before broadcasting |
| HX902 | LIVE-2: Live task below $15 minimum | Increase price to $15+ |
| RATE_LIMITED | Rate limit exceeded | Wait and retry |

### Application Errors

| Code | Meaning |
|------|---------|
| AUTH_REQUIRED | Authentication required |
| AUTH_INVALID | Invalid or expired token |
| FORBIDDEN | User lacks permission for action |
| NOT_FOUND | Resource not found |
| VALIDATION_ERROR | Input validation failed |
| CONFLICT | Resource conflict (e.g., duplicate) |

---

## Task Endpoints

**Reconciliation note:** the client-facing tRPC contract in this section is documented in camelCase. Legacy headings are retained only as non-authoritative notes so the authority surface matches the live router names.

### task.create

Create a new task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  title: string;
  description: string;
  price: number;                 // USD cents
  requirements?: string;
  location?: string;
  category?: string;
  deadline?: string;             // ISO 8601 datetime
  requiresProof?: boolean;       // Default true
  mode?: 'STANDARD' | 'LIVE';    // Default STANDARD
  liveBroadcastRadiusMiles?: number;
  instantMode?: boolean;         // Default false
}
```

**Output:**
```typescript
{
  id: string;
  posterId: string;
  title: string;
  description: string;
  state: 'OPEN';
  mode: 'STANDARD' | 'LIVE';
  price: number;
  requiresProof: boolean;
  createdAt: string;
}
```

---

### task.accept

Accept an open task as the worker.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'ACCEPTED';
  workerId: string;
  acceptedAt: string;
}
```

---

### task.start

Mark an accepted task as actively in progress on the client workflow.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: string;
  workerId: string;
  acceptedAt: string | null;
}
```

---

### task.submitProof

Submit proof of completion for a task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  description?: string;
  photoUrls?: string[];
  notes?: string;
  gpsLatitude?: number;
  gpsLongitude?: number;
  biometricHash?: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'PROOF_SUBMITTED';
  proofSubmittedAt: string | null;
}
```

---

### task.getProof

Get the latest proof submission for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  submitterId: string;
  state: string;
  description?: string;
  reviewedBy?: string;
  reviewedAt?: string;
  rejectionReason?: string;
}
```

---

### task.reviewProof

Accept or reject a proof submission.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  proofId?: string;
  taskId?: string;
  decision?: 'ACCEPTED' | 'REJECTED';
  approved?: boolean;
  reason?: string;
  feedback?: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'ACCEPTED' | 'REJECTED';
  reviewedBy: string;
  reviewedAt: string;
  rejectionReason?: string;
}
```

---

### task.complete

Complete a task after proof has been accepted.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'COMPLETED';
  completedAt: string;
}
```

---

### task.cancel

Cancel a task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  reason?: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'CANCELLED';
  cancelledAt: string | null;
}
```

---

### task.getById

Get a task by ID.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  posterId: string;
  workerId: string | null;
  title: string;
  description: string;
  requirements?: string;
  location?: string;
  category?: string;
  price: number;
  state: string;
  mode: 'STANDARD' | 'LIVE';
  deadline?: string;
  requiresProof: boolean;
  acceptedAt?: string;
  proofSubmittedAt?: string;
  completedAt?: string;
  cancelledAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### task.getState

Get the server-authoritative state for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  state: string;
}
```

---

### task.listByPoster

List tasks posted by the current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  posterId?: string;
  state?: string;
}
```

**Output:**
```typescript
TaskSummary[]
```

---

### task.listByWorker

List tasks assigned to the current worker.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  workerId?: string;
  state?: string;
}
```

**Output:**
```typescript
TaskSummary[]
```

---

### task.listOpen

List open tasks for the mobile feed.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
  offset?: number;
}
```

**Output:**
```typescript
TaskSummary[]
```

---

#### Legacy / Planned: task.list

This older aggregate list contract is not part of the authoritative live router surface during reconciliation.

## Escrow Endpoints

### escrow.getById

Get an escrow by ID.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  escrowId: string;
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  posterId?: string;
  workerId?: string;
  amountCents: number;
  state: string;
  stripePaymentIntentId?: string;
  stripeTransferId?: string;
  stripeRefundId?: string;
  fundedAt?: string;
  releasedAt?: string;
  refundedAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### escrow.getState

Get the server-authoritative state for an escrow.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  escrowId: string;
}
```

**Output:**
```typescript
{
  state: string;
}
```

---

### escrow.getByTaskId

Get the escrow for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  amountCents: number;
  state: string;
  stripePaymentIntentId?: string;
  stripeTransferId?: string;
  stripeRefundId?: string;
  fundedAt?: string;
  releasedAt?: string;
  refundedAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### escrow.createPaymentIntent

Create a Stripe PaymentIntent for escrow funding.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  amount?: number;
}
```

**Output:**
```typescript
{
  escrowId: string;
  paymentIntentId: string;
  clientSecret: string;
  amountCents: number;
}
```

---

### escrow.confirmFunding

Confirm an escrow has been funded after Stripe payment succeeds.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  escrowId: string;
  stripePaymentIntentId: string;
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  state: 'FUNDED';
  stripePaymentIntentId: string;
  fundedAt: string;
}
```

---

### escrow.release

Release escrow to the worker.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  escrowId: string;
  stripeTransferId?: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'RELEASED';
  stripeTransferId?: string;
  releasedAt: string;
}
```

---

### escrow.refund

Refund escrow to the poster.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  escrowId: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'REFUNDED';
  stripeRefundId?: string;
  refundedAt: string;
}
```

---

### escrow.lockForDispute

Lock escrow while a dispute is being resolved.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  escrowId: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'LOCKED_DISPUTE';
}
```

---

### escrow.getHistory

Get escrow history for the current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
}
```

**Output:**
```typescript
Escrow[]
```

---

### escrow.awardXP

Award XP after a released escrow.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  escrowId: string;
  baseXP: number;
}
```

**Output:**
```typescript
{
  entryId: string;
  amount: number;
  reason: string;
  taskId: string;
  awardedAt: string;
}
```

---

#### Legacy / Planned: escrow.createIntent

This older name is superseded by `escrow.createPaymentIntent` in the live router surface.

## Proof Endpoints

### proof.submit

Submit proof (alias for task.submitProof, see above).

---

### proof.accept

Accept submitted proof (as poster).

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  proof_id: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'ACCEPTED';
  reviewed_by: string;
  reviewed_at: string;
}
```

---

### proof.reject

Reject submitted proof (as poster).

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  proof_id: string;
  reason: string;       // 1-1000 chars, required
}
```

**Output:**
```typescript
{
  id: string;
  state: 'REJECTED';
  rejection_reason: string;
  reviewed_by: string;
  reviewed_at: string;
}
```

---

### proof.getByTaskId

Get proof for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  task_id: string;
}
```

**Output:**
```typescript
{
  id: string;
  task_id: string;
  submitter_id: string;
  state: ProofState;
  description: string | null;
  photos: ProofPhoto[];
  submitted_at: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
}
```

---

## User Endpoints

### user.me

Get the current authenticated user profile in the mobile-compatible shape.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  id: string;
  name: string;
  email: string;
  phone?: string;
  bio?: string;
  avatarURL?: string;
  role: 'hustler' | 'poster';
  trustTier: string;
  rating: number;
  totalRatings: number;
  xp: number;
  tasksCompleted: number;
  tasksPosted: number;
  totalEarnings: number;
  totalSpent: number;
  isVerified: boolean;
  hasCompletedOnboarding: boolean;
  defaultMode: 'worker' | 'poster';
  unpaidTaxCents: number;
  xpHeldBack: number;
  verificationEarnedCents: number;
  insuranceContributionsCents: number;
  createdAt: string;
}
```

---

### user.getById

Get a user profile by ID.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  userId: string;
}
```

**Output:**
```typescript
{
  id: string;
  name: string;
  avatarURL?: string;
  bio?: string;
  role: 'hustler' | 'poster';
  trustTier: string;
  xp: number;
  isVerified: boolean;
  rating: number;
  totalRatings: number;
  tasksCompleted: number;
  createdAt: string;
}
```

---

### user.register

Register a new HustleXP user after Firebase authentication.

**Auth:** Public
**Method:** Mutation

**Input:**
```typescript
{
  firebaseUid: string;
  email: string;
  fullName: string;
  defaultMode?: 'worker' | 'poster' | 'hustler';
  dateOfBirth: string;        // YYYY-MM-DD
}
```

**Output:**
```typescript
{
  id: string;
  name: string;
  email: string;
  role: 'hustler' | 'poster';
  isVerified: boolean;
  createdAt: string;
}
```

---

### user.updateProfile

Update the current user's profile.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  fullName?: string;
  bio?: string;
  avatarUrl?: string;
  phone?: string;
  defaultMode?: 'worker' | 'poster' | 'hustler';
}
```

**Output:**
```typescript
{
  id: string;
  name: string;
  bio?: string;
  avatarURL?: string;
  phone?: string;
  role: 'hustler' | 'poster';
  updatedAt: string;
}
```

---

### user.xpHistory

Get XP history for the current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
}
```

**Output:**
```typescript
XPHistoryEntry[]
```

---

### user.badges

Get badges for the current user.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
UserBadge[]
```

---

### user.getOnboardingStatus

Get onboarding and first-task completion state.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  onboardingComplete: boolean;
  role: 'hustler' | 'poster';
  xpFirstCelebrationShownAt?: string;
  hasCompletedFirstTask: boolean;
}
```

---

### user.completeOnboarding

Mark onboarding as complete and persist role confidence metadata.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  version: string;
  roleConfidenceWorker: number;
  roleConfidencePoster: number;
  roleCertaintyTier: 'STRONG' | 'MODERATE' | 'WEAK';
  inconsistencyFlags?: string[];
}
```

**Output:**
```typescript
{
  id: string;
  hasCompletedOnboarding: boolean;
  defaultMode: 'worker' | 'poster';
  updatedAt: string;
}
```

---

### user.getVerificationUnlockStatus

Get earned verification progress.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  earnedCents: number;
  thresholdCents: number;
  percentage: number;
  unlocked: boolean;
  tasksCompleted: number;
  remainingCents: number;
}
```

---

### user.checkVerificationEligibility

Check whether verification has been unlocked.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  isEligible: boolean;
}
```

---

### user.getVerificationEarningsLedger

Get the earned-verification ledger.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
}
```

**Output:**
```typescript
VerificationEarningsEntry[]
```

---

#### Legacy / Deprecated: user.getProfile

Superseded by `user.me`.

#### Legacy / Deprecated: user.getXP

Superseded by `user.xpHistory`.

#### Legacy / Deprecated: user.getBadges

Superseded by `user.badges`.

#### Legacy / Deprecated: user.getTrustTier

No standalone live router procedure currently exposes this shape.

## Dispute Endpoints

### dispute.create

Open a dispute on a task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
  reason: 'PROOF_INSUFFICIENT' | 'WORK_NOT_DONE' | 'QUALITY_ISSUE' | 'OTHER';
  description: string;      // 1-2000 chars
  evidence_urls?: string[]; // Optional photos
}
```

**Output:**
```typescript
{
  dispute: {
    id: string;
    task_id: string;
    opened_by: string;
    reason: string;
    state: 'OPEN';
    created_at: string;
  };
  task: {
    id: string;
    state: 'DISPUTED';
  };
  escrow: {
    id: string;
    state: 'LOCKED_DISPUTE';
  };
}
```

---

### dispute.resolve

Resolve a dispute (admin only).

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  dispute_id: string;
  resolution: 'HUSTLER_WINS' | 'CLIENT_WINS' | 'SPLIT';
  split_percent?: number;   // Required if resolution is SPLIT (1-99)
  notes: string;            // Admin notes
}
```

**Output:**
```typescript
{
  dispute: {
    id: string;
    state: 'RESOLVED';
    resolution: string;
    resolved_by: string;
    resolved_at: string;
  };
  task: {
    id: string;
    state: 'COMPLETED' | 'CANCELLED';
  };
  escrow: {
    id: string;
    state: 'RELEASED' | 'REFUNDED' | 'REFUND_PARTIAL';
  };
}
```

---

### dispute.getByTaskId

Get dispute for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  task_id: string;
}
```

**Output:**
```typescript
{
  id: string;
  task_id: string;
  opened_by: string;
  reason: string;
  description: string;
  evidence: Evidence[];
  state: 'OPEN' | 'EVIDENCE_REQUESTED' | 'ESCALATED' | 'RESOLVED';
  resolution: string | null;
  resolved_by: string | null;
  resolved_at: string | null;
  created_at: string;
}
```

---

## Messaging Endpoints

### messaging.sendMessage

Send a text or auto-message in a task thread.

**Auth:** Protected (must be poster or worker)
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  messageType: 'TEXT' | 'AUTO';
  content?: string; // Required for TEXT, max 500 chars
  autoMessageTemplate?: 'on_my_way' | 'running_late' | 'completed' | 'question';
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  senderId: string;
  messageType: 'TEXT' | 'AUTO' | 'PHOTO';
  content: string;
  photoUrls?: string[];
  caption?: string | null;
  readAt?: string | null;
  createdAt: string;
}
```

**Errors:**
- `FORBIDDEN` - Task not in ACCEPTED/PROOF_SUBMITTED/DISPUTED state
- `FORBIDDEN` - User is not poster or worker

---

### messaging.sendPhotoMessage

Send a photo message in a task thread.

**Auth:** Protected (must be poster or worker)
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  photoUrls: string[]; // 1-3 URLs
  caption?: string;    // Max 200 chars
}
```

**Output:** same shape as `messaging.sendMessage`

---

### messaging.getTaskMessages

Get all messages for a task thread.

**Auth:** Protected (must be poster or worker)
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
Array<{
  id: string;
  taskId: string;
  senderId: string;
  messageType: 'TEXT' | 'AUTO' | 'PHOTO';
  content: string;
  photoUrls?: string[];
  caption?: string | null;
  readAt?: string | null;
  createdAt: string;
}>
```

---

### messaging.markAsRead

Mark a single message as read.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  messageId: string;
}
```

**Output:**
```typescript
{
  id: string;
  taskId: string;
  senderId: string;
  readAt: string;
}
```

---

### messaging.markAllAsRead

Mark all messages in a task thread as read.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  marked: number;
}
```

---

### messaging.getUnreadCount

Get unread message count for the current user.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  unreadCount: number;
  count: number;
}
```

---

### messaging.getConversations

Get task-scoped conversation summaries for the current user.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
Array<{
  id: string; // taskId
  taskId: string;
  taskTitle: string;
  otherUserId: string;
  otherUserName: string;
  otherUserRole: string;
  lastMessage?: string | null;
  lastMessageAt?: string | null;
  unreadCount: number;
}>
```

---

## Notification Endpoints

### notification.getList

Get notifications for current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  unreadOnly?: boolean;   // Default false
  limit?: number;         // Default 50, max 100
  offset?: number;        // Default 0
}
```

**Output:**
```typescript
Array<{
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
  isRead: boolean;
  isClicked: boolean;
  createdAt: string;
}>
```

---

### notification.getUnreadCount

Get unread notification count for current user.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  count: number;
}
```

---

### notification.getById

Get a single notification by ID.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  notificationId: string;
}
```

**Output:** same shape as a single item from `notification.getList`

---

### notification.markAsRead

Mark a single notification as read.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  notificationId: string;
}
```

**Output:** same shape as a single item from `notification.getList`

---

### notification.markAllAsRead

Mark all notifications as read for the current user.

**Auth:** Protected
**Method:** Mutation

**Input:** None

**Output:**
```typescript
{
  marked: number;
}
```

---

### notification.markAsClicked

Mark a notification as clicked for analytics tracking.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  notificationId: string;
}
```

**Output:** same shape as a single item from `notification.getList`

---

### notification.getPreferences

Get notification preferences.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  pushEnabled: boolean;
  emailEnabled: boolean;
  smsEnabled?: boolean;
  quietHoursEnabled?: boolean;
  quietHoursStart?: string;
  quietHoursEnd?: string;
  categoryPreferences?: Record<string, boolean>;
  taskUpdates?: boolean;
  paymentUpdates?: boolean;
  messageNotifications?: boolean;
  marketingEmails?: boolean;
}
```

---

### notification.updatePreferences

Update notification preferences.

**Auth:** Protected
**Method:** Mutation

**Input:** all fields optional
```typescript
{
  quietHoursEnabled?: boolean;
  quietHoursStart?: string;
  quietHoursEnd?: string;
  pushEnabled?: boolean;
  emailEnabled?: boolean;
  smsEnabled?: boolean;
  categoryPreferences?: Record<string, boolean>;
}
```

**Output:** (same as getPreferences)

---

### notification.registerDeviceToken

Register an FCM device token for push notifications.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  fcmToken: string;
  deviceType?: 'ios' | 'android';
  deviceName?: string;
  appVersion?: string;
}
```

**Output:**
```typescript
{
  id: string;
  userId: string;
  fcmToken: string;
  deviceType: 'ios' | 'android';
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}
```

---

### notification.unregisterDeviceToken

Deactivate an FCM device token without deleting the historical record.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  fcmToken: string;
}
```

**Output:**
```typescript
{
  success: boolean;
}
```

---

## Webhook Endpoints

### POST /webhooks/stripe

Handle Stripe webhook events.

**Auth:** Stripe signature verification
**Method:** POST (HTTP, not tRPC)

**Headers:**
```
Stripe-Signature: <signature>
Content-Type: application/json
```

**Events Handled:**
- `payment_intent.succeeded` → Fund escrow
- `payment_intent.payment_failed` → Mark escrow funding failed, notify poster
- `payment_intent.canceled` → Mark escrow cancelled
- `transfer.created` → Track transfer ID
- `transfer.failed` → Flag failed payout, trigger admin alert + retry logic
- `charge.dispute.created` → Lock escrow (LOCKED_DISPUTE), create internal dispute record

**Idempotency:** All events are deduplicated via `processed_stripe_events` table. See STRIPE_INTEGRATION.md for full handler specifications.

**Response:** 200 OK (always, to prevent retry storms)

---

## Type Definitions

### Enums

```typescript
type TaskState =
  | 'OPEN'
  | 'ACCEPTED'
  | 'PROOF_SUBMITTED'
  | 'DISPUTED'
  | 'COMPLETED'
  | 'CANCELLED'
  | 'EXPIRED';

type EscrowState =
  | 'PENDING'
  | 'FUNDED'
  | 'LOCKED_DISPUTE'
  | 'RELEASED'
  | 'REFUNDED'
  | 'REFUND_PARTIAL';

type ProofState =
  | 'PENDING'
  | 'SUBMITTED'
  | 'ACCEPTED'
  | 'REJECTED'
  | 'EXPIRED';

type NotificationType =
  | 'TASK_CREATED'
  | 'TASK_ACCEPTED'
  | 'TASK_WORKER_ASSIGNED'
  | 'TASK_CANCELLED'
  | 'TASK_EXPIRED'
  | 'PROOF_SUBMITTED'
  | 'PROOF_ACCEPTED'
  | 'PROOF_REJECTED'
  | 'DISPUTE_OPENED'
  | 'DISPUTE_RESOLVED'
  | 'XP_EARNED'
  | 'LEVEL_UP'
  | 'BADGE_EARNED'
  | 'ESCROW_FUNDED'
  | 'ESCROW_RELEASED'
  | 'ESCROW_REFUNDED'
  | 'TRUST_TIER_UP'
  | 'TRUST_TIER_DOWN'
  | 'LIVE_TASK_MATCH'
  | 'NEW_MESSAGE'
  | 'SYSTEM_ANNOUNCEMENT';
```

### Summary Types

```typescript
interface UserSummary {
  id: string;
  full_name: string;
  avatar_url: string | null;
  trust_tier: number;
  is_verified: boolean;
}

interface TaskSummary {
  id: string;
  title: string;
  category: string;
  price: number;
  state: TaskState;
  mode: 'STANDARD' | 'LIVE';
  location: string;
  deadline: string;
  poster: UserSummary;
  created_at: string;
}

interface EscrowSummary {
  id: string;
  amount: number;
  state: EscrowState;
}

interface ProofSummary {
  id: string;
  state: ProofState;
  submitted_at: string | null;
}

/**
 * Eligibility Blocker Format
 * Used in task.getFeed to explain why a user cannot accept a task
 * Format: {type}_{requirement}
 */
interface EligibilityBlocker {
  type:
    | 'TRUST_TIER'      // User's trust tier too low
    | 'LICENSE'         // Missing required license
    | 'INSURANCE'       // Missing required insurance
    | 'BACKGROUND'      // Missing background check
    | 'LOCATION'        // Outside service area
    | 'VERIFICATION';   // Account not verified
  requirement: string;  // e.g., 'electrician', 'tier_3', 'TX'
  message: string;      // Human-readable explanation
}

// Example blockers:
// { type: 'TRUST_TIER', requirement: 'tier_3', message: 'Requires Trusted tier (Tier 3)' }
// { type: 'LICENSE', requirement: 'electrician', message: 'Requires verified electrician license' }
// { type: 'INSURANCE', requirement: 'liability', message: 'Requires liability insurance' }
// { type: 'BACKGROUND', requirement: 'standard', message: 'Requires background check' }
// { type: 'LOCATION', requirement: 'TX', message: 'Task is in Texas, your license is for CA' }
```

---

## Shared Type Definitions

These types are referenced across multiple endpoints.

```typescript
// User profile data (user.getProfile, admin.getUser)
interface UserProfile {
  id: string;
  email: string;
  display_name: string;
  avatar_url?: string;
  phone?: string;
  bio?: string;
  primary_role: 'worker' | 'poster';
  trust_tier: 1 | 2 | 3 | 4;  // 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE
  xp_total: number;
  level: number;
  created_at: string;
  updated_at: string;
}

// Capability profile for eligibility (verification.getCapabilityProfile)
interface CapabilityProfile {
  user_id: string;
  profile_id: string;
  trust_tier: 1 | 2 | 3 | 4;
  trust_tier_updated_at: string;
  risk_clearance: ('low' | 'medium' | 'high')[];
  insurance_valid: boolean;
  insurance_expires_at?: string;
  background_check_valid: boolean;
  background_check_expires_at?: string;
  location_state: string;  // 2-char state code
  location_city?: string;
  willingness_flags: {
    in_home_work: boolean;
    high_risk_tasks: boolean;
    urgent_jobs: boolean;
  };
  verification_status: Record<string, boolean>;
  derived_at: string;
}

// Verification status summary (admin.getUser)
interface VerificationStatus {
  email_verified: boolean;
  phone_verified: boolean;
  id_verified: boolean;
  background_check_status: 'NOT_STARTED' | 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
  insurance_status: 'NOT_UPLOADED' | 'PENDING' | 'VERIFIED' | 'EXPIRED';
}

// Dispute summary (admin.getUser, dispute.getByTaskId)
// NOTE: The `status` field is an API-level derivation. The database stores only 4 base states:
//   OPEN | EVIDENCE_REQUESTED | ESCALATED | RESOLVED
// When base state is RESOLVED, the API derives the granular status from the `outcome_escrow_action` field:
//   outcome_escrow_action = 'RELEASE' → RESOLVED_WORKER
//   outcome_escrow_action = 'REFUND'  → RESOLVED_POSTER
//   outcome_escrow_action = 'SPLIT'   → RESOLVED_SPLIT
// Service layer must implement this transformation in the dispute serializer.
interface DisputeSummary {
  id: string;
  task_id: string;
  status: 'OPEN' | 'EVIDENCE_REQUESTED' | 'ESCALATED' | 'RESOLVED_POSTER' | 'RESOLVED_WORKER' | 'RESOLVED_SPLIT';
  opened_by: 'poster' | 'worker';
  reason: string;
  created_at: string;
  resolved_at?: string;
  resolution_notes?: string;
}

// Trust ledger entry (admin.getUser)
interface TrustLedgerEntry {
  id: string;
  user_id: string;
  event_type: 'TIER_UPGRADE' | 'TIER_DOWNGRADE' | 'TASK_COMPLETED' | 'DISPUTE_LOST' | 'REVIEW_RECEIVED';
  previous_tier?: number;
  new_tier?: number;
  reason: string;
  created_at: string;
}

// Badge definition (user.getBadges)
interface BadgeDefinition {
  id: string;
  slug: string;
  name: string;
  description: string;
  icon_url: string;
  category: 'achievement' | 'milestone' | 'special' | 'seasonal';
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  earned_at: string;
}

// Proof photo (proof.getByTaskId)
interface ProofPhoto {
  id: string;
  proof_id: string;
  storage_key: string;
  content_type: string;
  file_size_bytes: number;
  sequence_number: number;
  capture_time?: string;
  created_at: string;
}

// Moderation queue item (admin.getModerationQueue)
interface ModerationQueueItem {
  id: string;
  content_type: 'task' | 'message' | 'rating' | 'profile' | 'photo';
  content_id: string;
  content_preview: string;
  flagged_reason: string;
  ai_confidence: number;
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'ESCALATED';
  created_at: string;
  assigned_to?: string;
}

// Evidence attachment (dispute.getByTaskId)
interface Evidence {
  id: string;
  dispute_id: string;
  submitted_by: string;
  evidence_type: 'PHOTO' | 'MESSAGE' | 'LOCATION' | 'DOCUMENT';
  storage_key: string;
  description?: string;
  created_at: string;
}

// XP ledger entry (user.getXP)
interface XPLedgerEntry {
  id: string;
  user_id: string;
  task_id?: string;
  amount: number;
  reason: string;
  decay_factor: number;
  effective_amount: number;
  balance_after: number;
  created_at: string;
}
```

---

## Onboarding Endpoints

### onboarding.getProgress

Get current user's onboarding progress.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  phase: 'NOT_STARTED' | 'ROLE_SELECTION' | 'PROFILE_SETUP' | 'CAPABILITY_CLAIMS' | 'TUTORIAL' | 'COMPLETED';
  completed_steps: string[];
  next_step: string | null;
  role: 'worker' | 'poster' | null;
  profile_percent_complete: number;
  started_at: string | null;
  completed_at: string | null;
}
```

---

### onboarding.setRole

Set user's primary role during onboarding.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  role: 'worker' | 'poster';
  confidence: 'STRONG' | 'MODERATE' | 'WEAK';
}
```

**Output:**
```typescript
{
  role: 'worker' | 'poster';
  next_step: string;
}
```

---

### onboarding.submitCapabilities

Submit capability claims during onboarding.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  claimed_trades: string[];           // e.g., ['electrician', 'plumber']
  license_claims: {
    trade: string;
    state: string;                    // 2-letter state code
    license_number: string;
  }[];
  insurance_claimed: boolean;
  work_state: string;                 // 2-letter state code
  work_region?: string;
  risk_preferences: {
    in_home_work: boolean;
    high_risk_tasks: boolean;
    urgent_jobs: boolean;
  };
}
```

**Output:**
```typescript
{
  claim_id: string;
  trades_requiring_verification: string[];
  next_step: string;
}
```

---

### onboarding.completeStep

Mark an onboarding step as complete.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  step_id: string;
  data?: Record<string, any>;         // Step-specific data
}
```

**Output:**
```typescript
{
  completed_steps: string[];
  next_step: string | null;
  phase: string;
}
```

---

### onboarding.complete

Complete the entire onboarding flow.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  skip_tutorial?: boolean;            // Default: false
}
```

**Output:**
```typescript
{
  success: boolean;
  profile: UserProfile;
  capability_profile: CapabilityProfile;
  onboarding_completed_at: string;
}
```

---

## Verification Endpoints

### verification.submitLicense

Submit a license for verification.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  trade: string;                      // e.g., 'electrician'
  state: string;                      // 2-letter state code
  license_number: string;
  license_type?: string;              // e.g., 'journeyman', 'master'
  document_urls?: string[];           // Optional supporting documents
}
```

**Output:**
```typescript
{
  verification_id: string;
  status: 'pending' | 'processing';
  estimated_completion: string;       // ISO 8601 datetime
}
```

---

### verification.submitInsurance

Submit insurance for verification.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  trade: string;
  policy_number?: string;
  coverage_amount: number;            // in cents
  document_urls: string[];            // COI uploads required
}
```

**Output:**
```typescript
{
  verification_id: string;
  status: 'pending' | 'processing';
  estimated_completion: string;
}
```

---

### verification.initiateBackgroundCheck

Initiate a background check.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  consent_given: boolean;             // Must be true
  consent_timestamp: string;          // ISO 8601
}
```

**Output:**
```typescript
{
  check_id: string;
  provider: string;
  status: 'initiated';
  redirect_url?: string;              // If provider requires user action
}
```

**Errors:**
- `VALIDATION_ERROR` - Consent not given
- `CONFLICT` - Check already in progress

---

### verification.getStatus

Get verification status for current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  type?: 'license' | 'insurance' | 'background_check';  // Optional filter
}
```

**Output:**
```typescript
{
  licenses: {
    id: string;
    trade: string;
    state: string;
    status: 'pending' | 'processing' | 'verified' | 'failed' | 'expired';
    verified_at: string | null;
    expires_at: string | null;
    failure_reason: string | null;
  }[];
  insurance: {
    id: string;
    trade: string;
    status: 'pending' | 'processing' | 'verified' | 'failed' | 'expired';
    coverage_amount: number;
    verified_at: string | null;
    expires_at: string | null;
  }[];
  background_check: {
    id: string;
    status: 'pending' | 'processing' | 'verified' | 'failed' | 'expired';
    provider: string;
    verified_at: string | null;
    expires_at: string | null;
  } | null;
}
```

---

### verification.getCapabilityProfile

Get computed capability profile.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  user_id: string;
  trust_tier: 1 | 2 | 3 | 4;  // 1=ROOKIE, 2=VERIFIED, 3=TRUSTED, 4=ELITE
  risk_clearance: ('low' | 'medium' | 'high')[];
  verified_trades: {
    trade: string;
    state: string;
    verified_at: string;
    expires_at: string | null;
  }[];
  insurance_valid: boolean;
  insurance_expires_at: string | null;
  background_check_valid: boolean;
  background_check_expires_at: string | null;
  location_state: string;
  willingness_flags: {
    in_home_work: boolean;
    high_risk_tasks: boolean;
    urgent_jobs: boolean;
  };
  derived_at: string;
}
```

---

## Live Mode Endpoints

### live.toggle

Toggle live mode on or off for the current user.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  enabled: boolean;
}
```

**Output:**
```typescript
{
  state: 'OFF' | 'ACTIVE' | 'COOLDOWN';
  sessionStartedAt?: string;
  bannedUntil?: string;
  totalTasks: number;
  completionRate: number;
}
```

---

### live.getStatus

Get live mode status for the current user.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  state: 'OFF' | 'ACTIVE' | 'COOLDOWN';
  sessionStartedAt?: string;
  bannedUntil?: string;
  totalTasks: number;
  completionRate: number;
}
```

---

### live.listBroadcasts

Get active live broadcasts near the caller.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  latitude: number;
  longitude: number;
  radiusMiles?: number;
}
```

**Output:**
```typescript
LiveBroadcast[]
```

---

#### Legacy / Deprecated: liveMode.activate

Superseded by `live.toggle`.

#### Legacy / Deprecated: liveMode.deactivate

Superseded by `live.toggle`.

#### Legacy / Deprecated: liveMode.getStatus

Superseded by `live.getStatus`.

#### Legacy / Deprecated: liveMode.updateLocation

Not part of the current live router surface.

#### Legacy / Deprecated: liveMode.respondToBroadcast

Not part of the current live router surface.

## Health Endpoints

### health.ping

Basic system liveness check.

**Auth:** Public
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  status: 'ok';
  timestamp: string;
}
```

---

### health.status

Get full system health.

**Auth:** Public
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  status: 'healthy' | 'degraded';
  timestamp: string;
  services: {
    database: unknown;
    stripe: unknown;
    firebase: unknown;
    redis: unknown;
  };
  environment: string;
}
```

---

### health.verifySchema

Verify the live database schema against the expected constitutional schema.

**Auth:** Public
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  valid: boolean;
  schemaVersion: string;
  tables: unknown;
  triggers: unknown;
  views: unknown;
}
```

## Instant Mode Endpoints

### instant.listAvailable

List instant-available tasks.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
}
```

**Output:**
```typescript
InstantTask[]
```

---

### instant.accept

Accept an instant-available task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  task: HXTask;
  timeToAcceptSeconds?: number;
}
```

---

### instant.dismiss

Dismiss an instant-task notification.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
{
  dismissed: boolean;
}
```

---

### instant.metrics

Get instant-mode acceptance and notification metrics.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  timeToAccept: unknown;
  notificationLatency: unknown;
  dismissRate: number;
  dismissStats: unknown;
}
```

## Task Feed Endpoints

#### Legacy / Planned: task.getFeed

Get personalized task feed for hustlers.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  location?: {
    lat: number;
    lng: number;
  };
  radius_miles?: number;              // Default: 25, max: 100
  categories?: string[];
  min_price?: number;                 // in cents
  max_price?: number;
  sort_by?: 'relevance' | 'distance' | 'price_desc' | 'price_asc' | 'deadline';
  pagination?: {
    limit?: number;                   // Default: 20, max: 50
    cursor?: string;                  // Cursor-based pagination
  };
}
```

**Output:**
```typescript
{
  tasks: {
    id: string;
    title: string;
    description: string;
    category: string;
    price: number;
    location: string;
    distance_miles: number | null;
    deadline: string;
    mode: 'STANDARD' | 'LIVE';
    poster: UserSummary;
    matching_score: number;           // 0.0 to 1.0
    eligibility: {
      eligible: boolean;
      blockers: EligibilityBlocker[]; // See format below
    };
    created_at: string;
  }[];
  pagination: {
    next_cursor: string | null;
    has_more: boolean;
    total_estimate: number;
  };
  feed_metadata: {
    location_used: { lat: number; lng: number } | null;
    radius_miles: number;
    applied_filters: string[];
    personalization_factors: string[];
  };
}
```

---

#### Legacy / Planned: task.getMatchingScore

Get detailed matching score breakdown for a task.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  task_id: string;
}
```

**Output:**
```typescript
{
  overall_score: number;              // 0.0 to 1.0
  components: {
    distance_score: number;           // 0.0 to 1.0, weight: 0.25
    price_attractiveness: number;     // 0.0 to 1.0, weight: 0.20
    category_match: number;           // 0.0 to 1.0, weight: 0.20
    poster_rating: number;            // 0.0 to 1.0, weight: 0.15
    urgency_fit: number;              // 0.0 to 1.0, weight: 0.10
    trust_compatibility: number;      // 0.0 to 1.0, weight: 0.10
  };
  eligibility: {
    eligible: boolean;
    checks: {
      name: string;
      passed: boolean;
      requirement?: string;
    }[];
  };
}
```

---

## Rating Endpoints

### rating.submitRating

Submit a rating after task completion.

**Auth:** Protected (must be poster or worker on the task)
**Method:** Mutation

**Input:**
```typescript
{
  taskId: string;
  stars: number;           // 1-5, required
  comment?: string;        // Max 500 chars, optional
  tags?: string[];         // Optional, from predefined list
}
```

**Predefined Tags:**
- Worker rating poster: `['clear_instructions', 'responsive', 'fair_expectations', 'prompt_payment']`
- Poster rating worker: `['on_time', 'professional', 'high_quality', 'good_communication', 'went_above']`

**Output:**
```typescript
{
  id: string;
  taskId: string;
  raterId: string;
  rateeId: string;
  stars: number;
  comment: string | null;
  tags: string[];
  createdAt: string;
}
```

**Errors:**
- `FORBIDDEN` - Task not in COMPLETED state
- `FORBIDDEN` - User is not poster or worker for task
- `CONFLICT` - User already rated this task
- `VALIDATION_ERROR` - Rating window expired (7 days after completion)
- `VALIDATION_ERROR` - Stars must be 1-5

---

### rating.getTaskRatings

Get ratings for a specific task.

**Auth:** Protected (must be poster or worker on the task)
**Method:** Query

**Input:**
```typescript
{
  taskId: string;
}
```

**Output:**
```typescript
Array<{
  id: string;
  taskId: string;
  raterId: string;
  rateeId: string;
  stars: number;
  comment: string | null;
  tags: string[];
  isPublic: boolean;
  createdAt: string;
}>
```

---

### rating.getUserRatingSummary

Get aggregated ratings for a user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  userId: string;
}
```

**Output:**
```typescript
{
  averageRating: number;
  totalRatings: number;
  ratingDistribution: {
    '1': number;
    '2': number;
    '3': number;
    '4': number;
    '5': number;
  };
}
```

---

### rating.getMyRatings

Get ratings submitted by the current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
  offset?: number;
}
```

**Output:**
```typescript
Array<{
  id: string;
  taskId: string;
  taskTitle?: string;
  fromUserId?: string;
  fromUserName?: string;
  rating: number;
  review?: string | null;
  createdAt: string;
}>
```

---

### rating.getRatingsReceived

Get public ratings received by the current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;
  offset?: number;
}
```

**Output:** same shape as `rating.getMyRatings`

---

### rating.processAutoRatings

Process overdue auto-ratings.

**Auth:** Admin
**Method:** Mutation

**Input:** None

**Output:**
```typescript
{
  processed: number;
}
```

---

## WebSocket Events (Live Mode)

### Connection

**Endpoint:** `wss://api.hustlexp.com/ws`
**Auth:** Firebase JWT token in query param or header

```typescript
// Connection URL
wss://api.hustlexp.com/ws?token=<firebase_jwt>
```

### Event Types

#### Server → Client Events

```typescript
// Live task broadcast
interface LiveTaskBroadcast {
  type: 'LIVE_TASK_BROADCAST';
  data: {
    broadcast_id: string;
    task: {
      id: string;
      title: string;
      description: string;
      price: number;
      location: string;
      distance_miles: number;
      deadline: string;
      xp_multiplier: number;    // 1.25x for live tasks
    };
    expires_at: string;         // Countdown deadline
    poster: UserSummary;
  };
}

// Broadcast expired/claimed
interface LiveTaskUnavailable {
  type: 'LIVE_TASK_UNAVAILABLE';
  data: {
    broadcast_id: string;
    reason: 'EXPIRED' | 'CLAIMED' | 'CANCELLED';
  };
}

// Live mode state change
interface LiveModeStateChange {
  type: 'LIVE_MODE_STATE_CHANGE';
  data: {
    state: 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
    reason?: string;
    cooldown_ends_at?: string;
  };
}

// Task status update
interface TaskStatusUpdate {
  type: 'TASK_STATUS_UPDATE';
  data: {
    task_id: string;
    state: TaskState;
    updated_at: string;
  };
}

// New message notification
interface NewMessage {
  type: 'NEW_MESSAGE';
  data: {
    task_id: string;
    message: Message;
  };
}

// Worker location update for poster (INV-PRIVACY-2 graduated visibility)
// Authority: SPATIAL_INTELLIGENCE_LOCKED.md §5
// CRITICAL: Server NEVER sends raw worker coordinates to poster at >100m
interface PosterLocationUpdate {
  type: 'POSTER_LOCATION_UPDATE';
  data: {
    task_id: string;
    visibility: 
      | { type: 'DIRECTION_ONLY'; direction: 'N' | 'NE' | 'E' | 'SE' | 'S' | 'SW' | 'W' | 'NW'; etaMinutes: number; showWorkerPin: false }  // >0.5mi
      | { type: 'APPROXIMATE_ZONE'; center: { lat: number; lng: number }; radiusMeters: 200; etaMinutes: number; showWorkerPin: false }         // 100m-800m (coords rounded to 200m grid)
      | { type: 'PRECISE'; coordinates: { lat: number; lng: number }; showWorkerPin: true }                                                      // ≤100m (verified proximity)
      | { type: 'ON_SITE'; showWorkerPin: false };                                                                                                // IN_PROGRESS (no tracking)
    updated_at: string;
  };
}

// Worker proximity zone trigger (approaching/arrival notifications)
// Authority: SPATIAL_INTELLIGENCE_LOCKED.md §8
interface ProximityZoneTrigger {
  type: 'PROXIMITY_ZONE_TRIGGER';
  data: {
    task_id: string;
    zone: 'APPROACHING' | 'ARRIVAL';  // 500m or 100m
    distanceMeters: number;
    target: 'WORKER' | 'POSTER';      // Who receives this event
    message: string;                    // "Almost there!" or "Worker is nearby"
  };
}
```

#### Client → Server Events

```typescript
// Subscribe to live mode broadcasts
interface SubscribeLiveMode {
  type: 'SUBSCRIBE_LIVE_MODE';
  data: {
    location: { lat: number; lng: number };
    radius_miles: number;
    categories?: string[];
  };
}

// Unsubscribe from live mode
interface UnsubscribeLiveMode {
  type: 'UNSUBSCRIBE_LIVE_MODE';
}

// Update location
interface UpdateLocation {
  type: 'UPDATE_LOCATION';
  data: {
    location: { lat: number; lng: number };
  };
}

// Respond to broadcast
interface RespondToBroadcast {
  type: 'RESPOND_TO_BROADCAST';
  data: {
    broadcast_id: string;
    response: 'ACCEPT' | 'DECLINE' | 'SKIP';
    decline_reason?: string;
  };
}

// Subscribe to task updates
interface SubscribeTask {
  type: 'SUBSCRIBE_TASK';
  data: {
    task_id: string;
  };
}
```

### Connection Lifecycle

```typescript
// Heartbeat (client must send every 30 seconds)
interface Heartbeat {
  type: 'PING';
}

// Server response
interface HeartbeatResponse {
  type: 'PONG';
  timestamp: string;
}

// Connection error
interface ConnectionError {
  type: 'ERROR';
  data: {
    code: string;
    message: string;
  };
}
```

---

## Admin Endpoints

Admin endpoints require admin authentication (validated admin role in token).

### admin.getUser

Get detailed user information (admin view).

**Auth:** Admin
**Method:** Query

**Input:**
```typescript
{
  user_id: string;
}
```

**Output:**
```typescript
{
  user: UserProfile;
  account_status: 'ACTIVE' | 'PAUSED' | 'SUSPENDED';
  admin_notes: string | null;
  trust_history: TrustLedgerEntry[];
  dispute_history: DisputeSummary[];
  verification_status: VerificationStatus;
  created_at: string;
  last_active_at: string;
}
```

---

### admin.updateUserStatus

Update a user's account status.

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  user_id: string;
  status: 'ACTIVE' | 'PAUSED' | 'SUSPENDED';
  reason: string;
  notes?: string;
  duration_days?: number;       // For temporary suspensions
}
```

**Output:**
```typescript
{
  user_id: string;
  previous_status: string;
  new_status: string;
  action_id: string;            // Audit log ID
  updated_at: string;
}
```

---

### admin.resolveDispute

Resolve a dispute (already documented in dispute.resolve, but included here for admin reference).

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  dispute_id: string;
  resolution: 'HUSTLER_WINS' | 'CLIENT_WINS' | 'SPLIT';
  split_percentage?: number;    // Required if SPLIT (0-100, hustler's share)
  notes: string;
}
```

**Output:**
```typescript
{
  dispute_id: string;
  resolution: string;
  escrow_action: 'RELEASE' | 'REFUND' | 'REFUND_PARTIAL';
  resolved_at: string;
}
```

---

### admin.updateTrustTier

Manually adjust a user's trust tier.

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  user_id: string;
  new_tier: 1 | 2 | 3 | 4;
  reason: string;
  notes?: string;
}
```

**Output:**
```typescript
{
  user_id: string;
  previous_tier: number;
  new_tier: number;
  action_id: string;
  updated_at: string;
}
```

---

### admin.getModerationQueue

Get content moderation queue.

**Auth:** Admin
**Method:** Query

**Input:**
```typescript
{
  status?: 'pending' | 'reviewing' | 'escalated';
  severity?: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  limit?: number;               // Default: 20, max: 100
  offset?: number;
}
```

**Output:**
```typescript
{
  items: ModerationQueueItem[];
  total_pending: number;
  total_escalated: number;
}
```

---

### admin.reviewContent

Review flagged content.

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  moderation_id: string;
  decision: 'approve' | 'reject' | 'escalate';
  notes: string;
}
```

**Output:**
```typescript
{
  moderation_id: string;
  decision: string;
  action_id: string;
  reviewed_at: string;
}
```

---

### admin.getSystemMetrics

Get system health and metrics.

**Auth:** Admin
**Method:** Query

**Input:**
```typescript
{
  period?: '1h' | '24h' | '7d' | '30d';
}
```

**Output:**
```typescript
{
  active_users: number;
  tasks_created: number;
  tasks_completed: number;
  disputes_opened: number;
  disputes_resolved: number;
  escrow_volume_cents: number;
  moderation_queue_size: number;
  avg_response_time_ms: number;
  error_rate: number;
}
```

---

### admin.getTransferRetryQueue

Get failed transfers pending retry.

**Auth:** Admin
**Method:** Query

**Input:**
```typescript
{
  status?: 'PENDING' | 'PROCESSING' | 'FAILED_PERMANENT';
  limit?: number;
  offset?: number;
}
```

**Output:**
```typescript
{
  items: {
    id: string;
    escrow_id: string;
    worker_id: string;
    amount: number;
    attempt_count: number;
    last_error: string | null;
    next_retry_at: string | null;
    created_at: string;
  }[];
  total_pending: number;
  total_failed: number;
}
```

---

### admin.retryTransfer

Manually retry a failed transfer.

**Auth:** Admin
**Method:** Mutation

**Input:**
```typescript
{
  retry_id: string;
  force?: boolean;              // Override automatic retry schedule
}
```

**Output:**
```typescript
{
  retry_id: string;
  status: 'PROCESSING' | 'SUCCEEDED' | 'FAILED';
  stripe_transfer_id?: string;
  error?: string;
}
```

---

## §N. Subsystem API Extensions (Phase 2+)

**Status:** Endpoint definitions to be added as subsystems are implemented. Full specifications in LOCKED subsystem files.

### Judge Agent Endpoints

**Authority:** `JUDGE_AGENT_SPEC_LOCKED.md`

| Endpoint | Method | Purpose | Phase |
|----------|--------|---------|-------|
| `proof.submit` | mutation | Submit proof with evidence tier/media | v1.0 |
| `proof.getVerdict` | query | Get Judge Agent verdict for a proof | v1.0 |
| `proof.getAuditTrail` | query | Verification audit for a proof | v1.5 |
| `admin.proof.manualReview` | mutation | Resolve UNCERTAIN/MANUAL_REVIEW proofs | v1.0 |

### Risk & Trust Engine Endpoints

**Authority:** `RISK_TRUST_ENGINE_LOCKED.md`

| Endpoint | Method | Purpose | Phase |
|----------|--------|---------|-------|
| `task.getSafetyFee` | query | Get safety pool premium for a task | v1.0 |
| `worker.getRateMultiplier` | query | Get worker's current rate range (0.8x-2.0x) | v1.0 |
| `worker.setRateMultiplier` | mutation | Worker sets their rate multiplier | v1.0 |
| `claim.file` | mutation | File a claim against safety pool | v1.0 |
| `claim.getStatus` | query | Get claim status | v1.0 |
| `admin.claim.review` | mutation | Manual claim resolution | v1.0 |
| `admin.pool.getHealth` | query | Safety pool health metrics | v1.5 |
| `admin.shadow.getScore` | query | Shadow score (admin only, INV-RISK-3) | v1.5 |
| `worker.livenessChallenge` | mutation | Complete liveness verification | v1.5 |

**Critical:** Shadow score endpoints MUST NOT exist for worker role. INV-RISK-3 enforces no worker-facing API.

### Risk Classifier Endpoints

**Authority:** `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`

| Endpoint | Method | Purpose | Phase |
|----------|--------|---------|-------|
| `task.classifyRisk` | internal | Classify risk at task creation (called by task.create) | v1.0 |

Risk classification is embedded in `task.create` — not a standalone endpoint.

---

## User Safety Endpoints

### user.block

**Auth:** Protected

```typescript
// Mutation
input: { blocked_user_id: string; reason?: string }
output: { success: boolean }
```

Guard: Cannot block yourself. Max 100 blocks per user. Cannot block admin accounts.

### user.unblock

**Auth:** Protected

```typescript
// Mutation
input: { blocked_user_id: string }
output: { success: boolean }
```

### user.getBlockList

**Auth:** Protected

```typescript
// Query
input: { limit?: number; offset?: number }
output: {
  blocks: Array<{
    blocked_user_id: string;
    blocked_user_name: string;
    created_at: string;
    reason?: string;
  }>;
  total: number;
}
```

---

## Tax Document Endpoints

### tax.getW9Status

**Auth:** Protected

```typescript
// Query
output: {
  status: 'NOT_SUBMITTED' | 'PENDING' | 'VERIFIED';
  submitted_at?: string;
}
```

### tax.getDocuments

**Auth:** Protected

```typescript
// Query
input: { tax_year: number }
output: {
  documents: Array<{
    type: '1099-NEC';
    tax_year: number;
    total_earnings: number;
    available_at: string;
    download_url: string;
  }>;
}
```

---

## Support Endpoints

### support.createTicket

**Auth:** Protected

```typescript
// Mutation
input: {
  category: 'PAYMENT' | 'TASK' | 'ACCOUNT' | 'DISPUTE' | 'SAFETY' | 'OTHER';
  subject: string;
  description: string;
  task_id?: string;
  attachments?: string[]; // Storage URLs
}
output: {
  ticket_id: string;
  status: 'OPEN';
  created_at: string;
}
```

### support.getTickets

**Auth:** Protected

```typescript
// Query
input: { status?: 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED'; limit?: number }
output: {
  tickets: Array<{
    ticket_id: string;
    category: string;
    subject: string;
    status: string;
    created_at: string;
    updated_at: string;
  }>;
}
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial API contract |
| 1.1.0 | Jan 2025 | Added onboarding, verification, liveMode, task.getFeed endpoints. Fixed photo_urls array type. Fixed price minimum to 500 cents. |
| 1.2.0 | Jan 2025 | Added rating.* endpoints (§12 compliance). Added WebSocket events schema for Live Mode. |
| 1.3.0 | Jan 2025 | Added Admin Endpoints section. Added dispute states (EVIDENCE_REQUESTED, ESCALATED). Added Live Mode $15 minimum validation. |
| 1.4.0 | Feb 2026 | Added §N: Judge Agent, Risk & Trust Engine, Risk Classifier endpoint references |
| 1.5.0 | Feb 2026 | Added: Force update protocol, rate limiting headers, HX302-305/RATE_LIMITED error codes, user.block/unblock, tax document endpoints, support ticket endpoints. 42-gap audit fixes. |

---

**END OF API CONTRACT**
