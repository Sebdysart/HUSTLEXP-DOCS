# Composition Contract: CTAStack

**Status:** APPROVED
**Version:** 1.0.0

---

## Purpose

Call-to-action stack with primary button and optional secondary link. The final push for user action.

---

## Atoms Used

| Atom | Required | Purpose |
|------|----------|---------|
| `PrimaryCTA` | Yes | Main action button |
| `MotionFadeIn` | Yes | Entrance animation |

---

## Forbidden Atoms

| Atom | Reason |
|------|--------|
| `BrandMark` | Belongs in BrandCluster |
| `GlowOrb` | PrimaryCTA has its own glow |
| `AnimatedMeshField` | Belongs in MarketField |

---

## Dominant Axis Compliance

- [x] **momentum > calm** — Entrance animation, glow effect
- [x] **urgency > comfort** — "Enter the market" implies action NOW
- [x] **action > reassurance** — Primary action is prominent
- [x] **direction > balance** — Clear primary/secondary hierarchy
- [x] **concrete > abstract** — Specific action text

---

## Role Bias

- [x] **NONE** — Entry screen is before role selection

---

## Layout Rules

- Primary button is full-width
- Secondary link is centered below
- Staggered entrance animation
- Glow only on primary button

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `primaryText` | required | Button text |
| `secondaryText` | nil | Link text |
| `secondaryPrefix` | nil | Text before link |
| `animated` | true | Enable animations |
| `entranceDelay` | 0 | Delay before entrance |
