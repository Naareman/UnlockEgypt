import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .allSites
    @State private var showingSettings = false
    @State private var showingAchievements = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 0) {
                    // Custom header
                    headerView
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Encouragement banner (tappable)
                    Button(action: { showingAchievements = true }) {
                        EncouragementBanner(viewModel: viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Tab selector
                    tabSelector
                        .padding(.horizontal)
                        .padding(.vertical, 12)

                    // Content - show loading state if no sites yet
                    if viewModel.sites.isEmpty && viewModel.isLoading {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Theme.Colors.gold)
                            Text("Loading ancient secrets...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    } else {
                        TabView(selection: $selectedTab) {
                            AllSitesView(viewModel: viewModel)
                                .tag(HomeTab.allSites)

                            FavoritesView(viewModel: viewModel)
                                .tag(HomeTab.favorites)

                            NearbyView(sites: viewModel.sites)
                                .tag(HomeTab.nearby)

                            HistoryTimelineView(sites: viewModel.sites)
                                .tag(HomeTab.timeline)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .environmentObject(viewModel)
        .preferredColorScheme(.dark)
        .task {
            // Auto-fetch latest content from GitHub on launch
            await viewModel.refreshContent()
        }
        .overlay {
            // Achievement unlocked notification
            if let achievement = viewModel.recentlyUnlockedAchievement {
                AchievementUnlockedOverlay(
                    achievement: achievement,
                    onDismiss: { viewModel.dismissAchievementNotification() }
                )
            }
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
                .environmentObject(viewModel)
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                (Text("UNLOCK")
                    .foregroundColor(.white)
                + Text(" EGYPT")
                    .foregroundColor(Theme.Colors.gold))
                    .font(.system(size: 28, weight: .black))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer()

                HStack(spacing: 12) {
                    PointsBadge(points: viewModel.totalPoints)

                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 4) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .medium))
                            .frame(width: 24, height: 24)
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab ?
                        Theme.Colors.gold :
                        Theme.Colors.cardBackground
                    )
                    .foregroundColor(selectedTab == tab ? .black : .white.opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Home Tab
enum HomeTab: CaseIterable {
    case allSites, favorites, nearby, timeline

    var title: String {
        switch self {
        case .allSites: return "Explore"
        case .favorites: return "Saved"
        case .nearby: return "Nearby"
        case .timeline: return "Timeline"
        }
    }

    var icon: String {
        switch self {
        case .allSites: return "safari.fill"
        case .favorites: return "heart.fill"
        case .nearby: return "location.fill"
        case .timeline: return "clock.fill"
        }
    }
}

// MARK: - All Sites View with Filters
struct AllSitesView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var searchText = ""
    @State private var selectedEra: Era? = nil
    @State private var selectedType: PlaceType? = nil
    @State private var selectedCity: City? = nil
    @State private var showPeriodFilter = false
    @State private var showTypeFilter = false
    @State private var showCityFilter = false

    var filteredSites: [Site] {
        viewModel.sites
            .filter { site in
                let matchesSearch = searchText.isEmpty ||
                    site.name.localizedCaseInsensitiveContains(searchText) ||
                    site.arabicName.contains(searchText) ||
                    site.shortDescription.localizedCaseInsensitiveContains(searchText) ||
                    site.city.rawValue.localizedCaseInsensitiveContains(searchText) ||
                    site.era.rawValue.localizedCaseInsensitiveContains(searchText) ||
                    site.placeType.rawValue.localizedCaseInsensitiveContains(searchText)

                let matchesFilters = (selectedEra == nil || site.era == selectedEra) &&
                    (selectedType == nil || site.placeType == selectedType) &&
                    (selectedCity == nil || site.city == selectedCity)

                return matchesSearch && matchesFilters
            }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search sites, cities, eras...")
                    .padding(.horizontal)

                // Filter bar
                filterBar

                // Sites count + loading indicator
                HStack {
                    Text("\(filteredSites.count) \(filteredSites.count == 1 ? "site" : "sites")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Theme.Colors.gold)
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal)

                // Sites list
                if filteredSites.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.3))
                        Text("No sites found for \"\(searchText)\"")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSites) { site in
                            NavigationLink(destination: SiteDetailView(site: site)) {
                                SiteCard(site: site)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            // Pull-to-refresh: fetch latest content from GitHub
            await viewModel.refreshContent()
        }
        .sheet(isPresented: $showPeriodFilter) {
            FilterSheet(
                title: "Select Period",
                options: Era.allCases.map { ($0.rawValue, $0) },
                selected: $selectedEra,
                isPresented: $showPeriodFilter
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTypeFilter) {
            FilterSheet(
                title: "Select Type",
                options: PlaceType.allCases.map { ($0.rawValue, $0) },
                selected: $selectedType,
                isPresented: $showTypeFilter
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showCityFilter) {
            FilterSheet(
                title: "Select City",
                options: City.allCases.map { ($0.rawValue, $0) },
                selected: $selectedCity,
                isPresented: $showCityFilter
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: selectedCity?.rawValue ?? "City",
                    isActive: selectedCity != nil,
                    icon: "mappin"
                ) {
                    showCityFilter = true
                }

                FilterChip(
                    title: selectedType?.rawValue ?? "Type",
                    isActive: selectedType != nil,
                    icon: "building.2"
                ) {
                    showTypeFilter = true
                }

                FilterChip(
                    title: selectedEra?.rawValue ?? "Period",
                    isActive: selectedEra != nil,
                    icon: "calendar"
                ) {
                    showPeriodFilter = true
                }

                if selectedEra != nil || selectedType != nil || selectedCity != nil {
                    Button(action: clearFilters) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear")
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func clearFilters() {
        withAnimation {
            selectedEra = nil
            selectedType = nil
            selectedCity = nil
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet<T: Hashable>: View {
    let title: String
    let options: [(String, T)]
    @Binding var selected: T?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selected = nil
                    isPresented = false
                }) {
                    HStack {
                        Text("All")
                        Spacer()
                        if selected == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(Theme.Colors.gold)
                        }
                    }
                }

                ForEach(options, id: \.1) { option in
                    Button(action: {
                        selected = option.1
                        isPresented = false
                    }) {
                        HStack {
                            Text(option.0)
                            Spacer()
                            if selected == option.1 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.gold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isActive: Bool
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Theme.Colors.gold : Theme.Colors.cardBackground)
            .foregroundColor(isActive ? .black : .white)
            .cornerRadius(20)
        }
    }
}

// MARK: - Encouragement Banner
struct EncouragementBanner: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HStack(spacing: 14) {
            // Rank icon with glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.1))
                    .frame(width: 48, height: 48)

                // Inner circle
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: viewModel.currentRank.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Colors.gold)
            }

            // Rank info
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.currentRank.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                // Progress to next rank
                if viewModel.currentRank != .pharaoh {
                    HStack(spacing: 6) {
                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                Capsule()
                                    .fill(Theme.Colors.gold)
                                    .frame(width: geo.size.width * viewModel.rankProgress)
                            }
                        }
                        .frame(width: 60, height: 4)

                        if let pointsNeeded = viewModel.pointsToNextRank {
                            Text("\(pointsNeeded) pts to go")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                } else {
                    Text("Maximum rank achieved!")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Colors.gold)
                }
            }

            Spacer()

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .fill(Theme.Colors.cardBackgroundSubtle)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(
                    LinearGradient(
                        colors: [Theme.Colors.gold.opacity(0.3), Theme.Colors.gold.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Circular Progress
struct CircularProgress: View {
    let progress: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.Colors.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Achievement Unlocked Overlay
struct AchievementUnlockedOverlay: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var isShowing = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(isShowing ? 0.7 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Achievement card
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Theme.Colors.gold.opacity(0.3))
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(Theme.Colors.gold.opacity(0.5))
                        .frame(width: 80, height: 80)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.gold)
                }

                VStack(spacing: 8) {
                    Text("ACHIEVEMENT UNLOCKED! 🏆")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.gold)
                        .tracking(2)

                    Text(achievement.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("+\(achievement.points) points")
                        .font(.headline)
                        .foregroundColor(Theme.Colors.gold)
                        .padding(.top, 8)
                }

                Button(action: dismiss) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.gold)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 32)
            }
            .padding(32)
            .background(Theme.Colors.darkBackground)
            .cornerRadius(24)
            .shadow(color: Theme.Colors.gold.opacity(0.3), radius: 20)
            .padding(40)
            .scaleEffect(isShowing ? 1 : 0.5)
            .opacity(isShowing ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isShowing = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
