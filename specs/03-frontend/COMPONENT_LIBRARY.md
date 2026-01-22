# HustleXP Component Library

**AUTHORITY:** DESIGN_SYSTEM.md, FRONTEND_ARCHITECTURE.md, UI_SPEC.md
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document provides formal specifications for ALL UI components. Cursor MUST use these specs — do not invent props, states, or behaviors.

---

## Table of Contents

1. [Button](#1-button)
2. [Card](#2-card)
3. [HXText](#3-hxtext)
4. [Input](#4-input)
5. [Avatar](#5-avatar)
6. [Badge](#6-badge)
7. [TaskCard](#7-taskcard)
8. [SearchBar](#8-searchbar)
9. [Modal](#9-modal)
10. [BottomSheet](#10-bottomsheet)
11. [List](#11-list)
12. [ProgressBar](#12-progressbar)
13. [Skeleton](#13-skeleton)
14. [Toast](#14-toast)
15. [TabBar](#15-tabbar)
16. [Header](#16-header)
17. [FirstXPCelebration](#17-firstxpcelebration)
18. [LockedGamificationUI](#18-lockedgamificationui)
19. [MoneyTimeline](#19-moneytimeline)
20. [FailureRecovery](#20-failurerecovery)
21. [LiveModeUI](#21-livemodeui)

---

## 1. Button

**Reference:** `reference/components/Button.js`
**Import:** `import { Button } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `title` | `string` | - | YES | Button label text |
| `onPress` | `() => void` | - | YES | Press handler |
| `variant` | `'primary' \| 'secondary' \| 'ghost' \| 'danger'` | `'primary'` | NO | Visual style |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | NO | Button size |
| `disabled` | `boolean` | `false` | NO | Disable interactions |
| `loading` | `boolean` | `false` | NO | Show loading spinner |
| `fullWidth` | `boolean` | `false` | NO | Expand to container width |
| `accessibilityLabel` | `string` | `title` | NO | Screen reader label |
| `style` | `ViewStyle` | - | NO | Additional container styles |
| `textStyle` | `TextStyle` | - | NO | Additional text styles |

### Visual States

| State | Visual | Interaction |
|-------|--------|-------------|
| Default | Per variant styling | Pressable |
| Pressed | 0.7 opacity | Active feedback |
| Disabled | Gray background, muted text | Non-interactive |
| Loading | Spinner replaces text, same size | Non-interactive |

### Variants

| Variant | Background | Text | Border |
|---------|------------|------|--------|
| `primary` | `GRAY[900]` (#111827) | White | None |
| `secondary` | White | `GRAY[900]` | `GRAY[300]` 1px |
| `ghost` | Transparent | `GRAY[900]` | None |
| `danger` | `STATUS.error` (#EF4444) | White | None |

### Sizes

| Size | Height | Horizontal Padding | Font Size |
|------|--------|-------------------|-----------|
| `sm` | 44px | 12px | 14px |
| `md` | 48px | 16px | 16px |
| `lg` | 56px | 24px | 18px |

### Accessibility

- Minimum touch target: 44×44 points (WCAG)
- `accessibilityRole="button"`
- `accessibilityState={{ disabled }}` when disabled or loading
- Focus indicator visible

### Usage Example

```tsx
<Button
  title="Accept Task"
  onPress={handleAccept}
  variant="primary"
  size="lg"
  fullWidth
  loading={isSubmitting}
/>
```

---

## 2. Card

**Reference:** `reference/components/Card.js`
**Import:** `import { Card } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `children` | `ReactNode` | - | YES | Card content |
| `variant` | `'elevated' \| 'outlined' \| 'filled'` | `'elevated'` | NO | Visual style |
| `padding` | `number` | `4` | NO | Padding level (SPACING index) |
| `onPress` | `() => void` | - | NO | Makes card pressable |
| `style` | `ViewStyle` | - | NO | Additional styles |

### Variants

| Variant | Background | Shadow | Border |
|---------|------------|--------|--------|
| `elevated` | White | `elevation: 2` | None |
| `outlined` | White | None | `BORDER` 1px |
| `filled` | `GRAY[50]` | None | None |

### Pressable Behavior

When `onPress` is provided:
- Card becomes `Pressable`
- Pressed state: `opacity: 0.9`, `scale: 0.99`
- `accessibilityRole="button"`

### Usage Example

```tsx
<Card variant="elevated" padding={4} onPress={handleTaskPress}>
  <HXText variant="h4">Task Title</HXText>
  <HXText variant="body" color="secondary">Task description...</HXText>
</Card>
```

---

## 3. HXText

**Reference:** `reference/components/Text.js`
**Import:** `import { HXText } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `children` | `ReactNode` | - | YES | Text content |
| `variant` | `'h1' \| 'h2' \| 'h3' \| 'h4' \| 'body' \| 'bodySmall' \| 'caption' \| 'label'` | `'body'` | NO | Typography style |
| `color` | `'primary' \| 'secondary' \| 'tertiary' \| 'inverse' \| 'error'` | `'primary'` | NO | Text color |
| `weight` | `'normal' \| 'medium' \| 'semibold' \| 'bold'` | Per variant | NO | Font weight override |
| `align` | `'left' \| 'center' \| 'right'` | `'left'` | NO | Text alignment |
| `style` | `TextStyle` | - | NO | Additional styles |

### Typography Scale

| Variant | Size | Weight | Line Height |
|---------|------|--------|-------------|
| `h1` | 48px | Bold | 1.2 |
| `h2` | 36px | Bold | 1.2 |
| `h3` | 24px | Semibold | 1.2 |
| `h4` | 20px | Semibold | 1.4 |
| `body` | 16px | Normal | 1.5 |
| `bodySmall` | 14px | Normal | 1.5 |
| `caption` | 12px | Normal | 1.5 |
| `label` | 14px | Medium | 1.5 |

### Color Mapping

| Color | Value |
|-------|-------|
| `primary` | `GRAY[900]` (#111827) |
| `secondary` | `GRAY[600]` (#4B5563) |
| `tertiary` | `GRAY[400]` (#9CA3AF) |
| `inverse` | White |
| `error` | `STATUS.error` (#EF4444) |

### Usage Example

```tsx
<HXText variant="h2" color="primary">Welcome Back</HXText>
<HXText variant="body" color="secondary">Your tasks for today</HXText>
```

---

## 4. Input

**Reference:** `reference/components/Input.js`
**Import:** `import { Input } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `label` | `string` | - | NO | Field label |
| `error` | `string` | - | NO | Error message |
| `hint` | `string` | - | NO | Helper text |
| `containerStyle` | `ViewStyle` | - | NO | Container styles |
| `value` | `string` | - | NO | Input value |
| `onChangeText` | `(text: string) => void` | - | NO | Text change handler |
| `placeholder` | `string` | - | NO | Placeholder text |
| `secureTextEntry` | `boolean` | `false` | NO | Password field |
| `keyboardType` | `KeyboardType` | `'default'` | NO | Keyboard type |
| `autoCapitalize` | `'none' \| 'sentences' \| 'words' \| 'characters'` | `'sentences'` | NO | Auto-capitalize |
| `autoComplete` | `string` | - | NO | Auto-complete hint |
| `autoFocus` | `boolean` | `false` | NO | Focus on mount |
| `editable` | `boolean` | `true` | NO | Editable state |
| `maxLength` | `number` | - | NO | Max character count |
| `multiline` | `boolean` | `false` | NO | Multiline input |
| `numberOfLines` | `number` | - | NO | Number of lines (multiline) |
| `onBlur` | `() => void` | - | NO | Blur handler |
| `onFocus` | `() => void` | - | NO | Focus handler |
| `onSubmitEditing` | `() => void` | - | NO | Submit handler |
| `returnKeyType` | `'done' \| 'go' \| 'next' \| 'search' \| 'send'` | - | NO | Return key type |

### Visual States

| State | Border Color | Border Width |
|-------|--------------|--------------|
| Default | `GRAY[300]` | 1px |
| Focused | `GRAY[900]` | 2px |
| Error | `STATUS.error` | 2px |
| Disabled | `GRAY[200]` | 1px (background: `GRAY[100]`) |

### Structure

```
┌─────────────────────────────────────┐
│ Label (14px, medium, GRAY[900])     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Input (16px, min-height 48px)   │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Hint/Error (14px, GRAY[600]/red)    │
└─────────────────────────────────────┘
```

### Accessibility

- `accessibilityLabel` defaults to `label` or `placeholder`
- Minimum touch target: 44×44 points
- Focus state visually distinct

### Usage Example

```tsx
<Input
  label="Email"
  value={email}
  onChangeText={setEmail}
  keyboardType="email-address"
  autoCapitalize="none"
  autoComplete="email"
  error={emailError}
/>
```

---

## 5. Avatar

**Import:** `import { Avatar } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `source` | `string \| null` | - | NO | Image URL |
| `name` | `string` | - | YES | User name (for fallback initials) |
| `size` | `'sm' \| 'md' \| 'lg' \| 'xl'` | `'md'` | NO | Avatar size |
| `trustTier` | `1 \| 2 \| 3 \| 4` | - | NO | Show trust tier badge |
| `showVerified` | `boolean` | `false` | NO | Show verified checkmark |

### Sizes

| Size | Diameter | Font Size (initials) |
|------|----------|---------------------|
| `sm` | 32px | 12px |
| `md` | 48px | 16px |
| `lg` | 64px | 20px |
| `xl` | 96px | 28px |

### Fallback Behavior

1. If `source` is provided and loads → Show image
2. If `source` fails or is null → Show initials from `name`
3. Initials: First letter of first name + first letter of last name (uppercase)

### Trust Tier Badge

When `trustTier` is provided, show small badge:
- Position: Bottom-right corner
- Size: 25% of avatar diameter
- Colors per tier (from DESIGN_SYSTEM.md)

### Usage Example

```tsx
<Avatar
  source={user.avatar_url}
  name={user.full_name}
  size="md"
  trustTier={user.trust_tier}
/>
```

---

## 6. Badge

**Import:** `import { Badge } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `label` | `string` | - | YES | Badge text |
| `variant` | `'default' \| 'success' \| 'warning' \| 'error' \| 'info' \| 'live'` | `'default'` | NO | Color variant |
| `size` | `'sm' \| 'md'` | `'md'` | NO | Badge size |
| `icon` | `ReactNode` | - | NO | Leading icon |

### Variant Colors

| Variant | Background | Text |
|---------|------------|------|
| `default` | `GRAY[100]` | `GRAY[700]` |
| `success` | `#D1FAE5` | `#065F46` |
| `warning` | `#FEF3C7` | `#92400E` |
| `error` | `#FEE2E2` | `#991B1B` |
| `info` | `#DBEAFE` | `#1E40AF` |
| `live` | `#FEE2E2` | `#EF4444` (with red dot) |

### Sizes

| Size | Height | Padding | Font Size |
|------|--------|---------|-----------|
| `sm` | 20px | 6px | 11px |
| `md` | 24px | 8px | 12px |

### Usage Example

```tsx
<Badge label="LIVE" variant="live" size="sm" />
<Badge label="Verified" variant="success" icon={<CheckIcon />} />
```

---

## 7. TaskCard

**Import:** `import { TaskCard } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `task` | `TaskSummary \| FeedTask` | - | YES | Task data |
| `onPress` | `() => void` | - | YES | Press handler |
| `showDistance` | `boolean` | `false` | NO | Show distance (for feed) |
| `showEligibility` | `boolean` | `false` | NO | Show eligibility blockers |
| `variant` | `'default' \| 'compact'` | `'default'` | NO | Card style |

### Structure (Default)

```
┌──────────────────────────────────────────────┐
│ 🔴 LIVE (if mode=LIVE)                       │
├──────────────────────────────────────────────┤
│ [Avatar] Poster Name • Trust Tier            │
│                                              │
│ Task Title (h4)                              │
│ Category • 1.2 mi away (if showDistance)    │
│                                              │
│ $35.00                    Deadline: 2h       │
│                                              │
│ ⚠️ Requires Tier 3 (if !eligible)           │
└──────────────────────────────────────────────┘
```

### Color Rules (UI_SPEC §2)

- **In Task Feed:** NO XP colors, NO success colors
- **Price:** Neutral gray (`GRAY[900]`)
- **LIVE badge:** Red (`LIVE_MODE.INDICATOR`)
- **Eligibility blockers:** Warning amber

### Usage Example

```tsx
<TaskCard
  task={task}
  onPress={() => navigation.navigate('TaskDetail', { taskId: task.id })}
  showDistance
  showEligibility
/>
```

---

## 8. SearchBar

**Import:** `import { SearchBar } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `value` | `string` | - | YES | Search query |
| `onChangeText` | `(text: string) => void` | - | YES | Text change handler |
| `placeholder` | `string` | `'Search...'` | NO | Placeholder text |
| `onSubmit` | `() => void` | - | NO | Submit handler |
| `onClear` | `() => void` | - | NO | Clear handler |
| `showCancel` | `boolean` | `false` | NO | Show cancel button |
| `onCancel` | `() => void` | - | NO | Cancel handler |
| `autoFocus` | `boolean` | `false` | NO | Focus on mount |

### Structure

```
┌────────────────────────────────────────────────┐
│ [🔍] Search...                    [✕] [Cancel] │
└────────────────────────────────────────────────┘
```

### Behavior

- Clear button (✕) appears when `value.length > 0`
- Cancel button appears when `showCancel=true`
- Submit on Return key press
- Minimum height: 44px

### Usage Example

```tsx
<SearchBar
  value={searchQuery}
  onChangeText={setSearchQuery}
  placeholder="Search tasks..."
  onSubmit={handleSearch}
  showCancel={isSearching}
  onCancel={handleCancelSearch}
/>
```

---

## 9. Modal

**Import:** `import { Modal } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `visible` | `boolean` | - | YES | Modal visibility |
| `onClose` | `() => void` | - | YES | Close handler |
| `title` | `string` | - | NO | Modal title |
| `children` | `ReactNode` | - | YES | Modal content |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | NO | Modal width |
| `showCloseButton` | `boolean` | `true` | NO | Show X button |
| `closeOnBackdrop` | `boolean` | `true` | NO | Close on backdrop press |

### Sizes

| Size | Width | Max Height |
|------|-------|------------|
| `sm` | 280px | 50% |
| `md` | 340px | 70% |
| `lg` | 400px | 85% |

### Structure

```
┌────────────────────────────────────┐
│ Title                         [✕]  │
├────────────────────────────────────┤
│                                    │
│ {children}                         │
│                                    │
└────────────────────────────────────┘
```

### Animation

- Fade in backdrop (150ms)
- Scale up content from 0.9 to 1.0 (200ms)

### Usage Example

```tsx
<Modal
  visible={showConfirm}
  onClose={() => setShowConfirm(false)}
  title="Cancel Task?"
  size="sm"
>
  <HXText>Are you sure you want to cancel this task?</HXText>
  <Button title="Cancel Task" variant="danger" onPress={handleCancel} />
</Modal>
```

---

## 10. BottomSheet

**Import:** `import { BottomSheet } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `visible` | `boolean` | - | YES | Sheet visibility |
| `onClose` | `() => void` | - | YES | Close handler |
| `title` | `string` | - | NO | Sheet title |
| `children` | `ReactNode` | - | YES | Sheet content |
| `snapPoints` | `string[]` | `['50%']` | NO | Snap point heights |
| `enablePanDownToClose` | `boolean` | `true` | NO | Swipe to close |

### Structure

```
┌────────────────────────────────────────────────┐
│                   ═══ (drag handle)            │
│ Title                                     [✕]  │
├────────────────────────────────────────────────┤
│                                                │
│ {children}                                     │
│                                                │
└────────────────────────────────────────────────┘
```

### Animation

- Slide up from bottom (300ms, ease-out)
- Backdrop fade in (150ms)
- Respects `prefers-reduced-motion`

### Usage Example

```tsx
<BottomSheet
  visible={showFilters}
  onClose={() => setShowFilters(false)}
  title="Filter Tasks"
  snapPoints={['40%', '80%']}
>
  <FilterOptions />
</BottomSheet>
```

---

## 11. List

**Import:** `import { List } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `data` | `T[]` | - | YES | List data |
| `renderItem` | `(item: T, index: number) => ReactNode` | - | YES | Item renderer |
| `keyExtractor` | `(item: T) => string` | - | YES | Key extractor |
| `onEndReached` | `() => void` | - | NO | Infinite scroll handler |
| `onEndReachedThreshold` | `number` | `0.5` | NO | End threshold |
| `refreshing` | `boolean` | `false` | NO | Pull-to-refresh state |
| `onRefresh` | `() => void` | - | NO | Refresh handler |
| `ListEmptyComponent` | `ReactNode` | - | NO | Empty state |
| `ListHeaderComponent` | `ReactNode` | - | NO | Header |
| `ListFooterComponent` | `ReactNode` | - | NO | Footer (loading indicator) |
| `ItemSeparatorComponent` | `ReactNode` | - | NO | Separator between items |

### Pagination Pattern

For infinite scroll:
1. Track `cursor` from API response
2. Call `onEndReached` when threshold hit
3. Show footer loading indicator while fetching
4. Append new items to data

### Usage Example

```tsx
<List
  data={tasks}
  renderItem={(task) => <TaskCard task={task} onPress={() => {}} />}
  keyExtractor={(task) => task.id}
  onEndReached={loadMoreTasks}
  refreshing={isRefreshing}
  onRefresh={handleRefresh}
  ListEmptyComponent={<EmptyState message="No tasks available" />}
  ListFooterComponent={isLoadingMore ? <ActivityIndicator /> : null}
/>
```

---

## 12. ProgressBar

**Import:** `import { ProgressBar } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `progress` | `number` | - | YES | Progress 0-1 |
| `variant` | `'default' \| 'xp' \| 'level'` | `'default'` | NO | Color variant |
| `height` | `number` | `4` | NO | Bar height |
| `showLabel` | `boolean` | `false` | NO | Show percentage |
| `animated` | `boolean` | `true` | NO | Animate changes |

### Variants

| Variant | Fill Color | Track Color |
|---------|------------|-------------|
| `default` | `GRAY[900]` | `GRAY[200]` |
| `xp` | `XP.PRIMARY` (#10B981) | `GRAY[200]` |
| `level` | `XP.SECONDARY` (#34D399) | `XP.BACKGROUND` |

### Animation

- Duration: 300ms (default) or instant if `!animated`
- Respects `prefers-reduced-motion`

### Usage Example

```tsx
<ProgressBar
  progress={0.65}
  variant="xp"
  height={8}
  showLabel
/>
```

---

## 13. Skeleton

**Import:** `import { Skeleton } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `variant` | `'text' \| 'avatar' \| 'card' \| 'button' \| 'rect'` | `'text'` | NO | Shape variant |
| `width` | `number \| string` | Per variant | NO | Width |
| `height` | `number` | Per variant | NO | Height |
| `borderRadius` | `number` | Per variant | NO | Corner radius |

### Variant Defaults

| Variant | Width | Height | Border Radius |
|---------|-------|--------|---------------|
| `text` | `75%` | 16px | 4px |
| `avatar` | 48px | 48px | 24px (full) |
| `card` | `100%` | 120px | 12px |
| `button` | `100%` | 44px | 8px |
| `rect` | `100%` | 40px | 8px |

### Shimmer Animation

- Direction: left to right
- Duration: 1500ms
- Easing: linear
- Respects `prefers-reduced-motion` (static gray if reduced)

### Usage Example

```tsx
{isLoading ? (
  <>
    <Skeleton variant="avatar" />
    <Skeleton variant="text" width="60%" />
    <Skeleton variant="text" width="80%" />
  </>
) : (
  <UserInfo user={user} />
)}
```

---

## 14. Toast

**Import:** `import { useToast } from '@/hooks'`

### Hook API

```typescript
const toast = useToast();

toast.show({
  message: string;
  variant?: 'default' | 'success' | 'error' | 'warning';
  duration?: number; // ms, default 3000
  action?: {
    label: string;
    onPress: () => void;
  };
});

toast.dismiss();
```

### Variants

| Variant | Icon | Background |
|---------|------|------------|
| `default` | Info | `GRAY[800]` |
| `success` | Check | `#065F46` |
| `error` | X | `#991B1B` |
| `warning` | Alert | `#92400E` |

### Position

- Bottom of screen, above tab bar
- 16px horizontal margin
- 8px above safe area

### Animation

- Slide up 50px + fade in (200ms)
- Auto-dismiss after `duration`
- Swipe to dismiss

### Usage Example

```tsx
const toast = useToast();

const handleSave = async () => {
  try {
    await saveTask();
    toast.show({ message: 'Task saved', variant: 'success' });
  } catch (error) {
    toast.show({
      message: 'Failed to save',
      variant: 'error',
      action: { label: 'Retry', onPress: handleSave }
    });
  }
};
```

---

## 15. TabBar

**Note:** Use React Navigation's `createBottomTabNavigator`

### Custom Tab Bar Props

| Prop | Type | Description |
|------|------|-------------|
| `state` | `TabNavigationState` | Navigation state |
| `descriptors` | `TabDescriptors` | Screen descriptors |
| `navigation` | `TabNavigation` | Navigation object |

### Tab Configuration

| Tab | Label | Icon | Badge |
|-----|-------|------|-------|
| Home | Home | `Home` (lucide) | - |
| Tasks | Tasks | `ClipboardList` | Unread count |
| Wallet | Wallet | `Wallet` | - |
| Profile | Profile | `User` | Verification needed |

### Styling

- Height: 49px (iOS) / 56px (Android)
- Active color: `GRAY[900]`
- Inactive color: `GRAY[400]`
- Background: White
- Top border: `GRAY[200]` 1px

---

## 16. Header

**Import:** `import { Header } from '@/components'`

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `title` | `string` | - | NO | Screen title |
| `showBack` | `boolean` | `false` | NO | Show back button |
| `onBack` | `() => void` | - | NO | Back handler |
| `rightAction` | `ReactNode` | - | NO | Right action button |
| `transparent` | `boolean` | `false` | NO | Transparent background |

### Structure

```
┌─────────────────────────────────────────────────┐
│ [←]    Title                      [RightAction] │
└─────────────────────────────────────────────────┘
```

### Styling

- Height: 44px + status bar
- Background: White (or transparent)
- Title: `h4` centered
- Back button: 44×44 touch target

---

## 17. FirstXPCelebration

**Reference:** `reference/components/FirstXPCelebration.js`
**AUTHORITY:** ONBOARDING_SPEC §13.4, UI_SPEC §12.4

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `xpAmount` | `number` | - | YES | XP awarded |
| `levelProgress` | `number` | - | YES | Progress 0-1 |
| `badgeUnlocked` | `Badge \| null` | - | NO | Badge if earned |
| `onComplete` | `() => void` | - | NO | Completion callback |
| `reducedMotion` | `boolean` | `false` | NO | Skip animations |

### Animation Sequence (2000ms max)

| Time | Element | Animation |
|------|---------|-----------|
| 0-300ms | XP number | Fade in + scale 1.0→1.1→1.0 |
| 300-800ms | Progress bar | Linear fill |
| 800-1200ms | Message | Fade in "First Task Complete!" |
| 1200-1800ms | Badge | Fade in (if unlocked) |
| 1800-2000ms | All | Settle to static |

### Constraints

- NO confetti
- NO sound
- NO shake/vibrate
- Server-tracked: `xp_first_celebration_shown_at`
- Reduced motion: All instant

### Trigger Conditions

- `xp_first_celebration_shown_at` IS NULL
- AND first XP awarded
- AND user role = 'worker' OR 'dual'

---

## 18. LockedGamificationUI

**Reference:** `reference/components/LockedGamificationUI.js`
**AUTHORITY:** ONBOARDING_SPEC §13.3

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `currentLevel` | `number` | `1` | NO | Locked level display |
| `streakCount` | `number` | `0` | NO | Locked streak display |
| `lockedBadgeCount` | `number` | `3` | NO | Badge silhouettes |

### Visual

```
┌─────────────────────────────────────────────┐
│        0 XP (grayed out)                    │
│        Level 1 • Locked                     │
│                                             │
│   [─────────────────────] 0%               │
│                                             │
│   🔒 Streak: Inactive                       │
│                                             │
│   [🔒] [🔒] [🔒] (badge silhouettes)       │
│                                             │
│   Unlocks after first task                  │
└─────────────────────────────────────────────┘
```

### Constraints

- NO animations
- NO celebrations
- NO unlocked visuals
- All XP colors replaced with `GRAY[400]`

---

## 19. MoneyTimeline

**Reference:** `reference/components/MoneyTimeline.js`
**AUTHORITY:** UI_SPEC §14

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `availableNow` | `number` | - | YES | Withdrawable amount (cents) |
| `todayReleases` | `MoneyTimelineEntry[]` | - | YES | Today's releases |
| `comingSoon` | `MoneyTimelineEntry[]` | - | YES | Pending escrows |
| `blocked` | `MoneyTimelineEntry[]` | - | YES | Disputed funds |

### Structure

```
┌─────────────────────────────────────────────┐
│ AVAILABLE NOW                               │
│ $127.50 (green, large)                      │
├─────────────────────────────────────────────┤
│ TODAY                                       │
│ + $21.25  Couch move — Released 2:34 PM    │
│ + $15.00  Grocery pickup — Released 11:20   │
├─────────────────────────────────────────────┤
│ COMING SOON                                 │
│ + $40.00  Deep cleaning — In escrow        │
│ + $25.00  Package delivery — In escrow     │
├─────────────────────────────────────────────┤
│ BLOCKED                                     │
│ ⚠️ $15.00  Furniture assembly — Under review │
└─────────────────────────────────────────────┘
```

### Color Mapping

| Section | Color |
|---------|-------|
| AVAILABLE NOW | `MONEY.POSITIVE` (#10B981) |
| TODAY | `MONEY.POSITIVE` (#10B981) |
| COMING SOON | `MONEY.LOCKED` (#F59E0B) |
| BLOCKED | `MONEY.NEGATIVE` (#EF4444) |

### Constraints

- NO charts or graphs
- NO vague language ("Pending", "Processing")
- NO gambling visuals

---

## 20. FailureRecovery

**Reference:** `reference/components/FailureRecovery.js`
**AUTHORITY:** UI_SPEC §15

### Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `whatHappened` | `string` | - | YES | Clear explanation |
| `impact` | `string` | - | YES | Concrete consequences |
| `whatYouCanDo` | `string[]` | - | YES | Specific actions |
| `recoveryPath` | `string` | - | NO | Hope/next steps |
| `onRetry` | `() => void` | - | NO | Retry action |
| `onDismiss` | `() => void` | - | NO | Dismiss action |

### Structure

```
┌─────────────────────────────────────────────┐
│ WHAT HAPPENED                               │
│ {whatHappened}                              │
├─────────────────────────────────────────────┤
│ IMPACT                                      │
│ {impact}                                    │
├─────────────────────────────────────────────┤
│ WHAT YOU CAN DO                             │
│ • {whatYouCanDo[0]}                         │
│ • {whatYouCanDo[1]}                         │
├─────────────────────────────────────────────┤
│ {recoveryPath}                              │
│                                             │
│ [Retry]  [Dismiss]                          │
└─────────────────────────────────────────────┘
```

### Forbidden Copy

- NO shame language ("You failed", "Your fault")
- NO punitive language ("Penalty", "Punished")
- NO vague impact ("Consequences", "Action taken")
- NO passive aggressive ("Unfortunately", "Regrettably")

---

## 21. LiveModeUI

**Reference:** `reference/components/LiveModeUI.js`
**AUTHORITY:** UI_SPEC §13

### LiveTaskCard Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `broadcast` | `LiveTaskBroadcast` | - | YES | Broadcast data |
| `onAccept` | `() => void` | - | YES | Accept handler |
| `onDecline` | `() => void` | - | YES | Decline handler |
| `onSkip` | `() => void` | - | NO | Skip handler |

### Structure

```
┌─────────────────────────────────────────────┐
│ 🔴 LIVE                                     │
├─────────────────────────────────────────────┤
│ Task title                                  │
│ Poster name • VERIFIED                      │
│                                             │
│ 💰 $35.00 (you receive ~$29.75)             │
│ 📍 1.2 miles away                           │
│ ✅ Escrow: FUNDED                           │
│                                             │
│ [Accept Task]                               │
└─────────────────────────────────────────────┘
```

### LiveModeToggle Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `state` | `LiveModeState` | - | YES | Current state |
| `session` | `LiveModeSession \| null` | - | NO | Active session |
| `onToggle` | `() => void` | - | YES | Toggle handler |
| `cooldownEndsAt` | `string \| null` | - | NO | Cooldown timestamp |

### Constraints

- Red "🔴 LIVE" badge always visible
- Escrow state always visible
- Distance always visible
- Clear price breakdown
- NO countdown timers
- NO urgency copy ("Act now!", "Hurry!")
- NO pulsing/flashing animations

---

## Usage in Cursor

When implementing screens, import components from the library:

```tsx
import {
  Button,
  Card,
  HXText,
  Input,
  Avatar,
  TaskCard,
  List,
  Modal,
  BottomSheet,
} from '@/components';

import type {
  ButtonProps,
  TaskSummary,
  FeedTask,
} from '@/types';
```

**CRITICAL:** Do not invent props or behaviors not specified in this document. If a prop is not listed, it does not exist.

---

**END OF COMPONENT LIBRARY**
