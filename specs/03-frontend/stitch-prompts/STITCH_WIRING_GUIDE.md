# Stitch Prompt Wiring Guide

**PURPOSE:** This guide provides consistent mock API wiring instructions for implementing stitch prompt screens.

**PHASE:** Wiring Phase (connecting UI to mock data)

---

## How to Use This Guide

1. Generate screen from stitch prompt using Google Stitch
2. Export to React Native / Expo
3. Use this guide to wire mock data to each screen component

---

## Screen-to-Mock-Data Mapping

### 01: Instant Interrupt Card

**Mock Data Import:**
```typescript
import {
  tasks,
  users,
  getTaskById,
  getUserById
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Task title | `tasks.live[0].title` | `task-live-now` |
| Task price | `tasks.live[0].price_total` | - |
| Poster name | `users.posters[0].display_name` | - |
| Distance | `tasks.live[0].location.distance_miles` | - |
| Escrow state | `tasks.live[0].escrow_state` | - |
| Time remaining | Calculate from `tasks.live[0].posted_at` | - |

**API Route (Mock):**
```typescript
// GET /api/tasks/live/nearby
const response = await fetch('/api/tasks/live/nearby');
// Returns: tasks.live filtered by location
```

---

### 02: Hustler Home Dashboard

**Mock Data Import:**
```typescript
import {
  users,
  xp,
  tasks,
  getUserById,
  calculateTodayEarnings
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| XP Total | `xp.transactions[0].running_total` | - |
| Trust Tier | `users.hustlers[0].trust_tier` | - |
| Trust Tier Name | Map `trust_tier` → "ROOKIE/VERIFIED/TRUSTED/ELITE" | - |
| Streak | `users.hustlers[0].streak_current` | - |
| Today's Earnings | `calculateTodayEarnings(userId)` | Helper function |
| Tasks Completed | `users.hustlers[0].stats.tasks_completed` | - |
| Instant Mode | `users.hustlers[0].instant_mode_active` | - |

**API Routes (Mock):**
```typescript
// GET /api/users/:id/dashboard
const dashboard = await fetch(`/api/users/${userId}/dashboard`);
// Returns: { xp, tier, streak, earnings, stats }

// GET /api/users/:id/xp
const xpData = await fetch(`/api/users/${userId}/xp`);
// Returns: xp.transactions filtered by user
```

---

### 03: Pinned Instant Card

**Mock Data Import:**
```typescript
import { tasks, users } from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Task | `tasks.live[0]` | Dismissed but pinned |
| Poster | `users.posters[0]` | - |
| Time since dismiss | Track locally | - |

---

### 04: Poster Task Creation

**Mock Data Import:**
```typescript
import {
  tasks,
  categories,
  aiOutputs
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Categories | `tasks.categories` | - |
| AI Suggestions | `aiOutputs.taskCompletionAssessments` | For price suggestions |
| Price range | Calculate from similar tasks | - |

**API Routes (Mock):**
```typescript
// POST /api/tasks/create
const newTask = await fetch('/api/tasks/create', { method: 'POST', body });
// Returns: New task object with id

// POST /api/ai/suggest-price
const suggestion = await fetch('/api/ai/suggest-price', { method: 'POST', body });
// Returns: { suggested_price, reasoning }
```

---

### 05: Poster Hustler on the Way

**Mock Data Import:**
```typescript
import {
  tasks,
  users,
  escrows
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Hustler name | `users.hustlers[0].display_name` | - |
| Hustler trust tier | `users.hustlers[0].trust_tier` | - |
| Tasks completed | `users.hustlers[0].stats.tasks_completed` | - |
| ETA | `tasks.inProgress[0].eta_minutes` | - |
| Distance | `tasks.inProgress[0].location.distance_miles` | - |
| Map data | `tasks.inProgress[0].location` | lat/lng |
| Escrow state | `escrows.openLive.state` | - |

**API Routes (Mock):**
```typescript
// GET /api/tasks/:id/tracking
const tracking = await fetch(`/api/tasks/${taskId}/tracking`);
// Returns: { hustler, eta, distance, location }

// Real-time updates via WebSocket mock
socket.on('hustler_location', (data) => updateMap(data));
```

---

### 06: Trust Tier Ladder

**Mock Data Import:**
```typescript
import {
  users,
  badges,
  xp
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Current tier | `users.hustlers[0].trust_tier` | - |
| XP to next tier | Calculate from tier thresholds | - |
| Tier benefits | Static content | - |
| Unlock progress | `xp.transactions[0].running_total` / threshold | - |

---

### 07: XP Breakdown

**Mock Data Import:**
```typescript
import {
  xp,
  badges
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Total XP | `xp.transactions[0].running_total` | Most recent |
| XP History | `xp.transactions` | Sorted by date |
| By source | Group transactions by `event_type` | - |
| By category | Group transactions by task category | - |
| Badges | `badges.unlocked` | - |

**API Routes (Mock):**
```typescript
// GET /api/users/:id/xp/breakdown
const breakdown = await fetch(`/api/users/${userId}/xp/breakdown`);
// Returns: { total, history, bySource, byCategory }
```

---

### 08: Hustler Task In Progress

**Mock Data Import:**
```typescript
import {
  tasks,
  users,
  escrows
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Task details | `tasks.inProgress[0]` | - |
| Poster info | `users.posters[0]` | - |
| Time elapsed | Calculate from `accepted_at` | - |
| Escrow state | `escrows.openLive.state` | - |
| Chat messages | Mock messages array | - |

**API Routes (Mock):**
```typescript
// GET /api/tasks/:id/in-progress
const task = await fetch(`/api/tasks/${taskId}/in-progress`);

// POST /api/tasks/:id/proof
const proof = await fetch(`/api/tasks/${taskId}/proof`, {
  method: 'POST',
  body: formData
});
```

---

### 09: Hustler Task Completion

**Mock Data Import:**
```typescript
import {
  xp,
  badges,
  escrows
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| XP earned | `xp.transactions[0].amount` | - |
| New total | `xp.transactions[0].running_total` | - |
| Badge unlocked | `badges.unlocked[0]` | If applicable |
| Payment amount | `escrows.released.amount_hustler` | - |
| Payment state | `escrows.released.state` | - |

---

### 10: Poster Task Completion

**Mock Data Import:**
```typescript
import {
  tasks,
  users,
  ratings
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Task summary | `tasks.completed[0]` | - |
| Hustler info | `users.hustlers[0]` | - |
| Proof images | `tasks.completed[0].proof_urls` | - |
| Rating form | `ratings.hustlerRatings[0]` | Template |

---

### 11: Poster Feedback

**Mock Data Import:**
```typescript
import { ratings } from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Rating options | GREAT / OKAY / DIFFICULT | Static |
| Feedback tags | `ratings.ratingTags` | - |

**API Routes (Mock):**
```typescript
// POST /api/ratings/hustler
const rating = await fetch('/api/ratings/hustler', {
  method: 'POST',
  body: { task_id, rating, tags, comment }
});
```

---

### 12: Trust Change Explanation

**Mock Data Import:**
```typescript
import {
  users,
  verifications
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Old tier | `users.hustlers[0].trust_tier` - 1 | - |
| New tier | `users.hustlers[0].trust_tier` | - |
| Reason | `verifications.verificationEvents[0].reason` | - |
| Requirements | Tier requirements | Static |

---

### 13: Dispute Entry

**Mock Data Import:**
```typescript
import {
  tasks,
  escrows,
  disputes
} from '@/mock-data';
```

**Data Mapping:**
| UI Element | Mock Data Source | Path |
|------------|------------------|------|
| Task | `tasks.completed[0]` | Disputed task |
| Escrow | `escrows.disputed` | - |
| Evidence upload | Form state | - |

**API Routes (Mock):**
```typescript
// POST /api/disputes/create
const dispute = await fetch('/api/disputes/create', {
  method: 'POST',
  body: { task_id, reason, evidence }
});
```

---

## State Management Pattern

Use React Context or Zustand for mock data state:

```typescript
// stores/mockStore.ts
import { create } from 'zustand';
import * as mockData from '@/mock-data';

interface MockStore {
  currentUser: typeof mockData.users.hustlers[0] | null;
  currentTask: typeof mockData.tasks.live[0] | null;
  setCurrentUser: (userId: string) => void;
  setCurrentTask: (taskId: string) => void;
}

export const useMockStore = create<MockStore>((set) => ({
  currentUser: mockData.users.hustlers[0],
  currentTask: mockData.tasks.live[0],
  setCurrentUser: (userId) => {
    const user = mockData.users.hustlers.find(u => u.id === userId)
      || mockData.users.posters.find(u => u.id === userId);
    set({ currentUser: user });
  },
  setCurrentTask: (taskId) => {
    const task = mockData.tasks.live.find(t => t.id === taskId)
      || mockData.tasks.inProgress.find(t => t.id === taskId);
    set({ currentTask: task });
  },
}));
```

---

## Mock API Route Setup

Create mock API handlers using MSW (Mock Service Worker):

```typescript
// mocks/handlers.ts
import { rest } from 'msw';
import * as mockData from '@/mock-data';

export const handlers = [
  // Tasks
  rest.get('/api/tasks/live/nearby', (req, res, ctx) => {
    return res(ctx.json(mockData.tasks.live));
  }),

  rest.get('/api/tasks/:id', (req, res, ctx) => {
    const task = mockData.getTaskById(req.params.id);
    return res(ctx.json(task));
  }),

  // Users
  rest.get('/api/users/:id/dashboard', (req, res, ctx) => {
    const user = mockData.getUserById(req.params.id);
    return res(ctx.json({
      xp: mockData.xp.transactions[0].running_total,
      tier: user.trust_tier,
      streak: user.streak_current,
      earnings: mockData.calculateTodayEarnings(req.params.id),
      stats: user.stats,
    }));
  }),

  // XP
  rest.get('/api/users/:id/xp', (req, res, ctx) => {
    return res(ctx.json(mockData.xp.transactions));
  }),

  // Ratings
  rest.post('/api/ratings/hustler', (req, res, ctx) => {
    return res(ctx.json({ success: true, id: 'rating-new' }));
  }),
];
```

---

## Cross-Reference

| Guide Section | Spec Reference |
|---------------|----------------|
| Mock Data Paths | `mock-data/index.js` |
| API Contract | `API_CONTRACT.md` |
| Mock API Routes | `MOCK_API_ROUTES.md` |
| Screen Specs | Individual stitch prompts |
| State Management | React Native / Expo patterns |

---

**END OF STITCH_WIRING_GUIDE.md**
