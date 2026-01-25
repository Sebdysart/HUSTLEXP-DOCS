// AnimatedMeshField.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Drifting gradient background with smooth color blending

import SwiftUI

/// Animated mesh gradient background.
/// Creates smooth, drifting color fields with no visible shapes.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleColors, PuzzleMotion, PuzzleShadows
/// IMPORTS: None (atoms cannot import other atoms)
public struct AnimatedMeshField: View {
    /// Base color for the deepest layer
    let baseColor: Color

    /// Accent color for the gradient points
    let accentColor: Color

    /// Whether to animate (set false for reduced motion)
    let animated: Bool

    public init(
        baseColor: Color = PuzzleColors.backgroundDeep,
        accentColor: Color = PuzzleColors.brandPurple,
        animated: Bool = true
    ) {
        self.baseColor = baseColor
        self.accentColor = accentColor
        self.animated = animated
    }

    public var body: some View {
        if animated {
            TimelineView(.animation(minimumInterval: PuzzleMotion.frameInterval)) { timeline in
                Canvas { context, size in
                    drawMesh(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
        } else {
            Canvas { context, size in
                drawMesh(context: context, size: size, time: 0)
            }
        }
    }

    private func drawMesh(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        // Layer 0: Base fill
        context.fill(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(baseColor)
        )

        // Layer 1: Ambient haze (deep, subtle)
        context.drawLayer { ctx in
            ctx.addFilter(.blur(radius: PuzzleShadows.Values.ambientBlur))

            let ambientPoints: [(x: CGFloat, y: CGFloat, opacity: Double, pointSize: CGFloat)] = [
                (0.2, 0.1, PuzzleShadows.MeshOpacity.ambient, 350),
                (0.8, 0.25, PuzzleShadows.MeshOpacity.accentHigh, 300),
                (0.5, 0.6, PuzzleShadows.MeshOpacity.accentLow, 400),
                (0.15, 0.85, PuzzleShadows.MeshOpacity.accentHigh, 320),
            ]

            for point in ambientPoints {
                let x = point.x * size.width
                let y = point.y * size.height
                ctx.fill(
                    Ellipse().path(in: CGRect(
                        x: x - point.pointSize / 2,
                        y: y - point.pointSize / 2,
                        width: point.pointSize,
                        height: point.pointSize
                    )),
                    with: .color(PuzzleColors.backgroundPurple.opacity(point.opacity))
                )
            }
        }

        // Layer 2: Drifting accent points
        context.drawLayer { ctx in
            ctx.addFilter(.blur(radius: PuzzleShadows.Values.accentBlur))

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
                let drift = sin(time * PuzzleMotion.meshDrift + point.phase) * PuzzleMotion.amplitudeMedium
                let driftY = cos(time * PuzzleMotion.meshDrift * 0.8 + point.phase * 0.8) * PuzzleMotion.amplitudeMedium * 0.85

                let x = point.baseX * size.width + drift
                let y = point.baseY * size.height + driftY

                let pointSize: CGFloat = CGFloat(60 + (i % 3) * 30)
                let opacity = PuzzleShadows.MeshOpacity.accentLow + Double(i % 3) * 0.04

                ctx.fill(
                    Ellipse().path(in: CGRect(
                        x: x - pointSize / 2,
                        y: y - pointSize / 2,
                        width: pointSize,
                        height: pointSize
                    )),
                    with: .color(accentColor.opacity(opacity))
                )
            }
        }

        // Layer 3: Bright highlight
        context.drawLayer { ctx in
            ctx.addFilter(.blur(radius: PuzzleShadows.Values.highlightBlur))

            let highlightX = size.width * 0.35 + sin(time * PuzzleMotion.glowPulse) * PuzzleMotion.amplitudeSmall
            let highlightY = size.height * 0.22 + cos(time * PuzzleMotion.meshDrift) * PuzzleMotion.amplitudeSmall

            ctx.fill(
                Ellipse().path(in: CGRect(
                    x: highlightX - 40,
                    y: highlightY - 40,
                    width: 80,
                    height: 80
                )),
                with: .color(PuzzleColors.brandPurpleLight.opacity(PuzzleShadows.MeshOpacity.highlight))
            )
        }
    }
}

// MARK: - Preview

#Preview("AnimatedMeshField") {
    AnimatedMeshField()
        .ignoresSafeArea()
}

#Preview("AnimatedMeshField - Static") {
    AnimatedMeshField(animated: false)
        .ignoresSafeArea()
}
