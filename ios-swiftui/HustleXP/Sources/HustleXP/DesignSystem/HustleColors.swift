// HustleColors.swift
// HustleXP Design System - Color Tokens
// Source: STITCH HTML specifications + tokens/colors.json

import SwiftUI

// MARK: - HustleXP Color Palette

public extension Color {

    // MARK: - Primary Colors

    /// Primary brand color - Teal green
    static let hustlePrimary = Color(hex: "#1FAD7E")

    /// Primary action yellow (instant mode)
    static let hustleYellow = Color(hex: "#FFD900")

    // MARK: - Apple System Colors (iOS Native)

    /// Apple Red - Alerts, errors, urgent
    static let appleRed = Color(hex: "#FF3B30")

    /// Apple Orange - Warnings, progress, XP
    static let appleOrange = Color(hex: "#FF9500")

    /// Apple Green - Success, complete, money
    static let appleGreen = Color(hex: "#34C759")

    /// Apple Blue - Info, links, actions
    static let appleBlue = Color(hex: "#007AFF")

    /// Apple Gray - Muted text, disabled
    static let appleGray = Color(hex: "#8E8E93")

    // MARK: - Background Colors

    /// Primary dark background
    static let hustleBackgroundDark = Color(hex: "#000000")

    /// Light background (unused in dark mode)
    static let hustleBackgroundLight = Color(hex: "#F2F2F3")

    // MARK: - Glass/Surface Colors

    /// Glass panel surface (80% opacity)
    static let glassSurface = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.8)

    /// Glass panel surface lighter (60% opacity)
    static let glassSurfaceLight = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.6)

    /// Glass panel surface lighter (40% opacity)
    static let glassSurfaceUltraLight = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.4)

    /// Glass border primary
    static let glassBorder = Color.white.opacity(0.1)

    /// Glass border secondary (subtle)
    static let glassBorderSecondary = Color.white.opacity(0.05)

    // MARK: - Text Colors

    /// Primary text color
    static let hustleTextPrimary = Color.white

    /// Secondary text color
    static let hustleTextSecondary = Color(hex: "#E5E5EA")

    /// Muted/disabled text
    static let hustleTextMuted = Color(hex: "#8E8E93")

    /// Zinc gray variants
    static let zinc200 = Color(hex: "#E4E4E7")
    static let zinc300 = Color(hex: "#D4D4D8")
    static let zinc400 = Color(hex: "#A1A1AA")
    static let zinc500 = Color(hex: "#71717A")
    static let zinc600 = Color(hex: "#52525B")
    static let zinc700 = Color(hex: "#3F3F46")
    static let zinc800 = Color(hex: "#27272A")

    // MARK: - Trust Tier Colors

    /// Tier 1 - Rookie/Unverified
    static let tierRookie = Color(hex: "#71717A")

    /// Tier 2 - Verified
    static let tierVerified = Color(hex: "#007AFF")

    /// Tier 3 - Trusted
    static let tierTrusted = Color(hex: "#FF9500")

    /// Tier 4 - Elite/In-Home
    static let tierElite = Color(hex: "#FFD700")
}

// MARK: - Hex Color Initializer

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
