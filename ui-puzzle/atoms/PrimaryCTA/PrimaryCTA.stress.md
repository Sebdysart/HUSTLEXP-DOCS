# Atom Stress Test: PrimaryCTA

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
| Font | `PuzzleTypography.ctaText()` | ✓ |
| Text color | `PuzzleColors.textPrimary` | ✓ |
| Height | `PuzzleSpacing.buttonHeight` | ✓ |
| Corner radius | `PuzzleSpacing.buttonRadius` | ✓ |
| Press scale | `PuzzleMotion.scalePress` | ✓ |
| Animation | `PuzzleAnimation.press` | ✓ |
| Shadow values | `PuzzleShadows.Values.purple*` | ✓ |

---

## Performance Test

- [ ] Press animation is smooth
- [ ] No layout jumps on press

### Measurements
| Metric | Target | Actual |
|--------|--------|--------|
| Press response | <50ms | — |
| Animation smoothness | 60fps | — |

---

## Accessibility Test

- [ ] Button is tappable (min 44pt)
- [ ] Text is readable
- [ ] Works with VoiceOver

---

## Visual Verification

- [ ] Glow is soft, not harsh
- [ ] Press effect is noticeable but subtle
- [ ] Full-width layout works
- [ ] Corner radius matches design

---

## Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Developer | — | — | — |
| Design Review | — | — | — |
