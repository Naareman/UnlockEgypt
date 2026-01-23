import SwiftUI

/// Card displaying a site with Egyptian styling
struct SiteCard: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel

    private var isFullyUnlocked: Bool {
        guard let subLocations = site.subLocations, !subLocations.isEmpty else { return false }
        let hasAllKnowledge = subLocations.allSatisfy { viewModel.hasScholarBadge(for: $0.id) }
        let hasDiscovery = viewModel.hasExplorerBadge(for: site.id)
        return hasAllKnowledge && hasDiscovery
    }

    private var hasAnyProgress: Bool {
        guard let subLocations = site.subLocations else { return false }
        let hasKnowledge = subLocations.contains { viewModel.hasScholarBadge(for: $0.id) }
        let hasDiscovery = viewModel.hasExplorerBadge(for: site.id)
        return hasKnowledge || hasDiscovery
    }

    var body: some View {
        HStack(spacing: 14) {
            // Site icon with Egyptian styling
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(Theme.goldGradient)
                    .frame(width: 76, height: 76)

                // Decorative border
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.Colors.gold.opacity(0.6), Theme.Colors.gold.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 76, height: 76)

                Image(systemName: site.placeType.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Theme.Colors.gold)

                // Completion indicator
                if isFullyUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.green)
                                .background(Circle().fill(Theme.Colors.darkBackground).padding(-2))
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 6) {
                // Site name
                Text(site.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                    Text(site.city.rawValue)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Theme.Colors.gold)

                // Meta info
                HStack(spacing: 12) {
                    Label(site.era.rawValue, systemImage: "calendar")
                    if let subLocations = site.subLocations {
                        Label("\(subLocations.count) secrets", systemImage: "key.fill")
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Status indicator
            VStack(spacing: 4) {
                if isFullyUnlocked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.gold)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.Colors.gold.opacity(0.5))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(hasAnyProgress ? Theme.Colors.cardBackgroundElevated : Theme.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(
                    isFullyUnlocked ? Color.green.opacity(0.3) :
                    (hasAnyProgress ? Theme.Colors.gold.opacity(0.25) : Theme.Colors.gold.opacity(0.15)),
                    lineWidth: 1
                )
        )
        .pressEffect()
    }
}

/// Compact site card for lists
struct SiteCardCompact: View {
    let site: Site

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .fill(Theme.goldGradient)
                    .frame(width: 48, height: 48)

                Image(systemName: site.placeType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(site.city.rawValue)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.gold.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(Theme.Colors.cardBackgroundSubtle)
        .cornerRadius(Theme.Radius.md)
        .pressEffect()
    }
}

#Preview {
    ZStack {
        GradientBackground()
        VStack(spacing: 16) {
            SiteCard(site: PreviewData.sites[0])
                .environmentObject(HomeViewModel())
            SiteCardCompact(site: PreviewData.sites[0])
        }
        .padding()
    }
}
