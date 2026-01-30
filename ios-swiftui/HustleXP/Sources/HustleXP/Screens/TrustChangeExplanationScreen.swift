// TrustChangeExplanationScreen.swift
// HustleXP - Task Impact Summary / Trust Change Explanation
// Source: 12-trust-change-explanation-FIXED.html

import SwiftUI

// MARK: - Data Models

public struct TrustChangeExplanationData {
    public let taskTitle: String
    public let contractId: String
    public let completedDate: String
    public let xpGained: Int
    public let xpBreakdown: String
    public let reliabilityStatus: String
    public let reliabilityPassed: Bool
    public let trustTierName: String
    public let trustTierNumber: Int
    public let trustTierChanged: Bool
    public let tasksUntilPromotion: Int
    public let systemImpacts: [String]
    public let noPenalties: Bool

    public init(
        taskTitle: String,
        contractId: String,
        completedDate: String,
        xpGained: Int,
        xpBreakdown: String,
        reliabilityStatus: String,
        reliabilityPassed: Bool,
        trustTierName: String,
        trustTierNumber: Int,
        trustTierChanged: Bool,
        tasksUntilPromotion: Int,
        systemImpacts: [String],
        noPenalties: Bool
    ) {
        self.taskTitle = taskTitle
        self.contractId = contractId
        self.completedDate = completedDate
        self.xpGained = xpGained
        self.xpBreakdown = xpBreakdown
        self.reliabilityStatus = reliabilityStatus
        self.reliabilityPassed = reliabilityPassed
        self.trustTierName = trustTierName
        self.trustTierNumber = trustTierNumber
        self.trustTierChanged = trustTierChanged
        self.tasksUntilPromotion = tasksUntilPromotion
        self.systemImpacts = systemImpacts
        self.noPenalties = noPenalties
    }
}

// MARK: - Trust Change Explanation Screen

public struct TrustChangeExplanationScreen: View {
    public let data: TrustChangeExplanationData
    public let onContinue: () -> Void
    public let onBack: () -> Void

    public init(
        data: TrustChangeExplanationData,
        onContinue: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.data = data
        self.onContinue = onContinue
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color.hustleBackgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)

                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        headerSection

                        // Task summary card
                        taskSummaryCard

                        // System updates card
                        systemUpdatesCard

                        // System impact card
                        systemImpactCard

                        // No penalties card
                        if data.noPenalties {
                            noPenaltiesCard
                        }

                        // Next steps card
                        nextStepsCard

                        // Primary action
                        primaryAction
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Task Impact Summary")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("How this task affected system trust and matching")
                .font(HustleFont.body())
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Task Summary Card

    private var taskSummaryCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Summary")
                    .font(HustleFont.micro(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.5))

                Text(data.taskTitle)
                    .font(HustleFont.title3(.bold))
                    .foregroundColor(.white)

                Text(data.contractId)
                    .font(HustleFont.micro(.medium))
                    .monospaced()
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 4)

                Text("Completed on \(data.completedDate)")
                    .font(HustleFont.caption())
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }

    // MARK: - System Updates Card

    private var systemUpdatesCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("System Updates")
                    .font(HustleFont.micro(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.5))

                // XP Gained
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appleGreen)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("XP Gained")
                            .font(HustleFont.body(.semibold))
                            .foregroundColor(.white)

                        Text("+\(data.xpGained) XP")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appleGreen)

                        Text(data.xpBreakdown)
                            .font(HustleFont.caption())
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Reliability Status
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(data.reliabilityPassed ? .appleGreen : .white.opacity(0.5))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reliability Status for This Task")
                            .font(HustleFont.body(.semibold))
                            .foregroundColor(.white)

                        Text(data.reliabilityStatus)
                            .font(HustleFont.headline(.bold))
                            .foregroundColor(data.reliabilityPassed ? .appleGreen : .white.opacity(0.5))

                        Text("Account Reliability (unchanged)")
                            .font(HustleFont.micro())
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Trust Tier
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trust Tier")
                            .font(HustleFont.body(.semibold))
                            .foregroundColor(.white)

                        Text(data.trustTierChanged ? "Changed" : "Unchanged")
                            .font(HustleFont.headline(.semibold))
                            .foregroundColor(.white.opacity(0.5))

                        Text("Current tier: \(data.trustTierName.uppercased()) (Tier \(data.trustTierNumber)). You are \(data.tasksUntilPromotion) completed tasks away from Tier \(data.trustTierNumber + 1) promotion.")
                            .font(HustleFont.caption())
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - System Impact Card

    private var systemImpactCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("System Impact")
                    .font(HustleFont.micro(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.5))

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Impact from this task:")
                            .font(HustleFont.caption(.medium))
                            .foregroundColor(.white.opacity(0.8))

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(data.systemImpacts, id: \.self) { impact in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))

                                    Text(impact)
                                        .font(HustleFont.caption())
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }

                        Text("High-trust status unlocks priority matching for future tasks.")
                            .font(HustleFont.caption())
                            .italic()
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 4)
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - No Penalties Card

    private var noPenaltiesCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("No Penalties")
                    .font(HustleFont.micro(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.5))

                Text("Task completed successfully. No trust penalties or restrictions applied.")
                    .font(HustleFont.caption())
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .opacity(0.6)
    }

    // MARK: - Next Steps Card

    private var nextStepsCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Next Steps")
                    .font(HustleFont.micro(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.5))

                Text("Your updated trust tier and XP will be reflected in future task matching and eligibility.")
                    .font(HustleFont.caption())
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .opacity(0.6)
    }

    // MARK: - Primary Action

    private var primaryAction: some View {
        Button(action: onContinue) {
            Text("Continue")
                .font(HustleFont.headline(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appleGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.top, 24)
    }
}

// MARK: - Preview

#Preview {
    TrustChangeExplanationScreen(
        data: TrustChangeExplanationData(
            taskTitle: "Site Survey: Sector 4",
            contractId: "Contract ID: #820-A4",
            completedDate: "Oct 24, 2024",
            xpGained: 342,
            xpBreakdown: "Base: 300 XP • Instant: +1.5× • Speed: +1.2×",
            reliabilityStatus: "Passed",
            reliabilityPassed: true,
            trustTierName: "Trusted",
            trustTierNumber: 3,
            trustTierChanged: false,
            tasksUntilPromotion: 3,
            systemImpacts: [
                "Priority matching weight increased for Instant tasks",
                "No penalties applied",
                "No restrictions added"
            ],
            noPenalties: true
        ),
        onContinue: {},
        onBack: {}
    )
}
