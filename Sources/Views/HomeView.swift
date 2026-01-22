import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .allSites

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

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
                        .foregroundColor(Color(hex: "d4af37")) // Gold

                    Text("Discover 5,000 years of history")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Profile/Points button
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "d4af37").opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "d4af37"))
                    }
                    Text("\(viewModel.totalPoints) pts")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "d4af37"))
                }
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
                        Color(hex: "d4af37") :
                        Color.white.opacity(0.1)
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
                    title: selectedEra?.shortName ?? "Era",
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
                                .foregroundColor(Color(hex: "d4af37"))
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
                                    .foregroundColor(Color(hex: "d4af37"))
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
            .background(isActive ? Color(hex: "d4af37") : Color.white.opacity(0.1))
            .foregroundColor(isActive ? .black : .white)
            .cornerRadius(20)
        }
    }
}

// MARK: - Site Card (Dark Theme)
struct SiteCard: View {
    let site: Site

    var body: some View {
        HStack(spacing: 14) {
            // Enhanced image placeholder with Egyptian styling
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color(hex: "d4af37").opacity(0.35), Color(hex: "8b7355").opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                // Decorative border pattern
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color(hex: "d4af37").opacity(0.5), Color(hex: "d4af37").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: site.placeType.icon)
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(Color(hex: "d4af37"))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text(site.city.rawValue)
                        .font(.caption)
                }
                .foregroundColor(Color(hex: "d4af37"))

                HStack(spacing: 12) {
                    Label(site.era.shortName, systemImage: "calendar")
                    if let subLocations = site.subLocations {
                        Label("\(subLocations.count) places", systemImage: "rectangle.stack")
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Arrow indicator
            VStack {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(hex: "d4af37").opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "d4af37").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
