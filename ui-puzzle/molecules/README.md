# Molecules — Layer 2

> **Semantic combinations. Atom assemblies. No screen logic.**

Molecules combine atoms into meaningful units. They have semantic purpose but no screen-level logic.

---

## Available Molecules

| Molecule | Atoms Used | Purpose |
|----------|-----------|---------|
| `BrandCluster` | BrandMark, GlowOrb, MotionFadeIn | Logo with glow and entrance |
| `CTAStack` | PrimaryCTA, MotionFadeIn | Button with secondary link |
| `MarketField` | AnimatedMeshField, ParticleField, NoiseOverlay | Premium animated background |

---

## Rules

1. **Approved atoms only** — Can only use atoms that passed stress tests
2. **No screen logic** — No full-screen layout, navigation, or state management
3. **Composition contract required** — Must declare what atoms are used
4. **Dominant Axis compliance** — Must pass all 5 axis checks
5. **Role neutral** — No hustler/poster bias (bidirectional)

---

## Folder Structure

```
molecules/
├── MoleculeName/
│   ├── MoleculeName.swift       # Implementation
│   ├── MoleculeName.contract.md # Composition rules
│   └── MoleculeName.stress.md   # Stress test results
```

---

## Composition Contract Template

```markdown
## Composition Contract: [MoleculeName]

### Atoms Used
- AtomA (required)
- AtomB (optional)

### Forbidden Atoms
- AtomX (reason)

### Dominant Axis Compliance
- [ ] momentum > calm
- [ ] urgency > comfort
- [ ] action > reassurance
- [ ] direction > balance
- [ ] concrete > abstract

### Role Bias
- [ ] NONE (bidirectional)
```

---

## Stress Test Protocol

Before a molecule can be used in a section:

1. Verify all atoms are approved
2. Check Dominant Axis compliance
3. Verify no role bias
4. Visual review
