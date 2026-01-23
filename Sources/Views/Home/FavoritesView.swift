import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.favoriteSitesList.isEmpty {
                    emptyState
                } else {
                    // Header
                    HStack {
                        Text("\(viewModel.favoriteSitesList.count) saved secrets")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Favorites list
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.favoriteSitesList) { site in
                            NavigationLink(destination: SiteDetailView(site: site)) {
                                FavoriteSiteCard(site: site, viewModel: viewModel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.gold.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No Saved Secrets Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("Tap the heart icon on any site to save it here for quick access.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

// MARK: - Favorite Site Card
struct FavoriteSiteCard: View {
    let site: Site
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Site image
            AsyncImage(url: URL(string: site.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Theme.Colors.cardBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.3))
                        )
                case .empty:
                    Rectangle()
                        .fill(Theme.Colors.cardBackground)
                        .overlay(ProgressView().tint(.white.opacity(0.5)))
                @unknown default:
                    Rectangle()
                        .fill(Theme.Colors.cardBackground)
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)

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

                // Badges
                HStack(spacing: 6) {
                    if viewModel.hasScholarBadge(for: site.id) {
                        BadgeIndicator(type: .knowledge, isEarned: true)
                    }
                    if viewModel.hasExplorerBadge(for: site.id) {
                        BadgeIndicator(type: .discovery, isEarned: true)
                    }
                }
            }

            Spacer()

            // Remove from favorites button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleFavorite(siteId: site.id)
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Badge Indicator
struct BadgeIndicator: View {
    enum BadgeIndicatorType {
        case knowledge
        case discovery
    }

    let type: BadgeIndicatorType
    let isEarned: Bool

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: type == .knowledge ? "key.fill" : "key.horizontal.fill")
                .font(.system(size: 10))
            Text(type == .knowledge ? "Knowledge" : "Discovery")
                .font(.system(size: 9, weight: .medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(isEarned ? (type == .knowledge ? Theme.Colors.gold : .cyan) : Color.gray)
        .foregroundColor(type == .knowledge ? .black : .white)
        .cornerRadius(8)
        .opacity(isEarned ? 1 : 0.3)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            GradientBackground()
            FavoritesView(viewModel: HomeViewModel())
        }
    }
    .preferredColorScheme(.dark)
}
