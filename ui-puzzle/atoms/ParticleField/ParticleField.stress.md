# Atom Stress Test: ParticleField

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
| Default color | `PuzzleColors.brandPurpleLight` | ✓ |

---

## Performance Test

- [ ] 60fps on iPhone 12
- [ ] No memory leaks in animation loop
- [ ] Canvas renders efficiently at 20fps

### Measurements
| Metric | Target | Actual |
|--------|--------|--------|
| Frame rate | 20fps+ | — |
| CPU usage | <8% | — |
| Particle count | 18 (default) | ✓ |

---

## Accessibility Test

- [ ] Does not interfere with content readability
- [ ] Respects reduced motion setting

### Reduced Motion Handling
```swift
ParticleField(animated: !UIAccessibility.isReduceMotionEnabled)
```

---

## Visual Verification

- [ ] Particles are tiny (1-3pt)
- [ ] Drift is slow and smooth
- [ ] Fade at edges works correctly
- [ ] No visible patterns

---

## Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Developer | — | — | — |
| Design Review | — | — | — |
