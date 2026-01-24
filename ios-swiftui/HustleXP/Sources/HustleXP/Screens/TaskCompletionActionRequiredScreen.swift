// TaskCompletionActionRequiredScreen.swift
// HustleXP - Hustler Task Completion (Action Required State)
// Source: 09-hustler-task-completion-ACTION-REQUIRED.html

import SwiftUI

// MARK: - Data Models

public struct TaskCompletionActionRequiredData {
    public let taskId: String
    public let rejectionReasons: [RejectionReason]
    public let xpPending: Int
    public let payoutAmount: Double
    public let canResubmit: Bool

    public init(
        taskId: String,
        rejectionReasons: [RejectionReason],
        xpPending: Int,
        payoutAmount: Double,
        canResubmit: Bool
    ) {
        self.taskId = taskId
        self.rejectionReasons = rejectionReasons
        self.xpPending = xpPending
        self.payoutAmount = payoutAmount
        self.canResubmit = canResubmit
    }
}

public struct RejectionReason: Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let description: String?

    public init(icon: String, title: String, description: String? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}

// MARK: - Task Completion Action Required Screen

public struct TaskCompletionActionRequiredScreen: View {
    public let data: TaskCompletionActionRequiredData
    public let onFixProof: () -> Void
    public let onContactSupport: () -> Void
    public let onDismiss: () -> Void

    public init(
        data: TaskCompletionActionRequiredData,
        onFixProof: @escaping () -> Void,
        onContactSupport: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.data = data
        self.onFixProof = onFixProof
        self.onContactSupport = onContactSupport
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Warm dark background
            Color(red: 35/255, green: 27/255, blue: 15/255).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                ScrollView {
                    VStack(spacing: 16) {
                        // Rejection reasons card
                        rejectionReasonsCard

                        // Status cards
                        HStack(spacing: 16) {
                            xpStatusCard
                            payoutStatusCard
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 200)
                }
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
        VStack(spacing: 20) {
            // Top bar
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.6))
                        .padding(8)
                }

                Spacer()

                Text("Task ID \(data.taskId)")
                    .font(HustleFont.micro(.bold))
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            // Status badge
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))

                Text("Action Required")
                    .font(HustleFont.micro(.bold))
                    .textCase(.uppercase)
                    .tracking(2)
            }
            .foregroundColor(.appleOrange)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.appleOrange.opacity(0.2))
            .overlay(
                Capsule()
                    .stroke(Color.appleOrange.opacity(0.5), lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: .appleOrange.opacity(0.3), radius: 15)

            // Title
            VStack(spacing: 8) {
                Text("Proof needs")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text("correction")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
            }

            Text("Please review the feedback below and update your submission to unlock your rewards.")
                .font(HustleFont.caption())
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Rejection Reasons Card

    private var rejectionReasonsCard: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [Color.appleOrange.opacity(0.2), .black.opacity(0.9), .black],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appleOrange)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "xmark.shield.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .appleOrange.opacity(0.2), radius: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rejection Reasons")
                            .font(HustleFont.title3(.bold))
                            .foregroundColor(.white)

                        Text("Review carefully")
                            .font(HustleFont.micro(.medium))
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                VStack(spacing: 12) {
                    ForEach(Array(data.rejectionReasons.enumerated()), id: \.element.id) { index, reason in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: reason.icon)
                                .font(.system(size: 18))
                                .foregroundColor(.appleOrange)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(reason.title)
                                    .font(HustleFont.caption(.medium))
                                    .foregroundColor(.white)

                                if let desc = reason.description {
                                    Text(desc)
                                        .font(HustleFont.micro())
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }

                        if index < data.rejectionReasons.count - 1 {
                            HustleDivider(opacity: 0.05)
                        }
                    }
                }
                .padding(20)
                .background(Color(red: 50/255, green: 38/255, blue: 23/255).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            }
            .padding(24)
            .padding(.top, 128)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - XP Status Card

    private var xpStatusCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("XP Status")
                        .font(HustleFont.caption(.medium))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Text("PAUSED")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Text("\(data.xpPending) XP")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))

                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))

                    Text("Resubmit to unlock")
                        .font(HustleFont.caption(.medium))
                }
                .foregroundColor(.appleOrange)
                .padding(.top, 8)
            }

            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: 8, y: -8)
        }
        .padding(20)
        .background(Color(red: 50/255, green: 38/255, blue: 23/255).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appleOrange.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Payout Status Card

    private var payoutStatusCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Payout")
                        .font(HustleFont.caption(.medium))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Text("BLOCKED")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.appleRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appleRed.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Text(String(format: "$%.2f", data.payoutAmount))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))

                HStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 14))

                    Text("Pending resolution")
                        .font(HustleFont.caption(.medium))
                }
                .foregroundColor(.appleRed)
                .padding(.top, 8)
            }

            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: 8, y: -8)
        }
        .padding(20)
        .background(Color(red: 50/255, green: 38/255, blue: 23/255).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appleOrange.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Bottom Action Section

    private var bottomActionSection: some View {
        VStack(spacing: 12) {
            Button(action: onFixProof) {
                HStack(spacing: 8) {
                    Text("Fix Proof Issues")
                        .font(HustleFont.headline(.bold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(red: 35/255, green: 27/255, blue: 15/255))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appleOrange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .appleOrange.opacity(0.4), radius: 20)
            }
            .buttonStyle(ScaleButtonStyle())

            Text("Resubmit proof to complete task")
                .font(HustleFont.caption(.medium))
                .foregroundColor(.white.opacity(0.6))

            if data.canResubmit {
                Text("You may resubmit proof **once** for this requirement.")
                    .font(HustleFont.micro(.medium))
                    .italic()
                    .foregroundColor(.white.opacity(0.5))
            }

            // Support section
            VStack(spacing: 8) {
                HustleDivider(opacity: 0.05)
                    .padding(.top, 16)

                Button(action: onContactSupport) {
                    Text("Contact Support")
                        .font(HustleFont.caption())
                        .underline()
                        .foregroundColor(.white.opacity(0.4))
                }

                Text("Use only if you believe this decision is incorrect")
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .padding(.top, 24)
        .background(
            LinearGradient(
                colors: [.clear, Color(red: 35/255, green: 27/255, blue: 15/255), Color(red: 35/255, green: 27/255, blue: 15/255)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Preview

#Preview {
    TaskCompletionActionRequiredScreen(
        data: TaskCompletionActionRequiredData(
            taskId: "#9942",
            rejectionReasons: [
                RejectionReason(icon: "eye.slash.fill", title: "Entry point not visible", description: "Ensure the store entrance is captured in the wide shot."),
                RejectionReason(icon: "sun.min.fill", title: "Image too dark", description: "Please turn on flash or increase brightness."),
                RejectionReason(icon: "crop", title: "Work area unclear", description: nil)
            ],
            xpPending: 350,
            payoutAmount: 45.00,
            canResubmit: true
        ),
        onFixProof: {},
        onContactSupport: {},
        onDismiss: {}
    )
}
