// TypeReveal.swift
// HustleXP UI Puzzle System — Layer 1: Atom
// RESPONSIBILITY: Text animation (headline reveal)

import SwiftUI

/// Text reveal animation for headlines.
/// Characters or words appear sequentially.
///
/// LAYER: Atom
/// TOKENS USED: PuzzleMotion
/// IMPORTS: None (atoms cannot import other atoms)
public struct TypeReveal: View {
    /// The text to reveal
    let text: String

    /// Font to use
    let font: Font

    /// Text color
    let color: Color

    /// Reveal mode
    let mode: RevealMode

    /// Whether animation is enabled
    let animated: Bool

    /// Delay before animation starts
    let delay: Double

    @State private var revealProgress: Double = 0

    public enum RevealMode {
        /// Reveal all at once (simple fade)
        case fade

        /// Reveal word by word
        case word

        /// Reveal character by character
        case character
    }

    public init(
        text: String,
        font: Font = PuzzleTypography.display(),
        color: Color = PuzzleColors.textPrimary,
        mode: RevealMode = .fade,
        animated: Bool = true,
        delay: Double = 0
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.mode = mode
        self.animated = animated
        self.delay = delay
    }

    public var body: some View {
        Group {
            switch mode {
            case .fade:
                fadeReveal
            case .word:
                wordReveal
            case .character:
                characterReveal
            }
        }
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: PuzzleMotion.slow).delay(delay)) {
                    revealProgress = 1
                }
            } else {
                revealProgress = 1
            }
        }
    }

    private var fadeReveal: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .opacity(revealProgress)
            .offset(y: (1 - revealProgress) * PuzzleSpacing.entranceOffset)
    }

    private var wordReveal: some View {
        let words = text.split(separator: " ").map(String.init)
        return HStack(spacing: 8) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text(word)
                    .font(font)
                    .foregroundColor(color)
                    .opacity(wordOpacity(index: index, total: words.count))
                    .offset(y: wordOffset(index: index, total: words.count))
            }
        }
    }

    private var characterReveal: some View {
        let chars = Array(text)
        return HStack(spacing: 0) {
            ForEach(Array(chars.enumerated()), id: \.offset) { index, char in
                Text(String(char))
                    .font(font)
                    .foregroundColor(color)
                    .opacity(charOpacity(index: index, total: chars.count))
            }
        }
    }

    private func wordOpacity(index: Int, total: Int) -> Double {
        let threshold = Double(index) / Double(total)
        return revealProgress > threshold ? 1 : 0
    }

    private func wordOffset(index: Int, total: Int) -> CGFloat {
        let threshold = Double(index) / Double(total)
        return revealProgress > threshold ? 0 : PuzzleSpacing.entranceOffset
    }

    private func charOpacity(index: Int, total: Int) -> Double {
        let threshold = Double(index) / Double(total)
        return revealProgress > threshold ? 1 : 0
    }
}

// MARK: - Convenience Initializers

public extension TypeReveal {
    /// Headline reveal for entry screens
    static func headline(_ text: String, delay: Double = 0) -> TypeReveal {
        TypeReveal(
            text: text,
            font: PuzzleTypography.display(),
            color: PuzzleColors.textPrimary,
            mode: .fade,
            delay: delay
        )
    }

    /// Subhead reveal
    static func subhead(_ text: String, delay: Double = 0) -> TypeReveal {
        TypeReveal(
            text: text,
            font: PuzzleTypography.body(),
            color: PuzzleColors.textSecondary.opacity(0.6),
            mode: .fade,
            delay: delay
        )
    }
}

// MARK: - Preview

#Preview("TypeReveal - Fade") {
    ZStack {
        Color.black.ignoresSafeArea()
        TypeReveal.headline("Turn time into money.", delay: 0.2)
    }
}

#Preview("TypeReveal - Word") {
    ZStack {
        Color.black.ignoresSafeArea()
        TypeReveal(
            text: "Turn time into money",
            font: PuzzleTypography.display(),
            mode: .word,
            delay: 0.2
        )
    }
}

#Preview("TypeReveal - Static") {
    ZStack {
        Color.black.ignoresSafeArea()
        TypeReveal(
            text: "No Animation",
            animated: false
        )
    }
}
