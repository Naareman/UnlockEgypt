import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .explore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting
                    headerSection

                    // Tab selector
                    tabSelector

                    // Content based on selected tab
                    switch selectedTab {
                    case .explore:
                        exploreContent
                    case .timeline:
                        timelineContent
                    case .nearby:
                        nearbyContent
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Unlock Egypt")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greeting)
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Image(systemName: viewModel.userProgress.explorerRank.icon)
                Text(viewModel.userProgress.explorerRank.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Badges count
                HStack(spacing: 4) {
                    Image(systemName: "medal.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.userProgress.badges.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 12) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                TabButton(
                    title: tab.title,
                    icon: tab.icon,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
    }

    // MARK: - Explore Content
    private var exploreContent: some View {
        VStack(spacing: 20) {
            // Featured Story
            if let featured = viewModel.featuredSite {
                FeaturedCard(site: featured)
            }

            // Sites by Era
            VStack(alignment: .leading, spacing: 12) {
                Text("Explore by Era")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Era.allCases, id: \.self) { era in
                            EraCard(era: era, siteCount: viewModel.sitesCount(for: era))
                        }
                    }
                }
            }

            // All Sites
            VStack(alignment: .leading, spacing: 12) {
                Text("All Sites")
                    .font(.headline)

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.sites) { site in
                        NavigationLink(destination: SiteDetailView(site: site)) {
                            SiteRow(site: site)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Timeline Content
    private var timelineContent: some View {
        HistoryTimelineView(sites: viewModel.sites)
    }

    // MARK: - Nearby Content
    private var nearbyContent: some View {
        NearbyView(sites: viewModel.sites)
    }
}

// MARK: - Home Tab
enum HomeTab: CaseIterable {
    case explore, timeline, nearby

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .timeline: return "Timeline"
        case .nearby: return "Nearby"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "safari"
        case .timeline: return "clock"
        case .nearby: return "location"
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(uiColor: .systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Featured Card
struct FeaturedCard: View {
    let site: Site

    var body: some View {
        NavigationLink(destination: SiteDetailView(site: site)) {
            ZStack(alignment: .bottomLeading) {
                // Background image placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.orange.opacity(0.8), .brown],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)

                // Overlay content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Featured")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(site.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(site.shortDescription)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Era Card
struct EraCard: View {
    let era: Era
    let siteCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(era.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(era.yearRange)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(siteCount) sites")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Site Row
struct SiteRow: View {
    let site: Site

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "building.columns")
                        .foregroundColor(.orange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)

                Text(site.era.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(site.shortDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
