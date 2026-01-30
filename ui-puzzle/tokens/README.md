# Tokens — Layer 0

> **Zero-decision primitives. READ-ONLY.**

Tokens are the raw design values that everything else is built from. They contain **no creative decisions** — just values.

---

## Files

| File | Contains |
|------|----------|
| `colors.swift` | All color definitions |
| `typography.swift` | Font sizes, weights, line heights |
| `spacing.swift` | Padding, margins, gaps, radii |
| `motion.swift` | Durations, easings, delays |
| `shadows.swift` | Shadow and glow definitions |

---

## Rules

1. **READ-ONLY** — Cursor cannot create, modify, or delete tokens
2. **Source of truth** — Every visual value must trace to a token
3. **No exceptions** — If a value doesn't exist as a token, it cannot be used

---

## Usage

```swift
// CORRECT: Using tokens
Text("Hello")
    .font(PuzzleTypography.headline())
    .foregroundColor(PuzzleColors.textPrimary)
    .padding(PuzzleSpacing.lg)

// FORBIDDEN: Hardcoded values
Text("Hello")
    .font(.system(size: 18, weight: .semibold))  // ❌
    .foregroundColor(.white)                       // ❌
    .padding(16)                                   // ❌
```

---

## Adding New Tokens

New tokens require:
1. PER approval
2. Addition to the appropriate token file
3. Documentation of use case
4. Update to COMPLETION_LOCK.md

Cursor is **never** allowed to add tokens. Only humans can modify this layer.
