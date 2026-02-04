# Screen O5: Capability Intro Screen (Category Selection)
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md, SKILL_TAXONOMY.md
**Cursor-Ready:** YES
**Role:** Hustler Only
**Successor:** O5b (Skill Cloud — bubble-tap granular skill selection within chosen categories)

---

## Overview

Introduces the capability declaration process. User selects broad categories (Physical Tasks, Handy Work, Transportation, etc.), then proceeds to O5b for granular skill selection within those categories.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│            🛠️                           │  ← Icon 64px
│                                         │
│         Tell us what you                │  ← typography.h1
│            can do                       │
│                                         │
│   The more capabilities you add,        │  ← typography.body
│   the more tasks you'll see.            │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📦                                  ││
│  │ Physical Tasks                      ││
│  │ Moving, lifting, delivery           ││
│  │                                  →  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🔧                                  ││
│  │ Handy Work                          ││
│  │ Assembly, repairs, installation     ││
│  │                                  →  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🚗                                  ││
│  │ Transportation                      ││
│  │ Deliveries, errands, driving        ││
│  │                                  →  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 💻                                  ││
│  │ Tech & Digital                      ││
│  │ Setup, troubleshooting, teaching    ││
│  │                                  →  ││
│  └─────────────────────────────────────┘│
│                                         │
│            Skip for now                 │  ← Link
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface CapabilityIntroScreenProps {
  // Categories to display
  categories?: CapabilityCategory[];

  // Callbacks
  onSelectCategory?: (categoryId: string) => void;
  onSkip?: () => void;
  onBack?: () => void;
}

interface CapabilityCategory {
  id: string;
  icon: string;
  name: string;
  description: string;
  taskCount?: number;  // Optional: "15 task types"
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Icon | 64px, `colors.neutral[400]` |
| Title | `typography.h1`, `colors.neutral[900]`, centered |
| Subtitle | `typography.body`, `colors.neutral[600]`, centered |
| Category cards | `cardStyles.default`, full width, pressable |
| Card icon | 32px, `colors.primary[500]` |
| Card title | `typography.body`, `colors.neutral[900]`, `fontWeight: 600` |
| Card description | `typography.bodySmall`, `colors.neutral[600]` |
| Arrow | `iconSize.md`, `colors.neutral[400]` |
| Skip link | `typography.body`, `colors.neutral[500]` |

---

## Category Data

| Icon | Name | Description |
|------|------|-------------|
| 📦 | Physical Tasks | Moving, lifting, delivery |
| 🔧 | Handy Work | Assembly, repairs, installation |
| 🚗 | Transportation | Deliveries, errands, driving |
| 💻 | Tech & Digital | Setup, troubleshooting, teaching |

---

## Behavior

- Tapping a category navigates to capability selection for that category
- Skip for now bypasses capability setup entirely
- User can return to add capabilities later from settings

---

**This screen is Cursor-ready. Build exactly as specified.**
