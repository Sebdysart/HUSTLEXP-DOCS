// TaskCompletionApprovedScreen.swift
// HustleXP - Hustler Task Completion (Approved State)
// Source: 09-hustler-task-completion-APPROVED.html

import SwiftUI

// MARK: - Data Models

public struct TaskCompletionApprovedData {
    public let taskTitle: String
    public let xpEarned: Int
    public let baseXP: Int
    public let bonusXP: Int
    public let bonusReason: String
    public let earnings: Double
    public let escrowStatus: String

    public init(
        taskTitle: String,
        xpEarned: Int,
        baseXP: Int,
        bonusXP: Int,
        bonusReason: String,
        earnings: Double,
        escrowStatus: String
    ) {
        self.taskTitle = taskTitle
        self.xpEarned = xpEarned
        self.baseXP = baseXP
        self.bonusXP = bonusXP
        self.bonusReason = bonusReason
        self.earnings = earnings
        self.escrowStatus = escrowStatus
    }
}

// MARK: - Task Completion Approved Screen

public struct TaskCompletionApprovedScreen: View {
    public let data: TaskCompletionApprovedData
    public let onFinishTask: () -> Void

    public init(data: TaskCompletionApprovedData, onFinishTask: @escaping () -> Void) {
        self.data = data
        self.onFinishTask = onFinishTask
    }

    public var body: some View {
        ZStack {
            Color.hustleBackgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 6)
                    .padding(.top, 24)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Status badge and title
                        headerSection

                        // Verification card
                        verificationCard

                        // XP outcome card
                        xpOutcomeCard

                        // Earnings card
                        earningsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }

                Spacer()
            }

            // Bottom action
            VStack {
                Spacer()
                bottomActionSection
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Status badge
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text("Completion Approved")
                    .font(HustleFont.micro(.bold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.appleGreen)
            .clipShape(Capsule())
            .shadow(color: .appleGreen.opacity(0.4), radius: 15)

            // Title
            VStack(spacing: 4) {
                Text("Task requirements met 100%")
                    .font(HustleFont.caption(.medium))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.6))

                Text(data.taskTitle)
                    .font(HustleFont.title2(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Verification Card

    private var verificationCard: some View {
        GlassCard(cornerRadius: 16) {
            HStack(alignment: .top, spacing: 16) {
                Circle()
                    .fill(Color.appleGreen.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appleGreen)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.appleGreen.opacity(0.2), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("All required criteria verified")
                        .font(HustleFont.headline(.bold))
                        .foregroundColor(.white)

                    Text("Auto-verified by HustleXP Protocol")
                        .font(HustleFont.caption())
                        .foregroundColor(.appleGreen.opacity(0.8))
                }

                Spacer()
            }
            .padding(20)
        }
    }

    // MARK: - XP Outcome Card

    private var xpOutcomeCard: some View {
        GlassCard(cornerRadius: 16) {
            ZStack(alignment: .topTrailing) {
                // Glow effect
                Circle()
                    .fill(Color.appleGreen.opacity(0.1))
                    .frame(width: 128, height: 128)
                    .blur(radius: 48)
                    .offset(x: 40, y: -40)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("XP Outcome")
                                .font(HustleFont.micro(.semibold))
                                .textCase(.uppercase)
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.6))

                            Text("+\(data.xpEarned) XP")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.appleGreen)
                                .shadow(color: .appleGreen.opacity(0.4), radius: 20)
                        }

                        Spacer()

                        Circle()
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.4))
                            )
                    }

                    HustleDivider()

                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 6, height: 6)

                                Text("Base Reward")
                                    .font(HustleFont.caption())
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            Text("+\(data.baseXP) XP")
                                .font(HustleFont.caption(.medium))
                                .foregroundColor(.white)
                        }

                        HStack {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.appleGreen)
                                    .frame(width: 6, height: 6)

                                Text(data.bonusReason)
                                    .font(HustleFont.caption())
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            Text("+\(data.bonusXP) XP")
                                .font(HustleFont.caption(.medium))
                                .foregroundColor(.appleGreen)
                        }
                    }
                }
                .padding(24)
            }
        }
    }

    // MARK: - Earnings Card

    private var earningsCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Earnings")
                            .font(HustleFont.micro(.semibold))
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.6))

                        Text(String(format: "$%.2f", data.earnings))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("USD")
                        .font(HustleFont.caption(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)

                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))

                    Text(data.escrowStatus)
                        .font(HustleFont.micro(.medium))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
            }
        }
    }

    // MARK: - Bottom Action

    private var bottomActionSection: some View {
        VStack(spacing: 12) {
            Button(action: onFinishTask) {
                HStack(spacing: 8) {
                    Text("Finish Task")
                        .font(HustleFont.headline(.bold))
                        .textCase(.uppercase)
                        .tracking(1)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appleGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .appleGreen.opacity(0.3), radius: 25)
            }
            .buttonStyle(ScaleButtonStyle())

            Text("This will finalize the task and release escrow.")
                .font(HustleFont.caption(.medium))
                .foregroundColor(.white.opacity(0.6))

            Text("Escrow will be released after poster confirmation")
                .font(HustleFont.micro(.medium))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 48)
        .background(
            LinearGradient(
                colors: [.clear, .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Preview

#Preview {
    TaskCompletionApprovedScreen(
        data: TaskCompletionApprovedData(
            taskTitle: "Site Survey: Sector 4",
            xpEarned: 342,
            baseXP: 300,
            bonusXP: 42,
            bonusReason: "Speed Bonus (Top 5%)",
            earnings: 45.00,
            escrowStatus: "Escrow release pending"
        ),
        onFinishTask: {}
    )
}
