// CTAStack.swift
// HustleXP UI Puzzle System — Layer 2: Molecule
// COMPOSITION: PrimaryCTA + secondary link + MotionFadeIn

import SwiftUI

/// Call-to-action stack with primary button and secondary link.
///
/// LAYER: Molecule
/// ATOMS USED: PrimaryCTA, MotionFadeIn
/// FORBIDDEN: BrandMark (belongs in BrandCluster)
public struct CTAStack: View {
    /// Primary button text
    let primaryText: String

    /// Secondary link text (optional)
    let secondaryText: String?

    /// Secondary link prefix (e.g., "Already have an account?")
    let secondaryPrefix: String?

    /// Primary button action
    let primaryAction: () -> Void

    /// Secondary link action
    let secondaryAction: (() -> Void)?

    /// Whether animations are enabled
    let animated: Bool

    /// Delay before entrance animation
    let entranceDelay: Double

    public init(
        primaryText: String,
        secondaryText: String? = nil,
        secondaryPrefix: String? = nil,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil,
        animated: Bool = true,
        entranceDelay: Double = 0
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.secondaryPrefix = secondaryPrefix
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.animated = animated
        self.entranceDelay = entranceDelay
    }

    public var body: some View {
        VStack(spacing: PuzzleGap.standard) {
            // Primary CTA
            MotionFadeIn(delay: entranceDelay, animated: animated) {
                PrimaryCTA(
                    text: primaryText,
                    backgroundColor: PuzzleColors.brandPurple,
                    showGlow: true,
                    action: primaryAction
                )
            }

            // Secondary link
            if let secondaryText = secondaryText {
                MotionFadeIn(delay: entranceDelay + PuzzleMotion.staggerIncrement, animated: animated) {
                    HStack(spacing: PuzzleGap.tiny) {
                        if let prefix = secondaryPrefix {
                            Text(prefix)
                                .foregroundColor(PuzzleColors.textDimmed)
                        }

                        Button(action: { secondaryAction?() }) {
                            Text(secondaryText)
                                .foregroundColor(PuzzleColors.textSecondary.opacity(0.6))
                                .underline()
                        }
                    }
                    .font(PuzzleTypography.secondaryCTA())
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension CTAStack {
    /// Entry screen CTA stack
    static func entry(
        onGetStarted: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        entranceDelay: Double = 0
    ) -> CTAStack {
        CTAStack(
            primaryText: "Enter the market",
            secondaryText: "Sign in",
            secondaryPrefix: "Already have an account?",
            primaryAction: onGetStarted,
            secondaryAction: onSignIn,
            entranceDelay: entranceDelay
        )
    }

    /// Single button (no secondary)
    static func single(
        text: String,
        action: @escaping () -> Void,
        entranceDelay: Double = 0
    ) -> CTAStack {
        CTAStack(
            primaryText: text,
            primaryAction: action,
            entranceDelay: entranceDelay
        )
    }
}

// MARK: - Preview

#Preview("CTAStack - Entry") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            CTAStack.entry(
                onGetStarted: {},
                onSignIn: {}
            )
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
            .padding(.bottom, PuzzleSpacing.safeAreaBottom)
        }
    }
}

#Preview("CTAStack - Single") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            CTAStack.single(text: "Continue", action: {})
                .padding(.horizontal, PuzzleSpacing.screenHorizontal)
                .padding(.bottom, PuzzleSpacing.safeAreaBottom)
        }
    }
}
