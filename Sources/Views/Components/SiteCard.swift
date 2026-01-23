import SwiftUI

/// Card displaying a site with Egyptian styling
struct SiteCard: View {
    let site: Site

    var body: some View {
        HStack(spacing: 14) {
            // Enhanced image placeholder with Egyptian styling
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.goldGradient)
                    .frame(width: 80, height: 80)

                // Decorative border pattern
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.Colors.gold.opacity(0.5), Theme.Colors.gold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: site.placeType.icon)
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text(site.city.rawValue)
                        .font(.caption)
                }
                .foregroundColor(Theme.Colors.gold)

                HStack(spacing: 12) {
                    Label(site.era.rawValue, systemImage: "calendar")
                    if let subLocations = site.subLocations {
                        Label("\(subLocations.count) places", systemImage: "rectangle.stack")
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.Colors.gold.opacity(0.6))
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        GradientBackground()
        SiteCard(site: PreviewData.sites[0])
            .padding()
    }
}
