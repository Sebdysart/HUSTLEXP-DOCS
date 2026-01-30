# Atom Stress Test: GlowOrb

**Status:** PENDING
**Last Tested:** —
**Tester:** —

---

## Isolation Test

- [ ] Renders correctly with no parent context
- [ ] Works on pure black background
- [ ] Works on pure white background
- [ ] No hardcoded values (all from tokens)

### Token Compliance
| Value | Token Used | Status |
|-------|------------|--------|
| Default color | `PuzzleColors.brandPurple` | ✓ |
| Scale effect | `PuzzleMotion.scaleSubtle` | ✓ |
| Animation | `PuzzleAnimation.breathe` | ✓ |

---

## Performance Test

- [ ] 60fps on iPhone 12
- [ ] No memory leaks in animation loop
- [ ] Blur performance acceptable

### Measurements
| Metric | Target | Actual |
|--------|--------|--------|
| Frame rate | 60fps | — |
| CPU usage | <5% | — |
| GPU usage | <15% | — |

---

## Accessibility Test

- [ ] Sufficient contrast (WCAG AA)
- [ ] Respects reduced motion setting

### Reduced Motion Handling
```swift
GlowOrb(animated: !UIAccessibility.isReduceMotionEnabled)
```

---

## Visual Verification

- [ ] Pulse is smooth, not jarring
- [ ] Colors match brand specification
- [ ] Blur is soft, no hard edges
- [ ] Scale effect is subtle

---

## Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Developer | — | — | — |
| Design Review | — | — | — |
