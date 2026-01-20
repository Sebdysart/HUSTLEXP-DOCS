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
  price: number;           // USD cents, min 100 ($1.00)
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
  state: 'OPEN' | 'RESOLVED';
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
  photo_url?: string;       // Required for PHOTO
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
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial API contract |

---

**END OF API CONTRACT**
