// spacing.swift
// HustleXP UI Puzzle System — Layer 0: Tokens
// STATUS: READ-ONLY — Do not modify without PER approval

import SwiftUI

// MARK: - Spacing Tokens

/// All spacing values for HustleXP UI.
/// These are the ONLY spacing values Cursor may use.
/// Any spacing not defined here is FORBIDDEN.
public enum PuzzleSpacing {

    // MARK: - Base Scale (4pt grid)

    /// 4pt — Micro spacing
    public static let xs: CGFloat = 4

    /// 8pt — Small spacing
    public static let sm: CGFloat = 8

    /// 12pt — Medium-small
    public static let md: CGFloat = 12

    /// 16pt — Medium (default)
    public static let lg: CGFloat = 16

    /// 20pt — Medium-large
    public static let xl: CGFloat = 20

    /// 24pt — Large
    public static let xxl: CGFloat = 24

    /// 32pt — Extra large
    public static let xxxl: CGFloat = 32

    /// 40pt — Huge
    public static let huge: CGFloat = 40

    /// 48pt — Massive
    public static let massive: CGFloat = 48

    // MARK: - Screen Padding

    /// Horizontal screen padding — 24pt
    public static let screenHorizontal: CGFloat = 24

    /// Horizontal screen padding small — 16pt
    public static let screenHorizontalSmall: CGFloat = 16

    /// Top safe area offset — 56pt
    public static let safeAreaTop: CGFloat = 56

    /// Bottom safe area offset — 34pt
    public static let safeAreaBottom: CGFloat = 34

    /// Bottom safe area with button — 40pt
    public static let safeAreaBottomWithButton: CGFloat = 40

    // MARK: - Component Specific

    /// Card internal padding — 20pt
    public static let cardPadding: CGFloat = 20

    /// Card internal padding small — 16pt
    public static let cardPaddingSmall: CGFloat = 16

    /// Button height — 56pt
    public static let buttonHeight: CGFloat = 56

    /// Button corner radius — 14pt
    public static let buttonRadius: CGFloat = 14

    /// Card corner radius — 16pt
    public static let cardRadius: CGFloat = 16

    /// Card corner radius large — 20pt
    public static let cardRadiusLarge: CGFloat = 20

    /// Badge corner radius — 20pt (pill)
    public static let badgeRadius: CGFloat = 20

    /// Icon container size — 44pt
    public static let iconContainer: CGFloat = 44

    /// Icon container small — 24pt
    public static let iconContainerSmall: CGFloat = 24

    /// Logo size — 72pt
    public static let logoSize: CGFloat = 72

    /// Logo corner radius — 18pt
    public static let logoRadius: CGFloat = 18

    // MARK: - Animation Offsets

    /// Entrance animation Y offset — 15pt
    public static let entranceOffset: CGFloat = 15

    /// Entrance animation Y offset large — 20pt
    public static let entranceOffsetLarge: CGFloat = 20
}

// MARK: - Gap Tokens (for stacks)

public enum PuzzleGap {
    /// Tiny gap — 4pt
    public static let tiny: CGFloat = 4

    /// Small gap — 8pt
    public static let small: CGFloat = 8

    /// Medium gap — 12pt
    public static let medium: CGFloat = 12

    /// Default gap — 16pt
    public static let standard: CGFloat = 16

    /// Large gap — 24pt
    public static let large: CGFloat = 24

    /// Section gap — 32pt
    public static let section: CGFloat = 32

    /// Major section gap — 48pt
    public static let majorSection: CGFloat = 48
}
