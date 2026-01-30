// NoTasksAvailableScreen.swift
// HustleXP iOS - Edge State: No Tasks Available
// Source: E1-no-tasks-available.html

import SwiftUI

// MARK: - Data Model

public struct NoTasksData {
    public let locationRadius: String
    public let trustTier: Int
    public let trustTierName: String
    public let isInstantModeOn: Bool

    public init(
        locationRadius: String = "UW Campus + 2mi",
        trustTier: Int = 2,
        trustTierName: String = "VERIFIED",
        isInstantModeOn: Bool = true
    ) {
        self.locationRadius = locationRadius
        self.trustTier = trustTier
        self.trustTierName = trustTierName
        self.isInstantModeOn = isInstantModeOn
    }
}

// MARK: - View

public struct NoTasksAvailableScreen: View {
    let data: NoTasksData?
    let isLoading: Bool
    let onReturnToDashboard: () -> Void

    public init(
        data: NoTasksData?,
        isLoading: Bool = false,
        onReturnToDashboard: @escaping () -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onReturnToDashboard = onReturnToDashboard
    }

    public var body: some View {
        ZStack {
            Color.hustleBackgroundDark
                .ignoresSafeArea()

            if isLoading {
                loadingState
            } else if let data = data {
                contentState(data: data)
            } else {
                emptyState
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - States

    private var loadingState: some View {
        ProgressView()
            .scaleEffect(1.5)
            .tint(.appleGray)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.hustleTextMuted)
            Text("Unable to load status")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: NoTasksData) -> some View {
        VStack(spacing: 0) {
            // Header spacer
            Spacer().frame(height: 56)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // System Status Card
                    systemStatusCard

                    // Current Settings
                    currentSettingsCard(data: data)

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }

            // Bottom Action
            bottomAction
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("No tasks available")
                .font(HustleFont.title1(.bold))
                .foregroundColor(.white)

            Text("There are currently no tasks matching your eligibility and location.")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(.top, 32)
    }

    private var systemStatusCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.hustleTextMuted)

                    Text("SYSTEM STATUS")
                        .font(HustleFont.micro(.semibold))
                        .tracking(2)
                        .foregroundColor(.hustleTextMuted)
                }

                // Status items
                VStack(alignment: .leading, spacing: 16) {
                    statusItem("Your account is active and eligible")
                    statusItem("Matching is automatic — no action required")
                    statusItem("Tasks appear when demand exists nearby")
                }

                HustleDivider(opacity: 0.05)

                // Time expectation
                Text("New tasks typically appear within 24 hours. No action required from you.")
                    .font(HustleFont.micro())
                    .italic()
                    .foregroundColor(.hustleTextMuted)
            }
            .padding(20)
        }
    }

    private func statusItem(_ text: String) -> some View {
        Text(text)
            .font(HustleFont.callout(.medium))
            .foregroundColor(.white.opacity(0.9))
    }

    private func currentSettingsCard(data: NoTasksData) -> some View {
        GlassCard(cornerRadius: 12, borderColor: .glassBorderSecondary) {
            VStack(alignment: .leading, spacing: 12) {
                Text("CURRENT SETTINGS")
                    .font(HustleFont.micro(.semibold))
                    .tracking(2)
                    .foregroundColor(.hustleTextMuted)

                FlowLayout(spacing: 8) {
                    settingsChip(data.locationRadius)
                    settingsChip("\(data.trustTierName) (Tier \(data.trustTier))")
                    settingsChip(
                        "Instant Mode: \(data.isInstantModeOn ? "ON" : "OFF")",
                        color: data.isInstantModeOn ? Color(hex: "#42BCF0") : .white
                    )
                }
            }
            .padding(16)
        }
    }

    private func settingsChip(_ text: String, color: Color = .white) -> some View {
        Text(text)
            .font(HustleFont.micro(.medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color == .white ? Color.white.opacity(0.1) : color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color == .white ? Color.white.opacity(0.05) : color.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    private var bottomAction: some View {
        VStack(spacing: 0) {
            HustleDivider(opacity: 0.1)

            PrimaryButton("Return to Dashboard", color: .appleGray, action: onReturnToDashboard)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
        }
        .background(
            Color.hustleBackgroundDark.opacity(0.9)
                .background(.ultraThinMaterial)
        )
    }
}

// MARK: - Preview

#Preview("No Tasks Available") {
    NoTasksAvailableScreen(
        data: NoTasksData(
            locationRadius: "UW Campus + 2mi",
            trustTier: 2,
            trustTierName: "VERIFIED",
            isInstantModeOn: true
        ),
        onReturnToDashboard: {}
    )
}

#Preview("No Tasks - Loading") {
    NoTasksAvailableScreen(
        data: nil,
        isLoading: true,
        onReturnToDashboard: {}
    )
}
