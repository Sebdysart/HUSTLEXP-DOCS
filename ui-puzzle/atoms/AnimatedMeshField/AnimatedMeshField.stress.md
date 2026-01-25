# Atom Stress Test: AnimatedMeshField

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
| Base color | `PuzzleColors.backgroundDeep` | ✓ |
| Accent color | `PuzzleColors.brandPurple` | ✓ |
| Ambient blur | `PuzzleShadows.Values.ambientBlur` | ✓ |
| Accent blur | `PuzzleShadows.Values.accentBlur` | ✓ |
| Highlight blur | `PuzzleShadows.Values.highlightBlur` | ✓ |
| Drift speed | `PuzzleMotion.meshDrift` | ✓ |
| Frame interval | `PuzzleMotion.frameInterval` | ✓ |
| Amplitude | `PuzzleMotion.amplitudeMedium` | ✓ |
| Opacities | `PuzzleShadows.MeshOpacity.*` | ✓ |

---

## Performance Test

- [ ] 60fps on iPhone 12
- [ ] No memory leaks in animation loop
- [ ] TimelineView efficiency

### Measurements
| Metric | Target | Actual |
|--------|--------|--------|
| Frame rate | 60fps | — |
| CPU usage | <10% | — |
| Memory growth | 0 | — |

---

## Accessibility Test

- [ ] Sufficient contrast (WCAG AA)
- [ ] Respects reduced motion setting

### Reduced Motion Handling
The `animated` parameter allows disabling animation when `UIAccessibility.isReduceMotionEnabled` is true.

```swift
AnimatedMeshField(animated: !UIAccessibility.isReduceMotionEnabled)
```

---

## Visual Verification

- [ ] No visible shapes (smooth blend)
- [ ] Drift is subtle, not distracting
- [ ] Colors match brand specification
- [ ] No jarring transitions

---

## Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Developer | — | — | — |
| Design Review | — | — | — |

---

## Notes

_Add any observations or issues found during testing._
