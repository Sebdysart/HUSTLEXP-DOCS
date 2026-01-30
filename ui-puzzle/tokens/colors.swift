// colors.swift
// HustleXP UI Puzzle System — Layer 0: Tokens
// STATUS: READ-ONLY — Do not modify without PER approval

import SwiftUI

// MARK: - Color Tokens

/// All colors used in HustleXP UI.
/// These are the ONLY colors Cursor may use.
/// Any color not defined here is FORBIDDEN.
public enum PuzzleColors {

    // MARK: - Brand Primary

    /// Main brand color — Teal green
    /// Use: Primary actions, success states, hustler identity
    public static let primary = Color(hex: "#1FAD7E")

    /// Brand purple — Entry screens, premium feel
    /// Use: Entry screen accents, special states
    public static let brandPurple = Color(hex: "#5B2DFF")

    /// Lighter purple — Highlights, glows
    public static let brandPurpleLight = Color(hex: "#7B4DFF")

    /// Instant mode yellow
    /// Use: Instant mode indicators, urgency
    public static let instantYellow = Color(hex: "#FFD900")

    // MARK: - Backgrounds

    /// Primary background — Pure black
    public static let backgroundPrimary = Color(hex: "#000000")

    /// Deep black — Entry screen base
    public static let backgroundDeep = Color(hex: "#050507")

    /// Standard dark — Most screens
    public static let backgroundDark = Color(hex: "#0B0B0F")

    /// Dark purple — Entry gradient top
    public static let backgroundPurple = Color(hex: "#1a0a2e")

    // MARK: - System Colors (Apple HIG)

    /// Apple Red — Errors, alerts, destructive
    public static let systemRed = Color(hex: "#FF3B30")

    /// Apple Orange — Warnings, XP, progress
    public static let systemOrange = Color(hex: "#FF9500")

    /// Apple Green — Success, money, complete
    public static let systemGreen = Color(hex: "#34C759")

    /// Apple Blue — Info, links, actions
    public static let systemBlue = Color(hex: "#007AFF")

    /// Apple Gray — Muted, disabled
    public static let systemGray = Color(hex: "#8E8E93")

    // MARK: - Text

    /// Primary text — White
    public static let textPrimary = Color.white

    /// Secondary text — Slightly dimmed
    public static let textSecondary = Color(hex: "#E5E5EA")

    /// Muted text — Disabled, hints
    public static let textMuted = Color(hex: "#8E8E93")

    /// Dimmed text — Very low emphasis
    public static let textDimmed = Color.white.opacity(0.4)

    // MARK: - Glass/Surface

    /// Glass surface — 80% opacity
    public static let glassSurface = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.8)

    /// Glass surface light — 60% opacity
    public static let glassSurfaceLight = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.6)

    /// Glass border — Subtle edge
    public static let glassBorder = Color.white.opacity(0.1)

    /// Glass border secondary — Very subtle
    public static let glassBorderSecondary = Color.white.opacity(0.05)

    // MARK: - Trust Tiers

    /// Tier 1 — Rookie/Unverified
    public static let tierRookie = Color(hex: "#71717A")

    /// Tier 2 — Verified
    public static let tierVerified = Color(hex: "#007AFF")

    /// Tier 3 — Trusted
    public static let tierTrusted = Color(hex: "#FF9500")

    /// Tier 4 — Elite/In-Home
    public static let tierElite = Color(hex: "#FFD700")

    // MARK: - Zinc Scale (Grays)

    public static let zinc200 = Color(hex: "#E4E4E7")
    public static let zinc300 = Color(hex: "#D4D4D8")
    public static let zinc400 = Color(hex: "#A1A1AA")
    public static let zinc500 = Color(hex: "#71717A")
    public static let zinc600 = Color(hex: "#52525B")
    public static let zinc700 = Color(hex: "#3F3F46")
    public static let zinc800 = Color(hex: "#27272A")
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Token Validation

/// Validates that a color is from the token system
/// Use in DEBUG builds to catch violations
public func validateColorToken(_ color: Color, file: String = #file, line: Int = #line) {
    #if DEBUG
    // In production, this would check against known token values
    // For now, it serves as documentation of the constraint
    #endif
}
