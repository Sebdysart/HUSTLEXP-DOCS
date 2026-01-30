# COLOR SEMANTICS LAW — HUSTLEXP BRAND AUTHORITY

**STATUS: CONSTITUTIONAL**
**EFFECTIVE: 2026-01-24**
**VIOLATION: BUILD FAILURE**

---

## The Core Problem This Solves

AI tools see a token called `primary` or `brand` and use it **everywhere**.

Without semantic rules, you get:
- Green entry screens (WRONG - green = "done", not "begin")
- Green backgrounds (WRONG - green = success state, not identity)
- Flat, lifeless screens that feel like dashboards

**This document defines WHAT each color MEANS, not just what it looks like.**

---

## HustleXP Brand Identity

### The Brand is: **Black + Purple**

NOT green. NOT teal. NOT any "success" color.

**Why black + purple:**
- Power, ambition, intelligence
- Premium fintech aesthetic
- Night-mode native
- Tension and momentum (not resolution)
- Compatible with XP, progression, gamification
- "This is not casual"

**Why NOT green:**
- Green = "done", "success", "completed", "safe"
- Green resolves tension — entry screens need tension
- Green is a STATE color, not an IDENTITY color
- Full-screen green = dashboard aesthetic, not arrival

---

## The Authoritative Color System

### Layer 1: Brand Canvas (Identity)

**USE FOR:** Entry screens, onboarding, backgrounds, mood, brand surfaces

```
BRAND_BLACK:        #0B0B0F     (near-black, premium feel)
BRAND_PURPLE:       #5B2DFF     (electric purple - primary accent)
BRAND_PURPLE_LIGHT: #7A4DFF     (lighter purple for gradients)
BRAND_PURPLE_GLOW:  #8B5CF6     (glow effects)
```

**RULES:**
- Entry screens MUST start from black
- Purple appears as glow, gradient, accent — NOT flat fill
- NEVER full-screen green on entry/brand surfaces
- Background gradients: `['#1a0a2e', '#0B0B0F']` or similar

---

### Layer 2: Brand Accent (Energy)

**USE FOR:** Highlights, progress bars, selection states, focus indicators

```
ACCENT_PURPLE:      #8B5CF6     (electric violet)
ACCENT_VIOLET:      #A78BFA     (lighter violet)
```

**RULES:**
- Used sparingly for emphasis
- Never floods the screen
- Creates depth and focus, not surface color

---

### Layer 3: Success / Money (State - CONDITIONAL)

**USE FOR:** Task completed, escrow released, money received, positive outcomes

```
SUCCESS_GREEN:      #34C759     (Apple HIG green)
MONEY_GREEN:        #1FAD7E     (HustleXP teal-green for money)
```

**RULES:**
- 🚨 **NEVER used on entry screens**
- 🚨 **NEVER used as primary background**
- 🚨 **ONLY appears AFTER user action succeeds**
- Reserved for: completion states, money flows, confirmations

---

### Layer 4: Status Colors (Contextual)

**USE FOR:** Alerts, warnings, errors, information

```
ERROR_RED:          #FF3B30     (Apple red)
WARNING_ORANGE:     #FF9500     (Apple orange)
INFO_BLUE:          #007AFF     (Apple blue)
LIVE_RED:           #FF3B30     (Live/instant mode indicator)
INSTANT_YELLOW:     #FFD900     (Instant mode accent)
```

---

### Layer 5: Neutrals (Foundation)

**USE FOR:** Text, borders, disabled states, backgrounds

```
TEXT_PRIMARY:       #FFFFFF
TEXT_SECONDARY:     #E5E5EA
TEXT_MUTED:         #8E8E93
BACKGROUND_BLACK:   #000000
BACKGROUND_ELEVATED:#1C1C1E
GLASS_SURFACE:      rgba(28, 28, 30, 0.6)
GLASS_BORDER:       rgba(255, 255, 255, 0.1)
```

---

## Semantic Rules (BINDING)

### Rule 1: Green is SUCCESS-ONLY

```
❌ FORBIDDEN:
   - Green entry screen background
   - Green onboarding backgrounds
   - Green as brand primary
   - Green buttons on entry (unless "Sign In to existing account")

✅ ALLOWED:
   - Green "Task Completed" banner
   - Green checkmarks
   - Green money amount (after received)
   - Green "Escrow Released" confirmation
```

### Rule 2: Entry Screens Use Black + Purple

```
✅ REQUIRED for Entry/Welcome:
   - Base: #0B0B0F or #000000
   - Gradient: Purple tint at top fading to black
   - Glow: Purple orb behind brand mark
   - CTA button: Purple (#5B2DFF) or white

❌ FORBIDDEN for Entry/Welcome:
   - Solid green background
   - Green gradient
   - Green as dominant color
   - Any "success" color as primary
```

### Rule 3: Color Follows Meaning

| Color | Semantic Meaning | When to Use |
|-------|------------------|-------------|
| Black | Foundation, premium | Always as base |
| Purple | Brand, energy, ambition | Entry, accents, CTAs |
| Green | Success, money, done | ONLY after positive outcome |
| Red | Error, live, urgent | Errors, live mode |
| Orange | Warning, XP, streak | Warnings, gamification |
| Blue | Info, trust, links | Information, trust badges |
| Yellow | Instant, highlight | Instant mode only |

---

## Token Naming (REQUIRED)

AI will misuse tokens with wrong names. Use these EXACT names:

```typescript
// ✅ CORRECT NAMING (Semantic)
const colors = {
  // Brand (use for entry, identity)
  brandBlack: '#0B0B0F',
  brandPurple: '#5B2DFF',
  brandPurpleLight: '#7A4DFF',

  // Success (use ONLY for positive outcomes)
  successGreen: '#34C759',
  moneyGreen: '#1FAD7E',

  // Status
  errorRed: '#FF3B30',
  warningOrange: '#FF9500',
  infoBlue: '#007AFF',

  // Neutrals
  textPrimary: '#FFFFFF',
  textMuted: '#8E8E93',
  backgroundBlack: '#000000',
};

// ❌ WRONG NAMING (Causes misuse)
const colors = {
  primary: '#1FAD7E',      // AI will use this everywhere
  brand: '#34C759',        // AI will flood screens with this
  main: '#1FAD7E',         // Ambiguous, will be misused
};
```

---

## Entry Screen Color Composition (LOCKED)

```tsx
// ✅ CORRECT Entry Screen Colors
<View style={{ flex: 1, backgroundColor: '#0B0B0F' }}>
  <LinearGradient
    colors={['#1a0a2e', '#0B0B0F', '#000000']}  // Purple tint → black
    locations={[0, 0.3, 1]}
    style={StyleSheet.absoluteFill}
  />

  {/* Purple glow behind brand */}
  <View style={{
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: '#5B2DFF',
    opacity: 0.2,
    shadowColor: '#5B2DFF',
    shadowRadius: 80,
  }} />

  {/* CTA Button - Purple */}
  <TouchableOpacity style={{
    backgroundColor: '#5B2DFF',  // Brand purple, NOT green
    // ...
  }}>
    <Text>Get Started</Text>
  </TouchableOpacity>
</View>
```

```tsx
// ❌ WRONG Entry Screen Colors (What you're seeing now)
<View style={{ flex: 1, backgroundColor: '#1FAD7E' }}>  // WRONG
  {/* No gradient */}
  {/* Green everywhere */}
  {/* Feels like "success" not "entry" */}
</View>
```

---

## UAP Integration

Add to `PER/UI_ACCEPTANCE_PROTOCOL.md`:

### UAP-6: Color Semantics Gate

**Requirement:** Colors must match their semantic meaning. Success colors (green) may NEVER appear on entry/brand surfaces.

**Failure Examples:**
- Green background on Entry Screen
- Green as primary brand color
- Success colors where no success has occurred

**Pass Examples:**
- Black + purple entry screen
- Green "Task Completed" confirmation
- Purple CTA buttons on entry

---

## Quick Reference Card

```
ENTRY SCREENS:       Black + Purple gradient + Purple glow
ONBOARDING:          Black + Purple accents
SUCCESS STATES:      Green (ONLY here)
ERROR STATES:        Red
MONEY DISPLAYS:      Green text on dark background (after received)
CTA BUTTONS:         Purple (entry) or contextual
LIVE MODE:           Red accent
INSTANT MODE:        Yellow accent
```

---

## Migration Checklist

- [ ] Rename `brandPrimary: '#1FAD7E'` → `successGreen: '#1FAD7E'`
- [ ] Add `brandPurple: '#5B2DFF'` as new primary
- [ ] Update EntryScreen gradient to purple tint
- [ ] Update CTA button to purple
- [ ] Add UAP-6 to UI_ACCEPTANCE_PROTOCOL.md
- [ ] Update .cursorrules with color semantics
- [ ] Update BOOTSTRAP.md example colors

---

**END OF COLOR_SEMANTICS_LAW.md**
