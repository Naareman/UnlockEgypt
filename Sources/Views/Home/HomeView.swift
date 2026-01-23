import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .allSites

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 0) {
                    // Custom header
                    headerView
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Tab selector
                    tabSelector
                        .padding(.horizontal)
                        .padding(.vertical, 12)

                    // Content
                    TabView(selection: $selectedTab) {
                        AllSitesView(viewModel: viewModel)
                            .tag(HomeTab.allSites)

                        NearbyView(sites: viewModel.sites)
                            .tag(HomeTab.nearby)

                        HistoryTimelineView(sites: viewModel.sites)
                            .tag(HomeTab.timeline)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .environmentObject(viewModel)
        .preferredColorScheme(.dark)
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("UNLOCK")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                    + Text(" EGYPT")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Theme.Colors.gold)

                    Text("Discover 5,000 years of history")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                PointsBadge(points: viewModel.totalPoints)
            }
        }
        .padding(.vertical, 8)
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
    case allSites, nearby, timeline

    var title: String {
        switch self {
        case .allSites: return "Explore"
        case .nearby: return "Nearby"
        case .timeline: return "Timeline"
        }
    }

    var icon: String {
        switch self {
        case .allSites: return "safari.fill"
        case .nearby: return "location.fill"
        case .timeline: return "clock.fill"
        }
    }
}

// MARK: - All Sites View with Filters
struct AllSitesView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedEra: Era? = nil
    @State private var selectedType: PlaceType? = nil
    @State private var selectedCity: City? = nil
    @State private var showEraFilter = false
    @State private var showTypeFilter = false
    @State private var showCityFilter = false

    var filteredSites: [Site] {
        viewModel.sites
            .filter { site in
                (selectedEra == nil || site.era == selectedEra) &&
                (selectedType == nil || site.placeType == selectedType) &&
                (selectedCity == nil || site.city == selectedCity)
            }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Filter bar
                filterBar

                // Sites count
                HStack {
                    Text("\(filteredSites.count) sites to explore")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal)

                // Sites list
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
            .padding(.vertical)
        }
        .sheet(isPresented: $showEraFilter) {
            FilterSheet(
                title: "Select Era",
                options: Era.allCases.map { ($0.rawValue, $0) },
                selected: $selectedEra,
                isPresented: $showEraFilter
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
                    title: selectedEra?.rawValue ?? "Era",
                    isActive: selectedEra != nil,
                    icon: "calendar"
                ) {
                    showEraFilter = true
                }

                FilterChip(
                    title: selectedType?.rawValue ?? "Type",
                    isActive: selectedType != nil,
                    icon: "building.2"
                ) {
                    showTypeFilter = true
                }

                FilterChip(
                    title: selectedCity?.rawValue ?? "City",
                    isActive: selectedCity != nil,
                    icon: "mappin"
                ) {
                    showCityFilter = true
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

// MARK: - Preview
#Preview {
    HomeView()
}
