// EligibilityMismatchScreen.swift
// HustleXP iOS - Edge State: Eligibility Mismatch
// Source: E2-eligibility-mismatch.html

import SwiftUI

// MARK: - Data Model

public struct EligibilityMismatchData {
    public let taskTitle: String
    public let requiredTier: Int
    public let requiredTierName: String
    public let currentTier: Int
    public let currentTierName: String
    public let missingRequirements: [MissingRequirement]
    public let upgradeActions: [UpgradeAction]

    public init(
        taskTitle: String,
        requiredTier: Int,
        requiredTierName: String,
        currentTier: Int,
        currentTierName: String,
        missingRequirements: [MissingRequirement],
        upgradeActions: [UpgradeAction]
    ) {
        self.taskTitle = taskTitle
        self.requiredTier = requiredTier
        self.requiredTierName = requiredTierName
        self.currentTier = currentTier
        self.currentTierName = currentTierName
        self.missingRequirements = missingRequirements
        self.upgradeActions = upgradeActions
    }
}

public struct MissingRequirement {
    public let icon: String
    public let title: String
    public let description: String

    public init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}

public struct UpgradeAction {
    public let title: String
    public let isPrimary: Bool

    public init(title: String, isPrimary: Bool = false) {
        self.title = title
        self.isPrimary = isPrimary
    }
}

// MARK: - View

public struct EligibilityMismatchScreen: View {
    let data: EligibilityMismatchData?
    let isLoading: Bool
    let onActionTap: (String) -> Void
    let onDismiss: () -> Void

    public init(
        data: EligibilityMismatchData?,
        isLoading: Bool = false,
        onActionTap: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onActionTap = onActionTap
        self.onDismiss = onDismiss
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
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appleOrange)
            Text("Checking eligibility...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 48))
                .foregroundColor(.appleGreen)
            Text("You're eligible!")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: EligibilityMismatchData) -> some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Title
                    headerSection(data: data)

                    // Tier Comparison
                    tierComparison(data: data)

                    // Missing Requirements
                    missingRequirementsSection(data: data)

                    // Explanation
                    explanationCard

                    // Actions
                    actionsSection(data: data)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Components

    private var headerBar: some View {
        HStack {
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
    }

    private func headerSection(data: EligibilityMismatchData) -> some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.appleOrange.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.appleOrange)
            }

            Text("Eligibility Required")
                .font(HustleFont.title1(.bold))
                .foregroundColor(.white)

            Text("This task requires higher trust tier access")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
                .multilineTextAlignment(.center)

            // Task name
            Text(data.taskTitle)
                .font(HustleFont.callout(.medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
        }
        .padding(.top, 16)
    }

    private func tierComparison(data: EligibilityMismatchData) -> some View {
        HStack(spacing: 16) {
            // Current tier
            tierBox(
                label: "YOUR TIER",
                tier: data.currentTier,
                tierName: data.currentTierName,
                color: .appleBlue
            )

            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.zinc600)

            // Required tier
            tierBox(
                label: "REQUIRED",
                tier: data.requiredTier,
                tierName: data.requiredTierName,
                color: .appleOrange
            )
        }
    }

    private func tierBox(label: String, tier: Int, tierName: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(HustleFont.micro(.semibold))
                .tracking(1)
                .foregroundColor(.zinc500)

            VStack(spacing: 4) {
                Text("Tier \(tier)")
                    .font(HustleFont.title2(.bold))
                    .foregroundColor(.white)

                Text(tierName)
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(color)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    private func missingRequirementsSection(data: EligibilityMismatchData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MISSING REQUIREMENTS")
                .hustleSectionHeader()
                .padding(.leading, 4)

            VStack(spacing: 12) {
                ForEach(data.missingRequirements, id: \.title) { req in
                    requirementRow(req: req)
                }
            }
        }
    }

    private func requirementRow(req: MissingRequirement) -> some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appleRed.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: req.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.appleRed)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(req.title)
                        .font(HustleFont.callout(.semibold))
                        .foregroundColor(.white)

                    Text(req.description)
                        .font(HustleFont.micro())
                        .foregroundColor(.zinc400)
                }

                Spacer()

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.appleRed.opacity(0.6))
            }
            .padding(16)
        }
    }

    private var explanationCard: some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appleBlue)

                Text("Trust tiers are earned through completed tasks and verification. Higher tiers unlock access to premium tasks with better pay.")
                    .font(HustleFont.micro())
                    .foregroundColor(.zinc300)
            }
            .padding(16)
        }
    }

    private func actionsSection(data: EligibilityMismatchData) -> some View {
        VStack(spacing: 12) {
            ForEach(data.upgradeActions, id: \.title) { action in
                if action.isPrimary {
                    PrimaryButton(action.title, icon: "arrow.up.circle.fill", color: .hustlePrimary) {
                        onActionTap(action.title)
                    }
                } else {
                    Button(action: { onActionTap(action.title) }) {
                        Text(action.title)
                            .font(HustleFont.callout(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Eligibility Mismatch") {
    EligibilityMismatchScreen(
        data: EligibilityMismatchData(
            taskTitle: "Interior Home Renovation",
            requiredTier: 4,
            requiredTierName: "In-Home",
            currentTier: 2,
            currentTierName: "Verified",
            missingRequirements: [
                MissingRequirement(icon: "shield.checkered", title: "Background Check", description: "Required for in-home access"),
                MissingRequirement(icon: "star.fill", title: "100 Completed Tasks", description: "You have completed 47 tasks")
            ],
            upgradeActions: [
                UpgradeAction(title: "Start Background Check", isPrimary: true),
                UpgradeAction(title: "View Trust Tier Requirements"),
                UpgradeAction(title: "Find Other Tasks")
            ]
        ),
        onActionTap: { _ in },
        onDismiss: {}
    )
}
