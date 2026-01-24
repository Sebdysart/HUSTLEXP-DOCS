// HustleXP.swift
// HustleXP iOS SwiftUI Package
// Production-ready screens converted from STITCH HTML specifications

import SwiftUI

// MARK: - Version Info

public enum HustleXPVersion {
    public static let version = "1.0.0"
    public static let buildDate = "2025-01-22"
    public static let source = "STITCH HTML Specifications"

    /// Total screens implemented
    public static let screenCount = 15

    /// Screens implemented
    public static let screens: [String] = [
        // Core Screens
        "InstantInterruptCard",
        "HustlerHomeScreen",
        "TrustTierLadderScreen",
        "TaskInProgressScreen",
        "XPBreakdownScreen",
        // Task Completion States (Hustler)
        "TaskCompletionApprovedScreen",
        "TaskCompletionActionRequiredScreen",
        "TaskCompletionBlockedScreen",
        // Task Completion (Poster)
        "PosterTaskCompletionScreen",
        // Trust & System
        "TrustChangeExplanationScreen",
        // Disputes
        "DisputeEntryScreen",
        // Edge States
        "NoTasksAvailableScreen",
        "EligibilityMismatchScreen",
        "TrustTierLockedScreen"
    ]
}

// MARK: - Preview Helpers

#if DEBUG
public struct HustleXPCatalog: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Core Screens") {
                    NavigationLink("Instant Interrupt Card") {
                        InstantInterruptCard(
                            task: InstantTaskData(
                                title: "Move furniture — 2nd floor walk-up",
                                distance: "0.8 mi away",
                                amount: 45.00
                            ),
                            onAccept: {},
                            onSkip: {}
                        )
                    }

                    NavigationLink("Hustler Home") {
                        HustlerHomeScreen(
                            data: HustlerHomeData(
                                user: HustlerUser(
                                    username: "Alex_Hustles",
                                    level: 12,
                                    trustTier: 3,
                                    trustTierName: "Trusted",
                                    xpProgress: 0.75,
                                    streakDays: 7
                                ),
                                todayStats: TodayStats(
                                    earnings: 142.00,
                                    xpGained: 450,
                                    tasksCompleted: 3
                                ),
                                isInstantModeOn: true,
                                progression: ProgressionData(
                                    currentGoalTitle: "In-Home Cleared",
                                    tasksCompleted: 18,
                                    tasksRequired: 25,
                                    daysActive: 22,
                                    daysRequired: 30,
                                    nextTierTitle: "Commercial Licensed"
                                )
                            ),
                            onNotificationsTap: {},
                            onInstantModeToggle: { _ in },
                            onViewRoadmap: {},
                            onTabSelect: { _ in }
                        )
                    }

                    NavigationLink("Trust Tier Ladder") {
                        TrustTierLadderScreen(
                            data: TrustTierLadderData(
                                currentTier: 2,
                                tiers: [
                                    TierInfo(tier: 1, name: "Unverified", tagline: "Starting", benefits: [], isPast: true),
                                    TierInfo(tier: 2, name: "Verified", tagline: "Trusted", benefits: ["Instant Payouts"]),
                                    TierInfo(tier: 3, name: "Trusted", tagline: "Premium", benefits: ["Weekly Bonus"], xpCurrent: 2847, xpRequired: 3200),
                                    TierInfo(tier: 4, name: "In-Home", tagline: "Elite", benefits: ["High-value tasks"], isLocked: true)
                                ],
                                totalXP: 12450,
                                totalTasks: 48,
                                rating: 4.9
                            ),
                            onBack: {}
                        )
                    }

                    NavigationLink("Task In Progress") {
                        TaskInProgressScreen(
                            data: TaskInProgressData(
                                taskTitle: "Site Survey: Sector 4",
                                contractId: "#820-A4",
                                timeRemaining: 2520,
                                totalTime: 7200,
                                steps: [
                                    TaskStep(title: "Accept Mission", status: .completed),
                                    TaskStep(title: "Arrive at Location", status: .completed),
                                    TaskStep(title: "Upload proof", status: .current),
                                    TaskStep(title: "Submit Report", status: .pending)
                                ],
                                proofRequirements: ProofRequirements(
                                    title: "In-Progress Proof Required",
                                    constraints: ["On-site only"],
                                    visibleItems: ["Entry point", "Work area"],
                                    rules: "Wide-angle photo",
                                    warningText: "Missing proof may delay completion"
                                )
                            ),
                            onCapturePhoto: {},
                            onReportIssue: {}
                        )
                    }

                    NavigationLink("XP Breakdown") {
                        XPBreakdownScreen(
                            data: XPBreakdownData(
                                totalXP: 342,
                                dailyGoal: 500,
                                dailyProgress: 0.68,
                                bonuses: [
                                    XPBonus(title: "Instant Mode", subtitle: "Acceptance within 30s", multiplier: 1.5, xpGained: 68, icon: "bolt.fill", color: .appleOrange),
                                    XPBonus(title: "Speed Bonus", subtitle: "Completed < 2 hrs", multiplier: 1.2, xpGained: 24, icon: "timer", color: .appleGreen)
                                ],
                                streakDays: 7,
                                streakBonus: 30,
                                baseXPItems: [
                                    BaseXPItem(title: "Logo Design Task", completedAt: "10:42 AM", xp: 150)
                                ],
                                calculationBase: 300,
                                multipliers: [1.5, 1.2, 1.1],
                                potentialXP: 594,
                                date: "Today, Oct 24"
                            )
                        )
                    }
                }

                Section("Task Completion (Hustler)") {
                    NavigationLink("Completion - Approved") {
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

                    NavigationLink("Completion - Action Required") {
                        TaskCompletionActionRequiredScreen(
                            data: TaskCompletionActionRequiredData(
                                taskId: "#9942",
                                rejectionReasons: [
                                    RejectionReason(icon: "eye.slash.fill", title: "Entry point not visible", description: "Ensure the store entrance is captured."),
                                    RejectionReason(icon: "sun.min.fill", title: "Image too dark", description: "Please turn on flash.")
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

                    NavigationLink("Completion - Blocked") {
                        TaskCompletionBlockedScreen(
                            data: TaskCompletionBlockedData(
                                taskId: "#4209",
                                failureReasons: ["Required proof missing", "Task not completed as described"],
                                submissionFileName: "Submission_v3_Final.jpg",
                                submissionTime: "2 hours ago"
                            ),
                            onViewDetails: {},
                            onContactSupport: {},
                            onBack: {},
                            onHelp: {}
                        )
                    }
                }

                Section("Task Completion (Poster)") {
                    NavigationLink("Poster - Task Completed") {
                        PosterTaskCompletionScreen(
                            data: PosterTaskCompletionData(
                                hustlerName: "Alex M.",
                                hustlerInitials: "AM",
                                hustlerTaskCount: 47,
                                hustlerRating: 4.9,
                                verificationItems: ["Work completed", "Proof verified", "Location confirmed"],
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
                }

                Section("Trust & System") {
                    NavigationLink("Trust Change Explanation") {
                        TrustChangeExplanationScreen(
                            data: TrustChangeExplanationData(
                                taskTitle: "Site Survey: Sector 4",
                                contractId: "Contract ID: #820-A4",
                                completedDate: "Oct 24, 2024",
                                xpGained: 342,
                                xpBreakdown: "Base: 300 XP • Instant: +1.5×",
                                reliabilityStatus: "Passed",
                                reliabilityPassed: true,
                                trustTierName: "Trusted",
                                trustTierNumber: 3,
                                trustTierChanged: false,
                                tasksUntilPromotion: 3,
                                systemImpacts: ["Priority matching increased", "No penalties applied"],
                                noPenalties: true
                            ),
                            onContinue: {},
                            onBack: {}
                        )
                    }
                }

                Section("Disputes") {
                    NavigationLink("Dispute Entry (Hustler)") {
                        DisputeEntryScreen(
                            data: DisputeEntryData(
                                role: .hustler,
                                taskTitle: "Backend API Refactor",
                                contractId: "#83921",
                                paymentAmount: 450.00,
                                completionAttemptDate: "Oct 24, 2024",
                                systemVerdict: "Completion not approved",
                                disputeReasons: [
                                    DisputeReason(title: "Access not provided"),
                                    DisputeReason(title: "Requirements changed"),
                                    DisputeReason(title: "System error")
                                ],
                                maxEvidenceCount: 2
                            ),
                            onSubmit: { _, _ in },
                            onBack: {},
                            onUploadImage: {},
                            onUploadDocument: {}
                        )
                    }

                    NavigationLink("Dispute Entry (Poster)") {
                        DisputeEntryScreen(
                            data: DisputeEntryData(
                                role: .poster,
                                taskTitle: "Site Survey: Sector 4",
                                contractId: "#820-A4",
                                paymentAmount: 45.00,
                                completionAttemptDate: "Oct 24, 2024",
                                systemVerdict: "Completion not approved",
                                disputeReasons: [
                                    DisputeReason(title: "Deliverables missing"),
                                    DisputeReason(title: "Proof not meeting criteria"),
                                    DisputeReason(title: "Work deviates from description")
                                ],
                                maxEvidenceCount: 2
                            ),
                            onSubmit: { _, _ in },
                            onBack: {},
                            onUploadImage: {},
                            onUploadDocument: {}
                        )
                    }
                }

                Section("Edge States") {
                    NavigationLink("No Tasks Available") {
                        NoTasksAvailableScreen(
                            data: NoTasksData(),
                            onReturnToDashboard: {}
                        )
                    }

                    NavigationLink("Eligibility Mismatch") {
                        EligibilityMismatchScreen(
                            data: EligibilityMismatchData(
                                taskTitle: "Interior Renovation",
                                requiredTier: 4,
                                requiredTierName: "In-Home",
                                currentTier: 2,
                                currentTierName: "Verified",
                                missingRequirements: [
                                    MissingRequirement(icon: "shield.checkered", title: "Background Check", description: "Required for access")
                                ],
                                upgradeActions: [
                                    UpgradeAction(title: "Start Background Check", isPrimary: true)
                                ]
                            ),
                            onActionTap: { _ in },
                            onDismiss: {}
                        )
                    }

                    NavigationLink("Trust Tier Locked") {
                        TrustTierLockedScreen(
                            data: TrustTierLockedData(
                                lockedTier: 3,
                                lockedTierName: "Trusted",
                                currentTier: 2,
                                currentTierName: "Verified",
                                xpCurrent: 2450,
                                xpRequired: 5000,
                                benefits: ["Weekly Bonus", "Priority Dispatch"]
                            ),
                            onViewProgress: {},
                            onDismiss: {}
                        )
                    }
                }
            }
            .navigationTitle("HustleXP Screens")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("Screen Catalog") {
    HustleXPCatalog()
}
#endif
