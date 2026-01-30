// EntryScreen.swift
// HustleXP UI Puzzle System — Layer 4: Screen
// ASSEMBLY: MarketField + EntryHeroSection + EntryActionSection

import SwiftUI

/// Entry screen — the first screen users see.
/// Pure assembly of pre-approved sections. No new concepts.
///
/// LAYER: Screen (Assembly Only)
/// SECTIONS USED: EntryHeroSection, EntryActionSection
/// MOLECULES USED: MarketField (as background)
/// NEW ATOMS: NONE
/// NEW MOLECULES: NONE
/// NEW COPY: NONE
/// NEW MOTION: NONE
@available(iOS 14.0, *)
@available(macOS, unavailable)
public struct PuzzleEntryScreen: View {
    /// Callback when user taps "Enter the market"
    let onGetStarted: () -> Void

    /// Callback when user taps "Sign in"
    let onSignIn: () -> Void

    /// Whether to enable animations
    let animated: Bool

    public init(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        animated: Bool = true
    ) {
        self.onGetStarted = onGetStarted
        self.onSignIn = onSignIn
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            // Background: MarketField molecule
            MarketField(
                animated: animated,
                showParticles: true,
                showNoise: true
            )
            .ignoresSafeArea()

            // Content: Sections
            VStack(spacing: 0) {
                // Hero section (top)
                EntryHeroSection(animated: animated)
                    .padding(.horizontal, PuzzleSpacing.screenHorizontal)
                    .padding(.top, PuzzleSpacing.safeAreaTop)

                Spacer()

                // Action section (bottom)
                EntryActionSection(
                    onGetStarted: onGetStarted,
                    onSignIn: onSignIn,
                    animated: animated
                )
                .padding(.horizontal, PuzzleSpacing.screenHorizontal)
                .padding(.bottom, PuzzleSpacing.safeAreaBottom)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#if os(iOS)
#Preview("PuzzleEntryScreen") {
    PuzzleEntryScreen(
        onGetStarted: { print("Get Started") },
        onSignIn: { print("Sign In") }
    )
}

#Preview("PuzzleEntryScreen - Static") {
    PuzzleEntryScreen(
        onGetStarted: {},
        onSignIn: {},
        animated: false
    )
}
#endif
