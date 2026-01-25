// OnboardingCarouselScreen.swift
// HustleXP iOS - Onboarding Carousel
// 5-screen carousel: Hero → Map → Trust Tiers → Earnings → CTA

import SwiftUI

// MARK: - Brand Colors (Entry Screen Specific)

private extension Color {
    static let neonPurple = Color(hex: "#5B2DFF")
    static let deepBlack = Color(hex: "#050507")
    static let darkPurple = Color(hex: "#1a0a2e")
}

// MARK: - Main Screen

@available(iOS 14.0, *)
@available(macOS, unavailable)
public struct OnboardingCarouselScreen: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    public init(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) {
        self.onGetStarted = onGetStarted
        self.onSignIn = onSignIn
    }

    @State private var currentPage: Int = 0
    @State private var showContent: Bool = false

    private let totalPages = 5

    public var body: some View {
        ZStack {
            // Background (page-aware)
            backgroundView
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button(action: { withAnimation { currentPage = totalPages - 1 } }) {
                            Text("Skip")
                                .font(HustleFont.callout(.medium))
                                .foregroundColor(.hustleTextMuted)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top, 56)
                .padding(.horizontal, 20)
                .frame(height: 80)

                // Page content
                TabView(selection: $currentPage) {
                    heroPage.tag(0)
                    mapPage.tag(1)
                    trustTiersPage.tag(2)
                    earningsPage.tag(3)
                    ctaPage.tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Custom page indicators
                pageIndicators
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if currentPage == 0 || currentPage == 4 {
            OnboardingAnimatedMeshBackground()
        } else {
            LinearGradient(
                colors: [Color.darkPurple.opacity(0.3), Color.deepBlack, Color.deepBlack],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Page Indicators

    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.neonPurple : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    // MARK: - Page 0: Hero

    private var heroPage: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)

            // Brand
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.neonPurple)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text("H")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.neonPurple.opacity(0.4), radius: 20, y: 5)

                Text("HustleXP")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 15)

            Spacer().frame(height: 48)

            // Headline
            Text("Turn time into money.")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)

            Spacer().frame(height: 16)

            // Subhead
            Text("Post tasks and find help in minutes.\nOr earn money completing tasks nearby.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)

            Spacer()
        }
    }

    // MARK: - Page 1: Map

    private var mapPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Text("Get paid on your schedule.")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("See tasks nearby and navigate\ndirectly to the job site.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 20)

            OnboardingMapPreview()
                .frame(height: 320)
                .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Page 2: Trust Tiers

    private var trustTiersPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Text("Level up. Unlock more.")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Climb the trust ladder to access\nhigher-paying premium tasks.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 20)

            OnboardingTrustTiersPreview()
                .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Page 3: Earnings

    private var earningsPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Text("Track every dollar.")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Real-time earnings, XP progress,\nand detailed breakdowns.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 20)

            OnboardingEarningsPreview()
                .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Page 4: CTA

    private var ctaPage: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Ready to hustle?")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 16)

            Text("Join thousands turning their\ntime into real money.")
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            // CTA Button
            Button(action: onGetStarted) {
                Text("Enter the market")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.neonPurple)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .shadow(color: Color.neonPurple.opacity(0.4), radius: 20, y: 5)

            Spacer().frame(height: 16)

            // Sign in link
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(.white.opacity(0.4))
                Button(action: onSignIn) {
                    Text("Sign in")
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
            }
            .font(.system(size: 15))

            Spacer().frame(height: 40)
        }
    }
}

// MARK: - Animated Mesh Background

struct OnboardingAnimatedMeshBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Base: Deep black
                context.fill(
                    Rectangle().path(in: CGRect(origin: .zero, size: size)),
                    with: .color(Color(hex: "#050507"))
                )

                // Layer 1: Ambient purple haze
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: 180))

                    let ambientPoints: [(x: CGFloat, y: CGFloat, opacity: Double, pointSize: CGFloat)] = [
                        (0.2, 0.1, 0.25, 350),
                        (0.8, 0.25, 0.2, 300),
                        (0.5, 0.6, 0.15, 400),
                        (0.15, 0.85, 0.2, 320),
                    ]

                    for point in ambientPoints {
                        let x = point.x * size.width
                        let y = point.y * size.height
                        ctx.fill(
                            Ellipse().path(in: CGRect(
                                x: x - point.pointSize/2,
                                y: y - point.pointSize/2,
                                width: point.pointSize,
                                height: point.pointSize
                            )),
                            with: .color(Color(hex: "#1a0a2e").opacity(point.opacity))
                        )
                    }
                }

                // Layer 2: Drifting purple accents
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: 100))

                    let accentPoints: [(baseX: CGFloat, baseY: CGFloat, phase: Double)] = [
                        (0.25, 0.15, 0.0),
                        (0.7, 0.2, 1.0),
                        (0.35, 0.45, 2.0),
                        (0.65, 0.55, 3.0),
                        (0.2, 0.75, 4.0),
                        (0.55, 0.8, 5.0),
                        (0.8, 0.7, 6.0),
                    ]

                    for (i, point) in accentPoints.enumerated() {
                        let drift = sin(time * 0.12 + point.phase) * 35
                        let driftY = cos(time * 0.1 + point.phase * 0.8) * 30

                        let x = point.baseX * size.width + drift
                        let y = point.baseY * size.height + driftY

                        let pointSize: CGFloat = CGFloat(60 + (i % 3) * 30)
                        let opacity = 0.12 + Double(i % 3) * 0.04

                        ctx.fill(
                            Ellipse().path(in: CGRect(
                                x: x - pointSize/2,
                                y: y - pointSize/2,
                                width: pointSize,
                                height: pointSize
                            )),
                            with: .color(Color(hex: "#5B2DFF").opacity(opacity))
                        )
                    }
                }

                // Layer 3: Bright highlight
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: 50))

                    let highlightX = size.width * 0.35 + sin(time * 0.15) * 25
                    let highlightY = size.height * 0.22 + cos(time * 0.12) * 20

                    ctx.fill(
                        Ellipse().path(in: CGRect(
                            x: highlightX - 40,
                            y: highlightY - 40,
                            width: 80,
                            height: 80
                        )),
                        with: .color(Color(hex: "#7B4DFF").opacity(0.2))
                    )
                }
            }
        }
        .overlay(OnboardingNoiseOverlay())
    }
}

// MARK: - Noise Overlay

struct OnboardingNoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height * 0.008) {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.05)

                context.fill(
                    Circle().path(in: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(Color.white.opacity(opacity))
                )
            }
        }
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }
}

// MARK: - Trust Tiers Preview

struct OnboardingTrustTiersPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            OnboardingTierPreviewCard(
                tier: 4,
                name: "In-Home",
                icon: "star.fill",
                color: Color(hex: "#FFD700"),
                isLocked: true,
                isCurrent: false,
                isNext: false
            )

            OnboardingTierPreviewCard(
                tier: 3,
                name: "Trusted",
                icon: "trophy.fill",
                color: .appleOrange,
                isLocked: false,
                isCurrent: false,
                isNext: true
            )

            OnboardingTierPreviewCard(
                tier: 2,
                name: "Verified",
                icon: "checkmark.seal.fill",
                color: .appleBlue,
                isLocked: false,
                isCurrent: true,
                isNext: false
            )

            OnboardingTierPreviewCard(
                tier: 1,
                name: "Unverified",
                icon: "person.fill",
                color: .appleGray,
                isLocked: false,
                isCurrent: false,
                isNext: false,
                isPast: true
            )
        }
    }
}

struct OnboardingTierPreviewCard: View {
    let tier: Int
    let name: String
    let icon: String
    let color: Color
    let isLocked: Bool
    let isCurrent: Bool
    let isNext: Bool
    var isPast: Bool = false

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(isCurrent ? 0.2 : 0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: isLocked ? "lock" : icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isLocked ? .white.opacity(0.4) : color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(HustleFont.headline(.semibold))
                    .foregroundColor(isPast ? .white.opacity(0.4) : .white)

                Text("Tier \(tier)")
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(color.opacity(isPast ? 0.4 : 0.8))
            }

            Spacer()

            if isCurrent {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.hustlePrimary)
                        .frame(width: 8, height: 8)
                    Text("YOU")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.hustlePrimary)
                }
            } else if isNext {
                Text("NEXT")
                    .font(HustleFont.micro(.bold))
                    .foregroundColor(.appleOrange)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isCurrent ? Color.appleBlue.opacity(0.5) :
                            isNext ? Color.appleOrange.opacity(0.3) :
                            Color.white.opacity(0.05),
                            lineWidth: isCurrent || isNext ? 1.5 : 1
                        )
                )
        )
        .scaleEffect(isNext ? pulseScale : 1.0)
        .opacity(isPast ? 0.5 : (isLocked ? 0.6 : 1.0))
        .grayscale(isPast ? 0.8 : (isLocked ? 0.6 : 0))
        .onAppear {
            if isNext {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.02
                }
            }
        }
    }
}

// MARK: - Earnings Preview

struct OnboardingEarningsPreview: View {
    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 16) {
            GlassCard(cornerRadius: 20) {
                VStack(spacing: 20) {
                    HStack {
                        Text("Today's Earnings")
                            .font(HustleFont.callout(.medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.appleGreen)
                                .frame(width: 8, height: 8)
                            Text("Live")
                                .font(HustleFont.micro(.semibold))
                                .foregroundColor(.appleGreen)
                        }
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Text("142")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.white)
                        Text(".00")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 10)

                    HustleDivider()

                    HStack(spacing: 0) {
                        earningsStatItem(label: "XP Gained", value: "+847", color: .appleOrange)
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 40)
                        earningsStatItem(label: "Tasks", value: "4", color: .hustlePrimary)
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 40)
                        earningsStatItem(label: "Hours", value: "3.5", color: .appleBlue)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateIn)
                }
                .padding(20)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Goal")
                        .font(HustleFont.callout(.medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("847 / 1000 XP")
                        .font(HustleFont.callout(.semibold))
                        .foregroundColor(.appleOrange)
                }

                GeometryReader { geo in
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .fill(Color.appleOrange)
                                .frame(width: animateIn ? geo.size.width * 0.847 : 0)
                                .shadow(color: Color.appleOrange.opacity(0.5), radius: 5)
                            , alignment: .leading
                        )
                }
                .frame(height: 8)
                .clipShape(Capsule())
                .animation(.easeOut(duration: 1.0).delay(0.5), value: animateIn)
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateIn = true
            }
        }
    }

    private func earningsStatItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(HustleFont.micro(.medium))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(HustleFont.headline(.bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#if os(iOS)
#Preview("Onboarding Carousel") {
    OnboardingCarouselScreen(
        onGetStarted: {},
        onSignIn: {}
    )
}
#endif
