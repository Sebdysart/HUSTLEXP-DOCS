// GlowOrb.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Pulsing glow effect (breathing light)

import SwiftUI

/// Pulsing glow effect that creates a "breathing" light.
/// Used behind brand marks, CTAs, and focal points.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleColors, PuzzleMotion, PuzzleShadows
/// IMPORTS: None (atoms cannot import other atoms)
public struct GlowOrb: View {
    /// Color of the glow
    let color: Color

    /// Size of the glow orb
    let size: CGFloat

    /// Whether to animate the pulse
    let animated: Bool

    /// Base opacity (will pulse between this and +0.2)
    let baseOpacity: Double

    @State private var isPulsing = false

    public init(
        color: Color = PuzzleColors.brandPurple,
        size: CGFloat = 200,
        animated: Bool = true,
        baseOpacity: Double = 0.3
    ) {
        self.color = color
        self.size = size
        self.animated = animated
        self.baseOpacity = baseOpacity
    }

    public var body: some View {
        ZStack {
            // Outer glow (larger, softer)
            Circle()
                .fill(color)
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: size * 0.4)
                .opacity(isPulsing ? baseOpacity + 0.1 : baseOpacity)

            // Inner glow (smaller, brighter)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .blur(radius: size * 0.25)
                .opacity(isPulsing ? baseOpacity + 0.2 : baseOpacity + 0.1)
        }
        .scaleEffect(isPulsing ? PuzzleMotion.scaleSubtle : 1.0)
        .onAppear {
            if animated {
                withAnimation(PuzzleAnimation.breathe) {
                    isPulsing = true
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension GlowOrb {
    /// Purple glow for entry screens
    static func purple(size: CGFloat = 200, animated: Bool = true) -> GlowOrb {
        GlowOrb(
            color: PuzzleColors.brandPurple,
            size: size,
            animated: animated,
            baseOpacity: 0.3
        )
    }

    /// Primary (teal) glow for success states
    static func primary(size: CGFloat = 150, animated: Bool = true) -> GlowOrb {
        GlowOrb(
            color: PuzzleColors.primary,
            size: size,
            animated: animated,
            baseOpacity: 0.25
        )
    }

    /// Orange glow for XP/progress
    static func orange(size: CGFloat = 100, animated: Bool = true) -> GlowOrb {
        GlowOrb(
            color: PuzzleColors.systemOrange,
            size: size,
            animated: animated,
            baseOpacity: 0.25
        )
    }
}

// MARK: - Preview

#Preview("GlowOrb - Purple") {
    ZStack {
        Color.black.ignoresSafeArea()
        GlowOrb.purple()
    }
}

#Preview("GlowOrb - Primary") {
    ZStack {
        Color.black.ignoresSafeArea()
        GlowOrb.primary()
    }
}

#Preview("GlowOrb - Static") {
    ZStack {
        Color.black.ignoresSafeArea()
        GlowOrb(animated: false)
    }
}
