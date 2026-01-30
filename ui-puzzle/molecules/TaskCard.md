# MOLECULE: TaskCard

**STATUS: LOCKED**  
**Location:** `src/components/molecules/TaskCard.tsx`

---

## PURPOSE

Displays a task summary in feed and list contexts.
The primary way users discover and select tasks.

---

## VARIANTS

| Variant | Use Case | Height |
|---------|----------|--------|
| `compact` | Feed lists, history | 120px |
| `expanded` | Selected/featured task | 200px |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│ ┌─────┐  Title                    [$Price] │
│ │Avatar│  Location • Distance              │
│ └─────┘  ┌─────────┐ ┌─────────┐          │
│          │ Badge 1 │ │ Badge 2 │          │
│          └─────────┘ └─────────┘          │
│                                            │
│  [Compact: ends here]                      │
│                                            │
│  Description text (expanded only)...       │
│  ┌──────────────┐                         │
│  │ Action Button│                         │
│  └──────────────┘                         │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Avatar | Poster's image |
| Text (heading) | Task title |
| Text (body) | Location, distance |
| Text (caption) | Description (expanded) |
| Badge (status) | Task status |
| Badge (tier) | Required trust tier |
| Icon | Distance, time icons |
| Button | Action (expanded only) |

---

## PROPS INTERFACE

```typescript
interface TaskCardProps {
  // Required data (from backend, never computed here)
  task: {
    id: string;
    title: string;
    description?: string;
    price: number;
    currency: string;
    location: {
      name: string;
      distance?: string;  // Pre-computed by backend
    };
    status: TaskStatus;
    requiredTrustTier: 1 | 2 | 3 | 4 | 5;
    poster: {
      id: string;
      name: string;
      avatarUrl?: string;
    };
    isEligible: boolean;  // Pre-computed by backend
  };
  
  // Appearance
  variant?: 'compact' | 'expanded';
  
  // Events
  onPress?: () => void;
  onAction?: () => void;  // For expanded variant
  
  // Accessibility
  accessibilityLabel?: string;
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Base appearance |
| Pressed | 2% darker background, scale 0.99 |
| Ineligible | 60% opacity, "Tier X Required" badge |
| Urgent | Pulsing border (if time-sensitive) |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ This task is available FOR YOU
- ✅ Taking it is easy
- ✅ The reward is clear and attractive

**FORBIDDEN:**
- ❌ "You don't qualify" (show tier needed instead)
- ❌ Empty price display
- ❌ Unclear location
- ❌ Missing poster info

---

## USAGE EXAMPLES

### In Feed (Compact)
```tsx
<TaskCard
  task={taskData}
  variant="compact"
  onPress={() => navigation.navigate('TaskDetail', { taskId: task.id })}
/>
```

### Selected Task (Expanded)
```tsx
<TaskCard
  task={taskData}
  variant="expanded"
  onPress={() => {}}
  onAction={() => handleAcceptTask(task.id)}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Appear in list | Fade in + slide up, stagger 50ms |
| Press | Scale 0.99, duration 100ms |
| Expand | Height animate, duration 200ms |

---

## FORBIDDEN

```
❌ Computing isEligible inside the component
❌ Computing distance inside the component
❌ Fetching poster data
❌ Hardcoded prices or currencies
❌ Custom background colors
❌ Inline styles
```

---

## ARCHETYPE USAGE

| Archetype | TaskCard Usage |
|-----------|----------------|
| B. Feed/Opportunity | Primary content, compact variant |
| C. Task Lifecycle | Selected task, expanded variant |

Not used in other archetypes (use different molecules for non-task content).
