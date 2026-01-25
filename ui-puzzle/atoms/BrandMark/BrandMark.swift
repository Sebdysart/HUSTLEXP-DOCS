// BrandMark.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: The "H" logo mark

import SwiftUI

/// The HustleXP "H" logo mark.
/// A rounded square with the letter H.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleColors, PuzzleSpacing, PuzzleShadows
/// IMPORTS: None (atoms cannot import other atoms)
public struct BrandMark: View {
    /// Size of the logo (width and height)
    let size: CGFloat

    /// Background color
    let backgroundColor: Color

    /// Text color
    let textColor: Color

    /// Whether to show the glow shadow
    let showGlow: Bool

    public init(
        size: CGFloat = PuzzleSpacing.logoSize,
        backgroundColor: Color = PuzzleColors.brandPurple,
        textColor: Color = PuzzleColors.textPrimary,
        showGlow: Bool = true
    ) {
        self.size = size
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.showGlow = showGlow
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: size * 0.25)
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay(
                Text("H")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(textColor)
            )
            .if(showGlow) { view in
                view.shadow(
                    color: PuzzleShadows.Values.purpleColor,
                    radius: PuzzleShadows.Values.purpleRadius,
                    y: PuzzleShadows.Values.purpleY
                )
            }
    }
}

// MARK: - Conditional Modifier

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Convenience Initializers

public extension BrandMark {
    /// Standard logo for entry screens
    static var standard: BrandMark {
        BrandMark()
    }

    /// Small logo for headers
    static var small: BrandMark {
        BrandMark(size: 44, showGlow: false)
    }

    /// Large logo for splash/celebration
    static var large: BrandMark {
        BrandMark(size: 100)
    }

    /// Primary (teal) version
    static var primary: BrandMark {
        BrandMark(backgroundColor: PuzzleColors.primary)
    }
}

// MARK: - Preview

#Preview("BrandMark - Standard") {
    ZStack {
        Color.black.ignoresSafeArea()
        BrandMark.standard
    }
}

#Preview("BrandMark - Sizes") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 24) {
            BrandMark.small
            BrandMark.standard
            BrandMark.large
        }
    }
}

#Preview("BrandMark - No Glow") {
    ZStack {
        Color.black.ignoresSafeArea()
        BrandMark(showGlow: false)
    }
}
