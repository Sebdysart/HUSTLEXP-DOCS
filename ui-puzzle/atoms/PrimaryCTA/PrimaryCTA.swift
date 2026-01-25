// PrimaryCTA.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Main action button

import SwiftUI

/// Primary call-to-action button.
/// Full-width, prominent, with optional glow.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleColors, PuzzleSpacing, PuzzleTypography, PuzzleShadows, PuzzleMotion
/// IMPORTS: None (atoms cannot import other atoms)
public struct PrimaryCTA: View {
    /// Button text
    let text: String

    /// Background color
    let backgroundColor: Color

    /// Whether to show the glow
    let showGlow: Bool

    /// Action callback
    let action: () -> Void

    @State private var isPressed = false

    public init(
        text: String,
        backgroundColor: Color = PuzzleColors.brandPurple,
        showGlow: Bool = true,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.showGlow = showGlow
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(text)
                .font(PuzzleTypography.ctaText())
                .foregroundColor(PuzzleColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: PuzzleSpacing.buttonHeight)
                .background(backgroundColor)
                .cornerRadius(PuzzleSpacing.buttonRadius)
        }
        .buttonStyle(PrimaryCTAButtonStyle(
            backgroundColor: backgroundColor,
            showGlow: showGlow
        ))
    }
}

// MARK: - Button Style

private struct PrimaryCTAButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let showGlow: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? PuzzleMotion.scalePress : 1.0)
            .animation(PuzzleAnimation.press, value: configuration.isPressed)
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

public extension PrimaryCTA {
    /// Entry screen CTA
    static func entry(action: @escaping () -> Void) -> PrimaryCTA {
        PrimaryCTA(
            text: "Enter the market",
            backgroundColor: PuzzleColors.brandPurple,
            showGlow: true,
            action: action
        )
    }

    /// Primary (teal) CTA
    static func primary(text: String, action: @escaping () -> Void) -> PrimaryCTA {
        PrimaryCTA(
            text: text,
            backgroundColor: PuzzleColors.primary,
            showGlow: true,
            action: action
        )
    }

    /// Instant mode CTA
    static func instant(text: String, action: @escaping () -> Void) -> PrimaryCTA {
        PrimaryCTA(
            text: text,
            backgroundColor: PuzzleColors.instantYellow,
            showGlow: false,
            action: action
        )
    }
}

// MARK: - Preview

#Preview("PrimaryCTA - Entry") {
    ZStack {
        Color.black.ignoresSafeArea()
        PrimaryCTA.entry(action: {})
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}

#Preview("PrimaryCTA - Primary") {
    ZStack {
        Color.black.ignoresSafeArea()
        PrimaryCTA.primary(text: "Continue", action: {})
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}

#Preview("PrimaryCTA - No Glow") {
    ZStack {
        Color.black.ignoresSafeArea()
        PrimaryCTA(text: "Submit", showGlow: false, action: {})
            .padding(.horizontal, PuzzleSpacing.screenHorizontal)
    }
}
