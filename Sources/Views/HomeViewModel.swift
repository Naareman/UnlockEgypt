import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var totalPoints: Int = 0
    @Published var discoveredPlaces: Set<String> = []
    @Published var completedQuizzes: Set<String> = []
    @Published var completedSubLocations: Set<String> = []

    private let pointsKey = "totalPoints"
    private let discoveredKey = "discoveredPlaces"
    private let quizzesKey = "completedQuizzes"
    private let completedKey = "completedSubLocations"

    init() {
        loadData()
        loadProgress()
    }

    private func loadData() {
        sites = SampleData.sites
    }

    private func loadProgress() {
        // Load from UserDefaults
        totalPoints = UserDefaults.standard.integer(forKey: pointsKey)

        if let discovered = UserDefaults.standard.array(forKey: discoveredKey) as? [String] {
            discoveredPlaces = Set(discovered)
        }
        if let quizzes = UserDefaults.standard.array(forKey: quizzesKey) as? [String] {
            completedQuizzes = Set(quizzes)
        }
        if let completed = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedSubLocations = Set(completed)
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(totalPoints, forKey: pointsKey)
        UserDefaults.standard.set(Array(discoveredPlaces), forKey: discoveredKey)
        UserDefaults.standard.set(Array(completedQuizzes), forKey: quizzesKey)
        UserDefaults.standard.set(Array(completedSubLocations), forKey: completedKey)
    }

    // MARK: - Gamification

    /// Award 1 point for discovering a new place (story card)
    func discoverPlace(_ placeId: String) {
        if !discoveredPlaces.contains(placeId) {
            discoveredPlaces.insert(placeId)
            addPoints(1)
            saveProgress()
        }
    }

    /// Award 10 points for correct quiz answer
    func correctQuizAnswer(_ quizId: String) {
        if !completedQuizzes.contains(quizId) {
            completedQuizzes.insert(quizId)
            addPoints(10)
            saveProgress()
        }
    }

    /// Mark a sub-location as completed
    func completeSubLocation(_ subLocationId: String) {
        if !completedSubLocations.contains(subLocationId) {
            completedSubLocations.insert(subLocationId)
            saveProgress()
        }
    }

    /// Check if a sub-location is completed
    func isSubLocationCompleted(_ subLocationId: String) -> Bool {
        completedSubLocations.contains(subLocationId)
    }

    private func addPoints(_ points: Int) {
        withAnimation {
            totalPoints += points
        }
    }

    // MARK: - Reset (for testing)
    func resetProgress() {
        totalPoints = 0
        discoveredPlaces.removeAll()
        completedQuizzes.removeAll()
        completedSubLocations.removeAll()
        saveProgress()
    }

    // MARK: - Filter Helpers
    func sitesCount(for era: Era) -> Int {
        sites.filter { $0.era == era }.count
    }

    func sites(for era: Era) -> [Site] {
        sites.filter { $0.era == era }
    }
}
