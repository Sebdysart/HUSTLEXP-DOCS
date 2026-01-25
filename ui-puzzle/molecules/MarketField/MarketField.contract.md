# Composition Contract: MarketField

**Status:** APPROVED
**Version:** 1.0.0

---

## Purpose

Premium animated background that creates the "living, breathing" market atmosphere. Combines mesh gradient, particles, and noise for depth.

---

## Atoms Used

| Atom | Required | Purpose |
|------|----------|---------|
| `AnimatedMeshField` | Yes | Drifting gradient base |
| `ParticleField` | Optional | Rising particles ("opportunity") |
| `NoiseOverlay` | Optional | Grain texture (premium feel) |

---

## Forbidden Atoms

| Atom | Reason |
|------|--------|
| `GlowOrb` | Belongs in BrandCluster, not background |
| `BrandMark` | Belongs in BrandCluster |
| `PrimaryCTA` | Belongs in CTAStack |

---

## Dominant Axis Compliance

- [x] **momentum > calm** — Animated drifting, rising particles
- [x] **urgency > comfort** — Constant subtle motion
- [x] **action > reassurance** — Dynamic, not static
- [x] **direction > balance** — Particles move UP (opportunity rising)
- [x] **concrete > abstract** — Visual depth, not flat

---

## Role Bias

- [x] **NONE** — This background works for both hustlers and posters

---

## Layer Rules

- Cannot contain UI elements (text, buttons)
- Cannot have tap interactions
- Must fill available space
- Must support reduced motion mode

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `animated` | true | Enable/disable all animation |
| `showParticles` | true | Show floating particles |
| `showNoise` | true | Show grain texture |
