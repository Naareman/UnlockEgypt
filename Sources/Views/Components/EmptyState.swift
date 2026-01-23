import SwiftUI

/// Reusable empty state view with consistent styling
struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.08))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Theme.Colors.gold.opacity(0.12))
                    .frame(width: 88, height: 88)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(Theme.Colors.gold.opacity(0.6))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.Colors.gold)
                        .cornerRadius(Theme.Radius.pill)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

/// Empty state specifically for search results
struct SearchEmptyState: View {
    let searchText: String

    var body: some View {
        EmptyState(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No sites found for \"\(searchText)\"\nTry a different search term"
        )
    }
}

/// Empty state for favorites
struct FavoritesEmptyState: View {
    var body: some View {
        EmptyState(
            icon: "heart",
            title: "No Saved Secrets",
            message: "Tap the heart icon on any site to save it here for quick access"
        )
    }
}

/// Empty state for nearby (no location)
struct LocationEmptyState: View {
    let action: () -> Void

    var body: some View {
        EmptyState(
            icon: "location.slash",
            title: "Location Disabled",
            message: "Enable location access to discover historical sites near you",
            actionTitle: "Enable Location",
            action: action
        )
    }
}

/// Loading state with skeleton cards
struct LoadingState: View {
    var cardCount: Int = 3

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<cardCount, id: \.self) { _ in
                SkeletonCard()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        GradientBackground()
        ScrollView {
            VStack(spacing: 40) {
                EmptyState(
                    icon: "star",
                    title: "No Achievements Yet",
                    message: "Start exploring to unlock achievements",
                    actionTitle: "Start Exploring",
                    action: {}
                )

                SearchEmptyState(searchText: "Pyramids")

                FavoritesEmptyState()

                LoadingState()
            }
        }
    }
}
