# HustleXP State Management Patterns

**AUTHORITY:** FRONTEND_ARCHITECTURE.md, ARCHITECTURE.md §2.5
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document defines HOW state flows through the app. Cursor MUST follow these patterns — do not invent state management approaches.

---

## Table of Contents

1. [Core Principles](#1-core-principles)
2. [State Categories](#2-state-categories)
3. [Data Flow Patterns](#3-data-flow-patterns)
4. [Screen State Patterns](#4-screen-state-patterns)
5. [Server State Management](#5-server-state-management)
6. [Context Providers](#6-context-providers)
7. [State Machine Integration](#7-state-machine-integration)

---

## 1. Core Principles

### 1.1 UI Has Zero Decision Authority

From ARCHITECTURE.md §2.5:

```
Layer 4: Frontend Logic → UX state only
Layer 5: UI → Representation only
```

**Rules:**
- UI may render state
- UI may request actions
- UI may **NEVER** compute, decide, or assume
- UI may **NEVER** display unconfirmed state

### 1.2 Server-Authoritative State

```typescript
// ❌ FORBIDDEN: Optimistic update
const handleComplete = async () => {
  setTaskState('COMPLETED'); // DON'T DO THIS
  await api.task.complete(taskId);
};

// ✅ CORRECT: Wait for server confirmation
const handleComplete = async () => {
  setIsLoading(true);
  try {
    const result = await api.task.complete(taskId);
    setTaskState(result.state); // Server-confirmed
  } catch (error) {
    handleError(error);
  } finally {
    setIsLoading(false);
  }
};
```

### 1.3 Single Source of Truth

| Data Type | Source of Truth | Where Stored |
|-----------|-----------------|--------------|
| Task state | Server | Fetched on demand |
| Escrow state | Server | Fetched on demand |
| User profile | Server | AuthContext (cached) |
| XP/Badges | Server | Fetched on demand |
| Form values | Local | Component state |
| UI state (modals, etc.) | Local | Component state |
| Navigation state | Local | React Navigation |

---

## 2. State Categories

### 2.1 Server State

Data that exists on the server. Always fetch, never assume.

```typescript
// Server state examples
interface ServerState {
  // User data
  user: UserProfile;
  xp: XPSummary;
  badges: Badge[];
  trustTier: TrustTierInfo;

  // Task data
  tasks: Task[];
  taskFeed: FeedTask[];
  activeTask: Task | null;

  // Financial data
  escrows: Escrow[];
  earnings: MoneyTimelineEntry[];
}
```

### 2.2 UI State

Ephemeral state that doesn't persist. Lives in component state.

```typescript
// UI state examples
interface UIState {
  // Loading states
  isLoading: boolean;
  isRefreshing: boolean;
  isSubmitting: boolean;

  // Modal/sheet visibility
  showFilterSheet: boolean;
  showConfirmModal: boolean;

  // Selection states
  selectedCategory: string | null;
  selectedPhotos: string[];

  // Form states
  formValues: Record<string, unknown>;
  formErrors: Record<string, string>;
}
```

### 2.3 Navigation State

Managed by React Navigation. Don't duplicate.

```typescript
// Navigation params are passed via navigation
navigation.navigate('TaskDetail', { taskId: '123' });

// Access in screen
const { taskId } = route.params;
```

---

## 3. Data Flow Patterns

### 3.1 Top-Down Data Flow

Data flows from parent to child via props.

```
App
├── AuthProvider (provides: user, auth methods)
│   └── NavigationContainer
│       └── TabNavigator
│           └── HomeScreen (receives: user from context)
│               └── TaskCard (receives: task via props)
```

### 3.2 Lifting State Up

When siblings need to share state, lift to common parent.

```typescript
// ❌ Wrong: Siblings trying to share state
const TaskList = () => {
  const [selectedId, setSelectedId] = useState(null);
  return tasks.map(t => <TaskCard task={t} />);
};

const TaskActions = () => {
  // Can't access selectedId!
};

// ✅ Correct: Lift state to parent
const TaskScreen = () => {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  return (
    <>
      <TaskList
        tasks={tasks}
        selectedId={selectedId}
        onSelect={setSelectedId}
      />
      <TaskActions
        taskId={selectedId}
        onAction={handleAction}
      />
    </>
  );
};
```

### 3.3 Callback Flow

Events flow up via callbacks.

```typescript
// Parent provides callbacks
const TaskScreen = () => {
  const handleAccept = async (taskId: string) => {
    const result = await api.task.accept({ task_id: taskId });
    // Update local state with server response
    setTask(result);
  };

  return <TaskCard task={task} onAccept={handleAccept} />;
};

// Child calls callbacks
const TaskCard = ({ task, onAccept }) => {
  return (
    <Button
      title="Accept"
      onPress={() => onAccept(task.id)}
    />
  );
};
```

---

## 4. Screen State Patterns

### 4.1 Standard Screen Pattern

Every screen follows this pattern:

```typescript
const ExampleScreen = () => {
  // 1. Navigation
  const navigation = useNavigation();
  const route = useRoute();

  // 2. Context (global state)
  const { user } = useAuth();

  // 3. Server state
  const [data, setData] = useState<Data | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // 4. UI state
  const [showModal, setShowModal] = useState(false);

  // 5. Data fetching
  useEffect(() => {
    const fetchData = async () => {
      try {
        const result = await api.getData(route.params.id);
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [route.params.id]);

  // 6. Event handlers
  const handleAction = async () => {
    try {
      const result = await api.doAction();
      setData(result);
    } catch (err) {
      setError(err.message);
    }
  };

  // 7. Render
  if (isLoading) return <LoadingScreen />;
  if (error) return <ErrorScreen message={error} onRetry={fetchData} />;
  if (!data) return null;

  return (
    <Screen>
      <Content data={data} onAction={handleAction} />
      <Modal visible={showModal} onClose={() => setShowModal(false)} />
    </Screen>
  );
};
```

### 4.2 List Screen Pattern

For screens with paginated lists:

```typescript
const TaskFeedScreen = () => {
  // Server state
  const [tasks, setTasks] = useState<FeedTask[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);

  // Loading states
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Initial load
  useEffect(() => {
    loadTasks();
  }, []);

  const loadTasks = async () => {
    setIsLoading(true);
    try {
      const result = await api.task.getFeed({ pagination: { limit: 20 } });
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
        pagination: { limit: 20, cursor }
      });
      setTasks(prev => [...prev, ...result.tasks]);
      setCursor(result.pagination.next_cursor);
      setHasMore(result.pagination.has_more);
    } finally {
      setIsLoadingMore(false);
    }
  };

  const refresh = async () => {
    setIsRefreshing(true);
    try {
      const result = await api.task.getFeed({ pagination: { limit: 20 } });
      setTasks(result.tasks);
      setCursor(result.pagination.next_cursor);
      setHasMore(result.pagination.has_more);
    } finally {
      setIsRefreshing(false);
    }
  };

  return (
    <List
      data={tasks}
      renderItem={(task) => <TaskCard task={task} />}
      keyExtractor={(task) => task.id}
      onEndReached={loadMore}
      onEndReachedThreshold={0.5}
      refreshing={isRefreshing}
      onRefresh={refresh}
      ListFooterComponent={isLoadingMore ? <ActivityIndicator /> : null}
    />
  );
};
```

### 4.3 Form Screen Pattern

For screens with forms:

```typescript
const TaskCreateScreen = () => {
  // Form state
  const [values, setValues] = useState({
    title: '',
    description: '',
    price: '',
    location: '',
    deadline: null,
    category: null,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Field change handler
  const handleChange = (field: string, value: unknown) => {
    setValues(prev => ({ ...prev, [field]: value }));

    // Clear error if field now valid
    if (touched[field] && errors[field]) {
      const error = validateField(field, value);
      if (!error) {
        setErrors(prev => {
          const next = { ...prev };
          delete next[field];
          return next;
        });
      }
    }
  };

  // Field blur handler
  const handleBlur = (field: string) => {
    setTouched(prev => ({ ...prev, [field]: true }));

    const error = validateField(field, values[field]);
    if (error) {
      setErrors(prev => ({ ...prev, [field]: error }));
    }
  };

  // Submit handler
  const handleSubmit = async () => {
    // Validate all
    const validationErrors = validateForm(values);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      setTouched(Object.keys(values).reduce((acc, k) => ({ ...acc, [k]: true }), {}));
      return;
    }

    setIsSubmitting(true);
    try {
      const result = await api.task.create(values);
      navigation.replace('TaskDetail', { taskId: result.id });
    } catch (error) {
      if (error.field) {
        setErrors({ [error.field]: error.message });
      } else {
        toast.show({ message: error.message, variant: 'error' });
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <ScrollView>
      <Input
        label="Title"
        value={values.title}
        onChangeText={(v) => handleChange('title', v)}
        onBlur={() => handleBlur('title')}
        error={touched.title ? errors.title : undefined}
      />
      {/* More fields... */}
      <Button
        title="Create Task"
        onPress={handleSubmit}
        loading={isSubmitting}
        disabled={isSubmitting}
      />
    </ScrollView>
  );
};
```

---

## 5. Server State Management

### 5.1 Fetch on Mount

```typescript
const useTask = (taskId: string) => {
  const [task, setTask] = useState<Task | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetch = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await api.task.getById({ task_id: taskId });
      setTask(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  }, [taskId]);

  useEffect(() => {
    fetch();
  }, [fetch]);

  return { task, isLoading, error, refetch: fetch };
};
```

### 5.2 Mutation Pattern

```typescript
const useMutation = <TInput, TOutput>(
  mutationFn: (input: TInput) => Promise<TOutput>
) => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const mutate = useCallback(async (input: TInput): Promise<TOutput | null> => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await mutationFn(input);
      return result;
    } catch (err) {
      setError(err.message);
      return null;
    } finally {
      setIsLoading(false);
    }
  }, [mutationFn]);

  return { mutate, isLoading, error };
};

// Usage
const { mutate: acceptTask, isLoading } = useMutation(api.task.accept);

const handleAccept = async () => {
  const result = await acceptTask({ task_id: taskId });
  if (result) {
    setTask(result);
  }
};
```

### 5.3 Polling Pattern (for real-time updates)

```typescript
const usePolling = <T>(
  fetchFn: () => Promise<T>,
  interval: number = 5000,
  enabled: boolean = true
) => {
  const [data, setData] = useState<T | null>(null);

  useEffect(() => {
    if (!enabled) return;

    const poll = async () => {
      try {
        const result = await fetchFn();
        setData(result);
      } catch (err) {
        // Silent fail for polling
        console.warn('Polling error:', err);
      }
    };

    poll(); // Initial fetch
    const intervalId = setInterval(poll, interval);

    return () => clearInterval(intervalId);
  }, [fetchFn, interval, enabled]);

  return data;
};

// Usage: Poll for task updates while in progress
const taskUpdates = usePolling(
  () => api.task.getById({ task_id: taskId }),
  5000,
  task?.state === 'ACCEPTED'
);
```

---

## 6. Context Providers

### 6.1 AuthContext

Global authentication state.

```typescript
interface AuthContextValue {
  user: UserProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (data: SignUpInput) => Promise<void>;
  signOut: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Check auth on mount
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = await getStoredToken();
        if (token) {
          const profile = await api.user.getProfile();
          setUser(profile);
        }
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, []);

  const signIn = async (email: string, password: string) => {
    const { token, user } = await api.auth.signIn({ email, password });
    await storeToken(token);
    setUser(user);
  };

  const signOut = async () => {
    await clearToken();
    setUser(null);
  };

  const refreshUser = async () => {
    const profile = await api.user.getProfile();
    setUser(profile);
  };

  return (
    <AuthContext.Provider value={{
      user,
      isAuthenticated: !!user,
      isLoading,
      signIn,
      signUp,
      signOut,
      refreshUser,
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### 6.2 OnboardingContext

Onboarding flow state.

```typescript
interface OnboardingContextValue {
  progress: OnboardingProgress | null;
  setRole: (role: UserRole, confidence: string) => Promise<void>;
  submitCapabilities: (claims: CapabilityClaims) => Promise<void>;
  completeStep: (stepId: string, data?: unknown) => Promise<void>;
  complete: () => Promise<void>;
}

const OnboardingContext = createContext<OnboardingContextValue | null>(null);

export const OnboardingProvider = ({ children }) => {
  const [progress, setProgress] = useState<OnboardingProgress | null>(null);

  useEffect(() => {
    const fetchProgress = async () => {
      const result = await api.onboarding.getProgress();
      setProgress(result);
    };
    fetchProgress();
  }, []);

  // ... methods

  return (
    <OnboardingContext.Provider value={{ progress, /* methods */ }}>
      {children}
    </OnboardingContext.Provider>
  );
};
```

### 6.3 ToastContext

Toast notification state.

```typescript
interface ToastContextValue {
  show: (options: ToastOptions) => void;
  dismiss: () => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

export const ToastProvider = ({ children }) => {
  const [toast, setToast] = useState<ToastOptions | null>(null);

  const show = (options: ToastOptions) => {
    setToast(options);
    setTimeout(() => setToast(null), options.duration || 3000);
  };

  const dismiss = () => setToast(null);

  return (
    <ToastContext.Provider value={{ show, dismiss }}>
      {children}
      {toast && <Toast {...toast} onDismiss={dismiss} />}
    </ToastContext.Provider>
  );
};
```

---

## 7. State Machine Integration

### 7.1 Using State Machines

State machines define valid transitions. Use them to validate UI actions.

```typescript
import { TaskStateMachine } from '@/state';

const TaskDetailScreen = () => {
  const [task, setTask] = useState<Task | null>(null);

  // Check if action is valid
  const canAccept = task && TaskStateMachine.canTransition(task.state, 'ACCEPTED');
  const canCancel = task && TaskStateMachine.canTransition(task.state, 'CANCELLED');
  const canSubmitProof = task && TaskStateMachine.canTransition(task.state, 'PROOF_SUBMITTED');

  return (
    <>
      {canAccept && (
        <Button title="Accept Task" onPress={handleAccept} />
      )}
      {canCancel && (
        <Button title="Cancel Task" variant="danger" onPress={handleCancel} />
      )}
      {canSubmitProof && (
        <Button title="Submit Proof" onPress={handleSubmitProof} />
      )}
    </>
  );
};
```

### 7.2 State Machine Reference

```typescript
// Task state transitions (from PRODUCT_SPEC)
const TASK_TRANSITIONS = {
  OPEN: ['ACCEPTED', 'CANCELLED', 'EXPIRED'],
  ACCEPTED: ['PROOF_SUBMITTED', 'CANCELLED', 'EXPIRED'],
  PROOF_SUBMITTED: ['COMPLETED', 'DISPUTED'],
  DISPUTED: ['COMPLETED', 'CANCELLED'],
  COMPLETED: [], // Terminal
  CANCELLED: [], // Terminal
  EXPIRED: [], // Terminal
};

// Escrow state transitions
const ESCROW_TRANSITIONS = {
  PENDING: ['FUNDED'],
  FUNDED: ['RELEASED', 'LOCKED_DISPUTE'],
  LOCKED_DISPUTE: ['RELEASED', 'REFUNDED', 'REFUND_PARTIAL'],
  RELEASED: [], // Terminal
  REFUNDED: [], // Terminal
  REFUND_PARTIAL: [], // Terminal
};

export const TaskStateMachine = {
  canTransition: (from: TaskState, to: TaskState): boolean => {
    return TASK_TRANSITIONS[from]?.includes(to) ?? false;
  },
  isTerminal: (state: TaskState): boolean => {
    return TASK_TRANSITIONS[state]?.length === 0;
  },
};
```

---

## Summary

| Pattern | When to Use |
|---------|-------------|
| Component state (`useState`) | UI state, form values, loading flags |
| Context | Global state shared across many screens (auth, toast) |
| Props | Passing data/callbacks from parent to child |
| Server fetch | Getting any data from the server |
| State machines | Validating state transitions before actions |

**Golden Rule:** If it's on the server, fetch it. If it's local UI, useState. If it's shared globally, Context. Never guess or assume state.

---

**END OF STATE MANAGEMENT PATTERNS**
