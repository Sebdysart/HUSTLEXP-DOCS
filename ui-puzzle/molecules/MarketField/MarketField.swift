// MarketField.swift
// HustleXP UI Puzzle System — Layer 2: Molecule
// COMPOSITION: AnimatedMeshField + ParticleField + NoiseOverlay

import SwiftUI

/// Premium animated background combining mesh gradient, particles, and noise.
/// Creates the "living, breathing" market atmosphere.
///
/// LAYER: Molecule
/// ATOMS USED: AnimatedMeshField, ParticleField, NoiseOverlay
/// FORBIDDEN: GlowOrb (belongs in BrandCluster)
public struct MarketField: View {
    /// Whether animations are enabled
    let animated: Bool

    /// Whether to show particles
    let showParticles: Bool

    /// Whether to show noise overlay
    let showNoise: Bool

    public init(
        animated: Bool = true,
        showParticles: Bool = true,
        showNoise: Bool = true
    ) {
        self.animated = animated
        self.showParticles = showParticles
        self.showNoise = showNoise
    }

    public var body: some View {
        ZStack {
            // Layer 1: Animated mesh gradient
            AnimatedMeshField(
                baseColor: PuzzleColors.backgroundDeep,
                accentColor: PuzzleColors.brandPurple,
                animated: animated
            )

            // Layer 2: Floating particles
            if showParticles {
                ParticleField.purple
            }

            // Layer 3: Noise texture
            if showNoise {
                NoiseOverlay.standard
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension MarketField {
    /// Standard market field for entry screens
    static var standard: MarketField {
        MarketField()
    }

    /// Simplified (no particles) for performance
    static var simple: MarketField {
        MarketField(showParticles: false)
    }

    /// Static version for reduced motion
    static var staticField: MarketField {
        MarketField(animated: false, showParticles: false)
    }

    /// Dense version with more particles
    static var dense: MarketField {
        MarketField(showParticles: true, showNoise: true)
    }
}

// MARK: - Preview

#Preview("MarketField - Standard") {
    MarketField.standard
        .ignoresSafeArea()
}

#Preview("MarketField - Simple") {
    MarketField.simple
        .ignoresSafeArea()
}

#Preview("MarketField - Static") {
    MarketField.staticField
        .ignoresSafeArea()
}
