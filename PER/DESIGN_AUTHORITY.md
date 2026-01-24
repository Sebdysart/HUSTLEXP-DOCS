# DESIGN AUTHORITY — LAYOUT OWNERSHIP FOR ENTRY SCREENS

**STATUS: CONSTITUTIONAL**
**PURPOSE: Remove AI's implicit belief that it decides layout**
**RULE: For entry screens, composition is LOCKED, not AI-decided**

---

## WHY THIS EXISTS

AI implicitly believes:

> "I am allowed to decide layout as long as rules are followed."

This is FALSE for Entry/Welcome/First-Contact screens.

For these screens, AI is a **fill-in-the-blanks executor**, not a layout designer.

---

## THE RULE

> **For Entry / Welcome / First-Contact screens:**
>
> - Layout is NOT AI-decided
> - Composition is LOCKED
> - AI may only fill predefined regions
> - If composition is missing → STOP → REQUEST SPEC → DO NOT INVENT

---

## ENTRY SCREEN COMPOSITION (LOCKED)

The Entry Screen composition is defined and locked:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ░░░░░░░░░░░░░░ GRADIENT BACKGROUND ░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                 │
│                    ┌──────────────┐                             │
│                    │  GLOW ORB    │ ← Purple glow (decorative)  │
│                    └──────────────┘                             │
│                                                                 │
│  ╔════════════════════════════════════════════════════════════╗ │
│  ║  REGION 1: BRAND MARK                                      ║ │
│  ║  - Logo container (80x80, purple)                          ║ │
│  ║  - Brand name text ("HustleXP")                            ║ │
│  ║  - Animated fade-in (300ms)                                ║ │
│  ╚════════════════════════════════════════════════════════════╝ │
│                                                                 │
│  ╔════════════════════════════════════════════════════════════╗ │
│  ║  REGION 2: VALUE PROPOSITION                               ║ │
│  ║  - Headline (what user gets)                               ║ │
│  ║  - Subheadline (how it works)                              ║ │
│  ║  - Centered text, full width                               ║ │
│  ╚════════════════════════════════════════════════════════════╝ │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                      SPACER (flex: 1)                    │   │
│  │                  Pushes CTA to bottom                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ╔════════════════════════════════════════════════════════════╗ │
│  ║  REGION 3: CTA SECTION (anchored at bottom)                ║ │
│  ║  - Primary button (purple, full width)                     ║ │
│  ║  - Secondary action ("Already have account?")              ║ │
│  ║  - Safe area padding applied                               ║ │
│  ╚════════════════════════════════════════════════════════════╝ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## WHAT AI MAY FILL IN

AI may ONLY fill the predefined regions:

### Region 1: Brand Mark
```
LOCKED ELEMENTS:
- Logo container: 80x80px, borderRadius 20, purple (#5B2DFF)
- Brand name: "HustleXP", 28px, bold, white
- Animation: fade-in 300ms

AI MAY NOT:
- Change logo size
- Change logo color
- Add additional brand elements
- Remove the logo
- Change animation timing
```

### Region 2: Value Proposition
```
LOCKED ELEMENTS:
- Headline position: below brand, centered
- Subheadline position: below headline, centered
- Text colors: white headline, secondary subheadline

AI MAY:
- Adjust text content per approved copy
- (But copy is also locked — see COPY below)

AI MAY NOT:
- Add images
- Add icons
- Add animations beyond fade-in
- Change text alignment
- Add additional sections
```

### Region 3: CTA Section
```
LOCKED ELEMENTS:
- Primary button: full width, purple, 14px radius
- Secondary text: centered below button
- Safe area padding: applied

AI MAY NOT:
- Add additional buttons
- Change button color
- Change button position (must be bottom-anchored)
- Add decorative elements
```

---

## LOCKED COPY (DO NOT MODIFY)

The copy for Entry Screen is locked:

```
HEADLINE:
"Get things done.\nGet paid."

SUBHEADLINE:
"Post tasks and find help in minutes.\nOr earn money completing tasks nearby."

PRIMARY CTA:
"Get Started"

SECONDARY:
"Already have an account? Sign in"
```

If copy needs to change:
→ STOP
→ REQUEST updated copy from user
→ DO NOT invent alternative copy

---

## IF COMPOSITION SPEC IS MISSING

For any entry/welcome/first-contact screen:

1. Check if composition spec exists in `screens-spec/`
2. If YES → Follow that spec exactly
3. If NO →
   ```
   STOP
   REQUEST: "No composition spec exists for [screen].
            Please provide layout regions and locked elements."
   DO NOT INVENT a layout
   ```

---

## DESIGN DECISIONS AI CANNOT MAKE

For entry screens, AI CANNOT decide:

| Decision | Who Decides |
|----------|-------------|
| Overall layout structure | LOCKED in this document |
| Region positions | LOCKED in this document |
| Gradient colors | LOCKED (purple tint) |
| Glow color | LOCKED (purple) |
| Logo size | LOCKED (80x80) |
| Button color | LOCKED (purple) |
| Copy text | LOCKED (see above) |
| Animation timing | LOCKED (300ms) |
| Font sizes | LOCKED (28px brand, 32px headline, 17px sub) |

---

## WHAT AI CAN ADJUST

Very limited adjustments:

```
✅ Safe area insets (using useSafeAreaInsets())
✅ Minor spacing tweaks (within 4px)
✅ Platform-specific adaptations (if documented)
```

Everything else requires explicit approval.

---

## VERIFICATION CHECKLIST

Before submitting Entry Screen work:

```
[ ] Used exact gradient colors ['#1a0a2e', '#0B0B0F', '#000000']
[ ] Used exact purple glow (#5B2DFF, opacity 0.2)
[ ] Logo container is 80x80 with borderRadius 20
[ ] Logo container is purple (#5B2DFF)
[ ] Brand name is "HustleXP" at 28px bold
[ ] Headline matches locked copy exactly
[ ] Subheadline matches locked copy exactly
[ ] CTA button is purple (#5B2DFF)
[ ] CTA button is full width
[ ] CTA is anchored at bottom with safe area
[ ] Secondary action text matches locked copy
[ ] No additional regions added
[ ] No layout structure changes
[ ] Animation is 300ms fade-in
```

If ANY checkbox is unchecked → NOT COMPLIANT

---

## THE FINAL RULE

> AI is a **fill-in-the-blanks executor** for entry screens.
>
> The blanks are small.
> The structure is fixed.
> Invention is forbidden.
>
> If you find yourself "designing" an entry screen → STOP.
> The design is already done. You are implementing, not designing.

---

**This document removes AI's authority over entry screen layout.**
**Composition is locked. AI fills regions. That's all.**
