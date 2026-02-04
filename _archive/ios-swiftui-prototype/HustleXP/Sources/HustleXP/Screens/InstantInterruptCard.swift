// InstantInterruptCard.swift
// HustleXP iOS - Instant Task Interrupt Screen
// Source: 01-instant-interrupt-card.html

import SwiftUI

// MARK: - Data Model

public struct InstantTaskData {
    public let title: String
    public let distance: String
    public let amount: Decimal
    public let xpMultiplier: Double
    public let requiredTier: Int
    public let timeRemaining: TimeInterval
    public let isPosterVerified: Bool

    public init(
        title: String,
        distance: String,
        amount: Decimal,
        xpMultiplier: Double = 1.8,
        requiredTier: Int = 2,
        timeRemaining: TimeInterval = 45,
        isPosterVerified: Bool = true
    ) {
        self.title = title
        self.distance = distance
        self.amount = amount
        self.xpMultiplier = xpMultiplier
        self.requiredTier = requiredTier
        self.timeRemaining = timeRemaining
        self.isPosterVerified = isPosterVerified
    }
}

// MARK: - View

public struct InstantInterruptCard: View {
    // Props (data comes from parent)
    let task: InstantTaskData?
    let isLoading: Bool
    let onAccept: () -> Void
    let onSkip: () -> Void

    @State private var remainingTime: TimeInterval

    public init(
        task: InstantTaskData?,
        isLoading: Bool = false,
        onAccept: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.task = task
        self.isLoading = isLoading
        self.onAccept = onAccept
        self.onSkip = onSkip
        self._remainingTime = State(initialValue: task?.timeRemaining ?? 0)
    }

    public var body: some View {
        ZStack {
            // Blurred background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            // Content
            if isLoading {
                loadingState
            } else if let task = task {
                contentState(task: task)
            } else {
                emptyState
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Finding instant task...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.slash")
                .font(.system(size: 48))
                .foregroundColor(.hustleTextMuted)
            Text("No instant tasks available")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
            Text("Check back soon")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private func contentState(task: InstantTaskData) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // The Glass Card
            GlassCard(cornerRadius: 24) {
                VStack(spacing: 0) {
                    // Top gradient border accent
                    LinearGradient(
                        colors: [.appleRed, .appleOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 4)

                    VStack(spacing: 0) {
                        // Header Section
                        headerSection(task: task)

                        HustleDivider()
                            .padding(.horizontal, 24)

                        // Task Preview Section
                        taskPreviewSection(task: task)

                        // Action Area
                        actionArea
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 24)
                }
            }
            .padding(.horizontal, 16)

            Spacer()
                .frame(height: 32)
        }
    }

    // MARK: - Sections

    private func headerSection(task: InstantTaskData) -> some View {
        VStack(spacing: 8) {
            // Instant Task Label
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.appleRed)

                Text("INSTANT TASK")
                    .font(HustleFont.micro(.bold))
                    .tracking(2)
                    .foregroundColor(.appleRed)
            }

            // Eligibility
            Text("You are eligible for this task")
                .font(HustleFont.callout(.medium))
                .foregroundColor(.appleGray)

            // Timer
            Text(formatTime(remainingTime))
                .font(HustleFont.tabular(36, weight: .heavy))
                .foregroundColor(Color(hex: "#F2F2F7").opacity(0.9))
                .padding(.vertical, 8)

            // Scarcity text
            Text("Limited to trusted hustlers nearby")
                .font(HustleFont.caption())
                .foregroundColor(.appleGray)

            // XP Badge
            HustleBadge(
                "+\(String(format: "%.1f", task.xpMultiplier))× XP",
                color: .appleOrange
            )
            .padding(.top, 8)
        }
        .padding(.bottom, 24)
    }

    private func taskPreviewSection(task: InstantTaskData) -> some View {
        VStack(spacing: 12) {
            // Title
            Text(task.title)
                .font(HustleFont.title2(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Location
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 16))
                Text(task.distance)
                    .font(HustleFont.body())
            }
            .foregroundColor(.appleGray)

            // Pay Amount
            Text(formatCurrency(task.amount))
                .font(.system(size: 42, weight: .heavy, design: .default))
                .foregroundColor(.appleGreen)
                .padding(.vertical, 8)

            // Safety/Trust Line
            HStack(spacing: 8) {
                Label("Tier \(task.requiredTier)+ required", systemImage: "checkmark.shield.fill")
                Circle()
                    .fill(Color.appleGray.opacity(0.4))
                    .frame(width: 4, height: 4)
                Text("Escrow protected")
                if task.isPosterVerified {
                    Circle()
                        .fill(Color.appleGray.opacity(0.4))
                        .frame(width: 4, height: 4)
                    Text("Verified poster")
                }
            }
            .font(HustleFont.micro(.medium))
            .foregroundColor(.appleGray.opacity(0.8))
        }
        .padding(.vertical, 24)
    }

    private var actionArea: some View {
        VStack(spacing: 16) {
            PrimaryButton("ACCEPT & GO", color: .appleGreen, action: onAccept)

            SecondaryButton("Skip this task", action: onSkip)
                .opacity(0.85)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview("Instant Interrupt - Loaded") {
    InstantInterruptCard(
        task: InstantTaskData(
            title: "Move furniture — 2nd floor walk-up",
            distance: "0.8 mi away",
            amount: 45.00,
            xpMultiplier: 1.8,
            requiredTier: 2,
            timeRemaining: 45,
            isPosterVerified: true
        ),
        onAccept: { print("Accepted") },
        onSkip: { print("Skipped") }
    )
}

#Preview("Instant Interrupt - Loading") {
    InstantInterruptCard(
        task: nil,
        isLoading: true,
        onAccept: {},
        onSkip: {}
    )
}

#Preview("Instant Interrupt - Empty") {
    InstantInterruptCard(
        task: nil,
        isLoading: false,
        onAccept: {},
        onSkip: {}
    )
}
