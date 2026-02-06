# MOLECULE: UserHeader

**STATUS: LOCKED**
**Location:** `src/components/molecules/UserHeader.tsx`

---

## PURPOSE

Displays user identity and status at the top of screens.
Primary way users see their profile info in context.

---

## VARIANTS

| Variant | Use Case | Elements |
|---------|----------|----------|
| `with-avatar` | Profile, home screens | Avatar + name + role + tier |
| `text-only` | Settings, compact headers | Name + role only |

---

## ANATOMY

### With Avatar Variant
```
┌─────────────────────────────────────────────┐
│ ┌─────┐                                     │
│ │     │  Marcus Johnson                     │
│ │ Img │  Hustler • Tier 3 ┌─────────┐      │
│ │     │                   │ Badge T3│      │
│ └─────┘                   └─────────┘      │
└─────────────────────────────────────────────┘
```

### Text-Only Variant
```
┌─────────────────────────────────────────────┐
│ Marcus Johnson                              │
│ Hustler • Tier 3                            │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Avatar | User profile image |
| Text (heading) | User's display name |
| Text (body) | Role and tier text |
| Badge | Trust tier indicator |

---

## PROPS INTERFACE

```typescript
interface UserHeaderProps {
  // Required data (from backend)
  user: {
    id: string;
    name: string;
    avatarUrl?: string;
    role: 'hustler' | 'poster';
    trustTier: 1 | 2 | 3 | 4 | 5;
  };
  
  // Appearance
  variant?: 'with-avatar' | 'text-only';
  
  // Events
  onPress?: () => void;  // Optional navigation to profile
  
  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Base appearance |
| Pressed | 95% opacity if onPress provided |
| Loading | Skeleton shimmer on avatar/text |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ User is recognized and valued
- ✅ Trust tier is visible and meaningful
- ✅ Role is clear (Hustler vs Poster)

**FORBIDDEN:**
- ❌ "New user" label (feels exclusionary)
- ❌ Missing tier badge
- ❌ Placeholder avatar without fallback

---

## USAGE EXAMPLES

### Home Screen Header
```tsx
<UserHeader
  user={currentUser}
  variant="with-avatar"
  onPress={() => navigation.navigate('Profile')}
/>
```

### Settings Header
```tsx
<UserHeader
  user={currentUser}
  variant="text-only"
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Screen enter | Fade in, duration 200ms |
| Press | Opacity 0.95, duration 100ms |

---

## FORBIDDEN

```
❌ Computing trust tier client-side
❌ Fetching user data inside component
❌ Hardcoded role labels
❌ Avatar without error fallback
❌ Inline styles for badges
```

---

## DESIGN TOKENS

**Colors:**
- Name text: `colors.textPrimary` (#FFFFFF)
- Role text: `colors.textSecondary` (#9CA3AF)
- Badge: Tier-specific color from design system

**Typography:**
- Name: `typography.headline` (20px SemiBold)
- Role: `typography.body` (16px Regular)

**Spacing:**
- Avatar to text: `spacing.md` (16px)
- Name to role: `spacing.xs` (4px)
- Internal padding: `spacing.lg` (24px)

**Sizes:**
- Avatar: 64px (with-avatar variant)

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
