// HustleTypography.swift
// HustleXP Design System - Typography Tokens
// Source: STITCH HTML specifications

import SwiftUI

// MARK: - HustleXP Typography

public struct HustleFont {

    // MARK: - Display Fonts (Headers, Titles)

    /// Display - Large hero text (36px)
    public static func display(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 36, weight: weight, design: .default)
    }

    /// Title 1 - Main titles (28px)
    public static func title1(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 28, weight: weight, design: .default)
    }

    /// Title 2 - Section headers (24px)
    public static func title2(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 24, weight: weight, design: .default)
    }

    /// Title 3 - Subsection headers (20px)
    public static func title3(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 20, weight: weight, design: .default)
    }

    // MARK: - Body Fonts

    /// Headline - Emphasized body (18px)
    public static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 18, weight: weight, design: .default)
    }

    /// Body - Primary content (16px)
    public static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 16, weight: weight, design: .default)
    }

    /// Callout - Secondary content (14px)
    public static func callout(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 14, weight: weight, design: .default)
    }

    // MARK: - Small Fonts

    /// Caption - Labels, metadata (12px)
    public static func caption(_ weight: Font.Weight = .medium) -> Font {
        .system(size: 12, weight: weight, design: .default)
    }

    /// Micro - Tiny labels, badges (10px)
    public static func micro(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 10, weight: weight, design: .default)
    }

    // MARK: - Special Fonts

    /// Monospace - Code, IDs, timestamps
    public static func mono(_ size: CGFloat = 12, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Tabular numbers - For timers, prices
    public static func tabular(_ size: CGFloat = 36, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
            .monospacedDigit()
    }
}

// MARK: - Typography View Modifiers

public extension View {

    /// Display style - Hero text
    func hustleDisplay() -> some View {
        self.font(HustleFont.display())
            .tracking(-0.5)
    }

    /// Title style - Main headers
    func hustleTitle() -> some View {
        self.font(HustleFont.title1())
            .tracking(-0.3)
    }

    /// Section header style
    func hustleSectionHeader() -> some View {
        self.font(HustleFont.micro(.bold))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundColor(.hustleTextMuted)
    }

    /// Body text style
    func hustleBody() -> some View {
        self.font(HustleFont.body())
            .foregroundColor(.hustleTextPrimary)
    }

    /// Muted text style
    func hustleMuted() -> some View {
        self.font(HustleFont.callout())
            .foregroundColor(.hustleTextMuted)
    }

    /// Badge/chip text style
    func hustleBadge() -> some View {
        self.font(HustleFont.micro(.bold))
            .tracking(1)
            .textCase(.uppercase)
    }
}
