import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .allSites

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector at top
                tabSelector
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                // Content based on selected tab
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
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Unlock Egypt")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == tab ? Color.accentColor : Color.clear)
                    .foregroundColor(selectedTab == tab ? .white : .secondary)
                }
            }
        }
        .background(Color(uiColor: .systemGray5))
        .cornerRadius(12)
    }
}

// MARK: - Home Tab
enum HomeTab: CaseIterable {
    case allSites, nearby, timeline

    var title: String {
        switch self {
        case .allSites: return "All Sites"
        case .nearby: return "Nearby"
        case .timeline: return "Timeline"
        }
    }

    var icon: String {
        switch self {
        case .allSites: return "square.grid.2x2"
        case .nearby: return "location"
        case .timeline: return "clock"
        }
    }
}

// MARK: - All Sites View with Filters
struct AllSitesView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedEra: Era? = nil
    @State private var selectedType: PlaceType? = nil
    @State private var selectedCity: City? = nil
    @State private var showingFilters = false

    var filteredSites: [Site] {
        viewModel.sites
            .filter { site in
                (selectedEra == nil || site.era == selectedEra) &&
                (selectedType == nil || site.placeType == selectedType) &&
                (selectedCity == nil || site.city == selectedCity)
            }
            .sorted { $0.name < $1.name }
    }

    var activeFiltersCount: Int {
        [selectedEra != nil, selectedType != nil, selectedCity != nil].filter { $0 }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Filter bar
                filterBar

                // Sites count
                HStack {
                    Text("Showing \(filteredSites.count) sites")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)

                // Sites list
                LazyVStack(spacing: 12) {
                    ForEach(filteredSites) { site in
                        NavigationLink(destination: SiteDetailView(site: site)) {
                            SiteRow(site: site)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Era filter
                FilterChip(
                    title: selectedEra?.shortName ?? "Era",
                    isActive: selectedEra != nil,
                    icon: "calendar"
                ) {
                    showFilterMenu(for: .era)
                }
                .contextMenu {
                    Button("All Eras") { selectedEra = nil }
                    Divider()
                    ForEach(Era.allCases, id: \.self) { era in
                        Button(era.rawValue) { selectedEra = era }
                    }
                }

                // Type filter
                FilterChip(
                    title: selectedType?.rawValue ?? "Type",
                    isActive: selectedType != nil,
                    icon: "building.2"
                ) {
                    showFilterMenu(for: .type)
                }
                .contextMenu {
                    Button("All Types") { selectedType = nil }
                    Divider()
                    ForEach(PlaceType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                }

                // City filter
                FilterChip(
                    title: selectedCity?.rawValue ?? "City",
                    isActive: selectedCity != nil,
                    icon: "mappin"
                ) {
                    showFilterMenu(for: .city)
                }
                .contextMenu {
                    Button("All Cities") { selectedCity = nil }
                    Divider()
                    ForEach(City.allCases, id: \.self) { city in
                        Button(city.rawValue) { selectedCity = city }
                    }
                }

                // Clear all
                if activeFiltersCount > 0 {
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

    private func showFilterMenu(for filter: FilterType) {
        // Context menu handles this
    }

    private func clearFilters() {
        withAnimation {
            selectedEra = nil
            selectedType = nil
            selectedCity = nil
        }
    }

    enum FilterType {
        case era, type, city
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
            .background(isActive ? Color.accentColor : Color(uiColor: .systemGray5))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Site Row
struct SiteRow: View {
    let site: Site

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.5), .brown.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: site.placeType.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(site.city.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Label(site.era.shortName, systemImage: "calendar")
                    Label(site.placeType.rawValue, systemImage: site.placeType.icon)
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
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
