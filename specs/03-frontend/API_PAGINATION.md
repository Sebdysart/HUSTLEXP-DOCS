# HustleXP API Pagination Spec

**AUTHORITY:** API_CONTRACT.md
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document defines exact pagination patterns for all list endpoints. Cursor MUST use these patterns.

---

## Table of Contents

1. [Pagination Types](#1-pagination-types)
2. [Endpoint Reference](#2-endpoint-reference)
3. [Implementation Patterns](#3-implementation-patterns)
4. [Query Parameters](#4-query-parameters)

---

## 1. Pagination Types

### 1.1 Offset-Based Pagination

Used for: Static lists where total count matters.

```typescript
interface OffsetPaginationInput {
  limit?: number;   // Default: 20, Max: 100
  offset?: number;  // Default: 0
}

interface OffsetPaginationOutput<T> {
  items: T[];
  total: number;
  has_more: boolean;
}
```

**Pros:**
- Can jump to any page
- Shows total count

**Cons:**
- Performance degrades at high offsets
- Items may shift between requests

### 1.2 Cursor-Based Pagination

Used for: Real-time feeds, infinite scroll.

```typescript
interface CursorPaginationInput {
  limit?: number;      // Default: 20, Max: 50
  cursor?: string;     // Opaque cursor from previous response
}

interface CursorPaginationOutput<T> {
  items: T[];
  next_cursor: string | null;
  has_more: boolean;
  total_estimate?: number;  // Approximate count (optional)
}
```

**Pros:**
- Consistent performance
- Stable ordering even with new items

**Cons:**
- Cannot jump to arbitrary page
- Total count may be approximate

---

## 2. Endpoint Reference

### 2.1 task.list (Offset)

**Use case:** Poster's task list, history views

```typescript
// Input
{
  filter?: {
    state?: TaskState | TaskState[];
    category?: string;
    mode?: 'STANDARD' | 'LIVE';
    poster_id?: string;
    worker_id?: string;
    min_price?: number;  // cents
    max_price?: number;  // cents
  };
  sort?: {
    field: 'created_at' | 'price' | 'deadline';
    direction: 'asc' | 'desc';
  };
  pagination?: {
    limit?: number;   // Default: 20, Max: 100
    offset?: number;  // Default: 0
  };
}

// Output
{
  tasks: TaskSummary[];
  total: number;
  has_more: boolean;
}
```

**Example:**
```typescript
// First page
const page1 = await api.task.list({
  filter: { poster_id: userId, state: ['OPEN', 'ACCEPTED'] },
  sort: { field: 'created_at', direction: 'desc' },
  pagination: { limit: 20, offset: 0 },
});

// Next page
const page2 = await api.task.list({
  filter: { poster_id: userId, state: ['OPEN', 'ACCEPTED'] },
  sort: { field: 'created_at', direction: 'desc' },
  pagination: { limit: 20, offset: 20 },
});
```

---

### 2.2 task.getFeed (Cursor)

**Use case:** Hustler's task discovery feed

```typescript
// Input
{
  location?: {
    lat: number;
    lng: number;
  };
  radius_miles?: number;    // Default: 25, Max: 100
  categories?: string[];
  min_price?: number;       // cents
  max_price?: number;       // cents
  sort_by?: 'relevance' | 'distance' | 'price_desc' | 'price_asc' | 'deadline';
  pagination?: {
    limit?: number;         // Default: 20, Max: 50
    cursor?: string;
  };
}

// Output
{
  tasks: FeedTask[];  // Includes matching_score, eligibility
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

**Example:**
```typescript
// First page
const page1 = await api.task.getFeed({
  location: { lat: 37.7749, lng: -122.4194 },
  radius_miles: 10,
  sort_by: 'relevance',
  pagination: { limit: 20 },
});

// Next page (use cursor from previous)
const page2 = await api.task.getFeed({
  location: { lat: 37.7749, lng: -122.4194 },
  radius_miles: 10,
  sort_by: 'relevance',
  pagination: { limit: 20, cursor: page1.pagination.next_cursor },
});
```

**Note:** MUST pass same filter/sort params with cursor!

---

### 2.3 messaging.getThread (Cursor)

**Use case:** Chat message history

```typescript
// Input
{
  task_id: string;
  limit?: number;       // Default: 50
  before?: string;      // Message ID for pagination (load older)
}

// Output
{
  messages: Message[];
  has_more: boolean;
}
```

**Example:**
```typescript
// Most recent messages
const recent = await api.messaging.getThread({
  task_id: taskId,
  limit: 50,
});

// Load older messages
const older = await api.messaging.getThread({
  task_id: taskId,
  limit: 50,
  before: recent.messages[recent.messages.length - 1].id,
});
```

---

### 2.4 notification.list (Offset)

**Use case:** Notification center

```typescript
// Input
{
  unread_only?: boolean;  // Default: false
  limit?: number;         // Default: 20, Max: 100
  offset?: number;        // Default: 0
}

// Output
{
  notifications: Notification[];
  unread_count: number;
  total: number;
}
```

---

### 2.5 user.getXP (Limit only)

**Use case:** XP history

```typescript
// Input
{
  limit?: number;  // History entries, default: 10
}

// Output
{
  total_xp: number;
  current_level: number;
  current_streak: number;
  level_progress: LevelProgress;
  recent_entries: XPLedgerEntry[];  // Limited by input
}
```

---

### 2.6 rating.getForUser (Offset)

**Use case:** User reviews

```typescript
// Input
{
  user_id: string;
  role?: 'poster' | 'worker';
  limit?: number;   // Default: 10, Max: 50
}

// Output
{
  user_id: string;
  aggregate: RatingAggregate;
  recent_ratings: Rating[];  // Limited by input
}
```

---

## 3. Implementation Patterns

### 3.1 Infinite Scroll (Cursor-based)

```typescript
const InfiniteTaskFeed = () => {
  const [tasks, setTasks] = useState<FeedTask[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  // Initial load
  useEffect(() => {
    loadTasks();
  }, []);

  const loadTasks = async () => {
    setIsLoading(true);
    try {
      const result = await api.task.getFeed({
        pagination: { limit: 20 },
      });
      setTasks(result.tasks);
      setCursor(result.pagination.next_cursor);
      setHasMore(result.pagination.has_more);
    } finally {
      setIsLoading(false);
    }
  };

  const loadMore = async () => {
    if (isLoadingMore || !hasMore || !cursor) return;

    setIsLoadingMore(true);
    try {
      const result = await api.task.getFeed({
        pagination: { limit: 20, cursor },
      });
      setTasks(prev => [...prev, ...result.tasks]);
      setCursor(result.pagination.next_cursor);
      setHasMore(result.pagination.has_more);
    } finally {
      setIsLoadingMore(false);
    }
  };

  return (
    <FlatList
      data={tasks}
      renderItem={({ item }) => <TaskCard task={item} />}
      keyExtractor={(item) => item.id}
      onEndReached={loadMore}
      onEndReachedThreshold={0.5}
      ListFooterComponent={isLoadingMore ? <ActivityIndicator /> : null}
    />
  );
};
```

### 3.2 Paginated List (Offset-based)

```typescript
const PaginatedTaskList = () => {
  const [tasks, setTasks] = useState<TaskSummary[]>([]);
  const [page, setPage] = useState(0);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  const PAGE_SIZE = 20;

  useEffect(() => {
    loadPage(0);
  }, []);

  const loadPage = async (pageNum: number) => {
    setIsLoading(true);
    try {
      const result = await api.task.list({
        filter: { poster_id: userId },
        pagination: { limit: PAGE_SIZE, offset: pageNum * PAGE_SIZE },
      });
      setTasks(result.tasks);
      setTotal(result.total);
      setPage(pageNum);
    } finally {
      setIsLoading(false);
    }
  };

  const totalPages = Math.ceil(total / PAGE_SIZE);
  const hasNextPage = page < totalPages - 1;
  const hasPrevPage = page > 0;

  return (
    <>
      <FlatList
        data={tasks}
        renderItem={({ item }) => <TaskCard task={item} />}
        keyExtractor={(item) => item.id}
      />
      <View style={styles.pagination}>
        <Button
          title="Previous"
          onPress={() => loadPage(page - 1)}
          disabled={!hasPrevPage || isLoading}
        />
        <HXText>
          Page {page + 1} of {totalPages}
        </HXText>
        <Button
          title="Next"
          onPress={() => loadPage(page + 1)}
          disabled={!hasNextPage || isLoading}
        />
      </View>
    </>
  );
};
```

### 3.3 Chat History (Reverse Cursor)

```typescript
const ChatThread = ({ taskId }: { taskId: string }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [hasMore, setHasMore] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  useEffect(() => {
    loadMessages();
  }, [taskId]);

  const loadMessages = async () => {
    const result = await api.messaging.getThread({
      task_id: taskId,
      limit: 50,
    });
    setMessages(result.messages);
    setHasMore(result.has_more);
  };

  const loadOlderMessages = async () => {
    if (isLoadingMore || !hasMore || messages.length === 0) return;

    setIsLoadingMore(true);
    try {
      const oldestMessage = messages[messages.length - 1];
      const result = await api.messaging.getThread({
        task_id: taskId,
        limit: 50,
        before: oldestMessage.id,
      });
      setMessages(prev => [...prev, ...result.messages]);
      setHasMore(result.has_more);
    } finally {
      setIsLoadingMore(false);
    }
  };

  return (
    <FlatList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      keyExtractor={(item) => item.id}
      inverted // Most recent at bottom
      onEndReached={loadOlderMessages}
      onEndReachedThreshold={0.5}
      ListFooterComponent={isLoadingMore ? <ActivityIndicator /> : null}
    />
  );
};
```

### 3.4 Pull-to-Refresh

```typescript
const RefreshableList = () => {
  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    try {
      // Reset to first page
      const result = await api.task.getFeed({
        pagination: { limit: 20 },
      });
      setTasks(result.tasks);
      setCursor(result.pagination.next_cursor);
      setHasMore(result.pagination.has_more);
    } finally {
      setIsRefreshing(false);
    }
  };

  return (
    <FlatList
      // ...
      refreshing={isRefreshing}
      onRefresh={handleRefresh}
    />
  );
};
```

---

## 4. Query Parameters

### 4.1 Filter Parameters by Endpoint

| Endpoint | Filter Params |
|----------|---------------|
| task.list | state, category, mode, poster_id, worker_id, min_price, max_price |
| task.getFeed | categories, min_price, max_price, radius_miles, location |
| notification.list | unread_only |
| rating.getForUser | role |

### 4.2 Sort Parameters

| Endpoint | Sort Fields |
|----------|-------------|
| task.list | created_at, price, deadline |
| task.getFeed | relevance, distance, price_desc, price_asc, deadline |

### 4.3 Default Values

| Parameter | Default | Max |
|-----------|---------|-----|
| limit (task.list) | 20 | 100 |
| limit (task.getFeed) | 20 | 50 |
| limit (messaging) | 50 | 100 |
| limit (notifications) | 20 | 100 |
| offset | 0 | - |
| radius_miles | 25 | 100 |

---

## Summary Table

| Endpoint | Type | Key Param | Max Items |
|----------|------|-----------|-----------|
| task.list | Offset | offset | 100 |
| task.getFeed | Cursor | cursor | 50 |
| messaging.getThread | Cursor | before (ID) | 100 |
| notification.list | Offset | offset | 100 |
| user.getXP | Limit | limit | - |
| rating.getForUser | Limit | limit | 50 |

---

**END OF API PAGINATION SPEC**
