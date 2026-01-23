import SwiftUI

// MARK: - Profile Card View (Shareable)
struct ProfileCardView: View {
    let rank: UserRank
    let points: Int
    let knowledgeKeys: Int
    let discoveryKeys: Int
    let achievements: Int
    let totalAchievements: Int
    let sitesUnlocked: Int
    let totalSites: Int

    var body: some View {
        VStack(spacing: 0) {
            // Header with rank
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.gold.opacity(0.3))
                        .frame(width: 80, height: 80)

                    Image(systemName: rank.icon)
                        .font(.system(size: 36))
                        .foregroundColor(Theme.Colors.gold)
                }

                Text(rank.rawValue.uppercased())
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .tracking(3)

                Text("\(points) Ankh Points")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.gold)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Theme.Colors.gold.opacity(0.2), Theme.Colors.darkBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Stats
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    ProfileStatItem(
                        value: "\(knowledgeKeys)",
                        label: "Knowledge Keys",
                        icon: "key.fill",
                        color: Theme.Colors.gold
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.2))

                    ProfileStatItem(
                        value: "\(discoveryKeys)",
                        label: "Discovery Keys",
                        icon: "key.horizontal.fill",
                        color: .cyan
                    )
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                HStack(spacing: 0) {
                    ProfileStatItem(
                        value: "\(achievements)/\(totalAchievements)",
                        label: "Achievements",
                        icon: "trophy.fill",
                        color: .orange
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.2))

                    ProfileStatItem(
                        value: "\(sitesUnlocked)/\(totalSites)",
                        label: "Sites Unlocked",
                        icon: "mappin.circle.fill",
                        color: .green
                    )
                }
            }
            .padding(.vertical, 20)
            .background(Theme.Colors.darkBackground)

            // Footer
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(Theme.Colors.gold)
                Text("UNLOCK EGYPT")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(2)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.05))
        }
        .frame(width: 300)
        .background(Theme.Colors.darkBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Colors.gold.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Theme.Colors.gold.opacity(0.2), radius: 20)
    }
}

// MARK: - Profile Stat Item
struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Card Sheet
struct ProfileCardSheet: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.darkBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Your Journey")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))

                    profileCard

                    // Share button
                    Button(action: shareCard) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Your Journey")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.gold)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.Colors.gold)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var profileCard: ProfileCardView {
        ProfileCardView(
            rank: viewModel.currentRank,
            points: viewModel.totalPoints,
            knowledgeKeys: viewModel.scholarBadges.count,
            discoveryKeys: viewModel.explorerBadges.count,
            achievements: viewModel.unlockedAchievementsCount,
            totalAchievements: Achievements.all.count,
            sitesUnlocked: viewModel.fullyUnlockedSitesCount,
            totalSites: viewModel.sites.count
        )
    }

    private func shareCard() {
        ShareService.shareProfileCard(
            rank: viewModel.currentRank,
            points: viewModel.totalPoints,
            knowledgeKeys: viewModel.scholarBadges.count,
            discoveryKeys: viewModel.explorerBadges.count,
            achievements: viewModel.unlockedAchievementsCount,
            totalAchievements: Achievements.all.count
        )
    }
}

#Preview {
    ProfileCardView(
        rank: .historian,
        points: 450,
        knowledgeKeys: 8,
        discoveryKeys: 5,
        achievements: 7,
        totalAchievements: 12,
        sitesUnlocked: 3,
        totalSites: 5
    )
    .padding()
    .background(Color.black)
}
