// XPBreakdownScreen.swift
// HustleXP - XP Breakdown & Rewards
// Source: 07-xp-breakdown.html

import SwiftUI

// MARK: - Data Models

public struct XPBreakdownData {
    public let totalXP: Int
    public let dailyGoal: Int
    public let dailyProgress: Double
    public let bonuses: [XPBonus]
    public let streakDays: Int
    public let streakBonus: Int
    public let baseXPItems: [BaseXPItem]
    public let calculationBase: Int
    public let multipliers: [Double]
    public let potentialXP: Int
    public let date: String

    public init(
        totalXP: Int,
        dailyGoal: Int,
        dailyProgress: Double,
        bonuses: [XPBonus],
        streakDays: Int,
        streakBonus: Int,
        baseXPItems: [BaseXPItem],
        calculationBase: Int,
        multipliers: [Double],
        potentialXP: Int,
        date: String
    ) {
        self.totalXP = totalXP
        self.dailyGoal = dailyGoal
        self.dailyProgress = dailyProgress
        self.bonuses = bonuses
        self.streakDays = streakDays
        self.streakBonus = streakBonus
        self.baseXPItems = baseXPItems
        self.calculationBase = calculationBase
        self.multipliers = multipliers
        self.potentialXP = potentialXP
        self.date = date
    }
}

public struct XPBonus: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let multiplier: Double
    public let xpGained: Int
    public let icon: String
    public let color: Color

    public init(title: String, subtitle: String, multiplier: Double, xpGained: Int, icon: String, color: Color) {
        self.title = title
        self.subtitle = subtitle
        self.multiplier = multiplier
        self.xpGained = xpGained
        self.icon = icon
        self.color = color
    }
}

public struct BaseXPItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let completedAt: String
    public let xp: Int

    public init(title: String, completedAt: String, xp: Int) {
        self.title = title
        self.completedAt = completedAt
        self.xp = xp
    }
}

// MARK: - XP Breakdown Screen

public struct XPBreakdownScreen: View {
    public let data: XPBreakdownData

    public init(data: XPBreakdownData) {
        self.data = data
    }

    public var body: some View {
        ZStack {
            // Background
            Color.hustleBackgroundDark.ignoresSafeArea()

            // Ambient glow
            GeometryReader { geo in
                Circle()
                    .fill(Color.appleOrange.opacity(0.1))
                    .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                    .blur(radius: 120)
                    .offset(x: -geo.size.width * 0.1, y: -geo.size.height * 0.1)

                Circle()
                    .fill(Color.appleBlue.opacity(0.1))
                    .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                    .blur(radius: 120)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.7)
            }

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Hero Summary
                    heroSummaryCard

                    // Real-Time Bonuses
                    realTimeBonusesSection

                    // Consistency Streak
                    consistencySection

                    // Base XP Breakdown
                    baseXPSection

                    // XP Resolution Formula
                    xpResolutionSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("XP Breakdown")
                    .font(HustleFont.title1())
                    .foregroundColor(.white)
            }

            Spacer()

            Text(data.date)
                .font(HustleFont.caption(.medium))
                .foregroundColor(.hustleTextMuted)
        }
        .padding(.top, 48)
    }

    // MARK: - Hero Summary

    private var heroSummaryCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(spacing: 0) {
                Text("Total Earned")
                    .font(HustleFont.micro(.medium))
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundColor(.hustleTextMuted)
                    .padding(.bottom, 8)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(data.totalXP)")
                        .font(.system(size: 56, weight: .bold, design: .default))
                        .foregroundColor(.appleOrange)

                    Text("XP")
                        .font(HustleFont.title3(.medium))
                        .foregroundColor(.appleOrange.opacity(0.8))
                }

                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appleOrange)
                                .frame(width: geo.size.width * data.dailyProgress, height: 4)
                                .shadow(color: .appleOrange.opacity(0.5), radius: 10)
                        }
                    }
                    .frame(height: 4)

                    HStack {
                        Text("Daily Goal: \(data.dailyGoal) XP")
                            .font(HustleFont.micro())
                            .foregroundColor(.hustleTextMuted)

                        Spacer()

                        Text("\(Int(data.dailyProgress * 100))%")
                            .font(HustleFont.micro())
                            .foregroundColor(.hustleTextMuted)
                    }
                }
                .padding(.top, 24)
            }
            .padding(32)
        }
    }

    // MARK: - Real-Time Bonuses

    private var realTimeBonusesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.appleOrange)

                Text("REAL-TIME BONUSES")
                    .font(HustleFont.headline(.bold))
                    .foregroundColor(.white)
            }

            ForEach(data.bonuses) { bonus in
                bonusRow(bonus)
            }
        }
    }

    private func bonusRow(_ bonus: XPBonus) -> some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(bonus.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: bonus.icon)
                            .foregroundColor(bonus.color)
                    )
                    .overlay(
                        Circle()
                            .stroke(bonus.color.opacity(0.2), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(bonus.title)
                            .font(HustleFont.body(.bold))
                            .foregroundColor(.white)

                        Text("\(String(format: "%.1f", bonus.multiplier))x")
                            .font(HustleFont.micro(.bold))
                            .foregroundColor(bonus.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(bonus.color.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(bonus.color.opacity(0.2), lineWidth: 1)
                            )
                    }

                    Text(bonus.subtitle)
                        .font(HustleFont.caption())
                        .foregroundColor(.hustleTextMuted)
                }

                Spacer()

                Text("+\(bonus.xpGained) XP")
                    .font(HustleFont.headline(.bold))
                    .foregroundColor(.appleGreen)
            }
            .padding(16)
        }
    }

    // MARK: - Consistency Section

    private var consistencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.appleRed)

                Text("CONSISTENCY")
                    .font(HustleFont.headline(.bold))
                    .foregroundColor(.white)
            }

            GlassCard(cornerRadius: 16) {
                ZStack(alignment: .bottom) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.appleRed.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("\(data.streakDays)D")
                                    .font(HustleFont.caption(.bold))
                                    .foregroundColor(.appleRed)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.appleRed.opacity(0.2), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("\(data.streakDays)-Day Streak")
                                    .font(HustleFont.body(.bold))
                                    .foregroundColor(.white)

                                Text("1.1x")
                                    .font(HustleFont.micro(.bold))
                                    .foregroundColor(.appleRed)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.appleRed.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }

                            Text("Keep it up tomorrow!")
                                .font(HustleFont.caption())
                                .foregroundColor(.hustleTextMuted)
                        }

                        Spacer()

                        Text("+\(data.streakBonus) XP")
                            .font(HustleFont.headline(.bold))
                            .foregroundColor(.appleGreen)
                    }
                    .padding(16)

                    // Red accent line at bottom
                    Rectangle()
                        .fill(Color.appleRed.opacity(0.5))
                        .frame(height: 1)
                }
            }
        }
    }

    // MARK: - Base XP Section

    private var baseXPSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base XP Breakdown")
                .font(HustleFont.headline(.bold))
                .foregroundColor(.white)
                .padding(.leading, 4)

            GlassCard(cornerRadius: 16) {
                VStack(spacing: 0) {
                    ForEach(Array(data.baseXPItems.enumerated()), id: \.element.id) { index, item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(HustleFont.body(.medium))
                                    .foregroundColor(.white)

                                Text("Completed at \(item.completedAt)")
                                    .font(HustleFont.caption())
                                    .foregroundColor(.hustleTextMuted)
                            }

                            Spacer()

                            Text("\(item.xp) XP")
                                .font(HustleFont.body(.medium))
                                .monospaced()
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(16)

                        if index < data.baseXPItems.count - 1 {
                            HustleDivider(opacity: 0.05)
                        }
                    }
                }
            }
        }
    }

    // MARK: - XP Resolution Section

    private var xpResolutionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "function")
                    .font(.system(size: 12))
                    .foregroundColor(.hustleTextMuted)

                Text("XP RESOLUTION")
                    .font(HustleFont.micro(.bold))
                    .tracking(2)
                    .foregroundColor(.hustleTextMuted)
            }

            // Formula display
            HStack(spacing: 8) {
                Text("\(data.calculationBase)")
                    .foregroundColor(.white.opacity(0.6))

                Text("base")
                    .font(HustleFont.caption())
                    .foregroundColor(.appleOrange)

                ForEach(data.multipliers, id: \.self) { mult in
                    Text("×")
                        .foregroundColor(.white.opacity(0.4))

                    Text(String(format: "%.1f", mult))
                        .foregroundColor(.white)
                }

                Text("=")
                    .foregroundColor(.white.opacity(0.4))

                Text("\(data.potentialXP) XP")
                    .fontWeight(.bold)
                    .foregroundColor(.appleOrange)
            }
            .font(HustleFont.headline())
            .monospaced()

            HustleDivider(opacity: 0.1)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 8) {
                Text("**Note:** The above calculation demonstrates potential max earnings. Your current realized gain (\(data.totalXP) XP) is based on completed quality gates.")
                    .font(HustleFont.micro())
                    .foregroundColor(.hustleTextMuted)

                Text("Multipliers are capped at 2.0x max per individual session event.")
                    .font(HustleFont.micro())
                    .foregroundColor(.hustleTextMuted)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 32)
    }
}

// MARK: - Preview

#Preview {
    XPBreakdownScreen(
        data: XPBreakdownData(
            totalXP: 342,
            dailyGoal: 500,
            dailyProgress: 0.68,
            bonuses: [
                XPBonus(title: "Instant Mode", subtitle: "Acceptance within 30s", multiplier: 1.5, xpGained: 68, icon: "bolt.fill", color: .appleOrange),
                XPBonus(title: "Speed Bonus", subtitle: "Completed < 2 hrs", multiplier: 1.2, xpGained: 24, icon: "timer", color: .appleGreen),
                XPBonus(title: "Surge Bonus", subtitle: "High demand window", multiplier: 2.0, xpGained: 120, icon: "chart.line.uptrend.xyaxis", color: .appleOrange)
            ],
            streakDays: 7,
            streakBonus: 30,
            baseXPItems: [
                BaseXPItem(title: "Logo Design Task", completedAt: "10:42 AM", xp: 150),
                BaseXPItem(title: "Feedback Response", completedAt: "11:15 AM", xp: 150)
            ],
            calculationBase: 300,
            multipliers: [1.5, 1.2, 1.1],
            potentialXP: 594,
            date: "Today, Oct 24"
        )
    )
}
