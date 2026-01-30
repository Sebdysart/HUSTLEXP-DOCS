// typography.swift
// HustleXP UI Puzzle System — Layer 0: Tokens
// STATUS: READ-ONLY — Do not modify without PER approval

import SwiftUI

// MARK: - Typography Tokens

/// All typography definitions for HustleXP UI.
/// These are the ONLY font configurations Cursor may use.
/// Any font not defined here is FORBIDDEN.
public enum PuzzleTypography {

    // MARK: - Display (Hero headlines)

    /// Display — 36pt Bold
    /// Use: Entry screen headlines, celebration screens
    public static func display() -> Font {
        .system(size: 36, weight: .bold)
    }

    // MARK: - Titles

    /// Title 1 — 28pt Bold
    /// Use: Screen titles, major headings
    public static func title1() -> Font {
        .system(size: 28, weight: .bold)
    }

    /// Title 2 — 24pt Semibold
    /// Use: Section headers, card titles
    public static func title2() -> Font {
        .system(size: 24, weight: .semibold)
    }

    /// Title 3 — 20pt Semibold
    /// Use: Subsection headers
    public static func title3() -> Font {
        .system(size: 20, weight: .semibold)
    }

    // MARK: - Body

    /// Headline — 18pt Semibold
    /// Use: Important labels, stat values
    public static func headline() -> Font {
        .system(size: 18, weight: .semibold)
    }

    /// Body — 16pt Regular
    /// Use: Default text, descriptions
    public static func body() -> Font {
        .system(size: 16, weight: .regular)
    }

    /// Body Bold — 16pt Semibold
    /// Use: Emphasized body text
    public static func bodyBold() -> Font {
        .system(size: 16, weight: .semibold)
    }

    // MARK: - Supporting

    /// Callout — 14pt Regular
    /// Use: Secondary information, captions
    public static func callout() -> Font {
        .system(size: 14, weight: .regular)
    }

    /// Callout Medium — 14pt Medium
    /// Use: Labels, form fields
    public static func calloutMedium() -> Font {
        .system(size: 14, weight: .medium)
    }

    /// Callout Semibold — 14pt Semibold
    /// Use: Emphasized secondary text
    public static func calloutSemibold() -> Font {
        .system(size: 14, weight: .semibold)
    }

    // MARK: - Small

    /// Caption — 12pt Medium
    /// Use: Timestamps, metadata
    public static func caption() -> Font {
        .system(size: 12, weight: .medium)
    }

    /// Micro — 10pt Semibold
    /// Use: Badges, tier labels, all-caps text
    public static func micro() -> Font {
        .system(size: 10, weight: .semibold)
    }

    /// Micro Bold — 10pt Bold
    /// Use: Status indicators
    public static func microBold() -> Font {
        .system(size: 10, weight: .bold)
    }

    // MARK: - CTA Specific

    /// CTA Text — 17pt Semibold
    /// Use: Primary button text
    public static func ctaText() -> Font {
        .system(size: 17, weight: .semibold)
    }

    /// Secondary CTA — 15pt Regular
    /// Use: Secondary links, "Sign in" links
    public static func secondaryCTA() -> Font {
        .system(size: 15, weight: .regular)
    }

    // MARK: - Monospace (for numbers)

    /// Monospace Large — 56pt Bold
    /// Use: Large earnings display ($142)
    public static func monoLarge() -> Font {
        .system(size: 56, weight: .bold, design: .default)
    }

    /// Monospace Medium — 32pt Bold
    /// Use: Dollar signs, cents
    public static func monoMedium() -> Font {
        .system(size: 32, weight: .bold, design: .default)
    }
}

// MARK: - Line Height Tokens

public enum PuzzleLineHeight {
    /// Tight — 1.1x
    public static let tight: CGFloat = 1.1

    /// Normal — 1.3x
    public static let normal: CGFloat = 1.3

    /// Relaxed — 1.5x
    public static let relaxed: CGFloat = 1.5

    /// Loose — 1.7x (multi-line body)
    public static let loose: CGFloat = 1.7
}

// MARK: - Letter Spacing Tokens

public enum PuzzleLetterSpacing {
    /// Tight — -0.5pt
    public static let tight: CGFloat = -0.5

    /// Normal — 0pt
    public static let normal: CGFloat = 0

    /// Wide — 1pt (micro text)
    public static let wide: CGFloat = 1

    /// Extra Wide — 2pt (all-caps labels)
    public static let extraWide: CGFloat = 2
}
