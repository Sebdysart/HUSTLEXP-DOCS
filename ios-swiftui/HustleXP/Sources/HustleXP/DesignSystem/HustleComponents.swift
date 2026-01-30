// HustleComponents.swift
// HustleXP Design System - Reusable UI Components
// Source: STITCH HTML specifications

import SwiftUI

// MARK: - Glass Card

/// Glassmorphism card container with blur and border
public struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let content: Content

    public init(
        cornerRadius: CGFloat = 24,
        borderColor: Color = .glassBorder,
        borderWidth: CGFloat = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.glassSurface)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Primary Action Button

/// Full-width primary action button
public struct PrimaryButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        color: Color = .appleGreen,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(title)
                    .font(HustleFont.headline(.bold))
                    .tracking(0.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 0)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Secondary Button

/// Text-only secondary action button
public struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(HustleFont.callout(.medium))
                .foregroundColor(.hustleTextMuted)
                .padding(.vertical, 8)
        }
    }
}

// MARK: - Badge/Chip

/// Small pill-shaped badge
public struct HustleBadge: View {
    let text: String
    let icon: String?
    let color: Color
    let filled: Bool

    public init(
        _ text: String,
        icon: String? = nil,
        color: Color = .appleOrange,
        filled: Bool = false
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.filled = filled
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(HustleFont.micro(.bold))
                .tracking(0.5)
        }
        .foregroundColor(filled ? .white : color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(filled ? color : color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Progress Ring

/// Circular progress indicator
public struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let trackColor: Color
    let progressColor: Color
    let centerContent: AnyView?

    public init(
        progress: Double,
        size: CGFloat = 96,
        lineWidth: CGFloat = 8,
        trackColor: Color = Color(hex: "#2A2A2C"),
        progressColor: Color = .hustlePrimary,
        @ViewBuilder centerContent: () -> some View = { EmptyView() }
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.trackColor = trackColor
        self.progressColor = progressColor
        self.centerContent = AnyView(centerContent())
    }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: progress)

            // Center content
            centerContent
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Status Indicator

/// Small pulsing status dot
public struct StatusIndicator: View {
    let color: Color
    let isActive: Bool

    public init(color: Color = .hustlePrimary, isActive: Bool = true) {
        self.color = color
        self.isActive = isActive
    }

    public var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(color.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .scaleEffect(1.5)
                    .opacity(0.5)
            }
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .animation(isActive ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isActive)
    }
}

// MARK: - Divider

/// Custom styled divider
public struct HustleDivider: View {
    let opacity: Double

    public init(opacity: Double = 0.1) {
        self.opacity = opacity
    }

    public var body: some View {
        Rectangle()
            .fill(Color.white.opacity(opacity))
            .frame(height: 1)
    }
}

// MARK: - Button Style

/// Scale effect on press
public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Step Indicator

/// Task step with completion state
public struct StepIndicator: View {
    public enum State {
        case completed
        case current
        case pending
    }

    let title: String
    let subtitle: String?
    let state: State
    let isLast: Bool

    public init(
        title: String,
        subtitle: String? = nil,
        state: State,
        isLast: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.state = state
        self.isLast = isLast
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.hustleBackgroundDark)
                        .frame(width: 28, height: 28)

                    switch state {
                    case .completed:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appleGreen)
                    case .current:
                        Image(systemName: "circle.inset.filled")
                            .font(.system(size: 24))
                            .foregroundColor(.appleOrange)
                            .shadow(color: .appleOrange.opacity(0.4), radius: 8)
                    case .pending:
                        Image(systemName: "circle")
                            .font(.system(size: 24))
                            .foregroundColor(.zinc700)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(state == .completed ? Color.zinc700 : Color.zinc800)
                        .frame(width: 2)
                        .frame(height: 40)
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HustleFont.body(state == .current ? .bold : .medium))
                    .foregroundColor(state == .pending ? .zinc600 : (state == .completed ? .zinc500 : .white))
                    .strikethrough(state == .completed, color: .zinc600)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(HustleFont.caption())
                        .foregroundColor(.zinc600)
                }

                if state == .current {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.appleOrange)
                            .frame(width: 6, height: 6)
                        Text("Action required")
                            .font(HustleFont.micro(.medium))
                            .foregroundColor(.appleOrange)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.top, 2)

            Spacer()
        }
    }
}
