# HustleXP API Contract v1.0.0

**STATUS: CONSTITUTIONAL REFERENCE**
**Authority:** BUILD_GUIDE.md §5, PRODUCT_SPEC.md, schema.sql
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

---

## Error Codes

### Database Invariant Errors (HXxxx)

| Code | Meaning | Recovery |
|------|---------|----------|
| HX001 | Task terminal state violation | Cannot modify completed/cancelled/expired task |
| HX002 | Escrow terminal state violation | Cannot modify released/refunded escrow |
| HX101 | INV-1: XP without RELEASED escrow | Task must be completed first |
| HX102 | XP ledger immutable | Cannot delete XP entries |
| HX201 | INV-2: RELEASED without COMPLETED task | Task must be completed first |
| HX301 | INV-3: COMPLETED without ACCEPTED proof | Proof must be accepted first |
| HX401 | INV-4: Escrow amount modification | Amount is immutable after creation |
| HX501 | Badge immutable | Cannot delete badge entries |

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

### task.create

Create a new task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  title: string;           // 1-255 chars
  description: string;     // 1-5000 chars
  requirements?: string;   // Optional, max 2000 chars
  location: string;        // Address string
  location_lat?: number;   // Latitude
  location_lng?: number;   // Longitude
  category: string;        // From TASK_CATEGORIES
  price: number;           // USD cents, min 500 ($5.00), min 1500 ($15.00) for LIVE mode
  deadline: string;        // ISO 8601 datetime
  mode?: 'STANDARD' | 'LIVE'; // Default: STANDARD
  requires_proof?: boolean;   // Default: true
  proof_instructions?: string;
}
```

**Output:**
```typescript
{
  id: string;
  poster_id: string;
  state: 'OPEN';
  created_at: string;
  escrow_id: string;      // Created escrow
  payment_intent_id: string; // Stripe PI for funding
}
```

---

### task.accept

Accept an open task (as worker).

**Auth:** Protected
**Method:** Mutation

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
  state: 'ACCEPTED';
  worker_id: string;
  accepted_at: string;
}
```

**Errors:**
- `NOT_FOUND` - Task not found
- `FORBIDDEN` - User is the poster (self-accept)
- `CONFLICT` - Task not in OPEN state
- `FORBIDDEN` - User doesn't meet trust tier requirement

---

### task.submitProof

Submit proof of completion (as worker).

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
  description: string;    // 1-2000 chars
  photo_urls: string[];   // 1-5 photo URLs (from upload)
}
```

**Output:**
```typescript
{
  task: {
    id: string;
    state: 'PROOF_SUBMITTED';
    proof_submitted_at: string;
  };
  proof: {
    id: string;
    state: 'SUBMITTED';
  };
}
```

**Errors:**
- `NOT_FOUND` - Task not found
- `FORBIDDEN` - User is not the worker
- `CONFLICT` - Task not in ACCEPTED state
- `VALIDATION_ERROR` - Photos required

---

### task.complete

Complete a task (as poster, after accepting proof).

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
}
```

**Output:**
```typescript
{
  task: {
    id: string;
    state: 'COMPLETED';
    completed_at: string;
  };
  escrow: {
    id: string;
    state: 'RELEASED';
    released_at: string;
  };
  xp_awarded?: {
    base_xp: number;
    streak_multiplier: number;
    effective_xp: number;
  };
}
```

**Errors:**
- `NOT_FOUND` - Task not found
- `FORBIDDEN` - User is not the poster
- `CONFLICT` - Task not in PROOF_SUBMITTED state
- `HX301` - Proof not in ACCEPTED state

---

### task.cancel

Cancel a task.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
  reason?: string;        // Optional cancellation reason
}
```

**Output:**
```typescript
{
  task: {
    id: string;
    state: 'CANCELLED';
    cancelled_at: string;
  };
  escrow: {
    id: string;
    state: 'REFUNDED';
    refunded_at: string;
  };
}
```

**Errors:**
- `NOT_FOUND` - Task not found
- `FORBIDDEN` - User is not poster or admin
- `CONFLICT` - Task already in terminal state

---

### task.getById

Get a single task by ID.

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
  poster_id: string;
  worker_id: string | null;
  title: string;
  description: string;
  requirements: string | null;
  location: string;
  location_lat: number | null;
  location_lng: number | null;
  category: string;
  price: number;
  state: TaskState;
  mode: 'STANDARD' | 'LIVE';
  deadline: string;
  requires_proof: boolean;
  proof_instructions: string | null;
  accepted_at: string | null;
  proof_submitted_at: string | null;
  completed_at: string | null;
  cancelled_at: string | null;
  created_at: string;
  updated_at: string;
  // Expanded relations
  poster: UserSummary;
  worker: UserSummary | null;
  escrow: EscrowSummary | null;
  proof: ProofSummary | null;
}
```

---

### task.list

List tasks with filters.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  filter?: {
    state?: TaskState | TaskState[];
    category?: string;
    mode?: 'STANDARD' | 'LIVE';
    poster_id?: string;
    worker_id?: string;
    min_price?: number;
    max_price?: number;
  };
  sort?: {
    field: 'created_at' | 'price' | 'deadline';
    direction: 'asc' | 'desc';
  };
  pagination?: {
    limit?: number;   // Default 20, max 100
    offset?: number;  // Default 0
  };
}
```

**Output:**
```typescript
{
  tasks: TaskSummary[];
  total: number;
  has_more: boolean;
}
```

---

## Escrow Endpoints

### escrow.createIntent

Create a Stripe PaymentIntent for escrow funding.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
}
```

**Output:**
```typescript
{
  escrow_id: string;
  payment_intent_id: string;
  client_secret: string;  // For Stripe.js
  amount: number;
}
```

---

### escrow.release

Release escrow to worker (internal, called by task.complete).

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  escrow_id: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'RELEASED';
  released_at: string;
  transfer_id: string;  // Stripe Transfer ID
}
```

**Errors:**
- `HX201` - Task not in COMPLETED state

---

### escrow.refund

Refund escrow to poster.

**Auth:** Protected (admin or poster)
**Method:** Mutation

**Input:**
```typescript
{
  escrow_id: string;
}
```

**Output:**
```typescript
{
  id: string;
  state: 'REFUNDED';
  refunded_at: string;
  refund_id: string;  // Stripe Refund ID
}
```

---

### escrow.getByTaskId

Get escrow for a task.

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
  amount: number;
  state: EscrowState;
  stripe_payment_intent_id: string;
  stripe_transfer_id: string | null;
  stripe_refund_id: string | null;
  funded_at: string | null;
  released_at: string | null;
  refunded_at: string | null;
  created_at: string;
}
```

---

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

### user.getProfile

Get current user's profile.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  id: string;
  email: string;
  phone: string | null;
  full_name: string;
  avatar_url: string | null;
  default_mode: 'worker' | 'poster';
  trust_tier: number;
  xp_total: number;
  current_level: number;
  current_streak: number;
  is_verified: boolean;
  verified_at: string | null;
  onboarding_completed_at: string | null;
  created_at: string;
}
```

---

### user.updateProfile

Update user profile.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  full_name?: string;
  avatar_url?: string;
  default_mode?: 'worker' | 'poster';
}
```

**Output:**
```typescript
{
  id: string;
  full_name: string;
  avatar_url: string | null;
  default_mode: 'worker' | 'poster';
  updated_at: string;
}
```

---

### user.getXP

Get XP summary and history.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  limit?: number;  // History entries, default 10
}
```

**Output:**
```typescript
{
  total_xp: number;
  current_level: number;
  current_streak: number;
  level_progress: {
    current_threshold: number;
    next_threshold: number;
    progress_percent: number;
  };
  recent_entries: XPLedgerEntry[];
}
```

---

### user.getBadges

Get user's badges.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  user_id?: string;  // Default: current user
}
```

**Output:**
```typescript
{
  earned_badges: Badge[];
  available_badges: BadgeDefinition[];
  total_earned: number;
  total_available: number;
}
```

---

### user.getTrustTier

Get trust tier info.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  current_tier: number;       // 1-4
  tier_name: string;          // "Newcomer", "Trusted", etc.
  next_tier: number | null;   // null if at max
  requirements_for_next: {
    tasks_completed: { required: number; current: number };
    approval_rate: { required: number; current: number };
    avg_rating: { required: number; current: number };
  } | null;
  tier_benefits: string[];
}
```

---

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

### messaging.getThread

Get messages for a task.

**Auth:** Protected (must be poster or worker)
**Method:** Query

**Input:**
```typescript
{
  task_id: string;
  limit?: number;     // Default 50
  before?: string;    // Message ID for pagination
}
```

**Output:**
```typescript
{
  messages: Message[];
  has_more: boolean;
}
```

```typescript
// Message type
{
  id: string;
  task_id: string;
  sender_id: string;
  message_type: 'TEXT' | 'PHOTO' | 'LOCATION' | 'AUTO_STATUS' | 'SYSTEM';
  content: string;
  photo_url?: string;
  location?: { lat: number; lng: number };
  read_at: string | null;
  created_at: string;
}
```

---

### messaging.sendMessage

Send a message in a task thread.

**Auth:** Protected (must be poster or worker)
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
  message_type: 'TEXT' | 'PHOTO' | 'LOCATION';
  content: string;          // Max 2000 chars for TEXT
  photo_urls?: string[];    // Required for PHOTO, max 3
  location?: {              // Required for LOCATION
    lat: number;
    lng: number;
  };
}
```

**Output:**
```typescript
{
  id: string;
  task_id: string;
  sender_id: string;
  message_type: string;
  content: string;
  created_at: string;
}
```

**Errors:**
- `FORBIDDEN` - Task not in ACCEPTED/PROOF_SUBMITTED/DISPUTED state
- `FORBIDDEN` - User is not poster or worker

---

### messaging.markRead

Mark messages as read.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
  message_ids: string[];
}
```

**Output:**
```typescript
{
  marked_count: number;
}
```

---

## Notification Endpoints

### notification.list

Get notifications for current user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  unread_only?: boolean;   // Default false
  limit?: number;          // Default 20, max 100
  offset?: number;         // Default 0
}
```

**Output:**
```typescript
{
  notifications: Notification[];
  unread_count: number;
  total: number;
}
```

```typescript
// Notification type
{
  id: string;
  user_id: string;
  type: NotificationType;
  title: string;
  body: string;
  priority: 'HIGH' | 'NORMAL' | 'LOW';
  task_id?: string;
  badge_id?: string;
  read: boolean;
  created_at: string;
}
```

---

### notification.markRead

Mark notifications as read.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  notification_ids: string[];
}
```

**Output:**
```typescript
{
  marked_count: number;
}
```

---

### notification.getPreferences

Get notification preferences.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  push_enabled: boolean;
  email_enabled: boolean;
  sms_enabled: boolean;
  quiet_hours: {
    enabled: boolean;
    start: string;    // "22:00"
    end: string;      // "08:00"
  };
  categories: {
    task_updates: boolean;
    messages: boolean;
    xp_badges: boolean;
    marketing: boolean;
  };
}
```

---

### notification.updatePreferences

Update notification preferences.

**Auth:** Protected
**Method:** Mutation

**Input:** (same shape as getPreferences output, all fields optional)

**Output:** (same as getPreferences)

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
- `payment_intent.canceled` → Mark escrow cancelled
- `transfer.created` → Track transfer ID

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

### liveMode.activate

Activate live mode for the current user.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  location: {
    lat: number;
    lng: number;
  };
  radius_miles?: number;              // Default: 5, max: 25
  categories?: string[];              // Optional category filter
}
```

**Output:**
```typescript
{
  session_id: string;
  state: 'ACTIVE';
  started_at: string;
  location: { lat: number; lng: number };
  radius_miles: number;
  categories: string[] | null;
}
```

**Errors:**
- `FORBIDDEN` - User in COOLDOWN or BANNED state
- `VALIDATION_ERROR` - Invalid location

---

### liveMode.deactivate

Deactivate live mode.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  reason?: 'MANUAL' | 'FATIGUE';      // Default: MANUAL
}
```

**Output:**
```typescript
{
  session_id: string;
  state: 'OFF';
  ended_at: string;
  end_reason: string;
  session_stats: {
    duration_minutes: number;
    tasks_accepted: number;
    tasks_declined: number;
    tasks_completed: number;
    earnings_cents: number;
  };
}
```

---

### liveMode.getStatus

Get current live mode status.

**Auth:** Protected
**Method:** Query

**Input:** None

**Output:**
```typescript
{
  state: 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
  session: {
    id: string;
    started_at: string;
    location: { lat: number; lng: number };
    radius_miles: number;
    tasks_accepted: number;
    earnings_cents: number;
  } | null;
  cooldown_ends_at: string | null;
  ban_ends_at: string | null;
  stats_today: {
    sessions: number;
    total_minutes: number;
    tasks_completed: number;
    earnings_cents: number;
  };
}
```

---

### liveMode.updateLocation

Update location while in live mode.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  location: {
    lat: number;
    lng: number;
  };
}
```

**Output:**
```typescript
{
  location: { lat: number; lng: number };
  updated_at: string;
  nearby_broadcast_count: number;
}
```

**Errors:**
- `CONFLICT` - Not in ACTIVE state

---

### liveMode.respondToBroadcast

Respond to a live task broadcast.

**Auth:** Protected
**Method:** Mutation

**Input:**
```typescript
{
  broadcast_id: string;
  response: 'ACCEPT' | 'DECLINE' | 'SKIP';
  decline_reason?: string;            // Required if DECLINE
}
```

**Output:**
```typescript
{
  success: boolean;
  task?: {                            // Only if ACCEPT succeeded
    id: string;
    title: string;
    price: number;
    location: string;
    deadline: string;
  };
  message?: string;                   // If already claimed by another
}
```

---

## Task Feed Endpoints

### task.getFeed

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

### task.getMatchingScore

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

### rating.submit

Submit a rating after task completion.

**Auth:** Protected (must be poster or worker on the task)
**Method:** Mutation

**Input:**
```typescript
{
  task_id: string;
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
  task_id: string;
  rater_id: string;
  ratee_id: string;
  stars: number;
  comment: string | null;
  tags: string[];
  created_at: string;
}
```

**Errors:**
- `FORBIDDEN` - Task not in COMPLETED state
- `FORBIDDEN` - User is not poster or worker for task
- `CONFLICT` - User already rated this task
- `VALIDATION_ERROR` - Rating window expired (7 days after completion)
- `VALIDATION_ERROR` - Stars must be 1-5

---

### rating.getForTask

Get ratings for a specific task.

**Auth:** Protected (must be poster or worker on the task)
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
  poster_rating: {
    id: string;
    stars: number;
    comment: string | null;
    tags: string[];
    created_at: string;
  } | null;
  worker_rating: {
    id: string;
    stars: number;
    comment: string | null;
    tags: string[];
    created_at: string;
  } | null;
  both_submitted: boolean;
  rating_window_expires_at: string | null;
}
```

---

### rating.getForUser

Get aggregated ratings for a user.

**Auth:** Protected
**Method:** Query

**Input:**
```typescript
{
  user_id: string;
  role?: 'poster' | 'worker';  // Filter by role
  limit?: number;              // Recent ratings, default 10, max 50
}
```

**Output:**
```typescript
{
  user_id: string;
  aggregate: {
    average_stars: number;       // 0.0 to 5.0
    total_ratings: number;
    star_distribution: {
      '1': number;
      '2': number;
      '3': number;
      '4': number;
      '5': number;
    };
    common_tags: { tag: string; count: number }[];
  };
  recent_ratings: {
    id: string;
    task_id: string;
    stars: number;
    comment: string | null;
    tags: string[];
    rater: UserSummary;
    created_at: string;
  }[];
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

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial API contract |
| 1.1.0 | Jan 2025 | Added onboarding, verification, liveMode, task.getFeed endpoints. Fixed photo_urls array type. Fixed price minimum to 500 cents. |
| 1.2.0 | Jan 2025 | Added rating.* endpoints (§12 compliance). Added WebSocket events schema for Live Mode. |
| 1.3.0 | Jan 2025 | Added Admin Endpoints section. Added dispute states (EVIDENCE_REQUESTED, ESCALATED). Added Live Mode $15 minimum validation. |

---

**END OF API CONTRACT**
