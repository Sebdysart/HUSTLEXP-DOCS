// EntryActionSection.swift
// HustleXP UI Puzzle System — Layer 3: Section
// PURPOSE: Answer "What do I do next?"

import SwiftUI

/// Entry screen action section.
/// Answers the question: "What do I do next?"
///
/// LAYER: Section
/// MOLECULES USED: CTAStack
/// FORBIDDEN: BrandCluster (belongs in EntryHeroSection)
public struct EntryActionSection: View {
    /// Primary button action
    let onGetStarted: () -> Void

    /// Sign in link action
    let onSignIn: () -> Void

    /// Whether animations are enabled
    let animated: Bool

    /// Delay before entrance animation
    let entranceDelay: Double

    public init(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        animated: Bool = true,
        entranceDelay: Double = 0.9
    ) {
        self.onGetStarted = onGetStarted
        self.onSignIn = onSignIn
        self.animated = animated
        self.entranceDelay = entranceDelay
    }

    public var body: some View {
        CTAStack.entry(
            onGetStarted: onGetStarted,
            onSignIn: onSignIn,
            entranceDelay: animated ? entranceDelay : 0
        )
    }
}

// MARK: - Convenience Initializers

public extension EntryActionSection {
    /// Standard action section with default delay
    static func standard(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) -> EntryActionSection {
        EntryActionSection(
            onGetStarted: onGetStarted,
            onSignIn: onSignIn
        )
    }

    /// Static version (no animations)
    static func staticAction(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) -> EntryActionSection {
        EntryActionSection(
            onGetStarted: onGetStarted,
            onSignIn: onSignIn,
            animated: false
        )
    }
}

// MARK: - Preview

#Preview("EntryActionSection") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            EntryActionSection.standard(
                onGetStarted: {},
                onSignIn: {}
            )
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
            .padding(.bottom, PuzzleSpacing.safeAreaBottom)
        }
    }
}
