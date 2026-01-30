# Section Contract: EntryActionSection

**Status:** APPROVED
**Version:** 1.0.0

---

## Purpose (ONE sentence only)

Answer the question: **"What do I do next?"**

---

## Molecules Used

| Molecule | Purpose |
|----------|---------|
| `CTAStack` | Primary button + sign in link |

---

## Forbidden Content

- **Brand elements** — Belongs in EntryHeroSection
- **Headlines** — Belongs in EntryHeroSection
- **Feature previews** — Belongs in separate sections
- **Multiple primary buttons** — One clear action

---

## UAP Compliance

- [x] **UAP-0: Visible hierarchy** — Primary button > secondary link
- [x] **UAP-1: Motion continuity** — Entrance animation
- [x] **UAP-2: Action clarity** — ONE primary action, ONE secondary
- [x] **UAP-3: Loading elegance** — Button appears after hero

---

## Role Handling

- [x] **Bidirectional** — "Enter the market" works for both roles

---

## Layout Rules

- Full-width primary button
- Centered secondary link below
- Positioned at bottom of screen (but section doesn't control this)
- Safe area padding handled by screen

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `onGetStarted` | required | Primary button callback |
| `onSignIn` | required | Sign in link callback |
| `animated` | true | Enable animations |
| `entranceDelay` | 0.9 | Delay before entrance |

---

## Animation Timing

Default delay of 0.9s ensures action section appears AFTER hero section completes its entrance. This creates the narrative flow:

1. Background appears (0s)
2. Brand cluster appears (0.3s)
3. Headline appears (0.5s)
4. Subhead appears (0.7s)
5. **CTA appears (0.9s)** ← This section
