# Atoms — Layer 1

> **Visual primitives. Single responsibility. Zero context.**

Atoms are the smallest visual building blocks. Each atom does ONE thing and does it perfectly.

---

## Available Atoms

| Atom | Responsibility | Used In |
|------|---------------|---------|
| `AnimatedMeshField` | Drifting gradient background | MarketField molecule |
| `GlowOrb` | Pulsing glow effect | BrandCluster molecule |
| `NoiseOverlay` | Grain texture overlay | MarketField molecule |
| `ParticleField` | Floating particles | MarketField molecule |
| `BrandMark` | The "H" logo | BrandCluster molecule |
| `PrimaryCTA` | Main action button | CTAStack molecule |
| `MotionFadeIn` | Entrance animation wrapper | Any molecule |
| `TypeReveal` | Text animation | ValueStatement molecule |

---

## Rules

1. **Single responsibility** — Each atom does ONE thing
2. **No context** — Atoms work in isolation, no parent dependencies
3. **Token-only** — All values must come from tokens
4. **No imports** — Atoms cannot import other atoms
5. **Stress test required** — Must pass before use in molecules

---

## Folder Structure

```
atoms/
├── AtomName/
│   ├── AtomName.swift       # Implementation
│   ├── AtomName.stress.md   # Stress test results
│   └── AtomName.snapshot.png # Visual reference (after lock)
```

---

## Stress Test Protocol

Before an atom can be used in a molecule:

```markdown
## Atom Stress Test: [AtomName]

### Isolation Test
- [ ] Renders correctly with no parent context
- [ ] Works on pure black background
- [ ] Works on pure white background
- [ ] No hardcoded values (all from tokens)

### Performance Test
- [ ] 60fps on iPhone 12
- [ ] No memory leaks in animation loop
- [ ] TimelineView efficiency (if animated)

### Accessibility Test
- [ ] Sufficient contrast (WCAG AA)
- [ ] Respects reduced motion setting
```

---

## Creating a New Atom

1. Create folder: `atoms/NewAtomName/`
2. Implement in `NewAtomName.swift`
3. Create `NewAtomName.stress.md`
4. Run stress tests
5. Get approval
6. Add to COMPLETION_LOCK.md
