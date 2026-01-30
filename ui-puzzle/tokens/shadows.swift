// shadows.swift
// HustleXP UI Puzzle System — Layer 0: Tokens
// STATUS: READ-ONLY — Do not modify without PER approval

import SwiftUI

// MARK: - Shadow Tokens

/// All shadow definitions for HustleXP UI.
/// These are the ONLY shadow configurations Cursor may use.
/// Any shadow not defined here is FORBIDDEN.
public enum PuzzleShadows {

    // MARK: - Glow Shadows (colored)

    /// Primary glow — Teal
    /// Use: Primary buttons, success states
    public static func primaryGlow(radius: CGFloat = 20) -> some View {
        Color.clear
            .shadow(color: PuzzleColors.primary.opacity(0.4), radius: radius, y: 5)
    }

    /// Brand purple glow
    /// Use: Entry screen CTA, special actions
    public static func purpleGlow(radius: CGFloat = 20) -> some View {
        Color.clear
            .shadow(color: PuzzleColors.brandPurple.opacity(0.4), radius: radius, y: 5)
    }

    /// Orange glow
    /// Use: XP indicators, progress
    public static func orangeGlow(radius: CGFloat = 10) -> some View {
        Color.clear
            .shadow(color: PuzzleColors.systemOrange.opacity(0.5), radius: radius)
    }

    // MARK: - Shadow Values (for manual application)

    public enum Values {
        // MARK: Glow Shadows

        /// Primary glow values
        public static let primaryColor = PuzzleColors.primary.opacity(0.4)
        public static let primaryRadius: CGFloat = 20
        public static let primaryY: CGFloat = 5

        /// Purple glow values
        public static let purpleColor = PuzzleColors.brandPurple.opacity(0.4)
        public static let purpleRadius: CGFloat = 20
        public static let purpleY: CGFloat = 5

        /// Purple glow subtle
        public static let purpleSubtleColor = PuzzleColors.brandPurple.opacity(0.3)
        public static let purpleSubtleRadius: CGFloat = 10

        /// Orange glow values
        public static let orangeColor = PuzzleColors.systemOrange.opacity(0.5)
        public static let orangeRadius: CGFloat = 10

        // MARK: Blur Shadows (for mesh gradients)

        /// Ambient blur — very large, very soft
        public static let ambientBlur: CGFloat = 180

        /// Accent blur — large, soft
        public static let accentBlur: CGFloat = 100

        /// Highlight blur — medium
        public static let highlightBlur: CGFloat = 50

        /// Tight blur — focused glow
        public static let tightBlur: CGFloat = 25

        // MARK: Elevation Shadows

        /// Card elevation
        public static let cardColor = Color.black.opacity(0.3)
        public static let cardRadius: CGFloat = 10
        public static let cardY: CGFloat = 4

        /// Floating element
        public static let floatingColor = Color.black.opacity(0.4)
        public static let floatingRadius: CGFloat = 20
        public static let floatingY: CGFloat = 10

        /// Subtle elevation
        public static let subtleColor = Color.black.opacity(0.2)
        public static let subtleRadius: CGFloat = 5
        public static let subtleY: CGFloat = 2
    }

    // MARK: - Opacity Values for Mesh Gradients

    public enum MeshOpacity {
        /// Ambient layer (background haze)
        public static let ambient: Double = 0.25

        /// Accent layer (color points)
        public static let accent: Double = 0.15

        /// Accent layer variation
        public static let accentLow: Double = 0.12
        public static let accentHigh: Double = 0.20

        /// Highlight layer (bright spots)
        public static let highlight: Double = 0.20

        /// Noise overlay
        public static let noiseMin: Double = 0.02
        public static let noiseMax: Double = 0.05
    }
}

// MARK: - View Modifier for Common Shadows

public struct PuzzleShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    public func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

public extension View {
    /// Apply primary glow shadow
    func puzzlePrimaryGlow() -> some View {
        self.shadow(
            color: PuzzleShadows.Values.primaryColor,
            radius: PuzzleShadows.Values.primaryRadius,
            y: PuzzleShadows.Values.primaryY
        )
    }

    /// Apply purple glow shadow
    func puzzlePurpleGlow() -> some View {
        self.shadow(
            color: PuzzleShadows.Values.purpleColor,
            radius: PuzzleShadows.Values.purpleRadius,
            y: PuzzleShadows.Values.purpleY
        )
    }

    /// Apply card elevation shadow
    func puzzleCardShadow() -> some View {
        self.shadow(
            color: PuzzleShadows.Values.cardColor,
            radius: PuzzleShadows.Values.cardRadius,
            y: PuzzleShadows.Values.cardY
        )
    }
}
