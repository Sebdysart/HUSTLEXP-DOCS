# Composition Contract: BrandCluster

**Status:** APPROVED
**Version:** 1.0.0

---

## Purpose

Brand identity cluster combining logo, name, glow, and entrance animation. The first visual users see on entry screens.

---

## Atoms Used

| Atom | Required | Purpose |
|------|----------|---------|
| `BrandMark` | Yes | The "H" logo |
| `GlowOrb` | Optional | Breathing glow behind logo |
| `MotionFadeIn` | Yes | Entrance animation wrapper |

---

## Forbidden Atoms

| Atom | Reason |
|------|--------|
| `PrimaryCTA` | Belongs in CTAStack |
| `AnimatedMeshField` | Belongs in MarketField |
| `ParticleField` | Belongs in MarketField |

---

## Dominant Axis Compliance

- [x] **momentum > calm** — Entrance animation, breathing glow
- [x] **urgency > comfort** — Immediate brand recognition
- [x] **action > reassurance** — "HustleXP" name implies action
- [x] **direction > balance** — Left-aligned, directional
- [x] **concrete > abstract** — Clear logo, clear name

---

## Role Bias

- [x] **NONE** — Brand is the same for hustlers and posters

---

## Layout Rules

- Logo and name are horizontally aligned
- Spacer pushes content left
- Glow is centered behind logo
- Entry animations are staggered

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `showName` | true | Show "HustleXP" text |
| `showGlow` | true | Show breathing glow |
| `animated` | true | Enable animations |
| `entranceDelay` | 0 | Delay before entrance |
