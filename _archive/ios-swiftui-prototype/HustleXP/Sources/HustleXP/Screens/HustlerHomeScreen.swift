// HustlerHomeScreen.swift
// HustleXP iOS - Hustler Home Dashboard
// Source: 02-hustler-home.html

import SwiftUI

// MARK: - Data Models

public struct HustlerHomeData {
    public let user: HustlerUser
    public let todayStats: TodayStats
    public let isInstantModeOn: Bool
    public let progression: ProgressionData
    public let hasUnreadNotifications: Bool

    public init(
        user: HustlerUser,
        todayStats: TodayStats,
        isInstantModeOn: Bool,
        progression: ProgressionData,
        hasUnreadNotifications: Bool = false
    ) {
        self.user = user
        self.todayStats = todayStats
        self.isInstantModeOn = isInstantModeOn
        self.progression = progression
        self.hasUnreadNotifications = hasUnreadNotifications
    }
}

public struct HustlerUser {
    public let username: String
    public let avatarURL: URL?
    public let level: Int
    public let trustTier: Int
    public let trustTierName: String
    public let xpProgress: Double // 0.0 - 1.0
    public let streakDays: Int

    public init(
        username: String,
        avatarURL: URL? = nil,
        level: Int,
        trustTier: Int,
        trustTierName: String,
        xpProgress: Double,
        streakDays: Int
    ) {
        self.username = username
        self.avatarURL = avatarURL
        self.level = level
        self.trustTier = trustTier
        self.trustTierName = trustTierName
        self.xpProgress = xpProgress
        self.streakDays = streakDays
    }
}

public struct TodayStats {
    public let earnings: Decimal
    public let xpGained: Int
    public let tasksCompleted: Int

    public init(earnings: Decimal, xpGained: Int, tasksCompleted: Int) {
        self.earnings = earnings
        self.xpGained = xpGained
        self.tasksCompleted = tasksCompleted
    }
}

public struct ProgressionData {
    public let currentGoalTitle: String
    public let tasksCompleted: Int
    public let tasksRequired: Int
    public let daysActive: Int
    public let daysRequired: Int
    public let nextTierTitle: String

    public init(
        currentGoalTitle: String,
        tasksCompleted: Int,
        tasksRequired: Int,
        daysActive: Int,
        daysRequired: Int,
        nextTierTitle: String
    ) {
        self.currentGoalTitle = currentGoalTitle
        self.tasksCompleted = tasksCompleted
        self.tasksRequired = tasksRequired
        self.daysActive = daysActive
        self.daysRequired = daysRequired
        self.nextTierTitle = nextTierTitle
    }
}

// MARK: - View

public struct HustlerHomeScreen: View {
    // Props
    let data: HustlerHomeData?
    let isLoading: Bool
    let onNotificationsTap: () -> Void
    let onInstantModeToggle: (Bool) -> Void
    let onViewRoadmap: () -> Void
    let onTabSelect: (HomeTab) -> Void

    public enum HomeTab: String, CaseIterable {
        case home = "Home"
        case tasks = "Tasks"
        case add = "Add"
        case wallet = "Wallet"
        case profile = "Profile"
    }

    @State private var selectedTab: HomeTab = .home

    public init(
        data: HustlerHomeData?,
        isLoading: Bool = false,
        onNotificationsTap: @escaping () -> Void,
        onInstantModeToggle: @escaping (Bool) -> Void,
        onViewRoadmap: @escaping () -> Void,
        onTabSelect: @escaping (HomeTab) -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onNotificationsTap = onNotificationsTap
        self.onInstantModeToggle = onInstantModeToggle
        self.onViewRoadmap = onViewRoadmap
        self.onTabSelect = onTabSelect
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
                .tint(.hustlePrimary)
            Text("Loading dashboard...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "house")
                .font(.system(size: 48))
                .foregroundColor(.hustleTextMuted)
            Text("Unable to load dashboard")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: HustlerHomeData) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top App Bar
                    topAppBar(user: data.user, hasNotifications: data.hasUnreadNotifications)

                    // Status Header Widget
                    statusHeaderWidget(user: data.user)

                    // Today's Snapshot
                    todaySnapshotSection(stats: data.todayStats)

                    // Instant Mode Toggle
                    instantModeSection(isOn: data.isInstantModeOn)

                    // Career Progression
                    progressionSection(data: data.progression)

                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }

            // Bottom Navigation
            bottomNavigation
        }
    }

    // MARK: - Components

    private func topAppBar(user: HustlerUser, hasNotifications: Bool) -> some View {
        HStack {
            // Profile section
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.zinc700)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.zinc500)
                        )

                    Circle()
                        .fill(Color.hustlePrimary)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("WELCOME BACK")
                        .font(HustleFont.micro(.medium))
                        .tracking(1)
                        .foregroundColor(.zinc400.opacity(0.7))

                    Text(user.username)
                        .font(HustleFont.callout(.bold))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Notifications button
            Button(action: onNotificationsTap) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.glassSurfaceLight)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "bell")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )

                    if hasNotifications {
                        Circle()
                            .fill(Color.appleRed)
                            .frame(width: 8, height: 8)
                            .offset(x: -6, y: 6)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private func statusHeaderWidget(user: HustlerUser) -> some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 24) {
                // XP Ring
                ProgressRing(
                    progress: user.xpProgress,
                    size: 96,
                    lineWidth: 8,
                    progressColor: .hustlePrimary
                ) {
                    VStack(spacing: 0) {
                        Text("Level")
                            .font(HustleFont.micro(.semibold))
                            .foregroundColor(.zinc400)
                            .textCase(.uppercase)
                            .tracking(1)
                        Text("\(user.level)")
                            .font(HustleFont.title2(.bold))
                            .foregroundColor(.white)
                    }
                }

                // Stats
                VStack(alignment: .leading, spacing: 12) {
                    // Trust Tier Badge
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 14))
                        Text(user.trustTierName.uppercased())
                            .font(HustleFont.micro(.bold))
                            .tracking(0.5)
                    }
                    .foregroundColor(.hustlePrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.hustlePrimary.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.hustlePrimary.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // Streak
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.appleOrange)
                        Text("\(user.streakDays)-day streak")
                            .font(HustleFont.callout(.semibold))
                            .foregroundColor(.white)
                    }

                    // Streak progress bar
                    GeometryReader { geo in
                        Capsule()
                            .fill(Color.zinc800)
                            .frame(height: 4)
                            .overlay(
                                Capsule()
                                    .fill(Color.appleOrange)
                                    .frame(width: geo.size.width)
                                ,
                                alignment: .leading
                            )
                    }
                    .frame(width: 96, height: 4)
                }

                Spacer()
            }
            .padding(20)
        }
    }

    private func todaySnapshotSection(stats: TodayStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S SNAPSHOT")
                .hustleSectionHeader()
                .padding(.leading, 4)

            GlassCard(cornerRadius: 16) {
                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Earnings")
                                .font(HustleFont.callout(.medium))
                                .foregroundColor(.zinc400)

                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(formatCurrency(stats.earnings, showCents: false))
                                    .font(.system(size: 48, weight: .heavy))
                                    .foregroundColor(.white)
                                Text(formatCents(stats.earnings))
                                    .font(HustleFont.title2(.semibold))
                                    .foregroundColor(.zinc500)
                            }
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.hustlePrimary.opacity(0.1))
                                .frame(width: 44, height: 44)

                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.hustlePrimary)
                        }
                    }

                    HustleDivider(opacity: 0.05)

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.hustlePrimary)
                            Text("+\(stats.xpGained) XP Gained")
                                .font(HustleFont.callout(.medium))
                                .foregroundColor(.zinc300)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.zinc500)
                            Text("\(stats.tasksCompleted) Tasks Done")
                                .font(HustleFont.callout())
                                .foregroundColor(.zinc400)
                        }
                    }
                }
                .padding(24)
            }
        }
    }

    private func instantModeSection(isOn: Bool) -> some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.hustlePrimary.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 28))
                        .foregroundColor(.hustlePrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Instant Mode: \(isOn ? "ON" : "OFF")")
                            .font(HustleFont.body(.bold))
                            .foregroundColor(.hustlePrimary)

                        if isOn {
                            StatusIndicator(color: .hustlePrimary)
                        }
                    }

                    Text(isOn ? "High-priority tasks active" : "Enable to receive instant tasks")
                        .font(HustleFont.micro())
                        .foregroundColor(.zinc400)
                }

                Spacer()

                Toggle("", isOn: .init(
                    get: { isOn },
                    set: { onInstantModeToggle($0) }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .hustlePrimary))
            }
            .padding(4)
            .padding(.trailing, 12)
        }
    }

    private func progressionSection(data: ProgressionData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CAREER PROGRESSION")
                    .hustleSectionHeader()

                Spacer()

                Button(action: onViewRoadmap) {
                    Text("View Roadmap")
                        .font(HustleFont.micro(.bold))
                        .foregroundColor(.hustlePrimary)
                }
            }
            .padding(.leading, 4)

            // Current Goal Card
            GlassCard(cornerRadius: 16, borderColor: .hustlePrimary) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CURRENT GOAL")
                                .font(HustleFont.micro(.bold))
                                .tracking(1)
                                .foregroundColor(.hustlePrimary)

                            Text(data.currentGoalTitle)
                                .font(HustleFont.headline(.bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.zinc600)
                    }

                    VStack(spacing: 16) {
                        // Tasks Progress
                        progressBar(
                            label: "Tasks Completed",
                            current: data.tasksCompleted,
                            total: data.tasksRequired
                        )

                        // Days Progress
                        progressBar(
                            label: "Days Active",
                            current: data.daysActive,
                            total: data.daysRequired
                        )
                    }
                }
                .padding(20)
            }
            .overlay(
                Rectangle()
                    .fill(Color.hustlePrimary)
                    .frame(width: 4)
                ,
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Next Tier (Locked)
            GlassCard(cornerRadius: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NEXT TIER")
                            .font(HustleFont.micro(.bold))
                            .tracking(1)
                            .foregroundColor(.zinc400)

                        Text(data.nextTierTitle)
                            .font(HustleFont.body(.bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Image(systemName: "lock.fill")
                        .foregroundColor(.zinc500)
                }
                .padding(16)
            }
            .opacity(0.5)
            .grayscale(0.8)
        }
    }

    private func progressBar(label: String, current: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(HustleFont.micro())
                    .foregroundColor(.zinc300)

                Spacer()

                Text("\(current)/\(total)")
                    .font(HustleFont.micro(.medium))
                    .foregroundColor(.white)
            }

            GeometryReader { geo in
                Capsule()
                    .fill(Color.zinc800)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.hustlePrimary, Color(hex: "#34D399")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(current) / CGFloat(total))
                        ,
                        alignment: .leading
                    )
            }
            .frame(height: 8)
            .clipShape(Capsule())
        }
    }

    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                if tab == .add {
                    // Floating action button
                    Button(action: { onTabSelect(tab) }) {
                        ZStack {
                            Circle()
                                .fill(Color.hustlePrimary)
                                .frame(width: 56, height: 56)
                                .shadow(color: .hustlePrimary.opacity(0.4), radius: 10)

                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .offset(y: -24)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Button(action: {
                        selectedTab = tab
                        onTabSelect(tab)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tabIcon(for: tab))
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == tab ? .hustlePrimary : .zinc500.opacity(0.56))

                            Text(tab.rawValue)
                                .font(HustleFont.micro(.medium))
                                .foregroundColor(selectedTab == tab ? .white : .zinc500)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#1C1C1E").opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 20)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Helpers

    private func tabIcon(for tab: HomeTab) -> String {
        switch tab {
        case .home: return "house.fill"
        case .tasks: return "list.clipboard"
        case .add: return "plus"
        case .wallet: return "creditcard"
        case .profile: return "person.fill"
        }
    }

    private func formatCurrency(_ amount: Decimal, showCents: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = showCents ? 2 : 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }

    private func formatCents(_ amount: Decimal) -> String {
        let cents = (amount as NSDecimalNumber).doubleValue.truncatingRemainder(dividingBy: 1) * 100
        return String(format: ".%02d", Int(cents))
    }
}

// MARK: - Preview

#Preview("Hustler Home - Loaded") {
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
            ),
            hasUnreadNotifications: true
        ),
        onNotificationsTap: {},
        onInstantModeToggle: { _ in },
        onViewRoadmap: {},
        onTabSelect: { _ in }
    )
}

#Preview("Hustler Home - Loading") {
    HustlerHomeScreen(
        data: nil,
        isLoading: true,
        onNotificationsTap: {},
        onInstantModeToggle: { _ in },
        onViewRoadmap: {},
        onTabSelect: { _ in }
    )
}
