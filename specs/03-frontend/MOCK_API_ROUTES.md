# HustleXP Mock API Routes

**STATUS: WIRING PHASE AUTHORITY**
**Owner:** Frontend Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** This document maps UI screens to mock API routes for the wiring phase.

---

## Overview

During the WIRING phase, frontend components connect to mock API routes that return data from `mock-data/`. This document defines the exact mapping between screens, API routes, and mock data sources.

### Import Pattern

```typescript
// All mock data imports from central index
import {
  MOCK_USERS,
  MOCK_TASKS,
  MOCK_ESCROWS,
  getTasksForFeed,
  getCurrentUser,
  // ... etc
} from '@/mock-data';
```

---

## Route Organization

```
src/app/api/
├── auth/
│   ├── login/route.ts
│   ├── signup/route.ts
│   └── logout/route.ts
├── users/
│   ├── [id]/route.ts
│   ├── me/route.ts
│   └── me/settings/route.ts
├── tasks/
│   ├── route.ts           # GET (feed), POST (create)
│   ├── [id]/route.ts      # GET, PATCH
│   ├── [id]/accept/route.ts
│   ├── [id]/proof/route.ts
│   ├── [id]/messages/route.ts
│   └── [id]/rating/route.ts
├── escrows/
│   ├── [id]/route.ts
│   └── [id]/release/route.ts
├── notifications/
│   └── route.ts
└── mock/
    └── delay.ts           # Artificial delay utility
```

---

## Auth Routes

### POST /api/auth/login

**Screen:** `screens/auth/LoginScreen.tsx`

**Mock Data:** `mock-data/users.js`

```typescript
// src/app/api/auth/login/route.ts
import { NextResponse } from 'next/server';
import { MOCK_USERS, mockDelay, mockResponse } from '@/mock-data';

export async function POST(req: Request) {
  await mockDelay(500);

  const { email, password } = await req.json();

  // Find user by email
  const user = Object.values(MOCK_USERS).find(u => u.email === email);

  if (!user) {
    return NextResponse.json(
      mockResponse(null, false, 'Invalid credentials'),
      { status: 401 }
    );
  }

  // Mock: any password works
  return NextResponse.json(mockResponse({
    user,
    token: `mock-jwt-${user.id}`,
  }));
}
```

### POST /api/auth/signup

**Screen:** `screens/auth/SignupScreen.tsx`

```typescript
export async function POST(req: Request) {
  await mockDelay(800);

  const { email, phone, full_name, default_mode } = await req.json();

  // Create mock user
  const newUser = {
    id: `user-new-${Date.now()}`,
    email,
    phone,
    full_name,
    default_mode,
    trust_tier: 1,
    xp_total: 0,
    current_level: 1,
    created_at: new Date().toISOString(),
  };

  return NextResponse.json(mockResponse({
    user: newUser,
    token: `mock-jwt-${newUser.id}`,
  }), { status: 201 });
}
```

---

## User Routes

### GET /api/users/me

**Screen:** `screens/profile/ProfileScreen.tsx`, `components/navigation/Header.tsx`

**Mock Data:** `mock-data/users.js`

```typescript
// src/app/api/users/me/route.ts
import { getCurrentUser, mockDelay, mockResponse } from '@/mock-data';

export async function GET(req: Request) {
  await mockDelay(200);

  // Mock: return active hustler by default
  const user = getCurrentUser('user-hustler-active');

  return NextResponse.json(mockResponse(user));
}
```

### GET /api/users/[id]

**Screen:** `screens/profile/PublicProfileScreen.tsx`

```typescript
export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(300);

  const user = getCurrentUser(params.id);

  if (!user) {
    return NextResponse.json(
      mockResponse(null, false, 'User not found'),
      { status: 404 }
    );
  }

  // Return public profile (limited fields)
  return NextResponse.json(mockResponse({
    id: user.id,
    full_name: user.full_name,
    avatar_url: user.avatar_url,
    trust_tier: user.trust_tier,
    current_level: user.current_level,
  }));
}
```

### GET /api/users/me/xp

**Screen:** `screens/profile/XPHistoryScreen.tsx`

**Mock Data:** `mock-data/xp-ledger.js`

```typescript
import { getXPLedgerForUser, getTotalXPForUser, mockDelay, mockResponse } from '@/mock-data';

export async function GET(req: Request) {
  await mockDelay(300);

  const userId = 'user-hustler-active'; // Mock current user
  const entries = getXPLedgerForUser(userId);
  const total = getTotalXPForUser(userId);

  return NextResponse.json(mockResponse({
    entries,
    total,
  }));
}
```

### GET /api/users/me/badges

**Screen:** `screens/profile/BadgesScreen.tsx`

**Mock Data:** `mock-data/badges.js`

```typescript
import { getBadgesForUser, getAllBadgeDefinitions, mockDelay, mockResponse } from '@/mock-data';

export async function GET(req: Request) {
  await mockDelay(300);

  const userId = 'user-hustler-active';
  const userBadges = getBadgesForUser(userId);
  const allBadges = getAllBadgeDefinitions();

  return NextResponse.json(mockResponse({
    earned: userBadges,
    available: allBadges,
  }));
}
```

---

## Task Routes

### GET /api/tasks (Feed)

**Screen:** `screens/feed/TaskFeedScreen.tsx`

**Mock Data:** `mock-data/tasks.js`

```typescript
// src/app/api/tasks/route.ts
import { getTasksForFeed, mockDelay, mockResponse } from '@/mock-data';

export async function GET(req: Request) {
  await mockDelay(400);

  const { searchParams } = new URL(req.url);
  const category = searchParams.get('category');
  const mode = searchParams.get('mode');
  const minPrice = searchParams.get('minPrice');
  const maxPrice = searchParams.get('maxPrice');

  const tasks = getTasksForFeed({
    category: category || undefined,
    mode: mode || undefined,
    minPrice: minPrice ? parseInt(minPrice) : undefined,
    maxPrice: maxPrice ? parseInt(maxPrice) : undefined,
  });

  return NextResponse.json(mockResponse({
    tasks,
    total: tasks.length,
    hasMore: false,
  }));
}
```

### POST /api/tasks (Create)

**Screen:** `screens/task/CreateTaskScreen.tsx`

```typescript
export async function POST(req: Request) {
  await mockDelay(600);

  const body = await req.json();

  // Validate minimum price
  if (body.price < 500) {
    return NextResponse.json(
      mockResponse(null, false, 'Minimum price is $5.00'),
      { status: 400 }
    );
  }

  // Validate Live mode price
  if (body.mode === 'LIVE' && body.price < 1500) {
    return NextResponse.json(
      { success: false, error: { code: 'HX902', message: 'Live tasks require $15 minimum' }},
      { status: 400 }
    );
  }

  const newTask = {
    id: `task-new-${Date.now()}`,
    ...body,
    state: 'OPEN',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  return NextResponse.json(mockResponse(newTask), { status: 201 });
}
```

### GET /api/tasks/[id]

**Screen:** `screens/task/TaskDetailScreen.tsx`

**Mock Data:** `mock-data/tasks.js`, `mock-data/escrows.js`

```typescript
import { getTask, getEscrowForTask, mockDelay, mockResponse } from '@/mock-data';

export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(300);

  const task = getTask(params.id);

  if (!task) {
    return NextResponse.json(
      mockResponse(null, false, 'Task not found'),
      { status: 404 }
    );
  }

  const escrow = getEscrowForTask(params.id);

  return NextResponse.json(mockResponse({
    ...task,
    escrow,
  }));
}
```

### POST /api/tasks/[id]/accept

**Screen:** `screens/task/TaskDetailScreen.tsx` (Accept button)

```typescript
import { getTask, mockDelay, mockResponse } from '@/mock-data';

export async function POST(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(500);

  const task = getTask(params.id);

  if (!task) {
    return NextResponse.json(
      mockResponse(null, false, 'Task not found'),
      { status: 404 }
    );
  }

  if (task.state !== 'OPEN') {
    return NextResponse.json(
      mockResponse(null, false, 'Task is not available'),
      { status: 409 }
    );
  }

  // Mock state transition
  const updatedTask = {
    ...task,
    state: 'ACCEPTED',
    worker_id: 'user-hustler-active',
    accepted_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  return NextResponse.json(mockResponse(updatedTask));
}
```

### GET /api/tasks/[id]/messages

**Screen:** `screens/task/TaskMessagesScreen.tsx`

**Mock Data:** `mock-data/messages.js`

```typescript
import { getMessagesForTask, mockDelay, mockResponse } from '@/mock-data';

export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(200);

  const messages = getMessagesForTask(params.id);

  return NextResponse.json(mockResponse({
    messages,
    total: messages.length,
  }));
}
```

### POST /api/tasks/[id]/messages

**Screen:** `screens/task/TaskMessagesScreen.tsx` (Send message)

```typescript
import { getTask, addMockMessage, mockDelay, mockResponse } from '@/mock-data';

export async function POST(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(300);

  const { content } = await req.json();

  // Validate content length (MSG-4)
  if (content && content.length > 500) {
    return NextResponse.json(
      { success: false, error: { code: 'HX804', message: 'Message exceeds 500 characters' }},
      { status: 400 }
    );
  }

  const task = getTask(params.id);

  // Validate task state (MSG-1)
  if (!['ACCEPTED', 'PROOF_SUBMITTED', 'DISPUTED'].includes(task?.state || '')) {
    return NextResponse.json(
      { success: false, error: { code: 'HX801', message: 'Messages not allowed in this state' }},
      { status: 409 }
    );
  }

  const newMessage = addMockMessage(params.id, {
    sender_id: 'user-hustler-active',
    content,
  });

  return NextResponse.json(mockResponse(newMessage), { status: 201 });
}
```

### POST /api/tasks/[id]/proof

**Screen:** `screens/task/SubmitProofScreen.tsx`

**Mock Data:** `mock-data/proofs.js`

```typescript
import { getTask, mockDelay, mockResponse } from '@/mock-data';

export async function POST(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(800);

  const formData = await req.formData();
  const photos = formData.getAll('photos');
  const notes = formData.get('notes');

  // Validate photo count
  if (photos.length < 1 || photos.length > 5) {
    return NextResponse.json(
      mockResponse(null, false, 'Must include 1-5 photos'),
      { status: 400 }
    );
  }

  const newProof = {
    id: `proof-new-${Date.now()}`,
    task_id: params.id,
    state: 'SUBMITTED',
    notes,
    photo_count: photos.length,
    submitted_at: new Date().toISOString(),
  };

  return NextResponse.json(mockResponse(newProof), { status: 201 });
}
```

### POST /api/tasks/[id]/rating

**Screen:** `screens/task/RateTaskScreen.tsx`

**Mock Data:** `mock-data/ratings.js` (to be created)

```typescript
import { getTask, mockDelay, mockResponse } from '@/mock-data';

export async function POST(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(400);

  const { stars, comment, tags } = await req.json();

  const task = getTask(params.id);

  // Validate task is COMPLETED (RATE-1)
  if (task?.state !== 'COMPLETED') {
    return NextResponse.json(
      { success: false, error: { code: 'HX807', message: 'Task must be completed to rate' }},
      { status: 409 }
    );
  }

  // Validate stars range (RATE-6)
  if (stars < 1 || stars > 5) {
    return NextResponse.json(
      { success: false, error: { code: 'HX810', message: 'Stars must be 1-5' }},
      { status: 400 }
    );
  }

  const newRating = {
    id: `rating-new-${Date.now()}`,
    task_id: params.id,
    rater_id: 'user-hustler-active',
    ratee_id: task.poster_id,
    stars,
    comment,
    tags,
    created_at: new Date().toISOString(),
  };

  return NextResponse.json(mockResponse(newRating), { status: 201 });
}
```

---

## Notification Routes

### GET /api/notifications

**Screen:** `screens/notifications/NotificationsScreen.tsx`

**Mock Data:** `mock-data/notifications.js`

```typescript
import { getNotificationsForUser, getUnreadCount, mockDelay, mockResponse } from '@/mock-data';

export async function GET(req: Request) {
  await mockDelay(300);

  const userId = 'user-hustler-active';
  const notifications = getNotificationsForUser(userId);
  const unreadCount = getUnreadCount(userId);

  return NextResponse.json(mockResponse({
    notifications,
    unread_count: unreadCount,
  }));
}
```

### PATCH /api/notifications/[id]/read

**Screen:** `screens/notifications/NotificationsScreen.tsx`

```typescript
import { markNotificationRead, mockDelay, mockResponse } from '@/mock-data';

export async function PATCH(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(200);

  markNotificationRead(params.id);

  return NextResponse.json(mockResponse({ success: true }));
}
```

---

## Escrow Routes

### GET /api/escrows/[id]

**Screen:** `screens/task/TaskDetailScreen.tsx` (Escrow status)

**Mock Data:** `mock-data/escrows.js`

```typescript
import { getEscrow, mockDelay, mockResponse } from '@/mock-data';

export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  await mockDelay(200);

  const escrow = getEscrow(params.id);

  if (!escrow) {
    return NextResponse.json(
      mockResponse(null, false, 'Escrow not found'),
      { status: 404 }
    );
  }

  return NextResponse.json(mockResponse(escrow));
}
```

---

## Screen → Route Mapping Summary

| Screen | Route | Method | Mock Data Source |
|--------|-------|--------|------------------|
| LoginScreen | `/api/auth/login` | POST | `users.js` |
| SignupScreen | `/api/auth/signup` | POST | - |
| TaskFeedScreen | `/api/tasks` | GET | `tasks.js` |
| TaskDetailScreen | `/api/tasks/[id]` | GET | `tasks.js`, `escrows.js` |
| CreateTaskScreen | `/api/tasks` | POST | - |
| SubmitProofScreen | `/api/tasks/[id]/proof` | POST | `proofs.js` |
| TaskMessagesScreen | `/api/tasks/[id]/messages` | GET/POST | `messages.js` |
| RateTaskScreen | `/api/tasks/[id]/rating` | POST | `ratings.js` |
| ProfileScreen | `/api/users/me` | GET | `users.js` |
| XPHistoryScreen | `/api/users/me/xp` | GET | `xp-ledger.js` |
| BadgesScreen | `/api/users/me/badges` | GET | `badges.js` |
| NotificationsScreen | `/api/notifications` | GET | `notifications.js` |

---

## Mock Delay Configuration

```typescript
// src/mock-data/delay.ts
const DELAY_CONFIG = {
  fast: 200,     // Simple reads
  normal: 400,   // Standard operations
  slow: 800,     // Complex operations
  upload: 1500,  // File uploads
};

export const mockDelay = (ms: number = DELAY_CONFIG.normal) => {
  if (process.env.NODE_ENV === 'development') {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  return Promise.resolve();
};
```

---

## Error Response Examples

### 400 Bad Request (Validation)

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Minimum price is $5.00",
    "details": {
      "field": "price",
      "received": 300,
      "minimum": 500
    }
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

### 409 Conflict (State Violation)

```json
{
  "success": false,
  "error": {
    "code": "HX301",
    "message": "Task cannot be completed: no accepted proof exists",
    "details": {
      "task_id": "task-123",
      "current_state": "ACCEPTED",
      "required": "proof_accepted"
    }
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

---

**END OF MOCK_API_ROUTES v1.0.0**
