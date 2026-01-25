// BrandCluster.swift
// HustleXP UI Puzzle System — Layer 2: Molecule
// COMPOSITION: BrandMark + GlowOrb + MotionFadeIn + app name

import SwiftUI

/// Brand identity cluster with logo, glow, name, and entrance animation.
///
/// LAYER: Molecule
/// ATOMS USED: BrandMark, GlowOrb, MotionFadeIn
/// FORBIDDEN: PrimaryCTA (belongs in CTAStack)
public struct BrandCluster: View {
    /// Whether to show the app name next to logo
    let showName: Bool

    /// Whether to show the glow behind logo
    let showGlow: Bool

    /// Whether animations are enabled
    let animated: Bool

    /// Delay before entrance animation
    let entranceDelay: Double

    public init(
        showName: Bool = true,
        showGlow: Bool = true,
        animated: Bool = true,
        entranceDelay: Double = 0
    ) {
        self.showName = showName
        self.showGlow = showGlow
        self.animated = animated
        self.entranceDelay = entranceDelay
    }

    public var body: some View {
        MotionFadeIn(delay: entranceDelay, animated: animated) {
            HStack(spacing: PuzzleGap.medium) {
                ZStack {
                    // Glow behind logo
                    if showGlow {
                        GlowOrb(
                            color: PuzzleColors.brandPurple,
                            size: PuzzleSpacing.logoSize * 1.5,
                            animated: animated,
                            baseOpacity: 0.2
                        )
                    }

                    // Logo
                    BrandMark(
                        size: PuzzleSpacing.logoSize,
                        showGlow: !showGlow // Don't double glow
                    )
                }

                // App name
                if showName {
                    Text("HustleXP")
                        .font(PuzzleTypography.title2())
                        .foregroundColor(PuzzleColors.textPrimary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension BrandCluster {
    /// Standard cluster for entry screens
    static var standard: BrandCluster {
        BrandCluster()
    }

    /// Logo only (no name)
    static var logoOnly: BrandCluster {
        BrandCluster(showName: false)
    }

    /// Minimal (no glow, no animation)
    static var minimal: BrandCluster {
        BrandCluster(showGlow: false, animated: false)
    }

    /// Header version (smaller, no glow)
    static var header: BrandCluster {
        BrandCluster(showGlow: false)
    }
}

// MARK: - Preview

#Preview("BrandCluster - Standard") {
    ZStack {
        Color.black.ignoresSafeArea()
        BrandCluster.standard
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}

#Preview("BrandCluster - Logo Only") {
    ZStack {
        Color.black.ignoresSafeArea()
        BrandCluster.logoOnly
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}

#Preview("BrandCluster - Minimal") {
    ZStack {
        Color.black.ignoresSafeArea()
        BrandCluster.minimal
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}
