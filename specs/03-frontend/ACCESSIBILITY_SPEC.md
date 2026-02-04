# ACCESSIBILITY SPECIFICATION

**Authority:** COMPONENT_LIBRARY.md | DESIGN_SYSTEM.md
**Status:** v1.0 — Launch-ready specification
**Standard:** WCAG 2.1 Level AA

---

## §1. Core Requirements

### 1.1 Touch Targets
- Minimum touch target: 44×44 points (iOS) / 48×48dp (Android)
- Spacing between targets: minimum 8 points
- Enforced via COMPONENT_LIBRARY atom sizing

### 1.2 Color Contrast
- Text on background: minimum 4.5:1 ratio (AA)
- Large text (18pt+): minimum 3:1 ratio
- Interactive elements: minimum 3:1 against adjacent colors
- DESIGN_SYSTEM colors must pass contrast checker before use

### 1.3 Text Scaling
- Support Dynamic Type (iOS) and font scaling (Android) up to 200%
- No text truncation at 150% scale — layout must reflow
- Fixed-size containers that clip text are prohibited

### 1.4 Screen Reader Support
- Every interactive element has `accessibilityLabel`
- Every image has `accessibilityLabel` (decorative images: `accessibilityElementsHidden={true}`)
- Form inputs have `accessibilityHint` describing expected input
- State changes announced via `accessibilityLiveRegion="polite"`

---

## §2. Per-Screen Focus Order

Focus order follows visual reading order (top-to-bottom, left-to-right) with these priorities:
1. Navigation/header actions
2. Primary content area
3. Action buttons (bottom)
4. Secondary/tertiary actions

**Critical screens:**
| Screen | Focus Order |
|---|---|
| H2-task-feed | Filter bar → first task card → subsequent cards → tab bar |
| H4-task-detail | Back button → task title → details → accept button |
| H5-active-task | Status header → map → proof button → chat button |
| O-series (onboarding) | Progress indicator → heading → content → continue button |

---

## §3. Motion & Animation

- Respect `prefers-reduced-motion` / `UIAccessibilityIsReduceMotionEnabled`
- When reduced motion enabled: disable parallax, crossfade instead of slide, no auto-playing animations
- Map animations: reduce to instant transitions when reduced motion enabled
- Loading states: use static spinner instead of animated skeleton screens

---

## §4. Error & Status Communication

- Errors announced to screen readers immediately (live region)
- Error states include both color AND icon/text indicator (never color alone)
- Success states include both visual and haptic feedback
- Form validation errors appear adjacent to the invalid field, not just at top of form

---

## §5. Testing Protocol

| Test | Tool | Frequency |
|---|---|---|
| VoiceOver walkthrough (iOS) | Manual | Every new screen |
| TalkBack walkthrough (Android) | Manual | Every new screen |
| Color contrast | Stark or aXe | Every design change |
| Touch target audit | Manual measurement | Every component change |
| Dynamic Type test | Simulator 200% | Every layout change |
| Keyboard navigation (web admin) | Manual | Every admin screen |

---

## §6. Enforcement

- PR checklist includes accessibility verification
- `accessibilityLabel` required on all `Pressable`/`TouchableOpacity` components (ESLint rule)
- Missing accessibility props = build warning (not error for v1, error for v2)

---

**END OF ACCESSIBILITY_SPEC v1.0.0**
