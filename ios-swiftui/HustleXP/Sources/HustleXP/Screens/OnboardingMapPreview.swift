// OnboardingMapPreview.swift
// HustleXP iOS - Map Feature Preview for Onboarding
// Animated route from Hustler to Task location

import SwiftUI

struct OnboardingMapPreview: View {
    @State private var routeProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Map background (simplified mockup)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1C1C1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            // Grid lines (map feel)
            Canvas { context, size in
                let gridSpacing: CGFloat = 40
                let gridColor = Color.white.opacity(0.03)

                // Horizontal lines
                for y in stride(from: CGFloat(0), to: size.height, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                }

                // Vertical lines
                for x in stride(from: CGFloat(0), to: size.width, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Route line
            GeometryReader { geo in
                let startPoint = CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.7)
                let endPoint = CGPoint(x: geo.size.width * 0.8, y: geo.size.height * 0.25)
                let controlPoint = CGPoint(x: geo.size.width * 0.6, y: geo.size.height * 0.5)

                Path { path in
                    path.move(to: startPoint)
                    path.addQuadCurve(to: endPoint, control: controlPoint)
                }
                .trim(from: 0, to: routeProgress)
                .stroke(
                    Color.hustlePrimary,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 6])
                )
                .shadow(color: Color.hustlePrimary.opacity(0.5), radius: 8)

                // Hustler pin (start)
                Circle()
                    .fill(Color.hustlePrimary)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "figure.walk")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.hustlePrimary.opacity(0.5), radius: 8)
                    .position(startPoint)

                // Task pin (end)
                Circle()
                    .fill(Color.appleOrange)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "mappin")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.appleOrange.opacity(0.5), radius: 8)
                    .position(endPoint)
                    .opacity(routeProgress > 0.9 ? 1 : 0.5)
            }
            .padding(20)

            // Distance badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text("0.8 mi away")
                            .font(HustleFont.callout(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.hustlePrimary)
                    .cornerRadius(20)
                    .shadow(color: Color.hustlePrimary.opacity(0.4), radius: 10)
                    .padding(16)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                routeProgress = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview("Map Preview") {
    OnboardingMapPreview()
        .frame(height: 320)
        .padding()
        .background(Color.black)
}
