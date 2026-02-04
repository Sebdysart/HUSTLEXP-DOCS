# HustleXP iOS SwiftUI Package

Production-ready SwiftUI screens converted from STITCH HTML specifications.

## Requirements

- iOS 17.0+
- macOS 14.0+ (for Mac Catalyst / previews)
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../ios-swiftui/HustleXP")
]
```

Or in Xcode: File → Add Package Dependencies → Add Local...

## Implemented Screens (7/15)

### Core Screens

| Screen | Source | Status |
|--------|--------|--------|
| `InstantInterruptCard` | 01-instant-interrupt-card.html | ✅ Complete |
| `HustlerHomeScreen` | 02-hustler-home.html | ✅ Complete |
| `TrustTierLadderScreen` | 06-trust-tier-ladder.html | ✅ Complete |
| `TaskInProgressScreen` | 08-hustler-task-in-progress.html | ✅ Complete |

### Edge States

| Screen | Source | Status |
|--------|--------|--------|
| `NoTasksAvailableScreen` | E1-no-tasks-available.html | ✅ Complete |
| `EligibilityMismatchScreen` | E2-eligibility-mismatch.html | ✅ Complete |
| `TrustTierLockedScreen` | E3-trust-tier-locked.html | ✅ Complete |

### Pending (8)

| Screen | Source |
|--------|--------|
| XP Breakdown | 07-xp-breakdown.html |
| Task Completion (Approved) | 09-hustler-task-completion-APPROVED.html |
| Task Completion (Action Required) | 09-hustler-task-completion-ACTION-REQUIRED.html |
| Task Completion (Blocked) | 09-hustler-task-completion-BLOCKED.html |
| Poster Task Completion | 10-poster-task-completion-FIXED.html |
| Trust Change Explanation | 12-trust-change-explanation-FIXED.html |
| Dispute Entry (Hustler) | 13-dispute-entry-hustler-FIXED.html |
| Dispute Entry (Poster) | 13-dispute-entry-poster-FIXED.html |

## Usage

### Import the Package

```swift
import HustleXP
```

### Using Screens

All screens follow the same pattern:
- Data model (props from parent)
- `isLoading` state
- Action callbacks (no logic inside)

```swift
struct ContentView: View {
    @State private var taskData: InstantTaskData?
    @State private var isLoading = true

    var body: some View {
        InstantInterruptCard(
            task: taskData,
            isLoading: isLoading,
            onAccept: { handleAccept() },
            onSkip: { handleSkip() }
        )
    }
}
```

### Screen Catalog (Debug)

Preview all screens in Xcode:

```swift
#Preview {
    HustleXPCatalog()
}
```

## Design System

### Colors

```swift
// Primary
Color.hustlePrimary        // #1FAD7E (teal green)
Color.hustleYellow         // #FFD900 (instant mode)

// Apple System Colors
Color.appleRed             // #FF3B30
Color.appleOrange          // #FF9500
Color.appleGreen           // #34C759
Color.appleBlue            // #007AFF
Color.appleGray            // #8E8E93

// Glass Surfaces
Color.glassSurface         // Dark with 80% opacity
Color.glassBorder          // White at 10% opacity
```

### Typography

```swift
HustleFont.display()       // 36px bold
HustleFont.title1()        // 28px bold
HustleFont.title2()        // 24px semibold
HustleFont.headline()      // 18px semibold
HustleFont.body()          // 16px regular
HustleFont.callout()       // 14px regular
HustleFont.caption()       // 12px medium
HustleFont.micro()         // 10px semibold
```

### Components

```swift
// Glass card container
GlassCard(cornerRadius: 24) {
    // Content
}

// Primary action button
PrimaryButton("ACCEPT", color: .appleGreen) {
    // Action
}

// Badge/chip
HustleBadge("+1.8× XP", color: .appleOrange)

// Progress ring
ProgressRing(progress: 0.75, size: 96)

// Step indicator
StepIndicator(title: "Upload proof", state: .current)
```

## Architecture

Each screen follows the HustleXP contract pattern:

```swift
public struct ScreenName: View {
    // Props (data comes from parent)
    let data: DataType?
    let isLoading: Bool
    let onAction: () -> Void

    public var body: some View {
        if isLoading {
            loadingState
        } else if let data = data {
            contentState(data: data)
        } else {
            emptyState
        }
    }
}
```

**Rules:**
- Screens receive data as props, never fetch
- All business logic stays in parent/coordinator
- Callbacks passed as closures, no logic inside
- Three states: loading, empty, content

## Source

Converted from STITCH HTML specifications in:
```
specs/03-frontend/stitch-prompts/
```

Design tokens from:
```
specs/03-frontend/tokens/
```

## Version

- Package Version: 1.0.0
- Build Date: 2025-01-22
- Source: STITCH HTML Specifications
