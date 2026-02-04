// TaskCompletionBlockedScreen.swift
// HustleXP - Hustler Task Completion (Blocked State)
// Source: 09-hustler-task-completion-BLOCKED.html

import SwiftUI

// MARK: - Data Models

public struct TaskCompletionBlockedData {
    public let taskId: String
    public let failureReasons: [String]
    public let submissionFileName: String
    public let submissionTime: String

    public init(
        taskId: String,
        failureReasons: [String],
        submissionFileName: String,
        submissionTime: String
    ) {
        self.taskId = taskId
        self.failureReasons = failureReasons
        self.submissionFileName = submissionFileName
        self.submissionTime = submissionTime
    }
}

// MARK: - Task Completion Blocked Screen

public struct TaskCompletionBlockedScreen: View {
    public let data: TaskCompletionBlockedData
    public let onViewDetails: () -> Void
    public let onContactSupport: () -> Void
    public let onBack: () -> Void
    public let onHelp: () -> Void

    public init(
        data: TaskCompletionBlockedData,
        onViewDetails: @escaping () -> Void,
        onContactSupport: @escaping () -> Void,
        onBack: @escaping () -> Void,
        onHelp: @escaping () -> Void
    ) {
        self.data = data
        self.onViewDetails = onViewDetails
        self.onContactSupport = onContactSupport
        self.onBack = onBack
        self.onHelp = onHelp
    }

    public var body: some View {
        ZStack {
            // Dark background
            Color(red: 18/255, green: 20/255, blue: 22/255).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerBar

                ScrollView {
                    VStack(spacing: 24) {
                        // Status section
                        statusSection

                        // Verification failed card
                        verificationFailedCard

                        // Status cards
                        HStack(spacing: 16) {
                            xpOutcomeCard
                            paymentStatusCard
                        }

                        // System verdict divider
                        systemVerdictDivider

                        // Submission preview
                        submissionPreview
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 150)
                }
            }

            // Footer
            VStack {
                Spacer()
                footerSection
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Task \(data.taskId) Review")
                .font(HustleFont.callout(.bold))
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Button(action: onHelp) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 18/255, green: 20/255, blue: 22/255).opacity(0.8))
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(spacing: 16) {
            // Status badge
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 20))

                Text("Completion Blocked")
                    .font(HustleFont.caption(.bold))
                    .textCase(.uppercase)
                    .tracking(2)
            }
            .foregroundColor(.appleRed)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.appleRed.opacity(0.1))
            .overlay(
                Capsule()
                    .stroke(Color.appleRed.opacity(0.2), lineWidth: 1)
            )
            .clipShape(Capsule())

            // Title
            VStack(spacing: 8) {
                Text("Completion criteria")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("not satisfied")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("This task cannot be finalized due to missing requirements.")
                .font(HustleFont.caption())
                .foregroundColor(.zinc400)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    // MARK: - Verification Failed Card

    private var verificationFailedCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Circle()
                    .fill(Color.appleRed.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "xmark.shield.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appleRed)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Verification Failed")
                            .font(HustleFont.headline(.bold))
                            .foregroundColor(.white)

                        Spacer()

                        Text("Action Required")
                            .font(HustleFont.micro(.bold))
                            .textCase(.uppercase)
                            .tracking(1)
                            .foregroundColor(.appleRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appleRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Text("The submitted evidence does not meet the specified standards for this campaign.")
                        .font(HustleFont.caption())
                        .foregroundColor(.zinc400)
                        .padding(.top, 4)
                }
            }

            VStack(spacing: 8) {
                ForEach(data.failureReasons, id: \.self) { reason in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.appleRed)

                        Text(reason)
                            .font(HustleFont.caption(.medium))
                            .foregroundColor(.zinc300)
                    }
                }
            }
            .padding(12)
            .background(Color(red: 28/255, green: 31/255, blue: 36/255))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.zinc800, lineWidth: 1)
            )
        }
        .padding(20)
        .background(Color(red: 28/255, green: 31/255, blue: 36/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.zinc800, lineWidth: 1)
        )
    }

    // MARK: - XP Outcome Card

    private var xpOutcomeCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("XP Outcome")
                    .font(HustleFont.micro(.bold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.zinc400)

                Text("Withheld")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.appleRed)
                        .frame(width: 8, height: 8)

                    Text("Criteria not met")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.appleRed)
                }
                .padding(.top, 8)
            }

            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: 8, y: -8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(red: 28/255, green: 31/255, blue: 36/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.zinc800, lineWidth: 1)
        )
    }

    // MARK: - Payment Status Card

    private var paymentStatusCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Payment Status")
                    .font(HustleFont.micro(.bold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.zinc400)

                Text("Blocked")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.appleRed)
                        .frame(width: 8, height: 8)

                    Text("Pending resolution")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.appleRed)
                }
                .padding(.top, 8)
            }

            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: 8, y: -8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(red: 28/255, green: 31/255, blue: 36/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.zinc800, lineWidth: 1)
        )
    }

    // MARK: - System Verdict Divider

    private var systemVerdictDivider: some View {
        HStack {
            Rectangle()
                .fill(Color.zinc800)
                .frame(height: 1)

            Text("System Verdict")
                .font(HustleFont.micro(.bold))
                .textCase(.uppercase)
                .tracking(2)
                .foregroundColor(.zinc600)

            Rectangle()
                .fill(Color.zinc800)
                .frame(height: 1)
        }
    }

    // MARK: - Submission Preview

    private var submissionPreview: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.zinc800)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "doc.fill")
                        .foregroundColor(.zinc600)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(data.submissionFileName)
                    .font(HustleFont.caption(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("Uploaded \(data.submissionTime)")
                    .font(HustleFont.micro())
                    .foregroundColor(.zinc400)
            }

            Spacer()

            Image(systemName: "eye")
                .foregroundColor(.zinc400)
        }
        .padding(12)
        .background(Color(red: 28/255, green: 31/255, blue: 36/255))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.zinc800, lineWidth: 1)
        )
        .opacity(0.6)
        .grayscale(1)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 16) {
            Button(action: onViewDetails) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))

                    Text("View Issue Details")
                        .font(HustleFont.body(.bold))
                }
                .foregroundColor(.appleRed)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appleRed, lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Support section
            VStack(spacing: 8) {
                HustleDivider(opacity: 0.1)

                Text("If you believe this is a system error,")
                    .font(HustleFont.caption())
                    .foregroundColor(.zinc500)

                Button(action: onContactSupport) {
                    Text("contact support")
                        .font(HustleFont.caption())
                        .underline()
                        .foregroundColor(.zinc400)
                }

                Text("Use only if you believe this decision is incorrect")
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(.zinc500.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 20)
        .background(Color(red: 18/255, green: 20/255, blue: 22/255))
    }
}

// MARK: - Preview

#Preview {
    TaskCompletionBlockedScreen(
        data: TaskCompletionBlockedData(
            taskId: "#4209",
            failureReasons: [
                "Required proof missing",
                "Task not completed as described"
            ],
            submissionFileName: "Submission_v3_Final.jpg",
            submissionTime: "2 hours ago"
        ),
        onViewDetails: {},
        onContactSupport: {},
        onBack: {},
        onHelp: {}
    )
}
