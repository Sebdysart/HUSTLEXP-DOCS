# MOLECULE: StatusBadge

**STATUS: LOCKED**
**Location:** `src/components/molecules/StatusBadge.tsx`

---

## PURPOSE

Displays status indicators for tasks, users, and other entities.
Combines Badge atom with icon for enhanced meaning.

---

## VARIANTS

| Variant | Use Case | Colors |
|---------|----------|--------|
| `task-status` | Task state (posted, active, completed) | Status-specific |
| `trust-tier` | User trust level (T1-T5) | Tier-specific |
| `verification-status` | ID verification state | Green/yellow/gray |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│  ┌──────────────────┐                       │
│  │ [Icon] POSTED   │                        │
│  └──────────────────┘                       │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Badge | Background container |
| Icon | Status indicator icon |
| Text (badge) | Status label text |

---

## PROPS INTERFACE

```typescript
interface StatusBadgeProps {
  // Required data (from backend)
  variant: 'task-status' | 'trust-tier' | 'verification-status';
  status: string;  // Status value from backend
  
  // Optional
  iconName?: string;  // Override default icon
  size?: 'small' | 'medium';
  
  // Accessibility
  accessibilityLabel?: string;
}
```

---

## VISUAL STATES

### Task Status Mapping
| Status | Color | Icon |
|--------|-------|------|
| POSTED | Blue (#3B82F6) | clock |
| ACTIVE | Orange (#FF6B35) | activity |
| IN_PROGRESS | Orange (#FF6B35) | play |
| COMPLETED | Green (#10B981) | check-circle |
| CANCELLED | Gray (#6B7280) | x-circle |
| DISPUTED | Red (#EF4444) | alert-triangle |

### Trust Tier Mapping
| Tier | Color | Label |
|------|-------|-------|
| 1 | Gray (#6B7280) | Tier 1 |
| 2 | Blue (#3B82F6) | Tier 2 |
| 3 | Purple (#8B5CF6) | Tier 3 |
| 4 | Gold (#F59E0B) | Tier 4 |
| 5 | Orange (#FF6B35) | Tier 5 |

### Verification Status
| Status | Color | Icon |
|--------|-------|------|
| VERIFIED | Green (#10B981) | check |
| PENDING | Yellow (#FBBF24) | clock |
| UNVERIFIED | Gray (#6B7280) | x |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Status is clear and unambiguous
- ✅ Color coding is consistent
- ✅ Icon reinforces meaning

**FORBIDDEN:**
- ❌ Computing status client-side
- ❌ Custom status values not from backend
- ❌ Missing color/icon mapping
- ❌ Status without proper context

---

## USAGE EXAMPLES

### Task Card Status
```tsx
<StatusBadge
  variant="task-status"
  status={taskData.status}
/>
```

### User Trust Tier
```tsx
<StatusBadge
  variant="trust-tier"
  status={userData.trustTier.toString()}
  size="small"
/>
```

### Verification Badge
```tsx
<StatusBadge
  variant="verification-status"
  status={userData.verificationStatus}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Status change | Fade out → update → fade in, 200ms |
| Appear | Fade in, 150ms |

---

## FORBIDDEN

```
❌ Computing status based on other fields
❌ Hardcoded status labels
❌ Custom badge colors outside mapping
❌ Status updates without backend data
❌ Missing status in mapping (must handle gracefully)
```

---

## DESIGN TOKENS

**Colors:**
See status mapping tables above. All colors referenced from:
- `colors.info` (blue)
- `colors.primary` (orange)
- `colors.success` (green)
- `colors.warning` (yellow)
- `colors.error` (red)
- `colors.textTertiary` (gray)

**Typography:**
- Badge text: `typography.badge` (12px SemiBold, uppercase)

**Spacing:**
- Icon to text: `spacing.xs` (4px)
- Internal padding: `spacing.xs` × `spacing.sm` (4px × 8px)

**Sizes:**
- Small badge: 20px height
- Medium badge: 24px height
- Icon: 12px (small), 16px (medium)

---

## STATUS FALLBACK

When status is not recognized:

```typescript
// Unknown status defaults to gray with question icon
<StatusBadge
  variant="task-status"
  status="UNKNOWN_STATUS"
  // Renders as: [?] UNKNOWN_STATUS (gray)
/>
```

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
