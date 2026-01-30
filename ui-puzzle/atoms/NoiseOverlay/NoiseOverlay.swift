// NoiseOverlay.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Grain texture overlay for premium feel

import SwiftUI

/// Subtle noise/grain texture overlay.
/// Adds premium fintech feel to backgrounds.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleShadows.MeshOpacity
/// IMPORTS: None (atoms cannot import other atoms)
public struct NoiseOverlay: View {
    /// Density of noise (0.0 to 1.0, default 0.008)
    let density: Double

    /// Minimum opacity for noise particles
    let opacityMin: Double

    /// Maximum opacity for noise particles
    let opacityMax: Double

    public init(
        density: Double = 0.008,
        opacityMin: Double = PuzzleShadows.MeshOpacity.noiseMin,
        opacityMax: Double = PuzzleShadows.MeshOpacity.noiseMax
    ) {
        self.density = density
        self.opacityMin = opacityMin
        self.opacityMax = opacityMax
    }

    public var body: some View {
        Canvas { context, size in
            let particleCount = Int(size.width * size.height * density)

            for _ in 0..<particleCount {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: opacityMin...opacityMax)

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

// MARK: - Convenience Initializers

public extension NoiseOverlay {
    /// Standard noise for backgrounds
    static var standard: NoiseOverlay {
        NoiseOverlay()
    }

    /// Subtle noise for cards
    static var subtle: NoiseOverlay {
        NoiseOverlay(density: 0.005, opacityMin: 0.01, opacityMax: 0.03)
    }

    /// Heavy noise for dramatic effect
    static var heavy: NoiseOverlay {
        NoiseOverlay(density: 0.012, opacityMin: 0.03, opacityMax: 0.07)
    }
}

// MARK: - Preview

#Preview("NoiseOverlay - Standard") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#1a0a2e"), Color.black],
            startPoint: .top,
            endPoint: .bottom
        )
        NoiseOverlay.standard
    }
    .ignoresSafeArea()
}

#Preview("NoiseOverlay - Heavy") {
    ZStack {
        Color.black
        NoiseOverlay.heavy
    }
    .ignoresSafeArea()
}
