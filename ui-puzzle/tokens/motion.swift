// motion.swift
// HustleXP UI Puzzle System — Layer 0: Tokens
// STATUS: READ-ONLY — Do not modify without PER approval

import SwiftUI

// MARK: - Motion Tokens

/// All animation values for HustleXP UI.
/// These are the ONLY timing/easing values Cursor may use.
/// Any animation not defined here is FORBIDDEN.
public enum PuzzleMotion {

    // MARK: - Durations

    /// Instant — 0.1s (micro-interactions)
    public static let instant: Double = 0.1

    /// Fast — 0.2s (button presses, toggles)
    public static let fast: Double = 0.2

    /// Normal — 0.3s (default transitions)
    public static let normal: Double = 0.3

    /// Medium — 0.5s (content reveals)
    public static let medium: Double = 0.5

    /// Slow — 0.6s (entrance animations)
    public static let slow: Double = 0.6

    /// Dramatic — 1.0s (celebration, emphasis)
    public static let dramatic: Double = 1.0

    /// Ambient — 1.5s (background glow pulse)
    public static let ambient: Double = 1.5

    /// Atmospheric — 3.0s (breathing effects)
    public static let atmospheric: Double = 3.0

    // MARK: - Background Animation Speeds

    /// Mesh drift speed — 0.12 cycles/sec
    public static let meshDrift: Double = 0.12

    /// Particle float speed — 0.1 cycles/sec
    public static let particleFloat: Double = 0.1

    /// Glow pulse speed — 0.15 cycles/sec
    public static let glowPulse: Double = 0.15

    // MARK: - Delays

    /// No delay
    public static let delayNone: Double = 0

    /// Micro delay — 0.1s
    public static let delayMicro: Double = 0.1

    /// Short delay — 0.2s
    public static let delayShort: Double = 0.2

    /// Medium delay — 0.3s
    public static let delayMedium: Double = 0.3

    /// Long delay — 0.5s
    public static let delayLong: Double = 0.5

    /// Stagger increment — 0.1s (for sequential animations)
    public static let staggerIncrement: Double = 0.1

    /// Stagger increment large — 0.2s
    public static let staggerIncrementLarge: Double = 0.2

    // MARK: - Frame Rates

    /// Animation frame interval — 1/30 sec
    public static let frameInterval: Double = 1.0 / 30.0

    /// High quality frame interval — 1/60 sec
    public static let frameIntervalHQ: Double = 1.0 / 60.0

    // MARK: - Amplitudes (for oscillation)

    /// Small amplitude — 15pt
    public static let amplitudeSmall: CGFloat = 15

    /// Medium amplitude — 30pt
    public static let amplitudeMedium: CGFloat = 30

    /// Large amplitude — 50pt
    public static let amplitudeLarge: CGFloat = 50

    // MARK: - Scale Values

    /// Subtle scale — 1.02x
    public static let scaleSubtle: CGFloat = 1.02

    /// Normal scale — 1.05x
    public static let scaleNormal: CGFloat = 1.05

    /// Emphasis scale — 1.1x
    public static let scaleEmphasis: CGFloat = 1.1

    /// Press scale — 0.97x (button press)
    public static let scalePress: CGFloat = 0.97
}

// MARK: - Easing Curves

public enum PuzzleEasing {
    /// Standard ease out — decelerate at end
    public static let easeOut = Animation.easeOut

    /// Standard ease in — accelerate at start
    public static let easeIn = Animation.easeIn

    /// Standard ease in-out — smooth both ends
    public static let easeInOut = Animation.easeInOut

    /// Spring — bouncy feel
    public static let spring = Animation.spring(response: 0.4, dampingFraction: 0.75)

    /// Spring snappy — quicker bounce
    public static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8)

    /// Spring gentle — slower, softer
    public static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.7)

    /// Linear — constant speed (for loops)
    public static let linear = Animation.linear
}

// MARK: - Pre-built Animations

public enum PuzzleAnimation {
    /// Entrance fade + slide
    public static func entrance(delay: Double = 0) -> Animation {
        .easeOut(duration: PuzzleMotion.slow).delay(delay)
    }

    /// Button press feedback
    public static let press = Animation.easeOut(duration: PuzzleMotion.fast)

    /// Content reveal
    public static func reveal(delay: Double = 0) -> Animation {
        .easeOut(duration: PuzzleMotion.medium).delay(delay)
    }

    /// Breathing loop (for glows)
    public static let breathe = Animation.easeInOut(duration: PuzzleMotion.atmospheric).repeatForever(autoreverses: true)

    /// Pulse loop (for indicators)
    public static let pulse = Animation.easeInOut(duration: PuzzleMotion.ambient).repeatForever(autoreverses: true)

    /// Page transition
    public static let pageTransition = Animation.easeInOut(duration: PuzzleMotion.normal)

    /// Stagger sequence
    public static func stagger(index: Int, base: Double = 0) -> Animation {
        .easeOut(duration: PuzzleMotion.slow).delay(base + Double(index) * PuzzleMotion.staggerIncrement)
    }
}
