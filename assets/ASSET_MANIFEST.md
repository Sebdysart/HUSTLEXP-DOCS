# HustleXP Asset Manifest

**STATUS:** Required Assets for Frontend Build
**VERSION:** 1.0.0

This manifest lists ALL required image assets. Cursor should use these paths.
For development, placeholder SVGs are provided. Replace with production assets before launch.

---

## Directory Structure

```
assets/
├── icon.png                    # App icon (1024x1024)
├── adaptive-icon.png           # Android adaptive icon (1024x1024)
├── splash-icon.png             # Splash screen icon (200x200)
├── favicon.png                 # Web favicon (48x48)
│
├── images/
│   ├── logo.png                # HustleXP logo (300x80)
│   ├── logo-dark.png           # Logo for dark backgrounds
│   └── wordmark.png            # Text-only logo
│
├── placeholders/
│   ├── avatar.svg              # Default user avatar
│   ├── task-image.svg          # Default task image
│   └── photo.svg               # Generic photo placeholder
│
├── illustrations/
│   ├── empty-tasks.svg         # No tasks available state
│   ├── empty-wallet.svg        # No earnings yet state
│   ├── empty-messages.svg      # No messages state
│   ├── onboarding-welcome.svg  # Onboarding frame 1
│   ├── onboarding-earn.svg     # Onboarding frame 2
│   ├── onboarding-trust.svg    # Onboarding frame 3
│   ├── success.svg             # Generic success state
│   ├── error.svg               # Generic error state
│   └── offline.svg             # Network offline state
│
└── badges/
    ├── first-task.svg          # First task completed
    ├── streak-7.svg            # 7-day streak
    ├── streak-30.svg           # 30-day streak
    ├── streak-100.svg          # 100-day streak
    ├── level-5.svg             # Level 5 reached
    ├── level-10.svg            # Level 10 reached
    ├── verified.svg            # Account verified
    ├── trusted.svg             # Trusted tier achieved
    ├── elite.svg               # Elite tier achieved
    └── locked.svg              # Locked badge silhouette
```

---

## Asset Specifications

### App Icons

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| icon.png | 1024x1024 | PNG | Square, no transparency |
| adaptive-icon.png | 1024x1024 | PNG | Android, with safe zone |
| splash-icon.png | 200x200 | PNG | Centered on splash |
| favicon.png | 48x48 | PNG | Web only |

### Logos

| Asset | Size | Format | Background |
|-------|------|--------|------------|
| logo.png | 300x80 | PNG | Transparent |
| logo-dark.png | 300x80 | PNG | For dark backgrounds |
| wordmark.png | 200x40 | PNG | Text only |

### Placeholders

| Asset | Size | Format | Use Case |
|-------|------|--------|----------|
| avatar.svg | 200x200 | SVG | Default user avatar |
| task-image.svg | 400x300 | SVG | Task without image |
| photo.svg | 400x400 | SVG | Failed image load |

### Illustrations

| Asset | Size | Format | Use Case |
|-------|------|--------|----------|
| empty-tasks.svg | 240x180 | SVG | No tasks in feed |
| empty-wallet.svg | 240x180 | SVG | No earnings |
| empty-messages.svg | 240x180 | SVG | No messages |
| onboarding-*.svg | 300x300 | SVG | Onboarding screens |
| success.svg | 120x120 | SVG | Success feedback |
| error.svg | 120x120 | SVG | Error feedback |
| offline.svg | 240x180 | SVG | No network |

### Badges

| Asset | Size | Format | Tier |
|-------|------|--------|------|
| first-task.svg | 80x80 | SVG | Achievement |
| streak-*.svg | 80x80 | SVG | Milestone |
| level-*.svg | 80x80 | SVG | Level |
| verified.svg | 80x80 | SVG | Verification |
| trusted.svg | 80x80 | SVG | Trust tier 3 |
| elite.svg | 80x80 | SVG | Trust tier 4 |
| locked.svg | 80x80 | SVG | Unearned badge |

---

## Import Pattern

```typescript
// Static imports for bundled assets
import logo from '@/assets/images/logo.png';
import defaultAvatar from '@/assets/placeholders/avatar.svg';
import emptyTasks from '@/assets/illustrations/empty-tasks.svg';
import firstTaskBadge from '@/assets/badges/first-task.svg';

// For SVG, use react-native-svg-transformer
// Add to metro.config.js and babel.config.js
```

---

## Color Palette for Placeholders

When generating placeholder graphics, use these colors:

| Element | Color | Hex |
|---------|-------|-----|
| Background | Gray 100 | #F3F4F6 |
| Primary shape | Gray 300 | #D1D5DB |
| Secondary shape | Gray 200 | #E5E7EB |
| Accent | Primary 500 | #10B981 |
| Text | Gray 500 | #6B7280 |

---

## SVG Template

All SVG placeholders follow this structure:

```xml
<svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="200" rx="100" fill="#F3F4F6"/>
  <!-- Content here -->
</svg>
```

---

**END OF ASSET MANIFEST**
