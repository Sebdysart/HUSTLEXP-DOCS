// TrustTierLadderScreen.swift
// HustleXP iOS - Trust Tier Ladder
// Source: 06-trust-tier-ladder.html

import SwiftUI

// MARK: - Data Models

public struct TrustTierLadderData {
    public let currentTier: Int
    public let tiers: [TierInfo]
    public let totalXP: Int
    public let totalTasks: Int
    public let rating: Double

    public init(
        currentTier: Int,
        tiers: [TierInfo],
        totalXP: Int,
        totalTasks: Int,
        rating: Double
    ) {
        self.currentTier = currentTier
        self.tiers = tiers
        self.totalXP = totalXP
        self.totalTasks = totalTasks
        self.rating = rating
    }
}

public struct TierInfo {
    public let tier: Int
    public let name: String
    public let tagline: String
    public let benefits: [String]
    public let requirements: [String]
    public let xpCurrent: Int?
    public let xpRequired: Int?
    public let isLocked: Bool
    public let isPast: Bool

    public init(
        tier: Int,
        name: String,
        tagline: String,
        benefits: [String],
        requirements: [String] = [],
        xpCurrent: Int? = nil,
        xpRequired: Int? = nil,
        isLocked: Bool = false,
        isPast: Bool = false
    ) {
        self.tier = tier
        self.name = name
        self.tagline = tagline
        self.benefits = benefits
        self.requirements = requirements
        self.xpCurrent = xpCurrent
        self.xpRequired = xpRequired
        self.isLocked = isLocked
        self.isPast = isPast
    }
}

// MARK: - View

public struct TrustTierLadderScreen: View {
    let data: TrustTierLadderData?
    let isLoading: Bool
    let onBack: () -> Void

    public init(
        data: TrustTierLadderData?,
        isLoading: Bool = false,
        onBack: @escaping () -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color.hustleBackgroundDark
                .ignoresSafeArea()

            // Background glow
            Circle()
                .fill(Color.hustlePrimary.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 120)
                .offset(y: -100)

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
            Text("Loading trust tiers...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundColor(.hustleTextMuted)
            Text("Unable to load trust tiers")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: TrustTierLadderData) -> some View {
        VStack(spacing: 0) {
            // Header
            header

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(data.tiers.reversed(), id: \.tier) { tier in
                        tierCard(tier: tier, currentTier: data.currentTier)
                    }

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }

            // Bottom summary
            bottomSummary(data: data)
        }
    }

    // MARK: - Components

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(8)
                }

                Spacer()

                Text("Trust Tiers")
                    .font(HustleFont.title2(.bold))
                    .foregroundColor(.white)

                Spacer()

                // Placeholder for symmetry
                Color.clear
                    .frame(width: 40, height: 40)
            }

            Text("Earned, not requested")
                .font(HustleFont.callout(.medium))
                .foregroundColor(.appleGray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 16)
        .background(
            Color.black.opacity(0.7)
                .background(.ultraThinMaterial)
        )
    }

    private func tierCard(tier: TierInfo, currentTier: Int) -> some View {
        let isCurrent = tier.tier == currentTier
        let isNextGoal = tier.tier == currentTier + 1

        return GlassCard(
            cornerRadius: 16,
            borderColor: tierBorderColor(tier: tier, isCurrent: isCurrent, isNextGoal: isNextGoal),
            borderWidth: (isCurrent || isNextGoal) ? 1.5 : 1
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Status banner (for current tier)
                if isCurrent {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.hustlePrimary)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        Text("YOU ARE HERE")
                            .font(HustleFont.micro(.bold))
                            .tracking(1)
                            .foregroundColor(.hustlePrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appleBlue.opacity(0.1))
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if isNextGoal {
                                HustleBadge("Next Goal", color: .appleOrange)
                            }

                            Text(tier.name)
                                .font(isNextGoal ? HustleFont.title1(.bold) : HustleFont.title2(.bold))
                                .foregroundColor(.white)

                            Text("Tier \(tier.tier)")
                                .font(HustleFont.micro(.medium))
                                .tracking(2)
                                .textCase(.uppercase)
                                .foregroundColor(tierAccentColor(tier: tier, isCurrent: isCurrent, isNextGoal: isNextGoal).opacity(0.8))
                        }

                        Spacer()

                        Image(systemName: tierIcon(tier: tier))
                            .font(.system(size: 24))
                            .foregroundColor(tier.isLocked ? .white : tierAccentColor(tier: tier, isCurrent: isCurrent, isNextGoal: isNextGoal))
                    }

                    // Progress (for next goal)
                    if isNextGoal, let current = tier.xpCurrent, let required = tier.xpRequired {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("XP Progress")
                                    .font(HustleFont.callout(.medium))
                                    .foregroundColor(.white.opacity(0.8))

                                Spacer()

                                HStack(spacing: 4) {
                                    Text("\(current)")
                                        .foregroundColor(.appleOrange)
                                    Text("/ \(required)")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .font(HustleFont.headline(.bold))
                            }

                            GeometryReader { geo in
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .fill(Color.appleOrange)
                                            .frame(width: geo.size.width * CGFloat(current) / CGFloat(required))
                                            .shadow(color: .appleOrange.opacity(0.5), radius: 5)
                                        ,
                                        alignment: .leading
                                    )
                            }
                            .frame(height: 8)
                            .clipShape(Capsule())

                            // Requirements info
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 12))
                                Text("Requirements are evaluated automatically.")
                            }
                            .font(HustleFont.micro())
                            .foregroundColor(.appleGray.opacity(0.7))
                            .padding(.top, 4)

                            ForEach(tier.requirements, id: \.self) { req in
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 12))
                                    Text("Need: \(req)")
                                }
                                .font(HustleFont.micro())
                                .foregroundColor(.appleGray)
                            }
                        }
                    }

                    // Benefits
                    if !tier.benefits.isEmpty && !tier.isPast {
                        if !isNextGoal {
                            HustleDivider()
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            if isCurrent {
                                ForEach(tier.benefits, id: \.self) { benefit in
                                    benefitRow(icon: benefitIcon(for: benefit), text: benefit)
                                }
                            } else if tier.isLocked {
                                ForEach(tier.benefits, id: \.self) { benefit in
                                    HStack(spacing: 12) {
                                        Image(systemName: benefitIcon(for: benefit))
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                        Text(benefit)
                                            .font(HustleFont.callout())
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                        .padding(.top, isCurrent ? 8 : 0)
                    }

                    // Benefits grid (for next goal)
                    if isNextGoal && !tier.benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BENEFITS UNLOCKED")
                                .font(HustleFont.micro(.semibold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.5))

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(tier.benefits, id: \.self) { benefit in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Image(systemName: benefitIcon(for: benefit))
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                        Text(benefit)
                                            .font(HustleFont.callout(.medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .padding(.horizontal, -20)
                        .padding(.bottom, -20)
                        .padding(.top, 8)
                    }

                    // Past tier description
                    if tier.isPast {
                        HustleDivider()
                        Text("Basic access level. Completed.")
                            .font(HustleFont.callout())
                            .italic()
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(20)
            }
        }
        .opacity(tier.isPast ? 0.4 : (tier.isLocked ? 0.4 : 1.0))
        .grayscale(tier.isPast ? 1.0 : (tier.isLocked ? 0.8 : 0))
        .shadow(
            color: (isCurrent || isNextGoal) ? tierAccentColor(tier: tier, isCurrent: isCurrent, isNextGoal: isNextGoal).opacity(0.3) : .clear,
            radius: 10
        )
        .scaleEffect(isNextGoal ? 1.02 : 1.0)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(HustleFont.callout(.medium))
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func bottomSummary(data: TrustTierLadderData) -> some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 0) {
                statColumn(label: "Total XP", value: formatNumber(data.totalXP))
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)

                statColumn(label: "Tasks", value: "\(data.totalTasks)")
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)

                HStack(spacing: 4) {
                    Text("\(data.rating, specifier: "%.1f")")
                        .font(HustleFont.headline(.bold))
                        .foregroundColor(.white)
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appleOrange)
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    Text("Rating")
                        .font(HustleFont.micro(.medium))
                        .tracking(1)
                        .textCase(.uppercase)
                        .foregroundColor(.appleGray)
                        .offset(y: -20)
                )
            }
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [.clear, .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(HustleFont.micro(.medium))
                .tracking(1)
                .foregroundColor(.appleGray)

            Text(value)
                .font(HustleFont.headline(.bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Helpers

    private func tierBorderColor(tier: TierInfo, isCurrent: Bool, isNextGoal: Bool) -> Color {
        if isCurrent { return .appleBlue }
        if isNextGoal { return .appleOrange }
        return .glassBorder
    }

    private func tierAccentColor(tier: TierInfo, isCurrent: Bool, isNextGoal: Bool) -> Color {
        if isCurrent { return .appleBlue }
        if isNextGoal { return .appleOrange }
        return .white
    }

    private func tierIcon(tier: TierInfo) -> String {
        if tier.isLocked { return "lock" }
        if tier.isPast { return "lock.open" }
        switch tier.tier {
        case 4: return "star.fill"
        case 3: return "trophy.fill"
        case 2: return "checkmark.seal.fill"
        default: return "person.fill"
        }
    }

    private func benefitIcon(for benefit: String) -> String {
        let lower = benefit.lowercased()
        if lower.contains("payout") || lower.contains("bonus") { return "bolt.fill" }
        if lower.contains("fee") { return "percent" }
        if lower.contains("dispatch") || lower.contains("delivery") { return "shippingbox.fill" }
        if lower.contains("interior") || lower.contains("home") { return "diamond.fill" }
        if lower.contains("background") { return "checkmark.shield.fill" }
        return "star.fill"
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Preview

#Preview("Trust Tier Ladder") {
    TrustTierLadderScreen(
        data: TrustTierLadderData(
            currentTier: 2,
            tiers: [
                TierInfo(tier: 1, name: "Unverified", tagline: "Starting out", benefits: [], isPast: true),
                TierInfo(
                    tier: 2,
                    name: "Verified",
                    tagline: "Trusted member",
                    benefits: ["Instant Payouts", "Standard Fees"]
                ),
                TierInfo(
                    tier: 3,
                    name: "Trusted",
                    tagline: "Proven performer",
                    benefits: ["Weekly Bonus", "Priority Dispatch"],
                    requirements: ["Maintain 4.8 star rating"],
                    xpCurrent: 2847,
                    xpRequired: 3200
                ),
                TierInfo(
                    tier: 4,
                    name: "In-Home",
                    tagline: "Ultimate Status",
                    benefits: ["Access to high-value interior tasks", "Background check required"],
                    isLocked: true
                )
            ],
            totalXP: 12450,
            totalTasks: 48,
            rating: 4.9
        ),
        onBack: {}
    )
}
