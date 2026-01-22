import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var userProgress: UserProgress = UserProgress()
    @Published var featuredSite: Site?

    init() {
        loadData()
    }

    // MARK: - Data Loading
    private func loadData() {
        // For now, load sample data
        // Later this can be replaced with JSON loading or API calls
        sites = SampleData.sites
        featuredSite = sites.first
    }

    // MARK: - Computed Properties
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning, Explorer!"
        case 12..<17:
            return "Good afternoon, Explorer!"
        case 17..<21:
            return "Good evening, Explorer!"
        default:
            return "Welcome back, Explorer!"
        }
    }

    // MARK: - Helper Methods
    func sitesCount(for era: Era) -> Int {
        sites.filter { $0.era == era }.count
    }

    func sites(for era: Era) -> [Site] {
        sites.filter { $0.era == era }
    }

    func unlockSite(_ siteId: String) {
        userProgress.unlockSite(siteId)
    }

    func markSiteVisited(_ siteId: String) {
        userProgress.markSiteVisited(siteId)
    }
}
