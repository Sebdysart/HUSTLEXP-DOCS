// PosterTaskCompletionScreen.swift
// HustleXP - Poster Task Completion View
// Source: 10-poster-task-completion-FIXED.html

import SwiftUI

// MARK: - Data Models

public struct PosterTaskCompletionData {
    public let hustlerName: String
    public let hustlerInitials: String
    public let hustlerTaskCount: Int
    public let hustlerRating: Double
    public let verificationItems: [String]
    public let paymentAmount: Double
    public let fundsReleased: Bool
    public let proofItemsVerified: Int
    public let taskTitle: String
    public let completedDate: String
    public let contractId: String

    public init(
        hustlerName: String,
        hustlerInitials: String,
        hustlerTaskCount: Int,
        hustlerRating: Double,
        verificationItems: [String],
        paymentAmount: Double,
        fundsReleased: Bool,
        proofItemsVerified: Int,
        taskTitle: String,
        completedDate: String,
        contractId: String
    ) {
        self.hustlerName = hustlerName
        self.hustlerInitials = hustlerInitials
        self.hustlerTaskCount = hustlerTaskCount
        self.hustlerRating = hustlerRating
        self.verificationItems = verificationItems
        self.paymentAmount = paymentAmount
        self.fundsReleased = fundsReleased
        self.proofItemsVerified = proofItemsVerified
        self.taskTitle = taskTitle
        self.completedDate = completedDate
        self.contractId = contractId
    }
}

// MARK: - Poster Task Completion Screen

public struct PosterTaskCompletionScreen: View {
    public let data: PosterTaskCompletionData
    public let onLeaveFeedback: () -> Void
    public let onReportIssue: () -> Void
    public let onDismiss: () -> Void
    public let onShare: () -> Void

    public init(
        data: PosterTaskCompletionData,
        onLeaveFeedback: @escaping () -> Void,
        onReportIssue: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        onShare: @escaping () -> Void
    ) {
        self.data = data
        self.onLeaveFeedback = onLeaveFeedback
        self.onReportIssue = onReportIssue
        self.onDismiss = onDismiss
        self.onShare = onShare
    }

    public var body: some View {
        ZStack {
            Color.hustleBackgroundDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Top bar
                    topBar

                    // Success header
                    successHeader

                    // Hustler card
                    hustlerCard

                    // Verification card
                    verificationCard

                    // Payment card
                    paymentCard

                    // Proof summary card
                    proofSummaryCard

                    // Task details card
                    taskDetailsCard

                    // Primary action
                    primaryAction

                    // Support footer
                    supportFooter
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                    )
            }

            Spacer()

            Text("Confirmation")
                .font(HustleFont.micro(.bold))
                .textCase(.uppercase)
                .tracking(3)
                .foregroundColor(.white.opacity(0.3))

            Spacer()

            Button(action: onShare) {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Success Header

    private var successHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.appleGreen.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                Circle()
                    .fill(Color(red: 19/255, green: 32/255, blue: 28/255))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.appleGreen.opacity(0.2), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.appleGreen)
                    )
                    .shadow(color: .appleGreen.opacity(0.3), radius: 40)
            }

            VStack(spacing: 8) {
                Text("Task Completed")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("All requirements were verified")
                    .font(HustleFont.body())
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Hustler Card

    private var hustlerCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(spacing: 20) {
                // Avatar
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.appleGreen, Color(red: 42/255, green: 176/255, blue: 74/255)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle()
                                .stroke(Color.appleGreen.opacity(0.3), lineWidth: 2)
                        )
                        .overlay(
                            Text(data.hustlerInitials)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .appleGreen.opacity(0.3), radius: 16)

                    Circle()
                        .fill(Color(red: 19/255, green: 32/255, blue: 28/255))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.appleGreen.opacity(0.2), lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.appleGreen)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4)
                        .offset(x: 4, y: 4)
                }

                // Name
                Text(data.hustlerName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                // Stats
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("\(data.hustlerTaskCount)")
                            .font(HustleFont.headline(.bold))
                            .foregroundColor(.white)

                        Text("Tasks")
                            .font(HustleFont.micro(.medium))
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )

                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", data.hustlerRating))
                                .font(HustleFont.headline(.bold))
                                .foregroundColor(.white)

                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.appleGreen)
                        }

                        Text("Rating")
                            .font(HustleFont.micro(.medium))
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
                .frame(maxWidth: 280)

                // Status
                HustleDivider()

                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.appleGreen)
                            .frame(width: 8, height: 8)

                        Circle()
                            .fill(Color.appleGreen)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.5)
                            .opacity(0.5)
                    }

                    Text("Verified and in good standing")
                        .font(HustleFont.caption(.medium))
                        .foregroundColor(.appleGreen.opacity(0.8))
                }
            }
            .padding(24)
        }
    }

    // MARK: - Verification Card

    private var verificationCard: some View {
        GlassCard(cornerRadius: 16) {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.appleGreen.opacity(0.2), .appleGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appleGreen.opacity(0.1), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.appleGreen)
                    )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Task Completion Verified")
                        .font(HustleFont.caption(.bold))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(data.verificationItems, id: \.self) { item in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appleGreen)

                                Text(item)
                                    .font(HustleFont.caption())
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }

                    Text("Verified automatically by HustleXP protocol")
                        .font(HustleFont.micro())
                        .italic()
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 4)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Payment Card

    private var paymentCard: some View {
        GlassCard(cornerRadius: 16) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [.appleGreen.opacity(0.1), .clear],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .opacity(0.5)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payment")
                                .font(HustleFont.micro(.bold))
                                .textCase(.uppercase)
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))

                            Text(String(format: "$%.2f", data.paymentAmount))
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

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.appleGreen)

                        Text(data.fundsReleased ? "Funds released from escrow" : "Funds pending release")
                            .font(HustleFont.caption(.medium))
                            .foregroundColor(.appleGreen.opacity(0.9))
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
    }

    // MARK: - Proof Summary Card

    private var proofSummaryCard: some View {
        GlassCard(cornerRadius: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Proof Verified")
                        .font(HustleFont.caption(.bold))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(data.proofItemsVerified) items verified")
                        .font(HustleFont.body(.semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(20)
        }
    }

    // MARK: - Task Details Card

    private var taskDetailsCard: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(data.taskTitle)
                    .font(HustleFont.body(.bold))
                    .foregroundColor(.white)

                Text("Completed on \(data.completedDate)")
                    .font(HustleFont.caption())
                    .foregroundColor(.white.opacity(0.5))

                Text(data.contractId)
                    .font(HustleFont.micro(.medium))
                    .monospaced()
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }

    // MARK: - Primary Action

    private var primaryAction: some View {
        VStack(spacing: 12) {
            Button(action: onLeaveFeedback) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 22))

                    Text("Leave Feedback")
                        .font(HustleFont.headline(.bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appleGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .appleGreen.opacity(0.4), radius: 25)
            }
            .buttonStyle(ScaleButtonStyle())

            Text("Optional, helps maintain trust")
                .font(HustleFont.caption())
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 24)
    }

    // MARK: - Support Footer

    private var supportFooter: some View {
        VStack(spacing: 8) {
            HustleDivider(opacity: 0.05)
                .padding(.top, 16)

            Button(action: onReportIssue) {
                Text("Report an issue")
                    .font(HustleFont.caption())
                    .underline()
                    .foregroundColor(.white.opacity(0.4))
            }

            Text("Use only if something went wrong")
                .font(HustleFont.micro(.medium))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

// MARK: - Preview

#Preview {
    PosterTaskCompletionScreen(
        data: PosterTaskCompletionData(
            hustlerName: "Alex M.",
            hustlerInitials: "AM",
            hustlerTaskCount: 47,
            hustlerRating: 4.9,
            verificationItems: [
                "Work completed as described",
                "Required proof verified",
                "Location & time confirmed"
            ],
            paymentAmount: 45.00,
            fundsReleased: true,
            proofItemsVerified: 3,
            taskTitle: "Move furniture — 2nd floor walk-up",
            completedDate: "Oct 24, 2024 at 2:34 PM",
            contractId: "Contract ID: #820-A4"
        ),
        onLeaveFeedback: {},
        onReportIssue: {},
        onDismiss: {},
        onShare: {}
    )
}
