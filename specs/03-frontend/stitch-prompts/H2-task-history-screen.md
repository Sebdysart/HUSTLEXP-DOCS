# Screen H2: Task History Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Shows hustler's completed, cancelled, and in-progress tasks. Provides access to task details and earnings history.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←  Task History                         │
├─────────────────────────────────────────┤
│                                         │
│  [All]  [Active]  [Completed] [Cancelled]│  ← Filter tabs
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  This Week                              │  ← Section header
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✅ Move furniture to storage        ││  ← Completed
│  │                                     ││
│  │ Jan 18, 2025  •  $75.00            ││
│  │ ⭐ 5.0 rating from Sarah M.         ││
│  │                                →    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🔄 Grocery delivery                 ││  ← In Progress
│  │                                     ││
│  │ Started 2h ago  •  $25.00          ││
│  │ En route to location                ││
│  │                                →    ││
│  └─────────────────────────────────────┘│
│                                         │
│  Last Week                              │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✅ Yard work help                   ││
│  │                                     ││
│  │ Jan 12, 2025  •  $50.00            ││
│  │ ⭐ 4.5 rating from Mike T.          ││
│  │                                →    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ❌ Assembly job                     ││  ← Cancelled
│  │                                     ││
│  │ Jan 10, 2025  •  Cancelled         ││
│  │ Poster cancelled task               ││
│  │                                →    ││
│  └─────────────────────────────────────┘│
│                                         │
│  Earlier                                │
│  ─────────────────────────────────────  │
│                                         │
│  [Load more...]                         │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface TaskHistoryScreenProps {
  // Tasks grouped by time period
  taskGroups?: TaskGroup[];

  // Filter
  filter?: 'ALL' | 'ACTIVE' | 'COMPLETED' | 'CANCELLED';

  // Summary stats
  stats?: {
    totalCompleted: number;
    totalEarnings: number;  // cents
    averageRating: number;
  };

  // Pagination
  hasMore?: boolean;
  isLoadingMore?: boolean;

  // State
  isLoading?: boolean;
  error?: Error | null;

  // Callbacks
  onFilterChange?: (filter: string) => void;
  onTaskPress?: (taskId: string) => void;
  onLoadMore?: () => void;
  onBack?: () => void;
}

interface TaskGroup {
  title: string;  // "This Week", "Last Week", "Earlier"
  tasks: HistoryTask[];
}

interface HistoryTask {
  id: string;
  title: string;
  status: 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'DISPUTED';
  price: number;
  completedAt?: string;
  cancelledAt?: string;
  startedAt?: string;
  rating?: number;
  raterName?: string;
  cancelReason?: string;
  statusDetail?: string;  // "En route to location"
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Back button + title |
| Title | `typography.h2`, `colors.neutral[900]` |
| Filter tabs | Horizontal scroll, `radius.full` |
| Active tab | `colors.primary[500]` bg |
| Section header | `typography.bodySmall`, `colors.neutral[500]`, sticky |
| Task cards | `cardStyles.default` |
| Status icon | 24px, status-colored |
| Task title | `typography.body`, `fontWeight: 500` |
| Date/Price | `typography.bodySmall`, `colors.neutral[600]` |
| Rating | `typography.bodySmall`, `colors.accent[500]` star |
| Status detail | `typography.caption`, `colors.neutral[500]` |
| Chevron | `iconSize.md`, `colors.neutral[400]` |

---

## Status Icons

| Status | Icon | Color |
|--------|------|-------|
| IN_PROGRESS | 🔄 | `colors.primary[500]` |
| COMPLETED | ✅ | `colors.success` |
| CANCELLED | ❌ | `colors.neutral[400]` |
| DISPUTED | ⚠️ | `colors.warning` |

---

## Filter Tabs

| Tab | Shows |
|-----|-------|
| All | All tasks |
| Active | IN_PROGRESS tasks |
| Completed | COMPLETED tasks |
| Cancelled | CANCELLED tasks |

---

## Empty States

### No Tasks (All filter)
```
No tasks yet

Complete your first task to see
your history here.

[Find Tasks]
```

### No Active Tasks
```
No active tasks

You don't have any tasks in progress.

[Find Tasks]
```

### No Completed Tasks
```
No completed tasks yet

Your completed tasks will appear here.
```

---

## Section Grouping

Tasks grouped by:
- **This Week**: Last 7 days
- **Last Week**: 8-14 days ago
- **Earlier**: 15+ days ago
- Or by month for older tasks

---

**This screen is Cursor-ready. Build exactly as specified.**
