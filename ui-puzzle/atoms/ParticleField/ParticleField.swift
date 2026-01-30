// ParticleField.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Floating particles (opportunity rising)

import SwiftUI

/// Floating particles that drift upward.
/// Semantic meaning: "opportunity rising"
///
/// LAYER: Atom
/// TOKENS USED: PuzzleColors, PuzzleMotion
/// IMPORTS: None (atoms cannot import other atoms)
public struct ParticleField: View {
    /// Color of the particles
    let color: Color

    /// Number of particles
    let count: Int

    /// Whether to animate
    let animated: Bool

    public init(
        color: Color = PuzzleColors.brandPurpleLight,
        count: Int = 18,
        animated: Bool = true
    ) {
        self.color = color
        self.count = count
        self.animated = animated
    }

    public var body: some View {
        if animated {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                Canvas { context, size in
                    drawParticles(
                        context: context,
                        size: size,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            }
        } else {
            Canvas { context, size in
                drawParticles(context: context, size: size, time: 0)
            }
        }
    }

    private func drawParticles(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        for i in 0..<count {
            // Golden angle distribution for natural spread
            let seed = Double(i) * 137.508

            let x = (sin(seed) * 0.5 + 0.5) * size.width
            let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height

            // Slow upward drift
            let cycleLength: Double = 25 + Double(i % 5) * 5
            let progress = (time / cycleLength).truncatingRemainder(dividingBy: 1.0)
            let y = baseY - CGFloat(progress) * size.height
            let adjustedY = y < 0 ? y + size.height : y

            // Tiny particles (1-3pt)
            let particleSize: CGFloat = 1 + CGFloat(i % 3)

            // Fade at edges
            let fadeFromEdge = min(
                adjustedY / (size.height * 0.2),
                (size.height - adjustedY) / (size.height * 0.2),
                1.0
            )
            let opacity = 0.3 * fadeFromEdge

            context.fill(
                Circle().path(in: CGRect(
                    x: x - particleSize / 2,
                    y: adjustedY - particleSize / 2,
                    width: particleSize,
                    height: particleSize
                )),
                with: .color(color.opacity(opacity))
            )
        }
    }
}

// MARK: - Convenience Initializers

public extension ParticleField {
    /// Purple particles for entry screens
    static var purple: ParticleField {
        ParticleField(color: PuzzleColors.brandPurpleLight, count: 18)
    }

    /// Primary (teal) particles
    static var primary: ParticleField {
        ParticleField(color: PuzzleColors.primary, count: 15)
    }

    /// Dense particle field
    static var dense: ParticleField {
        ParticleField(count: 30)
    }

    /// Sparse particle field
    static var sparse: ParticleField {
        ParticleField(count: 10)
    }
}

// MARK: - Preview

#Preview("ParticleField - Purple") {
    ZStack {
        Color.black.ignoresSafeArea()
        ParticleField.purple
    }
}

#Preview("ParticleField - Dense") {
    ZStack {
        Color.black.ignoresSafeArea()
        ParticleField.dense
    }
}

#Preview("ParticleField - Static") {
    ZStack {
        Color.black.ignoresSafeArea()
        ParticleField(animated: false)
    }
}
