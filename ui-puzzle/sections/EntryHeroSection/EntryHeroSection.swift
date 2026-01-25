// EntryHeroSection.swift
// HustleXP UI Puzzle System — Layer 3: Section
// PURPOSE: Answer "What is this app?"

import SwiftUI

/// Entry screen hero section.
/// Answers the question: "What is this app?"
///
/// LAYER: Section
/// MOLECULES USED: BrandCluster
/// ATOMS USED: TypeReveal (directly, for copy)
/// FORBIDDEN: CTAStack (belongs in EntryActionSection)
public struct EntryHeroSection: View {
    /// Headline text
    let headline: String

    /// Subhead text
    let subhead: String

    /// Whether animations are enabled
    let animated: Bool

    public init(
        headline: String = "Turn time into money.",
        subhead: String = "Post tasks and find help in minutes.\nOr earn money completing tasks nearby.",
        animated: Bool = true
    ) {
        self.headline = headline
        self.subhead = subhead
        self.animated = animated
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand cluster
            BrandCluster(
                showName: true,
                showGlow: true,
                animated: animated,
                entranceDelay: PuzzleMotion.delayMedium
            )

            Spacer().frame(height: PuzzleGap.majorSection)

            // Headline
            TypeReveal.headline(
                headline,
                delay: animated ? PuzzleMotion.delayLong : 0
            )

            Spacer().frame(height: PuzzleGap.standard)

            // Subhead
            Text(subhead)
                .font(PuzzleTypography.body())
                .foregroundColor(PuzzleColors.textSecondary.opacity(0.6))
                .lineSpacing(4)
                .motionFadeIn(
                    delay: PuzzleMotion.delayLong + PuzzleMotion.staggerIncrementLarge,
                    animated: animated
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Convenience Initializers

public extension EntryHeroSection {
    /// Standard entry hero
    static var standard: EntryHeroSection {
        EntryHeroSection()
    }

    /// Custom copy version
    static func custom(headline: String, subhead: String) -> EntryHeroSection {
        EntryHeroSection(headline: headline, subhead: subhead)
    }

    /// Static version (no animations)
    static var staticHero: EntryHeroSection {
        EntryHeroSection(animated: false)
    }
}

// MARK: - Preview

#Preview("EntryHeroSection") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            EntryHeroSection.standard
                .padding(.horizontal, PuzzleSpacing.screenHorizontal)
                .padding(.top, PuzzleSpacing.safeAreaTop)
            Spacer()
        }
    }
}
