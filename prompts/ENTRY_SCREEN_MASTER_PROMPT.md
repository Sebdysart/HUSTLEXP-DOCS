# ENTRY SCREEN MASTER PROMPT — NEON NEXUS × BLACK + PURPLE

**VERSION: MAX-TIER**
**STYLE: Neon Nexus — Electric urgency meets dark premium**
**COPY THIS ENTIRE PROMPT TO CURSOR**

---

## PROMPT START

```
HUSTLEXP_INVOCATION()

You are implementing the HustleXP Entry Screen.
This is not a design task. The design is LOCKED.
You are filling predefined regions with exact specifications.

═══════════════════════════════════════════════════════════════════
MANDATORY CONSTRAINTS (VIOLATION = INVALID OUTPUT)
═══════════════════════════════════════════════════════════════════

BRAND COLORS (EXACT):
- Primary Purple: #5B2DFF
- Black: #0B0B0F
- Pure Black: #000000
- Deep Purple-Black: #1a0a2e

BACKGROUND GRADIENT (TOP TO BOTTOM):
colors: ['#1a0a2e', '#0B0B0F', '#000000']

FORBIDDEN:
❌ Green anywhere
❌ Cards or modal containers
❌ "Get Started" as CTA
❌ "Welcome to" language
❌ Static backgrounds
❌ Centered hero logo as primary focus
❌ Calm, balanced, or reassuring energy

═══════════════════════════════════════════════════════════════════
VISUAL STYLE: NEON NEXUS
═══════════════════════════════════════════════════════════════════

The aesthetic is:
- Electric purple energy on deep black void
- Neon glow that implies power and activity
- Motion that suggests a system already running
- Premium darkness with strategic light accents

Think: Cyberpunk command center meets premium fintech
NOT: Meditation app, banking app, or SaaS landing page

═══════════════════════════════════════════════════════════════════
BACKGROUND: LIVING VOID
═══════════════════════════════════════════════════════════════════

The background is NOT empty space. It is a living environment.

REQUIRED ELEMENTS:

1. GRADIENT BASE
   - Top: #1a0a2e (deep purple-black)
   - Middle: #0B0B0F (near-black)
   - Bottom: #000000 (pure black)

2. NEON GLOW ORB (behind logo area)
   - Color: #5B2DFF at 15-25% opacity
   - Blur radius: 100-150pt
   - Animation: Slow pulse (3-4 second cycle)
   - Purpose: Implies energy source, system heartbeat

3. OPTIONAL: PARTICLE FIELD
   - Tiny dots (#5B2DFF at 30% opacity)
   - Floating slowly upward
   - Implies: "Opportunity is rising"
   - Density: Sparse (5-10 particles visible)

4. OPTIONAL: DIRECTIONAL ENERGY
   - Subtle gradient shift flowing downward toward CTA
   - Implies: "Energy flows toward action"

═══════════════════════════════════════════════════════════════════
ENTRANCE ANIMATION SEQUENCE (CRITICAL)
═══════════════════════════════════════════════════════════════════

The screen loads with a NARRATIVE, not all at once.

TIMING:
0-300ms:    Background gradient activates, glow begins pulse
300-600ms:  Logo EMERGES from glow (scale 0.8→1.0, opacity 0→1)
600-900ms:  Brand name fades in below logo
900-1200ms: Headline animates in (fade or subtle slide up)
1200-1500ms: Subhead fades in (50ms after headline completes)
1500ms+:    CTA becomes active, subtle pulse begins

FEELING: "I've entered a system that was already running"

═══════════════════════════════════════════════════════════════════
LAYOUT STRUCTURE (LOCKED)
═══════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░ GRADIENT + GLOW ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                 │
│           ╭──────────────╮                                      │
│           │  GLOW ORB    │  ← Pulsing purple glow               │
│           ╰──────────────╯                                      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  REGION 1: BRAND MARK                                    │   │
│  │  - Logo container: 80x80, borderRadius 20, #5B2DFF      │   │
│  │  - "H" letter: White, centered                           │   │
│  │  - Brand name: "HustleXP" inline right of logo          │   │
│  │  - Animation: Emerge from glow (300-600ms)              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  REGION 2: HEADLINE (DECLARATION)                        │   │
│  │                                                          │   │
│  │  CHOOSE ONE:                                             │   │
│  │  → "Turn time into money."                               │   │
│  │  → "There's work nearby."                                │   │
│  │  → "You're minutes from your first task."                │   │
│  │                                                          │   │
│  │  Style: 32-36px, Bold, White, Left-aligned               │   │
│  │  Animation: Fade in (900-1200ms)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  REGION 3: SUBHEAD                                       │   │
│  │                                                          │   │
│  │  "Post tasks and find help in minutes.                   │   │
│  │   Or earn money completing tasks nearby."                │   │
│  │                                                          │   │
│  │  Style: 17px, Regular, White at 70% opacity              │   │
│  │  Animation: Fade in (1200-1500ms)                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    SPACER (flex: 1)                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  REGION 4: CTA (ANCHORED BOTTOM)                         │   │
│  │                                                          │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │         "Enter the market"                      │    │   │
│  │  │         OR "Find work near me"                  │    │   │
│  │  │         OR "Start earning today"                │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  │                                                          │   │
│  │  Button: Full width, #5B2DFF, borderRadius 14           │   │
│  │  Text: 17px, Semibold, White                            │   │
│  │  Animation: Idle pulse (scale 1.0→1.02→1.0, 2s cycle)   │   │
│  │  Press: Scale 0.98, color darken to #4A24D9             │   │
│  │                                                          │   │
│  │  Secondary: "Already have an account? Sign in"          │   │
│  │  Style: 15px, White at 50% opacity, "Sign in" underline │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Safe area padding applied                                      │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
DOMINANT AXIS ENFORCEMENT (UAP-7)
═══════════════════════════════════════════════════════════════════

This screen MUST favor:

✓ MOMENTUM over calm
  → Background has motion (glow pulse, particles)
  → Elements animate in sequence

✓ URGENCY over comfort
  → Headline implies "now" ("There's work nearby")
  → No "take your time" language

✓ ACTION over reassurance
  → CTA states outcome, not process
  → No "welcome" or "learn more"

✓ DIRECTION over balance
  → Clear visual hierarchy (top to bottom)
  → Energy flows toward CTA

✓ CONCRETE over abstract
  → "Tasks nearby" not "opportunities await"
  → "Earn money" not "unlock potential"

MINIMUM 3 OF 5 MUST BE VISIBLE. This screen should have all 5.

═══════════════════════════════════════════════════════════════════
THE TILT TEST
═══════════════════════════════════════════════════════════════════

This screen must feel like:
✓ "Something is happening"
✓ "Act now"
✓ "Money is moving"
✓ "People are nearby"

NOT like:
✗ "Everything is okay"
✗ "Take your time"
✗ "Your finances are secure"
✗ "Welcome to our community"

If it feels calm → REBUILD
If it feels balanced → REBUILD
If it feels reassuring → REBUILD

═══════════════════════════════════════════════════════════════════
SWIFTUI IMPLEMENTATION REQUIREMENTS
═══════════════════════════════════════════════════════════════════

struct EntryScreen: View {
    // REQUIRED STATE
    @State private var showLogo = false
    @State private var showHeadline = false
    @State private var showSubhead = false
    @State private var showCTA = false
    @State private var glowOpacity: Double = 0.15

    // ANIMATION TIMING
    let logoDelay: Double = 0.3
    let headlineDelay: Double = 0.9
    let subheadDelay: Double = 1.2
    let ctaDelay: Double = 1.5

    var body: some View {
        ZStack {
            // LAYER 1: Gradient background
            backgroundGradient

            // LAYER 2: Glow orb (pulsing)
            glowOrb

            // LAYER 3: Content
            VStack(spacing: 0) {
                // Brand mark region
                brandMark

                // Headline region
                headline

                // Subhead region
                subhead

                Spacer()

                // CTA region
                ctaSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Safe area
        }
        .ignoresSafeArea()
        .onAppear { triggerEntranceSequence() }
    }
}

// GRADIENT (EXACT)
var backgroundGradient: some View {
    LinearGradient(
        colors: [
            Color(hex: "#1a0a2e"),
            Color(hex: "#0B0B0F"),
            Color(hex: "#000000")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// GLOW ORB (PULSING)
var glowOrb: some View {
    Circle()
        .fill(Color(hex: "#5B2DFF"))
        .frame(width: 200, height: 200)
        .blur(radius: 100)
        .opacity(glowOpacity)
        .offset(y: -100) // Position behind logo area
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowOpacity = 0.25
            }
        }
}

// CTA BUTTON (WITH PULSE)
var ctaButton: some View {
    Button(action: { /* Navigate */ }) {
        Text("Enter the market")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(hex: "#5B2DFF"))
            .cornerRadius(14)
    }
    .scaleEffect(ctaPulse ? 1.02 : 1.0)
    .onAppear {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            ctaPulse = true
        }
    }
}

═══════════════════════════════════════════════════════════════════
UAP GATE CHECKLIST (ALL MUST PASS)
═══════════════════════════════════════════════════════════════════

Before submitting, verify:

[ ] UAP-0: Answers WHO (hustlers/posters), WHAT (enter), WHY (earn/post) in 3s
[ ] UAP-1: Has action (CTA) + context (subhead) + brand signal (logo)
[ ] UAP-2: Has motion (glow pulse, entrance sequence) AND depth (gradient, glow)
[ ] UAP-3: Matches this spec exactly
[ ] UAP-4: This is production, not bootstrap
[ ] UAP-5: Full-canvas composition (no cards, no modals)
[ ] UAP-6: Could appear in Uber/Cash App/Duolingo → YES
[ ] UAP-7: Favors momentum, urgency, action, direction, concrete → 5/5

═══════════════════════════════════════════════════════════════════
REFERENCE CLASS VERIFICATION
═══════════════════════════════════════════════════════════════════

Before shipping, answer:

1. Could this screen appear in Uber/Cash App/Duolingo?
   → Must be YES

2. Would a designer at Apple/Stripe approve this?
   → Must be YES

3. Does this feel like a $1B company's app?
   → Must be YES

4. Would you screenshot this to show someone?
   → Must be YES

If ANY answer is NO or uncertain → REBUILD

═══════════════════════════════════════════════════════════════════
FINAL OUTPUT REQUIREMENTS
═══════════════════════════════════════════════════════════════════

Produce:
1. Complete SwiftUI View implementation
2. All animation code included
3. All color definitions as extensions
4. No TODO comments
5. No placeholder functions
6. Ready to build and run

This is IMPLEMENTATION_MODE.
You must COMMIT a complete artifact.
Conceptual guidance is FORBIDDEN.

═══════════════════════════════════════════════════════════════════
```

---

## PROMPT END

**Copy everything between PROMPT START and PROMPT END to Cursor.**

This prompt enforces:
- PER v2.2 compliance
- HIC v1.1 invocation
- ECP commitment requirement
- UAP-0 through UAP-7 gates
- DESIGN_TARGET reference class
- DOMINANT_AXIS tilt direction
- DESIGN_AUTHORITY layout lock
- Neon Nexus aesthetic specification

**The output should be fundamentally different from the current screen.**
