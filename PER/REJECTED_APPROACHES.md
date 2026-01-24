# REJECTED APPROACHES — ANTI-LOOP PROTECTION

**STATUS: CONSTITUTIONAL**
**PURPOSE: Prevent AI from re-attempting previously failed solutions**
**RULE: Reattempting rejected approaches is forbidden**

---

## WHY THIS EXISTS

AI has no memory of what already failed in previous sessions.

Without this document, AI will repeatedly:
- Attempt the same failed layouts
- Reproduce the same bad patterns
- Suggest solutions that were already rejected

This document is the **anti-loop protection**.

---

## THE RULE

> **Reattempting rejected approaches is FORBIDDEN.**
>
> If an approach is listed here, it has already failed.
> Do not try it again.
> Do not try a "slightly different version" of it.
> It failed. Move on.

---

## REJECTED LAYOUT APPROACHES

### ❌ Centered Logo + CTA Entry Screens

```
REJECTED: 2026-01-24
REASON: Fails UAP-5, looks like a popup not a destination

Description:
- Logo centered vertically and horizontally
- CTA button directly below logo
- Empty space around edges
- No gradient, no glow, no brand treatment

This approach creates a "card in the void" aesthetic.
It has been rejected. Do not attempt variations.
```

### ❌ Card-Based Welcome Layouts

```
REJECTED: 2026-01-24
REASON: Fails UAP-5, feels dismissable not immersive

Description:
- Content wrapped in a card/panel container
- Card floats in the center of screen
- Rounded corners suggest modal
- Background is flat black

Any variation of "content in a card" is rejected.
```

### ❌ Stacked VStack-Only Compositions

```
REJECTED: 2026-01-24
REASON: Feels generic, no brand personality

Description:
- Elements stacked vertically with no visual hierarchy
- No gradient background
- No glow effects
- No animation
- Just text on black

This approach produces generic, forgettable screens.
```

### ❌ Two-Box Layouts

```
REJECTED: 2026-01-24
REASON: Arbitrary division, no clear narrative

Description:
- Screen divided into two distinct boxes
- Top box for brand, bottom box for action
- Visible separation between boxes
- Feels like dashboard, not entry

Entry screens should flow, not segment.
```

---

## REJECTED COLOR APPROACHES

### ❌ Green Entry Screens

```
REJECTED: 2026-01-24
REASON: Semantic violation (green = success, entry ≠ success)

Any use of green (#1FAD7E, #34C759, or similar) on:
- Entry screen backgrounds
- Entry screen gradients
- Entry screen glows
- Entry screen CTAs

Green is reserved for SUCCESS states only.
```

### ❌ Flat Black Backgrounds

```
REJECTED: 2026-01-24
REASON: Lacks brand personality, no depth

Description:
- backgroundColor: '#000000' with no gradient
- No glow effects
- No visual interest
- Feels like debug screen

Entry screens require gradient + glow treatment.
```

### ❌ Wrong Black (#0D0D0D)

```
REJECTED: 2026-01-24
REASON: Not brand color

The color #0D0D0D was used incorrectly.
Correct values:
- #0B0B0F (brand black)
- #000000 (pure black for gradient end)
```

---

## REJECTED COPY APPROACHES

### ❌ Generic Welcome Copy

```
REJECTED: 2026-01-24
REASON: Forgettable, no value proposition

Examples of rejected copy:
- "Welcome to HustleXP"
- "Let's get started"
- "Your journey begins here"
- "Ready to hustle?"
- "Join the community"

Copy must communicate VALUE, not just greeting.
```

### ❌ Feature-Focused Headlines

```
REJECTED: 2026-01-24
REASON: Entry screens are about WHO, not WHAT

Examples of rejected copy:
- "The task marketplace"
- "Post and complete tasks"
- "Earn money doing tasks"

Entry copy should be about USER BENEFIT, not app features.
```

---

## REJECTED ANIMATION APPROACHES

### ❌ Slide-In Animations

```
REJECTED: 2026-01-24
REASON: Feels cheap, not premium

Entry screens use FADE animations only:
- Logo: fade-in 300ms
- Content: fade-in 400ms (after logo)

No slide, no bounce, no scale.
```

### ❌ No Animation

```
REJECTED: 2026-01-24
REASON: Feels static, lacks polish

Entry screens REQUIRE animation:
- Logo fade-in is mandatory
- Content fade-in is mandatory
- Static screens fail UAP-2
```

---

## REJECTED COMPONENT APPROACHES

### ❌ Using React Native <Button>

```
REJECTED: 2026-01-24
REASON: Unstyled, platform-inconsistent

<Button title="Get Started" />  // REJECTED

Use styled TouchableOpacity with explicit styles.
```

### ❌ Minimal Bootstrap Components

```
REJECTED: 2026-01-24
REASON: Designed for testing, not production

Components with names like:
- BootstrapButton
- MinimalScreen
- TestEntryScreen
- DebugWelcome

These are internal verification only.
Never promote to production.
```

---

## HOW TO CHECK BEFORE IMPLEMENTING

Before implementing any approach:

1. Check this document
2. Is your approach listed here?
   - YES → STOP, it's rejected
   - NO → Proceed with caution
3. Does your approach RESEMBLE something listed here?
   - YES → Likely rejected, ask before proceeding
   - NO → Proceed

---

## ADDING NEW REJECTIONS

When an approach fails:

1. Document it here with:
   - Date rejected
   - Reason for rejection
   - Description of the approach
   - Why it failed

2. This prevents future re-attempts

---

## THE ANTI-LOOP GUARANTEE

This document guarantees:

1. **No repeated failures** — Failed approaches are documented
2. **No wasted effort** — Don't attempt what already failed
3. **Progressive improvement** — Each failure teaches

---

**If an approach is listed here, it is dead.**
**Do not resurrect it. Do not "improve" it. It failed.**
