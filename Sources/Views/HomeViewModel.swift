import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sites: [Site] = []

    init() {
        loadData()
    }

    private func loadData() {
        sites = SampleData.sites
    }

    // MARK: - Filter Helpers
    func sitesCount(for era: Era) -> Int {
        sites.filter { $0.era == era }.count
    }

    func sites(for era: Era) -> [Site] {
        sites.filter { $0.era == era }
    }

    func sites(for city: City) -> [Site] {
        sites.filter { $0.city == city }
    }

    func sites(for placeType: PlaceType) -> [Site] {
        sites.filter { $0.placeType == placeType }
    }
}
