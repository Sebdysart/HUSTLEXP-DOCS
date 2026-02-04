// DisputeEntryScreen.swift
// HustleXP - Dispute Entry Screen (for both Hustler and Poster)
// Source: 13-dispute-entry-hustler-FIXED.html & 13-dispute-entry-poster-FIXED.html

import SwiftUI

// MARK: - Data Models

public enum DisputeRole {
    case hustler
    case poster
}

public struct DisputeEntryData {
    public let role: DisputeRole
    public let taskTitle: String
    public let contractId: String
    public let paymentAmount: Double
    public let completionAttemptDate: String
    public let systemVerdict: String
    public let disputeReasons: [DisputeReason]
    public let maxEvidenceCount: Int

    public init(
        role: DisputeRole,
        taskTitle: String,
        contractId: String,
        paymentAmount: Double,
        completionAttemptDate: String,
        systemVerdict: String,
        disputeReasons: [DisputeReason],
        maxEvidenceCount: Int
    ) {
        self.role = role
        self.taskTitle = taskTitle
        self.contractId = contractId
        self.paymentAmount = paymentAmount
        self.completionAttemptDate = completionAttemptDate
        self.systemVerdict = systemVerdict
        self.disputeReasons = disputeReasons
        self.maxEvidenceCount = maxEvidenceCount
    }
}

public struct DisputeReason: Identifiable {
    public let id = UUID()
    public let title: String

    public init(title: String) {
        self.title = title
    }
}

// MARK: - Dispute Entry Screen

public struct DisputeEntryScreen: View {
    public let data: DisputeEntryData
    public let onSubmit: (String, Bool) -> Void
    public let onBack: () -> Void
    public let onUploadImage: () -> Void
    public let onUploadDocument: () -> Void

    @State private var selectedReasonId: UUID?
    @State private var acknowledgementChecked: Bool = false
    @State private var certifyChecked: Bool = false

    private var primaryColor: Color {
        data.role == .hustler ? Color(hex: "#42bcf0") : Color(hex: "#1f6b7a")
    }

    private var backgroundColor: Color {
        data.role == .hustler ? Color(hex: "#181a1b") : .hustleBackgroundDark
    }

    public init(
        data: DisputeEntryData,
        onSubmit: @escaping (String, Bool) -> Void,
        onBack: @escaping () -> Void,
        onUploadImage: @escaping () -> Void,
        onUploadDocument: @escaping () -> Void
    ) {
        self.data = data
        self.onSubmit = onSubmit
        self.onBack = onBack
        self.onUploadImage = onUploadImage
        self.onUploadDocument = onUploadDocument
    }

    public var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerBar

                ScrollView {
                    VStack(spacing: 16) {
                        // Consequence disclosure
                        consequenceDisclosure

                        // Task context card
                        taskContextCard

                        // Qualification section
                        qualificationSection

                        // Reason selector
                        reasonSelector

                        // Evidence upload
                        evidenceUpload

                        // Consequences disclosure
                        consequencesCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 200)
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
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Dispute Task Outcome")
                .font(HustleFont.body(.bold))
                .foregroundColor(.white)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor.opacity(0.9))
    }

    // MARK: - Consequence Disclosure

    private var consequenceDisclosure: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(primaryColor)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Successful disputes")
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)

                    Text("restore XP and trust scores.")
                        .foregroundColor(.zinc300)
                }
                .font(HustleFont.caption(.medium))

                HStack {
                    Text("Frivolous abuse")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#96213A"))

                    Text("of this system significantly reduces future task eligibility.")
                        .foregroundColor(.zinc300)
                }
                .font(HustleFont.caption(.medium))
            }
        }
        .padding(20)
        .background(Color(hex: "#242526"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            HStack {
                Rectangle()
                    .fill(primaryColor)
                    .frame(width: 4)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.3), radius: 8)
        .padding(.top, 16)
    }

    // MARK: - Task Context Card

    private var taskContextCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Context")
                .font(HustleFont.micro(.semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(primaryColor.opacity(0.8))

            Text(data.taskTitle)
                .font(HustleFont.headline(.bold))
                .foregroundColor(.white)

            Text("\(data.contractId) • \(String(format: "$%.2f", data.paymentAmount))")
                .font(HustleFont.caption(.medium))
                .foregroundColor(.zinc400)

            Text("Completion attempted on \(data.completionAttemptDate)")
                .font(HustleFont.caption())
                .foregroundColor(.zinc500)

            Text("System verdict: \(data.systemVerdict)")
                .font(HustleFont.caption())
                .foregroundColor(.zinc500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .padding(.top, 100)
        .background(
            LinearGradient(
                colors: [backgroundColor.opacity(0.4), backgroundColor.opacity(0.95), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Qualification Section

    private var qualificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .frame(width: 20)

                Text("Disputing triggers a manual review by HustleXP staff. This freezes funds and may delay payment release by up to 7 days.")
                    .font(HustleFont.caption())
                    .foregroundColor(.zinc300)
            }

            HustleDivider(opacity: 0.05)

            Button(action: { acknowledgementChecked.toggle() }) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: acknowledgementChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(acknowledgementChecked ? primaryColor : .zinc600)

                    Text("I confirm that the selected issue is accurate and understand that false or unsupported disputes may reduce my future task eligibility.")
                        .font(HustleFont.caption(.medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }

            Text("You may submit one dispute per task. This action cannot be undone.")
                .font(HustleFont.micro())
                .italic()
                .foregroundColor(.zinc500)
                .padding(.leading, 32)
        }
        .padding(20)
        .background(Color(hex: "#242526"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Reason Selector

    private var reasonSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reason for Dispute")
                .font(HustleFont.caption(.bold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(.zinc400)

            Text("Which requirement was not met?")
                .font(HustleFont.body(.semibold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(data.disputeReasons) { reason in
                    Button(action: { selectedReasonId = reason.id }) {
                        HStack {
                            Text(reason.title)
                                .font(HustleFont.caption(.medium))
                                .foregroundColor(selectedReasonId == reason.id ? primaryColor : .white)

                            Spacer()

                            Circle()
                                .stroke(selectedReasonId == reason.id ? primaryColor : .zinc600, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(selectedReasonId == reason.id ? primaryColor : .clear)
                                        .frame(width: 12, height: 12)
                                )
                        }
                        .padding(16)
                        .background(selectedReasonId == reason.id ? primaryColor.opacity(0.1) : Color(hex: "#242526"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedReasonId == reason.id ? primaryColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(16)
    }

    // MARK: - Evidence Upload

    private var evidenceUpload: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Supporting Evidence")
                    .font(HustleFont.caption(.bold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(.zinc400)

                Spacer()

                Text("Max \(data.maxEvidenceCount)")
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(.zinc500)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            HStack(spacing: 16) {
                Button(action: onUploadImage) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.zinc400)
                            )

                        Text("Upload Image")
                            .font(HustleFont.micro(.medium))
                            .foregroundColor(.zinc500)
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color(hex: "#242526").opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.zinc600, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }

                Button(action: onUploadDocument) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.zinc400)
                            )

                        Text("Add Log/Doc")
                            .font(HustleFont.micro(.medium))
                            .foregroundColor(.zinc500)
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color(hex: "#242526").opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.zinc600, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
        }
        .padding(16)
    }

    // MARK: - Consequences Card

    private var consequencesCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "shield.fill")
                .font(.system(size: 24))
                .foregroundColor(.zinc500)

            VStack(alignment: .leading, spacing: 8) {
                Text("Important:")
                    .font(HustleFont.caption(.medium))
                    .foregroundColor(.zinc300)

                VStack(alignment: .leading, spacing: 4) {
                    Text("• Disputes pause XP and trust updates")
                    Text("• Abuse may reduce future dispute eligibility")
                    Text("• Most disputes resolve within 48 hours")
                    Text("• Successful disputes restore XP and trust")
                }
                .font(HustleFont.caption())
                .foregroundColor(.zinc400)
            }
        }
        .padding(16)
        .background(Color.zinc800.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.zinc800, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button(action: { certifyChecked.toggle() }) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: certifyChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 16))
                        .foregroundColor(certifyChecked ? primaryColor : .zinc600)

                    Text("I confirm that the selected issue is accurate and understand that false or unsupported disputes may reduce my future task eligibility.")
                        .font(HustleFont.micro())
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.leading)
                }
            }

            Button(action: {
                if let reasonId = selectedReasonId,
                   let reason = data.disputeReasons.first(where: { $0.id == reasonId }) {
                    onSubmit(reason.title, acknowledgementChecked && certifyChecked)
                }
            }) {
                Text("Submit Dispute")
                    .font(HustleFont.body(.semibold))
                    .foregroundColor(canSubmit ? .white.opacity(0.9) : .hustleTextMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(canSubmit ? Color(hex: "#4D4D4D") : Color(hex: "#2C2C2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: canSubmit ? Color(hex: "#4D4D4D").opacity(0.4) : .clear, radius: 20)
            }
            .disabled(!canSubmit)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .padding(.top, 16)
        .background(backgroundColor.opacity(0.95))
    }

    private var canSubmit: Bool {
        selectedReasonId != nil && acknowledgementChecked && certifyChecked
    }
}

// MARK: - Preview

#Preview("Hustler Dispute") {
    DisputeEntryScreen(
        data: DisputeEntryData(
            role: .hustler,
            taskTitle: "Backend API Refactor",
            contractId: "#83921",
            paymentAmount: 450.00,
            completionAttemptDate: "Oct 24, 2024 at 2:34 PM",
            systemVerdict: "Completion not approved",
            disputeReasons: [
                DisputeReason(title: "Access not provided as described"),
                DisputeReason(title: "Task requirements changed after acceptance"),
                DisputeReason(title: "System verification error"),
                DisputeReason(title: "Safety issue prevented completion")
            ],
            maxEvidenceCount: 2
        ),
        onSubmit: { _, _ in },
        onBack: {},
        onUploadImage: {},
        onUploadDocument: {}
    )
}

#Preview("Poster Dispute") {
    DisputeEntryScreen(
        data: DisputeEntryData(
            role: .poster,
            taskTitle: "Site Survey: Sector 4",
            contractId: "#820-A4",
            paymentAmount: 45.00,
            completionAttemptDate: "Oct 24, 2024 at 2:34 PM",
            systemVerdict: "Completion not approved",
            disputeReasons: [
                DisputeReason(title: "Required deliverables missing"),
                DisputeReason(title: "Proof does not meet stated criteria"),
                DisputeReason(title: "Work deviates from task description"),
                DisputeReason(title: "Location or time verification mismatch"),
                DisputeReason(title: "System error (proof upload / verification failure)")
            ],
            maxEvidenceCount: 2
        ),
        onSubmit: { _, _ in },
        onBack: {},
        onUploadImage: {},
        onUploadDocument: {}
    )
}
