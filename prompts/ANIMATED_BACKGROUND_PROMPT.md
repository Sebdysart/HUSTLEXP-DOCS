# ANIMATED BACKGROUND PROMPT — LIVING VOID

**PROBLEM:** Background is static. Needs motion, life, energy.
**SOLUTION:** Animated gradient mesh + particle field + pulsing glow

---

## COPY THIS ENTIRE PROMPT TO CURSOR

```
HUSTLEXP_INVOCATION()

CRITICAL REQUIREMENT: The background must be ANIMATED and ALIVE.

The current background is STATIC and DEAD. This fails UAP-7 (momentum over calm).

═══════════════════════════════════════════════════════════════════
WHAT I NEED: LIVING, BREATHING BACKGROUND
═══════════════════════════════════════════════════════════════════

The background must have VISIBLE MOTION at all times.
Not subtle. Not "if you look closely." OBVIOUS motion.

Think:
- Apple Vision Pro spatial environments
- Stripe's animated gradients
- Linear's mesh gradient backgrounds
- Discord Nitro animated backgrounds

NOT:
- Static gradient
- Single color
- "Premium but dead"

═══════════════════════════════════════════════════════════════════
TECHNIQUE 1: ANIMATED GRADIENT MESH (REQUIRED)
═══════════════════════════════════════════════════════════════════

Create a mesh gradient with multiple color blobs that slowly drift.

struct AnimatedMeshBackground: View {
    @State private var animate = false

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Multiple gradient blobs that move
                let colors: [Color] = [
                    Color(hex: "#5B2DFF").opacity(0.6),  // Purple
                    Color(hex: "#1a0a2e").opacity(0.8),  // Deep purple
                    Color(hex: "#3D1DFF").opacity(0.4),  // Lighter purple
                    Color(hex: "#0B0B0F")               // Near black
                ]

                // Blob 1 - Large, slow drift
                let blob1X = size.width * 0.3 + sin(time * 0.3) * 100
                let blob1Y = size.height * 0.2 + cos(time * 0.2) * 80

                // Blob 2 - Medium, different phase
                let blob2X = size.width * 0.7 + cos(time * 0.25) * 120
                let blob2Y = size.height * 0.5 + sin(time * 0.35) * 100

                // Blob 3 - Smaller, faster
                let blob3X = size.width * 0.5 + sin(time * 0.4) * 60
                let blob3Y = size.height * 0.8 + cos(time * 0.3) * 50

                // Draw radial gradients at each blob position
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: 80))

                    ctx.fill(
                        Circle().path(in: CGRect(x: blob1X - 150, y: blob1Y - 150, width: 300, height: 300)),
                        with: .color(colors[0])
                    )

                    ctx.fill(
                        Circle().path(in: CGRect(x: blob2X - 120, y: blob2Y - 120, width: 240, height: 240)),
                        with: .color(colors[2])
                    )

                    ctx.fill(
                        Circle().path(in: CGRect(x: blob3X - 100, y: blob3Y - 100, width: 200, height: 200)),
                        with: .color(colors[0])
                    )
                }
            }
        }
        .background(Color(hex: "#0B0B0F"))
        .ignoresSafeArea()
    }
}

═══════════════════════════════════════════════════════════════════
TECHNIQUE 2: AURORA WAVE EFFECT (ALTERNATIVE)
═══════════════════════════════════════════════════════════════════

Vertical waves of purple light that drift upward.

struct AuroraBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Multiple wave layers
                for i in 0..<5 {
                    let layerOffset = CGFloat(i) * 0.2
                    let wavePhase = time * 0.5 + layerOffset * .pi

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: size.height))

                    for x in stride(from: 0, through: size.width, by: 5) {
                        let relativeX = x / size.width
                        let wave1 = sin(relativeX * .pi * 2 + wavePhase) * 50
                        let wave2 = sin(relativeX * .pi * 3 + wavePhase * 1.3) * 30
                        let baseY = size.height * (0.3 + layerOffset * 0.15)
                        let y = baseY + wave1 + wave2

                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.closeSubpath()

                    let opacity = 0.15 - Double(i) * 0.02
                    context.fill(path, with: .color(Color(hex: "#5B2DFF").opacity(opacity)))
                }
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#1a0a2e"), Color(hex: "#0B0B0F"), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

═══════════════════════════════════════════════════════════════════
TECHNIQUE 3: FLOATING PARTICLES (ADD TO ANY BACKGROUND)
═══════════════════════════════════════════════════════════════════

Particles that slowly float upward = "opportunity rising"

struct ParticleField: View {
    @State private var particles: [Particle] = (0..<30).map { _ in Particle() }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for particle in particles {
                    let x = particle.x * size.width
                    let baseY = particle.y * size.height
                    let y = baseY - CGFloat(time.truncatingRemainder(dividingBy: particle.speed * 20)) * (size.height / (particle.speed * 20))
                    let adjustedY = y < 0 ? y + size.height : y

                    let opacity = particle.opacity * (1 - abs(adjustedY - size.height/2) / (size.height/2) * 0.5)

                    context.fill(
                        Circle().path(in: CGRect(x: x - particle.size/2, y: adjustedY - particle.size/2, width: particle.size, height: particle.size)),
                        with: .color(Color(hex: "#5B2DFF").opacity(opacity))
                    )
                }
            }
        }
    }
}

struct Particle {
    let x: CGFloat = .random(in: 0...1)
    let y: CGFloat = .random(in: 0...1)
    let size: CGFloat = .random(in: 2...6)
    let opacity: Double = .random(in: 0.2...0.5)
    let speed: Double = .random(in: 8...15)
}

═══════════════════════════════════════════════════════════════════
TECHNIQUE 4: PULSING GLOW ORB (BEHIND LOGO)
═══════════════════════════════════════════════════════════════════

struct PulsingGlow: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3

    var body: some View {
        ZStack {
            // Outer glow - slow pulse
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#5B2DFF").opacity(0.4),
                            Color(hex: "#5B2DFF").opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(scale)
                .opacity(opacity)

            // Inner glow - faster pulse
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#5B2DFF").opacity(0.6),
                            Color(hex: "#5B2DFF").opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(scale * 0.8 + 0.2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                scale = 1.15
                opacity = 0.5
            }
        }
    }
}

═══════════════════════════════════════════════════════════════════
COMPLETE ENTRY SCREEN WITH ALL EFFECTS
═══════════════════════════════════════════════════════════════════

struct EntryScreen: View {
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Layer 1: Base gradient
            LinearGradient(
                colors: [Color(hex: "#1a0a2e"), Color(hex: "#0B0B0F"), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )

            // Layer 2: Animated mesh (drifting blobs)
            AnimatedMeshBackground()
                .opacity(0.7)

            // Layer 3: Floating particles
            ParticleField()

            // Layer 4: Pulsing glow (positioned behind logo area)
            PulsingGlow()
                .offset(y: -200)

            // Layer 5: Content
            VStack(spacing: 0) {
                // Brand
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#5B2DFF"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("H")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text("HustleXP")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.top, 60)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 40)

                // Headline
                Text("Turn time into money.")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 16)

                // Subhead
                Text("Post tasks and find help in minutes.\nOr earn money completing tasks nearby.")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer()

                // CTA
                Button(action: {}) {
                    Text("Enter the market")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#5B2DFF"))
                        .cornerRadius(14)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 16)

                // Secondary
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.white.opacity(0.5))
                    Text("Sign in")
                        .foregroundColor(.white.opacity(0.7))
                        .underline()
                }
                .font(.system(size: 15))
                .opacity(showContent ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showContent = true
            }
        }
    }
}

═══════════════════════════════════════════════════════════════════
VERIFICATION CHECKLIST
═══════════════════════════════════════════════════════════════════

Before submitting, the background MUST have:

[ ] VISIBLE MOTION at all times (not just on load)
[ ] Multiple layers of animation (mesh + particles + glow)
[ ] Purple color blobs that DRIFT (not static)
[ ] Particles floating UPWARD (opportunity rising)
[ ] Pulsing glow that BREATHES (not static opacity)
[ ] 60fps smooth animation (no jank)

If the background looks like a static image → FAIL
If you have to "look closely" to see motion → FAIL
If it could be a screenshot → FAIL

The background must be OBVIOUSLY ALIVE.

═══════════════════════════════════════════════════════════════════
```

---

## KEY REQUIREMENTS

| Element | Motion Type | Speed |
|---------|-------------|-------|
| Gradient blobs | Slow drift (sin/cos) | 0.2-0.4 cycles/sec |
| Particles | Float upward | 8-15 sec cycle |
| Glow orb | Pulse scale + opacity | 3 sec cycle |
| Content | Fade in on load | 0.8 sec |

The background should feel like you're looking into a living void — not a poster.
