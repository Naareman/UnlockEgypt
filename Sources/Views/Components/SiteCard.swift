import SwiftUI

/// Card displaying a site with Egyptian styling
struct SiteCard: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel

    /// Has completed all Knowledge Keys (stories) for this site
    private var hasAllKnowledgeKeys: Bool {
        guard let subLocations = site.subLocations, !subLocations.isEmpty else { return false }
        return subLocations.allSatisfy { viewModel.hasScholarBadge(for: $0.id) }
    }

    /// Has any Knowledge Keys for this site
    private var hasAnyKnowledgeKeys: Bool {
        guard let subLocations = site.subLocations else { return false }
        return subLocations.contains { viewModel.hasScholarBadge(for: $0.id) }
    }

    /// Has Discovery Key (visited the site)
    private var hasDiscoveryKey: Bool {
        viewModel.hasExplorerBadge(for: site.id)
    }

    /// Site is fully completed (all Knowledge Keys + Discovery Key)
    private var isFullyUnlocked: Bool {
        hasAllKnowledgeKeys && hasDiscoveryKey
    }

    private var hasAnyProgress: Bool {
        hasAnyKnowledgeKeys || hasDiscoveryKey
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

                // Era info
                Label(site.era.rawValue, systemImage: "calendar")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Status icons: Crown when fully complete, otherwise two separate key icons
            if isFullyUnlocked {
                // Fully complete - show crown
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.gold)
            } else {
                // In progress - show two key icons
                VStack(spacing: 6) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 14))
                        .foregroundColor(hasAllKnowledgeKeys ? .green : (hasAnyKnowledgeKeys ? Theme.Colors.gold.opacity(0.6) : .white.opacity(0.2)))

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(hasDiscoveryKey ? .green : .white.opacity(0.2))
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
        .contentShape(Rectangle()) // Ensure entire card is tappable
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
