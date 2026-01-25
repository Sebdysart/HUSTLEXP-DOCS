// MotionFadeIn.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Entrance animation wrapper (fade + slide)

import SwiftUI

/// Entrance animation wrapper.
/// Applies fade-in with upward slide to any content.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleMotion, PuzzleSpacing
/// IMPORTS: None (atoms cannot import other atoms)
public struct MotionFadeIn<Content: View>: View {
    /// Content to animate
    let content: Content

    /// Delay before animation starts
    let delay: Double

    /// Whether animation is enabled
    let animated: Bool

    /// Vertical offset for slide (positive = start below)
    let offset: CGFloat

    @State private var isVisible = false

    public init(
        delay: Double = 0,
        animated: Bool = true,
        offset: CGFloat = PuzzleSpacing.entranceOffset,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.delay = delay
        self.animated = animated
        self.offset = offset
    }

    public var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offset)
            .onAppear {
                if animated {
                    withAnimation(PuzzleAnimation.entrance(delay: delay)) {
                        isVisible = true
                    }
                } else {
                    isVisible = true
                }
            }
    }
}

// MARK: - View Extension

public extension View {
    /// Apply fade-in entrance animation
    func motionFadeIn(delay: Double = 0, animated: Bool = true) -> some View {
        MotionFadeIn(delay: delay, animated: animated) {
            self
        }
    }

    /// Apply staggered fade-in (for lists)
    func motionFadeInStaggered(index: Int, baseDelay: Double = 0, animated: Bool = true) -> some View {
        MotionFadeIn(
            delay: baseDelay + Double(index) * PuzzleMotion.staggerIncrement,
            animated: animated
        ) {
            self
        }
    }
}

// MARK: - Preview

#Preview("MotionFadeIn - Single") {
    ZStack {
        Color.black.ignoresSafeArea()
        MotionFadeIn(delay: 0.2) {
            Text("Hello, World!")
                .font(PuzzleTypography.display())
                .foregroundColor(.white)
        }
    }
}

#Preview("MotionFadeIn - Staggered") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            ForEach(0..<5) { index in
                Text("Item \(index)")
                    .font(PuzzleTypography.headline())
                    .foregroundColor(.white)
                    .motionFadeInStaggered(index: index, baseDelay: 0.2)
            }
        }
    }
}

#Preview("MotionFadeIn - Static") {
    ZStack {
        Color.black.ignoresSafeArea()
        MotionFadeIn(animated: false) {
            Text("No Animation")
                .font(PuzzleTypography.headline())
                .foregroundColor(.white)
        }
    }
}
