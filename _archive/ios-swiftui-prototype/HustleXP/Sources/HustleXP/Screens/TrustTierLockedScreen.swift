// TrustTierLockedScreen.swift
// HustleXP iOS - Edge State: Trust Tier Locked
// Source: E3-trust-tier-locked.html

import SwiftUI

// MARK: - Data Model

public struct TrustTierLockedData {
    public let lockedTier: Int
    public let lockedTierName: String
    public let currentTier: Int
    public let currentTierName: String
    public let xpCurrent: Int
    public let xpRequired: Int
    public let benefits: [String]
    public let lockReason: String?

    public init(
        lockedTier: Int,
        lockedTierName: String,
        currentTier: Int,
        currentTierName: String,
        xpCurrent: Int,
        xpRequired: Int,
        benefits: [String],
        lockReason: String? = nil
    ) {
        self.lockedTier = lockedTier
        self.lockedTierName = lockedTierName
        self.currentTier = currentTier
        self.currentTierName = currentTierName
        self.xpCurrent = xpCurrent
        self.xpRequired = xpRequired
        self.benefits = benefits
        self.lockReason = lockReason
    }
}

// MARK: - View

public struct TrustTierLockedScreen: View {
    let data: TrustTierLockedData?
    let isLoading: Bool
    let onViewProgress: () -> Void
    let onDismiss: () -> Void

    public init(
        data: TrustTierLockedData?,
        isLoading: Bool = false,
        onViewProgress: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.data = data
        self.isLoading = isLoading
        self.onViewProgress = onViewProgress
        self.onDismiss = onDismiss
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
                .tint(.zinc500)
            Text("Loading tier info...")
                .font(HustleFont.callout())
                .foregroundColor(.hustleTextMuted)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.open")
                .font(.system(size: 48))
                .foregroundColor(.appleGreen)
            Text("Tier unlocked!")
                .font(HustleFont.headline())
                .foregroundColor(.hustleTextPrimary)
        }
    }

    private func contentState(data: TrustTierLockedData) -> some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Lock icon and title
                    headerSection(data: data)

                    // Progress card
                    progressCard(data: data)

                    // Benefits preview
                    benefitsPreview(data: data)

                    // Lock reason (if any)
                    if let reason = data.lockReason {
                        lockReasonCard(reason: reason)
                    }

                    // Action
                    PrimaryButton("View My Progress", icon: "chart.line.uptrend.xyaxis", color: .hustlePrimary, action: onViewProgress)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }
        }
    }

    // MARK: - Components

    private func headerSection(data: TrustTierLockedData) -> some View {
        VStack(spacing: 20) {
            // Lock icon with tier number
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.zinc700.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                // Lock container
                ZStack {
                    Circle()
                        .fill(Color.zinc800)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color.zinc700, lineWidth: 2)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.zinc500)

                        Text("T\(data.lockedTier)")
                            .font(HustleFont.micro(.bold))
                            .foregroundColor(.zinc500)
                    }
                }
            }

            VStack(spacing: 8) {
                Text("\(data.lockedTierName) Tier Locked")
                    .font(HustleFont.title1(.bold))
                    .foregroundColor(.white)

                Text("Continue earning XP to unlock this tier")
                    .font(HustleFont.callout())
                    .foregroundColor(.hustleTextMuted)
            }
        }
        .padding(.top, 16)
    }

    private func progressCard(data: TrustTierLockedData) -> some View {
        GlassCard(cornerRadius: 16) {
            VStack(spacing: 20) {
                // Current tier badge
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 14))
                        Text("Currently: \(data.currentTierName)")
                            .font(HustleFont.callout(.semibold))
                    }
                    .foregroundColor(.appleBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.appleBlue.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.appleBlue.opacity(0.3), lineWidth: 1)
                            )
                    )

                    Spacer()
                }

                // XP Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("XP Progress")
                            .font(HustleFont.callout())
                            .foregroundColor(.zinc400)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\(data.xpCurrent)")
                                .foregroundColor(.white)
                            Text("/ \(data.xpRequired)")
                                .foregroundColor(.zinc500)
                        }
                        .font(HustleFont.headline(.bold))
                    }

                    // Progress bar
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
                                    .frame(width: geo.size.width * CGFloat(data.xpCurrent) / CGFloat(data.xpRequired))
                                ,
                                alignment: .leading
                            )
                    }
                    .frame(height: 8)
                    .clipShape(Capsule())

                    // XP needed
                    let xpNeeded = data.xpRequired - data.xpCurrent
                    Text("\(xpNeeded) XP needed to unlock")
                        .font(HustleFont.micro())
                        .foregroundColor(.zinc500)
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 24)
    }

    private func benefitsPreview(data: TrustTierLockedData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UNLOCKS AT \(data.lockedTierName.uppercased())")
                .hustleSectionHeader()
                .padding(.horizontal, 28)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.benefits, id: \.self) { benefit in
                        benefitCard(text: benefit)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func benefitCard(text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: benefitIcon(for: text))
                .font(.system(size: 24))
                .foregroundColor(.zinc400)

            Text(text)
                .font(HustleFont.callout(.medium))
                .foregroundColor(.zinc300)
                .multilineTextAlignment(.center)
        }
        .frame(width: 140)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.glassSurfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
        .grayscale(0.5)
        .opacity(0.7)
    }

    private func lockReasonCard(reason: String) -> some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appleOrange)

                Text(reason)
                    .font(HustleFont.callout())
                    .foregroundColor(.zinc300)
            }
            .padding(16)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private func benefitIcon(for benefit: String) -> String {
        let lower = benefit.lowercased()
        if lower.contains("pay") || lower.contains("bonus") { return "dollarsign.circle.fill" }
        if lower.contains("priority") || lower.contains("dispatch") { return "bolt.fill" }
        if lower.contains("home") || lower.contains("interior") { return "house.fill" }
        if lower.contains("fee") { return "percent" }
        return "star.fill"
    }
}

// MARK: - Preview

#Preview("Trust Tier Locked") {
    TrustTierLockedScreen(
        data: TrustTierLockedData(
            lockedTier: 3,
            lockedTierName: "Trusted",
            currentTier: 2,
            currentTierName: "Verified",
            xpCurrent: 2450,
            xpRequired: 5000,
            benefits: ["Weekly Bonus", "Priority Dispatch", "Lower Fees", "Premium Tasks"],
            lockReason: "Complete 15 more tasks to reach the Trusted tier"
        ),
        onViewProgress: {},
        onDismiss: {}
    )
}
