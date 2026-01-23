import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.darkBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Rank Section
                        rankSection

                        // Stats Summary
                        statsSummary

                        // Achievements by Category
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            achievementSection(for: category)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Theme.Colors.gold)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.Colors.gold)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ProfileCardSheet()
                    .environmentObject(viewModel)
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Rank Section
    private var rankSection: some View {
        VStack(spacing: 16) {
            // Current Rank
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.gold.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: viewModel.currentRank.icon)
                        .font(.system(size: 36))
                        .foregroundColor(Theme.Colors.gold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR RANK")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1)

                    Text(viewModel.currentRank.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let pointsNeeded = viewModel.pointsToNextRank,
                       let nextRank = viewModel.currentRank.next {
                        Text("\(pointsNeeded) points to \(nextRank.rawValue)")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.gold)
                    } else {
                        Text("Maximum rank achieved!")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.gold)
                    }
                }

                Spacer()
            }

            // Progress to next rank
            if viewModel.currentRank != .pharaoh {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.Colors.gold)
                                .frame(width: geo.size.width * viewModel.rankProgress)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(viewModel.totalPoints) pts")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        if let max = viewModel.currentRank.maxPoints {
                            Text("\(max) pts")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.gold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Stats Summary
    private var statsSummary: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(viewModel.scholarBadges.count)",
                label: "Knowledge Keys",
                icon: "key.fill"
            )

            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))

            StatItem(
                value: "\(viewModel.explorerBadges.count)",
                label: "Discovery Keys",
                icon: "mappin.circle.fill"
            )

            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))

            StatItem(
                value: "\(viewModel.unlockedAchievementsCount)/\(Achievements.all.count)",
                label: "Unlocked",
                icon: "trophy.fill"
            )
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Achievement Section
    private func achievementSection(for category: AchievementCategory) -> some View {
        let categoryAchievements = Achievements.all.filter { $0.category == category }
        let unlockedCount = categoryAchievements.filter { viewModel.achievementProgress.isUnlocked($0.id) }.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Theme.Colors.gold)
                Text(category.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(1)
                Spacer()
                Text("\(unlockedCount)/\(categoryAchievements.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            VStack(spacing: 8) {
                ForEach(categoryAchievements) { achievement in
                    AchievementRow(
                        achievement: achievement,
                        isUnlocked: viewModel.achievementProgress.isUnlocked(achievement.id),
                        progress: viewModel.getAchievementProgress(achievement)
                    )
                }
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.gold)
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

// MARK: - Achievement Row
struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: (current: Int, required: Int)

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Theme.Colors.gold.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)

                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isUnlocked ? Theme.Colors.gold : .white.opacity(0.3))
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))

                // Progress bar for locked achievements
                if !isUnlocked && progress.required > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.Colors.gold.opacity(0.5))
                                .frame(width: geo.size.width * CGFloat(progress.current) / CGFloat(progress.required))
                        }
                    }
                    .frame(height: 4)
                }
            }

            Spacer()

            // Status
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Text("\(progress.current)/\(progress.required)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? Theme.Colors.gold.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    AchievementsView()
        .environmentObject(HomeViewModel())
}
