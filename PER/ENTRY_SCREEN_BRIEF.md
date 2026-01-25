# ENTRY SCREEN VISUAL BRIEF — MAX-TIER TARGET

**STATUS: CONSTITUTIONAL — IMPLEMENTATION SPEC**
**PURPOSE: Unambiguous target for max-tier entry screen**
**RULE: This is what the entry screen MUST look like and feel like**

---

## THE BRIEF (ONE PAGE)

### What We're Building

An entry screen that feels like **entering Uber, Cash App, or Duolingo** — not like a generic SaaS landing page.

### The Feeling (Non-Negotiable)

```
When a user opens this app, they must feel:

1. "Something is already happening here"
2. "This is not a toy — this is real money"
3. "I can act RIGHT NOW"
4. "People are using this nearby"
```

### The Anti-Feeling (Avoid At All Costs)

```
We must NEVER communicate:

❌ "Welcome to our platform"
❌ "Here's what we do"
❌ "Get started when you're ready"
❌ Contemplation
❌ Patience
❌ Generic startup energy
```

---

## VISUAL TARGET

### Background: Living Environment

```
NOT: Static black with centered content
YES: Environment that implies a larger system

Techniques:
- Subtle particle motion (tasks floating)
- Directional gradient (energy flowing down)
- Pulsing glow (system heartbeat)
- Depth layers (foreground/background separation)

The background should feel like the TOP of a feed,
not a poster in a frame.
```

### Brand Mark: Consequence, Not Focus

```
NOT: Hero centered logo as primary element
YES: Logo that emerges from the environment

The logo appears BECAUSE you arrived somewhere,
not as the thing you're looking at.

Animation: Emerge from glow, not fade from nothing
Timing: 300-500ms, after environment establishes
```

### Headline: Declaration, Not Description

```
NOT: "Get things done. Get paid."
     (Describes what the app does — boring)

YES: "Turn time into money."
     "There's work nearby."
     "You're minutes from your first task."

     (Declares what will happen — urgent)

Typography:
- Bold, confident, no apology
- Full width, not floating
- Animates in AFTER brand, reinforcing inevitability
```

### CTA: Entry, Not Start

```
NOT: "Get Started" (generic, says nothing)

YES: "Find work near me" (outcome, action)
     "Post a task now" (outcome, action)
     "Start earning today" (outcome, action)

Button treatment:
- Full width, anchored bottom
- Not floating in center
- Implies ENTERING a system, not STARTING a process
```

---

## MOTION REQUIREMENTS

### Entrance Sequence (Critical)

```
0-300ms:    Background activates (gradient shifts, glow pulses)
300-600ms:  Brand emerges from glow
600-900ms:  Headline types/fades in
900-1200ms: Subhead fades in
1200ms+:    CTA becomes active, slight pulse

Total experience: ~1.5 seconds to full state
```

### Background Motion (Subtle, Continuous)

```
Options (pick one):
1. Slow gradient shift (hue rotation, very subtle)
2. Particle float (small dots moving upward = opportunity rising)
3. Glow pulse (system heartbeat, 3-4 second cycle)
4. Depth parallax (slight movement on device tilt)

NOT: Static image with no life
NOT: Aggressive animation that distracts
```

### Interactive Feedback

```
Button press:
- Scale down 0.98x
- Haptic feedback (light)
- Color intensity increase

Secondary tap:
- Text color pulse
- No scale change
```

---

## COLOR APPLICATION

### Background Gradient (Exact)

```swift
// Top to bottom
colors: [
    Color(hex: "#1a0a2e"),  // Deep purple-black (top)
    Color(hex: "#0B0B0F"),  // Near-black (middle)
    Color(hex: "#000000")   // Pure black (bottom)
]
```

### Glow Treatment

```swift
// Behind brand mark
color: Color(hex: "#5B2DFF")
opacity: 0.15-0.25 (pulse between these)
blur: 80-120pt
```

### Text Hierarchy

```swift
headline: Color.white                    // 100% opacity
subhead: Color.white.opacity(0.7)       // 70% opacity
secondary: Color.white.opacity(0.5)     // 50% opacity
```

### CTA Button

```swift
background: Color(hex: "#5B2DFF")       // Primary purple
text: Color.white
pressed: Color(hex: "#4A24D9")          // Darker purple
```

---

## COPY OPTIONS (Pre-Approved)

### Headlines (Choose One)

| Option | Energy | Best For |
|--------|--------|----------|
| "Turn time into money." | Direct, transactional | General audience |
| "There's work nearby." | Immediate, localized | Hustler-focused |
| "You're minutes from your first task." | Urgent, specific | First-time users |

### CTAs (Choose Based on Flow)

| Flow | CTA | Energy |
|------|-----|--------|
| Hustler | "Find work near me" | Action + location |
| Poster | "Post a task now" | Action + immediacy |
| Generic | "Start earning today" | Outcome + time |

---

## REFERENCE COMPARISON

### We Are Like:

| App | What We Borrow |
|-----|----------------|
| **Uber** | "Request is happening now" urgency |
| **Cash App** | Bold money confidence |
| **Duolingo** | Streak momentum, system feeling |

### We Are NOT Like:

| Pattern | Why We Reject It |
|---------|------------------|
| Centered card on black | Modal aesthetic, not arrival |
| Abstract orb + tagline | Crypto wallet energy |
| "Welcome to [App]" | Says nothing, describes nothing |
| Carousel onboarding | User skips immediately |

---

## IMPLEMENTATION CHECKLIST

Before shipping entry screen:

```
ENVIRONMENT:
[ ] Background has gradient (not flat black)
[ ] Glow effect present (pulsing, not static)
[ ] Motion exists (subtle, not distracting)
[ ] Feels like top of a system (not poster)

BRAND:
[ ] Logo emerges (not just appears)
[ ] Animation timing correct (300-500ms)
[ ] Not centered hero (consequence of arrival)

COPY:
[ ] Headline is declaration (not description)
[ ] CTA states outcome (not "Get Started")
[ ] Secondary action present

MOTION:
[ ] Entrance sequence complete (~1.5s)
[ ] Background has subtle life
[ ] Button has feedback

FEEL:
[ ] Could this be Uber/Cash App? → YES required
[ ] Would Apple designer approve? → YES required
[ ] Would I screenshot this? → YES required
[ ] Does it feel like $1B app? → YES required
```

---

## THE SINGLE TEST

Show the entry screen to someone who doesn't know HustleXP.

Within 3 seconds, they should say something like:
- "Oh, this is like Uber for tasks"
- "I can make money with this?"
- "What's nearby?"

If they say:
- "Nice app"
- "Cool design"
- "What does it do?"

→ The screen has FAILED. It's not max-tier.

---

## FINAL RULE

```
Correctness is not excellence.
Compliance is not quality.
Safe is not memorable.

The entry screen must make someone want to ENTER.
Not admire. Not understand. ENTER.

If it doesn't create pull, it fails.
Even if every rule is followed.
```

---

**This is the target. This is what max-tier looks like.**
**No more ambiguity. Build this.**
