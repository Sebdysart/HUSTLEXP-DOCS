# Section Contract: EntryHeroSection

**Status:** APPROVED
**Version:** 1.0.0

---

## Purpose (ONE sentence only)

Answer the question: **"What is this app?"**

---

## Molecules Used

| Molecule | Purpose |
|----------|---------|
| `BrandCluster` | Logo, name, glow |

## Atoms Used Directly

| Atom | Purpose |
|------|---------|
| `TypeReveal` | Headline animation |
| `MotionFadeIn` | Subhead animation |

---

## Forbidden Content

- **CTA buttons** — Belongs in EntryActionSection
- **Secondary links** — Belongs in EntryActionSection
- **Feature previews** — Belongs in separate onboarding sections
- **Role-specific messaging** — Entry is before role selection

---

## UAP Compliance

- [x] **UAP-0: Visible hierarchy** — Brand → Headline → Subhead
- [x] **UAP-1: Motion continuity** — Staggered entrance animations
- [x] **UAP-2: Action clarity** — No actions in this section (hero only)
- [x] **UAP-3: Loading elegance** — Content reveals progressively

---

## Role Handling

- [x] **Bidirectional** — No role bias in hero section

---

## Layout Rules

- Left-aligned content
- Brand cluster at top
- Headline below with spacing
- Subhead with relaxed line spacing
- No bottom padding (sections don't control full layout)

---

## Configuration Options

| Option | Default | Purpose |
|--------|---------|---------|
| `headline` | "Turn time into money." | Main headline |
| `subhead` | (see default) | Supporting text |
| `animated` | true | Enable animations |
