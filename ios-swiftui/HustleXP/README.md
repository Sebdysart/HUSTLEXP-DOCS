# HustleXP iOS SwiftUI Package

Production-ready SwiftUI screens converted from STITCH HTML specifications.

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

Add the package to your Xcode project via Swift Package Manager:

```swift
dependencies: [
    .package(path: "./ios-swiftui/HustleXP")
]
```

## Usage

```swift
import HustleXP

// Use any screen
InstantInterruptCard(
    task: InstantTaskData(
        title: "Move furniture",
        distance: "0.8 mi",
        amount: 45.00
    ),
    onAccept: { /* handle */ },
    onSkip: { /* handle */ }
)
```

## Screens (15 Total)

### Core Screens
| Screen | Source | Description |
|--------|--------|-------------|
| `InstantInterruptCard` | 01-instant-interrupt-card.html | Full-screen instant task alert with timer |
| `HustlerHomeScreen` | 02-hustler-home.html | Main dashboard with XP ring, stats, instant mode |
| `TrustTierLadderScreen` | 06-trust-tier-ladder.html | Trust tier progression view |
| `TaskInProgressScreen` | 08-hustler-task-in-progress.html | Active task with steps and proof capture |
| `XPBreakdownScreen` | 07-xp-breakdown.html | XP breakdown with bonuses and multipliers |

### Task Completion (Hustler)
| Screen | Source | Description |
|--------|--------|-------------|
| `TaskCompletionApprovedScreen` | 09-hustler-task-completion-APPROVED.html | Success state with XP earned |
| `TaskCompletionActionRequiredScreen` | 09-hustler-task-completion-ACTION-REQUIRED.html | Proof rejected, needs resubmission |
| `TaskCompletionBlockedScreen` | 09-hustler-task-completion-BLOCKED.html | Final rejection state |

### Task Completion (Poster)
| Screen | Source | Description |
|--------|--------|-------------|
| `PosterTaskCompletionScreen` | 10-poster-task-completion-FIXED.html | Poster's view of completed task |

### Trust & System
| Screen | Source | Description |
|--------|--------|-------------|
| `TrustChangeExplanationScreen` | 12-trust-change-explanation-FIXED.html | Task impact on trust and XP |

### Disputes
| Screen | Source | Description |
|--------|--------|-------------|
| `DisputeEntryScreen` | 13-dispute-entry-*.html | Dispute filing for hustler/poster |

### Edge States
| Screen | Source | Description |
|--------|--------|-------------|
| `NoTasksAvailableScreen` | E1-no-tasks-available.html | Empty feed state |
| `EligibilityMismatchScreen` | E2-eligibility-mismatch.html | Why you can't see a task |
| `TrustTierLockedScreen` | E3-trust-tier-locked.html | Tier locked with progress |

## Design System

### Colors (HustleColors.swift)
```swift
Color.hustlePrimary      // #1FAD7E - Teal green
Color.hustleYellow       // #FFD900 - Instant mode
Color.appleRed           // #FF3B30 - Errors
Color.appleOrange        // #FF9500 - Warnings, XP
Color.appleGreen         // #34C759 - Success
Color.appleBlue          // #007AFF - Info, links
Color.glassSurface       // Glass panel background
```

### Typography (HustleTypography.swift)
```swift
HustleFont.display()     // 36px - Hero text
HustleFont.title1()      // 28px - Main titles
HustleFont.title2()      // 24px - Section headers
HustleFont.title3()      // 20px - Subsections
HustleFont.headline()    // 18px - Emphasized body
HustleFont.body()        // 16px - Primary content
HustleFont.caption()     // 12px - Labels
HustleFont.micro()       // 10px - Tiny labels
```

### Components (HustleComponents.swift)
- `GlassCard` - Glassmorphism container
- `PrimaryButton` - Full-width action button
- `SecondaryButton` - Text-only secondary action
- `HustleBadge` - Pill-shaped badge
- `ProgressRing` - Circular progress indicator
- `StatusIndicator` - Pulsing status dot
- `HustleDivider` - Styled divider
- `StepIndicator` - Task step with completion state

## Preview Catalog

In debug builds, use `HustleXPCatalog` to browse all screens:

```swift
#Preview {
    HustleXPCatalog()
}
```

## Architecture

Each screen follows the contract pattern:
1. **Data Model** - Public struct with all required props
2. **View** - Public SwiftUI View with data + callbacks
3. **Preview** - Sample data for Xcode previews

Screens are stateless and receive all data via initializers. State management is handled by the parent app.

## Source Authority

All screens are converted from STITCH HTML specifications. This package is tracked in the main documentation ecosystem.

| Spec Location | Contents |
|---------------|----------|
| `specs/03-frontend/DESIGN_SYSTEM.md` | Color tokens, typography, spacing |
| `specs/03-frontend/stitch-prompts/*.html` | Screen-by-screen HTML specs |
| `screens-spec/SCREEN_REGISTRY.md` | Master screen inventory (§11 for iOS) |
| `specs/03-frontend/STITCH_INVENTORY.md` | STITCH file tracking (iOS column) |

### Spec Compliance

This package implements screens exactly as specified in STITCH HTML files.
Any deviation from STITCH spec is a bug.

### Build Verification
```bash
cd ios-swiftui/HustleXP && swift build
```

Build date: 2025-01-22
