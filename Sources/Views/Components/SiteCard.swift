import SwiftUI

/// Card displaying a site with Egyptian styling
struct SiteCard: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel

    /// Has all Knowledge Keys for this site
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

    /// Fully unlocked (all Knowledge Keys + Discovery Key)
    private var isFullyUnlocked: Bool {
        hasAllKnowledgeKeys && hasDiscoveryKey
    }

    private var isFavorite: Bool {
        viewModel.isFavorite(siteId: site.id)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Site icon with completion badge overlay
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.goldGradient)
                        .frame(width: 80, height: 80)

                    Image(systemName: site.placeType.icon)
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(Theme.Colors.gold)
                }

                // Completion badge
                if isFullyUnlocked {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.gold)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .offset(x: 4, y: -4)
                }
            }

            // Site info
            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(site.arabicName)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.gold)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(site.city.rawValue, systemImage: "mappin")
                    Label(site.era.displayName, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)

                // Badge indicators (only show when fully earned)
                HStack(spacing: 6) {
                    if hasAllKnowledgeKeys {
                        SiteCardBadge(type: .knowledge)
                    }
                    if hasDiscoveryKey {
                        SiteCardBadge(type: .discovery)
                    }
                }
            }

            Spacer()

            // Favorite button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleFavorite(siteId: site.id)
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(isFavorite ? .red : .white.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Site Card Badge
struct SiteCardBadge: View {
    enum BadgeType {
        case knowledge
        case discovery
    }

    let type: BadgeType

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: type == .knowledge ? "key.fill" : "mappin.circle.fill")
                .font(.system(size: 10))
            Text(type == .knowledge ? "Knowledge" : "Discovery")
                .font(.system(size: 9, weight: .medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Theme.Colors.gold)
        .foregroundColor(.black)
        .cornerRadius(8)
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
