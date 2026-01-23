import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: HomeViewModel
    @StateObject private var contentService = ContentService.shared
    @StateObject private var imageCache = ImageCacheService.shared
    @State private var showingResetAlert = false
    @State private var showingClearCacheAlert = false
    @State private var showingDownloadAlert = false
    @State private var showingAchievements = false
    @State private var showingProfileCard = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.darkBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Rank & Achievements Section
                        rankSection

                        // Offline Mode Section
                        offlineModeSection

                        // Content Section
                        contentSection

                        // Progress Section
                        progressSection

                        // About Section
                        aboutSection

                        // Debug Section (only in debug builds)
                        #if DEBUG
                        debugSection
                        #endif
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.Colors.gold)
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingProfileCard) {
                ProfileCardSheet()
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - Rank Section
    private var rankSection: some View {
        SettingsSection(title: "YOUR RANK", icon: viewModel.currentRank.icon) {
            VStack(spacing: 16) {
                // Current rank display
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.currentRank.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if let pointsNeeded = viewModel.pointsToNextRank,
                           let nextRank = viewModel.currentRank.next {
                            Text("\(pointsNeeded) pts to \(nextRank.rawValue)")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.gold)
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Theme.Colors.gold.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: viewModel.currentRank.icon)
                            .font(.title2)
                            .foregroundColor(Theme.Colors.gold)
                    }
                }

                // Progress bar
                if viewModel.currentRank != .pharaoh {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.Colors.gold)
                                .frame(width: geo.size.width * viewModel.rankProgress)
                        }
                    }
                    .frame(height: 6)
                }

                Divider().background(Color.white.opacity(0.1))

                // View achievements button
                Button(action: { showingAchievements = true }) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View All Achievements")
                        Spacer()
                        Text("\(viewModel.unlockedAchievementsCount)/\(Achievements.all.count)")
                            .foregroundColor(.white.opacity(0.5))
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.gold)
                }

                // Share journey button
                Button(action: { showingProfileCard = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Your Journey")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.gold)
                }
            }
        }
    }

    // MARK: - Offline Mode Section
    private var offlineModeSection: some View {
        SettingsSection(title: "OFFLINE MODE", icon: "wifi.slash") {
            VStack(spacing: 16) {
                // Cache status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Downloaded Content")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text(imageCache.cacheSize > 0 ? "Ready for offline use" : "Not downloaded")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(imageCache.formattedCacheSize)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.Colors.gold)

                        if let lastUpdate = imageCache.lastCacheUpdate {
                            Text(lastUpdate, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }

                // Download progress
                if imageCache.isDownloading {
                    VStack(spacing: 8) {
                        ProgressView(value: imageCache.downloadProgress)
                            .tint(Theme.Colors.gold)

                        Text("Downloading \(imageCache.downloadedImages)/\(imageCache.totalImages) images...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: downloadForOffline) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text(imageCache.cacheSize > 0 ? "Update" : "Download")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.Colors.gold)
                        .cornerRadius(10)
                    }
                    .disabled(imageCache.isDownloading)

                    if imageCache.cacheSize > 0 {
                        Button(action: { showingClearCacheAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                imageCache.clearCache()
            }
        } message: {
            Text("This will delete all downloaded content. You'll need an internet connection to view images.")
        }
    }

    // MARK: - Content Section
    private var contentSection: some View {
        SettingsSection(title: "CONTENT", icon: "doc.text") {
            VStack(spacing: 12) {
                HStack {
                    Text("Sites")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(viewModel.sites.count)")
                        .foregroundColor(.white)
                }

                if let lastUpdated = contentService.lastUpdated {
                    HStack {
                        Text("Last Updated")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(lastUpdated, style: .date)
                            .foregroundColor(.white)
                    }
                }

                Divider().background(Color.white.opacity(0.1))

                Button(action: refreshContent) {
                    HStack {
                        if contentService.isLoading {
                            ProgressView()
                                .tint(Theme.Colors.gold)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Check for Updates")
                    }
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.gold)
                }
                .disabled(contentService.isLoading)
            }
            .font(.subheadline)
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        SettingsSection(title: "YOUR PROGRESS", icon: "trophy") {
            VStack(spacing: 12) {
                HStack {
                    Text("Total Points")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Theme.Colors.gold)
                        Text("\(viewModel.totalPoints)")
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.gold)
                    }
                }

                HStack {
                    Text("Scholar Badges")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(viewModel.scholarBadges.count)")
                        .foregroundColor(.white)
                }

                HStack {
                    Text("Explorer Badges")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(viewModel.explorerBadges.count)")
                        .foregroundColor(.white)
                }

                HStack {
                    Text("Quizzes Completed")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(viewModel.completedQuizzes.count)")
                        .foregroundColor(.white)
                }

                Divider().background(Color.white.opacity(0.1))

                Button(action: { showingResetAlert = true }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Progress")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            .font(.subheadline)
        }
        .alert("Reset Progress?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This will reset all your points, badges, and progress. This cannot be undone.")
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        SettingsSection(title: "ABOUT", icon: "info.circle") {
            VStack(spacing: 16) {
                // App info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unlock Egypt")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Discover 5,000 years of history")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    Text("v\(appVersion)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Divider().background(Color.white.opacity(0.1))

                // Credits
                VStack(alignment: .leading, spacing: 8) {
                    Text("Created with love for Egypt")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))

                    Text("Content sources: Ministry of Tourism and Antiquities, UNESCO World Heritage")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().background(Color.white.opacity(0.1))

                // Links
                VStack(spacing: 12) {
                    SettingsLink(
                        title: "Rate the App",
                        icon: "star",
                        action: { /* TODO: Open App Store */ }
                    )

                    SettingsLink(
                        title: "Privacy Policy",
                        icon: "hand.raised",
                        action: { /* TODO: Open privacy policy */ }
                    )

                    SettingsLink(
                        title: "Send Feedback",
                        icon: "envelope",
                        action: { /* TODO: Open email */ }
                    )
                }
            }
        }
    }

    // MARK: - Debug Section
    #if DEBUG
    private var debugSection: some View {
        SettingsSection(title: "DEBUG", icon: "hammer") {
            VStack(spacing: 12) {
                Button("Print Site Data") {
                    for site in viewModel.sites {
                        print("Site: \(site.name)")
                        print("  SubLocations: \(site.subLocations?.count ?? 0)")
                        site.subLocations?.forEach { sub in
                            print("    - \(sub.name): \(sub.storyCards.count) cards")
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(Theme.Colors.gold)

                Button("Clear All Data") {
                    viewModel.resetProgress()
                    imageCache.clearCache()
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
        }
    }
    #endif

    // MARK: - Actions

    private func downloadForOffline() {
        Task {
            await imageCache.downloadAllImages(from: viewModel.sites)
        }
    }

    private func refreshContent() {
        Task {
            await viewModel.refreshContent()
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.gold)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(1)
            }

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Settings Link
struct SettingsLink: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(Theme.Colors.gold)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HomeViewModel())
}
