# Screen H5: Active Task Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, HUSTLER_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Shows current task status while hustler is working. Provides proof submission, messaging, and task completion actions.

---

## Layout

```
┌─────────────────────────────────────────┐
│ Active Task                       ⋮     │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🟢 IN PROGRESS                      ││  ← Status badge
│  │                                     ││
│  │ Move furniture to storage           ││  ← Task title
│  │                                     ││
│  │ Started 45 min ago                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📍 Task Location                    ││
│  │    123 Main St, Austin TX           ││
│  │                           View Map →││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 👤 Sarah M.                         ││
│  │                                     ││
│  │    [Message]      [Call]            ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📋 Task Checklist                   ││
│  │                                     ││
│  │ ☑️ Arrived at location              ││
│  │ ☐ Complete requested work           ││
│  │ ☐ Submit proof photo                ││
│  │ ☐ Get poster approval               ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📸 Proof Submission                 ││
│  │                                     ││
│  │    No photos submitted              ││
│  │                                     ││
│  │    [Add Photo]                      ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        Submit for Approval          ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│  Having issues? [Report Problem]        │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface ActiveTaskScreenProps {
  // Task data
  task?: ActiveTask;

  // Checklist state (from props, not computed)
  checklist?: ChecklistItem[];

  // Proof photos
  proofPhotos?: ProofPhoto[];

  // State
  isLoading?: boolean;
  isSubmitting?: boolean;
  error?: Error | null;

  // Callbacks
  onViewMap?: () => void;
  onMessage?: () => void;
  onCall?: () => void;
  onAddPhoto?: () => void;
  onRemovePhoto?: (photoId: string) => void;
  onSubmitForApproval?: () => void;
  onReportProblem?: () => void;
}

interface ActiveTask {
  id: string;
  title: string;
  // Backend task.state is ACCEPTED or PROOF_SUBMITTED
  // uiPhase is a UI-only display state computed from worker location/actions
  taskState: 'ACCEPTED' | 'PROOF_SUBMITTED';
  uiPhase: 'EN_ROUTE' | 'ARRIVED' | 'WORKING' | 'SUBMITTING';  // Display state only, not persisted
  startedAt: string;

  location: {
    address: string;
    city: string;
    state: string;
  };

  poster: {
    id: string;
    displayName: string;
    avatarUrl?: string;
    phone?: string;
  };

  requirements?: string[];
}

interface ChecklistItem {
  id: string;
  label: string;
  isComplete: boolean;
}

interface ProofPhoto {
  id: string;
  uri: string;
  uploadedAt: string;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Title + overflow menu |
| Status card | `colors.success` tint bg for IN_PROGRESS |
| Status badge | `colors.success` bg, white text |
| Task title | `typography.h3`, `colors.neutral[900]` |
| Time elapsed | `typography.bodySmall`, `colors.neutral[600]` |
| Section cards | `cardStyles.outlined` |
| Section icon | 20px, `colors.neutral[500]` |
| Section title | `typography.bodySmall`, `colors.neutral[500]` |
| Poster name | `typography.body`, `fontWeight: 500` |
| Action buttons | `buttonVariants.secondary`, inline |
| Checklist | Checkboxes, `colors.success` when complete |
| Photo thumbnails | 80px square, `radius.md` |
| Add photo button | Dashed border, `colors.neutral[300]` |
| Submit button | `buttonVariants.primary`, `buttonSizes.lg` |
| Report link | `typography.bodySmall`, `colors.neutral[500]` |

---

## Status Badge Colors

| Status | Color | Label |
|--------|-------|-------|
| ACCEPTED | `colors.info` | ACCEPTED |
| EN_ROUTE | `colors.primary` | EN ROUTE |
| ARRIVED | `colors.primary` | ARRIVED |
| IN_PROGRESS | `colors.success` | IN PROGRESS |
| PROOF_SUBMITTED | `colors.warning` | AWAITING APPROVAL |

---

## Checklist Items

Standard checklist:
1. ☑️ Arrived at location
2. ☐ Complete requested work
3. ☐ Submit proof photo
4. ☐ Get poster approval

---

## Proof Photo Section

### No Photos
```
No photos submitted

[Add Photo]
```

### With Photos
```
┌──────┐ ┌──────┐ ┌──────┐
│ 📷   │ │ 📷   │ │ + Add│
│  ✕   │ │  ✕   │ │      │
└──────┘ └──────┘ └──────┘
```

---

## Submit Button States

| Condition | Button State |
|-----------|--------------|
| No photos | Disabled, "Add photos to submit" |
| Has photos | Enabled, "Submit for Approval" |
| Submitting | Loading, "Submitting..." |
| Already submitted | Disabled, "Awaiting Approval" |

---

## Overflow Menu

| Action |
|--------|
| View Task Details |
| Cancel Task |
| Report Problem |
| Contact Support |

---

**This screen is Cursor-ready. Build exactly as specified.**
