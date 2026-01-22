import SwiftUI

/// Displays the user's points with a trophy icon
struct PointsBadge: View {
    let points: Int

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.gold)
            }
            Text("\(points) pts")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.gold)
        }
    }
}

#Preview {
    ZStack {
        GradientBackground()
        PointsBadge(points: 150)
    }
}
