# Screen H1: Task Feed Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

The main task discovery screen for hustlers. Shows available tasks filtered by capabilities, location, and trust tier. Includes Live Mode toggle.

---

## Layout

```
┌─────────────────────────────────────────┐
│ Tasks Near You              [LIVE ○]    │  ← Header with Live Mode toggle
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🔍 Search tasks...                  ││  ← Search input
│  └─────────────────────────────────────┘│
│                                         │
│  [All] [Delivery] [Moving] [Handyman]   │  ← Category filters (horizontal scroll)
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Sort: Distance ▼                    ││  ← Sort dropdown
│  └─────────────────────────────────────┘│
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  Move furniture to storage          ││  ← Task title
│  │                                     ││
│  │  📍 0.8 mi  •  🕐 2-3 hrs           ││  ← Distance, duration
│  │                                     ││
│  │  $75.00                      →      ││  ← Price, chevron
│  │                                     ││
│  │  Posted 5m ago by Sarah M.          ││  ← Metadata
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  Grocery delivery                   ││
│  │                                     ││
│  │  📍 1.2 mi  •  🕐 30 min            ││
│  │                                     ││
│  │  $25.00                      →      ││
│  │                                     ││
│  │  Posted 12m ago by Mike T.          ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ⚡ INSTANT                         ││  ← Instant task badge
│  │  Help with yard work                ││
│  │                                     ││
│  │  📍 2.1 mi  •  🕐 1-2 hrs           ││
│  │                                     ││
│  │  $50.00                      →      ││
│  │                                     ││
│  │  Posted just now                    ││
│  └─────────────────────────────────────┘│
│                                         │
│  [Load more...]                         │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface TaskFeedScreenProps {
  // Tasks data
  tasks?: Task[];

  // Filter state
  searchQuery?: string;
  selectedCategory?: string | null;
  sortBy?: 'distance' | 'price' | 'posted' | 'urgency';

  // Categories
  categories?: Category[];

  // Live Mode
  liveModeState?: 'OFF' | 'ACTIVE' | 'COOLDOWN' | 'PAUSED';
  cooldownEndsAt?: string;

  // Pagination
  hasMore?: boolean;
  isLoadingMore?: boolean;

  // State
  isLoading?: boolean;
  isRefreshing?: boolean;
  error?: Error | null;

  // Callbacks
  onSearchChange?: (query: string) => void;
  onCategorySelect?: (categoryId: string | null) => void;
  onSortChange?: (sortBy: string) => void;
  onTaskPress?: (taskId: string) => void;
  onLiveModeToggle?: () => void;
  onLoadMore?: () => void;
  onRefresh?: () => void;
}

interface Task {
  id: string;
  title: string;
  description: string;
  price: number;          // cents
  distanceMiles: number;
  estimatedDuration: string;
  category: string;
  isInstant: boolean;
  postedAt: string;       // ISO 8601
  poster: {
    displayName: string;
    avatarUrl?: string;
  };
}

interface Category {
  id: string;
  name: string;
  icon: string;
  taskCount?: number;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | `colors.neutral[0]`, sticky |
| Title | `typography.h2`, `colors.neutral[900]` |
| Live toggle | See LIVE_MODE_UI_SPEC |
| Search input | `inputStyles.default`, 🔍 icon |
| Category chips | `radius.full`, horizontal scroll |
| Selected chip | `colors.primary[500]` bg, white text |
| Unselected chip | `colors.neutral[100]` bg |
| Sort dropdown | `typography.bodySmall`, ▼ icon |
| Task cards | `cardStyles.task` |
| Task title | `typography.body`, `fontWeight: 600` |
| Distance/Duration | `typography.bodySmall`, `colors.neutral[600]` |
| Price | `typography.price`, `colors.success` |
| Instant badge | `colors.warning` bg, "⚡ INSTANT" |
| Posted time | `typography.caption`, `colors.neutral[500]` |

---

## Sort Options

| Value | Label |
|-------|-------|
| distance | Distance |
| price | Price: High to Low |
| posted | Recently Posted |
| urgency | Urgency |

---

## Task Card States

### Standard Task
- White background
- Primary color left border

### Instant Task
- Warning badge at top
- Slightly elevated shadow

### Ineligible Task (shown dimmed)
```
opacity: 0.5
Badge: "Trust Tier 2 Required"
```

---

## Empty State

```
┌─────────────────────────────────────────┐
│                                         │
│            📭                           │
│                                         │
│     No tasks available                  │
│                                         │
│   Check back later or expand            │
│   your service area.                    │
│                                         │
│   [Adjust Filters]                      │
│                                         │
└─────────────────────────────────────────┘
```

---

## Loading State

- Show 3 skeleton task cards
- Shimmer animation

---

## Pull to Refresh

- Standard pull-to-refresh gesture
- Calls `onRefresh`

---

**This screen is Cursor-ready. Build exactly as specified.**
