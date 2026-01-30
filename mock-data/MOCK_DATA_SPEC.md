# HustleXP Mock Data Specification v1.0.0

**STATUS: CONSTITUTIONAL REFERENCE**
**Authority:** EXECUTION_QUEUE.md, BUILD_GUIDE.md §6
**Purpose:** Define mock data structures for WIRING phase (frontend development without backend)

---

## Table of Contents

1. [Overview](#overview)
2. [Mock Users](#mock-users)
3. [Mock Tasks](#mock-tasks)
4. [Mock Escrows](#mock-escrows)
5. [Mock Proofs](#mock-proofs)
6. [Mock XP Ledger](#mock-xp-ledger)
7. [Mock Badges](#mock-badges)
8. [Mock Messages](#mock-messages)
9. [Mock Notifications](#mock-notifications)
10. [Usage Guidelines](#usage-guidelines)

---

## Overview

Mock data enables frontend development to proceed without a live backend. All mock data must:

1. **Follow schema exactly** - Match `schema.sql` field types and constraints
2. **Cover all states** - Include examples of every state machine state
3. **Be deterministic** - Same IDs always return same data (no randomization)
4. **Be realistic** - Use plausible values, not "test123" placeholders

---

## Mock Users

### User Types

| ID | Type | Trust Tier | XP | Level | Purpose |
|----|------|------------|-----|-------|---------|
| `user-hustler-new` | worker | 1 | 0 | 1 | New hustler, no tasks completed |
| `user-hustler-active` | worker | 2 | 450 | 3 | Active hustler, mid-tier |
| `user-hustler-elite` | worker | 4 | 2500 | 8 | Elite hustler, max trust |
| `user-poster-new` | poster | 1 | 0 | 1 | New poster |
| `user-poster-active` | poster | 2 | 0 | 1 | Active poster (posters don't earn XP) |
| `user-both` | worker | 2 | 200 | 2 | Uses both modes |

### Mock User Objects

```javascript
// mock-data/users.js

export const MOCK_USERS = {
  'user-hustler-new': {
    id: 'user-hustler-new',
    email: 'alex.new@example.com',
    phone: '+1555000001',
    full_name: 'Alex Chen',
    avatar_url: null,
    default_mode: 'worker',
    onboarding_completed_at: '2025-01-15T10:00:00Z',
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    last_task_completed_at: null,
    is_verified: false,
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2025-01-15T09:00:00Z',
    updated_at: '2025-01-15T10:00:00Z',
  },

  'user-hustler-active': {
    id: 'user-hustler-active',
    email: 'jordan.active@example.com',
    phone: '+1555000002',
    full_name: 'Jordan Rivera',
    avatar_url: 'https://example.com/avatars/jordan.jpg',
    default_mode: 'worker',
    onboarding_completed_at: '2024-12-01T10:00:00Z',
    trust_tier: 2,
    xp_total: 450,
    current_level: 3,
    current_streak: 3,
    last_task_completed_at: '2025-01-14T16:00:00Z',
    is_verified: true,
    verified_at: '2024-12-05T14:00:00Z',
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: '2024-12-02T11:30:00Z',
    created_at: '2024-12-01T09:00:00Z',
    updated_at: '2025-01-14T16:00:00Z',
  },

  'user-hustler-elite': {
    id: 'user-hustler-elite',
    email: 'taylor.elite@example.com',
    phone: '+1555000003',
    full_name: 'Taylor Washington',
    avatar_url: 'https://example.com/avatars/taylor.jpg',
    default_mode: 'worker',
    onboarding_completed_at: '2024-06-01T10:00:00Z',
    trust_tier: 4,
    xp_total: 2500,
    current_level: 8,
    current_streak: 12,
    last_task_completed_at: '2025-01-15T09:00:00Z',
    is_verified: true,
    verified_at: '2024-06-05T14:00:00Z',
    student_id_verified: true,
    live_mode_state: 'ACTIVE',
    live_mode_session_started_at: '2025-01-15T08:00:00Z',
    xp_first_celebration_shown_at: '2024-06-02T11:30:00Z',
    created_at: '2024-06-01T09:00:00Z',
    updated_at: '2025-01-15T09:00:00Z',
  },

  'user-poster-new': {
    id: 'user-poster-new',
    email: 'sam.poster@example.com',
    phone: '+1555000004',
    full_name: 'Sam Miller',
    avatar_url: null,
    default_mode: 'poster',
    onboarding_completed_at: '2025-01-10T10:00:00Z',
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    is_verified: false,
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2025-01-10T09:00:00Z',
    updated_at: '2025-01-10T10:00:00Z',
  },

  'user-poster-active': {
    id: 'user-poster-active',
    email: 'casey.poster@example.com',
    phone: '+1555000005',
    full_name: 'Casey Thompson',
    avatar_url: 'https://example.com/avatars/casey.jpg',
    default_mode: 'poster',
    onboarding_completed_at: '2024-11-01T10:00:00Z',
    trust_tier: 2,
    xp_total: 0,
    current_level: 1,
    current_streak: 0,
    is_verified: true,
    verified_at: '2024-11-05T14:00:00Z',
    live_mode_state: 'OFF',
    xp_first_celebration_shown_at: null,
    created_at: '2024-11-01T09:00:00Z',
    updated_at: '2025-01-12T10:00:00Z',
  },
};

export const getCurrentUser = (userId) => MOCK_USERS[userId] || null;
```

---

## Mock Tasks

### Task States Coverage

| Task ID | State | Purpose |
|---------|-------|---------|
| `task-open-1` | OPEN | Available task, no worker |
| `task-open-2` | OPEN | Another available task |
| `task-open-live` | OPEN | Live mode task |
| `task-accepted` | ACCEPTED | In progress |
| `task-proof-submitted` | PROOF_SUBMITTED | Awaiting review |
| `task-disputed` | DISPUTED | Under dispute |
| `task-completed` | COMPLETED | Successfully done |
| `task-cancelled` | CANCELLED | Poster cancelled |
| `task-expired` | EXPIRED | Deadline passed |

### Mock Task Objects

```javascript
// mock-data/tasks.js

export const TaskState = {
  OPEN: 'OPEN',
  ACCEPTED: 'ACCEPTED',
  PROOF_SUBMITTED: 'PROOF_SUBMITTED',
  DISPUTED: 'DISPUTED',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
};

export const MOCK_TASKS = {
  'task-open-1': {
    id: 'task-open-1',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Help move couch to second floor',
    description: 'Need help moving a large sectional couch from ground floor to second floor apartment. Two people needed. Elevator available.',
    requirements: 'Must be able to lift 50+ lbs',
    location: '123 Main St, Apt 2B, Austin, TX 78701',
    category: 'moving',
    price: 4500, // $45.00 in cents
    state: TaskState.OPEN,
    mode: 'STANDARD',
    deadline: '2025-01-20T18:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of couch in final location',
    created_at: '2025-01-15T10:00:00Z',
    updated_at: '2025-01-15T10:00:00Z',
  },

  'task-open-2': {
    id: 'task-open-2',
    poster_id: 'user-poster-new',
    worker_id: null,
    title: 'Grocery pickup from H-E-B',
    description: 'Need someone to pick up groceries from H-E-B on Lamar. List will be provided. About 10-15 items.',
    requirements: 'Must have car',
    location: '4001 N Lamar Blvd, Austin, TX 78756',
    category: 'errands',
    price: 2000, // $20.00
    state: TaskState.OPEN,
    mode: 'STANDARD',
    deadline: '2025-01-16T14:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of receipt and bags',
    created_at: '2025-01-15T11:00:00Z',
    updated_at: '2025-01-15T11:00:00Z',
  },

  'task-open-live': {
    id: 'task-open-live',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Urgent: Flat tire help needed',
    description: 'Car has flat tire in parking lot. Need help changing to spare.',
    requirements: 'Know how to change a tire',
    location: '500 E 7th St, Austin, TX 78701',
    category: 'automotive',
    price: 3500, // $35.00
    state: TaskState.OPEN,
    mode: 'LIVE',
    live_broadcast_started_at: '2025-01-15T14:30:00Z',
    live_broadcast_radius_miles: 2.5,
    deadline: '2025-01-15T16:00:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of spare tire installed',
    created_at: '2025-01-15T14:30:00Z',
    updated_at: '2025-01-15T14:30:00Z',
  },

  'task-accepted': {
    id: 'task-accepted',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-active',
    title: 'Deep clean kitchen',
    description: 'Full kitchen deep clean including oven, fridge interior, and cabinets.',
    requirements: 'Cleaning supplies provided',
    location: '789 Oak Lane, Austin, TX 78704',
    category: 'cleaning',
    price: 7500, // $75.00
    state: TaskState.ACCEPTED,
    mode: 'STANDARD',
    deadline: '2025-01-16T20:00:00Z',
    accepted_at: '2025-01-15T12:00:00Z',
    requires_proof: true,
    proof_instructions: 'Before/after photos of kitchen',
    created_at: '2025-01-14T16:00:00Z',
    updated_at: '2025-01-15T12:00:00Z',
  },

  'task-proof-submitted': {
    id: 'task-proof-submitted',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-elite',
    title: 'Assemble IKEA bookshelf',
    description: 'Need help assembling a BILLY bookshelf. All parts and tools provided.',
    location: '456 Pine Ave, Austin, TX 78702',
    category: 'assembly',
    price: 4000, // $40.00
    state: TaskState.PROOF_SUBMITTED,
    mode: 'STANDARD',
    accepted_at: '2025-01-14T10:00:00Z',
    proof_submitted_at: '2025-01-14T12:30:00Z',
    requires_proof: true,
    proof_instructions: 'Photo of assembled bookshelf',
    created_at: '2025-01-13T18:00:00Z',
    updated_at: '2025-01-14T12:30:00Z',
  },

  'task-disputed': {
    id: 'task-disputed',
    poster_id: 'user-poster-new',
    worker_id: 'user-hustler-active',
    title: 'Dog walking (1 hour)',
    description: 'Walk my golden retriever Max for 1 hour in the neighborhood.',
    location: '321 Elm St, Austin, TX 78703',
    category: 'pet-care',
    price: 2500, // $25.00
    state: TaskState.DISPUTED,
    mode: 'STANDARD',
    accepted_at: '2025-01-13T14:00:00Z',
    proof_submitted_at: '2025-01-13T15:30:00Z',
    requires_proof: true,
    proof_instructions: 'Photo with dog during walk',
    created_at: '2025-01-13T10:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
  },

  'task-completed': {
    id: 'task-completed',
    poster_id: 'user-poster-active',
    worker_id: 'user-hustler-active',
    title: 'Package delivery to downtown',
    description: 'Deliver a small package to downtown office building.',
    location: '100 Congress Ave, Austin, TX 78701',
    category: 'delivery',
    price: 1500, // $15.00
    state: TaskState.COMPLETED,
    mode: 'STANDARD',
    accepted_at: '2025-01-14T09:00:00Z',
    proof_submitted_at: '2025-01-14T10:00:00Z',
    completed_at: '2025-01-14T10:15:00Z',
    requires_proof: true,
    created_at: '2025-01-14T08:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
  },

  'task-cancelled': {
    id: 'task-cancelled',
    poster_id: 'user-poster-new',
    worker_id: null,
    title: 'Yard work - mowing',
    description: 'Mow front and back yard.',
    location: '555 Cedar Dr, Austin, TX 78745',
    category: 'yard-work',
    price: 5000, // $50.00
    state: TaskState.CANCELLED,
    mode: 'STANDARD',
    cancelled_at: '2025-01-14T08:00:00Z',
    requires_proof: true,
    created_at: '2025-01-13T12:00:00Z',
    updated_at: '2025-01-14T08:00:00Z',
  },

  'task-expired': {
    id: 'task-expired',
    poster_id: 'user-poster-active',
    worker_id: null,
    title: 'Help with moving boxes',
    description: 'Need help loading boxes into truck.',
    location: '999 First St, Austin, TX 78701',
    category: 'moving',
    price: 3000, // $30.00
    state: TaskState.EXPIRED,
    mode: 'STANDARD',
    deadline: '2025-01-10T18:00:00Z',
    expired_at: '2025-01-10T18:00:00Z',
    requires_proof: true,
    created_at: '2025-01-09T12:00:00Z',
    updated_at: '2025-01-10T18:00:00Z',
  },
};

export const getTask = (taskId) => MOCK_TASKS[taskId] || null;

export const getTasksForFeed = (filters = {}) => {
  return Object.values(MOCK_TASKS)
    .filter(task => task.state === TaskState.OPEN)
    .filter(task => !filters.category || task.category === filters.category)
    .filter(task => !filters.maxPrice || task.price <= filters.maxPrice);
};

export const getTasksForUser = (userId, role) => {
  return Object.values(MOCK_TASKS)
    .filter(task => role === 'poster'
      ? task.poster_id === userId
      : task.worker_id === userId
    );
};
```

---

## Mock Escrows

### Escrow States Coverage

| Escrow ID | State | Linked Task |
|-----------|-------|-------------|
| `escrow-pending` | PENDING | (standalone test) |
| `escrow-funded-1` | FUNDED | task-accepted |
| `escrow-funded-2` | FUNDED | task-proof-submitted |
| `escrow-locked` | LOCKED_DISPUTE | task-disputed |
| `escrow-released` | RELEASED | task-completed |
| `escrow-refunded` | REFUNDED | task-cancelled |

### Mock Escrow Objects

```javascript
// mock-data/escrows.js

export const EscrowState = {
  PENDING: 'PENDING',
  FUNDED: 'FUNDED',
  LOCKED_DISPUTE: 'LOCKED_DISPUTE',
  RELEASED: 'RELEASED',
  REFUNDED: 'REFUNDED',
  REFUND_PARTIAL: 'REFUND_PARTIAL',
};

export const MOCK_ESCROWS = {
  'escrow-funded-1': {
    id: 'escrow-funded-1',
    task_id: 'task-accepted',
    amount: 7500, // $75.00
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_funded_1',
    funded_at: '2025-01-15T12:00:00Z',
    created_at: '2025-01-14T16:00:00Z',
    updated_at: '2025-01-15T12:00:00Z',
  },

  'escrow-funded-2': {
    id: 'escrow-funded-2',
    task_id: 'task-proof-submitted',
    amount: 4000, // $40.00
    state: EscrowState.FUNDED,
    stripe_payment_intent_id: 'pi_mock_funded_2',
    funded_at: '2025-01-14T10:00:00Z',
    created_at: '2025-01-13T18:00:00Z',
    updated_at: '2025-01-14T10:00:00Z',
  },

  'escrow-locked': {
    id: 'escrow-locked',
    task_id: 'task-disputed',
    amount: 2500, // $25.00
    state: EscrowState.LOCKED_DISPUTE,
    stripe_payment_intent_id: 'pi_mock_locked',
    funded_at: '2025-01-13T14:00:00Z',
    created_at: '2025-01-13T10:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
  },

  'escrow-released': {
    id: 'escrow-released',
    task_id: 'task-completed',
    amount: 1500, // $15.00
    state: EscrowState.RELEASED,
    stripe_payment_intent_id: 'pi_mock_released',
    stripe_transfer_id: 'tr_mock_released',
    funded_at: '2025-01-14T09:00:00Z',
    released_at: '2025-01-14T10:15:00Z',
    created_at: '2025-01-14T08:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
  },

  'escrow-refunded': {
    id: 'escrow-refunded',
    task_id: 'task-cancelled',
    amount: 5000, // $50.00
    state: EscrowState.REFUNDED,
    stripe_payment_intent_id: 'pi_mock_refunded',
    stripe_refund_id: 're_mock_refunded',
    funded_at: '2025-01-13T12:30:00Z',
    refunded_at: '2025-01-14T08:00:00Z',
    created_at: '2025-01-13T12:00:00Z',
    updated_at: '2025-01-14T08:00:00Z',
  },
};

export const getEscrow = (escrowId) => MOCK_ESCROWS[escrowId] || null;
export const getEscrowForTask = (taskId) => {
  return Object.values(MOCK_ESCROWS).find(e => e.task_id === taskId) || null;
};
```

---

## Mock Proofs

```javascript
// mock-data/proofs.js

export const ProofState = {
  PENDING: 'PENDING',
  SUBMITTED: 'SUBMITTED',
  ACCEPTED: 'ACCEPTED',
  REJECTED: 'REJECTED',
  EXPIRED: 'EXPIRED',
};

export const MOCK_PROOFS = {
  'proof-submitted': {
    id: 'proof-submitted',
    task_id: 'task-proof-submitted',
    submitter_id: 'user-hustler-elite',
    state: ProofState.SUBMITTED,
    description: 'Bookshelf fully assembled and secured to wall.',
    submitted_at: '2025-01-14T12:30:00Z',
    created_at: '2025-01-14T10:00:00Z',
    updated_at: '2025-01-14T12:30:00Z',
  },

  'proof-accepted': {
    id: 'proof-accepted',
    task_id: 'task-completed',
    submitter_id: 'user-hustler-active',
    state: ProofState.ACCEPTED,
    description: 'Package delivered to front desk.',
    submitted_at: '2025-01-14T10:00:00Z',
    reviewed_by: 'user-poster-active',
    reviewed_at: '2025-01-14T10:15:00Z',
    created_at: '2025-01-14T09:00:00Z',
    updated_at: '2025-01-14T10:15:00Z',
  },

  'proof-disputed': {
    id: 'proof-disputed',
    task_id: 'task-disputed',
    submitter_id: 'user-hustler-active',
    state: ProofState.REJECTED,
    description: 'Walked Max for 1 hour around neighborhood.',
    submitted_at: '2025-01-13T15:30:00Z',
    reviewed_by: 'user-poster-new',
    reviewed_at: '2025-01-13T16:00:00Z',
    rejection_reason: 'Photo does not show required duration or route.',
    created_at: '2025-01-13T14:00:00Z',
    updated_at: '2025-01-13T16:00:00Z',
  },
};

export const getProof = (proofId) => MOCK_PROOFS[proofId] || null;
export const getProofForTask = (taskId) => {
  return Object.values(MOCK_PROOFS).find(p => p.task_id === taskId) || null;
};
```

---

## Mock XP Ledger

```javascript
// mock-data/xp-ledger.js

export const MOCK_XP_LEDGER = [
  {
    id: 'xp-entry-1',
    user_id: 'user-hustler-active',
    task_id: 'task-completed',
    escrow_id: 'escrow-released',
    base_xp: 50,
    streak_multiplier: 1.15,
    decay_factor: 1.0,
    effective_xp: 58, // 50 * 1.15 = 57.5 → 58
    reason: 'task_completion',
    user_xp_before: 392,
    user_xp_after: 450,
    user_level_before: 3,
    user_level_after: 3,
    user_streak_at_award: 3,
    awarded_at: '2025-01-14T10:15:00Z',
  },
  {
    id: 'xp-entry-2',
    user_id: 'user-hustler-active',
    task_id: 'task-old-1',
    escrow_id: 'escrow-old-1',
    base_xp: 100,
    streak_multiplier: 1.10,
    decay_factor: 1.0,
    effective_xp: 110,
    reason: 'task_completion',
    user_xp_before: 282,
    user_xp_after: 392,
    user_level_before: 2,
    user_level_after: 3,
    user_streak_at_award: 2,
    awarded_at: '2025-01-13T14:00:00Z',
  },
  // Add more entries for user-hustler-elite
  {
    id: 'xp-entry-elite-1',
    user_id: 'user-hustler-elite',
    task_id: 'task-elite-recent',
    escrow_id: 'escrow-elite-recent',
    base_xp: 75,
    streak_multiplier: 1.60,
    decay_factor: 1.0,
    effective_xp: 120,
    reason: 'task_completion',
    user_xp_before: 2380,
    user_xp_after: 2500,
    user_level_before: 8,
    user_level_after: 8,
    user_streak_at_award: 12,
    awarded_at: '2025-01-15T09:00:00Z',
  },
];

export const getXPLedgerForUser = (userId) => {
  return MOCK_XP_LEDGER.filter(entry => entry.user_id === userId);
};

export const getTotalXPForUser = (userId) => {
  const entries = getXPLedgerForUser(userId);
  if (entries.length === 0) return 0;
  const lastEntry = entries.sort((a, b) =>
    new Date(b.awarded_at) - new Date(a.awarded_at)
  )[0];
  return lastEntry.user_xp_after;
};
```

---

## Mock Badges

```javascript
// mock-data/badges.js

export const BADGE_DEFINITIONS = {
  'first-task': {
    id: 'first-task',
    name: 'First Steps',
    description: 'Complete your first task',
    icon: 'rocket',
    tier: 'bronze',
  },
  'streak-7': {
    id: 'streak-7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: 'flame',
    tier: 'silver',
  },
  'streak-30': {
    id: 'streak-30',
    name: 'Monthly Master',
    description: 'Maintain a 30-day streak',
    icon: 'flame',
    tier: 'gold',
  },
  'trust-tier-2': {
    id: 'trust-tier-2',
    name: 'Trusted Hustler',
    description: 'Reach Trust Tier 2',
    icon: 'shield',
    tier: 'bronze',
  },
  'trust-tier-4': {
    id: 'trust-tier-4',
    name: 'Elite Status',
    description: 'Reach Trust Tier 4',
    icon: 'crown',
    tier: 'gold',
  },
  'level-5': {
    id: 'level-5',
    name: 'Rising Star',
    description: 'Reach Level 5',
    icon: 'star',
    tier: 'silver',
  },
  'tasks-10': {
    id: 'tasks-10',
    name: 'Dedicated',
    description: 'Complete 10 tasks',
    icon: 'check-circle',
    tier: 'bronze',
  },
  'tasks-50': {
    id: 'tasks-50',
    name: 'Veteran',
    description: 'Complete 50 tasks',
    icon: 'award',
    tier: 'silver',
  },
};

export const MOCK_USER_BADGES = {
  'user-hustler-new': [],
  'user-hustler-active': [
    { badge_id: 'first-task', awarded_at: '2024-12-02T11:30:00Z' },
    { badge_id: 'trust-tier-2', awarded_at: '2024-12-15T14:00:00Z' },
    { badge_id: 'tasks-10', awarded_at: '2025-01-10T12:00:00Z' },
  ],
  'user-hustler-elite': [
    { badge_id: 'first-task', awarded_at: '2024-06-02T11:30:00Z' },
    { badge_id: 'trust-tier-2', awarded_at: '2024-06-15T14:00:00Z' },
    { badge_id: 'trust-tier-4', awarded_at: '2024-09-01T10:00:00Z' },
    { badge_id: 'streak-7', awarded_at: '2024-06-10T12:00:00Z' },
    { badge_id: 'streak-30', awarded_at: '2024-07-05T12:00:00Z' },
    { badge_id: 'level-5', awarded_at: '2024-08-15T12:00:00Z' },
    { badge_id: 'tasks-10', awarded_at: '2024-06-20T12:00:00Z' },
    { badge_id: 'tasks-50', awarded_at: '2024-10-01T12:00:00Z' },
  ],
};

export const getBadgesForUser = (userId) => {
  const userBadges = MOCK_USER_BADGES[userId] || [];
  return userBadges.map(ub => ({
    ...BADGE_DEFINITIONS[ub.badge_id],
    awarded_at: ub.awarded_at,
  }));
};

export const getAllBadgeDefinitions = () => Object.values(BADGE_DEFINITIONS);
```

---

## Mock Messages

```javascript
// mock-data/messages.js

export const MOCK_MESSAGES = {
  'task-accepted': [
    {
      id: 'msg-1',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: 'TEXT',
      content: "Hi! I'm on my way. Should be there in about 20 minutes.",
      created_at: '2025-01-15T12:05:00Z',
    },
    {
      id: 'msg-2',
      task_id: 'task-accepted',
      sender_id: 'user-poster-active',
      message_type: 'TEXT',
      content: "Great! I'll leave the door unlocked. The kitchen is through the hallway on the left.",
      created_at: '2025-01-15T12:07:00Z',
    },
    {
      id: 'msg-3',
      task_id: 'task-accepted',
      sender_id: 'user-hustler-active',
      message_type: 'TEXT',
      content: "Perfect, thanks!",
      created_at: '2025-01-15T12:08:00Z',
    },
  ],
  'task-disputed': [
    {
      id: 'msg-d1',
      task_id: 'task-disputed',
      sender_id: 'user-hustler-active',
      message_type: 'TEXT',
      content: "Just finished walking Max! He was very well-behaved.",
      created_at: '2025-01-13T15:25:00Z',
    },
    {
      id: 'msg-d2',
      task_id: 'task-disputed',
      sender_id: 'user-poster-new',
      message_type: 'TEXT',
      content: "The photo you sent doesn't show you actually walked for an hour. My GPS collar shows only 20 minutes.",
      created_at: '2025-01-13T15:45:00Z',
    },
  ],
};

export const getMessagesForTask = (taskId) => {
  return MOCK_MESSAGES[taskId] || [];
};
```

---

## Mock Notifications

```javascript
// mock-data/notifications.js

export const MOCK_NOTIFICATIONS = {
  'user-hustler-active': [
    {
      id: 'notif-1',
      user_id: 'user-hustler-active',
      type: 'TASK_ACCEPTED',
      title: 'Task Accepted!',
      body: 'You accepted "Deep clean kitchen". Head to the location to get started.',
      task_id: 'task-accepted',
      read: false,
      created_at: '2025-01-15T12:00:00Z',
    },
    {
      id: 'notif-2',
      user_id: 'user-hustler-active',
      type: 'XP_EARNED',
      title: '+58 XP',
      body: 'You earned XP for completing "Package delivery to downtown"',
      task_id: 'task-completed',
      read: true,
      created_at: '2025-01-14T10:15:00Z',
    },
    {
      id: 'notif-3',
      user_id: 'user-hustler-active',
      type: 'DISPUTE_OPENED',
      title: 'Dispute Opened',
      body: 'The poster has disputed your proof for "Dog walking (1 hour)"',
      task_id: 'task-disputed',
      read: true,
      created_at: '2025-01-13T16:00:00Z',
    },
  ],
  'user-poster-active': [
    {
      id: 'notif-p1',
      user_id: 'user-poster-active',
      type: 'TASK_WORKER_ASSIGNED',
      title: 'Worker Found',
      body: 'Jordan Rivera accepted your task "Deep clean kitchen"',
      task_id: 'task-accepted',
      read: false,
      created_at: '2025-01-15T12:00:00Z',
    },
    {
      id: 'notif-p2',
      user_id: 'user-poster-active',
      type: 'PROOF_SUBMITTED',
      title: 'Proof Submitted',
      body: 'Taylor Washington submitted proof for "Assemble IKEA bookshelf"',
      task_id: 'task-proof-submitted',
      read: false,
      created_at: '2025-01-14T12:30:00Z',
    },
  ],
};

export const getNotificationsForUser = (userId) => {
  return MOCK_NOTIFICATIONS[userId] || [];
};

export const getUnreadCount = (userId) => {
  const notifications = MOCK_NOTIFICATIONS[userId] || [];
  return notifications.filter(n => !n.read).length;
};
```

---

## Usage Guidelines

### Importing Mock Data

```javascript
// In screens or components
import { MOCK_USERS, getCurrentUser } from '@/mock-data/users';
import { MOCK_TASKS, getTasksForFeed } from '@/mock-data/tasks';
import { getEscrowForTask } from '@/mock-data/escrows';

// Example usage in a screen
const TaskFeedScreen = () => {
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    // Use mock data during development
    const mockTasks = getTasksForFeed({ category: 'cleaning' });
    setTasks(mockTasks);
  }, []);

  return <TaskList tasks={tasks} />;
};
```

### Switching Between Mock and Real Data

```javascript
// utils/dataSource.js
const USE_MOCK_DATA = __DEV__; // Use mock in development

export const fetchTasks = async (filters) => {
  if (USE_MOCK_DATA) {
    return getTasksForFeed(filters);
  }
  return api.tasks.list(filters);
};
```

### Testing State Transitions

Mock data covers all states, allowing UI testing of:
- Empty states (new user with no history)
- Active states (task in progress)
- Terminal states (completed, cancelled)
- Edge states (disputes, locked escrows)

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial mock data specification |

---

**END OF MOCK DATA SPECIFICATION**
