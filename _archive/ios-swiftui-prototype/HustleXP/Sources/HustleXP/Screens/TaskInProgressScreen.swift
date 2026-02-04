// TaskInProgressScreen.swift
// HustleXP iOS - Task In Progress Dashboard
// Source: 08-hustler-task-in-progress.html

import SwiftUI

// MARK: - Data Models

public struct TaskInProgressData {
    public let taskTitle: String
    public let contractId: String
    public let isInstantTask: Bool
    public let timeRemaining: TimeInterval
    public let totalTime: TimeInterval
    public let steps: [TaskStep]
    public let proofRequirements: ProofRequirements
    public let locationStatus: String
    public let riskLevel: RiskLevel
    public let tierName: String

    public init(
        taskTitle: String,
        contractId: String,
        isInstantTask: Bool = true,
        timeRemaining: TimeInterval,
        totalTime: TimeInterval,
        steps: [TaskStep],
        proofRequirements: ProofRequirements,
        locationStatus: String = "On-site",
        riskLevel: RiskLevel = .low,
        tierName: String = "Gold"
    ) {
        self.taskTitle = taskTitle
        self.contractId = contractId
        self.isInstantTask = isInstantTask
        self.timeRemaining = timeRemaining
        self.totalTime = totalTime
        self.steps = steps
        self.proofRequirements = proofRequirements
        self.locationStatus = locationStatus
        self.riskLevel = riskLevel
        self.tierName = tierName
    }
}

public struct TaskStep {
    public let title: String
    public let subtitle: String?
    public let status: StepStatus

    public enum StepStatus {
        case completed
        case current
        case pending
    }

    public init(title: String, subtitle: String? = nil, status: StepStatus) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
    }
}

public struct ProofRequirements {
    public let title: String
    public let constraints: [String]
    public let visibleItems: [String]
    public let rules: String
    public let warningText: String

    public init(
        title: String,
        constraints: [String],
        visibleItems: [String],
        rules: String,
        warningText: String
    ) {
        self.title = title
        self.constraints = constraints
        self.visibleItems = visibleItems
        self.rules = rules
        self.warningText = warningText
    }
}

public enum RiskLevel: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var color: Color {
        switch self {
        case .low: return .appleGreen
        case .medium: return .appleOrange
        case .high: return .appleRed
        }
    }
}

// MARK: - View

public struct TaskInProgressScreen: View {
    let data: TaskInProgressData?
    let isLoading: Bool
    let onCapturePhoto: () -> Void
    let onReportIssue: () -> Void

    public init(
        data: TaskInProgressData?,
        isLoading: Bool = false,
        onCapturePhoto: @escaping () -> Void,
        onReportIssue: @escaping () -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onCapturePhoto = onCapturePhoto
        self.onReportIssue = onReportIssue
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
            Text("Loading task details...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 48))
                .foregroundColor(.hustleTextMuted)
            Text("No active task")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: TaskInProgressData) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                headerSection(data: data)

                // Time Progress
                timeProgressSection(data: data)

                // Steps
                stepsSection(steps: data.steps)

                // Proof Card
                proofCard(data: data)

                // Info Grid
                infoGrid(data: data)

                // Report Issue
                reportIssueButton

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }

    // MARK: - Sections

    private func headerSection(data: TaskInProgressData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Working badge
                HStack(spacing: 8) {
                    Text("WORKING")
                        .font(HustleFont.micro(.bold))
                        .tracking(2)
                        .foregroundColor(.appleOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .stroke(Color.appleOrange.opacity(0.3), lineWidth: 1)
                                .background(Capsule().fill(Color.appleOrange.opacity(0.1)))
                        )

                    Circle()
                        .fill(Color.appleOrange)
                        .frame(width: 6, height: 6)
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(.zinc500)
                }
            }

            Text(data.taskTitle)
                .font(HustleFont.title1(.bold))
                .foregroundColor(.white)
                .lineLimit(2)

            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.zinc400)

                Text(data.isInstantTask ? "Instant task" : "Standard task")
                    .foregroundColor(.zinc400)

                Text("•")
                    .foregroundColor(.zinc400)

                Text("Escrow protected")
                    .foregroundColor(.zinc400)
            }
            .font(HustleFont.callout())
        }
    }

    private func timeProgressSection(data: TaskInProgressData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TIME REMAINING")
                    .hustleSectionHeader()

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 16))
                        .foregroundColor(.appleOrange.opacity(0.9))

                    Text(formatTime(data.timeRemaining))
                        .font(HustleFont.headline(.bold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
            }

            GeometryReader { geo in
                Capsule()
                    .fill(Color(hex: "#1C1C1E"))
                    .overlay(
                        Capsule()
                            .fill(Color.appleOrange)
                            .frame(width: geo.size.width * CGFloat(data.timeRemaining / data.totalTime))
                            .shadow(color: .appleOrange.opacity(0.6), radius: 6)
                        ,
                        alignment: .leading
                    )
            }
            .frame(height: 6)
            .clipShape(Capsule())
        }
    }

    private func stepsSection(steps: [TaskStep]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("REQUIRED STEPS")
                .hustleSectionHeader()
                .padding(.bottom, 20)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                StepIndicator(
                    title: step.title,
                    subtitle: step.subtitle,
                    state: stepState(from: step.status),
                    isLast: index == steps.count - 1
                )
            }
        }
    }

    private func proofCard(data: TaskInProgressData) -> some View {
        ZStack {
            // Glow effect
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appleOrange.opacity(0.2))
                .blur(radius: 20)
                .opacity(0.3)

            GlassCard(cornerRadius: 12, borderColor: .appleOrange, borderWidth: 2) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.proofRequirements.title)
                                .font(HustleFont.headline(.bold))
                                .foregroundColor(.white)

                            Text("Contract ID: \(data.contractId)")
                                .font(HustleFont.mono(10))
                                .foregroundColor(.zinc500)
                                .textCase(.uppercase)
                                .tracking(1)
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appleOrange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.appleOrange.opacity(0.2), lineWidth: 1)
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: "checklist")
                                .font(.system(size: 20))
                                .foregroundColor(.appleOrange)
                        }
                    }

                    // Constraint chips
                    FlowLayout(spacing: 8) {
                        ForEach(data.proofRequirements.constraints, id: \.self) { constraint in
                            constraintChip(text: constraint)
                        }

                        constraintChip(text: "Verified", isHighlighted: true)
                    }

                    HustleDivider()

                    // Requirements
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WHAT MUST BE VISIBLE")
                                .font(HustleFont.micro(.bold))
                                .tracking(1.5)
                                .foregroundColor(.zinc500)

                            ForEach(data.proofRequirements.visibleItems, id: \.self) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.appleGreen)

                                    Text(item)
                                        .font(HustleFont.callout(.light))
                                        .foregroundColor(.zinc200)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("RULES")
                                .font(HustleFont.micro(.bold))
                                .tracking(1.5)
                                .foregroundColor(.zinc500)

                            Text(data.proofRequirements.rules)
                                .font(HustleFont.callout(.light))
                                .foregroundColor(.zinc300)
                        }
                    }

                    // Warning
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.appleOrange.opacity(0.7))

                        Text(data.proofRequirements.warningText)
                            .font(HustleFont.micro(.medium))
                            .foregroundColor(.zinc400)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#1C1C1E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                    )

                    // Capture button
                    PrimaryButton("Capture Required Photo", icon: "camera.fill", color: .appleBlue, action: onCapturePhoto)
                }
                .padding(20)
            }
        }
    }

    private func constraintChip(text: String, isHighlighted: Bool = false) -> some View {
        Text(text)
            .font(HustleFont.mono(10))
            .foregroundColor(isHighlighted ? .appleOrange : .zinc300)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHighlighted ? Color.appleOrange.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isHighlighted ? Color.appleOrange.opacity(0.2) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }

    private func infoGrid(data: TaskInProgressData) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            infoCard(icon: "location.fill", label: "Location", value: data.locationStatus)
            infoCard(icon: "shield.fill", label: "Risk", value: data.riskLevel.rawValue, valueColor: data.riskLevel.color)
            infoCard(icon: "rosette", label: "Tier", value: data.tierName, valueColor: Color(hex: "#FFD700"))
        }
    }

    private func infoCard(icon: String, label: String, value: String, valueColor: Color = .white) -> some View {
        GlassCard(cornerRadius: 12) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.zinc500)

                Text(label.uppercased())
                    .font(HustleFont.micro(.bold))
                    .tracking(2)
                    .foregroundColor(.zinc500)

                Text(value)
                    .font(HustleFont.callout(.semibold))
                    .foregroundColor(valueColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private var reportIssueButton: some View {
        Button(action: onReportIssue) {
            HStack(spacing: 8) {
                Image(systemName: "flag")
                    .font(.system(size: 12))
                Text("REPORT AN ISSUE")
                    .font(HustleFont.micro(.medium))
                    .tracking(1)
            }
            .foregroundColor(.zinc600)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(Color.clear)
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func stepState(from status: TaskStep.StepStatus) -> StepIndicator.State {
        switch status {
        case .completed: return .completed
        case .current: return .current
        case .pending: return .pending
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview("Task In Progress") {
    TaskInProgressScreen(
        data: TaskInProgressData(
            taskTitle: "Site Survey: Sector 4",
            contractId: "#820-A4",
            isInstantTask: true,
            timeRemaining: 2520,
            totalTime: 7200,
            steps: [
                TaskStep(title: "Accept Mission", status: .completed),
                TaskStep(title: "Arrive at Location", subtitle: "GPS Verified: 10:48 AM", status: .completed),
                TaskStep(title: "Upload in-progress proof", status: .current),
                TaskStep(title: "Submit Final Report", status: .pending)
            ],
            proofRequirements: ProofRequirements(
                title: "In-Progress Proof Required",
                constraints: ["On-site only", "During work window", "Rear camera"],
                visibleItems: ["Entry point of the site", "Active work area", "Equipment or materials in use"],
                rules: "Wide-angle photo • No filters or edits • Taken on-site (GPS verified)",
                warningText: "Missing or unclear proof may delay completion or affect XP."
            ),
            locationStatus: "On-site",
            riskLevel: .low,
            tierName: "Gold"
        ),
        onCapturePhoto: {},
        onReportIssue: {}
    )
}
