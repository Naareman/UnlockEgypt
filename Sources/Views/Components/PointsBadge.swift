import SwiftUI

/// Displays the user's points with animated counter
struct PointsBadge: View {
    let points: Int
    @State private var displayedPoints: Int = 0
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 6) {
            // Star icon with glow
            ZStack {
                // Glow effect
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.gold)
                    .blur(radius: 4)
                    .opacity(0.6)

                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.gold)
            }

            // Points count
            Text("\(displayedPoints)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Theme.Colors.cardBackground)
                .overlay(
                    Capsule()
                        .strokeBorder(Theme.Colors.gold.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            displayedPoints = points
        }
        .onChange(of: points) { oldValue, newValue in
            // Animate point changes
            withAnimation(Theme.Animation.smooth) {
                displayedPoints = newValue
            }

            // Pulse animation on increase
            if newValue > oldValue {
                withAnimation(Theme.Animation.bouncy) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
        }
        .scaleEffect(isAnimating ? 1.15 : 1.0)
    }
}

/// Larger points badge for profile/achievements
struct PointsBadgeLarge: View {
    let points: Int

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.15))
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(Theme.Colors.gold.opacity(0.25))
                    .frame(width: 48, height: 48)

                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.Colors.gold)
            }

            Text("\(points)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Ankh Points")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

#Preview {
    ZStack {
        GradientBackground()
        VStack(spacing: 32) {
            PointsBadge(points: 150)
            PointsBadge(points: 1250)
            PointsBadgeLarge(points: 450)
        }
    }
}
